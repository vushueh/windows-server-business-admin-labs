# Q011 Phase 9 — Retention Or Disposal Decision

**Status:** completed through `RETAIN-Q011`; historical, not repeat authority  
**Prepared and executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Current state:** Off, disconnected, Untagged VLAN 0, DVD empty, zero
checkpoints

## Objective

This phase closed Q011 through one explicit, attributable choice:

- **RETAIN-Q011:** keep the proved baseline Off and isolated, verify its
  retained VM/VHDX/media facts read-only, capture safe hands-on proof, and
  mark Q011 complete; or
- **PLAN-DISPOSAL-Q011:** record the intent to dispose but perform no live
  deletion. Prepare separate owner-specific windows for Red Hat registration,
  OPNsense reservation, and Hyper-V VM/VHDX cleanup.

Leonel selected `RETAIN-Q011`. This document never treats silence, the current
Off state, or an old approval as a disposal decision.

## Decision Evidence

Phase 8 proved the patched RHEL guest retained its required controls and
expected changes, then returned `Phase8EndStatePass=True`. The
[manual rebuild record](q011-manual-rebuild-record.md) is evidence-linked but
has not been replayed. No Q011 checkpoint, VM export, or image-level backup
exists. Deleting the VM and VHDX would therefore remove the only proved
running instance and rely on a future manual rebuild.

The verified RHEL ISO is shared reusable media, not a disposable Q011 object.
The DHCP reservation and Red Hat registration are external lifecycle objects;
deleting only the Hyper-V VM would leave stale state. For these reasons,
**RETAIN-Q011 is the recommended choice** until backup/restore or rebuild
replay exists. Leonel still owns the decision.

## Actual Decision Outcome

Leonel explicitly selected `RETAIN-Q011`. The read-only host gate returned
`Phase9RetentionPass=True`: Q011 was Off with one disconnected Untagged
VLAN-zero adapter, empty DVD, exact retained VHDX, zero checkpoints, automatic
checkpoints disabled, Automatic Start Action Nothing, and the exact-size
shared ISO present. Two reviewed GUI screenshots proved the Off row and Not
connected adapter without changing anything.

See the [retention evidence](../evidence/q011-phase9-evidence.md),
[searchable results](../evidence/q011-phase9-sanitized-results.txt),
[visual walkthrough](../evidence/q011-phase9-visual-walkthrough.md), and
[screenshot manifest](../evidence/q011-phase9-screenshots.sha256).

## Historical Choice Gate

Leonel provided exactly one of these choices:

1. `RETAIN-Q011`; or
2. `PLAN-DISPOSAL-Q011`.

The two branches were mutually exclusive. `PLAN-DISPOSAL-Q011` was not
selected and received no authority.

## Branch R — Retain The Verified Baseline

### Executed Approval Boundary

Branch R permitted only a fresh read-only Hyper-V verification of Q011 and the
exact VHDX/ISO paths, plus two safe screenshots. It changes no VM, VHDX, ISO,
adapter, VLAN, switch, checkpoint, service, package, network, OPNsense object,
Red Hat object, Git state, or GitHub state.

### Read-Only Final Retention Gate

