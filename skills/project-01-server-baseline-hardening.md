---
name: winserver-p01
description: >
  Windows Server Project 01 — Server Baseline Audit, Hardening, and Tiered Admin Model.
  Trigger when working on Project 01 of windows-server-business-admin-labs.
  This is NOT a clean install — the server is already a promoted PDC for Chongong.local
  with AD DS, DHCP, DNS, NPS, RDS (full farm), IIS, Hyper-V, and File Server all installed.
  Phases: (1) Audit Documentation, (2) Fix Password Policy + Lockout, (3) Tiered Admin Model,
  (4) Assess RDS/IIS on DC, (5) Firewall Baseline, (6) Break/Fix Lockout Exercise,
  (7) Document + Push.
  Also trigger when Leonel says "windows server p01", "server baseline", "AD hardening".
---

# Windows Server Project 01 — Server Baseline + Hardening

**Skill file:** `winserver-p01`
**Status:** In Progress
**Repo:** https://github.com/vushueh/windows-server-business-admin-labs
**SSH:** `ssh -i "$env:USERPROFILE\.ssh\claude_winserver_2022_ed25519" Administrator@100.81.197.116`

---

## Pre-Flight: What We Actually Found (Audit: 2026-06-05)

This server is NOT a clean slate. A live SSH audit confirmed a fully operational environment.
Everything below is fact — not assumption.

**Server identity:**
- Hostname: WIN-PRQD8TJG04M
- OS: Windows Server 2022 Datacenter
- DomainRole: 5 (Primary Domain Controller — already promoted)
- Domain: Chongong.local / CHONGONG NetBIOS / Windows2016Domain functional level
- IP via Tailscale: 100.81.197.116

**Installed roles (all active):**
- AD-Domain-Services (promoted, running)
- DHCP (scope active: Lan-Network, 192.168.20.0/24, range .1–.254)
- DNS (AD-integrated primary zone: Chongong.local)
- NPAS / NPS (RADIUS — installed; radius-service account exists in AD)
- FS-FileServer
- Hyper-V (13 VMs running — this host IS the Hyper-V server)
- RDS full farm: Connection Broker, Gateway, Licensing, Session Host, Web Access
- IIS / Web Server (full install: ASP.NET, Windows Authentication)
- GPMC, RSAT (all tools), BitLocker, Containers, WSL, WSUS tools

**AD users found:**
Administrator (enabled), Guest (disabled), krbtgt, lionel.chongong, joiceline.kinyuy,
mickelle.tsongwine, achiril.desmond, chongong.leonel, gefter.mbi, michell.chongong,
elsa.chongong, vushueh.banks, akaseng.frankline, testuser (enabled), radius-service

**Computer accounts joined:**
WIN-PRQD8TJG04M, RADIUS01, GITEA, DESKTOP-QVM6OQN, DESKTOP-576LPTN,
DESKTOP-PGMHP9F, DESKTOP-VHPSR2K, DESKTOP-5ISQOPR

**OUs:** Domain Controllers, Management, IT, HR, Sales, Finance, Groups

**Custom AD groups:**
- Global Security: Management-Users, IT-Users, HR-Users, Sales-Users, Finance-Users, RDS-Users
- Domain Local: docker-users, Windows Admin Center CredSSP, __vmware__

**GPOs:** Default Domain Policy, Default Domain Controllers Policy — NO custom GPOs

**Current password policy (DEFAULT DOMAIN POLICY — CRITICAL GAPS):**
| Setting | Current Value | Risk |
|---------|--------------|------|
| MinPasswordLength | 7 | WEAK — industry minimum is 14 |
| LockoutThreshold | 0 | CRITICAL — brute force unlimited |
| LockoutDuration | 10 minutes | Irrelevant while threshold is 0 |
| LockoutObservationWindow | 0 | Irrelevant while threshold is 0 |
| MaxPasswordAge | 42 days | Acceptable |
| MinPasswordAge | 1 day | Acceptable |
| PasswordHistoryCount | 24 | Good |

**Firewall:** All three profiles enabled. DefaultInboundAction: NotConfigured (not blocking by default).

**Critical constraint:** This DC is also the Hyper-V host running 13 VMs and the RDS farm.
Removing or disabling roles must NOT happen in this project. Document and plan only.

