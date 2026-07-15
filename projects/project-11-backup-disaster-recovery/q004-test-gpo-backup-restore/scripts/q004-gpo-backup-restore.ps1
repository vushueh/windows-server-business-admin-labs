[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Precheck', 'Execute', 'Resume', 'Verify', 'Cleanup')]
    [string]$Mode,
    [string]$ApprovalId,
    [string]$RunPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Leonel approved the exact Q004 change window on 2026-07-14.
$ExpectedApprovalId = 'Q004-20260714-LEONEL'
$ExpectedResumeApprovalId = 'Q004-20260714-LEONEL-RESUME1'
$Pdc = 'WIN-PRQD8TJG04M'
$Replica = 'WIN-DC02'
$Servers = @($Pdc, $Replica)
$Domain = 'Chongong.local'
$DomainDn = 'DC=Chongong,DC=local'
$DefaultDomainPolicyId = [Guid]'31b2f340-016d-11d2-945f-00c04fb984f9'
$DefaultDcPolicyId = [Guid]'6ac1786c-016f-11d2-945f-00c04fb984f9'
$ProtectedGpoIds = @($DefaultDomainPolicyId, $DefaultDcPolicyId)
$DcOu = 'OU=Domain Controllers,DC=Chongong,DC=local'
$QuarantineDn = 'OU=Quarantine,DC=Chongong,DC=local'
$WorkstationsDn = 'OU=Workstations,OU=ManagedComputers,DC=Chongong,DC=local'
$ModelingUser = 'q003-restore-0713'
$TestGpoName = 'Q004-GPO-Restore-Test'
$RegistryKey = 'HKCU\Software\Policies\Chongong\Q004'
$ValueName = 'RestoreMarker'
$BaselineValue = 'Q004-BASELINE'
$FaultValue = 'Q004-FAULT-INJECTED'
$BackupRoot = 'C:\GPO-Backups\Q004'
$StateFileName = 'q004-run-state.json'
$RsopReportName = 'q004-rsop-modeling.html'
$WaitSeconds = 300
$RestoreRtoMinutes = 30

Import-Module ActiveDirectory -ErrorAction Stop
Import-Module GroupPolicy -ErrorAction Stop

function Write-Q004Record {
    param([string]$Stage, [object]$Value)
    Write-Output ('--- {0} ---' -f $Stage)
    $Value | Format-List | Out-String | Write-Output
}

function Assert-Q004Approval {
    if ($ExpectedApprovalId -eq 'Q004-APPROVAL-NOT-RECORDED') {
        throw 'Q004 is locked. Insert Leonel''s exact dated approval ID only after the final change window is accepted.'
    }
    if ($ApprovalId -ne $ExpectedApprovalId) {
        throw "Execution requires exact approval ID $ExpectedApprovalId."
    }
}

function Assert-Q004ResumeApproval {
    if ($ExpectedResumeApprovalId -eq 'Q004-RESUME-APPROVAL-NOT-RECORDED') {
        throw 'Q004 resume is locked until Leonel accepts the reviewed contained-state recovery.'
    }
    if ($ApprovalId -ne $ExpectedResumeApprovalId) {
        throw "Resume requires exact approval ID $ExpectedResumeApprovalId."
    }
}

function Resolve-Q004RunPath {
    if ([string]::IsNullOrWhiteSpace($RunPath)) {
        throw 'RunPath is required for Verify and Cleanup.'
    }
    $root = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    $candidate = [IO.Path]::GetFullPath($RunPath).TrimEnd('\')
    if (-not $candidate.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "RunPath must be a child of $BackupRoot."
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        throw "RunPath does not exist: $candidate"
    }
    return $candidate
}

function Get-Q004BackupInventory {
    param([string]$ValidatedRunPath)
    $items = @()
    foreach ($directory in @(Get-ChildItem -LiteralPath $ValidatedRunPath -Directory)) {
        $parsedBackupId = [Guid]::Empty
        if (-not [Guid]::TryParse($directory.Name.Trim('{}'), [ref]$parsedBackupId)) { continue }
        $backupXmlPath = Join-Path $directory.FullName 'Backup.xml'
        if (-not (Test-Path -LiteralPath $backupXmlPath -PathType Leaf)) {
            throw "Backup directory lacks Backup.xml: $($directory.FullName)"
        }
        [xml]$backupXml = Get-Content -LiteralPath $backupXmlPath -Raw
        $manager = New-Object System.Xml.XmlNamespaceManager($backupXml.NameTable)
        $manager.AddNamespace('gpo','http://www.microsoft.com/GroupPolicy/GPOOperations')
        $core = $backupXml.SelectSingleNode('//gpo:GroupPolicyCoreSettings',$manager)
        if ($null -eq $core) { throw "Cannot parse GroupPolicyCoreSettings in $backupXmlPath" }
        $sourceId = $core.SelectSingleNode('gpo:ID',$manager).InnerText.Trim('{}')
        $displayName = $core.SelectSingleNode('gpo:DisplayName',$manager).InnerText
        $items += [pscustomobject]@{
            DisplayName = $displayName
            GpoId = ([Guid]$sourceId).ToString()
            BackupId = $parsedBackupId.ToString()
            Directory = $directory.FullName
        }
    }
    return @($items)
}

function Get-Q004DefaultState {
    $domainPolicy = Get-GPO -Guid $DefaultDomainPolicyId -Domain $Domain -Server $Pdc
    $dcPolicy = Get-GPO -Guid $DefaultDcPolicyId -Domain $Domain -Server $Pdc
    if ($domainPolicy.DisplayName -ne 'Default Domain Policy') {
        throw 'Canonical Default Domain Policy GUID/name guard failed.'
    }
    if ($dcPolicy.DisplayName -ne 'Default Domain Controllers Policy') {
        throw 'Canonical default DC policy GUID/name guard failed.'
    }
    return @(@($domainPolicy, $dcPolicy) | ForEach-Object {
        foreach ($configurationName in @('User','Computer')) {
            $configuration = $_.PSObject.Properties[$configurationName].Value
            if ($null -eq $configuration -or
                $null -eq $configuration.PSObject.Properties['DSVersion'] -or
                $null -eq $configuration.PSObject.Properties['SysvolVersion']) {
                throw "Protected GPO $($_.DisplayName) lacks the expected $configurationName version shape."
            }
        }
        [pscustomobject]@{
            DisplayName = $_.DisplayName
            Id = $_.Id.ToString()
            GpoStatus = $_.GpoStatus.ToString()
            UserDsVersion = $_.User.DSVersion.ToString()
            UserSysvolVersion = $_.User.SysvolVersion.ToString()
            ComputerDsVersion = $_.Computer.DSVersion.ToString()
            ComputerSysvolVersion = $_.Computer.SysvolVersion.ToString()
            ModificationTimeUtc = $_.ModificationTime.ToUniversalTime().ToString('o')
        }
    })
}

function Assert-Q004DefaultsUnchanged {
    param([object[]]$Baseline)
    $current = @(Get-Q004DefaultState)
    foreach ($expected in $Baseline) {
        $actual = @($current | Where-Object { $_.Id -eq $expected.Id })
        if ($actual.Count -ne 1) { throw "Cannot uniquely find protected GPO $($expected.Id)." }
        foreach ($property in @('DisplayName','GpoStatus','UserDsVersion','UserSysvolVersion',
            'ComputerDsVersion','ComputerSysvolVersion','ModificationTimeUtc')) {
            if ($actual[0].$property -ne $expected.$property) {
                throw "Protected GPO $($expected.DisplayName) changed $property."
            }
        }
    }
}

function Test-Q004Repadmin {
    param([string[]]$Arguments, [string]$Label)
    $output = & repadmin.exe @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $text = $output -join [Environment]::NewLine
    Write-Q004Record $Label $text

    if ($text -match '(?im)Experienced the following operational errors') {
        throw "repadmin reported an operational error during $Label."
    }
    if ($Arguments -contains '/replsummary') {
        $badRows = @($output | Where-Object {
            $_ -match '^\s*\S+\s+\S+\s+([1-9]\d*)\s*/\s*\d+\s+\d+'
        })
        if ($badRows.Count -ne 0) { throw "Replication failures appeared during $Label." }
    }
    $errorsOnly = $Arguments -contains '/errorsonly'
    if ($errorsOnly -and $text -match '(?im)failed,\s*result\s+\d+') {
        throw "Replication error appeared during $Label."
    }
    if ($errorsOnly -and
        ($text -notmatch '(?im)^DSA object GUID:\s*[0-9a-f-]{36}\s*$' -or
         $text -notmatch '(?im)^==== INBOUND NEIGHBORS')) {
        throw "Incomplete structured repadmin output during $Label."
    }
    $accepted234 = $errorsOnly -and $exitCode -eq 234
    if ($exitCode -ne 0 -and -not $accepted234) {
        throw "repadmin exited $exitCode during $Label."
    }
    if ($accepted234) {
        Write-Q004Record "$Label native status" ([pscustomobject]@{
            ExitCode = 234
            Disposition = 'Accepted only with complete headers and no failed result.'
        })
    }
}

function Invoke-Q004ReplicationChecks {
    $failures = @(Get-ADReplicationFailure -Target $Domain -Scope Forest |
        Where-Object { $_.FailureCount -gt 0 })
    $partners = @(Get-ADReplicationPartnerMetadata -Target $Domain -Scope Domain -Partition * |
        Where-Object { $_.LastReplicationResult -ne 0 })
    if ($failures.Count -ne 0 -or $partners.Count -ne 0) {
        Write-Q004Record 'Replication cmdlet failures' @($failures + $partners)
        throw 'AD replication cmdlets reported a current problem.'
    }
    Write-Q004Record 'Replication cmdlet summary' ([pscustomobject]@{
        CurrentFailureCount = $failures.Count
        NonzeroPartnerResultCount = $partners.Count
    })
    Test-Q004Repadmin @('/replsummary') 'repadmin replsummary'
    foreach ($server in $Servers) {
        Test-Q004Repadmin @('/showrepl',$server,'/errorsonly') "repadmin showrepl $server errors-only"
    }
}

function Get-Q004Links {
    param([string]$Target)
    return @((Get-GPInheritance -Target $Target -Domain $Domain -Server $Pdc).GpoLinks)
}

function Assert-Q004CanonicalLinks {
    $domainLinks = @(Get-Q004Links $DomainDn)
    $dcLinks = @(Get-Q004Links $DcOu)
    if ($domainLinks.Count -ne 1 -or $domainLinks[0].GpoId -ne $DefaultDomainPolicyId) {
        throw 'Domain-root direct link guard failed.'
    }
    if ($dcLinks.Count -ne 1 -or $dcLinks[0].GpoId -ne $DefaultDcPolicyId) {
        throw 'Domain Controllers direct link guard failed.'
    }
}

function Assert-Q004SafeQuarantine {
    Get-ADOrganizationalUnit -Identity $QuarantineDn -Server $Pdc | Out-Null
    $users = @(Get-ADUser -SearchBase $QuarantineDn -SearchScope Subtree -Filter * `
        -Properties Enabled -Server $Pdc)
    $enabled = @($users | Where-Object { $_.Enabled -eq $true })
    if ($enabled.Count -ne 0) { throw 'A user in the Quarantine subtree is enabled.' }
    $user = Get-ADUser -Identity $ModelingUser -Properties Enabled,MemberOf -Server $Pdc
    if ($user.Enabled -ne $false -or $user.DistinguishedName -notlike "*,$QuarantineDn" -or
        @($user.MemberOf).Count -ne 0) {
        throw 'The retained Q003 modeling identity no longer matches its safe baseline.'
    }
    return [pscustomobject]@{ SubtreeUsers=$users.Count; EnabledSubtreeUsers=$enabled.Count }
}

function Invoke-Q004Precheck {
    if ($env:COMPUTERNAME -ne $Pdc) {
        throw "Host guard failed: expected $Pdc, found $($env:COMPUTERNAME)."
    }
    $adDomain = Get-ADDomain -Server $Pdc
    $forest = Get-ADForest -Server $Pdc
    if ($adDomain.DNSRoot -ne $Domain -or $adDomain.DistinguishedName -ne $DomainDn -or
        $adDomain.PDCEmulator.Split('.')[0] -ne $Pdc -or $forest.RootDomain -ne $Domain) {
        throw 'Domain, forest, or PDC guard failed.'
    }
    foreach ($server in $Servers) {
        if ((Get-ADDomainController -Identity $server -Server $Pdc).IsReadOnly) {
            throw "$server is read-only."
        }
    }
    foreach ($name in @('Backup-GPO','Restore-GPO','New-GPO',
        'Set-GPRegistryValue','Get-GPRegistryValue','New-GPLink','Remove-GPLink',
        'Remove-GPO','Get-GPOReport','Get-GPInheritance')) {
        if ($null -eq (Get-Command $name -ErrorAction SilentlyContinue)) {
            throw "Missing GroupPolicy cmdlet: $name"
        }
    }
    $shares = @(Get-SmbShare -Name SYSVOL,NETLOGON)
    if ($shares.Count -ne 2 -or @($shares | Where-Object { $_.ShareState -ne 'Online' }).Count) {
        throw 'SYSVOL or NETLOGON is missing/not online.'
    }
    if (-not (Test-Path 'C:\GPO-Backups' -PathType Container)) {
        throw 'C:\GPO-Backups must already exist.'
    }
    $free = (Get-PSDrive C).Free
    if ($free -lt 1GB) { throw 'Less than 1 GB free on C:.' }

    $gpos = @(Get-GPO -All -Domain $Domain -Server $Pdc)
    if ($gpos.Count -ne 2 -or @($gpos | Where-Object { $ProtectedGpoIds -notcontains $_.Id }).Count) {
        throw 'Expected exactly the two canonical pre-Q004 GPOs.'
    }
    $defaults = @(Get-Q004DefaultState)
    if (@($gpos | Where-Object { $_.DisplayName -eq $TestGpoName }).Count) {
        throw "$TestGpoName already exists."
    }
    Assert-Q004CanonicalLinks
    if (@(Get-Q004Links $QuarantineDn).Count) { throw 'Quarantine already has a direct GPO link.' }
    $quarantine = Assert-Q004SafeQuarantine
    Get-ADOrganizationalUnit -Identity $WorkstationsDn -Server $Pdc | Out-Null
    Invoke-Q004ReplicationChecks

    Write-Q004Record 'Precheck summary' ([pscustomobject]@{
        Result='PASS'; Host=$env:COMPUTERNAME; Domain=$adDomain.DNSRoot
        Pdc=$adDomain.PDCEmulator; WritableServers=($Servers -join ', ')
        CurrentGpoCount=$gpos.Count; ProtectedIds=(($defaults.Id) -join ', ')
        QuarantineDirectLinks=0; QuarantineSubtreeUsers=$quarantine.SubtreeUsers
        QuarantineEnabledSubtreeUsers=$quarantine.EnabledSubtreeUsers
        ModelingUser=$ModelingUser; WorkstationModelingContainer=$WorkstationsDn
        BackupRootExists=$true; CDriveFreeGb=[math]::Round($free/1GB,2)
        TestGpoCollisionCount=0
    })
    Write-Output 'Q004_PRECHECK=PASS'
}

function Get-Q004TestGpo {
    $matches = @(Get-GPO -All -Domain $Domain -Server $Pdc |
        Where-Object { $_.DisplayName -eq $TestGpoName })
    if ($matches.Count -ne 1) { throw "Expected one $TestGpoName; found $($matches.Count)." }
    if ($ProtectedGpoIds -contains $matches[0].Id) { throw 'Test GUID is protected.' }
    return $matches[0]
}

function Get-Q004Marker {
    param([Guid]$GpoId, [string]$Server=$Pdc)
    return Get-GPRegistryValue -Guid $GpoId -Key $RegistryKey -ValueName $ValueName `
        -Domain $Domain -Server $Server
}

function Assert-Q004Link {
    param([Guid]$GpoId)
    $links = @(Get-Q004Links $QuarantineDn)
    $test = @($links | Where-Object { $_.GpoId -eq $GpoId })
    if ($links.Count -ne 1 -or $test.Count -ne 1 -or
        $test[0].Enabled.ToString() -ne 'True' -or $test[0].Enforced.ToString() -ne 'False') {
        throw 'Q004 Quarantine link guard failed.'
    }
}

function Wait-Q004Marker {
    param([Guid]$GpoId, [string]$Server, [string]$Expected)
    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    do {
        try {
            $marker = Get-Q004Marker $GpoId $Server
            if ($marker.Value -eq $Expected) { return $marker }
        } catch { }
        Start-Sleep 5
    } while ((Get-Date) -lt $deadline)
    throw "$Expected marker did not become readable through $Server within $WaitSeconds seconds."
}

function Read-Q004State {
    param([string]$ValidatedRunPath)
    $path = Join-Path $ValidatedRunPath $StateFileName
    if (-not (Test-Path $path -PathType Leaf)) { throw "Missing run state: $path" }
    $state = Get-Content $path -Raw | ConvertFrom-Json
    if ($state.TestGpoName -ne $TestGpoName -or $state.QuarantineDn -ne $QuarantineDn -or
        $state.RunPath -ne $ValidatedRunPath) { throw 'Run-state scope guard failed.' }
    if ($ProtectedGpoIds -contains [Guid]$state.TestGpoId) { throw 'Run-state GUID is protected.' }
    return $state
}

function Invoke-Q004Execute {
    Assert-Q004Approval
    Invoke-Q004Precheck
    $defaultBaseline = @(Get-Q004DefaultState)
    $activeRunPath = Join-Path $BackupRoot ((Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))
    $reports = Join-Path $activeRunPath 'reports'
    New-Item -ItemType Directory -Path $reports -Force | Out-Null

    $allBackups = @(Backup-GPO -All -Path $activeRunPath -Domain $Domain -Server $Pdc `
        -Comment 'Q004 pre-change backup of all current GPOs')
    if (@($allBackups | Where-Object { $ProtectedGpoIds -contains $_.GpoId }).Count -ne 2) {
        throw 'All-GPO backup did not return both protected GPOs.'
    }
    Write-Q004Record 'Pre-change backups' ($allBackups | Select-Object DisplayName,GpoId,
        @{Name='BackupId';Expression={$_.Id}},CreationTime)

    $testGpo = New-GPO -Name $TestGpoName -Comment 'Q004 disposable restore proof' `
        -Domain $Domain -Server $Pdc
    if ($ProtectedGpoIds -contains $testGpo.Id) { throw 'New-GPO returned a protected GUID.' }
    Set-GPRegistryValue -Guid $testGpo.Id -Key $RegistryKey -ValueName $ValueName `
        -Type String -Value $BaselineValue -Domain $Domain -Server $Pdc | Out-Null

    $linked = $false
    $faulted = $false
    try {
        New-GPLink -Guid $testGpo.Id -Target $QuarantineDn -LinkEnabled Yes -Enforced No `
            -Domain $Domain -Server $Pdc | Out-Null
        $linked = $true
        Assert-Q004Link $testGpo.Id
        Assert-Q004SafeQuarantine | Out-Null
        Wait-Q004Marker $testGpo.Id $Replica $BaselineValue | Out-Null

        Get-GPOReport -Guid $testGpo.Id -ReportType Xml -Path (Join-Path $reports 'q004-baseline.xml') `
            -Domain $Domain -Server $Pdc
        $testBackup = Backup-GPO -Guid $testGpo.Id -Path $activeRunPath -Domain $Domain `
            -Server $Pdc -Comment 'Q004 known-good custom GPO baseline'
        if ($testBackup.GpoId -ne $testGpo.Id -or $null -eq $testBackup.Id) {
            throw 'Known-good test backup identity is incomplete.'
        }

        [pscustomobject]@{
            Q004='SIM-B3-GPO-RESTORE'; RunPath=$activeRunPath
            TestGpoName=$TestGpoName; TestGpoId=$testGpo.Id.ToString()
            BackupId=$testBackup.Id.ToString(); QuarantineDn=$QuarantineDn
            AllBackups=@($allBackups | Select-Object DisplayName,GpoId,
                @{Name='BackupId';Expression={$_.Id}},CreationTime)
            DefaultPolicies=$defaultBaseline; CreatedUtc=(Get-Date).ToUniversalTime().ToString('o')
        } | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $activeRunPath $StateFileName) -Encoding UTF8

        $faultStarted = Get-Date
        Set-GPRegistryValue -Guid $testGpo.Id -Key $RegistryKey -ValueName $ValueName `
            -Type String -Value $FaultValue -Domain $Domain -Server $Pdc | Out-Null
        $faulted = $true
        if ((Get-Q004Marker $testGpo.Id).Value -ne $FaultValue) { throw 'Fault marker mismatch.' }
        Get-GPOReport -Guid $testGpo.Id -ReportType Xml -Path (Join-Path $reports 'q004-fault.xml') `
            -Domain $Domain -Server $Pdc

        Restore-GPO -BackupId $testBackup.Id -Path $activeRunPath -Domain $Domain `
            -Server $Pdc -Confirm:$false | Out-Null
        $restored = Get-Q004TestGpo
        if ($restored.Id -ne $testGpo.Id) { throw 'Restored GPO GUID changed.' }
        foreach ($server in $Servers) { Wait-Q004Marker $testGpo.Id $server $BaselineValue | Out-Null }
        Assert-Q004Link $testGpo.Id
        Assert-Q004SafeQuarantine | Out-Null
        Assert-Q004CanonicalLinks
        Assert-Q004DefaultsUnchanged $defaultBaseline
        Invoke-Q004ReplicationChecks
        Get-GPOReport -Guid $testGpo.Id -ReportType Xml -Path (Join-Path $reports 'q004-restored.xml') `
            -Domain $Domain -Server $Pdc
        $minutes = [math]::Round(((Get-Date)-$faultStarted).TotalMinutes,2)
        if ($minutes -gt $RestoreRtoMinutes) { throw "Restore exceeded $RestoreRtoMinutes minutes." }

        Write-Q004Record 'Restored GPO verification' ([pscustomobject]@{
            Result='PASS'; TestGpoName=$restored.DisplayName; TestGpoId=$restored.Id
            BackupId=$testBackup.Id; RestoredMarker=$BaselineValue
            LinkTarget=$QuarantineDn; RestoreMinutes=$minutes; RunPath=$activeRunPath
            NextGate=(Join-Path $activeRunPath $RsopReportName)
        })
        Write-Output 'Q004_RESTORE=PASS'
        Write-Output 'Q004_AWAITING_RSOP=YES'
    } catch {
        $originalError = $_
        if ($linked) {
            try {
                Remove-GPLink -Guid $testGpo.Id -Target $QuarantineDn -Domain $Domain `
                    -Server $Pdc -Confirm:$false
                Write-Output 'Q004_CONTAINMENT_LINK_REMOVAL=PASS'
            } catch {
                Write-Output ('Q004_CONTAINMENT_LINK_REMOVAL=FAILED: {0}' -f $_.Exception.Message)
            }
        }
        if ($faulted) { Write-Output 'Q004_FAULT_WAS_INJECTED=YES' }
        throw $originalError
    }
}

function Invoke-Q004Resume {
    Assert-Q004ResumeApproval
    $path = Resolve-Q004RunPath
    if ($env:COMPUTERNAME -ne $Pdc) { throw "Resume host guard failed: $($env:COMPUTERNAME)." }
    $inventory = @(Get-Q004BackupInventory $path)
    if ($inventory.Count -ne 3) { throw "Expected exactly three backup manifests; found $($inventory.Count)." }
    foreach ($protectedId in $ProtectedGpoIds) {
        if (@($inventory | Where-Object { [Guid]$_.GpoId -eq $protectedId }).Count -ne 1) {
            throw "Missing or duplicate protected backup manifest for $protectedId."
        }
    }
    $testGpo = Get-Q004TestGpo
    $testBackup = @($inventory | Where-Object { [Guid]$_.GpoId -eq $testGpo.Id })
    if ($testBackup.Count -ne 1 -or $testBackup[0].DisplayName -ne $TestGpoName) {
        throw 'Cannot uniquely map the contained test GPO to its backup manifest.'
    }
    $backupReport = Join-Path $testBackup[0].Directory 'gpreport.xml'
    if (-not (Test-Path -LiteralPath $backupReport -PathType Leaf)) { throw 'Test backup lacks gpreport.xml.' }
    $backupText = Get-Content -LiteralPath $backupReport -Raw
    foreach ($required in @($TestGpoName,$ValueName,$BaselineValue)) {
        if ($backupText -notmatch [regex]::Escape($required)) {
            throw "Known-good test backup report lacks $required."
        }
    }
    if (@(Get-GPO -All -Domain $Domain -Server $Pdc).Count -ne 3) {
        throw 'Resume requires exactly the two defaults plus the one contained test GPO.'
    }
    if (@(Get-Q004Links $QuarantineDn).Count) { throw 'Resume requires the test scope to be unlinked.' }
    Assert-Q004CanonicalLinks
    Assert-Q004SafeQuarantine | Out-Null
    if ((Get-Q004Marker $testGpo.Id).Value -ne $BaselineValue) {
        throw 'Contained test GPO is not at the known-good baseline.'
    }
    foreach ($server in $Servers) { Wait-Q004Marker $testGpo.Id $server $BaselineValue | Out-Null }
    $statePath = Join-Path $path $StateFileName
    if (Test-Path -LiteralPath $statePath) { throw "Unexpected existing run state: $statePath" }
    foreach ($unexpected in @('q004-fault.xml','q004-restored.xml')) {
        if (Test-Path -LiteralPath (Join-Path (Join-Path $path 'reports') $unexpected)) {
            throw "Unexpected prior-stage report exists: $unexpected"
        }
    }
    Invoke-Q004ReplicationChecks
    $defaultBaseline = @(Get-Q004DefaultState)
    [pscustomobject]@{
        Q004='SIM-B3-GPO-RESTORE'; RunPath=$path
        TestGpoName=$TestGpoName; TestGpoId=$testGpo.Id.ToString()
        BackupId=$testBackup[0].BackupId; QuarantineDn=$QuarantineDn
        AllBackups=$inventory; DefaultPolicies=$defaultBaseline
        RecoveryFrom='Contained pre-fault BackupId-property failure'
        CreatedUtc=(Get-Date).ToUniversalTime().ToString('o')
    } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statePath -Encoding UTF8

    $linked = $false
    $faulted = $false
    try {
        New-GPLink -Guid $testGpo.Id -Target $QuarantineDn -LinkEnabled Yes -Enforced No `
            -Domain $Domain -Server $Pdc | Out-Null
        $linked = $true
        Assert-Q004Link $testGpo.Id
        Assert-Q004SafeQuarantine | Out-Null

        $faultStarted = Get-Date
        Set-GPRegistryValue -Guid $testGpo.Id -Key $RegistryKey -ValueName $ValueName `
            -Type String -Value $FaultValue -Domain $Domain -Server $Pdc | Out-Null
        $faulted = $true
        if ((Get-Q004Marker $testGpo.Id).Value -ne $FaultValue) { throw 'Resume fault marker mismatch.' }
        Get-GPOReport -Guid $testGpo.Id -ReportType Xml `
            -Path (Join-Path (Join-Path $path 'reports') 'q004-fault.xml') `
            -Domain $Domain -Server $Pdc

        Restore-GPO -BackupId ([Guid]$testBackup[0].BackupId) -Path $path -Domain $Domain `
            -Server $Pdc -Confirm:$false | Out-Null
        $restored = Get-Q004TestGpo
        if ($restored.Id -ne $testGpo.Id) { throw 'Resume restored GPO GUID changed.' }
        foreach ($server in $Servers) { Wait-Q004Marker $testGpo.Id $server $BaselineValue | Out-Null }
        Assert-Q004Link $testGpo.Id
        Assert-Q004SafeQuarantine | Out-Null
        Assert-Q004CanonicalLinks
        Assert-Q004DefaultsUnchanged $defaultBaseline
        Invoke-Q004ReplicationChecks
        Get-GPOReport -Guid $testGpo.Id -ReportType Xml `
            -Path (Join-Path (Join-Path $path 'reports') 'q004-restored.xml') `
            -Domain $Domain -Server $Pdc
        $minutes = [math]::Round(((Get-Date)-$faultStarted).TotalMinutes,2)
        if ($minutes -gt $RestoreRtoMinutes) { throw "Resume exceeded $RestoreRtoMinutes minutes." }
        Write-Q004Record 'Resumed restored GPO verification' ([pscustomobject]@{
            Result='PASS'; TestGpoName=$restored.DisplayName; TestGpoId=$restored.Id
            BackupId=$testBackup[0].BackupId; RestoredMarker=$BaselineValue
            LinkTarget=$QuarantineDn; RestoreMinutes=$minutes; RunPath=$path
            NextGate=(Join-Path $path $RsopReportName)
        })
        Write-Output 'Q004_RESUME_RESTORE=PASS'
        Write-Output 'Q004_AWAITING_RSOP=YES'
    } catch {
        $originalError = $_
        if ($linked) {
            try {
                Remove-GPLink -Guid $testGpo.Id -Target $QuarantineDn -Domain $Domain `
                    -Server $Pdc -Confirm:$false
                Write-Output 'Q004_RESUME_CONTAINMENT_LINK_REMOVAL=PASS'
            } catch {
                Write-Output ('Q004_RESUME_CONTAINMENT_LINK_REMOVAL=FAILED: {0}' -f $_.Exception.Message)
            }
        }
        if ($faulted) { Write-Output 'Q004_RESUME_FAULT_WAS_INJECTED=YES' }
        throw $originalError
    }
}

function Invoke-Q004Verify {
    $path = Resolve-Q004RunPath
    $state = Read-Q004State $path
    $id = [Guid]$state.TestGpoId
    if ((Get-Q004TestGpo).Id -ne $id) { throw 'Live test GPO/run-state GUID mismatch.' }
    if ((Get-Q004Marker $id).Value -ne $BaselineValue) { throw 'Live marker is not baseline.' }
    Assert-Q004Link $id
    Assert-Q004SafeQuarantine | Out-Null
    Assert-Q004CanonicalLinks
    Assert-Q004DefaultsUnchanged @($state.DefaultPolicies)
    $rsop = Join-Path $path $RsopReportName
    if (-not (Test-Path $rsop -PathType Leaf)) {
        $htmRsop = [System.IO.Path]::ChangeExtension($rsop, '.htm')
        if (Test-Path $htmRsop -PathType Leaf) {
            $rsop = $htmRsop
        } else {
            throw "Missing RSoP report: $rsop or $htmRsop"
        }
    }
    $text = Get-Content $rsop -Raw
    foreach ($required in @($TestGpoName,$ValueName,$BaselineValue)) {
        if ($text -notmatch [regex]::Escape($required)) { throw "RSoP report lacks $required." }
    }
    Write-Q004Record 'RSoP verification' ([pscustomobject]@{
        Result='PASS'; TestGpoId=$id; RestoredMarker=$BaselineValue; RsopReport=$rsop
    })
    Write-Output 'Q004_VERIFY=PASS'
}

function Invoke-Q004Cleanup {
    Assert-Q004Approval
    $path = Resolve-Q004RunPath
    $state = Read-Q004State $path
    $id = [Guid]$state.TestGpoId
    Invoke-Q004Verify
    if ((Get-Q004TestGpo).Id -ne $id) { throw 'Cleanup GUID guard failed.' }
    Remove-GPLink -Guid $id -Target $QuarantineDn -Domain $Domain -Server $Pdc -Confirm:$false
    if (@(Get-Q004Links $QuarantineDn).Count) { throw 'Quarantine link remains; stop before Remove-GPO.' }
    Remove-GPO -Guid $id -Domain $Domain -Server $Pdc -Confirm:$false
    if (@(Get-GPO -All -Domain $Domain -Server $Pdc |
        Where-Object { $_.Id -eq $id -or $_.DisplayName -eq $TestGpoName }).Count) {
        throw 'Disposable GPO remains after cleanup.'
    }
    Assert-Q004DefaultsUnchanged @($state.DefaultPolicies)
    Assert-Q004SafeQuarantine | Out-Null
    Assert-Q004CanonicalLinks
    Invoke-Q004ReplicationChecks
    Write-Q004Record 'Cleanup verification' ([pscustomobject]@{
        Result='PASS'; RemovedTestGpoId=$id; RemovedLinkTarget=$QuarantineDn
        QuarantineDirectLinks=@(Get-Q004Links $QuarantineDn).Count
        RetainedBackupPath=$path; ProtectedDefaultPolicies=@(Get-Q004DefaultState).Count
    })
    Write-Output 'Q004_CLEANUP=PASS'
}

switch ($Mode) {
    Precheck { Invoke-Q004Precheck }
    Execute  { Invoke-Q004Execute }
    Resume   { Invoke-Q004Resume }
    Verify   { Invoke-Q004Verify }
    Cleanup  { Invoke-Q004Cleanup }
}
