# P01 Phase 3 - Tiered Admin Model
# Run on WIN-PRQD8TJG04M (live PDC for Chongong.local). Executed by Leonel 2026-06-22.

$DomainDN = (Get-ADDomain).DistinguishedName

# --- OU structure ---
New-ADOrganizationalUnit -Name "_Admin" -Path $DomainDN -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier0-DomainAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "Tier1-ServerAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "Tier2-WorkstationAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "ServiceAccounts" -Path "OU=_Admin,$DomainDN"

# --- Account creation ---
# NOTE: New-ADUser with -AccountPassword + -Enabled $true in one call hit a PAN-OS-style
# quirk: AD set the password but then failed the simultaneous Enable validation
# (ADPasswordComplexityException) even though the password itself was actually valid-length.
# Root cause was traced to a separate Enable-ADAccount complexity check; resolved by running
# Set-ADAccountPassword -Reset (interactive Read-Host -AsSecureString) followed by a standalone
# Enable-ADAccount call. Passwords are never stored in this repo or in chat - typed directly by
# Leonel into masked Read-Host prompts on the server.
#
# $admPwd = Read-Host -AsSecureString -Prompt "New password for adm-leonel"
# New-ADUser -Name "adm-leonel" -SamAccountName "adm-leonel" -UserPrincipalName "adm-leonel@Chongong.local" `
#     -Path "OU=Tier0-DomainAdmins,OU=_Admin,$DomainDN" -AccountPassword $admPwd -Enabled $false
# Set-ADAccountPassword -Identity "adm-leonel" -Reset -NewPassword $admPwd
# Enable-ADAccount -Identity "adm-leonel"
#
# $srvPwd = Read-Host -AsSecureString -Prompt "New password for srv-leonel"
# New-ADUser -Name "srv-leonel" -SamAccountName "srv-leonel" -UserPrincipalName "srv-leonel@Chongong.local" `
#     -Path "OU=Tier1-ServerAdmins,OU=_Admin,$DomainDN" -AccountPassword $srvPwd -Enabled $false
# Set-ADAccountPassword -Identity "srv-leonel" -Reset -NewPassword $srvPwd
# Enable-ADAccount -Identity "srv-leonel"

# --- Groups ---
$GroupsOU = (Get-ADOrganizationalUnit -Filter {Name -eq "Groups"} | Select-Object -First 1).DistinguishedName
New-ADGroup -Name "GG-Tier0-Admins" -GroupScope Global -GroupCategory Security -Path $GroupsOU -Description "Shadow group for Tier0 PSO"
Add-ADGroupMember -Identity "GG-Tier0-Admins" -Members "adm-leonel"
New-ADGroup -Name "GG-ServerAdmins" -GroupScope Global -GroupCategory Security -Path $GroupsOU -Description "Tier1 server admins - rights granted via GPO in P05"
Add-ADGroupMember -Identity "GG-ServerAdmins" -Members "srv-leonel"
Add-ADGroupMember -Identity "Domain Admins" -Members "adm-leonel"

# --- PSO ---
New-ADFineGrainedPasswordPolicy -Name "PSO-Tier0-Admins" -Precedence 10 -MinPasswordLength 20 `
    -LockoutThreshold 3 -LockoutDuration (New-TimeSpan -Minutes 60) -LockoutObservationWindow (New-TimeSpan -Minutes 60) `
    -MaxPasswordAge (New-TimeSpan -Days 180) -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false
Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-Tier0-Admins" -Subjects "GG-Tier0-Admins"

# --- Unplanned finding mid-phase: Domain Admins was massively over-provisioned (12 members,
# including 10 personal accounts and the testuser test account) - not in the original Phase 1
# audit findings table. Leonel decided which accounts to keep as Domain Admins (explicit
# decision, not the original P01 design default). No accounts were deleted - membership only. ---
Remove-ADGroupMember -Identity "Domain Admins" -Members `
    "lionel.chongong", "joiceline.kinyuy", "mickelle.tsongwine", "achiril.desmond", `
    "gefter.mbi", "michell.chongong", "elsa.chongong", "vushueh.banks", `
    "akaseng.frankline", "testuser" -Confirm:$false

# Rollback (if ever needed):
# Add-ADGroupMember -Identity "Domain Admins" -Members `
#     "lionel.chongong", "joiceline.kinyuy", "mickelle.tsongwine", "achiril.desmond", `
#     "gefter.mbi", "michell.chongong", "elsa.chongong", "vushueh.banks", `
#     "akaseng.frankline", "testuser"

# --- Verification ---
Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "_Admin"} | Select-Object Name, DistinguishedName | Sort-Object DistinguishedName
Get-ADPrincipalGroupMembership -Identity "srv-leonel" | Select-Object Name, GroupScope
Get-ADUser -Identity "adm-leonel" -Properties MemberOf | Select-Object SamAccountName, @{N="Groups";E={($_.MemberOf | ForEach-Object {($_ -split ',')[0] -replace 'CN=',''}) -join ', '}}
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel" | Select-Object Name, Precedence
Get-ADGroupMember -Identity "Domain Admins" | Select-Object SamAccountName
