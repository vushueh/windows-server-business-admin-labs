# Q011 Imported Sanitized Discovery Summary

This record imports only the minimum facts needed to design the Hyper-V build.
The original sanitized command evidence remains in the Proxmox predecessor
worktree until coordinated publication. No credential or per-guest
configuration is copied here.

## Media Identity

| Field | Value |
|---|---|
| Filename | `rhel-10.2-x86_64-dvd.iso` |
| Size | 11,059,986,432 bytes |
| Published SHA-256 | `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Computed source SHA-256 | `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Source verification | Pass |

## Proxmox Compatibility Stop

The selected Proxmox node uses Intel Xeon L5520 processors. Its retained CPU
features do not meet the x86-64-v3 level required by RHEL 10. Q011 therefore
stopped before VM creation; the Proxmox path is not a supported RHEL 10.2
execution candidate.

## Hyper-V Candidate Discovery

Read-only, filtered host discovery on `WIN-PRQD8TJG04M` found:

- Windows Server 2022 Datacenter, build 20348;
- dual Intel Xeon E5-2687W v3 processors, 20 cores and 40 logical processors;
- 137,355,468,800 bytes total memory and 40,411,889,664 bytes free at discovery;
- `D:` with 952,591,835,136 bytes free at discovery;
- default VHD path `D:\Hyper-V\Virtual Hard Disks`;
- six switch name/type rows, none selected for Q011;
- 20 host-level VM identity rows and no `Q011-RHEL102-BASELINE` name collision;
- an existing similar RHEL-labelled VM, explicitly outside Q011 scope; and
- `False` for the exact NAS UNC ISO path from the Hyper-V host at discovery.

The capacity values are point-in-time evidence, not build authorization. CPU
load was not captured. Phase 4B must perform a fresh capacity/load/collision
preflight.

## Isolation Finding

VLAN 70 has DHCP service, but the observed policy included a broad first-match
allow path. That evidence does not prove the required isolated-install
boundary. Q011 therefore starts with its single Hyper-V adapter unconnected.

## Evidence Boundary

The Hyper-V discovery used only approved host-level inventory and exact-path
access checks. It did not query an individual VM configuration, open a guest,
stage media, create a VM, change networking, or use credentials. No screenshot
was captured because the phase was command-only; actual GUI screenshots begin
with the first approved hands-on change.
