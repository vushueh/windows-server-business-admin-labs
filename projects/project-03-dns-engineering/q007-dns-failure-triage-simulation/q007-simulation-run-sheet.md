# Simulation Run Sheet — Q007 DNS Failure Triage

- **Queue / simulation ID:** `Q007` / `SIM-N3-DNS`
- **Owning repo:** `windows-server-business-admin-labs`
- **Vault note:** `homelab-obsidian-vault/08-simulations/sim-dhcp-dns-outage-vlan20.md`
- **Stage at execution:** in progress / isolated lab
- **Risk:** ISO
- **Case-study candidate:** yes — input to `CS-001` after Q008
- **Video status:** not recorded

## Design Gates

- [x] **Business scenario first:** an internal file-service name returns an
      extra wrong address, so a client selects the wrong host even though DNS
      still appears to answer.
- [x] **Named evidence artifact:** a sanitized protocol transcript, structured
      result, independent packet verification, and reusable Windows DNS
      failure-triage runbook.
- [x] **Cheapest credible environment chosen:** a disposable Python
      standard-library DNS responder and client bound to loopback.
- [x] **Why this environment is sufficient:** it exchanges real UDP DNS
      packets and exposes the answer set, RCODE, repair, negative retest, and
      cleanup without touching a production resolver. The existing P03
      incident evidence supplies the Windows-specific context.
- [x] **Recording decision:** no video. Text and raw packet hex are the named
      proof, so screenshots and recording would add no required fact.

## Business / Operations Scenario

**Scenario statement:** A user opens an internal file-service name and reaches
the wrong host because DNS returns both the intended A record and a stale extra
A record. The service appears intermittently broken until an operator inspects
the full answer set instead of accepting the first response.

**User impact:** A client can select the stale address and target a host where
the expected file service is unavailable.

**Operational decision this supports:** The drill proves when to inspect the
returned records, how to distinguish a bad record from client or forwarder
configuration, and what positive and negative checks must pass before closure.

## Entry, Dependency, And Lock Checks

| Gate | Evidence | Result |
|---|---|---|
| Queue order | `docs/homelab-goals.yaml` selected Q007 after Q006 | Pass |
| Required dependency | `CUR-B1` / Q002 is Complete | Pass |
| One-primary WIP | Q007 is the current primary; no urgent preemption exists | Pass |
| Owning-repo lock | `CLAUDE-REVIEW.md` has no OPEN Q007 or conflicting claim | Pass |
| Existing incident source | P03 break/fix log records the prior multi-homed DC DNS pollution | Pass |
| Live authority | Not required and not granted | Pass |

## Families And Tools

| Family / Repo | Tool or Service | Role in the simulation |
|---|---|---|
| Windows Server labs | Python 3 standard library | Disposable DNS responder, client, fault control, and evidence writer |
| Windows Server labs | Independent evidence verifier | Decodes saved raw response packets separately from the running harness |
| Windows Server DNS | Existing P03 incident evidence | Grounds the isolated record fault in a real Windows DNS failure |
| Homelab program | Q007 registry and state | Controls entry, completion, and Q008 handoff |

## Tools Intentionally Not Used

- Live Windows DNS, DHCP, AD, or domain controllers — protocol behavior and
  the reusable runbook can be proven without risking household identity.
- Hyper-V or a throwaway VM — the implementation matrix accepts existing DNS
  incident evidence or an isolated DNS VM; loopback is the smaller credible
  environment when combined with the existing incident evidence.
- `nslookup`, `Resolve-DnsName`, and `dig` — the available WSL environment has
  none of these clients, and Windows clients cannot select this nonstandard
  test port. The drill saves raw DNS packet hex and a second script decodes it
  independently. The operator runbook maps the lab steps to Windows tools.
- Screenshots and video — neither is needed to prove packet fields, returned
  records, RCODE, test status, or cleanup.
- External network access — `.test` names, RFC1918 addresses, and loopback keep
  the entire exercise local.

## Cert / Role Mapping

| Cert or Role | What this simulation proves |
|---|---|
| CCNA | DNS request/response interpretation, A-record validation, and failure isolation |
| Security+ | Controlled fault injection, minimum blast radius, evidence, and cleanup |
| Windows / systems administrator | Repeatable DNS triage, exact-record repair planning, cache awareness, and retest |

## Safe Lab Version

```text
Python DNS client
        |
        | UDP query on 127.0.0.1:10553
        v
Disposable authoritative responder
        |
        +-- baseline:  files.q007.test -> 10.77.7.10
        +-- fault:     files.q007.test -> 10.77.7.99, 10.77.7.10
        +-- repaired:  files.q007.test -> 10.77.7.10
        +-- negative:  old-files.q007.test -> NXDOMAIN
```

The server and client are processes in the same script. The saved response
hex remains independently decodable after the process exits. The script is
fail-closed to `127.0.0.1` and a non-privileged UDP port.

## Fault-Scope Decision

Q007 exercises one catalog fault: an extra wrong A record. This satisfies the
queue's singular isolated fault/repair/retest requirement without claiming all
DNS failure modes were executed. The other named catalog classes remain
operational branches in the runbook:

- The prior NIC/DNS-client-order failure was observed and repaired during P03;
  its dated evidence is in the parent project's break/fix log.
