# P01 Phase 2 — Password Policy + Account Lockout — Evidence

**Date:** 2026-06-22
**Executed by:** Leonel (PowerShell, on WIN-PRQD8TJG04M)
**Reviewed by:** Claude (per-step approval, AGENTS.md Tier 3)

## Pre-phase guard
```
Domain confirmed: DC=Chongong,DC=local
```

## Backup (before any edit)
```
DisplayName     : Default Domain Policy
GpoId           : 31b2f340-016d-11d2-945f-00c04fb984f9
Id              : 18bfe113-2d60-47ec-b044-8a931085ba17
BackupDirectory : C:\GPO-Backups\2026-06-22
CreationTime    : 6/22/2026 8:29:34 PM
DomainName      : Chongong.local
```
Rollback point: `Restore-GPO -Name "Default Domain Policy" -Path "C:\GPO-Backups\2026-06-22"`

## Change applied
```
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 14 -MaxPasswordAge (New-TimeSpan -Days 90) `
    -LockoutThreshold 5 -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)
gpupdate /force   # Computer + User policy update completed successfully
```

## Verification — before vs after

| Setting | Before | After | Target met |
|---|---|---|---|
| MinPasswordLength | 7 | 14 | ✅ |
| LockoutThreshold | 0 (disabled) | 5 | ✅ |
| LockoutDuration | 00:10:00 | 00:30:00 | ✅ |
| LockoutObservationWindow | 0 | 00:30:00 | ✅ |
| MaxPasswordAge | 42 days | 90.00:00:00 | ✅ |
| PasswordHistoryCount | 24 | 24 (unchanged) | ✅ |
| ComplexityEnabled | True | True (unchanged) | ✅ |

## radius-service review
```
SamAccountName : radius-service
PasswordNeverExpires : True
PasswordLastSet : 8/9/2025 5:22:01 PM
```
`PasswordNeverExpires=True` → exempt from the new `MaxPasswordAge=90d`. No action taken;
account purpose review deferred to Phase 4 (document-only).

## Locked accounts check
```
Search-ADAccount -LockedOut
```
Empty result — expected, since `LockoutThreshold` was previously 0 and no bad-attempt
counters could have accumulated before this change.

## Result
Phase 2 complete. Both critical gaps from the Phase 1 audit (no lockout, weak minimum
password length) are closed. No accounts locked out by the change. `radius-service`
exemption noted, not modified. GPO backup preserved for rollback.