---

## Phase 1 — Audit Documentation (COMPLETED)

All audit data above was collected in this phase. No changes were made to the server.

### Commands used:
```powershell
# SSH to server
ssh -i "$env:USERPROFILE\.ssh\claude_winserver_2022_ed25519" Administrator@100.81.197.116

# Roles
powershell -NonInteractive -Command "Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} | Select-Object Name, DisplayName | Format-Table -AutoSize"

# Domain info
powershell -NonInteractive -Command "Get-ADDomain | Select-Object DNSRoot,NetBIOSName,DomainMode,PDCEmulator | Format-List"

# Password policy
powershell -NonInteractive -Command "Get-ADDefaultDomainPasswordPolicy | Select-Object MinPasswordLength,LockoutThreshold,LockoutDuration,LockoutObservationWindow,MaxPasswordAge,MinPasswordAge,PasswordHistoryCount,ComplexityEnabled | Format-List"

# Users
powershell -NonInteractive -Command "Get-ADUser -Filter * -Properties Enabled | Select-Object SamAccountName,Enabled | Sort-Object SamAccountName | Format-Table -AutoSize"

# GPOs
powershell -NonInteractive -Command "Get-GPO -All | Select-Object DisplayName,GpoStatus | Format-Table -AutoSize"

# Firewall
powershell -NonInteractive -Command "Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize"
```

### Phase 1 checklist:
- [x] All roles documented
- [x] All users listed with enabled/disabled state
- [x] Password policy weaknesses identified
- [x] Firewall state confirmed
- [x] No changes made during this phase

---

## Phase 2 — Fix Critical Security: Password Policy + Account Lockout

### Objective
Eliminate the two critical gaps from the audit:
1. LockoutThreshold = 0 (unlimited brute force attempts)
2. MinPasswordLength = 7 (too weak)

### Why Default Domain Policy first

We harden the DDP because it covers ALL users including service accounts. This is independent
of the PSO that Phase 3 will create for Tier 0 accounts — both can be done, but the DDP must
be fixed for everyone regardless of whether tiered accounts exist yet.

### IMPORTANT safety rules
- Per winserver family skill: Never modify Default Domain Policy without staging first
- Backup the GPO with `Backup-Gpo` before any change
- Check radius-service account won't be disrupted

### Step 2.1 — Backup Default Domain Policy

**Run in an interactive RDP session or Windows Admin Center terminal** (not SSH — Backup-Gpo
needs proper interactive context for file path resolution):

```powershell
$BackupPath = "C:\GPO-Backups\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $BackupPath -Force

$DDP = Get-GPO -Name "Default Domain Policy"
Backup-Gpo -Guid $DDP.Id -Path $BackupPath

Get-ChildItem $BackupPath
```

**Expected output:** A directory named with the GPO GUID containing `gpreport.xml` and `bkupInfo.xml`.

### Step 2.2 — Confirm current policy before touching it

```powershell
Get-ADDefaultDomainPasswordPolicy | Select-Object `
    MinPasswordLength, LockoutThreshold, LockoutDuration,
    LockoutObservationWindow, MaxPasswordAge, MinPasswordAge,
    PasswordHistoryCount, ComplexityEnabled, ReversibleEncryptionEnabled
```

**Expected (pre-change values from audit):**
```
MinPasswordLength       : 7
LockoutThreshold        : 0
LockoutDuration         : 00:10:00
LockoutObservationWindow: 00:00:00
MaxPasswordAge          : 42.00:00:00
MinPasswordAge          : 1.00:00:00
PasswordHistoryCount    : 24
ComplexityEnabled       : True
ReversibleEncryptionEnabled: False
```

### Step 2.3 — Apply hardened settings

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName

Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 14 `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30) `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 24 `
    -ComplexityEnabled $true `
    -ReversibleEncryptionEnabled $false
```

