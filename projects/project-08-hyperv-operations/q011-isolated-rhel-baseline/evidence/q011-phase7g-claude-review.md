# Q011 Phase 7G — Bounded Claude Review

**Reviewed:** 2026-07-20  
**Reviewer:** Claude Fable, invoked through the verified native Claude CLI  
**Scope:** Phase 7 stop evidence, Phase 7G read-only investigation run sheet,
and paired containment plan  
**Result:** conditional review corrected and resolved locally

## Review Boundary

Codex remained the primary agent. Claude received one objective and a safe
inline packet containing only the three named repository documents. Every
Claude tool was disabled. The peer was forbidden from editing, using a shell,
accessing a live system or credential, invoking another agent, or performing
Git/GitHub work. One clarification round corrected the response format; no
additional consultation occurred.

## Findings And Dispositions

| Severity | Finding | Disposition |
|---|---|---|
| High | The original VLAN/connect/start sequence could start Q011 on the native switch path if VLAN configuration failed silently. | Accepted. Every cmdlet now stops on error, Access VLAN 70 and `vSwitch-LAN` are re-read and required before `Start-VM`, and any failure restores disconnected Untagged VLAN 0. |
| Medium | `dnf history list` launches DNF/plugins and was not structurally free from possible repository-file side effects. | Accepted more strictly. The DNF history command was removed from Phase 7G; unchanged history is already proved by Phase 7 evidence and is not needed for trust diagnosis. No Phase 7G guest command invokes DNF. |
| Medium | The two cached-RPM filenames lacked stated provenance. | Accepted. The run sheet now attributes them to the retained Phase 7 transaction output and requires repository-specific BaseOS/AppStream cache paths. Absence stops without download. |
| Low | Prefer the documented long key-list option. | Accepted. Both RPM tools now use `rpmkeys --list`; the pqrpm binary remains guarded by `test -x`. |
| Low | The fingerprint stop condition sounded like a new guest prompt. | Accepted. Both documents now identify an off-guest comparison between the already-recorded Phase 7 fingerprints and Red Hat's public record. |
| Low | The ASA-off gate was attestation-only and lacked a managed-object name. | Partially accepted with an explicit boundary. The exact managed object is not recorded and is not guessed; the run sheet says discovery is out of scope and requires positive operator confirmation or a stop. |
| Low | The three-minute normal-shutdown wait was prose only. | Accepted. The host block now polls for up to three minutes and restores disconnected Untagged VLAN 0 before stopping if shutdown times out. |

## Independent Verification

- The final start sequence cannot reach `Start-VM` until the exact switch and
  Access VLAN 70 are re-read and pass.
- Phase 7G contains no `dnf`, key-import, package-install, cache-cleaning, file
  editing, repository-refresh, or download command.
- `rpm`, `rpmkeys --list`, `rpmkeys -Kv`, `stat`, `sha256sum`, `awk`, `find`,
  `wc`, `printf`, and `test` only read or format the scoped local state.
- `sudo systemctl poweroff` and the exact Hyper-V network/power steps are
  explicit temporary containment actions in the future live approval, not
  guest trust or package mutations.
- Cached sample variables are quoted, repository-scoped, and required
  nonempty before signature checks.
- The Phase 7 evidence continues to make no claim that cached RPMs are trusted,
  the key file is authentic, patching succeeded, or a new kernel booted.

## Final Review Result

Claude's initial verdict was **Conditional**. Codex independently verified and
resolved the High and Medium findings and incorporated the applicable Low
clarifications. The corrected Phase 7G package is safe to present for a
separate exact live approval. This review is not authority to start Q011,
attach networking, import a key, retry DNF, clean the cache, or perform Git or
GitHub work.