Run in elevated Windows PowerShell directly on `WIN-PRQD8TJG04M`:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'
    $ExpectedVhd = (
        'D:\Hyper-V\Virtual Hard Disks\' +
        'Q011-RHEL102-BASELINE.vhdx'
    )
    $ExpectedIso = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $Vlans = @(Get-VMNetworkAdapterVlan -VMName $VmName)
    $Dvd = @(Get-VMDvdDrive -VMName $VmName)
    $Disks = @(Get-VMHardDiskDrive -VMName $VmName)
    $Snapshots = @(
        Get-VMSnapshot -VMName $VmName -ErrorAction SilentlyContinue
    )
    $VhdPresent = Test-Path -LiteralPath $ExpectedVhd -PathType Leaf
    $IsoPresent = Test-Path -LiteralPath $ExpectedIso -PathType Leaf
    $IsoBytes = if ($IsoPresent) {
        (Get-Item -LiteralPath $ExpectedIso).Length
    }
    else {
        0
    }
    $Disconnected = (
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName)
    )
    $DvdEmpty = (
        $Dvd.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Dvd[0].Path)
    )
    $VlanExact = (
        $Vlans.Count -eq 1 -and
        $Vlans[0].OperationMode -eq 'Untagged' -and
        $Vlans[0].AccessVlanId -eq 0
    )
    $OperationMode = if ($Vlans.Count -eq 1) {
        $Vlans[0].OperationMode
    }
    else {
        $null
    }
    $AccessVlanId = if ($Vlans.Count -eq 1) {
        $Vlans[0].AccessVlanId
    }
    else {
        $null
    }
    $DiskExact = (
        $Disks.Count -eq 1 -and
        $Disks[0].Path -eq $ExpectedVhd
    )

    $Phase9RetentionPass = (
        $env:COMPUTERNAME -eq 'WIN-PRQD8TJG04M' -and
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        $Disconnected -and
        $VlanExact -and
        $Dvd.Count -eq 1 -and
        $DvdEmpty -and
        $Disks.Count -eq 1 -and
        $DiskExact -and
        $VhdPresent -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing' -and
        $IsoPresent -and
        $IsoBytes -eq 11059986432
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        Decision              = 'RETAIN-Q011'
        VmName                = $Vm.Name
        State                 = $Vm.State
        AdapterCount          = $Adapters.Count
        Disconnected          = $Disconnected
        VlanRecordCount       = $Vlans.Count
        OperationMode         = $OperationMode
        AccessVlanId          = $AccessVlanId
        DvdEmpty              = $DvdEmpty
        DiskExact             = $DiskExact
        VhdPresent            = $VhdPresent
        SnapshotCount         = $Snapshots.Count
        AutomaticCheckpoints  = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction  = $Vm.AutomaticStartAction
        IsoPresent            = $IsoPresent
        IsoBytes              = $IsoBytes
        Phase9RetentionPass   = $Phase9RetentionPass
    } | Format-List

    if (-not $Phase9RetentionPass) {
        throw 'Q011 Phase 9 retention verification failed; make no change.'
    }
}
```

Stop unless `Phase9RetentionPass=True`. Do not start Q011 or hash the 10.3-GB
ISO again; Phase 4 already proved its checksum, and Phase 9 only proves the
retained exact-size media path.

### Hands-On Screenshot Result

Leonel captured actual Hyper-V practice rather than a picture of this
Markdown:

1. `q011-phase9-01-retained-vm-off.png` — Hyper-V Manager cropped to Q011's
   selected row/summary showing only its name and Off state; exclude unrelated
   VM rows.
2. `q011-phase9-02-retained-network-isolation.png` — Q011 Settings showing its
   single Network Adapter as Not connected with VLAN identification disabled.

The structured retention result is searchable evidence. Both GUI captures
appear inside the Phase 9 narrative and linked walkthrough. Neither contains
unrelated VM names, credentials, host IP addresses, or another system's
configuration.

The already-documented host name `WIN-PRQD8TJG04M` is permitted in these
captures; host IP addresses, credentials, and unrelated inventory are not.

### Branch R Success — Achieved

`Phase9RetentionPass=True`, the two reviewed screenshots, and the explicit
`RETAIN-Q011` decision complete Q011 with the VM preserved Off and isolated.
The media presence gate proves the exact path and byte size; ISO integrity
continues to rest on the retained Phase 4 SHA-256 evidence, not on a new Phase
9 hash.
The retained DHCP reservation, registration, and RPM trust remain lifecycle
state for this baseline. Starting, connecting, patching, backing up, exporting,
or repurposing it remains separately approval-gated.

### Historical Branch R Approval

This is the approval used for the completed window. Stored text is not
authority to repeat it:

> I choose RETAIN-Q011 and approve Q011 Phase 9 Branch R only on
> WIN-PRQD8TJG04M: run the documented read-only final retention gate for
> Q011-RHEL102-BASELINE and its exact VHDX/ISO paths, capture the two planned
> safe Hyper-V screenshots, and retain the VM Off, disconnected, Untagged
> VLAN 0, DVD-empty, and checkpoint-free. Do not start or change the VM,
> VHDX, ISO, adapter, switch, network, OPNsense, Red Hat registration, another
> system, Git, or GitHub. No other action is approved.

## Branch D — Not Selected; No Disposal Authority

Had Leonel chosen `PLAN-DISPOSAL-Q011`, it would have recorded intent and
stopped before live access. A
later decommission bundle must use three separately approved and ordered
owner-specific windows:

1. **Guest/Red Hat lifecycle:** decide whether to unregister the guest and
   remove only its subscription identity before it becomes unreachable.
2. **OPNsense lifecycle:** preview and remove only the Q011 Dnsmasq reservation
   for MAC `00:15:5d:14:0b:3e` and address `192.168.70.140`.
3. **Hyper-V lifecycle:** fresh-preflight exact VM/VHDX paths, preview removal,
   remove only Q011's VM registration and exact VHDX, retain the shared RHEL
   ISO, and verify absence.

Each window needs its own rollback/stop boundary and safe screenshots. No
single approval should silently span all three owners. Hyper-V VM/VHDX removal
is destructive and not recoverable from this repository.

### Unused Branch D Approval Template

This stored text was not selected and is not authority:

> I choose PLAN-DISPOSAL-Q011 and approve repository-only preparation of the
> three separate Q011 decommission windows for guest/Red Hat lifecycle,
> OPNsense reservation cleanup, and Hyper-V VM/VHDX cleanup. Do not access or
> change the live VM, registration, OPNsense, Hyper-V, ISO, VHDX, network,
> Git, or GitHub, and do not delete anything. No other action is approved.

## Stop Conditions

Stop without changing anything if:

- no exact choice is provided or both choices are mentioned;
- the requested action exceeds the chosen branch;
- Branch R finds Q011 running, connected, tagged, media-attached,
  checkpointed, missing, or path-mismatched;
- Branch D is interpreted as deletion authority;
- an unrelated VM, VHDX, ISO, reservation, registration, or host object would
  be read or changed; or
- evidence would expose credentials or private Red Hat identity values.

## Final Boundary

Q011 is complete as a retained baseline. It remains Off and isolated with its
VM/VHDX, DHCP reservation, registration, RPM trust, and shared installation
media preserved. Phase 9 grants no authority to start, connect, patch, back
up, export, clone, repurpose, unregister, or dispose it. The unselected Branch
D grants no deletion authority. Any later lifecycle action requires a new
exact approval.
