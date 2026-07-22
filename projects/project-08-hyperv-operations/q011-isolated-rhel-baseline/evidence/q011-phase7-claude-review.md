# Q011 Phase 7 — Bounded Claude Review

**Reviewed:** 2026-07-20  
**Reviewer:** Claude Fable, invoked as Codex's read-only peer  
**Scope:** Phase 7 change window, recovery plan, Q011 README, and Phase 6
starting-state evidence  
**Result:** conditional approval corrected and resolved locally

## Review Boundary

Claude received one objective and read-only access to four named Q011 files.
It was forbidden from editing, using a shell, accessing a live system,
handling credentials, invoking another agent, or performing Git/GitHub work.
The peer response is advisory; Codex independently checked every material
finding before changing the draft.

## Findings And Dispositions

| Severity | Finding | Disposition |
|---|---|---|
| High | Running the package transaction over SSH exposed it to session loss and a partially applied RPM state. | Accepted. The actual transaction now runs interactively at VMConnect. SSH remains only for short read-only baselines and validation. Lost-console recovery accounts for the one process before any other action. |
| Medium | Unattended `-y` contradicted the stop condition for unexpected products, removals, repositories, or GPG keys. | Accepted. `-y` was removed. Leonel must inspect the complete DNF transaction and answer its prompt interactively. |
| Medium | Post-reboot exit `100` could not prove when pending updates were published. | Accepted. Exit `100` now records the safe package list and stops without making a timing claim or running a second upgrade. |
| Medium | The 10-GiB root-space requirement relied on visually interpreting `df -h`. | Accepted. The pre-update block now computes available bytes and prints `root_space_pass`. |
| Medium | A shutdown timeout could leave the running guest connected to VLAN 70. | Accepted. The exact final block now disconnects only Q011 and restores Untagged VLAN 0 before stopping for separate power-state approval. |
| Low | The pre-update screenshot could retain unrelated scrollback. | Accepted. Capture instructions require cropping above the sanitized Boolean registration/repository lines. |
| Low | Pasting the entire confirmation block could make `read` consume the next command. | Accepted. The run sheet requires answering the point-of-no-return prompt interactively, not pasting the block whole. |
| Low | Final-object spacing was cosmetically inconsistent. | Accepted and aligned without changing behavior. |

## Independent Verification

- Phase 6 retained-state assumptions match the Phase 6 evidence.
- The change window no longer contains `dnf upgrade --refresh -y`.
- The actual package transaction is explicitly excluded from SSH.
- Root-space, repository, registration, service, update, reboot, and final
  isolation gates remain fail closed.
- The recovery plan still calls evidence **not** a backup and promises
  containment, not universal package reversal.
- Extracted Bash blocks pass `bash -n`.
- All embedded PowerShell blocks parse with zero errors under Windows
  PowerShell 5.1.
- Local links and `git diff --check` pass.

## Final Review Result

The High and Medium findings are resolved. The Phase 7 package is safe to
present for a separate exact hands-on approval, subject to the documented
no-image-backup risk and point-of-no-return confirmation. This review does not
authorize live execution, a package transaction, VM/network attachment,
credential use, commit, push, merge, or publication.
