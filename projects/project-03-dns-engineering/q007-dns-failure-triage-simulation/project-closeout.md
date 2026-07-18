# Project Closeout — Q007 DNS Failure-Triage Simulation

- **Repo:** `windows-server-business-admin-labs`
- **Closed:** 2026-07-15 MDT
- **Closed by:** Leonel with Codex implementation and Claude Fable review

## Checklist

- [x] Every phase is Complete.
- [x] The phase table uses absolute dates and matches the retained evidence.
- [x] Every phase row has a matching first-person narrative, method, proof,
      result, and handoff.
- [x] Phase status appears only in the phase table.
- [x] Evidence is saved, named, and linked from the project README.
- [x] The README follows the layered portfolio documentation standard.
- [x] No screenshots are required or linked.
- [x] The project folder contains no credential, token, key, public WAN
      address, or live configuration dump.
- [x] Syntax, retained evidence verification, and a fresh `/tmp` execution
      were rerun during closeout.
- [x] The extra-A-record scope, tool substitutions, cache limitation, and
      live-change boundary are recorded.
- [x] Q007 has no unresolved OPEN review item.
- [x] `CODEX-LOG.md` records the result and the next-project separator.
- [x] Cross-repository status and predecessor navigation are propagated.
- [x] Root/project indexes point to the dedicated Q007 page.
- [x] Canonical `docs/state.yaml` and `docs/homelab-goals.yaml` advance to Q008.
- [x] The Obsidian project card, index, hot context, evidence index when
      applicable, and session log reflect the owner-repo result.
- [x] STAR summary and collaboration record are present.
- [x] Reproduction includes prerequisites, safety boundary, verification, and
      cleanup.
- [x] `What Happens Next` names only Q008 and does not authorize it.
- [x] Commit, push, merge, and synchronization use Leonel's standing approval
      for this completion session.

## Ownership

- **Leonel:** approved proceeding through completion and identified the
  parent-folder link problem; no console or live action was required.
- **Codex:** owned scope, implementation, execution, verification,
  documentation, propagation, and approved release.
- **Claude Fable:** performed the bounded read-only design and evidence-quality
  challenge.

## Cross-Repo Updates Made

| Repository / layer | File or area | Closeout change |
|---|---|---|
| Windows Server labs | Q007 folder, indexes, bridge files | Dedicated project, evidence, runbook, Complete status, and exact navigation |
| Family playbook | Goal registry, current state, portfolio map | At Q007 close, Q007 was Complete and Q008 was selected but not started |
| Homelab management | Q006 predecessor handoff and queue directory | Q007 text becomes a direct GitHub `main` link to the completed documentation |
| Obsidian vault | N3 card, simulation index, hot context, session log | Human-facing reflection of the owner-repo closeout and Q008 handoff |

## Carried-Forward Items

| Item | Location | Owner / trigger |
|---|---|---|
| [Q008 blameless DNS incident postmortem](https://github.com/vushueh/homelab-management/tree/main/projects/q008-dns-incident-postmortem) | `homelab-management` | Completed 2026-07-18; Q008 now owns the next queue handoff |
| Any live Windows DNS adoption | Q007 operator runbook | New exact change window, current discovery, rollback, and Leonel approval |
| NIC-order and forwarder execution | P03 evidence and Q007 operator runbook | Only when a future incident or approved isolated Windows lab requires it |

## STAR Summary

**Situation:** A valid DNS response could include a stale address and send an
internal client to the wrong host.

**Task:** Reproduce the business failure without risking household DNS, repair
only the fault, prove the recovery and negative case, and publish a reusable
Windows troubleshooting path.

**Action:** I exchanged real DNS packets over loopback, injected an extra wrong
A record, demonstrated wrong-first client selection, repaired the in-memory
answer list, repeated the good query three times, required NXDOMAIN for an
unknown name, independently decoded the retained packets, and proved cleanup.

**Result:** Eleven assertions and a clean-room rerun passed. The wrong answer
was absent after repair, the server and port were released, the Windows
runbook was closed, and no live system changed.

## Verification Summary

The final retained run began at `2026-07-16T04:11:52Z` and ended at
`2026-07-16T04:11:53Z`, corresponding to July 15 in America/Denver. The
independent verifier confirmed:

- baseline answer `10.77.7.10`;
- fault answers `10.77.7.99, 10.77.7.10` and wrong-first client selection;
- three repaired responses containing only `10.77.7.10`;
- NXDOMAIN / RCODE 3 with zero answers;
- stopped server and released loopback UDP port.

An initial constrained execution was denied permission to create any socket
and stopped before binding or reaching another system. That attempt produced
no project evidence and no network effect. Codex hardened the cleanup path so
future permission failures are recorded cleanly, then reran with an explicit
loopback-only exception. Both the retained run and a separate `/tmp` rerun
passed.

A final protocol review also found that an earlier evidence draft used the
recursion-available bit rather than the authoritative-answer bit. Codex
corrected the responder to `0x8500` for positive answers and `0x8503` for
NXDOMAIN, made the separate verifier enforce those flags, and regenerated the
retained run, clean-room run, and manifest. The superseded output was not kept
as project evidence.

## How We Worked Together

### My Input And How I Helped

I approved proceeding and completing Q007, including the established release
workflow. I also noticed that clicking Q007 opened the parent P03 page and
asked why; that observation drove the final exact-page navigation check.

### What Codex Did And How

Codex recovered the canonical state, designed and built the loopback drill,
executed and independently reverified it, published the Windows runbook, and
reconciled the owner repo, predecessor, queue, and vault. The run sheet and
evidence files contain the reproducible detail.

### What Claude Did And How

Claude Fable read the authoritative inputs and challenged the proposed design
without editing or accessing a live system. Its conditional GO required honest
fault scope, raw packet proof, user impact, a dedicated Q007 folder, and the
Windows operator artifact.

### How We Communicated And Completed The Project

Leonel supplied execution and release authority and surfaced the navigation
defect during implementation. Codex provided bounded progress updates, folded
Fable's findings into the design, reported the test result, and used repository
files for the durable handoff.

### Pushback And How We Resolved It

Fable's evidence-independence and scope objections were resolved with a
separate raw-packet decoder, explicit one-fault coverage, prior P03 context,
and Windows fault branches. The execution sandbox's socket denial was resolved
with hardened cleanup and a narrow loopback-only run, never with live DNS or
external network authority. Codex's final protocol check corrected the DNS AA
and RA flag semantics before regenerating and re-verifying all evidence.

## What Happens Next

[Q008 — DNS Incident Postmortem And Blameless
Review](https://github.com/vushueh/homelab-management/tree/main/projects/q008-dns-incident-postmortem)
is the completed immediate successor. Q008 owns the next queue handoff; nothing
in this historical closeout authorizes live DNS or later queue work.
