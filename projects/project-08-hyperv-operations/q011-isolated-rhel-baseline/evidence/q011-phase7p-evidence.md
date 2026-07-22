# Q011 Phase 7P — Controlled Patch Retry And Reboot Evidence

**Executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** one DNF transaction succeeded, the newest installed kernel booted,
the final update check returned zero, and Hyper-V isolation passed

## Scope And Approval Boundary

Leonel approved the independently reviewed Phase 7P window exactly as
documented. It allowed fresh host and guest gates, temporary Q011-only Access
VLAN 70 attachment while the conflicting ASA remained Off, one supervised
interactive `dnf upgrade --refresh` transaction at VMConnect, one reboot,
read-only validation, safe screenshots, normal shutdown, and exact final
isolation. It did not allow a second package transaction, new key import,
cache cleanup, package removal, kernel erasure, repository or service edits,
checkpoint/export creation, ISO attachment, another VM, or Git/GitHub action.

## Starting Gates

The host preflight returned `Phase7PPreflightPass=True` with Q011 Off, one
disconnected Untagged VLAN-zero adapter, empty DVD, zero checkpoints, 37.8 GiB
free memory, 873.1 GiB free on `D:`, zero transitioning VMs, and the intended
external `vSwitch-LAN` target. Only Q011 was then attached as Access VLAN 70
and started; `Phase7PAttachmentPass=True` verified the exact host state.

Without manual NetworkManager activation, Windows 11 SSH reached
`leonel@q011-rhel01` at `192.168.70.140/24` with gateway `192.168.70.1`.
Guest readiness proved:

- RHEL 10.2 with running kernel `6.12.0-211.7.3.el10_2.x86_64`;
- exactly the Phase 7K three-certificate trust set;
- both retained cached samples still authenticated;
- system state `running`, zero failed units, active `sshd` and `firewalld`,
  and SELinux `Enforcing`;
- 34,338,951,168 available root bytes;
- registration plus BaseOS/AppStream enabled;
- no active package-manager process;
- DNF history still ending at original installation transaction `1`; and
- `check_update_exit=100` with `Phase7PGuestPreflightPass=true`.

## Reviewed Transaction

At VMConnect, Leonel explicitly accepted that no current checkpoint, VM
export, or image-level backup existed. The current repository proposal showed:

- five installs;
- 89 upgrades;
- zero removals or downgrades;
- only RHEL 10 BaseOS/AppStream sources;
- 560 MiB total and 104 MiB to download; and
- candidate kernel `6.12.0-211.37.1.el10_2.x86_64`.

The 89-upgrade proposal superseded the earlier Phase 7 observation of 88
upgrades because repository content had advanced. The reviewed Phase 7P gate
intentionally evaluated the current proposal rather than assuming the old
package set. No new GPG-key prompt appeared. DNF completed the one approved
transaction.

## Exit-Capture Deviation And Recovery

Immediately after `Complete!`, the shell assignment intended to retain `$?`
was mistyped. Bash attempted to execute `0`, so the original immediate
`upgrade_exit` variable was lost. No package or system mutation resulted from
that typo, and no second DNF transaction was run.

Phase 7P stopped before reboot and used only read-only DNF history and RPM
queries to remove ambiguity. They proved:

- transaction ID `2` followed original transaction `1`;
- action types were install and upgrade, with 94 packages altered;
- `Return-Code: Success`;
- command line `upgrade --refresh`;
- distinct begin and end RPM database hashes;
- both old and new kernel packages remained installed; and
- newest candidate kernel `6.12.0-211.37.1.el10_2.x86_64`.

The recovered structured result therefore recorded
`transaction_verification_source=dnf-history`,
`upgrade_exit_capture=lost-after-success`, `history_return_code=Success`,
`new_kernel_present=true`, and `Phase7PTransactionPass=true`. This is
stronger and more honest than reconstructing an unobserved shell variable.

## Reboot And Post-Patch Validation

Leonel performed the one approved normal reboot. Q011 returned automatically
at its reserved address without manual `nmcli`, and the running kernel matched
the newest installed kernel:
`6.12.0-211.37.1.el10_2.x86_64`.

The post-reboot result proved RHEL 10.2, system state `running`, zero failed
units, active `sshd` and `firewalld`, SELinux `Enforcing`, the exact retained
three-key trust set, valid registration, enabled BaseOS/AppStream repositories,
and `post_check_update_exit=0`. The combined result returned
`Phase7PControlsPass=true`, disposition `CurrentAtFinalCheck`, and
`Phase7PPostRebootPass=true`.

## Final Isolation

Leonel shut the guest down normally. Elevated host verification then
disconnected only Q011 and restored Untagged VLAN 0. Final proof returned:

- VM state `Off`;
- exactly one disconnected adapter;
- `OperationMode=Untagged` and `AccessVlanId=0`;
- empty DVD;
- zero checkpoints;
- automatic checkpoints disabled;
- Automatic Start Action `Nothing`; and
- `Phase7PEndStatePass=True`.

## Visual And Integrity Evidence

The [Phase 7P visual walkthrough](q011-phase7p-visual-walkthrough.md) uses all
four reviewed screenshots. The original transaction-review source was named
`011-phase7p-process-01-transaction-review.png`; its canonical evidence copy
adds only the missing leading `q`, with identical bytes and SHA-256. The
[screenshot manifest](q011-phase7p-screenshots.sha256) records every retained
hash.

No screenshot contains a password value, sudo prompt, Red Hat consumer or
organization identity, token, private key, authenticated URL, or unrelated VM
inventory.

## Claim Boundary

Phase 7P proves one supported package transaction succeeded, the newest
installed kernel booted, the required controls stayed healthy, no additional
updates were reported at the final check, and Hyper-V isolation was restored.
It does **not** prove long-duration stability, backup/restore, hardened SSH
policy, complete rebuild replay, or production readiness. Phase 8 must compare
the post-patch controls with the Phase 5 baseline and preserve a reproducible
manual rebuild record.

