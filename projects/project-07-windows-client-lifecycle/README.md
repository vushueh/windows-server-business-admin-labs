# Project 07 — Windows Client Lifecycle

**Status:** ⬜ Planned (requires Projects 02, 05, and 06 complete)
**Skill:** `/winserver-p07` — written when this project starts

## Objective

Create a domain-joined Windows 11 workstation (WIN-WS01) as a Hyper-V VM, enforce client
GPOs, practice the full user lifecycle (onboarding → daily work → offboarding), install RSAT
for admin tooling, and verify the tiered admin model works correctly from the client side.

**Why seventh:** All AD structure, GPOs, file shares, and security baselines must exist
before a client is domain-joined — the workstation picks them up at join time. WIN-WS01 is
the test client for every GPO, share permission, and user account created in P02–P06.

## Environment Context

- Dedicated lab workstation VM: WIN-WS01 (Hyper-V VM — Windows 11 Pro/Enterprise, 2 vCPU, 4GB RAM, 60GB disk)
- Existing AD already shows several DESKTOP-* domain-joined clients. Those are useful for discovery, but WIN-WS01 is still needed as the controlled test client for screenshots, GPO testing, RSAT, offboarding drills, and repeatable evidence.
- OU target: Computers\Workstations
- GPOs applied at join: Workstations-LocalAdminRestriction, Workstations-AuditPolicy, Workstations-UserRestrictions (from P05)
- Test users: standard user `leonel`, Tier 2 admin `ws-leonel`, Tier 1 `srv-leonel` (should NOT be local admin here)

## Test Scenarios This Project Proves

| Scenario | Expected Result |
|----------|----------------|
| Standard user `leonel` logs in | No local admin, screen locks after 10min, drive maps to shares |
| ws-leonel logs in | Local admin on workstation, can run elevated tasks |
| adm-leonel tries to log in | Blocked by GPO (Deny logon to workstations for Tier0) |
| srv-leonel tries to log in | Not blocked (Tier1), but should not have local admin |
| Map \\WIN-FS01\Finance | Succeeds only if leonel is in GG-Finance-Users |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Create WIN-WS01 VM | Hyper-V VM: Windows 11, 2 vCPU, 4GB RAM, 60GB |
| 2 | Pre-join Preparation | Set DNS to 192.168.20.11, verify reachability |
| 3 | Domain Join | Join WIN-WS01 to Chongong.local, place in Computers\Workstations OU |
| 4 | Install RSAT | Install all Remote Server Administration Tools via PowerShell |
| 5 | GPO Verification | Run gpresult on WIN-WS01 — confirm all workstation GPOs applied |
| 6 | Tiered Login Tests | Test all 4 account tiers — confirm correct access and blocks |
| 7 | Drive Mapping via GPO | Map department shares by group membership using GPO drive map |
| 8 | Logon Script Test | Verify mapped drives appear for correct users only |
| 9 | Offboarding Simulation | Disable a disposable test user, confirm logon denied, drive maps removed |
| 10 | RSAT Admin Tasks | Manage AD users, GPOs, DNS, DHCP from WIN-WS01 using admin accounts |
| 11 | Document + Push | Test results recorded, lifecycle runbook written |

## Phase Detail

### Phase 4 — RSAT Install
```powershell
# Install all RSAT features on WIN-WS01
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

# Verify key tools
Get-WindowsCapability -Name Rsat.ActiveDirectory* -Online | Select-Object Name, State
Get-WindowsCapability -Name Rsat.GroupPolicy* -Online | Select-Object Name, State
Get-WindowsCapability -Name Rsat.DHCP* -Online | Select-Object Name, State
Get-WindowsCapability -Name Rsat.DNS* -Online | Select-Object Name, State
```

### Phase 7 — Drive Mapping via GPO
```
GPO: Workstations-DriveMaps
User Configuration → Preferences → Windows Settings → Drive Maps
Finance share: Map F: to \\WIN-FS01\Finance — Item-level targeting: GG-Finance-Users
IT share: Map I: to \\WIN-FS01\IT — Item-level targeting: GG-IT-Admins
```

### Phase 9 — Offboarding Simulation
```powershell
# Use a disposable account for the simulation, not Leonel's daily user.
$User = "test-offboard"

if (-not (Get-ADUser -Filter "SamAccountName -eq '$User'")) {
  New-ADUser -Name $User -SamAccountName $User `
    -Path "OU=Users,DC=Chongong,DC=local" -Enabled $true `
    -AccountPassword (Read-Host -AsSecureString "Temporary password for $User")
}

# Capture group memberships for rollback/audit before removing access.
Get-ADUser $User -Properties MemberOf |
  Select-Object -ExpandProperty MemberOf |
  Set-Content "C:\Audit\$User-groups-before-offboarding.txt"

# Disable account (never delete)
Disable-ADAccount -Identity $User

# Move to quarantine OU
Move-ADObject -Identity (Get-ADUser $User).DistinguishedName -TargetPath "OU=Quarantine,DC=Chongong,DC=local"

# Remove group memberships
Get-ADUser $User -Properties MemberOf | Select-Object -ExpandProperty MemberOf | ForEach-Object {
  Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false
}

# Confirm cannot log in
# Expected: disabled-account logon denied at WIN-WS01 for test-offboard
```

## Verification Commands

```powershell
# Confirm GPOs applied at workstation
gpresult /R /Scope:Computer
gpresult /R /Scope:User

# Confirm Tier0 blocked
# Log in as adm-leonel at WIN-WS01 console → should receive "logon restriction" error

# Confirm drive maps visible
net use

# Confirm RSAT tools accessible
dsa.msc   # AD Users and Computers (opens against DC)
gpmc.msc  # Group Policy Management
```

## STAR Summary

**Situation:** Existing DESKTOP-* machines are already domain joined, but there is no
dedicated, controlled lab workstation for repeatable evidence. Every GPO, share
permission, and tiered admin rule needs to be verified from a known client state.

**Task:** Build WIN-WS01, domain-join it, run every GPO and account scenario, and prove
the admin model, drive maps, and offboarding process work exactly as designed.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
