# Q011 Phase 4C — Visual Walkthrough

This page preserves the reviewed, safe images from Leonel's disconnected RHEL
installation. The project README displays only two primary captures; this
linked page retains the useful process evidence and the input failure that
changed the verification method.

## 1. RHEL 10.2 Installer Reached

<p><strong>Proof:</strong> The exact Q011 VM reached the RHEL 10.2 Welcome screen with English (United States) selected. The intended boot-menu image was missed, so this is retained as welcome-screen proof and is not mislabeled as the boot menu.</p>

<img src="screenshots/q011-phase4c-process-01-rhel102-welcome.png" alt="Q011 VMConnect console at the RHEL 10.2 English United States Welcome screen" width="900">

## 2. Final No-Write Installation Summary

<p><strong>Proof:</strong> Before disk writes, the installer showed the local auto-detected source, Minimal Install, automatic partitioning, Denver time, root disabled, local administrator configured, and Red Hat not registered. The disconnected summary tile remained Unknown; a separate direct page and the later guest evidence proved hostname q011-rhel01 and no connectivity.</p>

<img src="screenshots/q011-phase4c-01-rhel-installation-summary.png" alt="RHEL 10.2 Installation Summary before Begin Installation with local media, Minimal Install, automatic partitioning, root disabled, administrator created, and no registration" width="900">

## 3. Installation Complete Before Reboot

<p><strong>Proof:</strong> RHEL reported installation complete while Reboot System remained untouched, preserving the mandatory DVD-ejection checkpoint.</p>

<img src="screenshots/q011-phase4c-process-02-installation-complete-before-eject.png" alt="RHEL 10.2 installer complete screen before Reboot System and DVD ejection" width="900">

## 4. Exact Hyper-V DVD Empty

<p><strong>Proof:</strong> The Q011 Settings dialog showed Media set to None on its SCSI 0:1 DVD drive; the same tree showed the one Network Adapter still Not connected.</p>

<img src="screenshots/q011-phase4c-process-03-hyperv-dvd-ejected.png" alt="Q011 Hyper-V DVD Drive settings showing Media None and Network Adapter Not connected" width="900">

## 5. VMConnect Clipboard Limitation Contained

<p><strong>Proof:</strong> VMConnect clipboard injection produced atkbd unknown-key messages. Leonel stopped this input path without changing the guest and switched to short, manually typed read-only commands.</p>

<img src="screenshots/q011-phase4c-process-04-vmconnect-clipboard-limit.png" alt="Q011 RHEL console showing atkbd unknown-key messages from rejected VMConnect clipboard injection" width="900">

## 6. Offline Network And Health Proof

<p><strong>Proof:</strong> The local console showed leonel in wheel, no failed-unit rows, only loopback addressing, no route, and eth0 unavailable.</p>

<img src="screenshots/q011-phase4c-process-05-offline-network-health.png" alt="Q011 RHEL console showing wheel membership, no failed units, loopback-only addressing, no routes, and eth0 unavailable" width="900">

## 7. Installed Baseline Summary

<p><strong>Proof:</strong> The final console capture showed RHEL 10.2, q011-rhel01, SELinux Enforcing, locked root state L, leonel in wheel, system running, and the reviewed combined verification marker. One mistyped systemctl command is visibly followed by its correct successful invocation.</p>

<img src="screenshots/q011-phase4c-02-installed-offline-verification.png" alt="Q011 installed RHEL console showing release, hostname, SELinux, locked root, wheel membership, running state, and combined manual verification pass" width="900">

The [sanitized results](q011-phase4c-sanitized-results.txt) preserve the full
searchable values, and the
[screenshot manifest](q011-phase4c-screenshots.sha256) proves the retained PNG
integrity.
