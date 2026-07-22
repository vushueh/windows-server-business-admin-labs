# Q011 Phase 7 — Controlled Patching Stop Evidence

**Executed:** 2026-07-20  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** stopped at the GPG trust gate before package modification; recovery
isolation passed

## Scope And Approval Boundary

Leonel approved the reviewed Phase 7 change window exactly as documented. It
allowed a fresh safe-state preflight, temporary Access VLAN 70 attachment, the
proved reserved DHCP/SSH path, a pre-update baseline, one interactive package
transaction at VMConnect, one reboot only after success, screenshots, and
final isolation. It did not permit an unexpected GPG-key import, a second
transaction, package-cache cleanup, or another system change.

## Preflight And Baseline

The host preflight returned `Phase7PreflightPass=True`: Q011 was Off with one
disconnected Untagged VLAN-zero adapter, empty DVD, zero checkpoints, and
874.1 GiB free on `D:`. After only Q011 was attached to Access VLAN 70 and
started, its existing profile automatically restored `192.168.70.140/24` and
gateway `192.168.70.1`; Windows 11 SSH proved `leonel@q011-rhel01`.

The compact baseline then proved RHEL 10.2, running and sole installed kernel
`6.12.0-211.7.3.el10_2.x86_64`, SELinux Enforcing, system state `running`, zero
failed units, active `sshd` and `firewalld`, 34,927,476,736 available root
bytes, registration, enabled BaseOS/AppStream repositories, and
`check_update_exit=100`.

## Reviewed Transaction

At VMConnect, Leonel accepted the documented no-image-backup point of no
return and ran one interactive `sudo dnf upgrade --refresh` command. Before
answering its transaction prompt, the summary showed five new kernel packages,
88 upgrades, zero removals or downgrades, 560 MiB total, and only the approved
BaseOS/AppStream repositories.

## GPG Trust Stop

After package download, DNF requested three public keys from the locally
configured `/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release` file:

| Prompt | Displayed fingerprint | Operator result |
|---|---|---|
| Red Hat release key 2, `FD431D51` | `567E 347A D004 4ADE 55BA 8A5F 199E 2F91 FD43 1D51` | Declined |
| Red Hat auxiliary key 3, `5A6340B3` | `7E46 2425 8C40 6535 D56D 6F13 5054 E4A4 5A63 40B3` | Declined |
| Red Hat release key 4, `05707A62` | `FCD3 55B3 0570 7A62 DA14 3AB6 E422 397E 50FE 8467 A2A9 5343 D246 D627 6AFE DF8F` | Declined |

The approved stop condition required every prompt to be answered `N`. DNF
reported that it did not install any keys, failed the GPG check, retained the
downloaded packages in cache, and returned `upgrade_exit=1`. The operator
accidentally pasted the prose label `Then run:`, which produced only
`-bash: Then: command not found`; the intended read-only history commands ran
immediately afterward.

DNF history still contained only transaction `1`, the original 457-package
installation from 2026-07-19. No new package transaction was recorded, no key
was accepted, no reboot occurred, and no package modification was observed.
The retained cache was not cleaned or reused.

## Recovery And Final State

The guest remained healthy, so Leonel shut it down normally without rebooting.
The Hyper-V host disconnected only Q011 and restored Untagged VLAN 0. Final
proof shows Off, one disconnected adapter, empty DVD, zero checkpoints,
automatic checkpoints disabled, Automatic Start Action `Nothing`, and
`Phase7RecoveryPass=True`.

## Visual And Integrity Evidence

The [Phase 7 visual walkthrough](q011-phase7-visual-walkthrough.md) displays
all five reviewed captures. The
[screenshot manifest](q011-phase7-screenshots.sha256) records their exact
SHA-256 values. No password, subscription identity, consumer UUID,
organization value, token, private key, or authenticated URL is visible.

## Claim Boundary

Phase 7 proves a healthy registered pre-update baseline, updates available
from the intended repositories, a reviewed proposed transaction, effective
fail-closed handling of an unapproved GPG-key import, unchanged recorded DNF
history, and safe recovery isolation. It does **not** prove that the cached
RPMs are trusted, that the local key file matches the official Red Hat key
set, that any key is installed in RPM's trust database, that patching
succeeded, that the new kernel boots, or that the guest is current.
