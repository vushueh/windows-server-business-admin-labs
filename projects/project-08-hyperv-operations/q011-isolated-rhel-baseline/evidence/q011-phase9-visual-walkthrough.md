# Q011 Phase 9 — Retention Visual Walkthrough

These two reviewed GUI screenshots prove the final hands-on retention choice
without exposing unrelated VM inventory.

## 1. Retained VM Is Off

The tightly cropped Hyper-V Manager row shows only
`Q011-RHEL102-BASELINE` and state `Off`. The read-only structured result
supplies the remaining host-side retention fields.

<img src="screenshots/q011-phase9-01-retained-vm-off.png" alt="Hyper-V Manager Q011 row showing the retained VM Off" width="900">

## 2. Retained Adapter Is Not Connected

The Q011 Settings window shows its single Network Adapter with Virtual switch
`Not connected` and virtual LAN identification unchecked. No setting was
changed or applied.

<img src="screenshots/q011-phase9-02-retained-network-isolation.png" alt="Q011 Hyper-V Network Adapter retained Not connected with VLAN identification disabled" width="900">

## Claim Boundary

The images prove the displayed retained GUI state. The
[searchable results](q011-phase9-sanitized-results.txt) prove the full
read-only gate, including VHDX/media presence and
`Phase9RetentionPass=True`. Neither source proves internal VHDX integrity,
backup/restore, a replayed rebuild, or production readiness.
