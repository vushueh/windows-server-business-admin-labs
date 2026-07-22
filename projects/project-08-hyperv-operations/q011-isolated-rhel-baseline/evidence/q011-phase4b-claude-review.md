# Q011 Phase 4B — Bounded Claude Review

**Date:** 2026-07-19  
**Mode:** read-only repository review  
**Verdict:** conditional pass, corrected to ready for separate live approval  
**Live access or changes:** none

## Review Scope

Claude reviewed only the Phase 2C frozen design, Phase 4B change window,
rollback plan, screenshot plan, project README, and the Q011-02 review item.
The request explicitly prohibited edits, shell commands, live host/network
access, credentials, commits, pushes, merges, GitHub actions, and recursive
consultation.

The review challenged Windows Server 2022/PowerShell 5.1 Hyper-V properties,
GUI labels, resource gates, `Zone.Identifier` behavior, DVD-first validation,
exact-object rollback provenance, and the two-image evidence design.

## Findings And Dispositions

| Severity | Finding | Codex disposition |
|---|---|---|
| Critical | None | No action required |
| High | None | No action required |
| Medium | A disk-inventory mismatch safely stopped rollback but did not explicitly tell the operator what approval was needed next | Accepted. The rollback decision path and exception now require a fresh exact-object inspection/recovery approval and forbid improvised cleanup. |
| Low | The ISO is not hashed a second time after CPU sampling and operator confirmation | Accepted residual risk. The exact 11 GB file is hashed once and then protected by length and high-resolution NTFS timestamp stability checks; a second full read would add avoidable load to the multi-role host. |
| Low | The VM-configuration-path and VHDX-path wizard choices could look contradictory | Accepted. The run sheet now clarifies that the unchecked option controls only the VM configuration path; the VHDX path is selected separately. |

## Independently Verified Agreements

Codex rechecked the reviewed text and accepted Claude's confirmation that:

- the named Hyper-V cmdlets and properties match the intended Windows Server
  2022 / PowerShell 5.1 surface;
- any `Zone.Identifier` stream produces `PreflightPass=False`, with no unblock
  or stream-content operation authorized;
- DVD-first and disk-second firmware checks compare the Generation 2 boot
  device controller coordinates;
- rollback is bounded to the exact Off Q011 VM and frozen VHDX and retains the
  ISO;
- the ISO byte count and SHA-256 are consistent across the design and change
  window; and
- exactly two safe GUI screenshots are planned, both cropped to the Q011
  Settings dialog.

## Final Boundary

The corrected package is ready to present for a separate Phase 4B live
approval. This review did not create a VM or VHDX, attach media, inspect or
unblock the live ISO, start a guest, open a console, connect a switch, access
the Hyper-V host, or authorize Phase 4C. Commit, push, merge, and GitHub actions
also remain outside scope.