**What each setting changes:**
| Setting | Old | New | Reason |
|---------|-----|-----|--------|
| MinPasswordLength | 7 | 14 | NIST SP 800-63B minimum for privileged accounts |
| LockoutThreshold | 0 | 5 | Blocks brute force — 5 bad attempts triggers lockout |
| LockoutDuration | 10 min | 30 min | Forces attacker to wait longer |
| LockoutObservationWindow | 0 | 30 min | Bad attempts within 30 min count toward threshold |
| MaxPasswordAge | 42 days | 90 days | Longer is acceptable with stronger minimum length |
| MinPasswordAge | 1 day | 1 day | No change — already correct |

**Note on LockoutObservationWindow:** Was 0 because threshold was 0 (irrelevant).
Now that threshold is 5, the window must be set — otherwise bad attempts never age out
and one bad-typing day could permanently accumulate lockouts.

### Step 2.4 — Verify the change applied

```powershell
Get-ADDefaultDomainPasswordPolicy | Select-Object `
    MinPasswordLength, LockoutThreshold, LockoutDuration, LockoutObservationWindow
```

**Expected:**
```
MinPasswordLength       : 14
LockoutThreshold        : 5
LockoutDuration         : 00:30:00
LockoutObservationWindow: 00:30:00
```

### Step 2.5 — Check radius-service account compliance

```powershell
Get-ADUser -Identity "radius-service" -Properties PasswordLastSet, PasswordNeverExpires, PasswordExpired |
    Select-Object SamAccountName, PasswordLastSet, PasswordNeverExpires, PasswordExpired
```

If `PasswordNeverExpires = True`: Document this — the account is exempt from MaxPasswordAge
but the MinPasswordLength applies at next manual change. Do NOT change this password now
without coordinating with NPS config (Project 13).

### Step 2.6 — Check for any accounts inadvertently locked

```powershell
Search-ADAccount -LockedOut | Select-Object SamAccountName, LockedOut, BadLogonCount, LastBadPasswordAttempt
```

**Expected:** No locked accounts (threshold was 0, so no locks could have accumulated).

### Phase 2 rollback procedure

If the new policy causes issues — restore in this order:

```powershell
# OPTION 1: Restore from GPO backup (preferred)
$BackupPath = "C:\GPO-Backups\<date>"
Restore-Gpo -BackupGpoName "Default Domain Policy" -Path $BackupPath

# OPTION 2: Manual revert — MUST set LockoutThreshold to 0 FIRST
# Reverting threshold first prevents a partially-reverted state where
# threshold=5 but observation window=0 causes permanent accumulation
$DomainDN = (Get-ADDomain).DistinguishedName
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN -LockoutThreshold 0
# Then revert remaining settings
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 7 `
    -LockoutDuration (New-TimeSpan -Minutes 10) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 0) `
    -MaxPasswordAge (New-TimeSpan -Days 42)
```

### Phase 2 checklist:
- [ ] GPO backup exists at C:\GPO-Backups\[date]
- [ ] MinPasswordLength = 14
- [ ] LockoutThreshold = 5
- [ ] LockoutDuration = 30 minutes
- [ ] LockoutObservationWindow = 30 minutes
- [ ] radius-service account state documented
- [ ] No accounts currently locked out
- [ ] testuser account: verify it is disabled or handled in Phase 6

---

## Phase 3 — Create Tiered Admin Model

### Objective
Implement the AGDLP-aligned tiered admin account model:
- **Tier 0 (adm-leonel):** Full domain admin — used only when domain-level changes are needed
- **Tier 1 (srv-leonel):** Server/service admin — day-to-day server management

### Why this matters on THIS server
All administration is currently done as the built-in `Administrator` account. That account:
- Cannot be locked out (built-in protection)
- Has no activity-specific audit trail
- Is the most targeted account in any AD domain

### ⚠️ Password entry — SSH limitation

`Read-Host -AsSecureString` does NOT work reliably over OpenSSH on Windows Server 2022.
**Run Steps 3.2 and 3.3 in an interactive RDP session or Windows Admin Center terminal.**

Alternative if SSH-only (replace with a strong password, then change at next RDP):
```powershell
$Tier0Password = ConvertTo-SecureString "TempP@ssword_ChangeMe!" -AsPlainText -Force
```

### Step 3.1 — Create the Admin Accounts OU structure

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName

New-ADOrganizationalUnit -Name "Admin Accounts" `
    -Path $DomainDN `
    -Description "Tiered admin accounts — DO NOT apply user GPOs here" `
    -ProtectedFromAccidentalDeletion $true

