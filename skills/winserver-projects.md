---
name: winserver-projects
description: >
  Windows Server Business Admin Labs — Projects 02 through 12.
  Trigger when Leonel says: "windows server project P02-P12", "AD architecture",
  "OU structure", "AGDLP", "replica DC", "DNS engineering", "DHCP IPAM",
  "GPO baseline", "file server", "NTFS", "WIN-FS01", "domain join", "WIN-WS01",
  "Hyper-V operations", "RDS migration", "PowerShell admin", "Windows Admin Center",
  "WAC", "security monitoring", "WEF", "Wazuh Windows", "backup DR", "system state",
  "M365 Entra", "hybrid identity", "Entra Connect", or any project number P02-P12.
  Works alongside winserver-p01 (baseline hardening) and winserver-p13 (capstone).
---

# Windows Server Business Admin Labs — Projects 02–12

## Environment Reference (all projects)

| Component | Value |
|-----------|-------|
| PDC | WIN-PRQD8TJG04M — 192.168.20.11 / Tailscale 100.81.197.116 |
| Domain | Chongong.local / CHONGONG |
| Replica DC | WIN-DC02 (created in P02) |
| File Server | WIN-FS01 (created in P06) |
| Workstation | WIN-WS01 (created in P07) |
| RDS farm | WIN-RDS01 + WIN-RDWEB01 (created in P08) |
| SSH to PDC | `ssh -i claude_winserver_2022_ed25519 Administrator@100.81.197.116` |

**Admin accounts:** `adm-leonel` (Tier 0 DA) | `srv-leonel` (Tier 1) | `ws-leonel` (Tier 2)
**Safety rules:** NEVER modify Default Domain Policy or Default Domain Controllers Policy directly.
NEVER delete AD objects — disable/move only. NEVER run scripts without Claude review.

---

## Project 02 — Active Directory Architecture

**Requires:** P01 complete
**Slash command:** `/winserver-p02`

### Purpose
Build full AD structure: OU hierarchy, tiered admin accounts, AGDLP groups, service accounts, delegated administration, replica DC for redundancy and DC-skills practice.

### Phase 1 — OU Structure

```powershell
# Build per identity-design.md
$base = "DC=Chongong,DC=local"
foreach ($ou in @("_Admin","Computers","Users","Groups")) {
    New-ADOrganizationalUnit -Name $ou -Path $base
}
New-ADOrganizationalUnit -Name "Tier0-DomainAdmins"   -Path "OU=_Admin,$base"
New-ADOrganizationalUnit -Name "Tier1-ServerAdmins"   -Path "OU=_Admin,$base"
New-ADOrganizationalUnit -Name "Tier2-WorkstationAdmins" -Path "OU=_Admin,$base"
New-ADOrganizationalUnit -Name "ServiceAccounts"      -Path "OU=_Admin,$base"
New-ADOrganizationalUnit -Name "Servers"      -Path "OU=Computers,$base"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Computers,$base"
foreach ($dept in @("IT","Finance","Operations")) {
    New-ADOrganizationalUnit -Name $dept -Path "OU=Users,$base"
}
New-ADOrganizationalUnit -Name "GlobalGroups"      -Path "OU=Groups,$base"
New-ADOrganizationalUnit -Name "DomainLocalGroups" -Path "OU=Groups,$base"
# VERIFY
Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName | Sort-Object
```

### Phase 2 — Move Existing Objects

```powershell
# Move existing users to correct OU
Get-ADUser -Filter {SamAccountName -ne "Administrator"} |
  Move-ADObject -TargetPath "OU=IT,OU=Users,DC=Chongong,DC=local"
# Move computers
Get-ADComputer -Filter {Name -like "DESKTOP-*"} |
  Move-ADObject -TargetPath "OU=Workstations,OU=Computers,DC=Chongong,DC=local"
```

### Phase 3 — Tiered Admin Accounts

