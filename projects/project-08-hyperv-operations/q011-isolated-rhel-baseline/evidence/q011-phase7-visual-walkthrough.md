# Q011 Phase 7 — Visual Walkthrough

These five reviewed images preserve the actual stopped patching window. They
are evidence, not a backup, and they do not authorize a retry.

## Pre-Update Readiness

This compact capture proves the release, current and installed kernel,
Enforcing SELinux, healthy system/services, zero failed units, root-space gate,
registration, required repositories, and update-availability exit `100`. It
does not prove an update ran.

<img src="screenshots/q011-phase7-01-preupdate-readiness.png" alt="Q011 compact pre-update readiness results with all safety gates passing" width="900">

## Updates Available

The safe tail of `dnf check-update` proves intended BaseOS/AppStream updates
were available and the command returned `100`. It does not prove package
authenticity or installation.

<img src="screenshots/q011-phase7-process-01-updates-available.png" alt="Q011 DNF update list tail with accepted check-update exit 100" width="900">

## Transaction Reviewed Before Acceptance

The VMConnect capture shows only the approved repositories, five installs, 88
upgrades, 560 MiB, and the interactive `y/N` gate. No removal or downgrade is
shown. It does not prove the later GPG trust gate passed.

<img src="screenshots/q011-phase7-process-02-dnf-transaction-review.png" alt="Q011 supervised DNF transaction summary before operator acceptance" width="900">

## GPG Stop And Unchanged History

The console result proves `upgrade_exit=1` and shows DNF history still ending
at transaction `1`, the original installation. The harmless pasted prose
error is visible. The key prompts themselves are preserved as searchable text
in the evidence record, not claimed as visible here.

<img src="screenshots/q011-phase7-process-03-gpg-key-stop-no-transaction.png" alt="Q011 failed upgrade exit and unchanged original DNF transaction history" width="900">

## Safe Recovery End State

The host output proves Q011 is Off with one disconnected Untagged VLAN-zero
adapter, empty DVD, zero checkpoints, and `Phase7RecoveryPass=True`. It does
not prove patch success; no post-update screenshot exists.

<img src="screenshots/q011-phase7-03-safe-end-state.png" alt="Q011 Phase 7 recovery ending Off disconnected and Untagged with recovery pass true" width="900">
