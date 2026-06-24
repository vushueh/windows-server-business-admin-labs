---
name: windows-server-business-admin
description: >
  Windows Server Business Admin Labs — 13 projects building a complete small-business
  Microsoft environment and integrating it as the identity backbone for all homelab families.
  Trigger when Leonel says: "windows server project", "AD project", "M365 project",
  "windows admin", "start project 01-13", mentions Active Directory, Group Policy,
  NPS/RADIUS for Windows, Entra ID, Microsoft 365, Hyper-V operations,
  PowerShell provisioning, domain join, or Windows event log forwarding.
  Also trigger when other families reference Windows auth (RADIUS to AD, SSSD domain join,
  event log forwarding to Wazuh). Works alongside homelab-ccna-expansion (physical gear AAA)
  and cml-enterprise-labs (virtual AAA). Project 13 is the cross-family capstone.
---

# Windows Server Business Admin Labs — Family Skill

## Purpose

Build, secure, automate, monitor, and recover a real small-business Microsoft environment.
Then integrate Windows Server AD as the central identity source for:
- Network devices (CML + physical Cisco gear via NPS/RADIUS)
- Linux VMs (Proxmox via SSSD domain join)
- Firewalls (OPNsense/Palo Alto RADIUS admin auth)
- Security monitoring (Wazuh pulling Windows event logs)
- Cloud (Microsoft 365 via Entra hybrid sync)

**Philosophy:** This is not "click through Server Manager" training.
Every project solves an operational problem a real small-business sysadmin faces.
The design is enterprise-grade: tiered admin accounts, AGDLP groups, least privilege,
audit policy, tested DR, and hybrid identity.

---

## Environment Reference

| Component | IP | Platform | Notes |
|-----------|----|----------|-------|
| WIN-PRQD8TJG04M | 192.168.20.11 | Physical / Hyper-V Host | Existing PDC for Chongong.local; runs all Windows Server VMs |
| WIN-DC02 | TBD | Hyper-V VM | Planned replica DC; VM not present as of P02 live AD architecture completion |
| WIN-FS01 | TBD (Project 06) | Hyper-V VM | File Server |
| WIN-WS01 | TBD (Project 07) | Hyper-V VM | Test workstation |
| OPNsense | 192.168.20.x | Hyper-V VM | Firewall — RADIUS auth in Project 13 |

**AD Domain (recommended):**
- Internal: `chongong.local` (AD DS domain)
- UPN suffix for M365: `<yourbusiness>.com` (added in Project 12)

---

## Project Map

| # | Project | Key deliverable | Cross-family impact |
|---|---------|----------------|---------------------|
| 01 | Server Baseline + Hardening | Secure server foundation, admin model | None yet — foundation |
| 02 | Active Directory Architecture | OU design, account tiers, AGDLP | Users available for cross-family auth |
| 03 | DNS Engineering | AD DNS, split DNS, forwarders | DNS available for all VMs |
| 04 | DHCP/IPAM Integration | Route10/OPNsense DHCP authority, AD DNS client validation, Hyper-V addressing | Network design supports Windows correctly |
| 05 | GPO Security Baselines | Password policy, firewall GPO, audit | Security baseline for all joined devices |
| 06 | File Server + Access Governance | Dept shares, AGDLP, auditing | File access for domain users |
| 07 | Windows Client Lifecycle | Domain join, RSAT, workstation hardening | Test user auth from workstations |
| 08 | Hyper-V Operations | Virtual switch, VLANs, backup, recovery | VM management formalized |
| 09 | PowerShell Admin Platform | Provisioning, reports, repeatable scripts | Automation available to all families |
| 10 | Security Monitoring + IR | Event forwarding, lockout tracking, Wazuh | SOC telemetry from AD/Windows |
| 11 | Backup + DR | System state, file restore, tested runbooks | AD recovery plan documented |
| 12 | M365 + Entra Hybrid Identity | Custom domain, UPN, sync, licensing | Cloud identity for all lab users |
| 13 | Enterprise Identity Integration | AD as central auth for ALL lab families | **CAPSTONE — all families integrate** |

---

## AD Design Principles

### Account Tiering (Tier 0 / Tier 1 / Tier 2)
```
Tier 0 — Domain Admins, DC management (e.g. CHONGONG\adm-leonel)
Tier 1 — Server admins (local admin on member servers)
Tier 2 — Workstation admins (local admin on workstations)
Standard user — e.g. CHONGONG\leonel (daily use, no local admin anywhere)
Service accounts — e.g. svc-backup, svc-sync (minimal permissions, no interactive login)
```

### AGDLP Group Model
```
Account → Global group → Domain Local group → Permission
Example:
  user leonel
    → GG-Finance-Users (Global group — who the people are)
      → DL-Finance-Share-RW (Domain Local — what resource access)
        → NTFS permission on \\WIN-FS01\Finance
```

