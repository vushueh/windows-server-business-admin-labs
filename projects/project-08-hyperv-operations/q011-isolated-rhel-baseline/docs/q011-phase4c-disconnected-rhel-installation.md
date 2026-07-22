# Q011 Phase 4C — Disconnected RHEL 10.2 Installation Run Sheet

**Prepared:** 2026-07-19  
**Mode:** completed `HANDS-ON` change window  
**Target host:** `WIN-PRQD8TJG04M`  
**Target VM:** `Q011-RHEL102-BASELINE`  
**Operator:** Leonel at the Hyper-V console  
**Current state:** Phase 4C passed; RHEL 10.2 is installed and the VM is Off,
disconnected, DVD-empty, and checkpoint-free  
**Final result:** `Phase4CEndStatePass=True`

This run sheet records the completed window and remains the supported
re-verification path. It covered one first boot, one disconnected local-media
installation, exact media ejection before the installer reboot, local-console
verification, and normal shutdown. It did not authorize network attachment,
registration, patching, package changes, baseline hardening, checkpoint
creation, VM deletion, or another guest.

The companion
[failure-containment plan](q011-phase4c-failure-containment.md) is part of this
run sheet and must be open before execution.

## Completion Result

Leonel completed the approved window on 2026-07-19. The fresh preflight,
installation, full ISO re-verification, guest assertions, normal shutdown, and
final host proof passed. Two execution details required evidence-backed
handling: Hyper-V exposed the successful DVD detach after the first immediate
query, and VMConnect could not safely type the long Bash block. The
[execution evidence](../evidence/q011-phase4c-evidence.md) records the exact
stops, the manual read-only fallback, and the final claim boundary.

## Frozen Installation Choices

