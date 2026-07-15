# Simulation Run Sheet — Q004 Test-GPO Backup And Restore

**Simulation ID:** B3 / Q004
**Owner:** `windows-server-business-admin-labs`
**Vault note:** `08-simulations/sim-backup-gated-gpo-rollout.md`
**Stage:** complete
**Risk:** LIVE-LOW after approval
**Case study:** contributes recovery proof to future CS-003; not separate
**Video:** not recorded

## Design Gates

- [x] Business scenario: roll back a bad GPO before it disrupts users.
- [x] Evidence: transcript, backup identity, baseline/fault/restored reports,
  RSoP model, screenshot, and closeout.
- [x] Environment: one real custom-domain GPO, linked only to disabled test
  identities; planning-mode RSoP instead of client application.
- [x] Recording: no video.

## Scenario

An administrator introduces a bad setting in a custom GPO and needs to restore
the last known-good version before rollout. An unproven rollback could turn a
security improvement into a business-wide logon or workstation failure.

## Tools And Boundaries

| Tool | Use |
|---|---|
| AD DS / SYSVOL / GroupPolicy module | Real backup and restore behavior |
| GPMC Group Policy Modeling | RSoP planning verification without client application |
| Q002 coverage record | Recovery context and known Windows backup gap |

Intentionally excluded: default-policy mutation/restore, `gpupdate`, actual
client application, AD object moves, new identities/OUs, OpenClaw, workflows,
DC checkpoints, and system-state restore.

## Execution Phases

0. Reconcile queue and review lock.
1. Run fresh fail-closed prechecks.
2. Capture default-policy baseline and create dated backup folder.
3. Back up all current GPOs.
4. Create the user-only test GPO, baseline marker, Quarantine link, and exact
   test-GPO backup.
5. Inject the harmless fault marker and capture its report.
6. Restore the exact backup ID; verify GUID, baseline marker, link, defaults,
   replication, and RTO.
7. Run GPMC modeling for the disabled Q003 user and Workstations container.
8. Verify saved RSoP report, then unlink/remove only the disposable GPO.
9. Redact, independently review, propagate state, and close.

## Required Evidence

| Artifact | Proof |
|---|---|
| `evidence/q004-precheck-YYYY-MM-DD.txt` | Fresh execution gates |
| `evidence/q004-sanitized-transcript.txt` | Ordered backup/fault/restore/cleanup |
| `evidence/reports/q004-{baseline,fault,restored}.xml` | Exact setting lifecycle |
| `evidence/reports/q004-rsop-modeling.html` | Winning restored GPO/marker |
| `screenshots/phase7-01-q004-rsop-restored-policy.png` | Portfolio proof |
| `evidence/q004-closeout.md` | RTO, final state, lessons, Q005 handoff |

## Terminal Success Sequence

```text
Q004_PRECHECK=PASS
Q004_RESUME_RESTORE=PASS
Q004_AWAITING_RSOP=YES
Q004_VERIFY=PASS
Q004_CLEANUP=PASS
```

No `PASS` is accepted if a default policy changes, scope leaves Quarantine, an
enabled Quarantine user exists, replication is unhealthy, or the saved RSoP
report lacks the restored baseline marker and winning custom GPO.

## Open Gates

- [x] Fresh precheck clears the WIN-DC02 ADWS/replication gate.
- [x] Claude independently reviewed the plan/script; the version-shape defect
  was corrected and its follow-up static review found no remaining issue.
- [x] Leonel recorded exact approvals `Q004-20260714-LEONEL` and
  `Q004-20260714-LEONEL-RESUME1`.
- [x] Leonel saved the GPMC modeling report and its contents passed Verify.
- [x] Claude independently reviewed the final execution evidence and returned
  `COMPLETE-READY` with no material blocker.
