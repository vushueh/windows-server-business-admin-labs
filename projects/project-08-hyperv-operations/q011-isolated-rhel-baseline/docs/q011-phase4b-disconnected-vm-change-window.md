# Q011 Phase 4B — Disconnected VM-Creation Change Window

**State:** completed 2026-07-19; `Phase4BPass=True`, VM retained Off  
**Executor:** Leonel, interactively on `WIN-PRQD8TJG04M`  
**Expected impact:** one new Off Hyper-V VM and one new dynamic VHDX; no
guest boot, memory allocation, network attachment, host reboot, or outage  
**Rollback:** exact Q011 VM and VHDX only, as defined in the linked plan

## Completion Result

The initial preflight safely stopped on `Zone.Identifier`. A separate exact
approval removed only that stream and proved the ISO byte size and SHA-256
unchanged. After a second operator-confirmation stop, the final fresh preflight
passed. Leonel then completed the documented Hyper-V Manager workflow and the
exact Off-state verification returned `Phase4BPass=True`. No rollback was
needed; Phase 4C first power-on remains separately gated. See the
[execution evidence](../evidence/q011-phase4b-evidence.md).

## Capacity Decision

The last approved read-only discovery found 20 physical cores, 40 logical
processors, 40,411,889,664 bytes (about 37.6 GiB) of free memory, and
952,591,835,136 bytes (about 887 GiB) free on `D:`. The frozen VM needs 2 vCPU,
6 GiB static memory, and a 60 GiB dynamically expanding VHDX. That evidence
supports the design, but it is point-in-time evidence rather than permission
to build.

The live window must recheck capacity and load. It stops below 16 GiB free
physical memory, below 100 GiB free on `D:`, above 50 percent average or 70
percent peak CPU across three samples, during another VM transition, or when
Leonel cannot confirm that no backup, storage maintenance, or competing
Hyper-V operation is active.

## Retained Exact Approval Text

This is the exact historical approval pattern retained for audit; it is not
permission to rerun the completed window:

> I approve Q011 Phase 4B only on WIN-PRQD8TJG04M: run the documented fresh
> read-only preflight and stop if any gate fails; if it passes, use Hyper-V
> Manager to create only Q011-RHEL102-BASELINE as the frozen Generation 2,
> 2-vCPU, 6-GiB-static, 60-GiB-dynamic VM, attach only the verified local RHEL
> 10.2 DVD, keep its one adapter Not Connected, disable automatic checkpoints,
> use the Microsoft UEFI Certificate Authority Secure Boot template, keep the
> VM Off, run the exact verification, and capture the two safe screenshots. If
> creation or verification fails, remove only the new Q011 VM and its exact
> new VHDX using the documented rollback. Do not unblock or alter the ISO,
> start the VM, open its console, connect any switch, create a checkpoint,
> change another VM or host setting, reboot the host, or perform Git/GitHub
> operations. Stop after Phase 4B. No other action is approved.

## Fixed Inputs

