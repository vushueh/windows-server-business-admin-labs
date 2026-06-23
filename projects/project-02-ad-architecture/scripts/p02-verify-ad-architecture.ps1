param(
    [string]$ExpectedDomainDn = 'DC=Chongong,DC=local'
)

$ErrorActionPreference = 'Stop'

Import-Module ActiveDirectory

$Domain = Get-ADDomain
if ($Domain.DistinguishedName -ne $ExpectedDomainDn) {
    throw "Unexpected domain DN: $($Domain.DistinguishedName)"
}

$Base = $Domain.DistinguishedName

function Write-ResultTable {
    param([object[]]$Rows)

    $Rows | Format-Table -AutoSize | Out-String -Width 240 | Write-Host
}

Write-Host '=== Domain ===' -ForegroundColor Cyan
Write-ResultTable (Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode)
Write-ResultTable (Get-ADForest | Select-Object Name, ForestMode)

Write-Host ''
Write-Host '=== Managed OUs ===' -ForegroundColor Cyan
Write-ResultTable (Get-ADOrganizationalUnit -Filter * |
    Select-Object Name, DistinguishedName |
    Sort-Object DistinguishedName)

Write-Host ''
Write-Host '=== Managed Computers ===' -ForegroundColor Cyan
Write-ResultTable (Get-ADComputer -Filter * -Properties OperatingSystem |
    Select-Object Name, OperatingSystem, DistinguishedName |
    Sort-Object Name)

Write-Host ''
Write-Host '=== P02 Groups ===' -ForegroundColor Cyan
Write-ResultTable (Get-ADGroup -Filter 'Name -like "GG-*" -or Name -like "DL-*"' |
    Select-Object Name, GroupScope, DistinguishedName |
    Sort-Object Name)

Write-Host ''
Write-Host '=== Department Group Members ===' -ForegroundColor Cyan
$GroupRows = @()
foreach ($Group in @(
    'GG-Finance-Users',
    'GG-HR-Users',
    'GG-IT-Users',
    'GG-Management-Users',
    'GG-Sales-Users',
    'GG-WorkstationAdmins'
)) {
    $Members = Get-ADGroupMember -Identity $Group -ErrorAction Stop |
        Select-Object -ExpandProperty SamAccountName
    $GroupRows += [pscustomobject]@{
        Group   = $Group
        Members = ($Members -join ', ')
    }
}
Write-ResultTable $GroupRows

Write-Host ''
Write-Host '=== Staged Admin and Service Accounts ===' -ForegroundColor Cyan
Write-ResultTable (Get-ADUser -LDAPFilter '(|(sAMAccountName=ws-leonel)(sAMAccountName=svc-backup)(sAMAccountName=svc-sync))' -Properties Enabled, DistinguishedName |
    Select-Object SamAccountName, Enabled, DistinguishedName |
    Sort-Object SamAccountName)

Write-Host ''
Write-Host '=== Recycle Bin and FSMO ===' -ForegroundColor Cyan
Write-ResultTable (Get-ADOptionalFeature 'Recycle Bin Feature' | Select-Object Name, EnabledScopes)
netdom query fsmo

Write-Host ''
Write-Host '=== Replica DC Check ===' -ForegroundColor Cyan
$Dc02Computer = Get-ADComputer -LDAPFilter '(name=WIN-DC02)' -ErrorAction SilentlyContinue
if ($Dc02Computer) {
    $Dc02Computer | Select-Object Name, DistinguishedName
} else {
    Write-Host 'WIN-DC02 computer object not found. Replica DC build is still pending.'
}
