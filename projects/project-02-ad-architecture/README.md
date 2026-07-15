# Project 02 — Active Directory Architecture

- **Status:** Complete — 2026-07-03
- **Project / Queue ID:** `Windows-P02`
- **Owner:** `windows-server-business-admin-labs`
- **Scope:** OU design, object placement, groups, delegation, recovery, and replica domain controller
- **Risk:** Approved live Active Directory and domain-controller changes

## Why This Matters

Users, computers, groups, and administrative identities need predictable
locations before GPO, file-share, RADIUS, SOC, or lifecycle work can be safe.
I also needed a second domain controller so identity and DNS did not depend on
one server.

## Portfolio Summary

**Situation:** Objects were spread across default containers and root-level
department OUs, and the domain had one controller.

**Task:** I needed to create a manageable identity structure and add
replication without deleting objects or moving FSMO roles.

**Action:** I built managed OUs, moved existing objects, created AGDLP and
cross-family groups, staged disabled accounts, delegated helpdesk rights,
enabled Recycle Bin, and promoted `WIN-DC02` as a DNS-enabled Global Catalog.

**Result:** The domain has a GPO-ready structure, least-privilege delegation,
recoverable deleted objects, and two healthy domain controllers while all FSMO
roles remain on the original PDC.

## How To Read This Project