- The wrong-forwarder branch is documented there and in the new runbook, but
  it is not structurally present in this single-responder harness.

The project therefore proves record-set diagnosis in isolation and reuses,
rather than repeats, the earlier Windows proof.

## Live-Readonly Checks

None. Existing dated P03 evidence is sufficient for the Windows context. Q007
does not contact a domain controller, DNS server, DHCP server, or client.

## Live-Change Gate

Not applicable to execution. Any later use of the runbook's repair commands on
Windows DNS still requires a fresh change window, current-state discovery,
backup/rollback, exact record or adapter scope, and Leonel's dated approval.

## Evidence Plan

| Evidence | File / Folder | What it proves |
|---|---|---|
| Sanitized protocol transcript | `evidence/q007-sanitized-transcript.txt` | Baseline, malformed input, fault impact, repair, repeated retest, NXDOMAIN, and cleanup |
| Structured run result | `evidence/q007-run-results.json` | Machine-readable test statuses and raw DNS response packets |
| Independent verification | `evidence/q007-closeout-verification.txt` | A second decoder confirms the saved packet fields and answer sets |
| Claude Fable design review | `evidence/q007-claude-design-review-2026-07-15.md` | Independent scope, credibility, and completion challenge |
| SHA-256 manifest | `evidence/q007-evidence-manifest.sha256` | Integrity of the retained evidence and implementation |
| Reusable operator artifact | `runbooks/q007-windows-dns-failure-triage.md` | Windows diagnosis, repair gate, validation, rollback, and fault branches |

## Recording Plan

No recording is required. Raw packet hex, decoded fields, machine-readable
results, and the text runbook prove the selected objective without exposing a
desktop, notifications, or unrelated systems.

## Execution Phases

| Phase | Work | Exit evidence |
|---|---|---|
| 0 | Select and gate Q007 | Queue, dependency, WIP, review lock, and ISO boundary pass |
| 1 | Review the business failure and prior incident | P03 NIC pollution and forwarder branches mapped |
| 2 | Design loopback DNS topology and fault scope | `.test` names, RFC1918 answers, high UDP port, no external flow |
| 3 | Define safety, tests, and named evidence | Stop, failure, cleanup, redaction, and evidence tables complete |
| 4 | Build the responder, client, verifier, and runbook | Scripts parse and bind only to loopback |
| 5 | Establish baseline and inject the fault | Correct single answer becomes wrong-first two-answer set |
| 6 | Diagnose, repair, retest, and clean up | Three positive retests, wrong IP absent, NXDOMAIN, server stopped, port free |
| 7 | Map the lab to Windows operations | Reusable runbook covers record, NIC, forwarder, cache, rollback, and approval gates |
| 8 | Package and independently verify evidence | Transcript, JSON, raw packet decode, review, hashes, and links pass |
| 9 | Close and propagate | Q007 Complete; Q008 selected but not started; Q006 links directly to Q007 |

## Verification

Run from the Q007 directory:

```bash
python3 -m py_compile scripts/q007_dns_drill.py scripts/q007_verify_evidence.py
python3 scripts/q007_dns_drill.py --output-dir evidence
python3 scripts/q007_verify_evidence.py evidence/q007-run-results.json
python3 scripts/q007_dns_drill.py --output-dir /tmp/q007-reverify
python3 scripts/q007_verify_evidence.py /tmp/q007-reverify/q007-run-results.json
```

Required assertions:

- startup fails cleanly while the selected UDP port is occupied;
- the baseline returns exactly `10.77.7.10`;
- one malformed packet is counted and the server still answers;
- the fault returns `10.77.7.99` first and `10.77.7.10` second;
- a naive client selects the wrong first answer;
- three post-repair responses contain only `10.77.7.10`;
- `10.77.7.99` is absent after repair;
- the unknown name has RCODE 3 / NXDOMAIN with no answer;
- the server thread stops and the UDP port can be rebound.

## Rollback, Stop Conditions, And Cleanup

- Stop if the requested bind address is not `127.0.0.1`, the port is
  privileged, the port is already occupied outside the intentional collision
  test, a packet assertion fails, or any external/live system would be needed.
- Repair is an in-memory answer-list replacement. Stopping the process removes
  the entire lab state; there is no persisted zone to roll back.
- Cleanup must stop the server thread and prove the port can be rebound.
- A failed run remains failed; do not edit the transcript to make it pass.

## Evidence Manifest

Filled after execution in `evidence/q007-evidence-manifest.sha256`.

## Portfolio Matrix Row

| Work | Skill Demonstrated | Evidence Link | Draft Resume Bullet | Cert / Role |
|---|---|---|---|---|
| Q007 isolated DNS failure triage | DNS packet analysis, fault isolation, negative testing, safe cleanup, runbook writing | `README.md` and `evidence/q007-sanitized-transcript.txt` | Built a loopback DNS outage drill that injected a wrong A record, demonstrated client impact, repaired it, passed repeated positive and NXDOMAIN tests, and produced a reusable Windows runbook without touching production DNS. | CCNA, Security+, systems administration |

## Case Study Decision

- [ ] Stays as lab evidence only.
- [x] Becomes supporting evidence for case-study candidate `CS-001` after the
      queue-selected Q008 postmortem.
- [ ] Needs more evidence before deciding.

## Open Questions

None. A future live adoption is a separate project and is not required for
Q007 completion.