New-ADOrganizationalUnit -Name "Tier0" `
    -Path "OU=Admin Accounts,$DomainDN" `
    -Description "Domain and forest admin accounts" `
    -ProtectedFromAccidentalDeletion $true

New-ADOrganizationalUnit -Name "Tier1" `
    -Path "OU=Admin Accounts,$DomainDN" `
    -Description "Server and service admin accounts" `
    -ProtectedFromAccidentalDeletion $true
```

**Verify:**
```powershell
Get-ADOrganizationalUnit -Filter {Name -like "*Admin*" -or Name -eq "Tier0" -or Name -eq "Tier1"} |
    Select-Object Name, DistinguishedName
```

### Step 3.2 — Create adm-leonel (Tier 0) — run in RDP session

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName
$Tier0OU = "OU=Tier0,OU=Admin Accounts,$DomainDN"

$Tier0Password = Read-Host -AsSecureString "Enter password for adm-leonel (min 14 chars)"

New-ADUser `
    -SamAccountName "adm-leonel" `
    -UserPrincipalName "adm-leonel@Chongong.local" `
    -Name "adm-leonel" `
    -DisplayName "Leonel Chongong (Tier0 Admin)" `
    -Description "Tier0 domain admin — use ONLY for domain-level changes" `
    -Path $Tier0OU `
    -AccountPassword $Tier0Password `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -CannotChangePassword $false `
    -ChangePasswordAtLogon $false

Add-ADGroupMember -Identity "Domain Admins" -Members "adm-leonel"
Get-ADGroupMember -Identity "Domain Admins" | Select-Object SamAccountName, ObjectClass
```

### Step 3.3 — Create srv-leonel (Tier 1) — run in RDP session

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName
$Tier1OU = "OU=Tier1,OU=Admin Accounts,$DomainDN"

$Tier1Password = Read-Host -AsSecureString "Enter password for srv-leonel (min 14 chars)"

New-ADUser `
    -SamAccountName "srv-leonel" `
    -UserPrincipalName "srv-leonel@Chongong.local" `
    -Name "srv-leonel" `
    -DisplayName "Leonel Chongong (Tier1 Srv Admin)" `
    -Description "Tier1 server admin — daily server management, NOT domain-level" `
    -Path $Tier1OU `
    -AccountPassword $Tier1Password `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -CannotChangePassword $false `
    -ChangePasswordAtLogon $false

Add-ADGroupMember -Identity "Server Operators" -Members "srv-leonel"
Add-ADGroupMember -Identity "Remote Management Users" -Members "srv-leonel"
Get-ADPrincipalGroupMembership -Identity "srv-leonel" | Select-Object Name, GroupScope
```

### Step 3.4 — Create Fine-Grained Password Policy for Tier 0

PSOs allow per-group policy overrides on top of the DDP. Phase 2 (DDP) and this PSO
are independent — the PSO adds stricter requirements for Tier 0 accounts only.

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName

# Verify Groups OU path before creating group
$GroupsOU = Get-ADOrganizationalUnit -Filter {Name -eq "Groups"} |
    Select-Object -First 1 -ExpandProperty DistinguishedName

if (-not $GroupsOU) {
    throw "Groups OU not found — verify with Get-ADOrganizationalUnit -Filter *"
}
Write-Host "Groups OU found: $GroupsOU"

# Create shadow group — PSOs apply to groups, not OUs
try {
    New-ADGroup `
        -Name "GG-Tier0-Admins" `
        -GroupScope Global `
        -GroupCategory Security `
        -Path $GroupsOU `
        -Description "Shadow group for Tier0 PSO application" `
        -ErrorAction Stop

    Add-ADGroupMember -Identity "GG-Tier0-Admins" -Members "adm-leonel"
    Write-Host "GG-Tier0-Admins created and adm-leonel added"
} catch {
    throw "Group creation failed: $_  — Cannot proceed to PSO creation without the group"
}

# Create PSO — only runs if group creation succeeded
New-ADFineGrainedPasswordPolicy `
    -Name "PSO-Tier0-Admins" `
    -Precedence 10 `
    -MinPasswordLength 20 `
    -LockoutThreshold 3 `
    -LockoutDuration (New-TimeSpan -Minutes 60) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 60) `
    -MaxPasswordAge (New-TimeSpan -Days 180) `
    -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 24 `
    -ComplexityEnabled $true `
    -ReversibleEncryptionEnabled $false `
    -Description "Tier0 domain admin accounts — stricter than domain default"

Add-ADFineGrainedPasswordPolicySubject `
    -Identity "PSO-Tier0-Admins" `
    -Subjects "GG-Tier0-Admins"
```

