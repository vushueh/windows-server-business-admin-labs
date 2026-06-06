# Project 09 — PowerShell Administration Platform and Windows Admin Center

**Status:** ⬜ Planned (requires Projects 02–08 complete)
**Skill:** `/winserver-p09` — written when this project starts

## Objective

Build a repeatable PowerShell administration platform for the Chongong.local environment.
Deploy Windows Admin Center (WAC) as the central browser-based management GUI.
Write production-quality scripts for user provisioning, AD reporting, stale account cleanup,
and Hyper-V inventory — then schedule them as automated tasks.

**Why ninth:** By Project 09, all infrastructure exists (AD, DNS, DHCP, GPO, file server,
Hyper-V). This project automates the day-to-day admin tasks and provides a unified management
experience via Windows Admin Center — the skill that ties everything together.

## Environment Context

- Script library location: `C:\AdminScripts\` on WIN-PRQD8TJG04M
- WAC target: installed on WIN-PRQD8TJG04M, gateway mode, HTTPS port 443
- WAC manages: WIN-PRQD8TJG04M, WIN-DC02, WIN-FS01, WIN-RDS01, WIN-WS01, all Hyper-V VMs
- PowerShell remoting: enabled for srv-leonel (Tier1) and adm-leonel (Tier0) only

## Windows Admin Center — Phase 1 and 2

WAC is folded into this project as the management GUI layer over all the PowerShell work.

### What WAC Manages in This Lab

| WAC Feature | What It Controls |
|-------------|-----------------|
| Server Manager | WIN-PRQD8TJG04M, WIN-DC02, WIN-FS01, WIN-RDS01 |
| Virtual Machines | All Hyper-V VMs on WIN-PRQD8TJG04M |
| Active Directory (extension) | AD users, groups, OUs via WAC |
| Storage | WIN-FS01 shares, volumes, FSRM |
| Firewall | Review and manage Windows Firewall rules |
| Events | Centralized event log viewer across all managed servers |
| PowerShell | Remote PowerShell sessions directly from browser |

## Script Library

| Script | Purpose | Schedule |
|--------|---------|----------|
| New-LabUser.ps1 | Provision user: AD account, correct OU, group memberships, home folder | Manual |
| Remove-LabUser.ps1 | Offboard: disable, move to Quarantine OU, remove groups, rename | Manual |
| Get-StaleAccounts.ps1 | Report: users not logged in >30 days | Weekly |
| Get-ADGroupReport.ps1 | Report: all group memberships, nested groups flattened | Weekly |
| Get-VMInventory.ps1 | Report: all Hyper-V VMs, state, resources, uptime | Daily |
| Get-DHCPLeaseReport.ps1 | Report: all active DHCP leases with hostname and MAC | Daily |
| Get-ADPasswordExpiry.ps1 | Report: users with passwords expiring in next 14 days | Weekly |
| Backup-ADSystemState.ps1 | Trigger Windows Server Backup system state | Daily |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Install Windows Admin Center | WAC on WIN-PRQD8TJG04M, HTTPS, self-signed cert |
| 2 | Configure WAC Access | Add all managed servers; restrict WAC access to GG-ServerAdmins |
| 3 | Verify WAC Management | Confirm WAC can manage VMs, view event logs, open PS sessions |
| 4 | PowerShell Remoting Setup | Enable and test WinRM to WIN-DC02, WIN-FS01, WIN-WS01 |
| 5 | Write New-LabUser.ps1 | Provision script with OU placement, group membership, home folder |
| 6 | Write Remove-LabUser.ps1 | Offboarding script: disable, quarantine OU, group removal |
| 7 | Write Reporting Scripts | StaleAccounts, GroupReport, VMInventory, DHCPLeases, PasswordExpiry |
| 8 | Write Backup-ADSystemState.ps1 | System state backup wrapper for P11 integration |
| 9 | Test All Scripts | Run each script, review output, fix errors |
| 10 | Schedule Automated Tasks | Create scheduled tasks for daily/weekly scripts |
| 11 | Script Library Organization | Folder structure, README, version headers in each script |
| 12 | Document + Push | Script library committed, WAC config documented, STAR summary |

## Phase Detail

### Phase 1 — WAC Install
```powershell
# Download and install current Windows Admin Center silently (gateway mode)
Start-Process -FilePath ".\WindowsAdminCenter.exe" `
  -ArgumentList "/VERYSILENT /HTTPSPortNumber=443" `
  -Wait

# Legacy MSI installers used this pattern:
# msiexec /i WindowsAdminCenter.msi /qn /L*v wac-install.log SME_PORT=443 SSL_CERTIFICATE_OPTION=generate
# Access: https://WIN-PRQD8TJG04M (from Tailscale or LAN)
```

### Phase 2 — WAC RBAC
```powershell
# Restrict WAC gateway access to GG-ServerAdmins
# WAC Settings → Access → Gateway access → select GG-ServerAdmins
# Users get role based on AD group — WAC Administrator vs WAC Reader
```

### Phase 5 — New-LabUser.ps1 (skeleton)
```powershell
param(
  [string]$FirstName,
  [string]$LastName,
  [string]$Department,   # IT, Finance, Operations
  [string]$Title,
  [string]$Manager
)
$Username = $FirstName.ToLower()
$UPN = "$Username@Chongong.local"
$OU = "OU=$Department,OU=Users,DC=Chongong,DC=local"

New-ADUser -Name "$FirstName $LastName" -SamAccountName $Username -UserPrincipalName $UPN `
  -Path $OU -Department $Department -Title $Title -Manager $Manager `
  -AccountPassword (Read-Host -AsSecureString "Password") -Enabled $true

# Add to department global group
Add-ADGroupMember -Identity "GG-$Department-Users" -Members $Username

Write-Host "Created $Username in $OU and added to GG-$Department-Users"
```

### Phase 10 — Scheduled Tasks
```powershell
$Credential = Get-Credential "CHONGONG\svc-backup"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" `
  -Argument "-NonInteractive -File C:\AdminScripts\Get-StaleAccounts.ps1 -OutputPath C:\Reports\"
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "07:00"
Register-ScheduledTask -TaskName "Weekly-StaleAccountReport" -Action $Action `
  -Trigger $Trigger -RunLevel Highest -User $Credential.UserName `
  -Password $Credential.GetNetworkCredential().Password
```

## Verification Commands

```powershell
# WAC accessible
Invoke-WebRequest -Uri "https://WIN-PRQD8TJG04M" -UseDefaultCredentials

# WinRM connectivity to all managed servers
Test-WSMan -ComputerName WIN-DC02, WIN-FS01, WIN-WS01

# Scheduled tasks registered
Get-ScheduledTask | Where-Object TaskName -like "*Stale*" | Select-Object TaskName, State

# Test provisioning script (dry run)
.\New-LabUser.ps1 -FirstName "Test" -LastName "User" -Department IT -Title "Test Account"
```

## STAR Summary

**Situation:** All infrastructure is running but administration is entirely manual with no
scripts, no WAC GUI, no scheduled reporting, and no documented provisioning/offboarding process.
Each admin task requires someone to remember the correct commands.

**Task:** Build a PowerShell script library for all routine admin tasks, deploy Windows Admin
Center as the unified management GUI, and schedule automated reports so account hygiene is
maintained without manual effort.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
