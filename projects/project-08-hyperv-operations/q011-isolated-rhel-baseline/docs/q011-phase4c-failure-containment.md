# Q011 Phase 4C — Failure Containment And Recovery Boundary

**Prepared:** 2026-07-19  
**Target:** `Q011-RHEL102-BASELINE` only  
**Purpose:** keep an installation failure inside the disposable disconnected
guest without deleting evidence or widening authority

This plan accompanies the
[Phase 4C installation run sheet](q011-phase4c-disconnected-rhel-installation.md).
It is not a general Hyper-V repair runbook and does not authorize recovery
changes merely because a failure occurs.

## Invariants

- Never attach a virtual switch, VLAN, second adapter, or host network.
- Never change Secure Boot, processor compatibility, memory, disk size, or
  firmware order to bypass a failure.
- Never enable root, reset a password, register RHEL, add a repository, install
  a package, or patch during containment.
- Never create or restore a checkpoint.
- Never delete, rename, replace, compact, mount, or inspect the contents of the
  VM's VHDX during this window.
- Never modify or delete the staged ISO file.
- Never affect another VM, disk, ISO, switch, service, or host setting.

## Stage A — Before `Begin Installation`

No installation writes are authorized yet. If a boot, media, storage,
software-selection, account, hostname, network, or final-summary gate fails:

1. capture one safe failure image if it contains no credential field;
2. use the installer's **Quit** control if available;
3. if the guest returns to the DVD boot menu, select only the Q011 VM in
   Hyper-V Manager and use **Turn Off** while the boot menu is static;
4. confirm the Q011 VM is Off; and
5. stop and report the failed gate.

Do not delete the VM or VHDX. Phase 4B created those objects before this
window, so they are not Phase 4C rollback artifacts.

## Stage B — After `Begin Installation`

Once disk writes begin, the VHDX is evidence and may contain partial state.

1. Do not interrupt a progressing installer merely because it is slow.
2. If the installer displays an error, capture the exact safe error and record
   whether progress stopped.
3. Do not select retry options that change the installation source, package
   set, storage layout, credentials, registration, or networking.
4. Do not force the VM Off while storage activity might still be occurring.
5. Leave the VM and VHDX intact and request a separate exact diagnostic or
   rebuild approval.

There is no automatic destructive rollback after this boundary. A later clean
reinstall would require an explicit decision covering the existing VHDX.

## Stage C — Installation Complete But ISO Ejection Fails

Do not select **Reboot System** unless the exact host block reports
`Phase4CEjectPass=True`.

If the pre-eject gate, `Set-VMDvdDrive`, or post-eject proof fails:

1. leave the installer on its completed screen;
2. do not detach another DVD drive or use a wildcard command;
3. retain the sanitized PowerShell error and one safe console image; and
4. stop for a separately approved exact-object inspection.

The installed system remains on disk. Keeping the completed installer running
is safer than knowingly rebooting into still-attached media.

## Stage D — Unexpected Installer Loop After Ejection

If the RHEL installer boot menu reappears after a passing eject result:

1. do not select **Install**, **Test**, **Rescue**, or a boot-option edit;
2. capture the static boot menu if safe;
3. use Hyper-V Manager **Turn Off** only while the VM is idle at that static
   boot menu; and
4. stop for a new read-only firmware/DVD/VHD inspection approval.

Do not reattach the ISO or change boot order in the same window.

## Stage E — Installed Guest Boot Or Login Fails

If the installed disk does not reach the expected login prompt, or `leonel`
authentication fails:

1. record the visible error without photographing a password entry;
2. do not attempt root login, password reset, rescue boot, single-user mode,
   or media reattachment;
3. if the guest offers a normal shutdown path, use it;
4. otherwise preserve the running or stopped state and request a separate
   recovery decision; and
5. do not delete or replace the VHDX.

## Stage F — Verification Fails

If any guest assertion is false:

1. retain the exact sanitized output;
2. do not repair the hostname, root state, user membership, SELinux, LVM,
   registration, service state, or networking in Phase 4C;
3. use `sudo systemctl poweroff` only if local administrative login works; and
4. stop with the VM Off when possible.

If normal shutdown does not finish within the run sheet's three-minute host
wait, do not use **Turn Off** automatically. Preserve state and request a new
exact approval.

## Recovery Decision After A Stop

The next approval must choose one bounded path based on retained evidence:

- read-only inspection of the exact VM configuration and console symptom;
- in-guest repair of one named failed assertion;
- exact ISO reattachment for a named recovery purpose; or
- destructive replacement of only the Q011 VHDX followed by a fresh install.

None of these paths is pre-approved. The default after any failure is to keep
the guest disconnected and preserve the VM/VHDX.

## Screenshot Safety During Failure

Capture only the Q011 VMConnect or exact Q011 Settings/error pane. Exclude
password prompts, password-quality messages, registration fields, tokens,
host notifications, other VMs, and unrelated desktops. A failure screenshot
must say what it proves and must never be presented as passing evidence.

