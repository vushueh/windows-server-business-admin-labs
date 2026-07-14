[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Precheck', 'Execute')]
    [string]$Mode,

    [string]$ApprovalId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedApprovalId = 'Q003-20260714-LEONEL'
$Pdc = 'WIN-PRQD8TJG04M'
$Replica = 'WIN-DC02'
$Servers = @($Pdc, $Replica)
$ExpectedDomain = 'Chongong.local'
$ExpectedDomainDn = 'DC=Chongong,DC=local'
$QuarantineDn = 'OU=Quarantine,DC=Chongong,DC=local'
$TestName = 'Q003 Restore Test 2026-07-13'
$TestSam = 'q003-restore-0713'
$TestDescription = 'Q003 disposable disabled Recycle Bin restore proof - 2026-07-13'
$ReplicationWaitSeconds = 300

Import-Module ActiveDirectory -ErrorAction Stop

function Write-Q003Record {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Stage,

        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    Write-Output ('--- {0} ---' -f $Stage)
    $Value | Format-List | Out-String | Write-Output
}

function Get-Q003LiveUser {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [Guid]$ObjectGuid
    )

    Get-ADUser -Identity $ObjectGuid -Server $Server -Properties Enabled,
        Description, DisplayName, MemberOf, PrimaryGroupID, SID, whenCreated
}

