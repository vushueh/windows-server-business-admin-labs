# Rollback Plan — Q004 Test-GPO Backup And Restore

**Written:** 2026-07-14
**Paired change:** [`q004-change-window.md`](q004-change-window.md)

## Starting State

Exactly the two canonical default GPOs exist, and Quarantine has no direct GPO
link. Q004 changes only one new custom GPO and its one Quarantine link.

## Triggers

- Precheck/backup incomplete, wrong GUID/target/enforcement, or enabled
  Quarantine user.
- Known-good backup ID absent, marker mismatch, restore failure/RTO breach.
- Default-policy, replication, SYSVOL, NETLOGON, or RSoP discrepancy.

## Rollback Ladder

1. **Before creation:** stop; no mutation occurred.
2. **Created but unlinked:** leave the custom GPO unlinked for inspection.
3. **Linked before fault:** remove only the captured Q004 link; leave GPO.
4. **Fault injected:** attempt the captured backup ID once. If restore fails,
   remove only the Q004 link, retain GPO/backup/reports, and stop.
5. **Restored before RSoP:** if GUID, baseline marker, link, and defaults are
   correct, it may remain briefly for modeling; otherwise unlink and stop.
6. **Cleanup:** unlink first. If unlink fails, do not remove the GPO. If GPO
   removal fails after unlink, the remaining unlinked GPO is safe.

Only the custom GPO is restored. The all-GPO backup is a recovery floor, not
permission to restore defaults. Never force replication, refresh production
clients, restore system state, or restore a DC checkpoint under Q004.

After containment, verify canonical defaults, root/DC-OU links, Quarantine
enabled-user count, replication, SYSVOL, and NETLOGON. Any broader anomaly
becomes a separately approved incident/recovery task.
