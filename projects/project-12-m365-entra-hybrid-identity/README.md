# Project 12 — Microsoft 365 and Entra Hybrid Identity

**Status:** ⬜ Planned (requires Projects 02, 05, 09, and 11 complete)
**Skill:** `/winserver-p12` — written when this project starts

## Objective

Connect the on-premises Chongong.local AD to Microsoft 365 via Entra Connect (formerly
Azure AD Connect). Add a custom UPN suffix aligned to your M365 domain, sync on-prem
users to cloud identities, and build a documented onboarding/offboarding workflow that
works in both on-prem AD and M365 simultaneously.

**Why twelfth:** Hybrid identity requires a clean AD (P02), enforced UPNs (naming standards),
and automated provisioning scripts (P09). It feeds into the capstone (P13) because Entra-synced
groups control M365 license assignment and can be used in NPS/RADIUS conditional access.

## Environment Context

- On-prem domain: `Chongong.local` (not routable — cannot be used as M365 UPN)
- M365 UPN suffix target: `<yourbusiness>.com` (Leonel to choose at project start)
- Entra Connect server: runs on WIN-PRQD8TJG04M (acceptable for lab; dedicated server in enterprise)
- Sync account: `svc-sync` if using a custom AD DS connector account; otherwise Entra Connect creates its own connector account
- M365 tenant: existing or new (Leonel to confirm at project start)

## Hybrid Identity Architecture

```
On-Prem AD (Chongong.local)          Microsoft 365 / Entra
  leonel@Chongong.local   ──sync──▶  leonel@<yourbusiness>.com
  GG-Finance-Users        ──sync──▶  Entra group → M365 license assignment
  svc-sync or connector account ──auth──▶  Entra Connect sync service
```

## Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| UPN suffix | `<yourbusiness>.com` | Chongong.local is not internet-routable |
| Sync mode | Password Hash Sync (PHS) | Simplest for lab; no ADFS/PTA dependency |
| Scope filter | Sync Users OU only | Exclude admin accounts (adm-*, srv-*, ws-*, svc-*) from cloud |
| License assignment | Group-based licensing | Entra group → license; not per-user manual |
| Password writeback | Enabled only after permissions are verified | Password reset in M365 writes back to on-prem AD |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | M365 Tenant Verification | Confirm M365 tenant exists, custom domain verified in DNS |
| 2 | Add UPN Suffix to AD | Add `<yourbusiness>.com` UPN suffix to on-prem AD |
| 3 | Update User UPNs | Change all standard users from @Chongong.local to @<yourbusiness>.com |
| 4 | Prepare svc-sync | Verify svc-sync exists with minimum permissions for Entra Connect |
| 5 | Install Entra Connect | Custom install, select Password Hash Sync, scope to Users OU, start in staging mode |
| 6 | Initial Sync | Review pending adds/deletes, disable staging mode only after verification |
| 7 | Group-Based Licensing | Create Entra group → assign M365 license (E3 or Business) |
| 8 | Password Writeback | Enable and test: reset password in M365 portal → confirm in AD |
| 9 | Onboarding Workflow | Update New-LabUser.ps1 (from P09) to set correct UPN suffix |
| 10 | Offboarding Workflow | Update Remove-LabUser.ps1: disable on-prem → M365 license released |
| 11 | Break/Fix Exercise | Remove svc-sync permissions → confirm sync failure → restore → re-sync |
| 12 | Document + Push | Sync config, UPN design, onboarding/offboarding runbook committed |

## Phase Detail

### Phase 2 — Add UPN Suffix
```powershell
# Add routable UPN suffix to AD forest
Get-ADForest | Set-ADForest -UPNSuffixes @{Add="<yourbusiness>.com"}

# Verify
(Get-ADForest).UPNSuffixes
```

### Phase 3 — Bulk UPN Update
```powershell
# Update all standard users in Users OU to new UPN suffix
Get-ADUser -Filter * -SearchBase "OU=Users,DC=Chongong,DC=local" |
  ForEach-Object {
    $NewUPN = "$($_.SamAccountName)@<yourbusiness>.com"
    Set-ADUser $_ -UserPrincipalName $NewUPN
    Write-Host "Updated $($_.SamAccountName) to $NewUPN"
  }
```

### Phase 5 — Entra Connect Sync Scope
```
Installation wizard settings:
  Authentication method: Password Hash Sync
  Connect to Entra: global admin credentials
  Sync scope: Domain and OU filtering → select OU=Users only
    (excludes _Admin, ServiceAccounts from cloud sync)
  Optional features: Password writeback (enable)
  Staging mode: ON for first validation; turn OFF only after confirming no unexpected deletes/updates
```

### Phase 11 — Break/Fix: Sync Failure
```powershell
# Simulate a reversible sync service outage without changing AD permissions.
Stop-Service ADSync
# Observe sync failure in Entra Connect Health / sync status.
Start-Service ADSync
Start-ADSyncSyncCycle -PolicyType Delta

# Verify sync healthy
Get-ADSyncScheduler | Select-Object LastSyncRunTime, NextSyncRunTime, SyncCycleEnabled
```

## Verification Commands

```powershell
# On-prem: confirm sync running
Get-ADSyncScheduler
Get-ADSyncConnectorStatistics -ConnectorName "Chongong.local"

# Confirm user synced to Entra (check Entra admin center or via MS Graph)
# https://entra.microsoft.com → Users → search for leonel

# Confirm password writeback working
# Reset leonel password in M365 admin center → login to WIN-WS01 with new password

# Confirm UPNs correct
Get-ADUser -Filter * -SearchBase "OU=Users,DC=Chongong,DC=local" |
  Select-Object SamAccountName, UserPrincipalName
```

## STAR Summary

**Situation:** On-prem AD and M365 are completely separate. Users have no cloud identity.
Onboarding requires two separate account creation steps. Password resets don't sync.
The lab has no hybrid identity foundation for M365-dependent projects.

**Task:** Deploy Entra Connect with Password Hash Sync, scope to standard users only,
enable password writeback, and update the provisioning scripts to manage both AD and M365
identity in a single workflow.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
