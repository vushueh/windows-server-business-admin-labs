# Project 001 — AD UNIX Attributes + SSSD Linux VM Integration

> Imported from the former `homelab-projects` repo during repo consolidation.
> This belongs in Windows Server Project 13 because it is really an enterprise
> identity integration project: Active Directory becomes the central login
> source for Linux VMs.

**Difficulty:** Advanced  
**Estimated time:** 3–5 hours  
**Status:** 🟡 Queued  
**Last updated:** 2026-06-04

---

## What This Project Does

Integrates all Linux VMs in the homelab with Active Directory (`Chongong.local`) so that:

- Every AD user can log into any Linux VM with their **domain credentials**
- No more per-VM local accounts (`leonel`, `analyst`, etc.)
- Sudo rights are controlled by **AD group membership** (e.g. `IT-Users` get sudo)
- SSH keys can optionally be stored in AD and fetched at login
- Home directories are created automatically on first login
- Password changes in AD propagate to all Linux VMs immediately

This mirrors how enterprise Linux infrastructure works in real organizations.

---

## Architecture

```
 Chongong.local Domain Controller
  WIN-PRQD8TJG04M (192.168.20.11)
         |
         |  LDAP / Kerberos (TCP 389, 636, 88, 464)
         |
  +------+-------+--------+----------+----------+
  |      |       |        |          |          |
  SO     Wazuh   Kali   OpenCTI   HQ-Wazuh   Ingest
 30.10  40.x   40.124   30.35     10.156     10.189

All Linux VMs authenticate via SSSD → AD
Sudo rules enforced by AD group membership
```

---

## Prerequisites

Before starting, verify all of these:

- [ ] `Chongong.local` AD is running on WIN-PRQD8TJG04M
- [ ] All target Linux VMs have SSH access established (homelab_master key)
- [ ] DNS on each Linux VM resolves `WIN-PRQD8TJG04M.Chongong.local`
- [ ] TCP ports 389 (LDAP), 88 (Kerberos), 464 (kpasswd) open between Linux VMs and DC
- [ ] AD user accounts exist for the people who need Linux access
- [ ] A dedicated AD service account created for SSSD bind (e.g. `sssd-bind`)

---

## Target Linux VMs

| VM | IP | OS | Priority |
|----|----|----|----------|
| HQ-Wazuh-SIEM | 192.168.10.156 | Ubuntu 22.04 | High |
| Wazuh-Ingest-VM | 192.168.10.189 | Ubuntu 22.04 | High |
| SecurityOnion | 192.168.30.10 | Oracle Linux 9.7 | Medium |
| Kali-VLAN40 | 192.168.40.124 | Kali Linux | Medium |
| OpenCTI | 192.168.30.35 | Linux (unknown) | Low |

---

## Phase 1 — Prepare Active Directory

### 1.1 Create SSSD Service Account

On the Domain Controller (WIN-PRQD8TJG04M):

```powershell
# Create a dedicated bind account for SSSD LDAP queries
New-ADUser -Name "sssd-bind" `
    -SamAccountName "sssd-bind" `
    -UserPrincipalName "sssd-bind@Chongong.local" `
    -AccountPassword (ConvertTo-SecureString "<STRONG_PASSWORD>" -AsPlainText -Force) `
    -PasswordNeverExpires $true `
    -CannotChangePassword $true `
    -Enabled $true `
    -Description "Service account for SSSD LDAP bind on Linux VMs"

# Lock it down - read-only access only
Add-ADGroupMember -Identity "Domain Users" -Members "sssd-bind"
```

> **Security note:** Use a long random password. Store it in a password manager. It will be placed in `/etc/sssd/sssd.conf` on each Linux VM (file is root-only, mode 0600).

### 1.2 Add UNIX Attributes to AD Users

Run on the Domain Controller for each user who needs Linux access:

```powershell
# Enable Identity Management for Unix on the schema (if not already done)
# Check if Unix attributes are available:
Get-ADUser administrator -Properties uidNumber

