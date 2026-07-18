# Claude Fable Review — Q007 Windows Operator Practicum

- **Date:** 2026-07-15 MDT
- **Mode:** bounded, read-only peer review
- **Model requested:** Fable
- **Allowed tools:** Read, Glob, and Grep
- **Forbidden:** edits, shell execution, live-system access, credentials,
  commits, pushes, merges, deployment, delegation, and scope expansion
- **Verdict:** **GO after the change-window approval gate**
- **Critical findings:** none
- **High findings:** none

## Review Objective

Independently assess whether the prepared guide provides meaningful Hyper-V,
Windows Server DNS Manager, and PowerShell practice; mirrors Q007's baseline,
extra-record, diagnosis, exact-repair, repeated-retest, NXDOMAIN, and cleanup
lifecycle; and remains isolated from production DNS, AD, DHCP, and existing
Hyper-V networking.

## Findings And Disposition

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| M1 | Medium | Generation 2 ISO boot timing and the safe Secure Boot default were not explained | Resolved: Phase 2 now tells the operator to connect before start, press a key for DVD boot, retry only the Q007 VM if missed, and retain the Microsoft Windows Secure Boot template |
| M2 | Medium | The expected red timeout from the wrong-address ping could look like an exercise failure | Resolved: Phase 5 now identifies the error/timeout as the required result and says to preserve it |
| L1 | Low | DNS client configuration precedes DNS role installation, leaving an expected period without name resolution | Resolved: Phase 3 now forbids adding a public, production, or second DNS server during that expected interval |
| L2 | Low | Baseline and fault records may show different TTL values without explanation | Resolved: Phase 5 explains that direct authoritative full-set checks make TTL irrelevant to the pass criterion |
| L3 | Low | An accidentally absent good record could make the Phase 6 record query error without a nearby recovery pointer | Resolved: Phase 6 now stops and links directly to rollback Level 1 |

## Positive Controls Confirmed

Fable specifically confirmed these controls should remain:

- Phase 0 proves the fixed VM and switch names are unused before creation.
- Fail-closed checks cover adapter count, baseline exactness, bad-address
  liveness, and repeated repaired-state results.
- Record order is explicitly excluded from the pass criterion because same-name
  records may rotate.
- Exact removal includes `-RecordData`; the rollback warns against a name-only
  removal that could delete both records.
- Zone removal waits for evidence acceptance, while VM and switch deletion need
  a separate approval.
- The completed automated Q007 result remains distinct from the prepared,
  unexecuted Windows extension.

## Final Review Statement

Fable found the commands and GUI paths technically correct for Windows
PowerShell 5.1 or later, the Private-switch topology accurately isolated, the
evidence mapping one-to-one with the phases, and the README status boundary
clear. With the five clarifications above applied, there were no remaining
material blockers to handing the guide to Leonel after its explicit approval
gate.