```powershell
$base = "DC=Chongong,DC=local"
# Tier 0
New-ADUser -Name "adm-leonel" -SamAccountName "adm-leonel" `
  -Path "OU=Tier0-DomainAdmins,OU=_Admin,$base" `
  -AccountPassword (Read-Host -AsSecureString "adm-leonel password (20+ chars)") -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "adm-leonel"

# Tier 1
New-ADUser -Name "srv-leonel" -SamAccountName "srv-leonel" `
  -Path "OU=Tier1-ServerAdmins,OU=_Admin,$base" `
  -AccountPassword (Read-Host -AsSecureString "srv-leonel password") -Enabled $true
Add-ADGroupMember -Identity "GG-ServerAdmins" -Members "srv-leonel"

# Tier 2
New-ADUser -Name "ws-leonel" -SamAccountName "ws-leonel" `
  -Path "OU=Tier2-WorkstationAdmins,OU=_Admin,$base" `
  -AccountPassword (Read-Host -AsSecureString "ws-leonel password") -Enabled $true
```

### Phase 4 — AGDLP Groups

```powershell
$gou = "OU=GlobalGroups,OU=Groups,DC=Chongong,DC=local"
$dlou = "OU=DomainLocalGroups,OU=Groups,DC=Chongong,DC=local"
foreach ($dept in @("Finance","IT","Operations")) {
    New-ADGroup -Name "GG-$dept-Users" -GroupScope Global -Path $gou
    New-ADGroup -Name "DL-$dept-Share-RW" -GroupScope DomainLocal -Path $dlou
    Add-ADGroupMember -Identity "DL-$dept-Share-RW" -Members "GG-$dept-Users"
}
New-ADGroup -Name "GG-NetAdmins"   -GroupScope Global -Path $gou
New-ADGroup -Name "GG-ServerAdmins" -GroupScope Global -Path $gou
New-ADGroup -Name "GG-Helpdesk"    -GroupScope Global -Path $gou
```

### Phase 5 — Service Accounts

```powershell
New-ADUser -Name "svc-backup" -SamAccountName "svc-backup" `
  -Path "OU=ServiceAccounts,OU=_Admin,DC=Chongong,DC=local" `
  -AccountPassword (Read-Host -AsSecureString "svc-backup password") `
  -Enabled $true -PasswordNeverExpires $true
# Deny interactive logon via GPO
```

### Phase 6 — Delegated Administration

```
GUI: ADUC → Users OU → right-click → Delegate Control
  Delegate to: GG-Helpdesk
  Task: Reset user passwords and force password change at next logon
```

### Phase 7 — Replica DC (WIN-DC02)

```powershell
# On WIN-DC02 Hyper-V VM (2 vCPU, 4GB, 80GB) — after Windows Server 2022 install
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSDomainController `
  -DomainName "Chongong.local" `
  -InstallDns:$true `
  -Credential (Get-Credential "CHONGONG\adm-leonel") `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password") `
  -Force:$true

# VERIFY
repadmin /replsummary
repadmin /showrepl
Get-ADReplicationPartnerMetadata -Target WIN-DC02
netdom query fsmo   ! All FSMO roles still on WIN-PRQD8TJG04M
```

### Phase 8 — Functional Level Upgrade

```powershell
Set-ADDomainMode -Identity "Chongong.local" -DomainMode Windows2016Domain
Set-ADForestMode -Identity "Chongong.local" -ForestMode Windows2016Forest
# VERIFY: Get-ADDomain | Select-Object DomainMode
```

---

## Project 03 — AD DNS Engineering

**Requires:** P02 complete (WIN-DC02 running)
**Slash command:** `/winserver-p03`

### Phase 1 — Audit

```powershell
Get-DnsServer
Get-DnsServerZone
Get-DnsServerForwarder
Get-DnsServerScavenging
```

### Phase 2 — Fix DNS Server Addressing

```
WIN-PRQD8TJG04M NIC: Primary DNS = 127.0.0.1 | Secondary = WIN-DC02 IP
WIN-DC02 NIC:        Primary DNS = WIN-PRQD8TJG04M IP | Secondary = 127.0.0.1
NEVER set DC NIC DNS to 8.8.8.8 — breaks AD authentication
```

### Phase 3 — Forwarders

```powershell
Set-DnsServerForwarder -IPAddress "8.8.8.8","1.1.1.1"
# VERIFY: Resolve-DnsName google.com -Server 192.168.20.11 → resolves
```

### Phase 4 — Reverse Lookup Zones

```powershell
Add-DnsServerPrimaryZone -NetworkID "192.168.20.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -ZoneName "20.168.192.in-addr.arpa" `
  -Name "11" -PtrDomainName "WIN-PRQD8TJG04M.Chongong.local"
