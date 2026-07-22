# Q011 Phase 8 — Post-Patch Validation Evidence

**Executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** post-patch controls and intended changes passed; final Hyper-V
isolation passed

## Scope And Approval Boundary

Leonel approved the reviewed Phase 8 window for a fresh host preflight,
temporary Q011-only Access VLAN 70 attachment while the conflicting ASA
remained Off, one Windows 11 SSH session, documented read-only guest checks,
safe screenshots, normal shutdown, and exact final isolation. It did not
authorize a package transaction, metadata refresh/check, key or repository
change, service/configuration repair, OPNsense change, checkpoint, export,
backup, another VM, or Git/GitHub action.

Two later narrow approvals allowed only a privileged read of the already
planned SSH configuration hash and correction of one local transcription.
Neither approval changed the guest.

## Host And Network Gates

The host preflight returned `Phase8PreflightPass=True` with Q011 Off, one
disconnected Untagged VLAN-zero adapter, empty DVD, zero checkpoints, 38.5 GiB
free memory, 872.6 GiB free on `D:`, zero transitioning VMs, and the intended
external `vSwitch-LAN` target.

Only Q011 was then attached as Access VLAN 70 and started;
`Phase8AttachmentPass=True` verified the exact state. Without manual
NetworkManager activation, Windows 11 SSH reached `leonel@q011-rhel01` at
`192.168.70.140/24`. DHCP server, gateway, and DNS all returned
`192.168.70.1`.

## Stable Control Comparison

The post-patch guest retained:

- RHEL 10.2 and hostname `q011-rhel01`;
- locked root and `leonel` wheel membership;
- system state `running` with zero failed units;
- active/enabled OpenSSH and firewalld;
- public-zone services `cockpit,dhcpv6-client,ssh`, no explicit ports, and
  forwarding enabled;
- effective root SSH policy `without-password`, password and public-key
  authentication enabled, and IPv4/IPv6 TCP 22 listeners;
- SELinux `Enforcing`;
- unchanged SSH and SELinux configuration hashes; and
- the original `rhel` LVM layout with `home,root,swap` and root mapper path.

The post-patch package facts were
`openssh-server-9.9p1-23.el10_2.x86_64`,
`firewalld-2.4.3-2.el10_2.noarch`,
`policycoreutils-3.10-1.el10.x86_64`, and
`selinux-policy-targeted-42.1.18-4.el10_2.1.noarch`.

## Intended Change Comparison

The guest ran and reported as latest installed kernel
`6.12.0-211.37.1.el10_2.x86_64`. It retained exactly the three verified Red
Hat RPM trust certificates, valid registration, enabled RHEL 10 x86_64
BaseOS/AppStream repositories, successful DNF history transaction `2` with
command `upgrade --refresh`, and the intended LVM layout.

The combined comparison returned `stable_controls_pass=true`,
`expected_changes_pass=true`, and `Phase8GuestBaselinePass=true`.

## Hash Collection And Transcription Correction

The initial Phase 8 block attempted to hash `/etc/ssh/sshd_config` without
`sudo`. The read produced no hash, so the stable-control gate stopped false;
this was a collection-permission failure, not configuration drift. Under a
narrow read-only approval, `sudo sha256sum` returned:

`a7329525af126b8280fd52036f81df62a8f893ce8d917d787ac06ad6d6d1adaf`

The Phase 5 text record had transposed two characters as `a6` where the
original Phase 5 screenshot visibly showed `af`. The current hash matched the
original screenshot exactly. Under a second narrow documentation-only
approval, Codex corrected only that local transcription and the Phase 8
expected value. Recomputing the already collected Booleans then passed. No
guest file, package, service, or setting changed.

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
- `Phase8EndStatePass=True`.

## Visual And Integrity Evidence

The [Phase 8 visual walkthrough](q011-phase8-visual-walkthrough.md) uses all
three reviewed screenshots. The
[screenshot manifest](q011-phase8-screenshots.sha256) records their exact
hashes. No image contains a password prompt/value, Red Hat consumer or
organization identity, token, authenticated URL, or unrelated VM inventory.

## Claim Boundary

Phase 8 proves the documented stable controls survived Phase 7P, the intended
network/registration/trust/kernel/history differences are attributable, and
the guest returned to exact isolation. It does not prove backup/restore,
hardened SSH policy, an actually replayed rebuild, long-duration stability,
or production readiness.
