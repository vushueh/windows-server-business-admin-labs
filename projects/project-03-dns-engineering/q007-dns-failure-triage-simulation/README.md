# Q007 — DNS Failure-Triage Simulation

| Project fact | Value |
|---|---|
| Status | Complete |
| Queue / simulation ID | `Q007` / `SIM-N3-DNS` |
| Completed | July 15, 2026 MDT |
| Owner | Leonel |
| Scope | Extra wrong A record, diagnosis, repair, retest, cleanup, and reusable Windows runbook |
| Risk / execution | ISO / loopback-only repository harness |
| Live changes | None |
| Production systems contacted | None |
| Named artifact | [Windows DNS failure-triage runbook](runbooks/q007-windows-dns-failure-triage.md) |

## Why This Matters

DNS can answer successfully and still send a user to the wrong system. I
wanted a repeatable drill that proves an operator inspects the complete answer
set, identifies the bad record, repairs only the fault, and verifies that the
bad answer is gone. I also wanted that proof without practicing on the domain
controllers that household identity depends on.

## Portfolio Summary

**Situation:** An internal file-service name returned an extra stale A record,
so a client could select an address where the expected service was not
available.

**Task:** Recreate that failure safely, demonstrate user impact, diagnose and
repair it, perform positive and negative retests, and turn the method into a
Windows operator runbook.

**Action:** I ran a Python standard-library DNS responder and client on
`127.0.0.1:10553`. I established one correct answer, injected a wrong answer
first, decoded the real UDP response packets, removed the wrong answer, repeated
the successful query three times, required NXDOMAIN for an unknown name, and
proved the server stopped and released its port.

**Result:** All eleven assertions passed. The saved packets independently
decode to one correct baseline record, a wrong-first two-record fault, three
correct repaired responses, and RCODE 3 for the negative test. No live DNS,
adapter, DHCP, AD, Hyper-V, or host resolver configuration changed.

## How To Read This Project

