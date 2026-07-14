# Q003 Screenshot Plan

Screenshots are supporting portfolio proof. The sanitized transcript remains
the exact technical record. Capture only the test object and the relevant
result; crop or redact unrelated identities, notifications, paths, and account
details before saving.

| Filename | When | What it proves | Capture path |
|---|---|---|---|
| `phase2-01-q003-precheck-pass.png` | Before mutation | Recycle Bin, both DCs, Quarantine OU, collision, and replication gates passed | PowerShell window showing only the final sanitized precheck summary |
| `phase4-01-q003-deleted-object.png` | After the approved deletion, before restore | The exact disposable name appears in Deleted Objects | ADAC → `Chongong (local)` → Deleted Objects; filter to `q003-restore-0713` |
| `phase5-01-q003-restored-disabled.png` | After restore | The test identity is restored, disabled, and in Quarantine | ADAC → `Chongong (local)` → Quarantine → test user properties |
| `phase5-02-q003-both-dc-verification.png` | Final verification | The same GUID is readable through both DCs and the run passed | PowerShell window showing only the final sanitized verification summary |

Save reviewed images under `../screenshots/`. Do not add a Markdown image link
until the matching file exists.

## PowerShell Equivalent

The final script output must show the exact GUID, both server names, enabled
state, final DN, group-membership count, elapsed restore time, and
`Q003_RESULT=PASS`. It must not show credentials or unrelated directory data.

## Capture Outcome

The reviewed final image is
[`phase5-02-q003-both-dc-verification.png`](../screenshots/phase5-02-q003-both-dc-verification.png).
It contains the required final fields, fits the project page at 750 pixels, and
does not show credentials or unrelated identities.

I did not pause the automated delete-and-restore workflow to capture the
transient Deleted Objects view. The complete sanitized transcript records the
GUID-pinned deleted-object guard and restore, so I did not repeat the deletion
only to create a screenshot.