function Get-Q003DeletedObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [Guid]$ObjectGuid
    )

    Get-ADObject -Identity $ObjectGuid -Server $Server -IncludeDeletedObjects `
        -Properties isDeleted, isRecycled, lastKnownParent, msDS-LastKnownRDN,
        sAMAccountName, whenChanged
}

function Wait-Q003LiveUser {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [Guid]$ObjectGuid
    )

    $deadline = (Get-Date).AddSeconds($ReplicationWaitSeconds)
    $lastError = $null

    do {
        try {
            return Get-Q003LiveUser -Server $Server -ObjectGuid $ObjectGuid
        }
        catch {
            $lastError = $_.Exception.Message
            Start-Sleep -Seconds 5
        }
    } while ((Get-Date) -lt $deadline)

    throw "The live object $ObjectGuid did not become readable through $Server within $ReplicationWaitSeconds seconds. Last error: $lastError"
}

function Wait-Q003DeletedObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [Guid]$ObjectGuid
    )

    $deadline = (Get-Date).AddSeconds($ReplicationWaitSeconds)
    $lastError = $null

    do {
        try {
            $deleted = Get-Q003DeletedObject -Server $Server -ObjectGuid $ObjectGuid
            if ($deleted.isDeleted -eq $true -and $deleted.isRecycled -ne $true) {
                return $deleted
            }
        }
        catch {
            $lastError = $_.Exception.Message
        }

        Start-Sleep -Seconds 5
    } while ((Get-Date) -lt $deadline)

    throw "The restorable deleted object $ObjectGuid did not become readable through $Server within $ReplicationWaitSeconds seconds. Last error: $lastError"
}

function Test-Q003ReplicationCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $output = & repadmin.exe @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $outputText = $output -join [Environment]::NewLine
    Write-Q003Record -Stage $Label -Value $outputText

    $isErrorsOnly = $Arguments -contains '/errorsonly'
    if ($isErrorsOnly -and
        $outputText -match '(?im)failed,\s*result\s+\d+') {
        throw "repadmin reported a replication error during $Label."
    }

    if ($isErrorsOnly -and
        ($outputText -notmatch '(?im)^DSA object GUID:\s*[0-9a-f-]{36}\s*$' -or
         $outputText -notmatch '(?im)^==== INBOUND NEIGHBORS')) {
        throw "repadmin returned incomplete structured output during $Label."
    }

    $acceptedEmptyErrorsOnlyStatus = $isErrorsOnly -and $exitCode -eq 234
    if ($exitCode -ne 0 -and -not $acceptedEmptyErrorsOnlyStatus) {
        throw "repadmin failed during $Label with exit code $exitCode."
    }

    if ($acceptedEmptyErrorsOnlyStatus) {
        Write-Q003Record -Stage "$Label native status" -Value ([pscustomobject]@{
            ExitCode = 234
            Win32Name = 'ERROR_MORE_DATA'
            Disposition = 'Accepted only because structured errors-only output contains no failed result.'
        })
    }

    if ($Arguments -contains '/replsummary') {
        $nonzeroSummaryRows = @($output | Where-Object {
            $_ -match '^\s*\S+\s+\S+\s+([1-9]\d*)\s*/\s*\d+\s+\d+'
        })
        if ($nonzeroSummaryRows.Count -ne 0) {
            throw "repadmin reported one or more replication failures during $Label."
        }
    }

}

function Invoke-Q003Precheck {
    $domain = Get-ADDomain -Server $Pdc
    $forest = Get-ADForest -Server $Pdc

    if ($domain.DNSRoot -ne $ExpectedDomain -or $domain.DistinguishedName -ne $ExpectedDomainDn) {
        throw "Domain guard failed. Expected $ExpectedDomain / $ExpectedDomainDn."
    }

    if ($forest.RootDomain -ne $ExpectedDomain) {
        throw "Forest guard failed. Expected root domain $ExpectedDomain."
    }

    foreach ($server in $Servers) {
        $dc = Get-ADDomainController -Identity $server -Server $Pdc
        if ($dc.IsReadOnly -eq $true) {
            throw "$server is read-only; Q003 requires a writable DC."
        }

        $feature = Get-ADOptionalFeature -Identity 'Recycle Bin Feature' -Server $server
        if ($null -eq $feature.EnabledScopes -or $feature.EnabledScopes.Count -eq 0) {
            throw "Recycle Bin has no enabled scope when queried through $server."
        }

        Write-Q003Record -Stage "Recycle Bin through $server" -Value ([pscustomobject]@{
            Server = $server
            EnabledScopeCount = $feature.EnabledScopes.Count
            EnabledScopes = ($feature.EnabledScopes -join '; ')
        })
    }

    $quarantine = Get-ADOrganizationalUnit -Identity $QuarantineDn -Server $Pdc
    Write-Q003Record -Stage 'Quarantine OU' -Value ([pscustomobject]@{
        DistinguishedName = $quarantine.DistinguishedName
        ObjectGuid = $quarantine.ObjectGuid
    })

    foreach ($server in $Servers) {
        $collision = @(Get-ADUser -Filter "SamAccountName -eq '$TestSam' -or Name -eq '$TestName'" -Server $server)
        if ($collision.Count -ne 0) {
            throw "A live name collision exists through $server. Stop without reusing or deleting it."
        }

        $deletedCollision = @(Get-ADObject -LDAPFilter "(&(isDeleted=TRUE)(|(msDS-LastKnownRDN=$TestName)(sAMAccountName=$TestSam)))" `
            -Server $server -IncludeDeletedObjects)
        if ($deletedCollision.Count -ne 0) {
            throw "A deleted name collision exists through $server. Stop without recycling or restoring it."
        }
    }

    $rootDse = Get-ADRootDSE -Server $Pdc
    $directoryServiceDn = "CN=Directory Service,CN=Windows NT,CN=Services,$($rootDse.configurationNamingContext)"
    $lifetimes = Get-ADObject -Identity $directoryServiceDn -Server $Pdc `
        -Properties msDS-DeletedObjectLifetime, tombstoneLifetime
    $effectiveDeletedObjectLifetime = $lifetimes.'msDS-DeletedObjectLifetime'
    if ($null -eq $effectiveDeletedObjectLifetime) {
        $effectiveDeletedObjectLifetime = $lifetimes.tombstoneLifetime
    }

    if ($null -eq $effectiveDeletedObjectLifetime) {
        throw 'Neither msDS-DeletedObjectLifetime nor tombstoneLifetime returned a usable recovery window.'
    }

    Write-Q003Record -Stage 'Directory object lifetimes' -Value ([pscustomobject]@{
        ConfiguredMsDSDeletedObjectLifetimeDays = $lifetimes.'msDS-DeletedObjectLifetime'
        TombstoneLifetimeDays = $lifetimes.tombstoneLifetime
        EffectiveDeletedObjectLifetimeDays = $effectiveDeletedObjectLifetime
    })

    $replicationFailureRecords = @(Get-ADReplicationFailure -Target $ExpectedDomain -Scope Forest)
    $replicationFailures = @($replicationFailureRecords |
        Where-Object { $_.FailureCount -gt 0 })
    $replicationFailureHistory = @($replicationFailureRecords |
        Where-Object { $_.FailureCount -eq 0 -and $_.LastError -ne 0 })

    if ($replicationFailures.Count -ne 0) {
        Write-Q003Record -Stage 'Active replication failures' -Value $replicationFailures
        throw 'Active Directory reports one or more current replication failures.'
    }

    if ($replicationFailureHistory.Count -ne 0) {
        Write-Q003Record -Stage 'Replication failure history with zero current failures' `
            -Value $replicationFailureHistory
    }

    $replicationPartnerProblems = @(Get-ADReplicationPartnerMetadata `
        -Target $ExpectedDomain -Scope Domain -Partition * |
        Where-Object { $_.LastReplicationResult -ne 0 })
    if ($replicationPartnerProblems.Count -ne 0) {
        Write-Q003Record -Stage 'Replication partner problems' -Value $replicationPartnerProblems
        throw 'One or more replication partners report a nonzero LastReplicationResult.'
    }

    Write-Q003Record -Stage 'Replication cmdlet summary' -Value ([pscustomobject]@{
        CurrentFailureCount = $replicationFailures.Count
        ZeroCountHistoricalFailureRecordCount = $replicationFailureHistory.Count
        NonzeroPartnerResultCount = $replicationPartnerProblems.Count
    })

    Test-Q003ReplicationCommand -Arguments @('/replsummary') -Label 'repadmin replsummary'
    foreach ($server in $Servers) {
        Test-Q003ReplicationCommand -Arguments @('/showrepl', $server, '/errorsonly') `
            -Label "repadmin showrepl $server errors-only"
    }

    Write-Q003Record -Stage 'Precheck summary' -Value ([pscustomobject]@{
        Result = 'PASS'
        Domain = $domain.DNSRoot
        Forest = $forest.RootDomain
        WritableServers = ($Servers -join ', ')
        Quarantine = $QuarantineDn
        ProposedSamAccountName = $TestSam
        LiveCollisionCount = 0
        DeletedCollisionCount = 0
    })

    Write-Output 'Q003_PRECHECK=PASS'
}

