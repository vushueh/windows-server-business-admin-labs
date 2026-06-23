# P01 Phase 2 — Password Policy + Account Lockout

**Date:** 2026-06-22
**Who ran it:** Leonel, on `WIN-PRQD8TJG04M`, in PowerShell
**Script:** [`../scripts/p01-phase2-password-policy.ps1`](../scripts/p01-phase2-password-policy.ps1)

## Step 1 — Confirm the domain before touching anything

**Command:**
```powershell
$Domain = Get-ADDomain
if ($Domain.DistinguishedName -ne "DC=Chongong,DC=local") {
    throw "Unexpected domain DN: $($Domain.DistinguishedName) — stop and verify before continuing"
}
Write-Host "Domain confirmed: $($Domain.DistinguishedName)"
```

**Output:**
```
Domain confirmed: DC=Chongong,DC=local
```

## Step 2 — Back up Default Domain Policy

**Command:**
```powershell
$BackupFolder = "C:\GPO-Backups\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
Backup-GPO -Name "Default Domain Policy" -Path $BackupFolder
```

**Output:**
```
DisplayName     : Default Domain Policy
GpoId           : 31b2f340-016d-11d2-945f-00c04fb984f9
Id              : 18bfe113-2d60-47ec-b044-8a931085ba17
BackupDirectory : C:\GPO-Backups\2026-06-22
CreationTime    : 6/22/2026 8:29:34 PM
DomainName      : Chongong.local
```

Rollback point if anything goes wrong: `Restore-GPO -Name "Default Domain Policy" -Path "C:\GPO-Backups\2026-06-22"`.

## Step 3 — Set password and lockout policy

**Command:**
```powershell
$DomainDN = (Get-ADDomain).DistinguishedName
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 14 `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)
gpupdate /force
```

**Output:**
```
Computer Policy update has completed successfully.
User Policy update has completed successfully.
```

## Step 4 — Verify

**Command:**
```powershell
Get-ADDefaultDomainPasswordPolicy | Select-Object MinPasswordLength, LockoutThreshold, LockoutDuration, LockoutObservationWindow, MaxPasswordAge, PasswordHistoryCount, ComplexityEnabled
```

**Output:**
```
MinPasswordLength        : 14
LockoutThreshold         : 5
LockoutDuration          : 00:30:00
LockoutObservationWindow : 00:30:00
MaxPasswordAge           : 90.00:00:00
PasswordHistoryCount     : 24
ComplexityEnabled        : True
```

Before this change: `MinPasswordLength=7`, `LockoutThreshold=0` (no lockout at all),
`LockoutDuration=00:10:00`, `MaxPasswordAge=42 days`. Both critical gaps from the
Phase 1 audit are closed.

**Command:**
```powershell
Get-ADUser -Identity "radius-service" -Properties PasswordNeverExpires, PasswordLastSet | Select-Object SamAccountName, PasswordNeverExpires, PasswordLastSet
```

**Output:**
```
SamAccountName PasswordNeverExpires PasswordLastSet
-------------- -------------------- ---------------
radius-service                 True 8/9/2025 5:22:01 PM
```

`radius-service` has `PasswordNeverExpires=True`, so the new 90-day `MaxPasswordAge`
does not apply to it. No action taken — account purpose review is Phase 4.

**Command:**
```powershell
Search-ADAccount -LockedOut | Select-Object SamAccountName, BadLogonCount, LastBadPasswordAttempt
```

**Output:** empty — no accounts locked out. Expected, since lockout was previously
disabled and no bad-attempt counters could have accumulated.

## Result

Phase 2 is done. No screenshots were taken — this phase was run entirely in
PowerShell, and the command output above is the verification record.
