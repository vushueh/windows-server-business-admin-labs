# Q011 Phase 5 — Service Baseline And Controlled Network Evidence

**Executed:** 2026-07-20  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** baseline captured; controlled network access proved; normal shutdown
returned `Phase5EndStatePass=True`

## Scope And Approval Boundary

Leonel approved read-only collection of the RHEL release, identity, SELinux,
root-lock, wheel, system-health, installed-package, OpenSSH, firewalld,
listener, configuration-hash, registration, LVM, and network baseline. The
later Phase 5N approvals superseded only the disconnected-network boundary for
bounded DHCP-source diagnosis and one interactive SSH path. They did not
authorize registration, package or service changes, firewall edits, static
addressing, a DHCP reservation, updates, backups, another VM, or production
changes.

## Why The Network Plan Changed

The first VLAN 70 activation returned `172.16.70.52/24`, DHCP server and router
`172.16.70.1`, DNS `8.8.8.8` and `1.1.1.1`, and a 43,200-second lease. That did
not match OPNsense's documented `192.168.70.100-192.168.70.200` pool. The
NetworkManager journal proved it was a fresh DHCP transaction rather than a
stale or static address, and the DHCP option record named `172.16.70.1` as the
server identifier.

Repository topology records identify `172.16.70.1` as the Cisco ASA inside
interface and show the ASA-facing switch port in VLAN 70. Leonel confirmed the
ASA was powered off before the corrected retry. A forced activation of the
existing `eth0` profile then returned `192.168.70.140/24`, DHCP server, router,
and DNS `192.168.70.1`, and an 86,400-second lease. No OPNsense, switch, ASA,
NetworkManager-profile, firewall, or service configuration was changed.

The Hyper-V host could not open TCP 22 to the corrected address, but Leonel's
Windows 11 workstation completed an interactive SSH login as `leonel` and
proved hostname `q011-rhel01`. This establishes one working administration
path, not universal inter-VLAN reachability. The address is not reserved and
must not be treated as persistent.

## Read-Only Baseline Results

The clean collection proved RHEL 10.2, hostname `q011-rhel01`, SELinux
Enforcing, locked root state `L`, `leonel` in `wheel`, system state `running`,
and no failed-unit rows. OpenSSH, firewalld, policycoreutils, and the targeted
SELinux policy were installed.

Both `sshd` and `firewalld` were enabled and active. Firewalld reported a
successful configuration check and public zone on `eth0`, with `cockpit`,
`dhcpv6-client`, and `ssh` services and forwarding enabled. Effective OpenSSH
settings were `permitrootlogin without-password`,
`passwordauthentication yes`, and `pubkeyauthentication yes`. TCP 22 listened
on IPv4 and IPv6. These are before-state findings; Phase 5 changed none of
them.

The collection also retained SHA-256 values for `/etc/ssh/sshd_config` and
`/etc/selinux/config`, the `rhel` LVM layout, root filesystem source, absent
consumer certificate, and unregistered subscription state. The searchable
values are in the [sanitized results](q011-phase5-sanitized-results.txt).

## Failures And Containment

- A missing `NO-COMPETING-WORK` response stopped the first network preflight
  before attachment.
- An unexpected `172.16.70.52` lease triggered immediate disconnection and
  VLAN-zero rollback instead of accepting the wrong DHCP authority.
- The first corrected OPNsense test exceeded its local three-minute evidence
  timer by 35.6 seconds. Address, server, gateway, and rollback checks passed,
  but the phase boolean remained false honestly.
- An SSH attempt from the Hyper-V host failed, and the wrapper returned Q011 to
  a disconnected VLAN-zero state. A separately permitted Windows 11 SSH path
  then succeeded after a fresh lease.
- Two initial command blocks contained operator or generated syntax mistakes.
  Their preflight/parser gates stopped before an unintended target change; the
  final exact-name checks independently proved the safe state.

## Final State

Leonel shut the guest down normally. The host verified `State=Off`, one
adapter, no switch, access VLAN ID `0`, empty DVD, zero checkpoints, automatic
checkpoints disabled, Automatic Start Action `Nothing`, and
`Phase5EndStatePass=True`.

## Visual And Integrity Evidence

The [Phase 5 visual walkthrough](q011-phase5-visual-walkthrough.md) links every
accepted screenshot and explains its claim boundary. Images containing an
empty password prompt are supporting evidence only; no credential value is
visible. The [screenshot manifest](q011-phase5-screenshots.sha256) protects all
14 retained images.

## Claim Boundary

Phase 5 proves a clean unpatched before-state, one working OPNsense DHCP lease,
one working Windows 11 SSH path, and safe shutdown/isolation. It does not prove
a persistent IP, corrected legacy ASA design, Hyper-V-host reachability,
registration, repository entitlement, patch currency, post-patch behavior,
backup, rebuild, or production readiness.
