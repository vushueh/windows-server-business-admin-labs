# Q011 Phase 7P — Bounded Claude Review

**Reviewed:** 2026-07-21  
**Model:** Claude Fable through the verified native read-only CLI bridge  
**Files reviewed:** Phase 7P change window and paired recovery plan  
**Initial verdict:** `CONDITIONAL`  
**Final Codex disposition:** all five findings accepted and corrected; ready
to present for a separate exact live approval

## Review Boundary

Claude received one bounded objective and read access only to:

- `docs/q011-phase7p-controlled-patch-retry-change-window.md`; and
- `docs/q011-phase7p-controlled-patch-retry-recovery.md`.

The request prohibited edits, shell execution, live host/VM/network access,
credentials, DNF execution, package/key/cache changes, Git/GitHub actions,
another agent, or authority expansion. No clarification round was needed.

## Findings And Dispositions

### 1. Medium — Shutdown-Timeout Containment Could Not Pass The Off-State Gate

**Finding:** a timeout intentionally leaves the VM power state unchanged after
network isolation, while the final recovery Boolean required `State=Off`.

**Resolution:** both documents now distinguish
`Phase7PNetworkContainmentPass=True` from `Phase7PRecoveryPass=True`. The
timeout branch verifies only disconnected Untagged VLAN 0 state, makes no Off
claim, and requires separate authority for forced power-off. The final
recovery gate runs only after Q011 is actually Off.

### 2. Medium — Updates-Remain Result Had No Explicit Disposition

**Finding:** `post_check_update_exit=100` made the success Boolean false but
the prose did not clearly classify the healthy-reboot/no-currency result.

**Resolution:** post-reboot evaluation now separates control health from
update state and emits one of `CurrentAtFinalCheck`, `UpdatesRemain`,
`RepositoryCheckError`, or `ValidationFailed`. Only `CurrentAtFinalCheck`
passes Phase 7P. `UpdatesRemain` is an explicit controlled stop: record the
safe list, withhold currency claims, run no second transaction, and isolate.

### 3. Medium — Successful Transaction Incorrectly Required A New Kernel

**Finding:** repository content can change, so a valid transaction might no
longer include the kernel proposed during the original Phase 7 attempt.

**Resolution:** transaction success now requires exit `0`, a new DNF history
ID, and a nonempty newest installed-kernel result. A separate
`new_kernel_present` fact records whether the candidate differs from the
pre-transaction running kernel. Either successful case reboots once and must
boot the newest installed kernel.

### 4. Low — Repository/Metadata Error Exit Needed Explicit Handling

**Finding:** the Boolean failed closed, but the prose explained only DNF
check-update exits `0` and `100`.

**Resolution:** any other exit, including `1`, is now explicitly a stop,
normal shutdown, isolation, and failed-gate evidence path.

### 5. Low — Package-Process Pattern Was Too Broad

**Finding:** the original substring pattern could false-match an unrelated
command line containing `dnf` or `rpm`.

**Resolution:** the process gate now matches executable path/name boundaries
for `dnf`, `rpm`, or `yum` while retaining the self-match-avoidance bracket
form.

## Independent Verification

After applying the corrections, Codex:

- parsed every Bash fence with `bash -n`;
- parsed every PowerShell fence with Windows PowerShell 5.1 without executing
  it;
- re-read the changed transaction, reboot-disposition, timeout-containment,
  and recovery sections; and
- confirmed the approval template still names only the documented future
  actions.

## Residual Risk

No checkpoint, VM export, or image-level backup exists. A partially applied
DNF transaction may therefore be unrecoverable within the window. The plan
limits recovery to evidence, one already-installed prior-kernel boot when
available, and network containment; a forced power-off, repair, or rebuild
requires separate authority.

This review is not approval to start Q011, attach networking, run DNF, reboot,
change a package, or perform Git/GitHub operations.
