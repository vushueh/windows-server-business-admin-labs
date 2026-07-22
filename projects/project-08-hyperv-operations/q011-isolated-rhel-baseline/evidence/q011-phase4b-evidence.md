# Q011 Phase 4B — Disconnected VM Evidence

**Date:** 2026-07-19  
**Host:** `WIN-PRQD8TJG04M`  
**Executor:** Leonel through Hyper-V Manager and elevated Windows PowerShell  
**Result:** pass; VM retained Off and disconnected  
**Rollback:** not triggered

## Objective And Boundary

Create only `Q011-RHEL102-BASELINE` from the frozen design while preventing
first power-on and all network attachment. The approved window permitted one
Generation 2 VM, one dynamic VHDX, the verified local RHEL DVD, exact Off-state
configuration and verification, and exact failed-creation rollback. It did not
permit guest start, console access, switch attachment, another VM/host change,
or Git/GitHub work.

## Preflight And Safe Stops

The first approved preflight passed host, elevation, VM/VHD collision, ISO
size/hash/stability, capacity, load, and transition checks, but found
`ZoneIdentifierPresent=True`. The operator-confirmation value was also false.
The script returned `PreflightPass=False` and stopped before creating a VM or
VHDX.

Under a separate exact approval, Leonel previewed and ran `Unblock-File` only
against the frozen ISO. Before/after size remained 11,059,986,432 bytes, both
SHA-256 values remained
`e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5`,
the zone stream changed from present to absent, other streams were preserved,
and `UnblockPass=True` while the VM/VHDX remained absent.

The first post-correction retry safely failed because the operator did not
enter the exact `NO-COMPETING-WORK` phrase. During the second retry, the phrase
was initially typed at PowerShell's incomplete-block `>>` prompt; Leonel
canceled that unexecuted input and pasted the complete block. At the actual
`Read-Host` prompt, he confirmed the host was free of competing work. The
final fresh result passed with 38.4 GiB free memory, 876.9 GiB free on `D:`,
1.3 percent average and 2.5 percent peak CPU, zero transitioning VMs, the
verified unblocked ISO, and `PreflightPass=True`.

The concise values are preserved in the
[sanitized searchable result](q011-phase4b-sanitized-results.txt).

## Hands-On Creation

Leonel created the VM through the New Virtual Machine Wizard. The first
generation screen initially showed Generation 1; review caught it before the
wizard advanced, and Leonel selected Generation 2. He then set 6144 MB static
memory, selected Not Connected, created the exact 60 GB dynamic VHDX, attached
the local verified ISO, and checked the wizard summary before selecting
Finish.

With the VM still Off, he set 2 vCPU, selected the Microsoft UEFI Certificate
Authority Secure Boot template, placed DVD first and disk second, confirmed
the one adapter remained Not connected, disabled automatic checkpoints, and
set Automatic Start Action to Nothing. The complete operator path is in the
[Phase 4B visual walkthrough](q011-phase4b-visual-walkthrough.md).

## Verification

The final exact query proved:

- `State=Off`, `Generation=2`, 2 vCPU, and 6 GiB static memory;
- Dynamic Memory and automatic checkpoints disabled;
- Automatic Start Action `Nothing`;
- exactly one adapter, blank `SwitchName`, and `Disconnected=True`;
- one 60 GiB Dynamic VHDX at the frozen path;
- the exact ISO path and pinned SHA-256;
- Secure Boot On with `MicrosoftUEFICertificateAuthority`;
- DVD first, disk second, and zero snapshots; and
- `Phase4BPass=True`.

No rollback was needed. The VM remains Off. This result does not prove that
RHEL boots or installs successfully; those are separately approval-gated Phase
4C claims.

## Screenshot Selection And Integrity

All thirteen reviewed Q011 captures were preserved byte-for-byte. The project
README displays only the strongest two Phase 4B images: final disconnected
network state and firmware/DVD-first state. The visual walkthrough uses the
remaining operator-process images, including the caught-and-corrected
Generation 1 selection. Exact hashes are in the
[Phase 4B screenshot manifest](q011-phase4b-screenshots.sha256).

No screenshot exposes a credential, token, password, account name, unrelated
VM inventory, public address, or notification. Internal host/VM names, exact
local paths, and the public RHEL ISO checksum are retained because they are
necessary technical evidence.

## End-State Boundary

At stop time, `Q011-RHEL102-BASELINE` existed only as an Off, disconnected VM.
No Start/Connect action, guest installation, network attachment, checkpoint,
other VM change, rollback, commit, push, merge, or GitHub operation occurred.