**Verify:**
```powershell
# Resultant policy for adm-leonel — must show PSO-Tier0-Admins, NOT Default Domain Policy
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel"
```

### Step 3.5 — Verify chongong.leonel is NOT elevated

```powershell
Get-ADUser -Identity "chongong.leonel" -Properties MemberOf, DistinguishedName |
    Select-Object SamAccountName, DistinguishedName, @{N="Groups";E={$_.MemberOf -join "; "}}
```

This account should NOT be in Domain Admins or any privileged group.

### Phase 3 checklist:
- [ ] OU=Admin Accounts exists at domain root
- [ ] OU=Tier0 and OU=Tier1 exist under Admin Accounts
- [ ] adm-leonel: enabled, in Tier0 OU, member of Domain Admins
- [ ] srv-leonel: enabled, in Tier1 OU, member of Server Operators
- [ ] Groups OU path verified before group creation
- [ ] GG-Tier0-Admins created in Groups OU
- [ ] PSO-Tier0-Admins applied with Precedence 10
- [ ] Get-ADUserResultantPasswordPolicy for adm-leonel returns PSO-Tier0-Admins
- [ ] chongong.leonel is NOT in any admin group

---

## Phase 4 — Assess RDS and IIS on DC (Document Only — Do NOT Remove)

### Objective
Document the security risk of RDS + IIS co-located on the DC. Do NOT change or remove
these roles. Migration belongs in Project 08 (Hyper-V Operations).

### Why this is a serious problem

**RDS Session Host on a DC:** Any RDS user who achieves privilege escalation has domain-level
access. Microsoft explicitly prohibits Session Host on a DC.

**IIS on a DC:** Web application exploits on the DC are domain exploits.

### Step 4.1 — Document RDS configuration

```powershell
Get-RDSessionCollection -ConnectionBroker "WIN-PRQD8TJG04M.Chongong.local" -ErrorAction SilentlyContinue
Get-ADGroupMember -Identity "RDS-Users" | Select-Object SamAccountName, ObjectClass
net localgroup "Remote Desktop Users"
```

### Step 4.2 — Document IIS configuration

```powershell
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-Website | Select-Object Name, State, PhysicalPath
Get-WebConfiguration "system.applicationHost/applicationPools/add" |
    Select-Object name, @{N="IdentityType";E={$_.processModel.identityType}}
```

### Step 4.3 — Document risk in docs/p01-rds-iis-risk-assessment.md

```
RISK: RDS Session Host co-located on PDC
SEVERITY: High
MITIGATION: Project 08 — create WIN-RDS01 VM, migrate RDS farm
DO NOT TOUCH NOW: Removing Session Host without a target server breaks the farm

RISK: IIS on PDC
SEVERITY: High  
MITIGATION: Likely serves RDS Web Access — migrates with RDS in Project 08
DO NOT TOUCH NOW: Stopping IIS may break RDS Web Access
```

### Phase 4 checklist:
- [ ] RDS-Users group membership documented
- [ ] IIS sites and app pool identities documented
- [ ] Risk assessment document written
- [ ] NO changes made to RDS or IIS roles

---

## Phase 5 — Firewall Baseline and Open Port Review

### Objective
Document all listening ports and enabled inbound rules. Restrict RDP to Tailscale-only.
DefaultInboundAction gap is documented but NOT changed — fixing it requires a custom GPO
with full AD port allowlists (Project 05 — GPO Security Baselines).

### Step 5.1 — Capture all listening ports

```powershell
Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}},
        OwningProcess |
    Sort-Object LocalPort | Format-Table -AutoSize
```

### Step 5.2 — List all enabled inbound firewall rules

