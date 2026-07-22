# Q011 Phase 8 — Bounded Claude Review

**Date:** 2026-07-21  
**Reviewer:** Claude Fable through the approved direct read-only CLI bridge  
**Scope:** exactly the Phase 8 validation run sheet and containment plan  
**Initial verdict:** `CONDITIONAL`  
**Final disposition:** all six findings resolved or explicitly anchored

## Review Boundary

Claude was allowed to read only:

- `docs/q011-phase8-postpatch-validation-and-rebuild-evidence.md`; and
- `docs/q011-phase8-failure-containment.md`.

Claude made no edit and performed no shell, network, VM, Hyper-V, SSH,
OPNsense, Git, GitHub, or credential action. Codex remained responsible for
verification and every resulting local edit.

## Findings And Dispositions

| Severity | Finding | Disposition |
|---|---|---|
| Medium | Locked-root status may render as `L` or `LK` across shadow-utils output. | Accepted. Phase 5 actually recorded `L`; the Phase 8 gate now records the raw token and accepts only semantic locked states `L` or `LK`. |
| Medium | OpenSSH may render the legacy `without-password` alias as `prohibit-password`. | Accepted. Phase 5 actually recorded `without-password`; Phase 8 now accepts only those two semantically equivalent no-password-root tokens and still records the observed value. |
| Medium | Exact spaces in `subscription-manager` Repo ID output were brittle; DNF history command matching also needed evidence anchoring. | Accepted for repository parsing: both gates now use anchored whitespace-tolerant regex. The exact history command remains `upgrade --refresh` because Phase 7P evidence recorded that literal command; the reason is stated in the run sheet. |
| Low | Shutdown polling could evaluate a stale VM object at the deadline. | Accepted. The block now refreshes `Get-VM` immediately before deciding that shutdown timed out. |
| Low | Diagnostic output indexed adapter/DVD element zero even when a count gate could fail. | Accepted. Preflight and final-state reporting now compute guarded `Disconnected` and `DvdEmpty` values before indexing. |
| Low | A post-start attachment verification failure could throw while Q011 remained attached. | Accepted. The failure path now immediately disconnects only Q011, restores Untagged mode, and explicitly hands off to containment without forcing power Off. |

## Residual Risks

- The accepted Phase 5 baseline still permits password SSH while Q011 is
  temporarily on VLAN 70; Phase 8 does not claim SSH hardening.
- The ASA-Off/no-competing-work gate remains a human attestation.
- A shutdown timeout intentionally leaves a contained but powered-on guest
  until separately approved action.
- Exact comparisons remain dependent on correctly transcribed Phase 5 and
  Phase 7P evidence; a mismatch stops rather than repairs the guest.

## Result

After correction, the Phase 8 package remains least-privilege and
guest-read-only. It has explicit host preflight, attachment containment,
semantic control comparisons, normal shutdown, final isolation, safe image
planning, and a separate approval boundary. This review is not authority to
start or attach Q011.

Codex's independent post-review audit also corrected an overbroad "no DNF"
statement that conflicted with the exact local `dnf -q history info 2` lookup,
and strengthened the firewall-services and LVM-name gates to compare the full
Phase 5 sets rather than partial presence.
