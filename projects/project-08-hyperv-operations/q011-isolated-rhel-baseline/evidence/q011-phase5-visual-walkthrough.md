# Q011 Phase 5 — Visual Walkthrough

**Captured:** 2026-07-20  
**Primary evidence:** clean baseline, corrected DHCP authority, and final safe
state  
**Supporting evidence:** stopped gates, initial console output, DHCP-source
diagnosis, and SSH access

All images were reviewed for passwords, tokens, keys, public WAN addresses,
and unrelated content. Several supporting captures show an empty password
prompt but no credential value; they are not primary README images.

## Initial Console Baseline

The first console capture proves the local RHEL identity, locked root, wheel
membership, running system, and initial package query. Its surprising targeted
SELinux-policy result was superseded by the clean repeated query without any
package change.

<img src="screenshots/q011-phase5-process-01-console-core-baseline-initial.png" alt="Initial local RHEL core baseline" width="900">

The service follow-up proves `sshd` and `firewalld` enabled and active plus a
successful firewalld configuration check. The empty sudo prompt contains no
credential value.

<img src="screenshots/q011-phase5-process-02-console-service-checks.png" alt="Initial local service and firewall checks" width="900">

## Guarded Network Investigation

The preflight capture proves the first attachment stopped because the operator
confirmation gate was false.

<img src="screenshots/q011-phase5n-process-01-operator-confirmation-gate.png" alt="Stopped network preflight confirmation gate" width="900">

The disconnected guest discovery proves one existing `eth0` NetworkManager
profile and an unavailable device before attachment.

<img src="screenshots/q011-phase5n-d-01-networkmanager-discovery.png" alt="Disconnected eth0 NetworkManager discovery" width="900">

The journal capture proves a fresh DHCP transaction produced
`172.16.70.52`, followed by cancellation and no lease after disconnection.

<img src="screenshots/q011-phase5n-d2-01-networkmanager-dhcp-lease-log.png" alt="NetworkManager unexpected DHCP lease journal" width="900">

The DHCP option capture names `172.16.70.1` as the unexpected server and
router for `172.16.70.52`.

<img src="screenshots/q011-phase5n-d3-01-dhcp-source-options.png" alt="Unexpected DHCP server identifier and address" width="900">

After the ASA was user-confirmed Off, the corrected capture proves OPNsense
issued `192.168.70.140/24` with server, router, and DNS `192.168.70.1`.

<img src="screenshots/q011-phase5n-e-01-opnsense-dhcp-lease.png" alt="Corrected OPNsense VLAN 70 DHCP lease" width="900">

The Windows 11 terminal capture proves one interactive SSH login as `leonel`
and guest hostname `q011-rhel01`. It is supporting evidence because the empty
password prompt remains visible.

<img src="screenshots/q011-phase5n-e-02-ssh-verified.png" alt="Windows 11 SSH login to q011-rhel01" width="900">

## Clean Service Baseline

The first SSH baseline capture includes an empty sudo prompt and is retained
only to preserve the operator sequence.

<img src="screenshots/q011-phase5-process-03-core-baseline-with-sudo-prompt.png" alt="Initial SSH core baseline with empty sudo prompt" width="900">

The clean repeat proves RHEL 10.2, hostname, SELinux, locked root, wheel,
running health, zero failed-unit rows, and installed package versions.

<img src="screenshots/q011-phase5-03-core-baseline-via-ssh-clean.png" alt="Clean RHEL core service baseline" width="900">

The security-service capture proves `sshd` and `firewalld` enabled and active,
the public-zone policy, and effective SSH authentication settings.

<img src="screenshots/q011-phase5-04-firewall-ssh-baseline-via-ssh.png" alt="Firewalld and OpenSSH effective baseline" width="900">

The listener and policy capture proves TCP 22 on IPv4 and IPv6, SELinux
Enforcing, and exact SSH/SELinux configuration hashes.

<img src="screenshots/q011-phase5-05-listeners-selinux-hashes.png" alt="Listeners SELinux and configuration hashes" width="900">

The storage and registration capture proves the active corrected lease, LVM
layout, root filesystem, absent consumer certificate, and unregistered state.

<img src="screenshots/q011-phase5-06-network-storage-registration.png" alt="Network storage and registration baseline" width="900">

## Final Isolation

The final host capture proves normal shutdown returned Q011 to Off,
disconnected, VLAN zero, DVD-empty, checkpoint-free state with
`Phase5EndStatePass=True`.

<img src="screenshots/q011-phase5-07-offline-end-state.png" alt="Q011 final Off and disconnected Phase 5 state" width="900">