```powershell
Get-NetFirewallRule -Direction Inbound -Enabled True |
    ForEach-Object {
        $rule = $_
        $portFilter = $rule | Get-NetFirewallPortFilter
        [PSCustomObject]@{
            Name      = $rule.DisplayName
            Profile   = $rule.Profile
            Action    = $rule.Action
            Protocol  = $portFilter.Protocol
            LocalPort = $portFilter.LocalPort
        }
    } | Sort-Object LocalPort | Format-Table -AutoSize
```

### Step 5.3 — DefaultInboundAction: document but defer

```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
```

**Do NOT set DefaultInboundAction to Block on a DC without first verifying all AD-required
ports have explicit Allow rules.** Blocking without those rules breaks domain auth for all
13 VMs and all joined workstations.

**Deferred to:** Project 05 — GPO Security Baselines.

### Step 5.4 — Expected listeners on this DC

| Port | Protocol | Service |
|------|----------|---------|
| 53 | TCP/UDP | DNS |
| 80 | TCP | IIS / RDS Web Access |
| 88 | TCP/UDP | Kerberos |
| 135 | TCP | RPC Endpoint Mapper |
| 389 | TCP/UDP | LDAP |
| 443 | TCP | IIS HTTPS / RDS Web Access |
| 445 | TCP | SMB (SYSVOL/NETLOGON) |
| 464 | TCP/UDP | Kerberos password change |
| 636 | TCP | LDAPS |
| 1812 | UDP | RADIUS authentication (NPS) |
| 1813 | UDP | RADIUS accounting (NPS) |
| 3268 | TCP | Global Catalog LDAP |
| 3269 | TCP | Global Catalog LDAPS |
| 3389 | TCP | RDP (restricted below) |
| 49152-65535 | TCP | Dynamic RPC |

Any listener NOT in this table needs investigation.

### Step 5.5 — Restrict RDP to Tailscale only

**Recommended: use your specific Tailscale node IP, not the /10 range.**
The /10 (100.64.0.0/10) covers all Tailscale nodes globally — a specific IP is tighter.
Run `tailscale ip -4` on your management machine to get your node IP.

```powershell
# Get all matching RDP rules and pipe directly to Set (handles multiple rule matches)
$RdpRules = Get-NetFirewallRule -DisplayName "*Remote Desktop*" -ErrorAction SilentlyContinue |
    Where-Object {$_.Direction -eq "Inbound" -and $_.Enabled -eq "True"}

if (-not $RdpRules) {
    Write-Warning "No enabled inbound Remote Desktop rules found"
} else {
    # Replace with your specific Tailscale node IP for tighter restriction
    $TailscaleIP = "100.64.0.0/10"   # Minimum — use specific node IP instead
    $RdpRules | Set-NetFirewallRule -RemoteAddress $TailscaleIP
    Write-Host "RDP restricted to $TailscaleIP"
}
```

### Step 5.6 — Export firewall baseline

```powershell
New-Item -ItemType Directory -Path "C:\Audit" -Force | Out-Null
Get-NetFirewallRule -Direction Inbound |
    Select-Object DisplayName, Enabled, Profile, Action, Direction |
    Export-Csv -Path "C:\Audit\firewall-inbound-baseline-$(Get-Date -Format 'yyyy-MM-dd').csv" `
    -NoTypeInformation
```

### Phase 5 checklist:
- [ ] All listening ports documented with process names
- [ ] All enabled inbound rules exported to CSV
- [ ] No unexpected listeners (or all documented)
- [ ] RDP restricted to Tailscale range/IP
- [ ] DefaultInboundAction NOT changed — deferred to Project 05 GPO
- [ ] Firewall baseline CSV saved to repo under docs/

---

## Phase 6 — Break/Fix: Account Lockout Exercise

### Objective
Confirm lockout policy from Phase 2 works. Use `testuser` (existing enabled account).
After the exercise, disable testuser permanently.

### ⚠️ Run the bad-attempt loop from a DIFFERENT machine

For the most realistic Type 3 network logon test, run from one of the joined workstations
(DESKTOP-QVM6OQN, etc.) or from your management machine.

If no other machine is available, `net use \\127.0.0.1\IPC$` from the DC generates
a Type 3 network logon and triggers the lockout correctly.

### Step 6.1 — Confirm testuser state

```powershell
Get-ADUser -Identity "testuser" -Properties Enabled, LockedOut, BadLogonCount, LastBadPasswordAttempt |
    Select-Object SamAccountName, Enabled, LockedOut, BadLogonCount, LastBadPasswordAttempt
