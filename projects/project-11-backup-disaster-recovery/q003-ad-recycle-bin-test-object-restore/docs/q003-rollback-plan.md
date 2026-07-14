# Rollback Plan — Q003 AD Recycle Bin Test-Object Restore

- **Written:** 2026-07-13
- **Paired change:** [`q003-change-window.md`](q003-change-window.md)
- **Recovery boundary:** One new disabled test user; no existing identity

## Pre-Change State

Before execution, neither the approved live identity nor a matching restorable
deleted identity may exist. The Quarantine OU, both writable DCs, healthy
replication, and enabled Recycle Bin scope must already exist.

## Rollback Ladder

### Before The Test Object Is Created

Any failed precheck means no mutation occurs. Record the failed gate and stop.

### After Creation But Before Deletion

The object is disabled, passwordless, non-privileged, and already in
Quarantine. If its baseline or cross-DC replication fails, leave it disabled
in Quarantine and stop. Do not delete it merely to make the test look clean.

### After Deletion But Before Restore

The deleted object is the expected recovery source, not a production outage.
Query only the captured GUID with `-IncludeDeletedObjects`. Restore only when
its GUID, `lastKnownParent`, `msDS-LastKnownRDN`, and restorable state match the
approved baseline.

If those guards fail, leave the disposable object in Deleted Objects, preserve
the transcript, and stop. Do not recreate the same name, delete another
object, force replication, or attempt directory metadata repair.

### After Restore

If the object returns with an unexpected enabled state, location, description,
SID, primary group, or explicit group membership:

1. disable the exact restored GUID if it is enabled;
2. move that exact GUID to the confirmed Quarantine OU only if it is elsewhere
   and replication is healthy;
3. capture both-DC read-only evidence;
4. stop and open a review item; and
5. do not delete it again.

The prepared script normally restores directly to the original Quarantine OU,
so steps 1 and 2 are contingency actions, not routine cleanup.

### Replication Anomaly

If one DC shows a different state:

1. stop all object mutation;
2. retain the exact GUID and timestamps;
3. run `repadmin /replsummary` and `repadmin /showrepl <DC> /errorsonly`;
4. wait for normal convergence within the approved 30-minute RTO; and
5. if divergence remains, classify Q003 as partial/rolled back and open a
   separate AD replication investigation.

Do not run `repadmin /syncall`, `Sync-ADObject`, authoritative restore, DSRM,
metadata cleanup, FSMO action, system-state restore, or checkpoint restore
under this change window.

## Restore-From-Backup Boundary

There is no DC-level restore path in Q003. Q002 records recurring Windows
system-state coverage as unconfirmed, and restoring a DC to recover one new
disposable user would increase risk dramatically. If a production directory
anomaly appears, stop Q003 and create a separately approved incident/recovery
plan.

## Post-Rollback Validation

The safe contained state is one of:

- no mutation occurred;
- the test user is disabled in Quarantine;
- the exact disposable GUID remains in Deleted Objects with no production
  impact; or
- the same GUID is restored, disabled, and quarantined but Q003 remains open
  because verification did not fully pass.

In every state, verify both DCs read-only, confirm replication health, confirm
no explicit membership on the test identity, and record the result honestly.

## Who Can Act

Claude may execute only the approved script through the supervised Windows
path. Leonel can stop the window at any time. Any contingency mutation beyond
disable/move of the exact GUID requires Leonel's fresh approval.
