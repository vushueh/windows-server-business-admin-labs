# Q011 Phase 4A — Exact ISO-Staging Change Window

**State:** completed 2026-07-19 — manual copy and approved path correction; final size/hash pass  
**Executor:** Leonel, interactively on `WIN-PRQD8TJG04M`  
**Expected impact:** no outage expected; temporary NAS/network transfer and
`D:` write/read load while the 10.3 GB file is copied and hashed  
**Systems touched:** Ugreen NAS share read-only; Hyper-V host `D:` write-only
for the exact destination

## Completion Result

The guarded scripted attempt was canceled before destination creation and a
fresh-session cleanup check passed. Leonel then copied the exact file manually,
corrected the accidental plural `ISOs` path under a second exact approval, and
verified the frozen singular destination at 11,059,986,432 bytes with matching
SHA-256. No VM or network state changed. See the
[Phase 4A evidence record](../evidence/q011-phase4a-iso-staging-evidence.md).

The PowerShell below remains the reviewed original change-window design. It is
retained for audit/reuse and must not be rerun now that the destination exists.

## Approval Text

Use this exact approval only when ready:

> I approve Q011 Phase 4A ISO staging only on WIN-PRQD8TJG04M: read and
> checksum only rhel-10.2-x86_64-dvd.iso from the Ugreen Proxmox-Storage share,
> create only D:\Hyper-V\ISO if needed, copy that exact file only to
> D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso, and verify its exact byte size and
> SHA-256. Credentials must be entered interactively and never retained. If
> the copy fails or the destination size/hash differs, remove only that exact
> new or partial destination file and remove the new ISO directory only if this
> window created it and it is empty. Do not overwrite an existing file, stage
> another file, create or change a VM, change Hyper-V or networking, touch the
> source, or perform Git/GitHub operations. Stop after the screenshot and
> sanitized result. No other action is approved.

## Fixed Inputs