```

### Step 6.2 — Set exercise password (must be 14+ chars after Phase 2)

```powershell
# Phase 2 raised MinPasswordLength to 14 — password must comply
$TestPwd = Read-Host -AsSecureString "Set testuser exercise password (min 14 chars)"
Set-ADAccountPassword -Identity "testuser" -NewPassword $TestPwd -Reset
Set-ADUser -Identity "testuser" -ChangePasswordAtLogon $false
```

### Step 6.3 — Trigger the lockout (5 bad attempts)

```powershell
# Run from a different machine, or use \\127.0.0.1 from the DC itself
1..6 | ForEach-Object {
    $attempt = $_
    $result = net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\testuser "WrongPassword123!" 2>&1
    Write-Host "Attempt ${attempt}: $result"
    net use \\WIN-PRQD8TJG04M\IPC$ /delete 2>&1 | Out-Null
    Start-Sleep -Seconds 1
}
```

### Step 6.4 — Verify lockout occurred

```powershell
Get-ADUser -Identity "testuser" -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt |
    Select-Object SamAccountName, LockedOut, BadLogonCount, LastBadPasswordAttempt

Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740} -MaxEvents 5 |
    Select-Object TimeCreated, Message | Format-List
```

**Expected:** LockedOut=True, BadLogonCount=5+, Event ID 4740 in Security log.

**Key Event IDs:** 4625=failed logon, 4740=locked out, 4767=unlocked, 4771=Kerberos pre-auth failed

### Step 6.5 — Unlock and verify

```powershell
Unlock-ADAccount -Identity "testuser"
Get-ADUser -Identity "testuser" -Properties LockedOut, BadLogonCount |
    Select-Object SamAccountName, LockedOut, BadLogonCount
```

### Step 6.6 — Disable testuser permanently (disable + quarantine, do NOT delete)

```powershell
Disable-ADAccount -Identity "testuser"

$DomainDN = (Get-ADDomain).DistinguishedName
try {
    Get-ADOrganizationalUnit -Identity "OU=Quarantine,$DomainDN" -ErrorAction Stop | Out-Null
    Write-Host "Quarantine OU exists"
} catch {
    New-ADOrganizationalUnit -Name "Quarantine" -Path $DomainDN `
        -Description "Disabled accounts awaiting deletion review" `
        -ProtectedFromAccidentalDeletion $false
}

Move-ADObject -Identity (Get-ADUser -Identity "testuser").DistinguishedName `
    -TargetPath "OU=Quarantine,$DomainDN"

Get-ADUser -Identity "testuser" -Properties Enabled, DistinguishedName |
    Select-Object SamAccountName, Enabled, DistinguishedName
```

### Phase 6 checklist:
- [ ] testuser lockout confirmed after 5 bad attempts
- [ ] Event ID 4740 in Security log
- [ ] Unlock procedure confirmed
- [ ] testuser disabled and moved to Quarantine OU

---

## Phase 7 — Document Verified State + Push to GitHub

### Step 7.1 — Final state capture

```powershell
Get-ADDefaultDomainPasswordPolicy | Select-Object MinPasswordLength, LockoutThreshold, LockoutDuration
Get-ADUser -Filter {SamAccountName -like "adm-*" -or SamAccountName -like "srv-*"} `
    -Properties Enabled, DistinguishedName | Select-Object SamAccountName, Enabled, DistinguishedName
Get-ADFineGrainedPasswordPolicy -Filter * | Select-Object Name, Precedence, MinPasswordLength, LockoutThreshold
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel"
Get-ADUser -Identity "testuser" -Properties Enabled, DistinguishedName |
    Select-Object SamAccountName, Enabled, DistinguishedName
```

### Step 7.2 — Git push from WSL

```bash
cd /home/leonel/code/windows-server-business-admin-labs
git remote -v
git add projects/project-01-server-baseline-hardening/ skills/ docs/
git commit -m "feat: P01 server baseline + hardening complete