| Item | Exact value |
|---|---|
| VM | `Q011-RHEL102-BASELINE` only |
| Installation media | `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso` |
| Media identity | 11,059,986,432 bytes; SHA-256 `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Guest hostname | `q011-rhel01` |
| Language and keyboard | English (United States) |
| Time zone | `America/Denver`; leave network time unavailable while offline |
| Installation source | Auto-detected local RHEL 10.2 DVD only |
| Software | `Minimal Install`; no add-ons |
| Storage | Select only the 60 GiB Microsoft virtual disk; Automatic partitioning; LVM expected; no encryption |
| Root account | Disabled/locked; no root password entered |
| Local account | `leonel`; password required; administrative privileges enabled |
| Registration | None; do not open or complete **Connect to Red Hat** |
| Network | Installer interface Off; Hyper-V adapter remains Not connected |
| Checkpoints | None; automatic checkpoints remain disabled |
| End state | DVD empty and VM Off after local-console verification |

The local password is entered only in the installer and at the console. It is
never pasted into chat, PowerShell, a screenshot, a transcript, or a repository
file.

## Retained Future Approval Text

The following is the exact approval pattern for the later hands-on window. It
is not active approval merely because it appears here.

> I approve Q011 Phase 4C only on WIN-PRQD8TJG04M: run the documented fresh
> read-only preflight and stop unless `Phase4CPreflightPass=True`; then use
> VMConnect to start only Q011-RHEL102-BASELINE and install RHEL 10.2 from the
> already attached verified local DVD using Minimal Install, automatic
> partitioning with LVM, hostname q011-rhel01, one password-protected local
> leonel administrator, root disabled/locked, no registration, and networking
> off while the Hyper-V adapter remains Not connected. After installation
> completes, detach only that VM's exact ISO using the documented
> WhatIf/change/verification block before selecting Reboot System. Verify the
> installed release, hostname, root lock, wheel membership, SELinux, LVM,
> unregistered state, system health, and absence of addressing, routes, and
> active non-loopback connections; capture the planned safe screenshots; then
> shut the guest down normally and require `Phase4CEndStatePass=True`. If a
> stop condition occurs before Begin Installation, return only this VM to Off.
> After disk writes begin, preserve the VM and VHDX for separate diagnosis; do
> not delete, reset, reinstall, or repair them. Do not attach a switch, expose
> credentials, change another VM/VHDX/ISO/host setting, install updates or
> packages, create a checkpoint, commit, push, merge, or change GitHub. No
> other action is approved.

## Stop Conditions

Stop before first power-on if any preflight field fails. After starting, stop
without broadening the window when any of these occurs:

- the console title is not the exact Q011 VM;
- Secure Boot, CPU compatibility, disk detection, or local-media boot fails;
- any interface shows a link, address, or unexpected connectivity;
- the installer does not identify the source as the local RHEL 10.2 DVD;
- more than one installation disk appears, or the selected disk is not 60 GiB;
- `Minimal Install`, root disabled, the `leonel` administrator, or automatic
  storage cannot be configured exactly;
- registration, repository, subscription, activation-key, or credential
  prompts appear outside the local-user creation screen;
- an unexpected destructive storage summary names anything other than the
  single new Q011 virtual disk;
- the installer reports an error or stops progressing after disk writes begin;
- the ISO cannot be proven detached before the installer reboot;
- the installed system returns to the installer, fails to boot, rejects the
  local account, or fails any final assertion; or
- another Hyper-V, backup, storage, or maintenance operation begins.

Follow the exact stage-specific response in the
[failure-containment plan](q011-phase4c-failure-containment.md). Never interpret
a stop as permission to attach networking, change Secure Boot, reset a
password, delete the VHDX, or reinstall.

## Step 1 — Fresh Off-State Preflight

Run the complete block in elevated Windows PowerShell directly on
`WIN-PRQD8TJG04M`. It reads only the Q011 VM, its attached VHDX/DVD, the exact
ISO, and host capacity/transition summaries. It does not start or change the
VM.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdPath = 'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'
    $IsoPath = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'
    $ExpectedIsoBytes = [int64]11059986432
    $ExpectedIsoHash = `
        'e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5'
    $MemoryFloor = [int64]16GB
    $DriveFloor = [int64]100GB

    $IsAdmin = (
        [Security.Principal.WindowsPrincipal]::new(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )
    ).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }
    if (-not $IsAdmin) {
        throw 'Run this preflight in elevated Windows PowerShell.'
    }

    $Vmms = Get-Service -Name vmms
    $Vm = Get-VM -Name $VmName
    $Processor = Get-VMProcessor -VMName $VmName
    $Memory = Get-VMMemory -VMName $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Firmware = Get-VMFirmware -VMName $VmName
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $Vhd = Get-VHD -Path $VhdPath

    if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
        throw 'The exact local Q011 ISO is absent.'
    }

    $IsoBefore = Get-Item -LiteralPath $IsoPath
    $IsoStreams = @(Get-Item -LiteralPath $IsoPath -Stream *)
    $ZoneIdentifierPresent = `
        $IsoStreams.Stream -contains 'Zone.Identifier'
    $ComputedIsoHash = (
        Get-FileHash -LiteralPath $IsoPath -Algorithm SHA256
    ).Hash.ToLowerInvariant()
    $IsoAfter = Get-Item -LiteralPath $IsoPath
    $IsoStable = (
        $IsoBefore.Length -eq $IsoAfter.Length -and
        $IsoBefore.LastWriteTimeUtc -eq $IsoAfter.LastWriteTimeUtc
    )

    $BootOrder = @($Firmware.BootOrder)
    $FirstBootDevice = if ($BootOrder.Count -ge 1) {
        $BootOrder[0].Device
    }
    $SecondBootDevice = if ($BootOrder.Count -ge 2) {
        $BootOrder[1].Device
    }
    $DvdFirst = (
        $DvdDrives.Count -eq 1 -and
        $null -ne $FirstBootDevice -and
        $FirstBootDevice.ControllerType -eq `
            $DvdDrives[0].ControllerType -and
        $FirstBootDevice.ControllerNumber -eq `
            $DvdDrives[0].ControllerNumber -and
        $FirstBootDevice.ControllerLocation -eq `
            $DvdDrives[0].ControllerLocation
    )
    $DiskSecond = (
        $HardDisks.Count -eq 1 -and
        $null -ne $SecondBootDevice -and
        $SecondBootDevice.ControllerType -eq `
            $HardDisks[0].ControllerType -and
        $SecondBootDevice.ControllerNumber -eq `
            $HardDisks[0].ControllerNumber -and
        $SecondBootDevice.ControllerLocation -eq `
            $HardDisks[0].ControllerLocation
    )

    $CpuSamples = @(1..3 | ForEach-Object {
        $Sample = (
            Get-CimInstance Win32_Processor |
                Measure-Object -Property LoadPercentage -Average
        ).Average
        if ($null -eq $Sample) {
            throw 'CPU load could not be measured.'
        }
        [double]$Sample
        if ($_ -lt 3) {
            Start-Sleep -Seconds 5
        }
    })
    $AverageCpuLoad = [math]::Round(
        ($CpuSamples | Measure-Object -Average).Average, 1
    )
    $PeakCpuLoad = [math]::Round(
        ($CpuSamples | Measure-Object -Maximum).Maximum, 1
    )

    $TransitionStates = @(
        'Starting','Stopping','Saving','Pausing','Resuming','Restoring'
    )
    $TransitioningVmCount = @(
        Get-VM | Where-Object {
            $_.State.ToString() -in $TransitionStates
        }
    ).Count

    $NoCompetingWorkConfirmed = (
        Read-Host (
            'After checking the host, type NO-COMPETING-WORK only if no ' +
            'backup, maintenance, storage task, or other Hyper-V/Q011 ' +
            'operation is active'
        )
    ) -ceq 'NO-COMPETING-WORK'

    # Re-read all gates after hashing, sampling, and confirmation.
    $Vm = Get-VM -Name $VmName
    $Processor = Get-VMProcessor -VMName $VmName
    $Memory = Get-VMMemory -VMName $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Firmware = Get-VMFirmware -VMName $VmName
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $Vhd = Get-VHD -Path $VhdPath
    $Vmms = Get-Service -Name vmms
    $OperatingSystem = Get-CimInstance Win32_OperatingSystem
    $FreeMemoryBytes = [int64]$OperatingSystem.FreePhysicalMemory * 1KB
    $DVolume = Get-Volume -DriveLetter D
    $IsoFinal = Get-Item -LiteralPath $IsoPath
    $FinalIsoStreams = @(Get-Item -LiteralPath $IsoPath -Stream *)
    $ZoneIdentifierPresent = `
        $FinalIsoStreams.Stream -contains 'Zone.Identifier'
    $IsoStillStable = (
        $IsoFinal.Length -eq $IsoAfter.Length -and
        $IsoFinal.LastWriteTimeUtc -eq $IsoAfter.LastWriteTimeUtc
    )
    $AdapterSwitchName = if ($Adapters.Count -eq 1) {
        $Adapters[0].SwitchName
    }
    $BootOrder = @($Firmware.BootOrder)
    $FirstBootDevice = if ($BootOrder.Count -ge 1) {
        $BootOrder[0].Device
    }
    $SecondBootDevice = if ($BootOrder.Count -ge 2) {
        $BootOrder[1].Device
    }
    $DvdFirst = (
        $DvdDrives.Count -eq 1 -and
        $null -ne $FirstBootDevice -and
        $FirstBootDevice.ControllerType -eq `
            $DvdDrives[0].ControllerType -and
        $FirstBootDevice.ControllerNumber -eq `
            $DvdDrives[0].ControllerNumber -and
        $FirstBootDevice.ControllerLocation -eq `
            $DvdDrives[0].ControllerLocation
    )
    $DiskSecond = (
        $HardDisks.Count -eq 1 -and
        $null -ne $SecondBootDevice -and
        $SecondBootDevice.ControllerType -eq `
            $HardDisks[0].ControllerType -and
        $SecondBootDevice.ControllerNumber -eq `
            $HardDisks[0].ControllerNumber -and
        $SecondBootDevice.ControllerLocation -eq `
            $HardDisks[0].ControllerLocation
    )

    $Phase4CPreflightPass = (
        $Vmms.Status -eq 'Running' -and
        $Vm.State -eq 'Off' -and
        $Vm.Generation -eq 2 -and
        $Processor.Count -eq 2 -and
        -not $Memory.DynamicMemoryEnabled -and
        $Memory.Startup -eq 6GB -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing' -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($AdapterSwitchName) -and
        $HardDisks.Count -eq 1 -and
        $HardDisks[0].Path -eq $VhdPath -and
        $Vhd.VhdType -eq 'Dynamic' -and
        $Vhd.Size -eq 60GB -and
        $DvdDrives.Count -eq 1 -and
        $DvdDrives[0].Path -eq $IsoPath -and
        $IsoStable -and
        $IsoStillStable -and
        $IsoFinal.Length -eq $ExpectedIsoBytes -and
        $ComputedIsoHash -eq $ExpectedIsoHash -and
        -not $ZoneIdentifierPresent -and
        $Firmware.SecureBoot -eq 'On' -and
        $Firmware.SecureBootTemplate -eq `
            'MicrosoftUEFICertificateAuthority' -and
        $DvdFirst -and
        $DiskSecond -and
        $Snapshots.Count -eq 0 -and
        $FreeMemoryBytes -ge $MemoryFloor -and
        $DVolume.SizeRemaining -ge $DriveFloor -and
        $AverageCpuLoad -le 50 -and
        $PeakCpuLoad -le 70 -and
        $TransitioningVmCount -eq 0 -and
        $NoCompetingWorkConfirmed
    )

    [pscustomobject]@{
        ComputerName              = $env:COMPUTERNAME
        VmName                    = $Vm.Name
        State                     = $Vm.State
        Generation                = $Vm.Generation
        ProcessorCount            = $Processor.Count
        StartupMemoryGiB          = $Memory.Startup / 1GB
        DynamicMemoryEnabled      = $Memory.DynamicMemoryEnabled
        Disconnected              = [string]::IsNullOrWhiteSpace(
            $AdapterSwitchName
        )
        VhdVirtualSizeGiB         = $Vhd.Size / 1GB
        IsoName                   = $IsoFinal.Name
        IsoBytes                  = $IsoFinal.Length
        IsoSHA256                 = $ComputedIsoHash
        ZoneIdentifierPresent     = $ZoneIdentifierPresent
        SecureBootTemplate        = $Firmware.SecureBootTemplate
        DvdFirst                  = $DvdFirst
        DiskSecond                = $DiskSecond
        SnapshotCount             = $Snapshots.Count
        FreeMemoryGiB             = [math]::Round(
            $FreeMemoryBytes / 1GB, 1
        )
        DFreeGiB                  = [math]::Round(
            $DVolume.SizeRemaining / 1GB, 1
        )
        AverageCpuLoadPercent     = $AverageCpuLoad
        PeakCpuLoadPercent        = $PeakCpuLoad
        TransitioningVmCount      = $TransitioningVmCount
        NoCompetingWorkConfirmed = $NoCompetingWorkConfirmed
        Phase4CPreflightPass      = $Phase4CPreflightPass
    } | Format-List

    if (-not $Phase4CPreflightPass) {
        throw 'Q011 Phase 4C preflight failed; do not start the VM.'
    }
}
```

Stop and return the structured output. First power-on requires every field to
match and `Phase4CPreflightPass=True` in this fresh run.

## Step 2 — Connect Before Starting

1. Open **Server Manager -> Tools -> Hyper-V Manager**.
2. Select only local host `WIN-PRQD8TJG04M`.
3. Select only `Q011-RHEL102-BASELINE` and confirm its state is **Off**.
4. Right-click the Q011 VM and select **Connect**.
5. Confirm the VMConnect title names only `Q011-RHEL102-BASELINE`.
6. In VMConnect, select **Action -> Start**.
7. Click inside the console immediately. If **Press any key to boot from CD or
   DVD** appears, press the spacebar once.
8. At the RHEL boot menu, select **Install Red Hat Enterprise Linux 10.2** and
   press Enter. Do not edit boot parameters or select rescue mode.

Capture the safe boot-menu process image described in the
[screenshot plan](q011-screenshot-plan.md#phase-4c--rhel-installer).
If the menu identifies another release, stop.

## Step 3 — Configure The Installer Without Network

Use the graphical installer and complete only these settings:

1. On **Welcome to Red Hat Enterprise Linux 10.2**, select **English ->
   English (United States)** and choose **Continue**.
2. Wait for **Installation Source** and **Software Selection** to finish their
   initial metadata checks. The source must resolve to auto-detected local
   media. Do not select CDN or add a network repository.
3. Open **Time & Date**:
   - choose `Americas` and `Denver`;
   - leave network time unavailable/off for this disconnected build; and
   - select **Done**.
4. Open **Software Selection**:
   - select **Minimal Install**;
   - select no additional software; and
   - choose **Done**.
5. Open **Installation Destination**:
   - select only the single 60 GiB Microsoft virtual disk;
   - select **Automatic** storage configuration;
   - leave encryption and space-reclamation options clear; and
   - choose **Done**.
6. Open **Network & Host Name**:
   - keep the interface toggle **Off**;
   - enter `q011-rhel01` in **Host Name** and select **Apply**;
   - confirm the interface remains disconnected; and
   - choose **Done**.
7. Open **Root Account** and confirm **Disable root account** remains selected.
   Do not enable root, set a root password, or allow root SSH login.
8. Open **User Creation**:
   - Full name: `Leonel`;
   - User name: `leonel`;
   - keep **Add administrative privileges to this user account** selected;
   - keep **Require a password to use this account** selected;
   - enter and confirm the local password privately; and
   - choose **Done**.
9. Leave **Connect to Red Hat** untouched and unregistered. Do not enter an
   account, organization ID, activation key, token, proxy, or repository URL.
10. Do not change Kdump, security-policy, kernel, package, or boot options in
    this phase.

## Step 4 — Final No-Write Gate And Primary Screenshot

Return to **Installation Summary** and do not select **Begin Installation**
until all of these are visible or have just been re-opened and confirmed:

- local media is the installation source;
- `Minimal Install` is selected;
- the one 60 GiB disk is selected with automatic storage;
- the network interface is disconnected/off;
- hostname is `q011-rhel01`;
- root is disabled;
- the local `leonel` administrator is configured; and
- Red Hat registration is not configured.

Capture
`q011-phase4c-01-rhel-installation-summary.png` now. The screenshot must not
show the user-creation dialog, password fields, a password-quality message,
registration fields, another VM, notifications, or unrelated host content.
The non-secret project username may appear only as an installer summary label.

If any tile is incomplete or unexpected, do not begin installation. Use the
pre-write path in the failure-containment plan and leave the VM Off.

## Step 5 — Install And Stop At Completion

1. Select **Begin Installation** once.
2. Let the installation run without opening another console, changing media,
   attaching a switch, or interrupting the VM.
3. If progress continues normally, wait. Do not treat a long package phase by
   itself as a failure.
4. When the installer reports completion and enables **Reboot System**, do not
   select it yet.
5. Capture the safe supporting installation-complete image. It proves that
   disk writes completed and identifies the mandatory pre-reboot eject point.

After **Begin Installation**, the VHDX contains partially or fully installed
state. A failure now is contained, not automatically rolled back. Preserve the
VM/VHDX and follow the post-write section of the companion plan.

## Step 6 — Eject Only The Q011 ISO Before Reboot

Leave VMConnect on the completed installer screen. In elevated Windows
PowerShell on the host, run the complete block. It verifies the exact target,
previews the one detach, detaches only that VM's DVD media, and proves the VM
is still running and disconnected. The ISO file itself is retained.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $IsoPath = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'
    $ExpectedIsoBytes = [int64]11059986432

    $IsAdmin = (
        [Security.Principal.WindowsPrincipal]::new(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )
    ).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }
    if (-not $IsAdmin) {
        throw 'Run the eject block in elevated Windows PowerShell.'
    }

    $VmBefore = Get-VM -Name $VmName
    $DvdBefore = @(Get-VMDvdDrive -VMName $VmName)
    $AdaptersBefore = @(Get-VMNetworkAdapter -VMName $VmName)
    $SnapshotsBefore = @(Get-VMSnapshot -VMName $VmName)
    $Iso = Get-Item -LiteralPath $IsoPath
    $SwitchBefore = if ($AdaptersBefore.Count -eq 1) {
        $AdaptersBefore[0].SwitchName
    }

    $PreEjectPass = (
        $VmBefore.State -eq 'Running' -and
        $DvdBefore.Count -eq 1 -and
        $DvdBefore[0].Path -eq $IsoPath -and
        $AdaptersBefore.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($SwitchBefore) -and
        $SnapshotsBefore.Count -eq 0 -and
        $Iso.Length -eq $ExpectedIsoBytes
    )

    [pscustomobject]@{
        ComputerName  = $env:COMPUTERNAME
        VmName        = $VmBefore.Name
        VmState       = $VmBefore.State
        AttachedMedia = $DvdBefore[0].Path
        Disconnected  = [string]::IsNullOrWhiteSpace($SwitchBefore)
        SnapshotCount = $SnapshotsBefore.Count
        IsoRetained   = $Iso.Exists
        PreEjectPass  = $PreEjectPass
    } | Format-List

    if (-not $PreEjectPass) {
        throw 'Q011 pre-eject gate failed; do not reboot the installer.'
    }

    $DvdBefore[0] | Set-VMDvdDrive -Path $null -WhatIf
    $DvdBefore[0] | Set-VMDvdDrive -Path $null

    # Hyper-V may expose the completed detach after a brief visibility delay.
    $EjectDeadline = (Get-Date).AddSeconds(15)
    do {
        $DvdAfter = @(Get-VMDvdDrive -VMName $VmName)
        if (
            $DvdAfter.Count -eq 1 -and
            [string]::IsNullOrWhiteSpace($DvdAfter[0].Path)
        ) {
            break
        }
        Start-Sleep -Seconds 1
    } while ((Get-Date) -lt $EjectDeadline)

    $VmAfter = Get-VM -Name $VmName
    $DvdAfter = @(Get-VMDvdDrive -VMName $VmName)
    $AdaptersAfter = @(Get-VMNetworkAdapter -VMName $VmName)
    $SnapshotsAfter = @(Get-VMSnapshot -VMName $VmName)
    $SwitchAfter = if ($AdaptersAfter.Count -eq 1) {
        $AdaptersAfter[0].SwitchName
    }
    $IsoAfter = Get-Item -LiteralPath $IsoPath

    $Phase4CEjectPass = (
        $VmAfter.State -eq 'Running' -and
        $DvdAfter.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($DvdAfter[0].Path) -and
        $AdaptersAfter.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($SwitchAfter) -and
        $SnapshotsAfter.Count -eq 0 -and
        $IsoAfter.Length -eq $ExpectedIsoBytes
    )

    [pscustomobject]@{
        VmName             = $VmAfter.Name
        VmState            = $VmAfter.State
        DvdMediaAfter      = $DvdAfter[0].Path
        DvdEmpty           = [string]::IsNullOrWhiteSpace(
            $DvdAfter[0].Path
        )
        Disconnected       = [string]::IsNullOrWhiteSpace($SwitchAfter)
        SnapshotCount      = $SnapshotsAfter.Count
        IsoFileRetained    = $IsoAfter.Exists
        IsoBytesUnchanged  = $IsoAfter.Length -eq $ExpectedIsoBytes
        Phase4CEjectPass   = $Phase4CEjectPass
    } | Format-List

    if (-not $Phase4CEjectPass) {
        throw 'Q011 ISO ejection verification failed; do not reboot.'
    }
}
```

Required result: `PreEjectPass=True`, `DvdEmpty=True`,
`Disconnected=True`, and `Phase4CEjectPass=True`. If any value fails, do not
select **Reboot System**.

The 15-second poll above is a post-execution correction. The completed live
window used an immediate post-change query, which returned the old path before
a later exact inspection found the DVD empty. The poll has not been validated
by a second live detach. If it still fails, do not repeat the mutation or
reboot; preserve the completed installer and request the exact read-only
already-ejected verification recorded in the
[execution evidence](../evidence/q011-phase4c-evidence.md).

After the pass, optionally open only the Q011 VM's **Settings -> SCSI
Controller -> DVD Drive** and capture the supporting empty-DVD image without
selecting Apply. Close Settings without changing anything.

## Step 7 — Reboot From The Installed Disk

1. Return to the unchanged VMConnect installer-complete screen.
2. Select **Reboot System** once.
3. The empty DVD drive is still first in firmware order, so UEFI must skip it
   and boot the installed virtual hard disk.
4. If the RHEL installer menu reappears, do not select any option. Use the
   unexpected-loop containment procedure and stop.
5. Wait for the installed `q011-rhel01` text login prompt.

Do not attach a switch to make boot or login easier.

## Step 8 — Verify The Installed Offline Baseline

Log in locally as `leonel`. Enter the password only at the console. Run
`sudo -v`, enter the same local password privately, and then run `clear` so no
authentication prompt remains on screen.

Run the following read-only block from the Bash prompt. It writes no file and
prints no secret.

During the completed execution, VMConnect rejected the long **Type clipboard
text** payload and emitted `atkbd` unknown-key messages. Leonel stopped using
that input path and manually ran the same assertions as short commands. The
block remains valid for a console that can receive it safely; VMConnect
operators should follow the short-command method in the
[execution evidence](../evidence/q011-phase4c-evidence.md) instead of retrying
clipboard injection.

```bash
Release="$(cat /etc/redhat-release)"
HostName="$(hostnamectl --static)"
SelinuxMode="$(getenforce)"
RootState="$(sudo passwd -S root | awk '{print $2}')"
RootLockPass=False
case "$RootState" in
    L|LK) RootLockPass=True ;;
