# Phase 6 -- Break/fix lockout exercise for testuser
# Reviewed and approved by Leonel before execution. Resets password (value never
# displayed/stored), triggers failed logons to confirm LockoutThreshold, then
# unlocks, disables, and quarantines the account. No AD objects are deleted.

# 1. Reset password to a random, never-displayed value
$NewPass = -join ((48..57)+(65..90)+(97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
$SecurePass = ConvertTo-SecureString $NewPass -AsPlainText -Force
Set-ADAccountPassword -Identity testuser -Reset -NewPassword $SecurePass
Write-Host "Password reset done for testuser (value not displayed or stored)"

# 2. Trigger failed logons until lockout (LockoutThreshold=5 from Phase 2)
for ($i = 1; $i -le 5; $i++) {
    net use \\localhost\IPC$ /user:CHONGONG\testuser "WrongPassword$i!" 2>&1 | Out-Null
    net use \\localhost\IPC$ /delete 2>&1 | Out-Null
    Start-Sleep -Seconds 1
    $u = Get-ADUser testuser -Properties BadLogonCount, LockedOut
    Write-Host "Attempt $i -> BadLogonCount=$($u.BadLogonCount) LockedOut=$($u.LockedOut)"
    if ($u.LockedOut) { break }
}

# 3. Confirm lockout
Search-ADAccount -LockedOut | Select-Object SamAccountName, LockedOut

# 4. Unlock, disable, quarantine
Unlock-ADAccount -Identity testuser
Disable-ADAccount -Identity testuser

$ouExists = Get-ADOrganizationalUnit -Filter "Name -eq 'Quarantine'" -ErrorAction SilentlyContinue
if (-not $ouExists) {
    New-ADOrganizationalUnit -Name "Quarantine" -Path "DC=Chongong,DC=local" -ProtectedFromAccidentalDeletion $true
}

$dn = (Get-ADUser testuser).DistinguishedName
Move-ADObject -Identity $dn -TargetPath "OU=Quarantine,DC=Chongong,DC=local"

Get-ADUser testuser -Properties DistinguishedName, Enabled, LockedOut |
    Select-Object SamAccountName, DistinguishedName, Enabled, LockedOut