if ($Mode -eq 'Precheck') {
    Invoke-Q003Precheck
    return
}

if ($ApprovalId -ne $ExpectedApprovalId) {
    throw "Execution requires the exact approval ID $ExpectedApprovalId."
}

Invoke-Q003Precheck

$runStarted = Get-Date
Write-Output ('Q003_RUN_STARTED={0:o}' -f $runStarted)
Write-Output ('Q003_APPROVAL_ID={0}' -f $ApprovalId)

New-ADUser -Name $TestName -DisplayName $TestName -SamAccountName $TestSam `
    -Path $QuarantineDn -Enabled $false -Description $TestDescription -Server $Pdc

$created = Get-ADUser -Identity $TestSam -Server $Pdc -Properties Enabled,
    Description, DisplayName, MemberOf, PrimaryGroupID, SID, whenCreated
$objectGuid = [Guid]$created.ObjectGuid

$createdOnReplica = Wait-Q003LiveUser -Server $Replica -ObjectGuid $objectGuid

if ($created.Enabled -ne $false -or $createdOnReplica.Enabled -ne $false) {
    throw 'The test identity is enabled. Stop before deletion.'
}

if (@($created.MemberOf).Count -ne 0 -or @($createdOnReplica.MemberOf).Count -ne 0) {
    throw 'The test identity has explicit group membership. Stop before deletion.'
}

if ($created.DistinguishedName -ne $createdOnReplica.DistinguishedName -or
    $created.ObjectGuid -ne $createdOnReplica.ObjectGuid) {
    throw 'The two DCs do not agree on the created identity. Stop before deletion.'
}

$baseline = [pscustomobject]@{
    ObjectGuid = $objectGuid
    SID = $created.SID.Value
    DistinguishedName = $created.DistinguishedName
    SamAccountName = $created.SamAccountName
    DisplayName = $created.DisplayName
    Enabled = $created.Enabled
    Description = $created.Description
    PrimaryGroupID = $created.PrimaryGroupID
    ExplicitGroupMembershipCount = @($created.MemberOf).Count
    WhenCreated = $created.whenCreated
}
Write-Q003Record -Stage 'Captured baseline' -Value $baseline

$deleteStarted = Get-Date
Write-Output ('Q003_DELETE_STARTED={0:o}' -f $deleteStarted)
Remove-ADObject -Identity $objectGuid -Server $Pdc -Confirm:$false

$deletedOnPdc = Wait-Q003DeletedObject -Server $Pdc -ObjectGuid $objectGuid
$deletedOnReplica = Wait-Q003DeletedObject -Server $Replica -ObjectGuid $objectGuid

foreach ($deleted in @($deletedOnPdc, $deletedOnReplica)) {
    if ($deleted.lastKnownParent -ne $QuarantineDn) {
        throw "Deleted-object parent guard failed for $objectGuid."
    }

    if ($deleted.'msDS-LastKnownRDN' -ne $TestName) {
        throw "Deleted-object name guard failed for $objectGuid."
    }
}

Write-Q003Record -Stage 'Deleted object guard' -Value ([pscustomobject]@{
    ObjectGuid = $objectGuid
    SeenThrough = ($Servers -join ', ')
    IsDeleted = $deletedOnPdc.isDeleted
    IsRecycled = $deletedOnPdc.isRecycled
    LastKnownParent = $deletedOnPdc.lastKnownParent
    LastKnownRDN = $deletedOnPdc.'msDS-LastKnownRDN'
})

$restored = Restore-ADObject -Identity $deletedOnPdc -Server $Pdc -PassThru
if ($restored.ObjectGuid -ne $objectGuid) {
    throw 'Restore returned an unexpected GUID.'
}

$finalOnPdc = Wait-Q003LiveUser -Server $Pdc -ObjectGuid $objectGuid
$finalOnReplica = Wait-Q003LiveUser -Server $Replica -ObjectGuid $objectGuid

foreach ($final in @($finalOnPdc, $finalOnReplica)) {
    if ($final.Enabled -ne $false) {
        throw "Restored identity is enabled through $($final.DistinguishedName)."
    }

    if ($final.DistinguishedName -ne $baseline.DistinguishedName -or
        $final.SamAccountName -ne $baseline.SamAccountName -or
        $final.DisplayName -ne $baseline.DisplayName -or
        $final.Description -ne $baseline.Description -or
        $final.SID.Value -ne $baseline.SID -or
        $final.PrimaryGroupID -ne $baseline.PrimaryGroupID -or
        @($final.MemberOf).Count -ne $baseline.ExplicitGroupMembershipCount) {
        throw 'Restored identity does not match the captured safe baseline.'
    }
}

foreach ($server in $Servers) {
    Test-Q003ReplicationCommand -Arguments @('/showrepl', $server, '/errorsonly') `
        -Label "final repadmin showrepl $server errors-only"
}

