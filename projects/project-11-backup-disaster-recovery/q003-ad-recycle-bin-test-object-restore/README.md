# Q003 — AD Recycle Bin Test-Object Restore

- **Status:** ✅ Complete — 2026-07-14
- **Queue ID:** `Q003 / SIM-W2-AD-RESTORE`
- **Risk:** `LIVE-LOW` under one exact dated approval
- **Owner:** Windows Server Business Admin Labs
- **Scope:** `Chongong.local`; one new disabled test user
- **Parent project:** [Project 11 — Backup, Restore, and Disaster Recovery](../)

## Why This Matters

An accidental Active Directory deletion can remove a user and its unique
identity from normal administration views. I wanted proof that I could recover
one deleted object safely without using a real identity or restoring an entire
domain controller.

Q003 is a focused recovery exercise. It proves one part of Project 11, but it
does not start or complete the full backup and disaster-recovery project.

## Portfolio Summary

**Situation:** AD Recycle Bin was enabled, but I did not yet have a measured
restore test showing the same object could return safely through both domain
controllers.

**Task:** Create one disposable disabled user, capture its identity, delete only
that captured object, restore it within 30 minutes, and prove no real identity
or production service was affected.

**Action:** I used a fail-closed PowerShell workflow with fresh domain and
replication prechecks, a GUID-pinned delete, `Restore-ADObject`, and independent
readback from both writable domain controllers.

**Result:** PASS. The same GUID and SID returned in 0.51 minutes. The user
remained disabled in Quarantine with no explicit group membership, and both
domain controllers reported the same restored state.

## How To Read This Project

