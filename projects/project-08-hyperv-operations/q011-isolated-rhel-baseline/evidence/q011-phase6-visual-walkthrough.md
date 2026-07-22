# Q011 Phase 6 Visual Walkthrough

All images were reviewed for credentials, tokens, consumer UUIDs,
organization identifiers, authenticated URLs, unrelated windows, and public
address leakage. No credential value is visible. Images containing an empty
password prompt are retained as supporting evidence rather than the primary
README proof.

## Phase 6A Preflight

<p><strong>Proof:</strong> The host result proves the correct Off,
disconnected, VLAN-zero, DVD-empty, checkpoint-free starting state, the ASA-Off
operator confirmation, and <code>Phase6PreflightPass=True</code>.</p>

<img src="screenshots/q011-phase6-01-preflight-pass.png" alt="Q011 Phase 6 Hyper-V safe-state preflight pass" width="900">

## Phase 6B VLAN 70 Attachment And DHCP

<p><strong>Proof:</strong> The local console shows the existing profile
activated with <code>192.168.70.140/24</code> and DHCP server, gateway, and DNS
<code>192.168.70.1</code>. The empty sudo prompt contains no password value.</p>

<img src="screenshots/q011-phase6-02-vlan70-dhcp-validation.png" alt="Q011 VLAN 70 OPNsense DHCP options" width="900">

<p><strong>Proof:</strong> The SSH session proves <code>leonel</code> reached
<code>q011-rhel01</code> and observed the expected address.</p>

<img src="screenshots/q011-phase6-03-ssh-login.png" alt="Q011 interactive SSH identity and address proof" width="900">

## Phase 6C-R Reservation Precheck And Creation

<p><strong>Proof:</strong> The Dnsmasq Hosts search returned no reservation for
Q011's MAC before the change; the table itself had zero entries.</p>

<img src="screenshots/q011-phase6c-r-01-host-reservation-precheck.png" alt="OPNsense Dnsmasq empty Q011 reservation precheck" width="900">

<p><strong>Proof:</strong> The active VLAN 70 lease maps Q011's MAC and hostname
to <code>192.168.70.140</code>.</p>

<img src="screenshots/q011-phase6c-r-02-current-dhcp-lease.png" alt="OPNsense Q011 dynamic VLAN 70 lease" width="900">

<p><strong>Proof:</strong> The Hosts table contains exactly one Q011 mapping
with the approved hostname, IP address, and hardware address and no tags or
domain changes.</p>

<img src="screenshots/q011-phase6c-r-03-reservation-created.png" alt="OPNsense Q011 Dnsmasq host reservation" width="900">

## Automatic-Activation Failure And Containment

<p><strong>Proof:</strong> After reboot, <code>eth0</code> had link state but no
IPv4 address until the existing profile was manually activated. This capture
prevents the earlier reboot from being mislabeled as automatic persistence.</p>

<img src="screenshots/q011-phase6c-process-01-autoconnect-failure-manual-recovery.png" alt="Q011 reboot without automatic IPv4 followed by manual profile recovery" width="900">

<p><strong>Proof:</strong> SSH and the expected DHCP values returned after the
manual recovery. This is recovery proof, not automatic-start proof.</p>

<img src="screenshots/q011-phase6c-process-02-post-manual-activation-ssh.png" alt="Q011 SSH after manual NetworkManager activation" width="900">

## Phase 6C-A Automatic Activation Correction

<p><strong>Proof:</strong> The existing profile now shows only the approved
<code>connection.autoconnect=yes</code> change while the interface remains
<code>eth0</code> and IPv4 method remains <code>auto</code>.</p>

<img src="screenshots/q011-phase6c-a-01-autoconnect-enabled.png" alt="Q011 NetworkManager autoconnect enabled on existing DHCP profile" width="900">

<p><strong>Proof:</strong> After a normal reboot, Windows 11 reached Q011 over
SSH without manual activation and observed autoconnect yes, reserved address
<code>192.168.70.140/24</code>, and OPNsense DHCP/gateway
<code>192.168.70.1</code>.</p>

<img src="screenshots/q011-phase6c-a-02-automatic-reboot-persistence.png" alt="Q011 automatic DHCP reservation persistence after reboot" width="900">

## Phase 6D Registration And Repositories

<p><strong>Proof:</strong> The sanitized output records only Boolean pass
results for registration and the required BaseOS/AppStream repositories. It
contains no Red Hat identity or credential value.</p>

<img src="screenshots/q011-phase6d-01-registration-repositories-pass.png" alt="Q011 sanitized RHEL registration and repository pass results" width="900">

## Phase 6E Final Safe State

<p><strong>Proof:</strong> The host result proves Q011 is Off with one
disconnected Untagged VLAN-zero adapter, empty DVD, zero checkpoints, and
<code>Phase6EndStatePass=True</code>.</p>

<img src="screenshots/q011-phase6e-01-safe-end-state.png" alt="Q011 Phase 6 final safe Hyper-V state" width="900">
