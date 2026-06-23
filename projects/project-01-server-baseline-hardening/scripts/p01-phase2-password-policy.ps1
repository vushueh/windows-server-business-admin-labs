# P01 Phase 2 - Password Policy + Account Lockout
# Run on WIN-PRQD8TJG04M (live PDC for Chongong.local). Executed by Leonel 2026-06-22.

# Pre-phase safety guard
$Domain = Get-ADDomain
if ($Domain.DistinguishedName -ne "DC=Chongong,DC=local") {
    throw "Unexpected domain DN: $($Domain.DistinguishedName) - stop and verify before continuing"
}
Write-Host "Domain confirmed: $($Domain.DistinguishedName)"

# Backup Default Domain Policy before any edit
$BackupFolder = "C:\GPO-Backups\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
Backup-GPO -Name "Default Domain Policy" -Path $BackupFolder

# Apply the policy change
$DomainDN = (Get-ADDomain).DistinguishedName
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 14 `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)

gpupdate /force

# Verification
Get-ADDefaultDomainPasswordPolicy | Select-Object MinPasswordLength, LockoutThreshold, LockoutDuration, LockoutObservationWindow, MaxPasswordAge, PasswordHistoryCount, ComplexityEnabled
Get-ADUser -Identity "radius-service" -Properties PasswordNeverExpires, PasswordLastSet | Select-Object SamAccountName, PasswordNeverExpires, PasswordLastSet
Search-ADAccount -LockedOut | Select-Object SamAccountName, BadLogonCount, LastBadPasswordAttempt

# Rollback (if ever needed) - IMPORTANT ORDER: disable lockout before reverting observation window
# Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN -LockoutThreshold 0
# Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN -MinPasswordLength 7 -LockoutDuration (New-TimeSpan -Minutes 10) -LockoutObservationWindow (New-TimeSpan -Minutes 0) -MaxPasswordAge (New-TimeSpan -Days 42)
# Restore-GPO -Name "Default Domain Policy" -Path "C:\GPO-Backups\2026-06-22"