```

### Phase 5 — Scavenging

```powershell
Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00
Set-DnsServerZoneAging -Name "Chongong.local" -Aging $true `
  -RefreshInterval 4.00:00:00 -NoRefreshInterval 4.00:00:00
```

### Phase 6 — Break/Fix

| Scenario | Symptom | Fix |
|----------|---------|-----|
| Client DNS to 8.8.8.8 | Domain join fails, AD auth fails | Change to DC IP |
| _msdcs SRV missing | Replication fails | Restart Netlogon: `net stop netlogon && net start netlogon` |
| Forwarder missing | Internet resolution fails | `Set-DnsServerForwarder -IPAddress 8.8.8.8` |

---

## Project 04 — DHCP and IPAM

**Requires:** P03 complete
**Slash command:** `/winserver-p04`

### Phase 1 — Audit

```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4Lease -ScopeId 192.168.20.0
Get-DhcpServerv4Reservation -ScopeId 192.168.20.0
Get-DhcpServerv4ScopeOptionValue -ScopeId 192.168.20.0
```

### Phase 2 — Redesign Scope

IP scheme: .1-10 Static infra | .11-30 Static servers | .31-50 Reserved VMs | .100-200 DHCP clients

### Phase 3 — Reservations

```powershell
Add-DhcpServerv4Reservation -ScopeId 192.168.20.0 -IPAddress 192.168.20.11 `
  -ClientId "<MAC-of-WIN-PRQD8TJG04M>" -Description "PDC WIN-PRQD8TJG04M"
```

### Phase 4 — DHCP Failover

```powershell
Add-DhcpServerv4Failover -Name "LAN-Failover" -PartnerServer WIN-DC02 `
  -ScopeId 192.168.20.0 -Mode HotStandby -ServerRole Active `
  -ReservePercent 5 -AutoStateTransition $true -StateSwitchInterval 00:01:00
# VERIFY: Get-DhcpServerv4Failover
```

---

## Project 05 — GPO Security Baselines

**Requires:** P02 complete (OU structure exists)
**Slash command:** `/winserver-p05`

### GPO Architecture

| GPO | Link | Purpose |
|-----|------|---------|
| Domain-PasswordPolicy | Domain | MinLength 14, complexity, history 24 |
| Domain-AccountLockout | Domain | Threshold 5, duration 15min |
| Servers-AuditPolicy | Computers\Servers | Success+Failure all categories |
| Servers-FirewallBaseline | Computers\Servers | DefaultInboundAction=Block |
| Workstations-LocalAdminRestriction | Computers\Workstations | Remove standard users from local admins |
| Admins-TierZeroRestriction | _Admin\Tier0 | Deny logon to workstations |

```powershell
# Never edit Default Domain Policy — create separate GPOs
New-GPO -Name "Domain-PasswordPolicy" | New-GPLink -Target "DC=Chongong,DC=local"
# Settings via GPMC: Computer Config → Policies → Windows Settings → Security Settings → Account Policies

# Test in staged OU first
New-GPLink -Name "Workstations-LocalAdminRestriction" -Target "OU=TestOU,DC=Chongong,DC=local"
gpresult /H C:\Audit\gpo-rsop.html   ! Verify RSoP before production link
```

### GPO Audit Policy Path

```
Computer Configuration → Policies → Windows Settings → Security Settings →
Advanced Audit Policy Configuration → Audit Policies
Categories: Logon/Logoff, Account Mgmt, Privilege Use, Object Access → Success + Failure
```

---

## Project 06 — File Server and Access Governance

**Requires:** P02 (AGDLP groups) and P05 (GPO audit) complete
**Slash command:** `/winserver-p06`

### Phase 1 — Create WIN-FS01 (Hyper-V VM)

2 vCPU | 4GB RAM | 80GB OS + 200GB data disk | Windows Server 2022
Domain join → move to `OU=Servers,OU=Computers,DC=Chongong,DC=local`

### Phase 2 — Shares and NTFS

```powershell
Install-WindowsFeature FS-FileServer, FS-Resource-Manager -IncludeManagementTools

# Create share structure
foreach ($dept in @("Finance","IT","Operations","Shared","Archives")) {
    New-Item -ItemType Directory -Path "D:\Shares\$dept"
    New-SmbShare -Name $dept -Path "D:\Shares\$dept" -FullAccess "Domain Admins"
}