esac
SystemState="$(systemctl is-system-running)"
FailedUnitCount="$(systemctl --failed --no-legend --plain | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')"
GlobalIPv4Count="$(ip -o -4 address show scope global | wc -l | tr -d ' ')"
GlobalIPv6Count="$(ip -o -6 address show scope global | wc -l | tr -d ' ')"
DefaultIPv4RouteCount="$(ip -4 route show default | wc -l | tr -d ' ')"
DefaultIPv6RouteCount="$(ip -6 route show default | wc -l | tr -d ' ')"
ConnectedNonLoopbackCount="$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status | awk -F: '$2 != "loopback" && $3 == "connected" {count++} END {print count+0}')"
PhysicalVolumeCount="$(sudo pvs --noheadings -o pv_name | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')"
VolumeGroupCount="$(sudo vgs --noheadings -o vg_name | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')"
LogicalVolumeCount="$(sudo lvs --noheadings -o lv_name | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')"
RootSource="$(findmnt -n -o SOURCE /)"
ConsumerCertificatePresent=False
if sudo test -s /etc/pki/consumer/cert.pem; then
    ConsumerCertificatePresent=True
fi

SubscriptionManagerPresent=False
SubscriptionIdentityRegistered=False
if command -v subscription-manager >/dev/null 2>&1; then
    SubscriptionManagerPresent=True
    sudo subscription-manager identity >/dev/null 2>&1
    if [ "$?" -eq 0 ]; then
        SubscriptionIdentityRegistered=True
    fi