# If uidNumber is not available, install the Identity Management for Unix feature:
Install-WindowsFeature Server-for-NFS -IncludeManagementTools
```

**Option A — Using Altdisplay (if RFC2307 schema extension available):**

```powershell
$users = @(
    @{ Sam="chongong.leonel";  UID=10001; GID=10000; Home="/home/chongong.leonel";  Shell="/bin/bash" },
    @{ Sam="vushueh.banks";    UID=10002; GID=10000; Home="/home/vushueh.banks";    Shell="/bin/bash" },
    @{ Sam="akaseng.frankline";UID=10003; GID=10000; Home="/home/akaseng.frankline";Shell="/bin/bash" },
    @{ Sam="lionel.chongong"; UID=10004; GID=10000; Home="/home/lionel.chongong"; Shell="/bin/bash" },
    @{ Sam="elsa.chongong";   UID=10005; GID=10000; Home="/home/elsa.chongong";   Shell="/bin/bash" }
)

foreach ($u in $users) {
    Set-ADUser $u.Sam -Replace @{
        uidNumber    = $u.UID
        gidNumber    = $u.GID
        unixHomeDirectory = $u.Home
        loginShell   = $u.Shell
    }
    Write-Host "Set UNIX attrs for $($u.Sam)"
}
```

**Option B — SSSD with id_provider=ad (no UNIX attributes needed):**  
SSSD can auto-generate UID/GID from the SID using `ldap_id_mapping = true`.  
This is simpler but gives non-deterministic UIDs across VMs.
Recommend Option A for consistent UIDs across all VMs.

### 1.3 Create Linux-specific AD Groups

```powershell
# Group for users allowed to SSH into Linux VMs
New-ADGroup -Name "Linux-Users" -GroupScope Global -GroupCategory Security `
    -Description "Users allowed to SSH into Linux VMs"

# Group for users who get sudo on Linux VMs
New-ADGroup -Name "Linux-Admins" -GroupScope Global -GroupCategory Security `
    -Description "Users who get passwordless sudo on Linux VMs"

# Populate
Add-ADGroupMember -Identity "Linux-Users"  -Members "chongong.leonel","vushueh.banks","akaseng.frankline","lionel.chongong","elsa.chongong"
Add-ADGroupMember -Identity "Linux-Admins" -Members "vushueh.banks","akaseng.frankline"
```

### 1.4 Create Organizational Units

```powershell
# Organize VMs and service accounts into OUs
New-ADOrganizationalUnit -Name "Linux-Servers" -Path "DC=Chongong,DC=local"
New-ADOrganizationalUnit -Name "Service-Accounts" -Path "DC=Chongong,DC=local"
New-ADOrganizationalUnit -Name "Workstations" -Path "DC=Chongong,DC=local"

# Move service account
Move-ADObject -Identity (Get-ADUser sssd-bind).DistinguishedName `
    -TargetPath "OU=Service-Accounts,DC=Chongong,DC=local"
```

---

## Phase 2 — Configure Each Linux VM

Repeat Phase 2 on every target Linux VM. Order: HQ-Wazuh-SIEM first (Ubuntu, most straightforward).

### 2.1 Set DNS to Point to Domain Controller

```bash
# Ubuntu / Debian
sudo nano /etc/systemd/resolved.conf
# Add:
# [Resolve]
# DNS=192.168.20.11
# Domains=Chongong.local

sudo systemctl restart systemd-resolved

# Verify
resolvectl status
nslookup WIN-PRQD8TJG04M.Chongong.local
```

```bash
# Oracle Linux / RHEL (SecurityOnion)
sudo nmcli con mod <connection-name> ipv4.dns 192.168.20.11
sudo nmcli con mod <connection-name> ipv4.dns-search Chongong.local
sudo nmcli con up <connection-name>
```

### 2.2 Install Required Packages

**Ubuntu / Debian:**
```bash
sudo apt-get install -y \
    sssd \
    sssd-ad \
    sssd-tools \
    realmd \
    adcli \
    krb5-user \
    samba-common-bin \
    oddjob \
    oddjob-mkhomedir \
    packagekit
```

**Oracle Linux / RHEL (SecurityOnion):**
```bash
sudo dnf install -y \
    sssd \
    sssd-ad \
    sssd-tools \
    realmd \
    adcli \
    krb5-workstation \
    oddjob \
    oddjob-mkhomedir \
    samba-common-tools
```