# Apply NTFS AGDLP — remove inheritance, assign DL-* groups
$path = "D:\Shares\Finance"
$acl = Get-Acl $path
$acl.SetAccessRuleProtection($true, $false)   # disable inheritance, remove inherited
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "CHONGONG\DL-Finance-Share-RW","Modify","ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $path -AclObject $acl
```

### Phase 3 — Shadow Copies and FSRM

```powershell
# Shadow copies on data volume
$vol = Get-WmiObject -Class Win32_Volume -ComputerName WIN-FS01 | Where-Object DriveLetter -eq "D:"
# Enable VSS via Server Manager or: vssadmin add shadowstorage /for=D: /on=D: /maxsize=10GB

# FSRM quota
New-FsrmQuota -Path "D:\Shares\Finance" -Size 10GB -SoftLimit $false
```

### Phase 4 — Access Review Report

```powershell
Get-ADGroupMember "DL-Finance-Share-RW" | ForEach-Object {
    if ($_.objectClass -eq "group") { Get-ADGroupMember $_.SamAccountName }
    else { $_ }
} | Select-Object Name, SamAccountName | Sort-Object Name
```

---

## Project 07 — Windows Client Lifecycle

**Requires:** P02, P05, P06 complete
**Slash command:** `/winserver-p07`

### Phase 1 — Create WIN-WS01 (Hyper-V VM)

Windows 11 Pro/Enterprise | 2 vCPU | 4GB RAM | 60GB disk
Set DNS to 192.168.20.11 → domain join → move to `OU=Workstations,OU=Computers,DC=Chongong,DC=local`

### Phase 2 — RSAT Install

```powershell
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
# VERIFY: dsa.msc, gpmc.msc, dhcpmgmt.msc open against DC
```

### Phase 3 — GPO Verification

```powershell
gpresult /R /Scope Computer    ! confirm workstation GPOs applied
gpresult /R /Scope User        ! confirm user GPOs applied
```

### Phase 4 — Tiered Login Tests

| Account | Expected result |
|---------|----------------|
| `leonel` (standard) | Login OK, no local admin, screen lock after 10min |
| `ws-leonel` (Tier 2) | Login OK, local admin on workstation |
| `adm-leonel` (Tier 0) | BLOCKED — GPO denies logon to workstations |
| `srv-leonel` (Tier 1) | Login OK, NOT local admin |

### Phase 5 — Drive Mapping via GPO

```
GPO: Workstations-DriveMaps
User Configuration → Preferences → Windows Settings → Drive Maps
F: → \\WIN-FS01\Finance → item-level targeting: GG-Finance-Users
```

### Phase 6 — Offboarding

```powershell
Disable-ADAccount -Identity leonel
Move-ADObject -Identity (Get-ADUser leonel).DistinguishedName `
  -TargetPath "OU=Disabled,DC=Chongong,DC=local"
Get-ADUser leonel -Properties MemberOf | Select-Object -ExpandProperty MemberOf | `
  ForEach-Object { Remove-ADGroupMember -Identity $_ -Members leonel -Confirm:$false }
```

---

## Project 08 — Hyper-V Operations

**Requires:** P06 and P07 complete (new VMs created)
**Slash command:** `/winserver-p08`

### Phase 1 — VM Inventory

```powershell
Get-VM | ForEach-Object {
    [PSCustomObject]@{
        Name   = $_.Name
        State  = $_.State
        vCPU   = $_.ProcessorCount
        RAM_GB = [math]::Round($_.MemoryAssigned/1GB,1)
        Disks  = ($_ | Get-VMHardDiskDrive | Get-VHD | Measure-Object Size -Sum).Sum/1GB
        Switch = ($_ | Get-VMNetworkAdapter).SwitchName -join ","
    }
} | Format-Table -AutoSize
```

### Phase 2 — Virtual Switch Design

```powershell
New-VMSwitch -Name "vSwitch-External" -NetAdapterName "<physical-NIC>" -AllowManagementOS $true
New-VMSwitch -Name "vSwitch-Internal" -SwitchType Internal
```

### Phase 3 — Checkpoint Policy

```powershell
Get-VM | Set-VM -CheckpointType Production -AutomaticCheckpointsEnabled $false
```

### Phase 4 — RDS Migration (off DC — critical P01 finding)

Create WIN-RDS01 VM → install RD Session Host → migrate sessions from WIN-PRQD8TJG04M

```powershell
# After migration verified — remove RDS from DC
Remove-WindowsFeature Remote-Desktop-Services, RDS-RD-Server, RDS-Connection-Broker, `
  RDS-Gateway, RDS-Licensing, RDS-Web-Access -ComputerName WIN-PRQD8TJG04M
# Schedule reboot during maintenance window
```

