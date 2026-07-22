# Recovery Plan — Q011 Phase 7 Controlled Patching

**Written:** 2026-07-20  
**Paired change:** [Phase 7 controlled patching](q011-phase7-controlled-patching-change-window.md)

## Actual Recovery Outcome — 2026-07-20

The package transaction stopped at an unexpected GPG-key import gate. Leonel
declined all three prompts, DNF installed no key, returned `upgrade_exit=1`,
and recorded no transaction after the original installation. Because no
package change or reboot occurred, no kernel or package rollback was needed.
The guest shut down normally, and the host restored Off, disconnected,
Untagged VLAN 0 state with `Phase7RecoveryPass=True`.

This plan is now historical. It does not authorize a DNF retry, key import,
cache cleanup, or package repair. The next possible action is the separately
approved [Phase 7G read-only trust investigation](q011-phase7g-gpg-trust-read-only-investigation.md).

## Starting State

- Q011 is Off, disconnected, Untagged VLAN 0, DVD-empty, checkpoint-free.
- DHCP reservation `192.168.70.140`, NetworkManager autoconnect,
  registration, and BaseOS/AppStream access passed Phase 6.
- Phase 5 contains the pre-patch service/security baseline.
- No current checkpoint, VM export, or image-level backup exists.

The evidence is not a backup. A `dnf` upgrade can change many packages and is
not treated as safely reversible by one generic undo command.

## Recovery Triggers

- preflight, DHCP, SSH, registration, repository, disk, or service gate fails;
- `dnf check-update` has an unexpected exit;
- the upgrade returns nonzero or is interrupted;
- VMConnect is lost and the one transaction cannot be accounted for;
- the guest does not boot the updated kernel;
- SSH does not return automatically after reboot;
- SELinux is not Enforcing or `sshd`/`firewalld` is inactive;
- unexpected failed units appear; or
- final isolation cannot be proved.

## Before The Upgrade Starts

If a gate fails before `dnf upgrade`, do not run the transaction. Shut down
normally when possible, disconnect only Q011, restore Untagged VLAN 0, and
record the failed gate. No package recovery is needed.

## Upgrade Failure Before Reboot

Do not rerun the upgrade or use `dnf history undo`. Retain only:

```bash
sudo dnf history list --reverse | tail -5
sudo dnf history info last
systemctl --failed --no-legend --plain
```

If the guest remains stable, shut it down normally. Otherwise use Hyper-V
**Turn Off** only if normal shutdown cannot complete and Leonel separately
confirms the containment action. Leave the VM Off and disconnected for a new
diagnostic approval.

If VMConnect was lost, reconnect to the same Q011 console and do not start a
second package command. Check first for the approved process and its last
history result:

```bash
pgrep -a -f '[d]nf upgrade --refresh'
sudo dnf history info last
```

Allow an active approved process to finish. Treat an incomplete or failed
history result as containment evidence, not authority to retry or repair.

## Updated Kernel Does Not Boot

Keep VMConnect available. If GRUB lists a previously installed kernel, select
that prior kernel once and verify `uname -r`, storage, SELinux, and system
health. Do not erase the new kernel or change the GRUB default in this window.

If no prior kernel boots, leave Q011 Off and disconnected. The recovery path
is a separately approved rebuild from the verified RHEL 10.2 ISO and retained
Phase 4–6 evidence. Do not attach the ISO, replace the VHDX, or delete the VM
under this recovery document alone.

## Guest Boots But Validation Fails

Do not weaken SELinux, disable firewalld, edit SSH, remove packages, or run a
second update. Capture the failed unit or service name, then shut down and
isolate Q011. A later diagnosis can decide between a targeted supported repair,
previous-kernel boot, or clean rebuild.

## Contain A Guest That Does Not Shut Down

If the three-minute normal-shutdown wait expires, do not automatically use
Hyper-V **Turn Off**. Disconnect only Q011's adapter and restore it to Untagged
VLAN 0 while the VM remains running. Verify that network containment, then
leave console-only diagnosis or forced power-off for separate confirmation.

## Restore The Hyper-V Safety Boundary

After Q011 is Off:

```powershell
$VmName = 'Q011-RHEL102-BASELINE'
Disconnect-VMNetworkAdapter -VMName $VmName
Set-VMNetworkAdapterVlan -VMName $VmName -Untagged
```

Verify the VM is Off, its only adapter is disconnected and Untagged VLAN 0,
the DVD is empty, and checkpoint count is zero. Keep the DHCP reservation,
autoconnect setting, and registration unless a later exact approval says
otherwise.

## Point Of No Return

The package transaction is the practical non-atomic boundary. Once it alters
packages, this window promises containment and evidence, not a blind complete
rollback. That limitation must be accepted explicitly with Phase 7 approval.
