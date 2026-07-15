# Q004 Closeout — Test-GPO Backup And Restore

**Completed:** 2026-07-14
**Result:** PASS
**Measured restore time:** 0.1 minutes against a 30-minute objective
**Final live state:** Original two-GPO domain state restored

## Outcome

I proved that I can back up the current Group Policy set, restore one exact
known-good custom-GPO backup after a harmless fault, verify the restored
setting with Group Policy Modeling, and remove the disposable object without
changing either canonical default policy or applying policy to a client.

The retained run is `C:\GPO-Backups\Q004\20260714T233623Z`. The test GPO kept
GUID `b6a59828-e00b-4228-b285-b4a2a08f2909` through fault and restore. Backup
ID `2c5ab818-6893-4ed7-b942-8e403e5b4b3e` returned its marker from
`Q004-FAULT-INJECTED` to `Q004-BASELINE` in 0.1 minutes.

## Evidence

- The baseline and restored XML reports contain `Q004-BASELINE`; the fault
  report contains `Q004-FAULT-INJECTED` on the same GPO GUID.
- GPMC modeling for the disabled Quarantine test user reports successful
  Group Policy Infrastructure and Registry processing and names
  `Q004-GPO-Restore-Test` as the winning source for the baseline marker.
- Verify and Cleanup both passed. Final read-only checks found zero test GPOs,
  zero direct Quarantine links, zero enabled users in the Quarantine subtree,
  both protected defaults, and zero replication failures on both DCs.
- The all-GPO backup retained exact backup identities for the custom GPO and
  both default policies. The defaults were backup-only and were never restore
  targets.

## Exception And Recovery

The first approved Execute run exposed an object-shape bug: this host's
`Microsoft.GroupPolicy.GpoBackup` object returns the backup identifier in
`Id`, not `BackupId`. The script failed before fault injection and removed the
temporary Quarantine link as designed. Read-only inspection confirmed that
the unlinked test GPO remained at the baseline marker and the defaults were
unchanged.

I corrected the property handling, pinned the recovered GUID/path/backup ID in
a separate fail-closed Resume mode, obtained the exact resume approval, and
had Claude independently review that recovery before continuing. The resume,
RSoP verification, and cleanup then passed. A later `.htm` versus `.html`
filename mismatch also failed verification safely; copying the preserved GPMC
report to the expected name resolved it without changing the domain.

## Production Impact And Limitations

No current production configuration remains changed. The temporary GPO was
linked only to Quarantine, whose subtree had no enabled user; no `gpupdate`
ran, no identity or computer moved, and no production OU was linked. The
exercise proves restore of an existing custom GPO and planning-mode RSoP. It
does not prove deleted-GPO recovery, live client processing, DC system-state
restore, or VM restore-to-copy.

## Lessons And Handoff

- Validate the actual property shape of PowerShell module output before a
  change window, especially when a script depends on strict mode.
- Treat report filenames as normalized inputs or accept both `.htm` and
  `.html` while still validating report contents.
- Keep exact backup IDs, GUIDs, manifests, containment, and approval gates
  separate from general all-GPO backups.

Q004 / SIM-B3-GPO-RESTORE is complete. It unlocks Q005 /
SIM-B4-VM-RESTORE, the isolated VM restore-to-copy proof. Starting Q005 and
any live or destructive action remain separate work and authority.