---

## Project 09 — PowerShell Admin Platform and Windows Admin Center

**Requires:** P02-P08 complete
**Slash command:** `/winserver-p09`

### Phase 1 — Windows Admin Center

```powershell
# Silent install — gateway mode
msiexec /i WindowsAdminCenter.msi /qn /L*v wac-install.log SME_PORT=443 SSL_CERTIFICATE_OPTION=generate
# Access: https://WIN-PRQD8TJG04M (from Tailscale or LAN)
# Add managed servers: WIN-DC02, WIN-FS01, WIN-RDS01, WIN-WS01
# Restrict access: WAC Settings → Access → GG-ServerAdmins only
```

### Phase 2 — PowerShell Remoting

```powershell
Test-WSMan -ComputerName WIN-DC02, WIN-FS01, WIN-WS01
```

### Phase 3 — New-LabUser.ps1

```powershell
param([string]$FirstName, [string]$LastName, [string]$Department, [string]$Title)
$Username = $FirstName.ToLower()
$OU = "OU=$Department,OU=Users,DC=Chongong,DC=local"
New-ADUser -Name "$FirstName $LastName" -SamAccountName $Username `
  -UserPrincipalName "$Username@Chongong.local" -Path $OU `
  -Department $Department -Title $Title `
  -AccountPassword (Read-Host -AsSecureString "Password") -Enabled $true
Add-ADGroupMember -Identity "GG-$Department-Users" -Members $Username
```

### Phase 4 — Scheduled Reports

```powershell
# Stale accounts (not logged in 30+ days)
Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate |
  Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-30) } |
  Select-Object Name, SamAccountName, LastLogonDate | Export-Csv C:\Reports\stale.csv

# Schedule: Task Scheduler → weekly Monday 7am → svc-backup account
```

---

## Project 10 — Security Monitoring and Incident Response

**Requires:** P05 (audit GPO) and P09 (script platform) complete
**Slash command:** `/winserver-p10`

### Phase 1 — WEF Subscriptions

```powershell
wecutil qc /q:true   ! initialize WEF collector
wecutil cs C:\AdminScripts\WEF\SecurityEvents.xml
! XML defines: SourceInitiated, Security log IDs 4624/4625/4634/4648/4740/4728/4732/4756, System 7045
```

### Phase 2 — WEF GPO

```
Computer Config → Admin Templates → Windows Components → Event Forwarding →
Configure target Subscription Manager:
  Server=http://WIN-PRQD8TJG04M:5985/wsman/SubscriptionManager/WEC,Refresh=60
```

### Phase 3 — Verify Forwarding

```powershell
Get-WinEvent -LogName "ForwardedEvents" -MaxEvents 20 |
  Select-Object TimeCreated, Id, Message | Format-Table -Wrap
```

### Phase 4 — Wazuh Agent

```powershell
# Install Wazuh agent → point to Wazuh manager IP → enroll
Get-Service WazuhSvc   ! confirm running
```

### Phase 5 — Account Lockout IR Playbook

```
Detect: Event 4740 fires
  Get-ADUser <user> -Properties LockedOut, BadLogonCount, BadPasswordTime

Identify source:
  Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625} |
    Where-Object {$_.Properties[5].Value -eq '<user>'}

Determine if malicious:
  Known device? Known time? Check Event 4648 from same source.

Remediate:
  Benign: Unlock-ADAccount -Identity <user>
  Suspicious: Disable-ADAccount, quarantine source machine
```

---

## Project 11 — Backup and Disaster Recovery

**Requires:** P08 (Hyper-V) and P09 (scripts) complete
**Slash command:** `/winserver-p11`

### Phase 1 — AD Recycle Bin

```powershell
Get-ADOptionalFeature -Filter 'Name -like "Recycle*"' | Select-Object EnabledScopes
# If not enabled:
Enable-ADOptionalFeature "Recycle Bin Feature" -Scope ForestOrConfigurationSet `
  -Target "Chongong.local" -Confirm:$false

# Test: delete and restore
Remove-ADUser -Identity testuser -Confirm:$false
Get-ADObject -Filter {SamAccountName -eq 'testuser'} -IncludeDeletedObjects | Restore-ADObject
```