| Reader | Start here |
|---|---|
| Hiring manager or non-technical reader | [Portfolio Summary](#portfolio-summary), [What I Proved](#what-i-proved), and [Phase 5 proof](#phase-5--both-dc-verification) |
| Technical reviewer | [Change window](docs/q003-change-window.md), [PowerShell script](scripts/q003-ad-recycle-bin-test.ps1), and [sanitized transcript](evidence/q003-sanitized-transcript.txt) |
| Future operator | [Rollback plan](docs/q003-rollback-plan.md), [closeout](evidence/q003-closeout.md), and [Reproduce Or Re-Verify](#reproduce-or-re-verify) |

## My Test Boundary

| Item | Approved value |
|---|---|
| Test identity | `Q003 Restore Test 2026-07-13` |
| `sAMAccountName` | `q003-restore-0713` |
| Starting and final location | `OU=Quarantine,DC=Chongong,DC=local` |
| Enabled state | `False` |
| Password | None set |
| Explicit group membership | None |
| Restore target | Exact captured object GUID only |
| Verification | `WIN-PRQD8TJG04M` and `WIN-DC02` |
| Recovery objective | 30 minutes |
| Approval | `Q003-20260714-LEONEL` |

The standing no-delete rule remained in force for every existing AD object.
This window allowed one narrowly named disposable-object exception. I did not
modify either default GPO, force replication, restore a checkpoint, or use a
real user, group, computer, or OU.

## Phase Status

| Phase | Work | Status |
|---:|---|---|
| 1 | Scope, change window, rollback, and script design | Complete |
| 2 | Fresh Recycle Bin, DC, replication, OU, and collision precheck | Complete — `Q003_PRECHECK=PASS` |
| 3 | Independent challenge and exact approval gate | Complete — 2026-07-14 |
| 4 | Create, baseline, delete, and restore the captured GUID | Complete |
| 5 | Verify identity, attributes, location, timing, and both DCs | Complete — 0.51 minutes |
| 6 | Retain the safe disabled state, review evidence, and close | Complete |

## Phase 1 — Scope, Change Window, And Script Design

I started by limiting the exercise to one new, disabled, passwordless test user
in the existing Quarantine OU. The [change window](docs/q003-change-window.md)
defined the recovery objective, protected objects, approval gate, and exact
stop conditions, while the [rollback plan](docs/q003-rollback-plan.md) covered
every point before and after deletion. I then encoded those controls in a
[fail-closed PowerShell script](scripts/q003-ad-recycle-bin-test.ps1). With the
scope and recovery ladder written first, I could test the environment without
improvising a live change.

## Phase 2 — Fresh Read-Only Precheck

I ran the script's read-only precheck from my authenticated PDC console because
the available SSH session could not delegate my domain credential to WIN-DC02.
The checks covered both writable DCs, Recycle Bin scope, deleted-object
lifetime, Quarantine, name collisions, and replication health. They also
exposed two implementation details: a historical record with
`FailureCount=0`, and native status `234` for otherwise clean
`repadmin /showrepl ... /errorsonly` output on both DCs. I corrected the script
to accept only the evidence-backed safe cases, and the saved
[precheck](evidence/q003-precheck-2026-07-14.txt) ended
`Q003_PRECHECK=PASS`. That clean result made the approval decision possible.

## Phase 3 — Independent Challenge And Approval

Before any mutation, Claude challenged the plan and identified four missing
guards: document the Quarantine OU, pin deletion to a captured GUID, separate
deleted-object lifetime from tombstone lifetime, and verify the same restored
object through both DCs. I incorporated those findings into the plan and
script, and the [repository review record](../../../CLAUDE-REVIEW.md) preserved
the resolution. I then approved the one named exception as
`Q003-20260714-LEONEL`. That approval authorized only the reviewed disposable
user and allowed the execution phase to begin.

## Phase 4 — Create, Delete, And Restore By GUID

Under the approved window, the script created `q003-restore-0713` disabled in
Quarantine and captured its GUID, SID, location, description, and membership
baseline. It waited until both DCs reported the same GUID before deleting only
that captured object. The workflow then checked the deleted record's
`lastKnownParent` and `msDS-LastKnownRDN` before calling
`Restore-ADObject -PassThru`. The [execution transcript](evidence/q003-sanitized-transcript.txt)
shows GUID `2386a6b1-8830-4457-bc5f-56da1ac493a1` returned rather than a newly
created replacement. With the original identity live again, I could verify its
full state independently.

## Phase 5 — Both-DC Verification

I read the restored user through `WIN-PRQD8TJG04M` and `WIN-DC02` and compared
the result with the captured baseline. Both DCs agreed on the GUID, SID,
disabled state, Quarantine location, description, primary group, and absence of
explicit membership. The [sanitized transcript](evidence/q003-sanitized-transcript.txt)
measured 0.51 minutes from deletion to verified restore, well inside the
30-minute objective, and ended `Q003_RESULT=PASS`. That matching proof allowed
me to close the live portion without another deletion.

### Both-DC Restore Verification

<p><strong>Proof:</strong> I verified the same restored GUID through both domain controllers, kept the account disabled in Quarantine, and completed the restore in 0.51 minutes.</p>

<img src="screenshots/phase5-02-q003-both-dc-verification.png" alt="Q003 final both-domain-controller restore verification" width="900">

## Phase 6 — Safe Retained State And Closeout

After verification, I kept the restored user disabled in Quarantine instead of
deleting it again merely to make the lab look clean. I reviewed the final state
against the transcript, and Claude independently checked the complete evidence
for safety, consistency, and secrets. The [closeout](evidence/q003-closeout.md)
records the retained object, zero production impact, measured recovery, and
role boundaries. This closed Q003 and handed a tested object-recovery method to
the next restore exercise without claiming that full Project 11 was complete.

## What I Proved

- AD Recycle Bin was enabled and queryable through both writable DCs.
- One disabled disposable user could be deleted and restored by its captured
  GUID rather than by name alone.
- The restored object kept the same GUID, SID, location, description, primary
  group, and explicit-membership state.
- Both domain controllers reported the same restored identity.
- Delete-to-verified-restore time was 0.51 minutes against a 30-minute target.
- No real identity, default policy, DNS, DHCP, NPS, or service configuration
  was changed.
- The safest final state was the restored user disabled in Quarantine, not a
  second deletion.

## Technical Evidence

- [Change window and approval boundary](docs/q003-change-window.md)
- [Rollback plan](docs/q003-rollback-plan.md)
- [Reviewed PowerShell script](scripts/q003-ad-recycle-bin-test.ps1)
- [Fresh passing precheck](evidence/q003-precheck-2026-07-14.txt)
- [Complete sanitized execution transcript](evidence/q003-sanitized-transcript.txt)
- [Plain-language closeout](evidence/q003-closeout.md)
- [Screenshot plan](docs/q003-screenshot-plan.md)
- [Both-DC PASS screenshot](screenshots/phase5-02-q003-both-dc-verification.png)
- [Independent repository review record](../../../CLAUDE-REVIEW.md)

## How We Worked Together

### My Input And How I Helped

I reviewed the exact test identity, Quarantine boundary, recovery objective,
rollback plan, and stop conditions. I ran the final precheck and live script
from my authenticated PDC console, supplied the returned evidence, and gave the
only live-change approval: `Q003-20260714-LEONEL`. I have no remaining Q003
action unless I later approve a separate change to remove the retained test
user.

### What Codex Did And How

Codex acted as the primary assistant. It designed the change window, rollback
ladder, screenshot plan, and PowerShell workflow; diagnosed the failed
precheck assumptions; corrected and revalidated the script; reconciled the
queue; and built the evidence-backed project record. The
[closeout](evidence/q003-closeout.md) records that responsibility in detail.

### What Claude Did And How

Claude independently challenged the safety and verification design, tested the
available SSH paths, reviewed each script correction, verified transferred
script hashes, and inspected the full execution transcript for contradictions
or secrets. Its Q003 findings and resolutions remain in the
[repository review record](../../../CLAUDE-REVIEW.md).

### How We Communicated And Completed The Project

Codex prepared each gate, Claude challenged it, and I returned the console
result after the matching step. Review items Q003-01 and Q003-02 tracked the
precheck, exact approval, execution, independent evidence review, and closeout.
No assistant expanded the approved scope or approved its own live change.

### Pushback And How We Resolved It

Claude initially found four material gaps in the design. I required those
guards to be added before approval. Claude also suggested deleting the test
user again as routine rollback; I chose the safer retained state because a
second delete added risk without proving more recovery value. When SSH could
not delegate my domain credential to WIN-DC02, I used my authenticated PDC
console rather than weakening the both-DC verification requirement.

## Reproduce Or Re-Verify

1. Treat this repository as historical proof. The exact test name is still
   retained, so do not rerun the script unchanged or reuse its approval token.
2. Create a new dated [change window](docs/q003-change-window.md) and
   [rollback plan](docs/q003-rollback-plan.md) with a new unique disabled test
   identity and a new exact approval.
3. Review and update the [PowerShell script](scripts/q003-ad-recycle-bin-test.ps1)
   for that new identity, then run `-Mode Precheck` from an authenticated domain
   session. Stop unless every gate passes.
4. Execute only the newly approved object, capture its GUID before deletion,
   and restore only that GUID with `Restore-ADObject`.
5. Verify the same GUID and safe attributes through both writable DCs, measure
   the recovery time, review the evidence for secrets, and preserve the safest
   contained final state.

## What Happens Next

Q003 is closed. [Q004](../q004-test-gpo-backup-restore/) later completed the
separate test-GPO restore proof. Neither result starts or completes the full
Project 11 program, and neither authorizes the next queue item.