$unexpectedDeletedCopy = $null
try {
    $unexpectedDeletedCopy = Get-Q003DeletedObject -Server $Pdc -ObjectGuid $objectGuid
}
catch {
    $unexpectedDeletedCopy = $null
}

if ($null -ne $unexpectedDeletedCopy -and $unexpectedDeletedCopy.isDeleted -eq $true) {
    throw 'A deleted copy of the restored GUID is still visible unexpectedly.'
}

$runFinished = Get-Date
$restoreMinutes = [math]::Round(($runFinished - $deleteStarted).TotalMinutes, 2)
if ($restoreMinutes -gt 30) {
    throw "The measured restore time of $restoreMinutes minutes exceeded the 30-minute RTO."
}

Write-Q003Record -Stage 'Final verification' -Value ([pscustomobject]@{
    Result = 'PASS'
    ObjectGuid = $objectGuid
    SID = $finalOnPdc.SID.Value
    VerifiedThrough = ($Servers -join ', ')
    Enabled = $finalOnPdc.Enabled
    DistinguishedName = $finalOnPdc.DistinguishedName
    SamAccountName = $finalOnPdc.SamAccountName
    ExplicitGroupMembershipCount = @($finalOnPdc.MemberOf).Count
    DeleteToVerifiedRestoreMinutes = $restoreMinutes
    FinalState = 'Disabled in Quarantine'
})

Write-Output ('Q003_RUN_FINISHED={0:o}' -f $runFinished)
Write-Output 'Q003_RESULT=PASS'