### OU Structure (Project 02)
```
chongong.local
  ├── _Admin
  │   ├── Tier0-DomainAdmins
  │   ├── Tier1-ServerAdmins
  │   ├── Tier2-WorkstationAdmins
  │   └── ServiceAccounts
  ├── ManagedComputers
  │   ├── Servers
  │   └── Workstations
  ├── ManagedUsers
  │   ├── Finance
  │   ├── HR
  │   ├── IT
  │   ├── Management
  │   └── Sales
  └── Groups
      ├── GlobalGroups
      └── DomainLocalGroups
```

Project 02 uses `ManagedUsers` and `ManagedComputers` because the live domain
already has built-in root containers named `CN=Users` and `CN=Computers`.

---

## Key PowerShell Commands

### AD DS
```powershell
# Install AD DS role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promote to DC (new forest)
Install-ADDSForest -DomainName "chongong.local" -SafeModeAdministratorPassword (Read-Host -AsSecureString)

# Create OU
New-ADOrganizationalUnit -Name "IT" -Path "OU=ManagedUsers,DC=chongong,DC=local"

# Create user
New-ADUser -Name "Leonel Chongong" -SamAccountName "leonel" -UserPrincipalName "leonel@chongong.local" -AccountPassword (Read-Host -AsSecureString) -Enabled $true

# Create security group
New-ADGroup -Name "GG-NetAdmins" -GroupScope Global -GroupCategory Security -Path "OU=GlobalGroups,OU=Groups,DC=chongong,DC=local"

# Add user to group
Add-ADGroupMember -Identity "GG-NetAdmins" -Members "leonel"
```

### DNS
```powershell
# Check AD-integrated zones
Get-DnsServerZone

# Add forwarder (for public DNS)
Add-DnsServerForwarder -IPAddress 8.8.8.8, 1.1.1.1

# A record
Add-DnsServerResourceRecordA -Name "proxmox" -ZoneName "chongong.local" -IPv4Address "192.168.10.35"

# Check DC DNS is pointing to itself (critical — NOT 8.8.8.8)
Get-DnsClientServerAddress
```

### NPS / RADIUS (for network device auth — Project 13)
```powershell
# Install NPS role
Install-WindowsFeature NPAS -IncludeManagementTools

# Export NPS config (backup)
Export-NpsConfiguration -Path C:\Backup\nps-config.xml

# Import NPS config
Import-NpsConfiguration -Path C:\Backup\nps-config.xml
```

### Hyper-V
```powershell
# List VMs
Get-VM | Select-Object Name, State, MemoryAssigned, CPUUsage

# Create VM
New-VM -Name "WIN-FS01" -MemoryStartupBytes 4GB -SwitchName "vSwitch-Internal" -NewVHDPath "D:\VMs\WIN-FS01.vhdx" -NewVHDSizeBytes 60GB

# Create checkpoint
Checkpoint-VM -Name "WIN-DC02" -SnapshotName "Before-Project02"
```

---

## Project 13 — Enterprise Identity Integration Reference

**This is the capstone.** All previous projects must be complete.

### What gets integrated:

| Service | Integration | Protocol |
|---------|------------|----------|
| CML Cisco routers | AAA login → NPS → AD group → privilege level | RADIUS |
| Physical Cisco gear (R1/R2/SW1/SW2) | AAA login → NPS → AD group → privilege level | RADIUS |
| OPNsense admin | Admin auth → NPS → AD group | RADIUS |
| Proxmox Linux VMs | SSSD domain join → AD users can SSH | Kerberos/LDAP |
| Wazuh SIEM | Windows event log forwarding | Wazuh agent |
| Microsoft 365 | Entra Connect Sync → AD users get M365 accounts | OAuth/SAML |
| PowerShell remoting | AD admins can WinRM to all Windows servers | WinRM/Kerberos |

### AD Groups for Network Device Auth:
```
GG-NetAdmins       → RADIUS attribute: privilege level 15
GG-Net-ReadOnly    → RADIUS attribute: privilege level 5
GG-ServerAdmins    → full admin on member servers
GG-SOC-Analysts    → read-only on security tools
```

### Cisco IOS AAA config (applied in CML/CCNA families):
```
aaa new-model
aaa authentication login ADMIN group radius local
aaa authorization exec ADMIN group radius local
radius server WIN-NPS
 address ipv4 <NPS-SERVER-IP> auth-port 1812 acct-port 1813
 key <shared-secret>
line vty 0 4
 login authentication ADMIN
 authorization exec ADMIN
```

---

## Common Failure Modes

| Symptom | Root cause | Fix |
|---------|-----------|-----|
| Domain join fails | DNS pointing to 8.8.8.8, not DC | Point DNS to DC IP first |
| RADIUS auth fails for Cisco devices | Shared secret mismatch or wrong NPS client IP | Verify NPS RADIUS client entry |
| AD user can't log in | UPN suffix not registered in AD | `Set-ADForest -UPNSuffixes` |
| Entra sync stops | Password sync or connector account locked | Check Entra Connect health |
| GPO not applying | WMI filter or link order | `gpresult /r` on client |
| Event logs not reaching Wazuh | Windows Firewall blocking agent | Allow Wazuh agent port in GPO |