| Item | Exact value |
|---|---|
| Source share | `\\192.168.10.150\Proxmox-Storage` |
| Source relative path | `template\iso\rhel-10.2-x86_64-dvd.iso` |
| Destination | `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso` |
| Expected bytes | `11059986432` |
| Expected SHA-256 | `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Required free-space floor | expected bytes plus 10 GiB headroom |

## Preconditions

- Run Windows PowerShell as Administrator directly on
  `WIN-PRQD8TJG04M`, not inside a guest.
- Close unrelated consoles and hide notifications before evidence capture.
- Have the NAS share credential available for interactive entry.
- Confirm no backup, high disk activity, maintenance, or other Hyper-V storage
  operation is in progress; postpone the copy if the host is busy.
- Stop if the host name, source identity, destination collision, free space, or
  expected hash differs.
- A system-state backup is not required: this window does not modify AD, DNS,
  DHCP, Hyper-V configuration, services, or the registry. Its rollback is the
  exact new file and, conditionally, its newly created empty directory.

## Exact PowerShell

Copy the complete block. Do not replace paths with wildcards.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $DriveName = 'Q011SRC'
    $ShareRoot = '\\192.168.10.150\Proxmox-Storage'
    $SourceRelative = 'template\iso\rhel-10.2-x86_64-dvd.iso'
    $DestinationDirectory = 'D:\Hyper-V\ISO'
    $Destination = Join-Path $DestinationDirectory 'rhel-10.2-x86_64-dvd.iso'
    $ExpectedBytes = [int64]11059986432
    $ExpectedHash = 'e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5'
    $Headroom = 10GB
    $DirectoryExistedBefore = $null
    $DirectoryCreatedByWindow = $false
    $CopyStartedByWindow = $false
    $Credential = $null
    $Result = $null

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }
    $DirectoryExistedBefore = Test-Path `
        -LiteralPath $DestinationDirectory -PathType Container
    if (Get-PSDrive -Name $DriveName -ErrorAction SilentlyContinue) {
        throw "Temporary drive name $DriveName is already in use."
    }
    if (Test-Path -LiteralPath $Destination -PathType Leaf) {
        throw 'Destination already exists; overwrite is forbidden.'
    }

    try {
        $Credential = Get-Credential -Message 'Enter Ugreen NAS share credentials'
        New-PSDrive -Name $DriveName -PSProvider FileSystem `
            -Root $ShareRoot -Credential $Credential -Scope Local | Out-Null

        $Source = "$DriveName`:\$SourceRelative"
        if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
            throw 'The exact source ISO is unavailable.'
        }

        $SourceFile = Get-Item -LiteralPath $Source
        if ($SourceFile.Length -ne $ExpectedBytes) {
            throw 'Source byte size does not match the frozen value.'
        }

        $SourceHash = (Get-FileHash -LiteralPath $Source `
            -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($SourceHash -ne $ExpectedHash) {
            throw 'Source SHA-256 does not match the frozen value.'
        }

        $InitialDestinationVolume = Get-Volume -DriveLetter D
        if ($InitialDestinationVolume.SizeRemaining -lt `
            ($ExpectedBytes + $Headroom)) {
            throw 'Drive D: does not meet the free-space safety floor.'
        }

        if (-not (Test-Path -LiteralPath $DestinationDirectory `
            -PathType Container)) {
            New-Item -ItemType Directory -Path $DestinationDirectory | Out-Null
            $DirectoryCreatedByWindow = $true
        }

        if (Test-Path -LiteralPath $Destination) {
            throw 'Destination collision detected immediately before copy.'
        }

        # Recheck immediately before the mutating copy because source hashing
        # may take time and host free space can change.
        $PreCopyDestinationVolume = Get-Volume -DriveLetter D
        if ($PreCopyDestinationVolume.SizeRemaining -lt `
            ($ExpectedBytes + $Headroom)) {
            throw 'Drive D: fell below the free-space floor before copy.'
        }

        $CopyStartedByWindow = $true
        Copy-Item -LiteralPath $Source -Destination $Destination

        $DestinationFile = Get-Item -LiteralPath $Destination
        $DestinationHash = (Get-FileHash -LiteralPath $Destination `
            -Algorithm SHA256).Hash.ToLowerInvariant()

        $Pass = (
            $DestinationFile.Length -eq $ExpectedBytes -and
            $DestinationHash -eq $ExpectedHash
        )

        if (-not $Pass) {
            throw 'Destination verification failed; use the exact rollback.'
        }

        $Result = [pscustomobject]@{
            ComputerName      = $env:COMPUTERNAME
            FileName          = $DestinationFile.Name
            Length            = $DestinationFile.Length
            PublishedSHA256   = $ExpectedHash
            DestinationSHA256 = $DestinationHash
            ChecksumPass      = $Pass
            DirectoryExistedBefore = $DirectoryExistedBefore
            DirectoryCreatedByWindow = $DirectoryCreatedByWindow
            VMCreated         = $false
            NetworkChanged    = $false
        }
    }
    catch {
        $FailureMessage = $_.Exception.Message

        # This same approved window rolls back only objects whose creation it
        # tracked in memory after both collision checks passed.
        if ($CopyStartedByWindow -and
            (Test-Path -LiteralPath $Destination -PathType Leaf)) {
            Remove-Item -LiteralPath $Destination -Force
        }

        if ($DirectoryCreatedByWindow -and
            (Test-Path -LiteralPath $DestinationDirectory `
                -PathType Container) -and
            -not (Get-ChildItem -LiteralPath $DestinationDirectory -Force)) {
            Remove-Item -LiteralPath $DestinationDirectory -Force
        }

        throw "Q011 staging failed; exact in-window rollback ran: $FailureMessage"
    }
    finally {
        Remove-PSDrive -Name $DriveName -ErrorAction SilentlyContinue
        $Credential = $null
        [GC]::Collect()
    }

    $Result | Add-Member -NotePropertyName TemporaryDriveAbsent `
        -NotePropertyValue (-not [bool](Get-PSDrive -Name $DriveName `
            -ErrorAction SilentlyContinue))
    $Result | Format-List
}
```

The success result records whether the destination directory existed before
the window and whether this window created it. A normal PowerShell `throw`
routes through the exact in-window rollback and then through `finally`, so the
temporary drive and credential variable are cleared. If the host loses power
or PowerShell is forcibly terminated, do not infer rollback state: stop and
request a new inspection/cleanup approval.

## Success Criteria

- The structured result shows the exact host, filename, byte size, matching
  hashes, `ChecksumPass=True`, directory-origin booleans, `VMCreated=False`,
  `NetworkChanged=False`, and `TemporaryDriveAbsent=True`.
- The temporary PSDrive is absent.
- The exact local ISO is visible in File Explorer and the required safe
  screenshot is captured.
- Stop. Do not open Hyper-V Manager to create the VM in this window.

## Evidence Capture

Follow [the screenshot plan](q011-screenshot-plan.md#phase-4a--local-iso-staging).
Retain the sanitized structured output as searchable text. Do not screenshot a
credential prompt, NAS session, mapped-drive username, or authenticated URL.
