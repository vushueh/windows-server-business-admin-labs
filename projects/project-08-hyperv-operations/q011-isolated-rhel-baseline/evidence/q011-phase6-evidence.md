# Q011 Phase 6 — Controlled Network, Persistence, And Registration Evidence

**Executed:** 2026-07-20  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** controlled network, persistent DHCP, registration, repositories,
and final isolation passed

## Scope And Approval Boundary

Leonel approved Phase 6A–6E in separately bounded windows. The first window
allowed only a fresh Hyper-V preflight, temporary access VLAN 70 attachment,
activation of the existing `eth0` profile, one DHCP/SSH proof, optional
interactive Red Hat registration, repository verification, and normal safe
shutdown. Two narrow follow-up approvals then allowed one OPNsense Dnsmasq
reservation and changing only `connection.autoconnect` on the existing
NetworkManager profile.

No package was installed, updated, or removed. No firewall, SSH, SELinux,
account, DHCP range, DNS option, NAT rule, switch, checkpoint, VHDX, ISO,
other VM, Git, or GitHub object changed. The legacy ASA remained powered off.

## Phase 6A — Fresh Safe-State Gate

The host preflight proved the correct host and VM, administrator context, VM
Off state, one disconnected Untagged VLAN-zero adapter, empty DVD, zero
checkpoints, automatic checkpoints disabled, Automatic Start Action `Nothing`,
and the external `vSwitch-LAN` target. Leonel explicitly confirmed both the
ASA-Off condition and absence of competing work. `Phase6PreflightPass=True`.

## Phase 6B — Controlled VLAN 70 And SSH

Only Q011's existing adapter was changed to Access VLAN 70, connected to
`vSwitch-LAN`, and started. The existing `eth0` profile returned
`192.168.70.140/24`, with DHCP server, gateway, and DNS all
`192.168.70.1`; the lease duration was 86,400 seconds. Windows 11 then
completed an interactive SSH login as `leonel` and proved hostname
`q011-rhel01`.

## Phase 6C-R — DHCP Reservation

OPNsense Dnsmasq initially contained zero host reservations. The current
VLAN 70 lease mapped `192.168.70.140` to MAC `00:15:5d:14:0b:3e` and
hostname `q011-rhel01`. Leonel added exactly one host mapping for those values
without changing DHCP ranges, tags, domains, options, interfaces, firewall,
or NAT.

The first reboot exposed a separate issue: the reservation worked, but the
guest did not request it automatically. `eth0` had link state but no IPv4
address until Leonel ran `nmcli connection up eth0`. This stopped the claim
of automatic persistence and triggered the narrower Phase 6C-A correction.

## Phase 6C-A — Automatic Network Activation

Read-only inspection proved the existing profile had
`connection.autoconnect=no`, `connection.interface-name=eth0`, and
`ipv4.method=auto`. Under exact approval, Leonel changed only
`connection.autoconnect` to `yes`. A normal reboot then proved SSH worked
without manual activation and that Q011 automatically returned with reserved
address `192.168.70.140/24`, gateway and DHCP server `192.168.70.1`.

## Phase 6D — Interactive Registration

Leonel ran `subscription-manager register` interactively. No username,
password, consumer UUID, organization value, token, certificate, or
authenticated URL was retained. A sanitized Boolean-only check proved:

- `RegistrationPass=True`
- `BaseOSRepoEnabled=True`
- `AppStreamRepoEnabled=True`
- `Phase6DPass=True`

No `dnf` package transaction ran.

## Phase 6E — Final Safe State

Leonel shut down Q011 normally. The Hyper-V host disconnected only Q011's
adapter and restored it to Untagged VLAN 0. The final result proved VM Off,
one disconnected adapter, empty DVD, zero checkpoints, automatic checkpoints
disabled, Automatic Start Action `Nothing`, and `Phase6EndStatePass=True`.

The Dnsmasq reservation, NetworkManager autoconnect setting, registration,
and enabled BaseOS/AppStream repositories remain intentionally retained.
Starting the VM in its current state provides local console access only;
network access requires a separately approved Access VLAN 70 attachment.

## Visual And Integrity Evidence

The [Phase 6 visual walkthrough](q011-phase6-visual-walkthrough.md) displays
all twelve reviewed captures, including the stopped automatic-activation
claim and its correction. The
[screenshot manifest](q011-phase6-screenshots.sha256) records exact SHA-256
values. Images with an empty password prompt retain no credential value and
are supporting evidence only.

## Claim Boundary

Phase 6 proves one reserved OPNsense DHCP identity, automatic activation after
reboot, one working Windows 11 SSH path, interactive RHEL registration,
enabled RHEL 10 x86_64 BaseOS/AppStream repositories, and safe final
isolation. It does not prove patch currency, package-update success,
post-patch service health, backup/restore, hardened SSH policy, universal
inter-VLAN reachability, or production readiness.
