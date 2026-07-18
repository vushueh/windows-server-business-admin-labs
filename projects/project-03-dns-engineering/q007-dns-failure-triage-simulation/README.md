# Q007 — DNS Failure-Triage Simulation

| Project fact | Value |
|---|---|
| Status | Complete |
| Queue / simulation ID | `Q007` / `SIM-N3-DNS` |
| Completed | Automated core: July 15, 2026 MDT; Windows practicum: July 17, 2026 MDT |
| Owner | Leonel |
| Scope | Extra wrong A record, diagnosis, repair, retest, cleanup, and reusable Windows runbook |
| Risk / execution | Loopback-only repository harness plus isolated standalone Windows VM |
| Live changes | Approved disposable `Q007-DNS01` and `q007.test` objects only; no production change |
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

**Result:** All eleven automated assertions passed. The saved packets
independently decode to one correct baseline record, a wrong-first two-record
fault, three repaired responses, and RCODE 3 for the negative test. The later
Windows practicum repeated the operator workflow only in the isolated
`Q007-DNS01` guest and made no production DNS, DHCP, AD, or host-resolver
change.

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

## Windows Hands-On Operator Practicum

The completed automated result above remains unchanged. A separately gated
[Windows DNS operator practicum](hands-on/q007-windows-dns-operator-practicum.md)
mirrored Q007 phases 0–9 in one standalone VM on a Hyper-V Private switch.
It includes the [screenshot plan](hands-on/q007-windows-screenshot-plan.md),
[change-window plan](hands-on/q007-windows-lab-change-window.md), and
[rollback plan](hands-on/q007-windows-lab-rollback-plan.md). Claude Fable's
[bounded read-only review](hands-on/q007-claude-fable-practicum-review-2026-07-15.md)
returned GO after five clarifications, all of which are applied in the guide.

The [evidence log](evidence/q007-windows-hands-on-evidence-log.md) records each
approval and result. The practicum proved the Private-switch boundary,
standalone workgroup state, two fixed lab addresses, self-DNS, and no default
route. It installed only DNS and its tools, created the file-backed
`q007.test` zone, demonstrated the correct baseline and two-record fault,
removed only `10.77.7.99`, passed three exact-good retests and NXDOMAIN, and
finished with `Q007-DNS01` powered off. The Phase 9 image proves only the VM's
Off state because the empty-zone check was not captured separately. This
isolated evidence does not authorize any production DNS or Windows change.

## My Test Boundary

I used the reserved `.test` namespace, RFC1918 addresses, and a high UDP port
bound only to loopback. The client and disposable authoritative responder ran
locally and had no external dependency. The server held its record list only
in memory, so stopping the process removed the entire lab state.

I exercised one catalog fault: an extra wrong A record. I did not claim that
this run executes a Windows NIC-order or forwarder fault. The parent P03
[break/fix log](../troubleshooting/break-fix-log.md) supplies the real prior
multi-homed DC context, while the new operator runbook keeps the NIC and
forwarder branches available for diagnosis. The automated core needed no
screenshots because packet hex, decoded fields, and test output are stronger
for that proof; the later Windows practicum supplied GUI and PowerShell
operator evidence separately.

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

### Windows Host Precheck

<p><strong>Proof:</strong> The later operator practicum confirmed the fixed Q007 VM and switch names were unused before creation and the read-only gate passed. <a href="evidence/screenshots/phase0-01-q007-hyperv-precheck.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase0-01-q007-hyperv-precheck.png" alt="Q007 Hyper-V precheck" width="900">

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