fi

ReleasePass=False
case "$Release" in
    "Red Hat Enterprise Linux release 10.2"*) ReleasePass=True ;;
esac

WheelPass=False
if id -nG leonel | tr ' ' '\n' | grep -qx wheel; then
    WheelPass=True
fi

RegistrationAbsent=False
if [ "$ConsumerCertificatePresent" = False ] && \
   [ "$SubscriptionIdentityRegistered" = False ]; then
    RegistrationAbsent=True
fi

Phase4CPass=False
if [ "$ReleasePass" = True ] && \
   [ "$HostName" = q011-rhel01 ] && \
   [ "$SelinuxMode" = Enforcing ] && \
   [ "$RootLockPass" = True ] && \
   [ "$WheelPass" = True ] && \
   [ "$SystemState" = running ] && \
   [ "$FailedUnitCount" -eq 0 ] && \
   [ "$GlobalIPv4Count" -eq 0 ] && \
   [ "$GlobalIPv6Count" -eq 0 ] && \
   [ "$DefaultIPv4RouteCount" -eq 0 ] && \
   [ "$DefaultIPv6RouteCount" -eq 0 ] && \
   [ "$ConnectedNonLoopbackCount" -eq 0 ] && \
   [ "$PhysicalVolumeCount" -ge 1 ] && \
   [ "$VolumeGroupCount" -ge 1 ] && \
   [ "$LogicalVolumeCount" -ge 1 ] && \
   [ "$RegistrationAbsent" = True ]; then
    Phase4CPass=True