- Password policy hardened: 14-char min, 5-attempt lockout, 30-min duration
- Tiered admin model: adm-leonel (Tier0), srv-leonel (Tier1)
- PSO-Tier0-Admins applied to GG-Tier0-Admins with Precedence 10
- RDS/IIS risk documented — migration deferred to P08
- Firewall baseline captured, RDP restricted to Tailscale
- testuser disabled and quarantined"

git push origin main
```

### Phase 7 checklist:
- [ ] All docs written and in project folder
- [ ] All scripts saved
- [ ] Final state matches expected values
- [ ] GitHub push confirmed
- [ ] Parent skill (winserver.md) updated to mark P01 ✅

---

## CCNA Cross-Reference — Project 13 Preview (NPS/RADIUS)

NPS is already installed and `radius-service` account already exists.

**Important:** NPS uses the machine account (WIN-PRQD8TJG04M$) for AD lookups — NOT
radius-service. NPS queries AD automatically as the machine account.
Verify the actual purpose of `radius-service` before Project 13 — it may be:
- A condition account used in NPS Network Policies (group membership checks)
- A legacy entry from a previous NPS config
Do NOT change its password without investigating this first.

**CCNA connection:**
```
aaa new-model
aaa authentication login default group radius local
aaa authorization exec default group radius local
radius server WIN-NPS
 address ipv4 <DC-IP> auth-port 1812 acct-port 1813
 key <shared-secret>
```

**Port check:** UDP 1812 and 1813 must be open inbound — verify in Phase 5 port scan.

**Groups to create in Project 02** (plan now, build later):
```powershell
New-ADGroup -Name "GG-NetAdmins" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "GG-Net-ReadOnly" -GroupScope Global -GroupCategory Security
```

---

## Quick Reference

```powershell
# SSH to server
ssh -i "$env:USERPROFILE\.ssh\claude_winserver_2022_ed25519" Administrator@100.81.197.116

dcdiag /test:all /q                                          # Domain health
netdom query fsmo                                            # FSMO roles (all should be here)
Search-ADAccount -LockedOut | Select-Object SamAccountName   # Locked accounts
Unlock-ADAccount -Identity <username>                        # Unlock account
gpupdate /force                                              # Force GP update (local only)
Get-Service -Name IAS                                        # NPS service status
repadmin /showrepl                                           # AD replication (no partners expected)
```

---

## Do-Not-Touch List (This Project)

| Item | Reason | Addressed In |
|------|--------|-------------|
| RDS roles (all 5) | Active — removing breaks the RDS farm | Project 08 |
| IIS / Web Server | Likely serves RDS Web Access | Project 08 |
| DHCP scope 192.168.20.0/24 | All 13 VMs and workstations depend on it | Project 04 |
| DNS zones (Chongong.local, _msdcs) | Breaking DNS breaks the entire domain | Project 03 |
| radius-service account password | Investigate purpose before touching | Project 13 |
| Default Domain Controllers Policy | Modifying without testing can lock out AD | Project 05 |
| Hyper-V VMs | 13 running VMs — no VM operations here | Project 08 |
| DefaultInboundAction = Block | Requires full AD port allowlist GPO first | Project 05 |
| __vmware__ group | Unknown purpose — investigate before removing | Project 02 |

---

## Project 01 Completion Checklist

- [ ] Phase 1: Audit documented in docs/p01-audit-baseline.md
- [ ] Phase 2: LockoutThreshold = 5, MinPasswordLength = 14
- [ ] Phase 2: GPO backup saved at C:\GPO-Backups\[date]
- [ ] Phase 3: adm-leonel (Tier0), srv-leonel (Tier1) created
- [ ] Phase 3: PSO-Tier0-Admins active, precedence 10, min 20 chars, lockout 3
- [ ] Phase 4: RDS/IIS risk assessment documented — no changes made
- [ ] Phase 5: Firewall baseline CSV in docs/
- [ ] Phase 5: RDP restricted to Tailscale
- [ ] Phase 6: Lockout exercise completed, testuser quarantined
- [ ] Phase 7: All scripts saved, docs complete, GitHub push done
- [ ] Parent skill (winserver.md) updated to mark P01 ✅
