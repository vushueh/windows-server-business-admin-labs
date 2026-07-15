# Change Window — Q004 Test-GPO Backup And Restore

- **Date/time:** Approved and completed 2026-07-14
- **Impact:** None expected
- **Approved by Leonel:** `Q004-20260714-LEONEL`
- **Executor:** Claude runs the reviewed script through PDC LAN SSH; Leonel
  performs the GPMC modeling step; Codex verifies evidence
- **Systems:** `Chongong.local` through `WIN-PRQD8TJG04M`, with replication
  checked through `WIN-DC02`
- **Risk:** `LIVE-LOW`
- **Script:** [`../scripts/q004-gpo-backup-restore.ps1`](../scripts/q004-gpo-backup-restore.ps1)
- **Rollback:** [`q004-rollback-plan.md`](q004-rollback-plan.md)
- **Contained resume:** [`q004-resume-addendum-2026-07-14.md`](q004-resume-addendum-2026-07-14.md)

## Objective And Scope

Restore one deliberately faulted custom GPO from an exact known-good backup
and verify the result with RSoP planning data.

| Item | Exact scope |
|---|---|
| GPO | `Q004-GPO-Restore-Test` |
| Target | `OU=Quarantine,DC=Chongong,DC=local`; enabled, non-enforced link |
| Policy | `HKCU\Software\Policies\Chongong\Q004\RestoreMarker` |
| Values | baseline `Q004-BASELINE`; fault `Q004-FAULT-INJECTED` |
| Modeling | disabled `q003-restore-0713`; Workstations OU as simulated computer location |
| Backup | existing `C:\GPO-Backups\Q004\<UTC timestamp>` |
| RTO | 30 minutes from fault injection to verified restore |

No user, computer, group, or OU is created, enabled, disabled, moved, renamed,
or deleted. No `gpupdate` runs. Neither default policy is modified or restored.

## Protection

1. Capture IDs, versions, status, and modification times for both defaults.
2. Run `Backup-GPO -All`; require both canonical default GUIDs in the result.
3. Back up the known-good custom GPO separately and capture its exact
   `BackupId`.
4. Save baseline, fault, and restored XML reports plus run-state JSON.
5. Treat deep DC recovery as out of scope; never restore a checkpoint or
   system state for this disposable object.

## Prechecks

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\q004-gpo-backup-restore.ps1 -Mode Precheck
```

The script must confirm the exact host/domain/PDC, two writable DCs, clean
replication without operational errors, online SYSVOL/NETLOGON, required
cmdlets, exactly two canonical pre-Q004 GPOs and links, no test-name collision,
an unlinked Quarantine OU with zero enabled users anywhere in its subtree, the
disabled Q003 modeling identity, existing backup root, and at least 1 GB free.

The preliminary SSH query showed 0/5 replication failures but operational
error 110 when the public-key session tried to query WIN-DC02. Leonel then
proved from an interactive domain Administrator session that ADWS is Running/
Automatic, direct ADWS queries succeed, partner results are zero, current
failures are absent, and `repadmin` is clean. No repair was required. Execute
the script only from that interactive context and require a completely passing
fresh precheck.

## Approval Gate

After the precheck and Claude review pass, Leonel must approve this exact
dated statement:

> I approve `Q004-YYYYMMDD-LEONEL` for Claude to back up all current GPOs;
> create, configure, link, fault, and restore only
> `Q004-GPO-Restore-Test` at the existing Quarantine OU; and, after RSoP
> verification, unlink and remove only that disposable GPO. Default policies,
> production OUs, identities, and computers remain out of scope. Stop on any
> mismatch.

Leonel supplied the exact `Q004-20260714-LEONEL` ID after the interactive
precheck passed. That ID now replaces the script's closed placeholder.

## Supervised Transcript

After approval, keep one PowerShell session open for the execution, manual
GPMC modeling pause, verification, and cleanup. Start the transcript before
`Execute` and stop it after cleanup or any stop condition:

```powershell
$TranscriptRoot = 'C:\GPO-Backups\Q004'
New-Item -ItemType Directory -Path $TranscriptRoot -Force | Out-Null
$TranscriptPath = Join-Path $TranscriptRoot `
  ("q004-supervised-{0}.txt" -f (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ'))
Start-Transcript -Path $TranscriptPath -Force

# Run Execute below. Keep this session open while Leonel saves the GPMC model,
# then run Verify and Cleanup below. On completion or stop:
# Stop-Transcript
```

The raw transcript remains server-side until it is reviewed, redacted, and
copied to `evidence/q004-sanitized-transcript.txt`.

## Execution

```powershell
# Backup, custom GPO, fault, and exact restore.
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\q004-gpo-backup-restore.ps1 -Mode Execute `
  -ApprovalId Q004-YYYYMMDD-LEONEL
```

After `Q004_RESTORE=PASS`, Leonel opens **Group Policy Management**, runs the
**Group Policy Modeling Wizard**, selects `Chongong.local` and the PDC, the
disabled Q003 user in Quarantine, and the Workstations OU as the computer
location. Keep normal link/group/site/WMI/loopback choices. Confirm the custom
GPO wins `RestoreMarker=Q004-BASELINE`, then save:

```text
<run path>\q004-rsop-modeling.html
```

```powershell
# Read-only report/live-state validation.
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\q004-gpo-backup-restore.ps1 -Mode Verify `
  -RunPath '<path printed by Execute>'

# Approved cleanup after Verify passes.
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\q004-gpo-backup-restore.ps1 -Mode Cleanup `
  -RunPath '<path printed by Execute>' `
  -ApprovalId Q004-YYYYMMDD-LEONEL
```

## Stop Conditions

Stop on any failed precheck, collision, enabled Quarantine user, unexpected
GPO/link, incomplete backup, replication/SYSVOL/NETLOGON problem, absent
approval, default-policy change, credential prompt, RTO breach, or evidence
leak. If restore fails after fault injection, remove only the captured test
link as containment, leave the custom GPO unlinked for investigation, and do
not improvise or restore another backup.

## Outcome

PASS. The first Execute attempt stopped before fault injection on a
`GpoBackup.Id`/`BackupId` object-shape mismatch and removed the temporary link.
After a separately approved, independently reviewed Resume, the exact custom
backup restored the baseline marker in 0.1 minutes. RSoP and cleanup passed;
the disposable GPO/link are absent, defaults are unchanged, and backups remain.

## Microsoft References

- <https://learn.microsoft.com/powershell/module/grouppolicy/backup-gpo>
- <https://learn.microsoft.com/powershell/module/grouppolicy/restore-gpo>
- <https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-backup-restore>
- <https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-modeling-results>
