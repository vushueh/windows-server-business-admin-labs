# Q011 Phase 9 — Retained Baseline Evidence

**Executed:** 2026-07-21  
**Decision:** `RETAIN-Q011`  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Result:** read-only retention gate passed; VM preserved Off and isolated

## Scope And Approval Boundary

Leonel explicitly selected `RETAIN-Q011` and approved only the reviewed
read-only Branch R gate plus two safe Hyper-V screenshots. The window did not
permit starting or changing the VM, VHDX, ISO, adapter, VLAN, switch, network,
OPNsense reservation, Red Hat registration, another system, Git, or GitHub.
The disposal branch was not selected and no delete operation was authorized.

## Read-Only Retention Result

Elevated Windows PowerShell on the Hyper-V host proved:

- host `WIN-PRQD8TJG04M`;
- decision `RETAIN-Q011`;
- VM `Q011-RHEL102-BASELINE` in state `Off`;
- exactly one disconnected adapter;
- exactly one VLAN record in Untagged mode with Access VLAN ID `0`;
- one empty DVD drive;
- the exact Q011 VHDX path attached and present;
- zero checkpoints;
- automatic checkpoints disabled;
- Automatic Start Action `Nothing`;
- exact local RHEL ISO path present with 11,059,986,432 bytes; and
- `Phase9RetentionPass=True`.

The Phase 9 media gate proves path and byte-size retention only. ISO integrity
continues to rest on the matching Phase 4 SHA-256 evidence; the 10.3-GB media
was not rehashed in this window.

## Hands-On GUI Proof

The first cropped Hyper-V Manager capture shows only the selected Q011 row and
state `Off`. The second Q011 Settings capture shows the single Network Adapter
as `Not connected` with virtual LAN identification unchecked. The greyed VLAN
text box is inactive; the authoritative read-only host result returned
`OperationMode=Untagged` and `AccessVlanId=0`.

Both source images were copied byte-for-byte from Downloads. The
[visual walkthrough](q011-phase9-visual-walkthrough.md) places them in the
retention sequence, and the
[screenshot manifest](q011-phase9-screenshots.sha256) records their exact
hashes.

## Final Decision And Boundary

Q011 is complete as a retained verified lab baseline. Its VM/VHDX, DHCP
reservation, Red Hat registration, RPM trust, and shared installation media
remain lifecycle state. No backup/export or replayed rebuild exists.

Starting, connecting, patching, backing up, exporting, cloning, repurposing,
unregistering, or disposing Q011 requires a new exact change window. The
unselected disposal path retains no authority from Phase 9.