**Kali Linux:**
```bash
sudo apt-get install -y sssd sssd-ad realmd adcli krb5-user oddjob oddjob-mkhomedir
```

### 2.3 Configure Kerberos

```bash
sudo nano /etc/krb5.conf
```

```ini
[libdefaults]
    default_realm = CHONGONG.LOCAL
    dns_lookup_realm = true
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    CHONGONG.LOCAL = {
        kdc = WIN-PRQD8TJG04M.Chongong.local
        admin_server = WIN-PRQD8TJG04M.Chongong.local
    }

[domain_realm]
    .chongong.local = CHONGONG.LOCAL
    chongong.local = CHONGONG.LOCAL
```

### 2.4 Join the Domain with realm

```bash
# Discover the domain
realm discover Chongong.local

# Join (uses a domain admin account interactively)
sudo realm join --user=Administrator Chongong.local

# Verify
realm list
```

Expected output:
```
chongong.local
  type: kerberos
  realm-name: CHONGONG.LOCAL
  domain-name: chongong.local
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  login-formats: %U@chongong.local
  login-policy: allow-realm-logins
```

### 2.5 Configure SSSD

```bash
sudo nano /etc/sssd/sssd.conf
```

```ini
[sssd]
domains = Chongong.local
config_file_version = 2
services = nss, pam, ssh

[domain/Chongong.local]
ad_domain = Chongong.local
krb5_realm = CHONGONG.LOCAL
realmd_tags = manages-system joined-with-adcli
cache_credentials = true
id_provider = ad
krb5_store_password_if_offline = true
default_shell = /bin/bash
ldap_id_mapping = false
use_fully_qualified_names = false
fallback_homedir = /home/%u
access_provider = ad

# Restrict login to Linux-Users group only
ldap_access_order = filter
ldap_access_filter = (memberOf=CN=Linux-Users,DC=Chongong,DC=local)

# UNIX attribute mapping
ldap_user_uid_number = uidNumber
ldap_user_gid_number = gidNumber
ldap_user_home_directory = unixHomeDirectory
ldap_user_shell = loginShell

# Performance
cache_credentials = true
krb5_store_password_if_offline = true
entry_cache_timeout = 600
```

```bash
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl enable sssd
sudo systemctl restart sssd
```

### 2.6 Configure PAM for Home Directory Creation

```bash
# Ubuntu
sudo pam-auth-update --enable mkhomedir

# RHEL / Oracle Linux
sudo authselect select sssd with-mkhomedir --force
sudo systemctl enable --now oddjobd
```

### 2.7 Configure Sudo via AD Groups

```bash
sudo nano /etc/sudoers.d/ad-admins
```

```
# AD Linux-Admins group gets passwordless sudo
%Linux-Admins@Chongong.local ALL=(ALL) NOPASSWD:ALL
```

```bash
sudo chmod 440 /etc/sudoers.d/ad-admins
sudo visudo -cf /etc/sudoers.d/ad-admins
```

### 2.8 Configure SSH to Accept AD Users

```bash
sudo nano /etc/ssh/sshd_config
```

Add or verify:
```
# Allow AD group to SSH in
AllowGroups Linux-Users@Chongong.local sudo

# Enable GSSAPI for Kerberos SSO (optional)
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes

# Keep existing key auth working
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

```bash
sudo systemctl reload sshd
```

---

## Phase 3 — Advanced: SSH Keys Stored in AD

This allows SSH public keys to be stored as an AD attribute and fetched by SSSD at login — no need to deploy keys to each VM manually.

### 3.1 Extend AD Schema with altSecurityIdentities

The `altSecurityIdentities` attribute already exists in AD and supports SSH key storage.

### 3.2 Store SSH Key in AD

```powershell
# On the Domain Controller
# Add the user’s SSH public key to their AD account
Set-ADUser -Identity "vushueh.banks" -Add @{
    altSecurityIdentities = "SSHKey: ssh-ed25519 AAAA...rest-of-key... vushueh@homelab"
}
```

### 3.3 Configure SSSD to Fetch SSH Keys from AD

Add to `/etc/sssd/sssd.conf`:
```ini
[domain/Chongong.local]
# ... existing config ...
ldap_user_extra_attrs = altSecurityIdentities:sshkeys
ldap_user_ssh_public_key = altSecurityIdentities
```

Add to `/etc/ssh/sshd_config`:
```
AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
AuthorizedKeysCommandUser nobody
```

```bash
sudo systemctl reload sshd
sudo systemctl restart sssd
```

Result: `ssh vushueh.banks@192.168.10.156` authenticates using the key stored in AD.

---

## Phase 4 — Verification

Run these on each Linux VM after setup:

```bash
# 1. Resolve AD user
id vushueh.banks@Chongong.local
# Expected: uid=10002(vushueh.banks) gid=10000(domain users) groups=...

