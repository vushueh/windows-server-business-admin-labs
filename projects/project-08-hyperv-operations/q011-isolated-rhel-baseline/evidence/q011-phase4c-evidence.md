# Q011 Phase 4C — Disconnected RHEL Installation Evidence

**Date:** 2026-07-19  
**Host:** `WIN-PRQD8TJG04M`  
**VM:** `Q011-RHEL102-BASELINE`  
**Executor:** Leonel through Hyper-V Manager, VMConnect, elevated Windows
PowerShell, and the local RHEL console  
**Result:** pass; RHEL installed and VM retained Off, disconnected, DVD-empty,
and checkpoint-free

## Objective And Approval Boundary

Install RHEL 10.2 from the verified local DVD without attaching any virtual
switch. The approved window allowed the exact fresh preflight, one first
power-on, Minimal Install, automatic LVM, hostname `q011-rhel01`, one local
`leonel` administrator, locked root password, no registration, pre-reboot DVD
ejection, local-console verification, screenshot capture, normal shutdown, and
the exact final host check. It did not allow networking, registration,
packages, updates, checkpoints, another VM, Git, or GitHub.

## Fresh Preflight And Installation

The first preflight attempt stopped because the exact operator-confirmation
value was not accepted. Leonel manually typed the ASCII confirmation on the
approved retry. The fresh result then proved the VM was Off, Generation 2,
2-vCPU, 6-GiB-static, disconnected, checkpoint-free, and attached to the exact
60-GiB VHDX and verified RHEL DVD. Host headroom remained 38.2 GiB free memory
and 876.9 GiB free on `D:` with no transitioning VM; `Phase4CPreflightPass=True`.

Leonel used VMConnect to install RHEL 10.2 with Minimal Install, the one 60-GiB
Microsoft virtual disk, automatic LVM, no encryption, root disabled, and a
password-protected `leonel` administrator. The summary tile continued to say
`Unknown` while disconnected, so Leonel reopened the Network & Host Name page
and directly proved `q011-rhel01`, `eth0` unplugged, and no address or DNS
before selecting **Begin Installation**. The local password was never retained
in chat, a screenshot, or the repository.

## ISO Ejection Stop And Resolution

At the completed installer screen, the exact pre-eject gate passed. The
documented `Set-VMDvdDrive -Path $null` preview and change ran, but the
immediate post-change query still returned the ISO path and safely reported
`Phase4CEjectPass=False`. Leonel did not reboot.

The separately approved exact-controller inspection then found the same SCSI
0:1 DVD path already empty before any retry command could run. The guard
stopped the retry, so no second detach occurred. A final read-only proof
recomputed the full 11,059,986,432-byte ISO SHA-256, matched the published
`e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5`,
and returned `Phase4CAlreadyEjectedPass=True`. This demonstrates an
asynchronous visibility delay, not a failed detach or a changed ISO.

## Guest Verification

The VM booted the installed disk with no media attached. VMConnect rejected
the long **Type clipboard text** payload and emitted `atkbd` unknown-key
messages, so Leonel stopped using clipboard injection. He ran the same
read-only assertions as short manual commands and supplied cropped console
evidence.

The combined outputs proved:

- `Red Hat Enterprise Linux release 10.2 (Coughlan)` and hostname
  `q011-rhel01`;
- SELinux `Enforcing`, system state `running`, and zero failed units;
- root password status `L`, the installed shadow-utils code for locked, and
  `leonel` in `wheel`;
- no global IPv4 or IPv6 address, no default route, and `eth0` unavailable;
- `/dev/sda3` as the LVM physical volume, volume group `rhel`, logical volumes
  `home`, `root`, and `swap`, and `/` on `/dev/mapper/rhel-root` with XFS; and
- no consumer certificate and Subscription Manager reporting the system was
  not registered.

The exact values are retained in the
[sanitized results](q011-phase4c-sanitized-results.txt). The aggregate marker
`CombinedManualVerificationPass=True` is explicitly an operator-reviewed
summary of those visible commands, not a substitute for their outputs.

## Normal Shutdown And Final State

Leonel ran `sudo systemctl poweroff` inside the guest. The final elevated host
query proved `State=Off`, one disconnected adapter, the exact VHDX, an empty
DVD, zero snapshots, automatic checkpoints disabled, Automatic Start Action
`Nothing`, and `Phase4CEndStatePass=True`.

No network, registration, package, update, checkpoint, backup, another VM,
repository, Git, or GitHub change occurred.

## Screenshot Selection And Safety

Seven reviewed PNGs were copied byte-for-byte. The project README displays
only the Installation Summary and final offline verification images. The
[visual walkthrough](q011-phase4c-visual-walkthrough.md) uses the RHEL Welcome,
completion, DVD-empty, VMConnect-input limitation, and offline network images
as supporting proof. Exact hashes are in the
[screenshot manifest](q011-phase4c-screenshots.sha256).

The intended boot-menu screenshot was missed, so the Welcome screen is named
and described honestly rather than relabeled. The Network & Host Name capture
was excluded because it displayed the adapter hardware address. Three
diagnostic captures containing sudo password-prompt text were also excluded;
none contained the password itself. No retained image exposes a password,
token, registration value, notification, public address, or unrelated VM.

## Claim Boundary

Phase 4C proves only the disconnected installation and the verified final
state above. It does not prove patch currency, OpenSSH reachability, firewalld
policy, VLAN isolation, subscription entitlement, backup, final hardening, or
production readiness. Those claims remain later, separately approved Q011
work.
