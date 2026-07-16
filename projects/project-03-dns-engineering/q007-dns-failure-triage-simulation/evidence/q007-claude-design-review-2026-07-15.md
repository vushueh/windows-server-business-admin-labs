# Q007 Claude Fable Design Review — 2026-07-15

- **Mode:** read-only peer consultation initiated by Codex.
- **Model:** Claude Fable.
- **Scope:** Q007 isolated environment, evidence minimum, and completion claim.
**Not authorized or performed:** edits, shell execution, live access,
credentials, commit, push, merge, deployment, or another agent call.

## Verdict

Claude returned a conditional **GO**. It agreed that a Python standard-library
loopback DNS responder is credible because the implementation matrix accepts
existing incident evidence or an isolated DNS VM and because the cheapest
credible environment should win. It required the package to distinguish
protocol-level lab proof from Windows DNS administration.

## Findings And Disposition

| Severity | Finding | Disposition |
|---|---|---|
| High | One extra-A-record fault must not be presented as coverage of the catalog's NIC and forwarder faults. | The run sheet explicitly scopes the exercised fault and links the existing P03 NIC/forwarder evidence and runbook branches. |
| High | A single script serving and reading packets would be self-attesting. | The drill retains raw response hex and a separate verifier independently decodes header fields, RCODE, counts, and A records. |
| Medium | The fault must show user impact, not merely two records. | The wrong address is returned first and the transcript proves a naive client selects it instead of the intended host. |
| Medium | Q007 should not reopen completed P03. | Q007 has its own subfolder, README, scripts, evidence, runbook, and closeout. P03 remains Complete. |
| Medium | The named artifact must be a reusable Windows runbook. | The runbook maps the drill to `Resolve-DnsName`, `nslookup`, DNS record, adapter, forwarder, cache, rollback, and retest procedures. |
| Low | The harness has no cache layer. | The limitation is explicit and the Windows path includes capture-before-clear and post-repair cache handling. |
| Low | The named Windows tools are unavailable for a high-port loopback target. | The run sheet explains the substitution and retains independently decodable packet hex. |

## Required Tests Accepted Into The Plan

- exactly one correct baseline A record;
- wrong and correct records during the fault, with wrong-answer consumption;
- three exact post-repair responses and explicit wrong-address absence;
- NXDOMAIN / RCODE 3 for an unknown name;
- clean abort on port collision;
- malformed-packet survival;
- stopped server and released UDP port after cleanup.

Codex verified these findings against the queue, simulation library, matrix,
P03 evidence, and repository lock. This review grants no live or Git authority.
