# Q004 — Test-GPO Backup And Restore

- **Status:** ✅ Complete — 2026-07-14
- **Queue ID:** `Q004 / SIM-B3-GPO-RESTORE`
- **Risk:** `LIVE-LOW` under two exact dated approvals
- **Owner:** Windows Server Business Admin Labs
- **Parent project:** [Project 11 — Backup, Restore, and Disaster Recovery](../)

## Why This Matters

A bad Group Policy change can affect many users or computers at once. Before I
begin Project 05 security-baseline work, I want proof that I can return one
test policy to a known backup without touching either default policy or a
production OU.

Q004 uses one custom GPO, the existing Quarantine OU—which currently has no
direct GPO link—and Group Policy Modeling. It does not run `gpupdate`, move a
computer, enable a user, or apply a policy to a production workstation.

## Portfolio Summary

**Situation:** The domain currently has only the two default GPOs, while later
Windows security work needs a tested rollback method.

**Task:** Back up the current GPO set, create and back up one disposable GPO,
inject a harmless test-only change, restore the exact known-good backup, and
use RSoP planning data to prove the restored setting would win.

**Action:** I backed up all three GPOs present during the test, faulted only the
disposable custom GPO, restored its exact known-good backup, proved the
restored marker with Group Policy Modeling, then removed its link and object.

**Result:** PASS. The restore completed in 0.1 minutes. Final verification
found only the two canonical default GPOs, no Quarantine link, no enabled
Quarantine user, and clean replication on both DCs.

## How To Read This Project

