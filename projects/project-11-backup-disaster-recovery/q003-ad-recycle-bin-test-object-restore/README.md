# Q003 — AD Recycle Bin Test-Object Restore

- **Status:** ▶ Selected — documentation home created; execution not started
- **Risk:** `LIVE-LOW`
- **Owner:** Windows Server Business Admin Labs
- **Parent project:** [Project 11 — Backup, Restore, and Disaster Recovery](../)
- **Queue dependency:** Q002 complete
- **Completion rule:** I restore and verify one deliberately created test object without affecting a real identity.

## Why I Am Doing This

I am using one disposable, disabled Active Directory test identity to prove
that I can recover an accidentally deleted object safely. This is a small
recovery exercise, not permission to delete an existing user, group, computer,
or OU.

Q003 has its own page because it is an early master-queue recovery proof. It
uses part of Project 11, but it does not start or claim completion of the full
Project 11 backup and disaster-recovery project, which remains Q037.

## Queue Placement

| Position | Work | Status |
|---|---|---|
| Immediate safety preemption | U0-RUNNER-R01 local review package | Planned; its local-only package must close before Q003 preparation resumes |
| Previous numbered item | Q002 backup coverage and restore plan | Complete — 2026-07-13 |
| This item | Q003 AD Recycle Bin test-object restore | Selected; not started |
| Next item | Q004 test-GPO backup and restore | Waiting for Q003 |

## Where The Q003 Record Will Live

This folder is the permanent Q003 home. I will keep the project story on this
page and add the following material here as the project advances:

| Material | Planned location |
|---|---|
| Approved scope, RPO/RTO, pre-checks, backup, rollback, and stop conditions | `docs/q003-change-window.md` |
| Sanitized PowerShell transcript and before/after results | `evidence/` |
| Screenshot plan and reviewed screenshots | `docs/q003-screenshot-plan.md` and `screenshots/` |
| Final verification, cleanup, lessons, and queue handoff | This README and `evidence/q003-closeout.md` |

I will not create empty evidence claims or broken screenshot links. Those
files will be added only when their phase is actually prepared or performed.

## What I Will Do

| Phase | Work | Current state |
|---|---|---|
| 1 | Write the exact test-object scope and change window | Pending |
| 2 | Run fresh read-only checks for Recycle Bin, DC health, replication, test OU, naming, and recovery-point readiness | Pending |
| 3 | Review the named disposable-object exception and obtain Leonel's dated approval | Pending |
| 4 | Create, baseline, delete, and restore only the approved disabled test object | Not approved or started |
| 5 | Verify restored identity, attributes, location, replication, and absence of impact to real identities | Pending |
| 6 | Disable and move the test object to the approved Quarantine location, review evidence, and close Q003 | Pending |

## My Safety Boundary

- I will never use a real identity for this exercise.
- I will not restore a domain-controller checkpoint.
- I will not modify either default Group Policy object.
- I will stop if DC health, replication, Recycle Bin scope, backup readiness,
  object identity, permissions, or the test OU differs from the approved plan.
- The standing no-delete rule remains in force for all existing AD objects.
  The eventual change window must name one disposable object and receive a
  narrow, dated exception before its deliberate delete/restore step.
- After verification, I will disable and move the restored object rather than
  delete it again.

## What Leonel Approves And Provides

Leonel does not need to write the documentation or invent the commands. His
job is to:

1. review the named test object, OU, backup, rollback, stop conditions, and
   proposed recovery targets;
2. approve or reject the narrow disposable-object exception;
3. provide a dated approval for the exact live change window;
4. enter a credential manually only if the approved executor cannot proceed
   without it;
5. decide whether to stop or retry if an unexpected condition appears; and
6. review the final proof before approving completion, commit, and push.

Codex prepares the project documentation and independently verifies the proof.
Claude provides the Windows-side review and may execute the approved commands
through the established supervised path. Neither assistant can approve its own
live change.

## Evidence Required Before I Mark Q003 Complete

- Dated approval and executor identity.
- Fresh pre-check and recovery-point evidence.
- Exact test-object name, distinguished name, and captured safe attributes.
- Delete and `Restore-ADObject` results for only that object.
- Positive verification on both domain controllers where applicable.
- Negative verification that no real identity, privileged membership, default
  policy, or production service was affected.
- Measured start/end time against the approved RTO.
- Cleanup/quarantine result, redaction review, lessons, and Q004 handoff.

Until all of that evidence exists, this page must continue to say **Selected —
not started** or the precise in-progress/blocked state; it must not say
Complete.
