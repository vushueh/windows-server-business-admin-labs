# Q011 Phase 4C — Bounded Claude Review

**Date:** 2026-07-19  
**Mode:** one read-only direct-bridge consultation  
**Result:** conditional pass; no Critical or High finding  
**Live access or mutation:** none

## Review Scope

Codex asked Claude to review only the Phase 4C disconnected-installation run
sheet, failure-containment plan, screenshot plan, project README, and the
Phase 4B frozen-state run sheet. Claude had repository read/search tools only.
The review covered least privilege, offline isolation, installer choices,
credential handling, pre-reboot ISO ejection, guest and host verification,
failure containment, and screenshot evidence.

## Findings And Dispositions

| Finding | Disposition |
|---|---|
| `subscription-manager` might not be included by RHEL 10.2 Minimal Install, so requiring the command could create an unnecessary failure | Accepted and made package-independent. The final check now requires the local Red Hat consumer certificate to be absent and treats a successful `subscription-manager identity` as a conflict only when the command exists. Command absence is recorded, not repaired. |
| Two `$VhdPath` assignments used avoidable PowerShell backtick continuation | Accepted. Both values are now single-line literals, removing trailing-whitespace risk. |
| The preflight repeats media/boot checks before and after sampling and operator confirmation | Retained intentionally. The second read closes the normal time-of-check/time-of-use gap and is part of the fail-closed design. |

Claude explicitly found the following areas sound:

- the fresh Off-state preflight and frozen Phase 4B setting checks;
- Minimal Install, automatic LVM expectation, root lock, local administrator,
  no-registration, and offline installer choices;
- the order of pre-eject gate, `-WhatIf`, exact ISO detach, post-eject proof,
  and only then installer reboot;
- the read-only Bash assertions and multiple independent network-isolation
  checks;
- the final normal shutdown and host Off/disconnected/DVD-empty proof;
- the pre-write versus post-write containment boundary; and
- the two-primary plus three-supporting screenshot design.

## Independent Codex Verification

Codex checked Red Hat's current RHEL 10 documentation rather than assuming a
specific Minimal Install package list. Red Hat documents that Minimal Install
contains only essential packages and that registration uses Subscription
Manager or other registration paths. The revised check therefore avoids
installing or depending on an optional command and checks only local identity
state.

After applying the accepted corrections:

- all three embedded Windows PowerShell blocks parse with Windows PowerShell
  5.1 and report zero parser errors;
- the embedded Bash block passes `bash -n`;
- the ISO-ejection block still targets one named VM and one attached DVD;
- the live window remains separately approval-gated; and
- `git diff --check` passes.

## Safety Result

This consultation and its corrections changed repository documentation only.
No Hyper-V host, VM, VHDX, ISO, network, credential, Git commit, push, merge,
or GitHub setting was accessed or changed. Phase 4C first power-on remains
blocked pending Leonel's separate exact approval.

