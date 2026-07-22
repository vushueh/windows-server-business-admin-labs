# Q011 Phase 7K — Bounded Claude Review

**Review date:** 2026-07-21  
**Reviewer:** Claude Fable through the verified direct local CLI bridge  
**Scope:** read only the Phase 7K change-window and rollback documents  
**Initial verdict:** `CONDITIONAL`  
**Live authority:** none

**Execution update:** Leonel later approved and completed the corrected
window. `Phase7KTrustPass=true` and `Phase7KEndStatePass=True`; the rollback
was not required, and no DNF command or package transaction ran. See the
[execution evidence](q011-phase7k-evidence.md).

## Review Boundary

Claude received one exact objective: assess whether the proposed RPM trust
repair was exact, rollback-capable, and guaranteed to stop before DNF. The
bridge allowed only Claude's `Read` tool against the two named Q011 documents.
It prohibited edits, shell commands, live-system or credential access, key
import, DNF, VM/network action, Git, GitHub, approvals, and callbacks.

The first call could read the bounded request but needed the exact Q011 docs
path. One clarification supplied only that path. Claude then read the two
allowed files and returned its review. No peer-produced edit was accepted
without Codex inspection.

## Findings And Dispositions

| Severity | Finding | Codex disposition |
|---|---|---|
| Medium | The prose promised automatic rollback, but import failures returned to the operator and depended on a separate pasted block. | Accepted. The import block now defines and invokes rollback in the same shell whenever the post-import set or signature gate exits `23` or `24`. It prints and requires the rollback result. |
| Medium | Rollback parsed an assumed colon-delimited `rpmkeys --list` display. | Accepted. Codex verified upstream RPM implements list as `VERSION-RELEASE: SUMMARY` and delete as an erase of `gpg-pubkey-KEYHASH`. The revised rollback does not parse display text; it requests exact `%{VERSION}-%{RELEASE}` handles through RPM query format, syntax-gates every handle, deletes only those entries, and rechecks both native list and package query as empty. |
| Medium | Post-import checks used short IDs rather than the published full fingerprints. | Accepted control objective; resolved with the stronger existing identity chain. The run sheet now states that short IDs are not standalone authentication. Import is allowed only after `rpm -V redhat-release` passes and the exact package-owned input matches its pinned SHA-256. BaseOS/AppStream point to that file; Phase 7 displayed the three configured-source fingerprints, and Phase 7G matched them with Red Hat's published record. Post-import IDs and exact three queried handles prove only the resulting set from that anchored input. |
| Low | Counting every non-empty list line could reject a legitimate multiline certificate display. | Accepted. The exact set count now comes from distinct RPM key-package handles, not human-readable list lines. |
| Low | The import block inherited three path variables from the earlier shell block. | Accepted. The exact key and two cached sample paths are restated immediately before the functions. |
| Low | `grep -q` under `pipefail` could cause a false support-probe failure through early pipe closure. | Accepted and broadened. Support and signature probes now let `grep` consume their complete input and redirect matched output instead of using `-q`. |
| Low | The final PowerShell block did not set terminating error behavior. | Accepted. Phase 7K-E now begins with `$ErrorActionPreference = 'Stop'`. |

## Independent Verification

Codex independently inspected both scripts and the upstream
[RPM keyring manual](https://rpm.org/docs/4.20.x/man/rpmkeys.8). The manual
defines `rpmkeys --delete KEYHASH`; the upstream `rpmkeys.c` implementation
constructs list output from `%{version}-%{release}: %{summary}` and maps delete
operands to `gpg-pubkey` erasures. That behavior is visible in the
[upstream source](https://github.com/rpm-software-management/rpm/blob/rpm-4.20.x/tools/rpmkeys.c).
The corrected plan uses the machine-readable RPM query instead of scraping
that display.

Every path still stops before DNF. Neither the change window nor rollback
contains a DNF command, metadata refresh, download, install/update, cache
clean, or repository edit. A successful repair retains only the verified trust
entries, isolates Q011, and stops. The package retry remains a later exact
approval.

## Residual Risks Retained Honestly

- A lost SSH session or abandoned operator workflow after import can leave
  trust entries present until an exact recovery and host isolation are run.
  The same-block rollback closes ordinary command/gate failures but cannot
  guarantee execution after transport loss.
- If RPM's explicit key-package query itself fails after a partial import, the
  plan refuses a broad erase, contains the VM network, and requires a separate
  exact recovery instead of guessing.
- Verification authenticates the same two repository-scoped cached samples,
  not all 93 cached RPMs.
- Successful key repair is not patch success. No DNF operation is included or
  implied.

## Final Preparation Result

The conditional findings were incorporated or resolved through a stronger
verified control. The corrected documents are safe to retain as a
repository-only future change window. They do not authorize starting Q011,
attaching VLAN 70, importing a certificate, running DNF, or changing Git or
GitHub.
