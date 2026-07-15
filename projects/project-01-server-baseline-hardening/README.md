# Project 01 — Server Baseline, Hardening, And Admin Model

- **Status:** Complete — 2026-06-23
- **Project / Queue ID:** `Windows-P01`
- **Owner:** `windows-server-business-admin-labs`
- **Scope:** Live primary domain controller baseline, account policy, privileged administration, service risk, firewall visibility, and lockout proof
- **Risk:** Approved live identity changes with documentation-only service review

## Why This Matters

The domain controller already supported real users and services, so I could not
treat it like a disposable training server. I needed to reduce the most serious
identity risks while preserving access and documenting work that belonged in
later projects.

## Portfolio Summary

**Situation:** The domain allowed seven-character passwords, had no lockout
threshold, included too many Domain Admins, and ran undocumented RDS/IIS roles.

**Task:** I needed to harden the existing foundation without breaking the live
Windows environment.

**Action:** I audited the server, backed up policy, strengthened password and
lockout settings, built a tiered admin model, reduced Domain Admin membership,
documented service and firewall risk, and tested lockout with a disposable user.

**Result:** The domain has a stronger verified account policy, three approved
Domain Admin members, separated admin identities, and a reusable baseline for
the later Windows projects.

## How To Read This Project

| Reader | Start here |
|---|---|
| Hiring manager or non-technical reader | [Portfolio Summary](#portfolio-summary) and [What I Proved](#what-i-proved) |
| Technical reviewer | [Phase Status](#phase-status), [Technical Evidence](#technical-evidence), and [technical details](technical-details.md) |
| Future operator | [Reproduce Or Re-Verify](#reproduce-or-re-verify) |

## My Test Boundary

I changed only the approved account-policy and identity items after recording
the starting state. I did not remove RDS, IIS, NPS, VNC, or remote-access rules,
and I used `testuser` instead of a real person for the lockout exercise.

## Phase Status

| Phase | Work | Status |
|---:|---|---|
| 1 | Audit and starting-state documentation | Complete |
| 2 | Password and lockout policy | Complete |
| 3 | Tiered admin model | Complete |
| 4 | RDS, IIS, and NPS risk assessment | Complete |
| 5 | Firewall and listener baseline | Complete |
| 6 | Lockout break/fix proof | Complete |
| 7 | Evidence and closeout | Complete |

## Phase 1 — Audit And Starting-State Documentation

I inventoried the live roles, users, groups, GPOs, joined computers, listeners,
and firewall posture before making a change. The
[verified state](docs/p01-verified-final-state.md) established that this was a
working multi-role domain controller, not a fresh build. That baseline let me
rank the account-policy gaps first.

## Phase 2 — Password And Lockout Policy

I backed up the policy state, raised the minimum password length to 14, and set
lockout at five failed attempts for 30 minutes. The
[Phase 2 evidence](docs/p01-phase2-evidence.md) records the final domain policy
instead of relying on a GUI screenshot alone. Once the account policy was
verified, I could reduce standing privilege safely.

## Phase 3 — Tiered Admin Model

I created the `_Admin` structure, separated `adm-leonel` and `srv-leonel`,
created the Tier 0 password policy, and reduced Domain Admins from 12 to three
approved members. The [admin-model evidence](docs/p01-phase3-evidence.md)
verifies placement, membership, and policy assignment. This established the
identity boundary needed to assess the remaining server roles.

## Phase 4 — RDS, IIS, And NPS Risk Assessment

I inspected RDS, IIS application pools, and NPS without removing a live role.
The [risk assessment](docs/p01-rds-iis-risk-assessment.md) explains why an
unplanned cleanup could break access and carries migration to Project 08. That
decision kept the baseline safe while I documented network exposure.

## Phase 5 — Firewall And Listener Baseline

I captured the firewall profiles and TCP/UDP listeners and verified the NPS
ports. The [firewall baseline](docs/p01-phase5-firewall-baseline.md) preserves
the RDP/Tailscale path and defers default-block hardening until tested GPO
allowlists exist. With access protected, I could test the new lockout behavior.

## Phase 6 — Lockout Break/Fix Proof

I triggered five failed attempts against `testuser`, verified Event 4740, then
disabled the account and moved it to Quarantine. The
[break/fix record](docs/p01-phase6-lockout-breakfix.md) also documents the
missing failed-logon audit events for future policy work. The disposable test
proved enforcement without risking a real identity.

## Phase 7 — Evidence And Closeout

I saved the phase records, reviewed the final state, and kept sensitive NPS
exports outside the repository. The [full technical record](technical-details.md)
preserves commands, screenshots, deferrals, and links. That closeout made the
server foundation ready for the Active Directory architecture project.

## What I Proved

- The domain enforces a 14-character minimum and locks an account after five
  failed attempts.
- Domain Admin membership was reduced from 12 to three approved identities.
- Tier 0 and Tier 1 administrative identities are separated and auditable.
- The disposable lockout account ended disabled in Quarantine.
- RDS, IIS, NPS, firewall, and audit gaps remain documented rather than falsely
  reported as remediated.

## Technical Evidence

- [Complete commands, screenshots, and deferred items](technical-details.md)
- [Password and lockout evidence](docs/p01-phase2-evidence.md)
- [Tiered admin evidence](docs/p01-phase3-evidence.md)
- [RDS, IIS, and NPS risk assessment](docs/p01-rds-iis-risk-assessment.md)
- [Firewall and listener baseline](docs/p01-phase5-firewall-baseline.md)
- [Lockout break/fix record](docs/p01-phase6-lockout-breakfix.md)
- [Verified final state](docs/p01-verified-final-state.md)
- [Supporting screenshots](screenshots/)

## How We Worked Together

### My Input And How I Helped

I approved the live policy and identity changes, performed the early GUI steps,
and supplied screenshots and console results. I chose to preserve remote access
and defer risky service removal.

### What Codex Did And How

Codex reviewed the seven-phase design, corrected the safety guidance, verified
the policy and evidence structure, and completed the final documentation and
status cleanup.

### What Claude Did And How

Claude designed and coordinated the early project phases, reviewed Codex's
corrections, and performed approved remote checks after the SSH path became
available. The bridge log records the role change and review history.

### How We Communicated And Completed The Project

I returned GUI screenshots and PowerShell results after each gate. Claude and
Codex used the bridge files to reconcile corrections, and the project closed
only after the evidence and live readback agreed.

### Pushback And How We Resolved It

The initial hardening scope could have expanded into removing RDS/IIS or
tightening remote-access rules on the domain controller. I kept those items as
documented future work because the project had no tested migration or allowlist
for them.

## Reproduce Or Re-Verify

1. Read the [verified state](docs/p01-verified-final-state.md) and confirm the
   target is still the live domain controller before running read-only checks.
2. Query the password policy, Domain Admin membership, tiered accounts,
   firewall profiles, listeners, and Quarantine state using the commands in
   [technical details](technical-details.md).
3. Use only a disposable disabled test identity for any new lockout exercise.
4. Do not remove a role, change remote access, or alter account policy without
   a fresh backup, approved window, verification, and rollback.

## What Happens Next

Project 01 is closed. [Project 02](../project-02-ad-architecture/) uses this
secured foundation to organize users, computers, groups, delegation, recovery,
and domain-controller redundancy. This closeout and link do not start or
authorize an Active Directory change.