| Item | Exact value |
|---|---|
| Host | `WIN-PRQD8TJG04M` |
| VM name | `Q011-RHEL102-BASELINE` |
| Generation | 2 |
| Processor | 2 vCPU |
| Memory | 6 GiB static; Dynamic Memory disabled |
| VHDX | `D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx` |
| VHDX virtual size/type | 60 GiB, dynamically expanding |
| ISO | `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso` |
| ISO bytes | `11059986432` |
| ISO SHA-256 | `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Secure Boot template | `MicrosoftUEFICertificateAuthority` |
| Network | exactly one adapter; `SwitchName` blank / **Not connected** |
| Automatic checkpoints | disabled |
| Automatic start | `Nothing` |
| End state | VM Off; no checkpoint |

## Stop Conditions

Stop before VM creation when any of these is true:

- the PowerShell session is not elevated or the computer name differs;
- the exact VM name or VHDX already exists;
- the VMMS service is not Running or the exact VHD directory is unavailable;
- the ISO is missing, has a different byte count or hash, or changes while it
  is being hashed;
- a `Zone.Identifier` alternate data stream is present;
- a capacity, CPU-load, concurrent-transition, or operator-confirmation gate
  fails; or
- another console is already performing Q011 or Hyper-V work.

The screenshot-visible **Unblock** control from Phase 4A makes the read-only
stream check important. Phase 4B does not authorize `Unblock-File`, stream
deletion, stream-content reads, or any other ISO change. If the stream exists,
retain `PreflightPass=False`, stop, and request a separate narrow decision.

## Step 1 — Fresh Read-Only Preflight

Run the complete block in elevated Windows PowerShell directly on
`WIN-PRQD8TJG04M`. It reads only the exact target objects and sanitized
host-level capacity/state summaries. It does not create or change anything.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdDirectory = 'D:\Hyper-V\Virtual Hard Disks'
    $VhdPath = Join-Path $VhdDirectory "$VmName.vhdx"
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
    $OperatingSystem = Get-CimInstance Win32_OperatingSystem
    $FreeMemoryBytes = [int64]$OperatingSystem.FreePhysicalMemory * 1KB
    $DVolume = Get-Volume -DriveLetter D

    $ExistingVm = Get-VM -Name $VmName -ErrorAction SilentlyContinue
    $VmNameAbsent = -not [bool]$ExistingVm
    $VhdAbsent = -not (Test-Path -LiteralPath $VhdPath)
    $VhdDirectoryPresent = Test-Path -LiteralPath $VhdDirectory `
        -PathType Container

    if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
        throw 'The exact local Q011 ISO is absent.'
    }

    $IsoBefore = Get-Item -LiteralPath $IsoPath
    $IsoStreams = @(Get-Item -LiteralPath $IsoPath -Stream * )
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
    $IsoPass = (
        $IsoStable -and
        $IsoAfter.Length -eq $ExpectedIsoBytes -and
        $ComputedIsoHash -eq $ExpectedIsoHash
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

    # Recheck collision and free-space gates after hashing and load sampling.
    $VmNameAbsent = -not [bool](
        Get-VM -Name $VmName -ErrorAction SilentlyContinue
    )
    $VhdAbsent = -not (Test-Path -LiteralPath $VhdPath)
    $DVolume = Get-Volume -DriveLetter D
    $OperatingSystem = Get-CimInstance Win32_OperatingSystem
    $FreeMemoryBytes = [int64]$OperatingSystem.FreePhysicalMemory * 1KB
    $Vmms = Get-Service -Name vmms
    $IsoFinal = Get-Item -LiteralPath $IsoPath
    $IsoStillStable = (
        $IsoFinal.Length -eq $IsoAfter.Length -and
        $IsoFinal.LastWriteTimeUtc -eq $IsoAfter.LastWriteTimeUtc
    )
    $FinalIsoStreams = @(Get-Item -LiteralPath $IsoPath -Stream *)
    $ZoneIdentifierPresent = `
        $FinalIsoStreams.Stream -contains 'Zone.Identifier'

    $PreflightPass = (
        $Vmms.Status -eq 'Running' -and
        $VmNameAbsent -and
        $VhdAbsent -and
        $VhdDirectoryPresent -and
        $IsoPass -and
        $IsoStillStable -and
        -not $ZoneIdentifierPresent -and
        $FreeMemoryBytes -ge $MemoryFloor -and
        $DVolume.SizeRemaining -ge $DriveFloor -and
        $AverageCpuLoad -le 50 -and
        $PeakCpuLoad -le 70 -and
        $TransitioningVmCount -eq 0 -and
        $NoCompetingWorkConfirmed
    )

    [pscustomobject]@{
        ComputerName             = $env:COMPUTERNAME
        IsAdmin                  = $IsAdmin
        VmmsStatus               = $Vmms.Status
        VmNameAbsent             = $VmNameAbsent
        VhdAbsent                = $VhdAbsent
        VhdDirectoryPresent      = $VhdDirectoryPresent
        IsoName                  = $IsoFinal.Name
        IsoBytes                 = $IsoFinal.Length
        IsoSHA256                = $ComputedIsoHash
        IsoStableThroughPreflight = $IsoStable -and $IsoStillStable
        ZoneIdentifierPresent    = $ZoneIdentifierPresent
        FreeMemoryGiB            = [math]::Round($FreeMemoryBytes / 1GB, 1)
        DFreeGiB                 = [math]::Round($DVolume.SizeRemaining / 1GB, 1)
        AverageCpuLoadPercent    = $AverageCpuLoad
        PeakCpuLoadPercent       = $PeakCpuLoad
        TransitioningVmCount     = $TransitioningVmCount
        NoCompetingWorkConfirmed = $NoCompetingWorkConfirmed
        PreflightPass            = $PreflightPass
    } | Format-List

    if (-not $PreflightPass) {
        throw 'Q011 Phase 4B preflight failed; do not create the VM.'
    }
}
```

Stop and return the structured output for validation. Do not continue when
the final value is anything other than `PreflightPass=True`.

The 11 GB ISO is hashed once, then its exact length and NTFS
`LastWriteTimeUtc` are rechecked after load sampling and operator confirmation.
A second hash would add another full-file read to this multi-role host. The
accepted low residual risk is a deliberately engineered in-place rewrite that
preserves both length and high-resolution timestamp during that short gap; any
ordinary file change fails the stability gate.

## Step 2 — Create The VM In Hyper-V Manager

Continue only inside the exact approved window after Step 1 passes.

1. Open **Server Manager → Tools → Hyper-V Manager**.
2. Select only local host `WIN-PRQD8TJG04M`.
3. Select **Action → New → Virtual Machine**.
4. On **Before You Begin**, select **Next**.
5. On **Specify Name and Location**:
   - Name: `Q011-RHEL102-BASELINE`.
   - Leave **Store the virtual machine in a different location** unchecked so
     the existing Hyper-V default **configuration** path is used. This choice
     is independent of the VHDX location selected later in the wizard.
6. On **Specify Generation**, choose **Generation 2**.
7. On **Assign Memory**:
   - Startup memory: `6144` MB.
   - Clear **Use Dynamic Memory for this virtual machine**.
8. On **Configure Networking**, select **Not Connected**. Do not select
   `Q007-Private`, VLAN 70, an external switch, or any other switch.
9. On **Connect Virtual Hard Disk**:
   - Choose **Create a virtual hard disk**.
   - Name: `Q011-RHEL102-BASELINE.vhdx`.
   - Location: `D:\Hyper-V\Virtual Hard Disks\`.
   - Size: `60` GB.
10. On **Installation Options**, choose **Install an operating system from a
    bootable image file** and select only
    `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso`.
11. On **Summary**, reread the name, Generation 2, 6144 MB, Not Connected,
    exact VHDX, and exact ISO. If any value differs, select **Previous** and
    correct it or **Cancel**. Otherwise select **Finish**.
12. Do **not** select **Start** or **Connect**.

## Step 3 — Apply The Frozen Off-State Settings

With `Q011-RHEL102-BASELINE` still Off, right-click only that VM and choose
**Settings**:

1. **Processor** → set **Number of virtual processors** to `2`.
2. **Memory** → confirm **Startup RAM** is `6144` MB and Dynamic Memory is not
   enabled.
3. **Firmware** → enable Secure Boot, select **Microsoft UEFI Certificate
   Authority**, and move the DVD drive above the hard drive in the boot order.
4. **DVD Drive** → confirm the exact local RHEL ISO path.
5. **Network Adapter** → confirm **Virtual switch: Not connected**.
6. **Checkpoints** → clear **Use automatic checkpoints**. Do not create a
   checkpoint.
7. **Automatic Start Action** → select **Nothing**.
8. Select **Apply**, reread the settings, then select **OK**. Keep the VM Off.

Do not add a second adapter, configure VLAN identification, enable vTPM,
enable nested virtualization, alter another VM, or change a host switch.

## Step 4 — Exact Off-State Verification

Run the complete block in elevated Windows PowerShell. It queries only the
new Q011 VM and exact ISO/VHDX. It does not start or change the VM.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdPath = `
        'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'
    $IsoPath = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'
    $ExpectedIsoBytes = [int64]11059986432
    $ExpectedIsoHash = `
        'e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5'

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }

    $Vm = Get-VM -Name $VmName
    $Processor = Get-VMProcessor -VMName $VmName
    $Memory = Get-VMMemory -VMName $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Firmware = Get-VMFirmware -VMName $VmName
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $Vhd = Get-VHD -Path $VhdPath
    $Iso = Get-Item -LiteralPath $IsoPath
    $IsoHash = (
        Get-FileHash -LiteralPath $IsoPath -Algorithm SHA256
    ).Hash.ToLowerInvariant()

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
        $FirstBootDevice.ControllerType -eq $DvdDrives[0].ControllerType -and
        $FirstBootDevice.ControllerNumber -eq $DvdDrives[0].ControllerNumber -and
        $FirstBootDevice.ControllerLocation -eq `
            $DvdDrives[0].ControllerLocation
    )
    $DiskSecond = (
        $HardDisks.Count -eq 1 -and
        $null -ne $SecondBootDevice -and
        $SecondBootDevice.ControllerType -eq $HardDisks[0].ControllerType -and
        $SecondBootDevice.ControllerNumber -eq `
            $HardDisks[0].ControllerNumber -and
        $SecondBootDevice.ControllerLocation -eq `
            $HardDisks[0].ControllerLocation
    )
    $AdapterSwitchName = if ($Adapters.Count -eq 1) {
        $Adapters[0].SwitchName
    }
    $VerifiedVhdPath = if ($HardDisks.Count -eq 1) {
        $HardDisks[0].Path
    }
    $VerifiedIsoPath = if ($DvdDrives.Count -eq 1) {
        $DvdDrives[0].Path
    }

    $Phase4BPass = (
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
        $Iso.Length -eq $ExpectedIsoBytes -and
        $IsoHash -eq $ExpectedIsoHash -and
        $Firmware.SecureBoot -eq 'On' -and
        $Firmware.SecureBootTemplate -eq `
            'MicrosoftUEFICertificateAuthority' -and
        $BootOrder.Count -ge 2 -and
        $DvdFirst -and
        $DiskSecond -and
        $Snapshots.Count -eq 0
    )

    [pscustomobject]@{
        ComputerName               = $env:COMPUTERNAME
        VMName                     = $Vm.Name
        State                      = $Vm.State
        Generation                 = $Vm.Generation
        ProcessorCount             = $Processor.Count
        StartupMemoryGiB           = $Memory.Startup / 1GB
        DynamicMemoryEnabled       = $Memory.DynamicMemoryEnabled
        AutomaticCheckpoints       = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction       = $Vm.AutomaticStartAction
        AdapterCount               = $Adapters.Count
        SwitchName                 = $AdapterSwitchName
        Disconnected               = [string]::IsNullOrWhiteSpace(
            $AdapterSwitchName
        )
        VhdPath                    = $VerifiedVhdPath
        VhdType                    = $Vhd.VhdType
        VhdVirtualSizeGiB          = $Vhd.Size / 1GB
        IsoPath                    = $VerifiedIsoPath
        IsoSHA256                  = $IsoHash
        SecureBoot                 = $Firmware.SecureBoot
        SecureBootTemplate         = $Firmware.SecureBootTemplate
        DvdFirst                   = $DvdFirst
        DiskSecond                 = $DiskSecond
        SnapshotCount              = $Snapshots.Count
        Phase4BPass                = $Phase4BPass
    } | Format-List

    if (-not $Phase4BPass) {
        throw 'Phase 4B verification failed. Do not start the VM; use rollback.'
    }
}
```

Required result: `Phase4BPass=True`, `State=Off`, `Disconnected=True`, and
every frozen setting shown above. Do not use a successful VM as permission to
start Phase 4C.

## Step 5 — Capture The Actual Practice

Follow the exact [Phase 4B screenshot instructions](q011-screenshot-plan.md#phase-4b--disconnected-vm-creation):

1. `q011-phase4b-01-hyperv-disconnected-network.png` proves the final Q011
   Network Adapter is **Not connected**.
2. `q011-phase4b-02-hyperv-firmware-media.png` proves Linux-compatible Secure
   Boot and DVD-first firmware order.

Keep the VM Off after both captures. Screenshots do not replace the searchable
verification output.

## Rollback And Interruption Boundary

Use the linked [exact Phase 4B rollback plan](q011-phase4b-rollback-plan.md)
when the wizard creates an object but configuration or verification fails.
The future approval text includes rollback only for objects proven absent at
Step 1 and newly created by this same window.

If the host loses power, PowerShell is forcibly terminated, the VM is not Off,
or object provenance becomes uncertain, do not delete anything. Stop and
request a fresh exact-object inspection approval.

## Technical References

- [Microsoft `New-VM`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/new-vm)
- [Microsoft `Get-VHD`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/get-vhd)
- [Microsoft `Get-VMFirmware`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/get-vmfirmware)
- [Microsoft `Disconnect-VMNetworkAdapter`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/disconnect-vmnetworkadapter)
- [Microsoft Generation 2 VM security](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/generation-2-virtual-machine-security-features)
