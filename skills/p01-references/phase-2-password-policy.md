# Phase 2 — Fix Critical Security: Password Policy + Account Lockout

## Goal
Fix the two critical gaps: LockoutThreshold=0 (no lockout) and MinPasswordLength=7 (too weak).
Use Group Policy Management Console (GPMC) to make the change, PowerShell to verify.

---

## Pre-Phase Safety Check

```powershell
# Guard: confirm you are on the right domain before touching Default Domain Policy
$Domain = Get-ADDomain
if ($Domain.DistinguishedName -ne "DC=Chongong,DC=local") {
    throw "Unexpected domain DN: $($Domain.DistinguishedName) — stop and verify before continuing"
}
Write-Host "Domain confirmed: $($Domain.DistinguishedName)"
```

---

## Track A — GUI Steps (GPMC)

### Console: Group Policy Management

Open: **Start → Windows Administrative Tools → Group Policy Management**
*(or: `gpmc.msc` in Run)*

### Step A1 — Back up Default Domain Policy first

1. Expand: **Forest → Domains → Chongong.local → Group Policy Objects**
2. Right-click **Default Domain Policy** → **Back Up...**
3. Set backup folder: `C:\GPO-Backups\` + today's date subfolder
4. Click **Back Up** → wait for "The backup was successful"

**Screenshot to capture:** Backup completion dialog showing "Succeeded"

### Step A2 — Edit Password Policy

1. Right-click **Default Domain Policy** → **Edit**
2. Navigate to:
   `Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Password Policy`
3. Double-click each setting and change:

| Setting | Current | Target |
|---------|---------|--------|
| Enforce password history | 24 | 24 (no change) |
| Maximum password age | 42 days | 90 days |
| Minimum password age | 1 day | 1 day (no change) |
| Minimum password length | 7 | **14** |
| Password must meet complexity | Enabled | Enabled (no change) |

**Screenshot to capture:** Password Policy node showing Minimum password length = 14

### Step A3 — Edit Account Lockout Policy

1. Navigate (same editor):
   `Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Account Lockout Policy`
2. Change:

| Setting | Current | Target |
|---------|---------|--------|
| Account lockout threshold | 0 (disabled) | **5 invalid logon attempts** |
| Account lockout duration | 10 minutes | **30 minutes** |
| Reset account lockout counter after | 0 | **30 minutes** |

> Setting threshold to 5 will auto-suggest values for duration and counter — accept or set manually.

**Screenshot to capture:** Account Lockout Policy showing threshold=5, duration=30, counter=30

4. Close Group Policy Management Editor
5. Run `gpupdate /force` to apply immediately

---

## Track B — PowerShell Verification

### Verify backup exists:
```powershell
Get-ChildItem "C:\GPO-Backups" -Recurse | Where-Object {$_.Name -eq "bkupInfo.xml"}
```

### Verify policy applied:
```powershell
Get-ADDefaultDomainPasswordPolicy | Select-Object `
    MinPasswordLength, LockoutThreshold, LockoutDuration, LockoutObservationWindow,
    MaxPasswordAge, PasswordHistoryCount, ComplexityEnabled
```

**Expected:**
```
MinPasswordLength       : 14
LockoutThreshold        : 5
LockoutDuration         : 00:30:00
LockoutObservationWindow: 00:30:00
MaxPasswordAge          : 90.00:00:00
PasswordHistoryCount    : 24
ComplexityEnabled       : True
```

### Check radius-service:
```powershell
Get-ADUser -Identity "radius-service" -Properties PasswordNeverExpires, PasswordLastSet |
    Select-Object SamAccountName, PasswordNeverExpires, PasswordLastSet
```
If `PasswordNeverExpires = True`: exempt from MaxPasswordAge. Do NOT change now — see Phase 4.

### Check no accounts locked:
```powershell
Search-ADAccount -LockedOut | Select-Object SamAccountName, BadLogonCount, LastBadPasswordAttempt
```
**Expected:** Empty (threshold was 0, no bad-attempt counts could have accumulated).

---

## Rollback Procedure

**GUI rollback (preferred — atomic and reversible):**
1. GPMC → Group Policy Objects → right-click Default Domain Policy → **Restore from Backup...**
2. Select backup folder → select the backup → Restore

**PowerShell rollback — IMPORTANT ORDER:**
Must set LockoutThreshold to 0 FIRST. Setting threshold=5 with observation window=0 creates a
state where bad attempts never age out.

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName

# Step 1: disable lockout first
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN -LockoutThreshold 0

# Step 2: revert remaining settings
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 7 `
    -LockoutDuration (New-TimeSpan -Minutes 10) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 0) `
    -MaxPasswordAge (New-TimeSpan -Days 42)
```

---

## Documentation Checklist — Phase 2

- [ ] Screenshot: GPO backup completion dialog
- [ ] Screenshot: Password Policy — MinPasswordLength = 14
- [ ] Screenshot: Account Lockout Policy — threshold=5, duration=30min, counter=30min
- [ ] PowerShell: `Get-ADDefaultDomainPasswordPolicy` output saved to docs/p01-audit-baseline.md
- [ ] radius-service password state documented
- [ ] No accounts currently locked — confirmed
- [ ] testuser noted — will be handled in Phase 6