fi

printf 'Release=%s\n' "$Release"
printf 'Hostname=%s\n' "$HostName"
printf 'SELinux=%s\n' "$SelinuxMode"
printf 'RootPasswordState=%s\n' "$RootState"
printf 'RootLockPass=%s\n' "$RootLockPass"
printf 'LeonelInWheel=%s\n' "$WheelPass"
printf 'SystemState=%s\n' "$SystemState"
printf 'FailedUnitCount=%s\n' "$FailedUnitCount"
printf 'GlobalIPv4Count=%s\n' "$GlobalIPv4Count"
printf 'GlobalIPv6Count=%s\n' "$GlobalIPv6Count"
printf 'DefaultIPv4RouteCount=%s\n' "$DefaultIPv4RouteCount"
printf 'DefaultIPv6RouteCount=%s\n' "$DefaultIPv6RouteCount"
printf 'ConnectedNonLoopbackCount=%s\n' "$ConnectedNonLoopbackCount"
printf 'PhysicalVolumeCount=%s\n' "$PhysicalVolumeCount"
printf 'VolumeGroupCount=%s\n' "$VolumeGroupCount"
printf 'LogicalVolumeCount=%s\n' "$LogicalVolumeCount"
printf 'RootSource=%s\n' "$RootSource"
printf 'ConsumerCertificatePresent=%s\n' "$ConsumerCertificatePresent"
printf 'SubscriptionManagerPresent=%s\n' "$SubscriptionManagerPresent"
printf 'SubscriptionIdentityRegistered=%s\n' "$SubscriptionIdentityRegistered"
printf 'RegistrationAbsent=%s\n' "$RegistrationAbsent"
printf 'Phase4CPass=%s\n' "$Phase4CPass"
```

Required result: `Phase4CPass=True` and `RootLockPass=True`. The installed
RHEL 10.2 shadow-utils returned `RootPasswordState=L`; other supported builds
may return `LK`. Both are accepted locked-password status codes and expose no
hash. The network counts prove this phase remained offline. The LVM counts
prove automatic installation produced the expected LVM-backed layout. This
phase does not claim patch currency, OpenSSH reachability, firewall policy, or
final hardening; those remain later Q011 phases.

Capture `q011-phase4c-02-installed-offline-verification.png` after the final
output is visible. Crop to the VMConnect console and keep credentials and any
earlier password prompt out of frame.

Registration absence is fail-closed on the local consumer certificate. When
`subscription-manager` is installed, its local identity result provides a
second check; when Minimal Install omits the command, the script records that
fact without installing anything. If a consumer certificate exists, identity
reports registered, or any other assertion fails, retain the output as a
failure and stop.

## Step 9 — Normal Shutdown And Host End-State Proof

Only after `Phase4CPass=True`, run this inside the guest:

```bash
sudo systemctl poweroff
```

Enter no credential if the existing `sudo` timestamp is still valid; otherwise
enter the local password privately. Do not use Hyper-V **Turn Off** for normal
closeout.

After VMConnect reports the guest has stopped, run this read-only block in
elevated Windows PowerShell:

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdPath = 'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }

    $Deadline = (Get-Date).AddMinutes(3)
    do {
        $Vm = Get-VM -Name $VmName
        if ($Vm.State -eq 'Off') {
            break
        }
        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $Deadline)

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $SwitchName = if ($Adapters.Count -eq 1) {
        $Adapters[0].SwitchName
    }

    $Phase4CEndStatePass = (
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($SwitchName) -and
        $HardDisks.Count -eq 1 -and
        $HardDisks[0].Path -eq $VhdPath -and
        $DvdDrives.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($DvdDrives[0].Path) -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing'
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        VmName                = $Vm.Name
        State                 = $Vm.State
        AdapterCount          = $Adapters.Count
        Disconnected          = [string]::IsNullOrWhiteSpace($SwitchName)
        VhdPath               = $HardDisks[0].Path
        DvdEmpty              = [string]::IsNullOrWhiteSpace(
            $DvdDrives[0].Path
        )
        SnapshotCount         = $Snapshots.Count
        AutomaticCheckpoints  = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction  = $Vm.AutomaticStartAction
        Phase4CEndStatePass   = $Phase4CEndStatePass
    } | Format-List

    if (-not $Phase4CEndStatePass) {
        throw 'Q011 Phase 4C end-state verification failed; stop.'
    }
}
```

