# Q004 Contained-State Resume Addendum — 2026-07-14

## Why A Resume Is Required

The first approved Execute run completed the all-GPO backup, created the
custom GPO, set its known-good baseline marker, linked it briefly, and created
its dedicated backup. It then stopped before fault injection because the
installed `Microsoft.GroupPolicy.GpoBackup` object exposes the backup
identifier as `Id`, while the draft script checked a nonexistent `BackupId`
property.

Containment removed the Quarantine link. Read-only inspection proves the test
GPO is unlinked and remains at `Q004-BASELINE`; the fault value was never
written. Neither default policy was changed or restored.

## Exact Contained State

| Item | Pinned value |
|---|---|
| Run path | `C:\GPO-Backups\Q004\20260714T233623Z` |
| Test GPO GUID | `b6a59828-e00b-4228-b285-b4a2a08f2909` |
| Test backup ID | `2c5ab818-6893-4ed7-b942-8e403e5b4b3e` |
| Default Domain Policy backup ID | `40a14d4e-ba9a-4274-aeba-6f82e2e662e3` |
| Default DC Policy backup ID | `f09d96b4-6c75-4a84-a7ac-c61732ed56a1` |
| Live test marker | `Q004-BASELINE` |
| Quarantine direct links | zero |
| Fault injected | no |

## Reviewed Recovery

The corrected script uses `GpoBackup.Id` for new executions and adds a locked
`Resume` mode. Resume must parse all three `Backup.xml` manifests, map the
exact test GUID to its exact backup directory, confirm the backup report
contains the baseline marker, require the two defaults plus one unlinked test
GPO, recheck Quarantine/default links/default versions/replication, and create
the missing run-state file before any new mutation.

Only then may it relink the same test GPO, inject the harmless fault, restore
backup ID `2c5ab818-6893-4ed7-b942-8e403e5b4b3e`, and verify both DCs. Any
failure after linking removes only the test link as containment.

Claude independently reviewed the correction and rated it `RESUME-READY` with
no Critical or High finding. The script remains locked until a new exact
approval is recorded.

Leonel supplied exact approval `Q004-20260714-LEONEL-RESUME1` after reviewing
the contained state and recovery scope. The script now accepts only that ID
for `Resume`.

## Exact Resume Approval

> I approve `Q004-20260714-LEONEL-RESUME1` to resume only the contained Q004
> run at `C:\GPO-Backups\Q004\20260714T233623Z`, using only test GPO
> `b6a59828-e00b-4228-b285-b4a2a08f2909` and its exact backup ID
> `2c5ab818-6893-4ed7-b942-8e403e5b4b3e`; relink it only to Quarantine,
> inject/restore only the documented marker, unlink on failure, and proceed to
> RSoP verification and cleanup. The default GPOs remain backup-only and must
> never be restored.

## Stop Conditions

Stop on any GUID/path/manifest/marker/link/default/replication mismatch,
unexpected run-state or fault/restored report, approval mismatch, credential
prompt, restore/RTO failure, or containment failure. Do not delete the
contained GPO or rerun `Execute`.

## Final Outcome

Resume passed using the pinned GUID and backup ID. The fault and restored
reports showed `Q004-FAULT-INJECTED` and `Q004-BASELINE`, respectively, on the
same GPO; restore time was 0.1 minutes. RSoP named the restored custom GPO as
the winning source. Cleanup then removed the link and disposable GPO and left
the retained backup tree intact.
