param(
    [ValidateSet('Plan', 'Apply')]
    [string]$Mode = 'Plan'
)

$ErrorActionPreference = 'Stop'

Import-Module ActiveDirectory

$Domain = Get-ADDomain
if ($Domain.DistinguishedName -ne 'DC=Chongong,DC=local') {
    throw "Unexpected domain DN: $($Domain.DistinguishedName)"
}

$Base = $Domain.DistinguishedName
$Netbios = $Domain.NetBIOSName
$Changes = New-Object System.Collections.Generic.List[string]

function Write-Plan {
    param([string]$Message)
    $Changes.Add($Message) | Out-Null
    Write-Host "[$Mode] $Message"
}

function Test-ADObjectDn {
    param([string]$Dn)
    try {
        Get-ADObject -Identity $Dn -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Ensure-OU {
    param(
        [string]$Name,
        [string]$Path,
        [bool]$Protected = $true
    )
    $Dn = "OU=$Name,$Path"
    if (Test-ADObjectDn $Dn) {
        Write-Plan "OU exists: $Dn"
        return $Dn
    }

    Write-Plan "Create OU: $Dn"
    if ($Mode -eq 'Apply') {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $Protected
    }
    return $Dn
}

function Move-ObjectIfNeeded {
    param(
        [string]$IdentityDn,
        [string]$TargetPath,
        [string]$Label
    )
    if (-not (Test-ADObjectDn $IdentityDn)) {
        Write-Plan "Skip missing object: $Label ($IdentityDn)"
        return
    }
    $Current = Get-ADObject -Identity $IdentityDn
    if ($Current.DistinguishedName -like "*,$TargetPath") {
        Write-Plan "Object already under target: $Label"
        return
    }

    Write-Plan "Move $Label to $TargetPath"
    if ($Mode -eq 'Apply') {
        $WasProtected = $false
        if ($Current.ObjectClass -eq 'organizationalUnit') {
            $Ou = Get-ADOrganizationalUnit -Identity $Current.DistinguishedName -Properties ProtectedFromAccidentalDeletion
            $WasProtected = [bool]$Ou.ProtectedFromAccidentalDeletion
            if ($WasProtected) {
                Write-Plan "Temporarily clear accidental-deletion protection for move: $Label"
                Set-ADOrganizationalUnit -Identity $Ou.DistinguishedName -ProtectedFromAccidentalDeletion $false
            }
        }
        Move-ADObject -Identity $IdentityDn -TargetPath $TargetPath
        if ($WasProtected) {
            $MovedDn = ($Current.DistinguishedName -replace [regex]::Escape(($Current.DistinguishedName -split ',', 2)[1]), $TargetPath)
            Write-Plan "Restore accidental-deletion protection after move: $Label"
            Set-ADOrganizationalUnit -Identity $MovedDn -ProtectedFromAccidentalDeletion $true
        }
    }
}

function Ensure-ObjectAtTarget {
    param(
        [string]$SourceDn,
        [string]$TargetDn,
        [string]$TargetPath,
        [string]$Label
    )

    if (Test-ADObjectDn $TargetDn) {
        Write-Plan "Object already under target: $Label"
        return
    }

    if (Test-ADObjectDn $SourceDn) {
        Move-ObjectIfNeeded -IdentityDn $SourceDn -TargetPath $TargetPath -Label $Label
        return
    }

    Write-Plan "Skip missing object: $Label ($SourceDn or $TargetDn)"
}

function Ensure-Group {
    param(
        [string]$Name,
        [ValidateSet('Global', 'DomainLocal', 'Universal')]
        [string]$Scope,
        [string]$Path,
        [string]$Description = ''
    )

    $Existing = Get-ADGroup -LDAPFilter "(cn=$Name)" -ErrorAction SilentlyContinue
    if ($Existing) {
        Write-Plan "Group exists: $Name"
        if ($Existing.DistinguishedName -notlike "*,$Path" -and ($Existing.Name -like 'GG-*' -or $Existing.Name -like 'DL-*')) {
            Write-Plan "Move group $Name to $Path"
            if ($Mode -eq 'Apply') {
                Move-ADObject -Identity $Existing.DistinguishedName -TargetPath $Path
            }
        }
        return
    }

    Write-Plan "Create $Scope group: $Name in $Path"
    if ($Mode -eq 'Apply') {
        New-ADGroup -Name $Name -SamAccountName $Name -GroupScope $Scope -GroupCategory Security -Path $Path -Description $Description
    }
}

function Ensure-Member {
    param(
        [string]$Group,
        [string]$Member
    )

    try {
        $GroupObj = Get-ADGroup -Identity $Group -ErrorAction Stop
    } catch {
        $GroupObj = $null
    }
    try {
        $MemberObj = Get-ADObject -LDAPFilter "(|(sAMAccountName=$Member)(cn=$Member))" -ErrorAction Stop | Select-Object -First 1
    } catch {
        $MemberObj = $null
    }
    if ($Mode -eq 'Plan' -and -not $GroupObj) {
        Write-Plan "Would add member after group exists: $Member -> $Group"
        return
    }
    if (-not $GroupObj) {
        throw "Group not found for membership update: $Group"
    }
    if (-not $MemberObj) {
        if ($Mode -eq 'Plan') {
            Write-Plan "Would add member after member exists: $Member -> $Group"
            return
        }
        Write-Plan "Skip missing member $Member for group $Group"
        return
    }

    $IsMember = Get-ADGroupMember -Identity $GroupObj -Recursive:$false | Where-Object {$_.DistinguishedName -eq $MemberObj.DistinguishedName}
    if ($IsMember) {
        Write-Plan "Member already present: $Member -> $Group"
        return
    }

    Write-Plan "Add member: $Member -> $Group"
    if ($Mode -eq 'Apply') {
        Add-ADGroupMember -Identity $GroupObj -Members $MemberObj
    }
}

function Ensure-DisabledUser {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Description
    )

    try {
        $Existing = Get-ADUser -Identity $Name -ErrorAction Stop
    } catch {
        $Existing = $null
    }
    if ($Existing) {
        Write-Plan "User exists: $Name"
        if ($Existing.DistinguishedName -notlike "*,$Path") {
            Write-Plan "Move user $Name to $Path"
            if ($Mode -eq 'Apply') {
                Move-ADObject -Identity $Existing.DistinguishedName -TargetPath $Path
            }
        }
        return
    }

    Write-Plan "Create disabled staged user: $Name in $Path"
    if ($Mode -eq 'Apply') {
        New-ADUser -Name $Name -SamAccountName $Name -UserPrincipalName "$Name@Chongong.local" -Path $Path -Enabled $false -Description $Description
    }
}

function Ensure-Delegation {
    param(
        [string]$Dn,
        [string]$Principal,
        [string]$Rule,
        [string]$Marker,
        [string]$Label
    )

    $AclText = dsacls $Dn 2>&1 | Out-String
    if ($AclText -match [regex]::Escape($Principal) -and $AclText -match [regex]::Escape($Marker)) {
        Write-Plan "Delegation already present: $Label"
        return
    }

    Write-Plan "Add delegation: $Label"
    if ($Mode -eq 'Apply') {
        dsacls $Dn /I:S /G $Rule | Out-Null
    }
}

$AdminOu = "OU=_Admin,$Base"
$GroupsOu = "OU=Groups,$Base"

# The domain already has built-in CN=Computers and CN=Users containers at the root.
# AD does not allow root OUs with the same leaf names, so managed objects live
# under purpose-built OUs and the built-in containers remain intact.
$ManagedComputersOu = Ensure-OU -Name 'ManagedComputers' -Path $Base
$ServersOu = Ensure-OU -Name 'Servers' -Path $ManagedComputersOu
$WorkstationsOu = Ensure-OU -Name 'Workstations' -Path $ManagedComputersOu
$UsersOu = Ensure-OU -Name 'ManagedUsers' -Path $Base
$GlobalGroupsOu = Ensure-OU -Name 'GlobalGroups' -Path $GroupsOu
$DomainLocalGroupsOu = Ensure-OU -Name 'DomainLocalGroups' -Path $GroupsOu

foreach ($Dept in @('Finance', 'HR', 'IT', 'Management', 'Sales')) {
    Ensure-ObjectAtTarget -SourceDn "OU=$Dept,$Base" -TargetDn "OU=$Dept,$UsersOu" -TargetPath $UsersOu -Label "department OU $Dept"
}

$Computers = Get-ADComputer -Filter * -Properties OperatingSystem | Where-Object {$_.DistinguishedName -notlike "*,OU=Domain Controllers,$Base"}
foreach ($Computer in $Computers) {
    $Target = if ($Computer.Name -like 'DESKTOP-*') { $WorkstationsOu } else { $ServersOu }
    Move-ObjectIfNeeded -IdentityDn $Computer.DistinguishedName -TargetPath $Target -Label "computer $($Computer.Name)"
}

$GlobalGroups = @(
    'GG-Finance-Users',
    'GG-HR-Users',
    'GG-IT-Users',
    'GG-Management-Users',
    'GG-Sales-Users',
    'GG-IT-Admins',
    'GG-WorkstationAdmins',
    'GG-Helpdesk',
    'GG-NetAdmins',
    'GG-Net-ReadOnly',
    'GG-SOC-Analysts'
)

foreach ($Group in $GlobalGroups) {
    Ensure-Group -Name $Group -Scope Global -Path $GlobalGroupsOu -Description "P02 AD architecture group"
}

foreach ($Group in @('GG-Tier0-Admins', 'GG-ServerAdmins')) {
    Ensure-Group -Name $Group -Scope Global -Path $GlobalGroupsOu -Description "Existing P01 admin group moved into P02 group structure"
}

$DepartmentMembers = @{
    'GG-Finance-Users'    = @('achiril.desmond', 'mickelle.tsongwine')
    'GG-HR-Users'         = @('elsa.chongong', 'michell.chongong')
    'GG-IT-Users'         = @('akaseng.frankline', 'vushueh.banks')
    'GG-Management-Users' = @('chongong.leonel', 'gefter.mbi')
    'GG-Sales-Users'      = @('joiceline.kinyuy', 'lionel.chongong')
}

foreach ($Group in $DepartmentMembers.Keys) {
    foreach ($Member in $DepartmentMembers[$Group]) {
        Ensure-Member -Group $Group -Member $Member
    }
}

$DomainLocalGroups = @(
    'DL-Finance-Share-RW',
    'DL-HR-Share-RW',
    'DL-IT-Share-RW',
    'DL-IT-Share-Full',
    'DL-Management-Share-RW',
    'DL-Sales-Share-RW'
)

foreach ($Group in $DomainLocalGroups) {
    Ensure-Group -Name $Group -Scope DomainLocal -Path $DomainLocalGroupsOu -Description "P02 staged domain local group for P06 file server permissions"
}

$GroupNesting = @{
    'DL-Finance-Share-RW'    = 'GG-Finance-Users'
    'DL-HR-Share-RW'         = 'GG-HR-Users'
    'DL-IT-Share-RW'         = 'GG-IT-Users'
    'DL-Management-Share-RW' = 'GG-Management-Users'
    'DL-Sales-Share-RW'      = 'GG-Sales-Users'
}

foreach ($DL in $GroupNesting.Keys) {
    Ensure-Member -Group $DL -Member $GroupNesting[$DL]
}

$Tier2Ou = "OU=Tier2-WorkstationAdmins,$AdminOu"
$ServiceAccountsOu = "OU=ServiceAccounts,$AdminOu"
Ensure-DisabledUser -Name 'ws-leonel' -Path $Tier2Ou -Description 'Tier 2 workstation admin account, staged disabled in P02 until password handoff/use is approved'
Ensure-Member -Group 'GG-WorkstationAdmins' -Member 'ws-leonel'

Ensure-DisabledUser -Name 'svc-backup' -Path $ServiceAccountsOu -Description 'Staged backup service account, disabled until owning backup workflow is implemented'
Ensure-DisabledUser -Name 'svc-sync' -Path $ServiceAccountsOu -Description 'Staged sync service account, disabled until owning sync workflow is implemented'

$RecycleBin = Get-ADOptionalFeature 'Recycle Bin Feature'
if ($RecycleBin.EnabledScopes.Count -gt 0) {
    Write-Plan "AD Recycle Bin already enabled"
} else {
    Write-Plan "Enable AD Recycle Bin for forest $($Domain.Forest)"
    if ($Mode -eq 'Apply') {
        Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $Domain.Forest -Confirm:$false
    }
}

$HelpdeskPrincipal = "$Netbios\GG-Helpdesk"
Ensure-Delegation -Dn $UsersOu -Principal $HelpdeskPrincipal -Rule "${HelpdeskPrincipal}:CA;Reset Password;user" -Marker 'Reset Password' -Label 'GG-Helpdesk reset password on ManagedUsers users'
Ensure-Delegation -Dn $UsersOu -Principal $HelpdeskPrincipal -Rule "${HelpdeskPrincipal}:WP;pwdLastSet;user" -Marker 'pwdLastSet' -Label 'GG-Helpdesk force password change on ManagedUsers users'
Ensure-Delegation -Dn $UsersOu -Principal $HelpdeskPrincipal -Rule "${HelpdeskPrincipal}:WP;lockoutTime;user" -Marker 'lockoutTime' -Label 'GG-Helpdesk unlock accounts on ManagedUsers users'

Write-Host ''
Write-Host '=== Verification ===' -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName

Get-ADGroup -Filter 'Name -like "GG-*" -or Name -like "DL-*"' |
    Select-Object Name, GroupScope, DistinguishedName |
    Sort-Object Name

Get-ADComputer -Filter * -Properties OperatingSystem |
    Select-Object Name, OperatingSystem, DistinguishedName |
    Sort-Object Name

Get-ADOptionalFeature 'Recycle Bin Feature' |
    Select-Object Name, EnabledScopes

Write-Host ''
Write-Host "Completed P02 AD architecture script in $Mode mode. Log entry count: $($Changes.Count)"