### Phase 2 — System State Backup

```powershell
Install-WindowsFeature Windows-Server-Backup
$Policy = New-WBPolicy
$Target = New-WBBackupTarget -VolumePath D:
Add-WBBackupTarget -Policy $Policy -Target $Target
Add-WBSystemState -Policy $Policy
Set-WBSchedule -Policy $Policy -Schedule 02:00
Set-WBPolicy -Policy $Policy
```

### Phase 3 — GPO Backup (before every change)

```powershell
$BackupPath = "C:\GPO-Backups\$(Get-Date -Format yyyyMMdd)"
New-Item -ItemType Directory -Path $BackupPath
Backup-Gpo -All -Path $BackupPath

# Restore:
Restore-GPO -Name "Default Domain Policy" -Path $BackupPath
```

### Phase 4 — Five Restore Tests (all must be executed)

| Test | Command | Proves |
|------|---------|--------|
| AD Recycle Bin | Restore-ADObject | AD object recovery works |
| File from shadow copy | Previous Versions tab on WIN-FS01 | VSS working |
| GPO restore | Restore-GPO | GPO rollback runbook works |
| DC system state | Restore on WIN-DC02 | DC recovery possible |
| VM restore | Restore from export | VM recovery possible |

---

## Project 12 — Microsoft 365 and Entra Hybrid Identity

**Requires:** P02, P05, P09, P11 complete
**Slash command:** `/winserver-p12`

### Phase 1 — Add UPN Suffix

```powershell
Get-ADForest | Set-ADForest -UPNSuffixes @{Add="<yourbusiness>.com"}
(Get-ADForest).UPNSuffixes   ! verify
```

### Phase 2 — Bulk UPN Update

```powershell
Get-ADUser -Filter * -SearchBase "OU=Users,DC=Chongong,DC=local" | ForEach-Object {
    Set-ADUser $_ -UserPrincipalName "$($_.SamAccountName)@<yourbusiness>.com"
}
```

### Phase 3 — Entra Connect Install

```
Custom installation:
  Auth method: Password Hash Sync
  Connect to Entra: global admin credentials
  Scope: OU=Users only (exclude _Admin, ServiceAccounts)
  Optional features: Password writeback (enable)
  Staging mode: ON for first validation → turn OFF only after confirming no unexpected deletes
```

### Phase 4 — Initial Sync and Verify

```powershell
Get-ADSyncScheduler
Start-ADSyncSyncCycle -PolicyType Delta
Get-ADSyncConnectorStatistics -ConnectorName "Chongong.local"
# Check Entra admin center: users should appear synced
```

### Phase 5 — Break/Fix: Sync Failure

```powershell
# Simulate service outage (reversible)
Stop-Service ADSync
# Observe sync failure in Entra Connect Health
Start-Service ADSync
Start-ADSyncSyncCycle -PolicyType Delta
Get-ADSyncScheduler | Select-Object LastSyncRunTime, NextSyncRunTime, SyncCycleEnabled
```

---

## Cross-Project Safety Rules

| Rule | Why |
|------|-----|
| Never modify Default Domain Policy | Use custom GPOs instead |
| Never delete AD objects | Disable + move to Disabled OU |
| Always GPO backup before changes | `Backup-Gpo -All -Path $BackupPath` |
| System state backup before DC changes | `Set-WBPolicy` daily |
| Scripts reviewed by Claude before running | Prevents AD damage |
| NPS XML export never committed to GitHub | Contains RADIUS shared secrets |

---

## Skills Saved Locations

| Location | Path |
|----------|------|
| Repo | `skills/winserver-projects.md` |
| Agents | `C:\Users\CHONGONG\.agents\skills\winserver-projects\SKILL.md` |
| Codex | `C:\Users\CHONGONG\.codex\skills\winserver-projects\SKILL.md` |
| Slash command | `C:\Users\CHONGONG\.claude\commands\winserver-projects.md` |

**Trigger phrases:** "windows server P02-P12", "AD architecture", "AGDLP", "replica DC",
"GPO baseline", "WIN-FS01", "WIN-WS01", "RDS migration", "Windows Admin Center",
"WEF forwarding", "Wazuh Windows", "system state backup", "Entra Connect", "hybrid identity"