Required final result: `State=Off`, `Disconnected=True`, `DvdEmpty=True`,
`SnapshotCount=0`, and `Phase4CEndStatePass=True`.

## Evidence And Claim Boundary

The completed window retains sanitized searchable text for:

1. the fresh Phase 4C preflight;
2. the pre-eject and post-eject assertions;
3. the reviewed manual guest assertions and combined pass marker; and
4. the host `Phase4CEndStatePass` result.

Follow the [Phase 4C screenshot plan](q011-screenshot-plan.md#phase-4c--rhel-installer).
The project README may display only the Installation Summary and installed
offline-verification images. Boot, completion, and DVD-ejection captures go in
a linked visual walkthrough.

Phase 4C proved only that the verified RHEL 10.2 media installed a minimal,
locally administered, root-locked, SELinux-enforcing, LVM-backed guest while
the Hyper-V adapter stayed disconnected. It does not prove a patched system,
subscription state suitable for updates, SSH reachability, firewalld policy,
or production readiness.

## Technical References

- [Red Hat: interactively installing RHEL 10 from installation media](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/interactively_installing_rhel_from_installation_media/index)
- [Red Hat: installer storage, users, software, and network/hostname choices](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/interactively_installing_rhel_from_installation_media/customizing-the-system-in-the-installer)
- [Red Hat: RHEL 10 registration methods](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/interactively_installing_rhel_from_installation_media/registering-your-rhel-system)
- [Microsoft: `Set-VMDvdDrive`, including ejecting media with a null path](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vmdvddrive)