| Reader | Start here |
|---|---|
| Hiring manager or non-technical reader | [Portfolio Summary](#portfolio-summary) and [What I Proved](#what-i-proved) |
| Technical reviewer | [Phase Status](#phase-status), [Technical Evidence](#technical-evidence), and [technical details](technical-details.md) |
| Future operator | [Reproduce Or Re-Verify](#reproduce-or-re-verify) |

## My Test Boundary

I used idempotent scripts and verified every object before or after movement. I
deleted no AD object, enabled no staged service/admin account, transferred no
FSMO role, and created no file-share permission or later-project policy.

## Phase Status

| Phase | Work | Status |
|---:|---|---|
| 1 | Managed OU structure | Complete |
| 2 | Existing-object placement | Complete |
| 3 | Tiered admin staging | Complete |
| 4 | AGDLP group model | Complete |
| 5 | Service-account staging | Complete |
| 6 | Delegation and AD Recycle Bin | Complete |
| 7 | Replica domain controller | Complete |
| 8 | Functional-level verification | Complete |
| 9 | Repeatable verification and closeout | Complete |

## Phase 1 — Managed OU Structure

I created `ManagedUsers`, `ManagedComputers`, their child OUs, and the global
and domain-local group containers. The
[apply script](scripts/p02-apply-ad-architecture.ps1) uses plan/apply behavior
so existing objects are recognized rather than recreated. That structure gave
me safe destinations for the current domain objects.

## Phase 2 — Existing-Object Placement

I moved the five department OUs beneath `ManagedUsers`, workstations beneath
`ManagedComputers/Workstations`, and member servers beneath
`ManagedComputers/Servers`. I left both domain controllers in their protected
OU and deleted nothing. The verified placement made later group and policy
scope predictable.

## Phase 3 — Tiered Admin Staging

I preserved the Project 01 admin tiers and created `ws-leonel` under the Tier 2
OU in a disabled state. I did not enable new workstation-admin access before a
workstation project needed it. That kept account existence separate from
authorization.

## Phase 4 — AGDLP Group Model

I created department `GG-*` groups, matching `DL-*` resource groups, and the
required nesting. I also created the network, SOC, helpdesk, server, and
workstation groups used by later projects. This made membership the user-facing
control while future resource ACLs remain on domain-local groups.

## Phase 5 — Service-Account Staging

I created `svc-backup` and `svc-sync` beneath `_Admin/ServiceAccounts` and left
both disabled. The accounts exist for later owned workflows, but this project
did not grant logon rights or embed credentials. That preserved least privilege
before delegation work.

## Phase 6 — Delegation And AD Recycle Bin

I enabled AD Recycle Bin and delegated password reset, forced password change,
and unlock rights to `GG-Helpdesk` only beneath `ManagedUsers`. The
[verification script](scripts/p02-verify-ad-architecture.ps1) checks the
result without granting Domain Admin. This added recoverability and routine
support capability before I introduced the second DC.

## Phase 7 — Replica Domain Controller

I backed up the original server, cleaned multihomed DNS registration, built
`WIN-DC02`, joined it to the domain, and promoted it with DNS and Global
Catalog. The [build evidence](docs/p02-win-dc02-build-evidence.md) proves clean
replication plus SYSVOL and NETLOGON shares. I kept all FSMO roles on
`WIN-PRQD8TJG04M`, so redundancy did not become an unplanned role migration.

## Phase 8 — Functional-Level Verification

I verified `Windows2016Domain` and `Windows2016Forest`, which are the valid
functional-level labels for this Windows Server 2022 deployment. I made no
unnecessary functional-level change. That check closed a common design
assumption before final verification.

## Phase 9 — Repeatable Verification And Closeout

I reran the read-only script to confirm OUs, groups, nesting, account states,
Recycle Bin, delegation, FSMO placement, and both DCs. The
[technical record](technical-details.md) preserves the screenshots, commands,
layout, and recovery notes. That verified identity foundation handed cleanly
to DNS engineering.

## What I Proved

- Managed user, computer, group, admin, service-account, and Quarantine OUs
  exist with the documented object placement.
- Department global groups are nested into their matching resource groups.
- Staged workstation and service identities remain disabled.
- AD Recycle Bin and scoped helpdesk delegation are enabled.
- `WIN-DC02` replicates with zero reported failures and serves SYSVOL,
  NETLOGON, DNS, and Global Catalog while the original PDC keeps every FSMO role.

## Technical Evidence

- [Complete commands, diagrams, screenshots, and recovery notes](technical-details.md)
- [Idempotent architecture apply script](scripts/p02-apply-ad-architecture.ps1)
- [Read-only architecture verification script](scripts/p02-verify-ad-architecture.ps1)
- [WIN-DC02 build and replication evidence](docs/p02-win-dc02-build-evidence.md)
- [Screenshot checklist](docs/p02-screenshot-plan.md)
- [Reviewed screenshots](screenshots/)

## How We Worked Together

### My Input And How I Helped

I approved the live directory and replica-DC changes, supplied the real
department and computer context, and performed or authorized the required
Windows and Hyper-V steps. I kept FSMO transfer and account activation outside
scope.

### What Codex Did And How

Codex designed and ran the idempotent OU/group workflow, verified the live
directory, documented the `WIN-DC02` build, and reconciled the final identity
records across the repository.

### What Claude Did And How

Claude reviewed the project command design, including DC-promotion parameters,
functional-level assumptions, DNS safety, and the rule that FSMO seizure does
not belong in normal deployment. The retained record does not show Claude
performing the final promotion.

### How We Communicated And Completed The Project

The architecture moved from plan output to approved apply, verification, VM
build, promotion, and replication evidence. Screenshots and command results
were written into the project records after each gate.

### Pushback And How We Resolved It

The early design included unsafe or inaccurate ideas about a newer functional
level and routine FSMO seizure. Review removed both: the valid level remained
Windows Server 2016, and all roles stayed on the healthy original PDC.

## Reproduce Or Re-Verify

1. Run `scripts/p02-apply-ad-architecture.ps1 -Mode Plan`; expect existing
   objects rather than proposed recreation or movement.
2. Run the [read-only verification script](scripts/p02-verify-ad-architecture.ps1)
   from an approved administrative session.
3. Check replication, SYSVOL/NETLOGON, both DC DNS roles, Global Catalog state,
   and FSMO ownership using the commands in [technical details](technical-details.md).
4. Do not move, delete, enable, promote, demote, or transfer a role without a
   new backup, change window, stop conditions, and rollback.

## What Happens Next

Project 02 is closed. [Project 03](../project-03-dns-engineering/) uses the two-
DC identity foundation to harden AD DNS and name resolution. This closeout and
link do not start or authorize a DNS change.
