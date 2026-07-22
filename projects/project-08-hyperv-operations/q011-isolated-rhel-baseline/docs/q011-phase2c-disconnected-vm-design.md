# Q011 Phase 2C — Disconnected Hyper-V VM Design

**Mode:** repository-only design  
**Live changes:** none  
**Design state:** frozen, subject to build-time gates

## Design Objective

Create one new Generation 2 Hyper-V VM for a fresh RHEL 10.2 installation,
while preventing the guest from reaching any lab or production network during
installation. The design deliberately uses a local ISO and an unconnected
virtual network adapter.

## Exact Specification

| Control | Frozen value | Reason |
|---|---|---|
| Host | `WIN-PRQD8TJG04M` | Compatible CPU candidate and sufficient discovered capacity |
| VM name | `Q011-RHEL102-BASELINE` | Queue-attributable and unused at discovery time |
| Guest hostname | `q011-rhel01` | Short Linux hostname scoped to this project |
| Generation | 2 | UEFI/Secure Boot support |
| Processor | 2 vCPU | Conservative install/baseline allocation |
| Memory | 6 GiB static | Predictable install state; Dynamic Memory off |
| VHDX | 60 GiB dynamic | Adequate baseline capacity without immediate full allocation |
| VHDX path | `D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx` | Existing host default VHD location |
| ISO path | `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso` | Host-local media avoids install-time NAS dependence |
| Firmware | Secure Boot enabled, `MicrosoftUEFICertificateAuthority` | Linux-compatible Generation 2 Secure Boot template |
| DVD | ISO attached to virtual DVD drive; first boot device for install | Explicit installation media |
| Network | One vNIC, `SwitchName` empty / Not Connected | Hard disconnected boundary |
| Checkpoints | Automatic checkpoints disabled | Avoid opaque install-time state |
| Start action | `Nothing` | Prevent unexpected host-boot start |
| vTPM | Not configured | Not required for this baseline |
| Nested virtualization | Not configured | Not required and outside scope |

`New-VM` creates one unconnected network adapter when no `-SwitchName` is
specified. The build must verify that adapter exists and that its `SwitchName`
is empty. It must not delete the adapter merely to describe the guest as
disconnected.

## Intended Construction Sequence

These commands document the future build, but are **not approved to run** by
Phase 2C:

```powershell
$VmName  = 'Q011-RHEL102-BASELINE'
$VhdPath = 'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'
$IsoPath = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'

New-VM -Name $VmName -Generation 2 `
  -MemoryStartupBytes 6GB `
  -NewVHDPath $VhdPath -NewVHDSizeBytes 60GB

# Defense in depth: keep the one default vNIC but explicitly disconnect it.
Get-VMNetworkAdapter -VMName $VmName | Disconnect-VMNetworkAdapter

Set-VMProcessor -VMName $VmName -Count 2
Set-VMMemory -VMName $VmName `
  -DynamicMemoryEnabled $false -StartupBytes 6GB
Set-VM -Name $VmName `
  -AutomaticCheckpointsEnabled $false `
  -AutomaticStartAction Nothing

Set-VMFirmware -VMName $VmName -EnableSecureBoot On `
  -SecureBootTemplate MicrosoftUEFICertificateAuthority

Add-VMDvdDrive -VMName $VmName -Path $IsoPath
$Dvd = Get-VMDvdDrive -VMName $VmName
$Disk = Get-VMHardDiskDrive -VMName $VmName
Set-VMFirmware -VMName $VmName -BootOrder $Dvd, $Disk
```

The future run sheet must stop if any command would target an existing object.
It must not use `-SwitchName`, `Connect-VMNetworkAdapter`, or `Set-VMNetworkAdapterVlan`.

## Build-Time Preconditions

Immediately before VM creation, an approved read-only preflight must prove:

1. `$env:COMPUTERNAME` is exactly `WIN-PRQD8TJG04M`.
2. `Q011-RHEL102-BASELINE` does not exist.
3. The exact VHDX path does not exist.
4. The exact local ISO exists, is 11,059,986,432 bytes, and matches SHA-256
   `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5`.
5. The exact ISO's `Zone.Identifier`/Windows block state is inspected
   read-only. If a zone stream exists or Hyper-V rejects attachment, stop and
   obtain separate approval before removing or changing that stream.
6. At least 16 GiB physical memory is free before powering on the 6 GiB VM,
   preserving at least 10 GiB of immediate headroom for this multi-role host.
7. Drive `D:` has at least 100 GiB free.
8. Current host CPU load is reviewed and is suitable for an interactive build.
9. No Q011 operation is in progress from another console.

These are safety floors, not a claim that the older discovery remains current.
Because the Hyper-V server also carries critical Windows roles and running
guests, an approved build must stop during high CPU/disk activity, backup work,
pending host maintenance, or another VM operation. The build must not reboot
the host.

## Post-Creation Verification

Before first power-on, a separately approved verification must show:

- Generation 2, Off state, 2 vCPU, 6 GiB startup memory;
- Dynamic Memory and automatic checkpoints disabled;
- exact VHDX and ISO paths;
- Secure Boot on with the Linux-compatible template;
- exactly one vNIC and blank `SwitchName`;
- no snapshot/checkpoint; and
- no configuration change to any other VM.

## Rollback Boundary

If future creation fails before installation begins, stop and inventory only
the exact Q011 VM/VHDX objects. Deletion requires the separately approved build
window's rollback clause or a new approval. Never remove a path based only on a
variable or wildcard, and never touch the source ISO.

## Phase 2C Screenshot Exception

No screenshot is appropriate for this repository-only phase: there is no new
GUI or live state to prove. The first required actual-practice screenshot is
the locally staged ISO in Phase 4A. Phase 4B will require Hyper-V Manager proof
of the frozen disconnected settings.

## Technical References

- [Microsoft `New-VM`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/new-vm)
- [Microsoft `Set-VMProcessor`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vmprocessor)
- [Microsoft `Set-VMMemory`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vmmemory)
- [Microsoft `Set-VMFirmware`](https://learn.microsoft.com/en-us/powershell/module/hyper-v/set-vmfirmware)
- [Microsoft Generation 2 VM security](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/generation-2-virtual-machine-security-features)