# 2. List AD users visible to the VM
getent passwd | grep Chongong

# 3. Test Kerberos ticket
kinit vushueh.banks@CHONGONG.LOCAL
klist

# 4. Test SSH as AD user
ssh vushueh.banks@Chongong.local@192.168.10.156

# 5. Verify sudo
ssh akaseng.frankline@Chongong.local@192.168.10.156 sudo whoami
# Expected: root

# 6. Check home dir was created
ls -la /home/
```

---

## Phase 5 — Rollback Plan

If something goes wrong on a VM:

```bash
# Leave the domain (non-destructive — local accounts still work)
sudo realm leave Chongong.local

# Remove SSSD
sudo systemctl stop sssd
sudo apt-get remove --purge sssd sssd-ad realmd adcli -y  # Ubuntu
sudo dnf remove sssd realmd adcli -y                       # RHEL/OL

# Restore original SSH config
sudo nano /etc/ssh/sshd_config  # remove the AllowGroups line
sudo systemctl reload sshd

# Local accounts (leonel, etc.) continue to work throughout
```

---

## Phase 6 — Group Policy Equivalent on Linux (SSSD + Kerberos)

For an enterprise feel, configure these after SSSD is stable:

1. **Password policy enforcement** — AD password complexity rules apply to domain logins automatically
2. **Account lockout** — SSSD respects AD lockout policies
3. **Offline caching** — SSSD caches credentials so users can log in even if DC is unreachable
4. **Centralized audit logging** — forward PAM auth events from Linux VMs to Wazuh SIEM

---

## Execution Order

```
1. Phase 1 on DC (30 min)
   ├─ 1.1 Create sssd-bind account
   ├─ 1.2 Add UNIX attributes to users
   ├─ 1.3 Create Linux-Users and Linux-Admins groups
   └─ 1.4 Create OUs

2. Phase 2 on HQ-Wazuh-SIEM first (45 min) — use as test VM
   ├─ 2.1 Set DNS
   ├─ 2.2 Install packages
   ├─ 2.3 Configure Kerberos
   ├─ 2.4 Join domain
   ├─ 2.5 Configure SSSD
   ├─ 2.6 Configure PAM
   ├─ 2.7 Configure sudo
   └─ 2.8 Configure SSH

3. Phase 4 — Verify on HQ-Wazuh-SIEM (15 min)

4. Repeat Phase 2+4 on remaining VMs (30 min each)
   Wazuh-Ingest → SecurityOnion → Kali → OpenCTI

5. Phase 3 (optional) — SSH keys in AD (30 min)

6. Phase 6 (optional) — Wazuh integration for audit logging
```

---

## Security Considerations

- The `sssd-bind` account password must be strong and stored in a password manager only
- `/etc/sssd/sssd.conf` must be `chmod 600` and `chown root:root` on every VM
- `Linux-Admins` group grants `NOPASSWD:ALL` sudo — keep membership minimal
- Consider enabling `ldap_tls_reqcert = demand` with LDAPS (port 636) for encrypted LDAP in production
- SecurityOnion has its own host firewall — ensure AD ports are allowed in nftables

---

## To Start This Project

Tell Claude:
> *"Let’s work on homelab project 001 — AD SSSD Linux integration"*

Claude will read this spec and guide you through each phase interactively.

---

*Project spec authored 2026-06-04. Difficulty: Advanced.*
