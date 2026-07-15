# Q004 Execute Attempt 1 — Contained Script Failure

## Result

The approved run stopped with exit code 1 before fault injection. The
`GpoBackup` object returned by `Backup-GPO` has backup identifier property
`Id`; the script referenced nonexistent property `BackupId` under strict mode.
Microsoft's documented output shows `GpoId` for the source GPO and `Id` for
the backup: <https://learn.microsoft.com/powershell/module/grouppolicy/backup-gpo>.

## Containment And Read-Only Verification

- `Q004_CONTAINMENT_LINK_REMOVAL=PASS`.
- Test GPO `b6a59828-e00b-4228-b285-b4a2a08f2909` remains present and
  unlinked.
- Its marker remains `Q004-BASELINE`; `Q004-FAULT-INJECTED` was never written.
- Run path `C:\GPO-Backups\Q004\20260714T233623Z` contains the baseline report
  and three backup manifests.
- Test backup ID is `2c5ab818-6893-4ed7-b942-8e403e5b4b3e`.
- The two default backups are present; neither default was changed/restored.
- No run-state, fault report, or restored report existed after the stop.

## Disposition

Do not rerun Execute or manually remove the GPO. Codex corrected the property
mapping and added an exact contained-state Resume path. Windows PowerShell
parsing passed, and Claude independently rated the recovery `RESUME-READY`.
A new exact resume approval remains required.

Leonel subsequently supplied `Q004-20260714-LEONEL-RESUME1`; only the reviewed
contained-state Resume path is authorized.