| Reader | Start here |
|---|---|
| Hiring manager or non-technical reader | [Portfolio Summary](#portfolio-summary), [What I Proved](#what-i-proved), and [Phase 7 proof](#phase-7--rsop-verification) |
| Technical reviewer | [Sanitized transcript](evidence/q004-sanitized-transcript.txt), [GPO reports](evidence/reports/), [RSoP report](evidence/reports/q004-rsop-modeling.html), and [PowerShell script](scripts/q004-gpo-backup-restore.ps1) |
| Future operator | [Change window](docs/q004-change-window.md), [rollback plan](docs/q004-rollback-plan.md), and [closeout](evidence/q004-closeout.md) |

## My Test Boundary

| Item | Value used |
|---|---|
| GPO | `Q004-GPO-Restore-Test` |
| Link target | `OU=Quarantine,DC=Chongong,DC=local` |
| Setting | `HKCU\Software\Policies\Chongong\Q004\RestoreMarker` |
| Baseline / fault | `Q004-BASELINE` / `Q004-FAULT-INJECTED` |
| Modeling user | Existing disabled `q003-restore-0713` |
| Modeling computer location | `OU=Workstations,OU=ManagedComputers,DC=Chongong,DC=local` |
| Backup root | Existing `C:\GPO-Backups` directory |

Before execution, I required the precheck to prove that every user anywhere in
the Quarantine subtree was disabled before the GPO could be linked.

## Phase Status

| Phase | Work | Status |
|---:|---|---|
| 0 | Queue/dependency/review-lock reconciliation | Complete |
| 1 | Domain, GPO, OU, module, storage, and replication discovery | Complete |
| 2 | Simulation and evidence design | Complete |
| 3 | Backup, change window, rollback, and stop conditions | Complete |
| 4 | Create/configure custom GPO | Complete |
| 5 | Back up and inject harmless fault | Complete after contained resume |
| 6 | Restore exact test-GPO backup | Complete — 0.1 minutes |
| 7 | Group Policy Modeling / RSoP verification | Complete |
| 8 | Unlink/remove only the disposable GPO | Complete |
| 9 | Evidence, review, state propagation, closeout | Complete |

## Why I Kept The Test GPO During Restore

The older parent Project 11 example deleted the test GPO before calling
`Restore-GPO`. Current Microsoft documentation says the PowerShell cmdlet
fails when the original GPO no longer exists. I therefore tested the
supported rollback path: keep the disposable GPO, inject a bad value, and
restore the exact backup by `BackupId`. Deleted-GPO recovery through GPMC
Manage Backups is a separate exercise.

## Phase 0 — Queue And Safety Reconciliation

**Status:** Complete

**What I did:** I confirmed Q004 was the selected queue item and reconciled its
dependencies, review lock, and live-change boundary.

**How I did it:** I compared the central queue, repository state, Q003
closeout, and review records before designing any change.

**Result:** Q004 had a clear scope and no unresolved dependency that allowed a
different project to start first.

**Connection to the next phase:** This gate authorized read-only discovery,
not a live GPO change.

**Details:** [Simulation run sheet](docs/q004-simulation-run-sheet.md)

## Phase 1 — Domain And Replication Discovery

**Status:** Complete

**What I did:** I inspected the domain, both writable domain controllers, the
existing GPOs, Quarantine OU, storage, and replication health.

**How I did it:** I used read-only Active Directory, Group Policy, service, and
`repadmin` queries. I checked WIN-DC02 directly after an earlier remote-path
failure.

**Result:** ADWS was running, replication had zero failures, the domain had
only its two default GPOs, and the Quarantine subtree had no enabled user.

**Connection to the next phase:** Healthy services and an empty isolated link
target allowed me to design a disposable simulation.

**Details:** [Read-only discovery](evidence/q004-read-only-discovery-2026-07-14.txt)

## Phase 2 — Simulation And Evidence Design

**Status:** Complete

**What I did:** I designed one disposable custom GPO, one harmless registry
marker, an isolated modeling scope, and evidence for every safety claim.

**How I did it:** I mapped baseline, fault, restore, RSoP, cleanup, and manifest
artifacts before execution.

**Result:** The test could prove restore behavior without applying policy to a
production computer or enabled user.

**Connection to the next phase:** The evidence design defined the backup,
stop-condition, and rollback requirements.

**Details:** [Evidence plan](docs/q004-evidence-plan.md)

## Phase 3 — Change Window And Rollback Controls

**Status:** Complete

**What I did:** I documented the exact approved actions, protected objects,
prechecks, stop conditions, containment, and rollback path.

**How I did it:** I used a dated change window and separate rollback plan, then
had Claude independently review the plan before live execution.

**Result:** The two default GPOs were protected by exact IDs and unchanged
version/time guards. Any failed gate stopped the script.

**Connection to the next phase:** Leonel's approval and the passing controls
allowed creation of the disposable GPO.

**Details:** [Change window](docs/q004-change-window.md), [rollback plan](docs/q004-rollback-plan.md), and [Claude pre-execution review](evidence/q004-claude-preexecution-review-2026-07-14.md)

## Phase 4 — Baseline Backup And Disposable GPO

**Status:** Complete

**What I did:** I passed the precheck, backed up the current policies, created
`Q004-GPO-Restore-Test`, and wrote the baseline marker.

**How I did it:** I ran the fail-closed PowerShell script from the PDC under a
supervised administrator session.

**Result:** The dated run held backups for both default policies and the
separate known-good custom-GPO backup.

**Connection to the next phase:** The exact custom backup ID established the
known-good state required before fault injection.

**Details:** [Backup inventory](evidence/q004-backup-inventory.txt) and [fail-closed script](scripts/q004-gpo-backup-restore.ps1)

## Phase 5 — Harmless Fault And Containment

**Status:** Complete after contained resume

**What I did:** I changed only the disposable marker to
`Q004-FAULT-INJECTED`. The first execution then stopped on an unexpected
PowerShell backup-object property.

**How I did it:** I preserved the run directory, removed the direct test link,
verified the default policies were unchanged, and wrote a state-specific resume
addendum before continuing.

**Result:** The failure was contained. No default GPO changed, no policy was
applied to a client, and the exact backup remained available.

**Connection to the next phase:** The containment proof and resume gate made it
safe to restore the known-good backup without repeating earlier mutations.

**Details:** [Execute attempt incident](evidence/q004-execute-attempt1-incident-2026-07-14.md) and [contained-state resume addendum](docs/q004-resume-addendum-2026-07-14.md)

## Phase 6 — Exact Backup Restore

**Status:** Complete — 0.1 minutes

**What I did:** I restored the same disposable GPO GUID from its exact
known-good `BackupId`.

**How I did it:** I used the guarded resume path, then checked the restored
registry marker and default-policy invariants.

**Result:** The marker returned to `Q004-BASELINE` in 0.1 minutes while both
default policies remained unchanged.

**Connection to the next phase:** The restored value was ready for independent
Group Policy Modeling verification.

**Details:** [Restored GPO report](evidence/reports/q004-restored.xml) and [sanitized transcript](evidence/q004-sanitized-transcript.txt)

## Phase 7 — RSoP Verification

**Status:** Complete

**What I did:** I modeled the restored GPO for the disabled Quarantine user and
the Workstations computer container.

**How I did it:** I used Group Policy Management's Modeling Wizard and saved
the resulting RSoP report with the run evidence.

**Result:** Modeling showed `Q004-BASELINE` and named the disposable restored
GPO as the winning source. This was planning proof, not live policy application.

**Connection to the next phase:** The restored result was proven, so the test
link and GPO could be safely removed.

**Details:** [RSoP modeling report](evidence/reports/q004-rsop-modeling.html)

### Restored Marker And Winning GPO

<p><strong>Proof:</strong> Group Policy Modeling shows <code>Q004-BASELINE</code> and names the restored disposable GPO as the winning source.</p>

<img src="screenshots/phase7-01-q004-rsop-restored-policy.png" alt="Restored Q004 baseline marker and winning GPO" width="900">

### Isolated Modeling Scope

<p><strong>Proof:</strong> The model uses the disabled Quarantine test user, reports successful Group Policy processing, and applies only the captured test-GPO GUID.</p>

<img src="screenshots/phase7-02-q004-rsop-modeling-scope.png" alt="Q004 isolated Quarantine modeling scope and applied GPO" width="900">

## Phase 8 — Disposable GPO Cleanup

**Status:** Complete

**What I did:** I removed the Quarantine link and deleted only the disposable
custom GPO after the restore proof was complete.

**How I did it:** I ran the script's cleanup mode and checked the remaining GPO
count, direct links, protected IDs, users, and replication.

**Result:** Only the two canonical default GPOs remained. Quarantine had no
direct link, and the retained backup/evidence path remained intact.

**Connection to the next phase:** The clean final state allowed evidence review
and project closeout.

**Details:** [Final live state](evidence/q004-final-live-state-2026-07-14.txt)

## Phase 9 — Evidence Review And Closeout

**Status:** Complete

**What I did:** I sanitized the transcript, collected reports and screenshots,
generated an integrity manifest, reconciled status, and closed Q004.

**How I did it:** I checked the final live state against the evidence set and
had Claude independently review the completed package.

**Result:** The final review found the restore proof, containment, cleanup, and
documentation sufficient for Q004 completion.

**Connection to the next phase:** Q004 has no next phase. Its verified rollback
method is an entry condition for later GPO security-baseline work.

**Details:** [Closeout](evidence/q004-closeout.md), [evidence manifest](evidence/q004-evidence-manifest.sha256), and [Claude final review](evidence/q004-claude-final-review-2026-07-14.md)

## What I Proved

- `Backup-GPO -All` records both canonical default GPOs without restoring them.
- The disposable GPO receives a separate known-good backup ID.
- The fault marker is observed, then the same GPO GUID returns to the baseline
  marker within 30 minutes.
- Default-policy IDs, versions, and modification times remain unchanged.
- The link is limited to Quarantine, is not enforced, and no user in that
  subtree is enabled.
- Group Policy Modeling names the custom GPO as the winning source for the
  restored marker.
- Cleanup removes only the test link and custom GPO; backup/evidence remain.

## Technical Evidence

- [Read-only discovery](evidence/q004-read-only-discovery-2026-07-14.txt)
- [Read-only precheck attempts](evidence/q004-precheck-2026-07-14.txt)
- [Claude pre-execution review](evidence/q004-claude-preexecution-review-2026-07-14.md)
- [Execute attempt 1 incident](evidence/q004-execute-attempt1-incident-2026-07-14.md)
- [Sanitized execution transcript](evidence/q004-sanitized-transcript.txt)
- [Backup inventory](evidence/q004-backup-inventory.txt)
- [Run state](evidence/q004-run-state.json)
- [SHA-256 evidence manifest](evidence/q004-evidence-manifest.sha256)
- [Baseline report](evidence/reports/q004-baseline.xml)
- [Fault report](evidence/reports/q004-fault.xml)
- [Restored report](evidence/reports/q004-restored.xml)
- [RSoP modeling report](evidence/reports/q004-rsop-modeling.html)
- [Final live state](evidence/q004-final-live-state-2026-07-14.txt)
- [Closeout](evidence/q004-closeout.md)
- [Claude final evidence review](evidence/q004-claude-final-review-2026-07-14.md)
- [Simulation run sheet](docs/q004-simulation-run-sheet.md)
- [Change window](docs/q004-change-window.md)
- [Contained-state resume addendum](docs/q004-resume-addendum-2026-07-14.md)
- [Rollback plan](docs/q004-rollback-plan.md)
- [Evidence plan](docs/q004-evidence-plan.md)
- [Fail-closed script](scripts/q004-gpo-backup-restore.ps1)

## How We Worked Together

### My Input And How I Helped

I approved the two dated live-change windows. I ran the supervised PowerShell
and Group Policy Management steps, supplied command output, and provided the
two reviewed RSoP screenshots. I have no remaining Q004 action.

### What Codex Did And How

Codex designed and revised the guarded PowerShell workflow, interpreted each
returned result, contained the first execution failure, and assembled the
evidence-backed project record. The exact execution and recovery sequence is in
the [sanitized transcript](evidence/q004-sanitized-transcript.txt) and
[resume addendum](docs/q004-resume-addendum-2026-07-14.md).

### What Claude Did And How

Claude independently challenged the plan before execution and reviewed the
final evidence after cleanup. Its findings are in the
[pre-execution review](evidence/q004-claude-preexecution-review-2026-07-14.md)
and [final evidence review](evidence/q004-claude-final-review-2026-07-14.md).

### How We Communicated And Completed The Project

I returned each console result and screenshot after the matching gate. Codex
used that evidence to select the next safe step, and Claude reviewed the plan
and final package without expanding the approved scope. The
[closeout](evidence/q004-closeout.md) records the completed result.

### Pushback And How We Resolved It

The first concern was that WIN-DC02 ADWS needed repair. Direct service, ADWS,
and replication checks showed it was healthy; the earlier failure was a remote
execution-path problem, so I made no service change. The first Execute run then
stopped because a backup result lacked the expected `BackupId` property. Codex
kept the change contained, corrected the backup-ID handling, and used a guarded
resume instead of restarting the mutation. The first Verify attempt expected
an `.html` filename that GPMC had saved differently; I preserved the RSoP proof,
normalized the evidence filename, and completed cleanup without applying the
GPO to a client.

## Reproduce Or Re-Verify

1. Treat this as historical proof. Do not repeat the live simulation without a
   new dated approval and the same isolated boundary.
2. Review the [change window](docs/q004-change-window.md), [simulation run sheet](docs/q004-simulation-run-sheet.md), and [rollback plan](docs/q004-rollback-plan.md).
3. Use the [fail-closed script](scripts/q004-gpo-backup-restore.ps1) only from an
   approved administrator session after its precheck passes.
4. Compare the generated reports with the [baseline](evidence/reports/q004-baseline.xml), [fault](evidence/reports/q004-fault.xml), [restored](evidence/reports/q004-restored.xml), and [RSoP](evidence/reports/q004-rsop-modeling.html) evidence.
5. Verify cleanup through the script's cleanup mode and the checks documented
   in the [final live state](evidence/q004-final-live-state-2026-07-14.txt).

## What Happens Next

Q004 is closed. The disposable GPO and Quarantine link are absent, both default
policies passed unchanged guards, and the retained backups/evidence remain at
the dated run path. Q005 / SIM-B4-VM-RESTORE is the next queue item; this
closeout does not start or authorize it.