I later reproduced the isolation design in one standalone Windows Server VM on
the `Q007-Private` Hyper-V switch. Additional GUI views are in the
[Windows evidence details](evidence/q007-windows-evidence-details.md#phase-2--private-switch-and-isolated-vm).

### Private Switch Validation

<p><strong>Proof:</strong> `Q007-Private` is a Private Hyper-V switch with no physical-adapter binding. <a href="evidence/screenshots/phase2-01-q007-private-switch.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase2-01-q007-private-switch.png" alt="Q007 Private Hyper-V switch" width="900">

### Isolated VM Network

<p><strong>Proof:</strong> `Q007-DNS01` has one adapter attached only to `Q007-Private`. <a href="evidence/screenshots/phase2-02-q007-vm-isolated-network.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase2-02-q007-vm-isolated-network.png" alt="Q007 isolated VM network" width="900">

## Phase 3 — Define Safety And Evidence

Before execution, I named the transcript, JSON result, raw packet proof,
independent verifier, SHA-256 manifest, and Windows runbook. I also wrote stop
conditions for an unexpected bind address, a privileged or occupied port, a
failed assertion, or any need for external access. Claude Fable's
[read-only design review](evidence/q007-claude-design-review-2026-07-15.md)
challenged the single-fault scope, self-attesting evidence risk, and missing
user-impact proof; resolving those findings established the execution gate.

The Windows extension then proved the guest remained standalone, used only the
approved lab addresses, had no default route, and used itself as DNS.

### Standalone Guest Safety Check

<p><strong>Proof:</strong> The guest passed the combined name, workgroup, addressing, self-DNS, and no-default-route assertions. <a href="evidence/screenshots/phase3-01-q007-guest-safety-precheck.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase3-01-q007-guest-safety-precheck.png" alt="Q007 guest safety validation" width="900">

### Rename And Workgroup Membership

<p><strong>Proof:</strong> The Computer Name dialog shows `Q007-DNS01` remaining in `WORKGROUP`. <a href="evidence/screenshots/phase3-02-q007-rename-workgroup.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase3-02-q007-rename-workgroup.jpg" alt="Q007 rename and workgroup" width="900">

## Phase 4 — Build The Harness And Runbook

I built a dependency-free [DNS drill](scripts/q007_dns_drill.py) that encodes
and decodes real UDP DNS packets and fails closed to loopback. A separate
[evidence verifier](scripts/q007_verify_evidence.py) decodes the saved raw
responses independently instead of trusting only the live harness summary. I
also drafted the [Windows operator runbook](runbooks/q007-windows-dns-failure-triage.md),
which connected the lab record fault to record, NIC, forwarder, cache,
approval, rollback, and service-retest steps.

The approved Windows build installed only DNS and its management tools, then
created the file-backed `q007.test` zone with one correct `files` record.
Additional GUI creation views are in the [Windows evidence details](evidence/q007-windows-evidence-details.md#phase-4--dns-role-and-baseline-zone).

### DNS Role Validation

<p><strong>Proof:</strong> DNS and its management tools are installed, the DNS service runs automatically, and AD DS and DHCP remain uninstalled. <a href="evidence/screenshots/phase4-01-q007-dns-role-installed.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase4-01-q007-dns-role-installed.png" alt="Q007 DNS role validation" width="900">

### Baseline Zone And Record

<p><strong>Proof:</strong> DNS Manager shows `q007.test` with the single correct `files` A record for `10.77.7.10` and no PTR selection. <a href="evidence/screenshots/phase4-02-q007-zone-baseline-record.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase4-02-q007-zone-baseline-record.png" alt="Q007 baseline DNS record" width="900">

## Phase 5 — Establish Baseline And Inject Fault

The baseline response contained one A record, `10.77.7.10`, with RCODE 0. I
then changed only the in-memory answer list to return `10.77.7.99` first and
the correct record second. The [protocol transcript](evidence/q007-sanitized-transcript.txt)
shows ANCOUNT changing from one to two and the naive client selecting the
wrong first answer, which demonstrated the business impact rather than merely
asserting that two records existed.

The Windows practicum repeated that progression with direct queries against
`10.77.7.2`, first proving the single-answer baseline and then the two-record
fault state.

### Exact Baseline Answer

<p><strong>Proof:</strong> The direct query returned only `10.77.7.10`, the wrong address did not respond, and the baseline gate passed. <a href="evidence/screenshots/phase5-01-q007-baseline-resolution.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase5-01-q007-baseline-resolution.png" alt="Q007 baseline DNS resolution" width="900">

### Injected Two-Record Fault

<p><strong>Proof:</strong> DNS Manager shows both the correct `10.77.7.10` and injected `10.77.7.99` A records. <a href="evidence/screenshots/phase5-02-q007-fault-two-a-records.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase5-02-q007-fault-two-a-records.png" alt="Q007 two-record DNS fault" width="900">

## Phase 6 — Repair, Retest, And Clean Up

I removed only the injected address and repeated the query three times; every
response contained only `10.77.7.10`. I then confirmed the wrong address was
absent and `old-files.q007.test` returned RCODE 3 with no answer. The same run
also proved an occupied port stops startup, a malformed packet does not crash
the server, the server thread stops, and the port can be rebound. These eleven
[structured assertions](evidence/q007-run-results.json) completed the isolated
fault, repair, retest, and cleanup path.

The Windows repair previewed and removed only `10.77.7.99`, cleared only the
guest DNS cache, passed three exact-good retests, and confirmed NXDOMAIN for
`old-files.q007.test`.

### Repair And Retest Output

<p><strong>Proof:</strong> PowerShell shows one good record, three exact-good retests, the wrong record absent, NXDOMAIN, and `Phase6Pass=True`. <a href="evidence/screenshots/phase6-01-q007-repair-powershell.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase6-01-q007-repair-powershell.png" alt="Q007 repair and retest" width="900">

### Repaired DNS Manager State

<p><strong>Proof:</strong> DNS Manager shows only `files` pointing to `10.77.7.10`. <a href="evidence/screenshots/phase6-02-q007-repaired-dns-manager.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase6-02-q007-repaired-dns-manager.png" alt="Q007 repaired DNS Manager" width="900">

## Phase 7 — Map The Drill To Windows Operations

The lab deliberately avoided live Windows administration, so I mapped each
step to `Resolve-DnsName`, `nslookup`, `Get-DnsServerResourceRecord`, adapter
DNS inspection, and forwarder inspection in the [operator
runbook](runbooks/q007-windows-dns-failure-triage.md). I added capture-before-
clear guidance because the loopback server has no cache layer, and I kept
every repair behind exact current-state, backup, rollback, and dated approval.
That made the artifact reusable without turning it into permission for a live
change.

### Windows Operator Closeout

<p><strong>Proof:</strong> DNS runs automatically, the zone is non-AD-integrated with updates disabled, only the good record remains, and no default route is present. <a href="evidence/screenshots/phase7-01-q007-windows-operator-validation.txt">Paired evidence note</a>.</p>

<img src="evidence/screenshots/phase7-01-q007-windows-operator-validation.png" alt="Q007 Windows operator validation" width="900">

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

The separately approved Windows cleanup retained the disposable VM in the Off
state. No separate screenshot captured the empty-zone check before shutdown,
so the evidence claim remains limited to what the final image proves.

### Powered-Off VM Retention

<p><strong>Proof:</strong> Hyper-V host PowerShell reports `Q007-DNS01` in the `Off` state. <a href="evidence/screenshots/phase9-02-q007-vm-powered-off-retained.txt">Paired evidence note and limitation</a>.</p>

<img src="evidence/screenshots/phase9-02-q007-vm-powered-off-retained.png" alt="Q007 VM powered off" width="900">

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
- The automated exercise needed no live Windows DNS change or screenshot.
- The isolated Windows practicum reproduced the baseline, fault, exact repair,
  repeated retest, NXDOMAIN, and powered-off retention path without changing
  what the automated core proved.

## Technical Evidence

- [Simulation run sheet](q007-simulation-run-sheet.md)
- [Reusable Windows DNS failure-triage runbook](runbooks/q007-windows-dns-failure-triage.md)
- [Prepared Windows DNS operator practicum](hands-on/q007-windows-dns-operator-practicum.md)
- [Hands-on screenshot plan](hands-on/q007-windows-screenshot-plan.md)
- [Hands-on change-window plan](hands-on/q007-windows-lab-change-window.md)
- [Hands-on rollback plan](hands-on/q007-windows-lab-rollback-plan.md)
- [Claude Fable hands-on plan review](hands-on/q007-claude-fable-practicum-review-2026-07-15.md)
- [Windows hands-on evidence log](evidence/q007-windows-hands-on-evidence-log.md)
- [Windows overflow screenshot details](evidence/q007-windows-evidence-details.md)
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
