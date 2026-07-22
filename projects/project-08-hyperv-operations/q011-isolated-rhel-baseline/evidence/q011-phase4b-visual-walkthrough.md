# Q011 Phase 4B — Visual Walkthrough

This page preserves Leonel's complete hands-on Hyper-V workflow. The project
README displays only two final-state images; this linked evidence page uses
the remaining process captures without turning the main story into a gallery.

## 1. Generation Gate Caught Before Creation

<p><strong>Proof:</strong> The first generation screen still showed Generation 1. Review stopped the wizard here, before creation, and required Generation 2; the later wizard summary proves the correction.</p>

<img src="screenshots/q011-phase4b-process-01-generation-gate-before-correction.png" alt="New Virtual Machine Wizard paused with Generation 1 initially selected before correction" width="900">

## 2. Static Installation Memory

<p><strong>Proof:</strong> The wizard assigned 6144 MB and left Dynamic Memory unchecked.</p>

<img src="screenshots/q011-phase4b-process-02-static-memory.png" alt="Hyper-V wizard with 6144 MB startup memory and Dynamic Memory disabled" width="900">

## 3. Disconnected Wizard Network

<p><strong>Proof:</strong> The wizard's only network selection was Not Connected.</p>

<img src="screenshots/q011-phase4b-process-03-wizard-network-not-connected.png" alt="Hyper-V wizard network page with Not Connected selected" width="900">

## 4. Exact Dynamic VHDX

<p><strong>Proof:</strong> The wizard targeted the exact Q011 VHDX under the approved D drive path with a 60 GB virtual size.</p>

<img src="screenshots/q011-phase4b-process-04-dynamic-vhdx.png" alt="Hyper-V wizard creating the exact 60 GB Q011 dynamic VHDX" width="900">

## 5. Exact Local RHEL DVD

<p><strong>Proof:</strong> The installation-media page selected only the local RHEL 10.2 DVD and showed the network-install option unavailable while disconnected.</p>

<img src="screenshots/q011-phase4b-process-05-local-iso.png" alt="Hyper-V wizard installation options with the local RHEL 10.2 DVD selected" width="900">

## 6. Pre-Creation Summary

<p><strong>Proof:</strong> Before Finish, the summary showed the corrected Generation 2 design, 6144 MB memory, Not Connected networking, exact VHDX, and exact ISO.</p>

<img src="screenshots/q011-phase4b-process-06-wizard-summary.png" alt="Hyper-V New Virtual Machine Wizard summary for the frozen Q011 design" width="900">

## 7. Two Virtual Processors

<p><strong>Proof:</strong> The Off VM's Processor page was set to two virtual processors; the settings tree also showed the frozen memory, disk, DVD, and disconnected adapter.</p>

<img src="screenshots/q011-phase4b-process-07-two-vcpu.png" alt="Q011 Hyper-V settings with two virtual processors" width="900">

## 8. Linux-Compatible Secure Boot Template

<p><strong>Proof:</strong> Secure Boot was enabled with Microsoft UEFI Certificate Authority while vTPM remained disabled.</p>

<img src="screenshots/q011-phase4b-03-secure-boot-template.png" alt="Q011 security settings with Microsoft UEFI Certificate Authority Secure Boot template" width="900">

## 9. DVD-First Firmware Order

<p><strong>Proof:</strong> Firmware placed the RHEL DVD first, the Q011 VHDX second, and the Not connected adapter third.</p>

<img src="screenshots/q011-phase4b-02-hyperv-firmware-media.png" alt="Q011 firmware boot order with RHEL DVD first and hard disk second" width="900">

## 10. Final Disconnected Adapter

<p><strong>Proof:</strong> The one adapter had Virtual switch set to Not connected with VLAN identification disabled.</p>

<img src="screenshots/q011-phase4b-01-hyperv-disconnected-network.png" alt="Q011 Network Adapter settings with virtual switch Not connected" width="900">

## 11. Automatic Checkpoints Disabled

<p><strong>Proof:</strong> The VM retained Production checkpoint capability but cleared Use automatic checkpoints; no checkpoint was created.</p>

<img src="screenshots/q011-phase4b-process-11-automatic-checkpoints-disabled.png" alt="Q011 checkpoint settings with automatic checkpoints disabled" width="900">

## 12. Automatic Start Set To Nothing

<p><strong>Proof:</strong> The host-start behavior was changed from the default restart behavior to Nothing.</p>

<img src="screenshots/q011-phase4b-process-12-automatic-start-nothing.png" alt="Q011 Automatic Start Action set to Nothing" width="900">

## 13. Final Searchable-State Companion

<p><strong>Proof:</strong> The final cropped PowerShell capture shows every frozen field and Phase4BPass=True. The paired text file remains the searchable authority.</p>

<img src="screenshots/q011-phase4b-04-verification-pass.png" alt="PowerShell verification showing Q011 Phase4BPass True" width="900">

The paired [sanitized result](q011-phase4b-sanitized-results.txt) provides
searchable values and the [screenshot manifest](q011-phase4b-screenshots.sha256)
proves file integrity.
