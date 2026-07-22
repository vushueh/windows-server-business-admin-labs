# Q011 Phase 4B — Exact Rollback Plan

**Scope:** only a failed Q011 Phase 4B creation on `WIN-PRQD8TJG04M`  
**Protected objects:** every other VM, VHDX, ISO, switch, host setting, and
guest  
**Normal successful state:** retain `Q011-RHEL102-BASELINE` Off for a separate
Phase 4C approval

**Execution result:** rollback was not triggered. Final verification returned
`Phase4BPass=True`, and the VM was retained Off and disconnected.

## Rollback Authority

The Phase 4B approval text authorizes this rollback only when the fresh
preflight proved both the exact VM name and exact VHDX absent, and the same
approved window then created one or both objects before failing. It does not
authorize deleting a previously existing object, cleaning an uncertain state,
or removing a successfully verified retained VM after the window closes.

`Remove-VM` removes the VM configuration but does not delete its virtual hard
disk. The exact VHDX therefore has its own guarded removal step. The source ISO
must remain untouched.

## Decision Path

1. If the New Virtual Machine Wizard was canceled before **Finish**, run the
   read-only absence check below. Do not delete anything when both objects are
   absent.
2. If the wizard completed but a setting or verification failed, leave the VM
   Off and run the exact rollback block. The block removes objects only when
   the attached-disk inventory exactly matches the frozen one-disk design.
3. If the VM is Running, Starting, Stopping, Saving, Paused, or in any state
   other than Off, do not stop or remove it under this plan. Stop and request a
   new inspection/recovery approval.
4. If the VM has any VHD path other than the frozen Q011 path, if provenance is
   uncertain, or if the host/session was interrupted, stop without deletion.
   Retain the exact mismatch output and request a fresh exact-object inspection
   and recovery approval; do not improvise a cleanup under Phase 4B.

## Read-Only Absence Check

```powershell
$VmName = 'Q011-RHEL102-BASELINE'
$VhdPath = 'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    VMExists = [bool](Get-VM -Name $VmName -ErrorAction SilentlyContinue)
    VhdExists = Test-Path -LiteralPath $VhdPath -PathType Leaf
} | Format-List
```

When both values are `False`, rollback is already complete.

## Exact Failed-Creation Rollback

Run this only under the same failed Phase 4B window described above. It uses
literal names and paths; it contains no wildcard.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdPath = `
        'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'
    $IsoPath = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }

    $Vm = Get-VM -Name $VmName -ErrorAction SilentlyContinue
    $VmExistedAtRollback = [bool]$Vm
    $VhdExistedAtRollback = Test-Path -LiteralPath $VhdPath -PathType Leaf

    if (-not $VmExistedAtRollback -and -not $VhdExistedAtRollback) {
        [pscustomobject]@{
            ComputerName = $env:COMPUTERNAME
            VMAbsent = $true
            VhdAbsent = $true
            IsoRetained = Test-Path -LiteralPath $IsoPath -PathType Leaf
            RollbackPass = $true
        } | Format-List
        return
    }

    if ($Vm) {
        if ($Vm.State -ne 'Off') {
            throw 'Rollback stopped: the Q011 VM is not Off. Nothing deleted.'
        }

        $AttachedHardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
        if ($AttachedHardDisks.Count -ne 1 -or
            $AttachedHardDisks[0].Path -ne $VhdPath) {
            throw (
                'Rollback stopped: the Q011 disk inventory does not match ' +
                'the one frozen VHDX. Nothing deleted; request a fresh ' +
                'exact-object inspection and recovery approval.'
            )
        }

        Remove-VM -Name $VmName -Force
    }

    if (Get-VM -Name $VmName -ErrorAction SilentlyContinue) {
        throw 'Rollback stopped: the exact VM configuration is still present.'
    }

    if (Test-Path -LiteralPath $VhdPath -PathType Leaf) {
        Remove-Item -LiteralPath $VhdPath -Force
    }

    $VMAbsent = -not [bool](
        Get-VM -Name $VmName -ErrorAction SilentlyContinue
    )
    $VhdAbsent = -not (Test-Path -LiteralPath $VhdPath)
    $IsoRetained = Test-Path -LiteralPath $IsoPath -PathType Leaf
    $RollbackPass = $VMAbsent -and $VhdAbsent -and $IsoRetained

    [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        VMExistedAtRollback = $VmExistedAtRollback
        VhdExistedAtRollback = $VhdExistedAtRollback
        VMAbsent = $VMAbsent
        VhdAbsent = $VhdAbsent
        IsoRetained = $IsoRetained
        RollbackPass = $RollbackPass
    } | Format-List

    if (-not $RollbackPass) {
        throw 'Q011 Phase 4B rollback did not reach the exact safe state.'
    }
}
```

## Rollback Success Criteria

- `VMAbsent=True`;
- `VhdAbsent=True`;
- `IsoRetained=True`;
- `RollbackPass=True`; and
- no other VM, disk, switch, service, or host setting changed.

Retain the sanitized structured output as searchable evidence. If rollback
was needed, capture a tightly cropped PowerShell result only when it is safe;
store it as overflow evidence rather than displacing the planned success
screenshots. Never capture an account path, credential prompt, unrelated VM
inventory, notification, or desktop content.

## What This Plan Does Not Remove

- the verified local RHEL ISO;
- `D:\Hyper-V\ISO` or either Hyper-V default directory;
- an existing or unrelated `.vhdx` file;
- another VM or checkpoint; or
- a successfully verified Q011 VM after Phase 4B closes.

## Technical Reference

- [Microsoft `Remove-VM`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/remove-vm)
