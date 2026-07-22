# Q011 Manual Rebuild Record

**Status:** evidence-linked manual record; rebuild not replayed  
**Prepared:** 2026-07-21  
**Baseline:** `Q011-RHEL102-BASELINE` / `q011-rhel01`  
**Platform:** Hyper-V host `WIN-PRQD8TJG04M`

## Purpose And Claim Boundary

This record identifies the proved inputs, choices, sequence, and acceptance
gates needed to manually recreate Q011. It is not an unattended build
artifact, backup, export, image, credential record, or claim that a second VM
was rebuilt. Every material fact links to evidence captured during the actual
Q011 build.

## Prerequisites

- A Hyper-V host compatible with RHEL 10's x86-64-v3 requirement. The earlier
  Proxmox Xeon L5520 candidate failed that gate; the selected Hyper-V Xeon
  E5-2687W v3 host passed. See the
  [imported discovery summary](../evidence/q011-imported-discovery-summary.md).
- At least 8 GiB free host memory and 100 GiB free on the selected Hyper-V
  volume at the change window. Recheck capacity rather than treating the
  historical values as permanent.
- Exact RHEL media `rhel-10.2-x86_64-dvd.iso`, 11,059,986,432 bytes, SHA-256
  `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5`.
  See the [Phase 4A evidence](../evidence/q011-phase4a-iso-staging-evidence.md).
- A separately approved, conflict-free name and VHDX path. Do not overwrite
  the retained Q011 VM or disk.

## Frozen VM Design

Recreate only after a fresh collision/capacity preflight, using the
[Phase 2C design](q011-phase2c-disconnected-vm-design.md) and
[Phase 4B evidence](../evidence/q011-phase4b-evidence.md):

| Setting | Proved value |
|---|---|
| Generation | 2 |
| Processor count | 2 vCPU |
| Startup memory | 6 GiB static; dynamic memory disabled |
| System disk | One 60-GiB dynamically expanding VHDX |
| Secure Boot | On; Microsoft UEFI Certificate Authority |
| Installation media | Exact verified local RHEL 10.2 DVD |
| Boot order during install | DVD first, system disk second |
| Network | Exactly one adapter, initially Not Connected and Untagged |
| Automatic checkpoints | Disabled |
| Automatic Start Action | Nothing |

## Installation Choices

Use the [Phase 4C run sheet](q011-phase4c-disconnected-rhel-installation.md)
and [execution evidence](../evidence/q011-phase4c-evidence.md):

1. Keep the Hyper-V adapter Not Connected for the entire installation.
2. Select Minimal Install from local verified media.
3. Use automatic partitioning with LVM.
4. Set hostname `q011-rhel01`.
5. Keep root disabled/locked.
6. Create local password-protected administrator `leonel`; enter credentials
   only interactively and retain no value.
7. Do not register or enable networking in the installer.
8. After installation completes, detach only the exact DVD, prove the local
   ISO is unchanged, reboot from disk, verify the offline baseline, and shut
   down normally.

Expected installed storage is volume group `rhel`, logical volumes
`home,root,swap`, and root filesystem `/dev/mapper/rhel-root`.

## Controlled Network Identity

The initial VLAN 70 test exposed a conflicting legacy DHCP authority at
`172.16.70.1`. Do not attach a rebuild while that authority is active. Under a
separate network approval and with the conflict contained:

1. attach only the rebuilt guest to `vSwitch-LAN` as Access VLAN 70;
2. use the existing NetworkManager DHCP profile rather than a static guest
   address;
3. create a conflict-free OPNsense Dnsmasq reservation for the rebuilt
   adapter's actual MAC—do not reuse Q011's MAC unless the original VM no
   longer exists and a separate network decision explicitly permits it;
4. set only that existing profile's `connection.autoconnect=yes` if its proved
   before-state is disabled; and
5. require the reserved address, DHCP server/gateway/DNS `192.168.70.1`, and
   Windows 11 SSH to persist after one normal reboot.

The retained original uses MAC `00:15:5d:14:0b:3e` and reservation
`192.168.70.140`; these values identify the existing guest and are not a safe
default for a concurrent rebuild. See the
[Phase 6 evidence](../evidence/q011-phase6-evidence.md).

## Registration, Trust, And Patch Sequence

Use separate approvals and stop gates for each risk boundary:

1. register interactively without retaining credentials, consumer UUID, or
   organization identity;
2. require only RHEL 10 x86_64 BaseOS and AppStream enabled;
3. verify the package-owned Red Hat key bundle before importing exactly the
   three proved certificates (`fd431d51-4ae0493b`,
   `5a6340b3-6229229e`, `05707a62-68e6a1f3`);
4. authenticate repository-scoped samples before package work;
5. review one current DNF proposal and stop on unexpected sources, removals,
   downgrades, or new key prompts;
6. run one supported transaction only after explicit acceptance of the
   backup/rollback boundary; and
7. reboot once, require the newest installed kernel, healthy controls, and a
   final update-state disposition.

The historical Phase 7P target ended at kernel
`6.12.0-211.37.1.el10_2.x86_64` and DNF transaction `2`. A future rebuild must
evaluate current supported content rather than force those historical package
versions. See the [trust evidence](../evidence/q011-phase7k-evidence.md),
[patch evidence](../evidence/q011-phase7p-evidence.md), and
[post-patch comparison](../evidence/q011-phase8-evidence.md).

## Acceptance Checklist

A recreated baseline is not equivalent until it proves:

- RHEL 10.2 identity and intended hostname;
- locked root and the intended local administrator in `wheel`;
- SELinux Enforcing;
- enabled/active OpenSSH and firewalld with explicitly compared effective
  policy;
- zero unexpected failed units;
- expected LVM layout;
- attributable DHCP identity and successful approved SSH path;
- registration, required repositories, and exact intended RPM trust;
- one successful supported package transaction and newest-kernel reboot;
- safe screenshots and searchable results; and
- final Off, disconnected, Untagged VLAN 0, DVD-empty, checkpoint-free state.

## Known Gaps

This project still does not prove backup/restore, hardened password SSH,
unattended provisioning, an actually replayed rebuild, production readiness,
or long-duration stability. Those claims require separate projects and
evidence.