- For the result and business story, read this page and [What I
  Proved](#what-i-proved).
- For the exact isolated design and tests, read the [simulation run
  sheet](q007-simulation-run-sheet.md).
- For operations, use the [Windows DNS failure-triage
  runbook](runbooks/q007-windows-dns-failure-triage.md).
- For technical proof, inspect the [sanitized
  transcript](evidence/q007-sanitized-transcript.txt), [structured
  result](evidence/q007-run-results.json), and [independent
  verification](evidence/q007-closeout-verification.txt).

## Prepared Hands-On Operator Practicum

The completed automated result above remains unchanged. A separately gated
[Windows DNS operator practicum](hands-on/q007-windows-dns-operator-practicum.md)
now mirrors Q007 phases 0–9 in one standalone VM on a Hyper-V Private switch.
It includes the [screenshot plan](hands-on/q007-windows-screenshot-plan.md),
[change-window plan](hands-on/q007-windows-lab-change-window.md), and
[rollback plan](hands-on/q007-windows-lab-rollback-plan.md). Claude Fable's
[bounded read-only review](hands-on/q007-claude-fable-practicum-review-2026-07-15.md)
returned GO after five clarifications, all of which are applied in the guide.

The practicum's [Phase 0 read-only precheck evidence](evidence/q007-windows-hands-on-evidence-log.md)
has passed and been ingested. Leonel approved the exact Phase 2 scope on
2026-07-15; on 2026-07-16, the accepted ISO was copied with an exact hash match
and `Q007-Private` was created and verified as Private with no physical-adapter
description. Phase 2B then created `Q007-DNS01` and its dynamic 40 GB VHDX.
The accepted host-side capture proves an Off Generation 2 VM with 2 vCPU, 4 GB
static startup memory, one adapter, and attachment only to `Q007-Private`.
After the overnight pause, [guest-side CIM evidence](evidence/q007-phase2-guest-installation-verification.txt)
proved Windows Server 2022 Standard Evaluation build 20348 was running in
`WORKGROUP` with `PartOfDomain=False`. A separately approved Phase 3 then
renamed the guest to `Q007-DNS01` and [proved its two fixed lab addresses,
self-DNS, no default route, and standalone state](evidence/screenshots/phase3-01-q007-guest-safety-precheck.txt).
A separately approved Phase 4 then installed only DNS and its tools and
[created the file-backed `q007.test` zone with one correct `files` A
record](evidence/screenshots/phase4-02-q007-zone-baseline-record.txt). No
baseline query, fault, or repair is claimed. A separately approved Phase 5
then [proved the exact baseline and the real two-record DNS Manager fault
state](evidence/q007-phase5-fault-validation-2026-07-17.txt) through six direct
queries and reachability checks. The wrong record remains active only in the
isolated guest pending Phase 6 approval; no repair is claimed. This later
evidence does not reopen or weaken the completed loopback proof and does not
authorize production DNS, commit, push, merge, or deletion.

## My Test Boundary

I used the reserved `.test` namespace, RFC1918 addresses, and a high UDP port
bound only to loopback. The client and disposable authoritative responder ran
locally and had no external dependency. The server held its record list only
in memory, so stopping the process removed the entire lab state.

I exercised one catalog fault: an extra wrong A record. I did not claim that
this run executes a Windows NIC-order or forwarder fault. The parent P03
[break/fix log](../troubleshooting/break-fix-log.md) supplies the real prior
multi-homed DC context, while the new operator runbook keeps the NIC and
forwarder branches available for diagnosis. No screenshots were required
because packet hex, decoded fields, and test output are the stronger evidence.

## Phase Status

| Phase | Work | Status | Date |
|---:|---|---|---|
| 0 | Select And Gate Q007 | Complete | 2026-07-15 |
| 1 | Review The Business Failure | Complete | 2026-07-15 |
| 2 | Design The Isolated DNS Topology | Complete | 2026-07-15 |
| 3 | Define Safety And Evidence | Complete | 2026-07-15 |
| 4 | Build The Harness And Runbook | Complete | 2026-07-15 |
| 5 | Establish Baseline And Inject Fault | Complete | 2026-07-15 |
| 6 | Repair, Retest, And Clean Up | Complete | 2026-07-15 |
| 7 | Map The Drill To Windows Operations | Complete | 2026-07-15 |
| 8 | Independently Verify The Evidence | Complete | 2026-07-15 |
| 9 | Close And Propagate | Complete | 2026-07-15 |

## Phase 0 — Select And Gate Q007

The authoritative queue selected Q007 after Q006 closed, and its only required
dependency, Q002/CUR-B1, was already complete. I confirmed there was no urgent
preemption and no OPEN or in-flight Q007 claim in `CLAUDE-REVIEW.md`. The
[run sheet](q007-simulation-run-sheet.md) records those checks and fixed the
execution path at ISO/repository-only, so design could begin without live
authority.

## Phase 1 — Review The Business Failure

I started with the user-visible failure: a file-service name can return a
stale address and send a client to the wrong host even while DNS reports a
successful response. I compared that scenario with the parent P03
[break/fix evidence](../troubleshooting/break-fix-log.md), where multi-homed DC
registration and DNS client order had caused real pollution. That connection
made an extra-record drill the smallest useful fault while preserving the NIC
and forwarder branches for the runbook.

## Phase 2 — Design The Isolated DNS Topology

I placed both sides of the exchange on `127.0.0.1:10553`, used
`files.q007.test`, and selected `10.77.7.10` and `10.77.7.99` as private lab
answers. The [topology and fault-scope decision](q007-simulation-run-sheet.md#safe-lab-version)
show why this is credible when combined with the existing Windows incident
evidence. With no path to a household resolver, I could define the exact
failure without building a VM or touching a domain controller.

## Phase 3 — Define Safety And Evidence

Before execution, I named the transcript, JSON result, raw packet proof,
independent verifier, SHA-256 manifest, and Windows runbook. I also wrote stop
conditions for an unexpected bind address, a privileged or occupied port, a
failed assertion, or any need for external access. Claude Fable's
[read-only design review](evidence/q007-claude-design-review-2026-07-15.md)
challenged the single-fault scope, self-attesting evidence risk, and missing
user-impact proof; resolving those findings established the execution gate.

## Phase 4 — Build The Harness And Runbook

I built a dependency-free [DNS drill](scripts/q007_dns_drill.py) that encodes
and decodes real UDP DNS packets and fails closed to loopback. A separate
[evidence verifier](scripts/q007_verify_evidence.py) decodes the saved raw
responses independently instead of trusting only the live harness summary. I
also drafted the [Windows operator runbook](runbooks/q007-windows-dns-failure-triage.md),
which connected the lab record fault to record, NIC, forwarder, cache,
approval, rollback, and service-retest steps.

## Phase 5 — Establish Baseline And Inject Fault

The baseline response contained one A record, `10.77.7.10`, with RCODE 0. I
then changed only the in-memory answer list to return `10.77.7.99` first and
the correct record second. The [protocol transcript](evidence/q007-sanitized-transcript.txt)
shows ANCOUNT changing from one to two and the naive client selecting the
wrong first answer, which demonstrated the business impact rather than merely
asserting that two records existed.

## Phase 6 — Repair, Retest, And Clean Up

I removed only the injected address and repeated the query three times; every
response contained only `10.77.7.10`. I then confirmed the wrong address was
absent and `old-files.q007.test` returned RCODE 3 with no answer. The same run
also proved an occupied port stops startup, a malformed packet does not crash
the server, the server thread stops, and the port can be rebound. These eleven
[structured assertions](evidence/q007-run-results.json) completed the isolated
fault, repair, retest, and cleanup path.

## Phase 7 — Map The Drill To Windows Operations

The lab deliberately avoided live Windows administration, so I mapped each
step to `Resolve-DnsName`, `nslookup`, `Get-DnsServerResourceRecord`, adapter
DNS inspection, and forwarder inspection in the [operator
runbook](runbooks/q007-windows-dns-failure-triage.md). I added capture-before-
clear guidance because the loopback server has no cache layer, and I kept
every repair behind exact current-state, backup, rollback, and dated approval.
That made the artifact reusable without turning it into permission for a live
change.

## Phase 8 — Independently Verify The Evidence

After the retained run passed, I used a second decoder to parse the raw packet
hex and independently confirm the answer counts, addresses, RCODE, and cleanup
status. I also reran the entire drill into `/tmp` and verified the fresh result
instead of relying only on the project evidence copy. The [closeout
verification](evidence/q007-closeout-verification.txt) records both passes and
the exact final checks, which supported documentation and status propagation.

## Phase 9 — Close And Propagate

I applied the project documentation and closeout standards, checked every
evidence link, and preserved P03 as its own already-complete project. I then
updated the dedicated Q007 links, canonical queue/state, repository indexes,
Q006 predecessor handoff, and vault reflection. The [project
closeout](project-closeout.md) records that Q007 is closed and that its
immediate successor remains a separate, unstarted project.

## What I Proved

- A real DNS response can be successful while containing a harmful extra A
  record.
- A wrong-first answer can make a naive client select the wrong host.
- Inspecting the complete answer set distinguishes that fault from simple
  resolver unavailability.
- Removing only the wrong record restores the exact single-answer baseline.
- Three repeated positive tests contain only the intended answer.
- The wrong address is explicitly absent after repair.
- An unknown name returns NXDOMAIN / RCODE 3 rather than a false answer.
- An occupied port stops startup and a malformed packet does not crash the
  server.
- Cleanup stops the server and releases the UDP port.
- The complete result is reproducible and independently decodable.
- The exercise needs no live Windows DNS change or screenshot.
- A later optional Windows practicum can add operator screenshots without
  changing what the completed automated core proved.

## Technical Evidence

- [Simulation run sheet](q007-simulation-run-sheet.md)
- [Reusable Windows DNS failure-triage runbook](runbooks/q007-windows-dns-failure-triage.md)
- [Prepared Windows DNS operator practicum](hands-on/q007-windows-dns-operator-practicum.md)
- [Hands-on screenshot plan](hands-on/q007-windows-screenshot-plan.md)
- [Hands-on change-window plan](hands-on/q007-windows-lab-change-window.md)
- [Hands-on rollback plan](hands-on/q007-windows-lab-rollback-plan.md)
- [Claude Fable hands-on plan review](hands-on/q007-claude-fable-practicum-review-2026-07-15.md)
- [Windows hands-on evidence log](evidence/q007-windows-hands-on-evidence-log.md)
- [Phase 2 guest installation verification](evidence/q007-phase2-guest-installation-verification.txt)
- [Windows hands-on integrity manifest](evidence/q007-windows-hands-on-manifest.sha256)
- [DNS drill source](scripts/q007_dns_drill.py)
- [Independent evidence verifier](scripts/q007_verify_evidence.py)
- [Sanitized protocol transcript](evidence/q007-sanitized-transcript.txt)
- [Structured run result](evidence/q007-run-results.json)
- [Closeout verification](evidence/q007-closeout-verification.txt)
- [Claude Fable design review](evidence/q007-claude-design-review-2026-07-15.md)
- [SHA-256 evidence manifest](evidence/q007-evidence-manifest.sha256)
- [Project closeout](project-closeout.md)

## How We Worked Together

### My Input And How I Helped

I approved proceeding through completion and retained my standing instruction
to commit, push, merge, and close after approval. While the work was underway,
I reported that the Q007 index link opened the parent P03 page rather than a
dedicated simulation page. I did not need to run a console step or approve a
live configuration because the exercise remained isolated.

### What Codex Did And How

Codex recovered the queue and repository gates, designed the isolated DNS
protocol drill, wrote the harness, verifier, run sheet, operator runbook, and
project record, then executed and re-executed the tests. It verified the raw
packets and corrected the Q007 navigation to the dedicated project page before
preparing the closeout.

### What Claude Did And How

Claude Fable performed one bounded read-only design review. It challenged the
fault-scope claim, evidence independence, user-impact proof, project placement,
and Windows runbook requirement. The exact findings and their dispositions are
in the [design review record](evidence/q007-claude-design-review-2026-07-15.md).

### How We Communicated And Completed The Project

I supplied the execution and release approval and reported the navigation
problem during the work. Codex kept the execution updates bounded to the ISO
scope, incorporated Fable's review, reported the completed assertions, and
changed the indexes and Q006 handoff to the exact Q007 page. The repository
evidence and bridge files carry the durable result rather than the private
assistant exchange.

### Pushback And How We Resolved It

Claude Fable objected that one all-in-one harness could overstate catalog
coverage and attest to its own output. Codex responded by limiting the claim to
the extra-A-record fault, linking the real P03 NIC/forwarder context, retaining
raw response hex, and adding a separate packet decoder. The first execution
environment also blocked all socket creation before a port could open; Codex
hardened failure cleanup and reran only after granting the process the narrow
loopback exception, with no external or live-system access.
The final protocol review then caught that the first evidence draft advertised
recursion availability instead of setting the authoritative-answer flag.
Codex corrected the response flags to `0x8500` / `0x8503`, strengthened the
separate verifier to enforce them, and regenerated both passing runs and the
integrity manifest before release.

## Reproduce Or Re-Verify

Prerequisites are Python 3.10 or later and permission to bind a local
non-privileged UDP socket. No administrator credential, external network, VM,
or live DNS access is required.

From this Q007 directory:

```bash
python3 -m py_compile scripts/q007_dns_drill.py scripts/q007_verify_evidence.py
python3 scripts/q007_dns_drill.py --output-dir /tmp/q007-reverify
python3 scripts/q007_verify_evidence.py /tmp/q007-reverify/q007-run-results.json
```

The runner refuses a non-loopback bind address and a privileged port. Stop if
the selected port is unexpectedly occupied or any assertion fails. Cleanup is
process termination plus a successful bind to the released port; no zone,
adapter, cache, or service state persists.

## What Happens Next

Q007 is closed. Q008 — DNS Or Network Incident Postmortem is next in the
[authoritative queue](../../../../docs/homelab-goals.yaml). It is selected but
not started; this handoff does not start or authorize Q008.
