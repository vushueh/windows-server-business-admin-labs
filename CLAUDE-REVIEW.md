# CLAUDE-REVIEW.md — Open Items for Codex

Claude writes items here. Codex must resolve all OPEN items before starting new work.

---

## Status Key
- 🔴 OPEN — must be resolved before proceeding
- 🟡 IN PROGRESS — Codex is working on it
- 🟢 RESOLVED — closed

---

## Q011 ISOLATED RHEL 10.2 BASELINE — 2026-07-21

### 🟢 RESOLVED — Item Q011-11: Close Phase 9 retention and Q011

**Owner:** Leonel hands-on retention decision and evidence capture; Codex
local evidence intake, project closure, and status synchronization

Leonel selected `RETAIN-Q011`, ran the reviewed host-side read-only retention
gate, and returned `Phase9RetentionPass=True`. The exact VM remained Off with
one disconnected adapter, one Untagged VLAN-zero record, an empty DVD, the
exact retained VHDX, zero checkpoints, automatic checkpoints disabled, and
Automatic Start Action Nothing. The shared verified RHEL ISO remained present
at its expected byte size. The VM was not started or changed.

Codex copied the two reviewed safe Hyper-V screenshots byte-for-byte, recorded
their SHA-256 manifest, created the searchable retention result and linked
visual walkthrough, converted the Phase 9 run sheet and screenshot plan into
historical records, and marked Q011 complete. The README now includes the
final hands-on evidence, collaboration retrospective, honest unproved-claims
boundary, and separately gated next steps. Project 08, project-index, and root
status links now distinguish completed Q011 from the still-planned broader
P08 work.

**Final result:** Q011 is complete as a retained verified RHEL 10.2 baseline.
The disposal branch was not selected, and no guest, Red Hat, OPNsense, VM,
VHDX, or ISO cleanup was authorized or performed.

**Validation:** the two source/copy SHA-256 values match and the Phase 9
manifest passes; the Phase 9 PowerShell fence parses in Windows PowerShell
5.1; Markdown links, retained images, README phase-image limits,
secret/conflict patterns, stale status text, and tracked diff whitespace pass.

**Safety result:** no live host/VM access by Codex, no infrastructure change,
no commit, push, merge, GitHub setting, or publication action occurred during
local closure.

### 🟢 RESOLVED — Item Q011-10: Review Phase 8 intake and Phase 9 decision

**Owner:** Codex evidence/rebuild intake and decision design; Claude Fable
bounded read-only review; Leonel future decision owner

Codex copied the three reviewed Phase 8 captures byte-for-byte, recorded their
SHA-256 manifest, documented the passing stable-control and intended-change
comparison, created an evidence-linked manual rebuild record, and recorded
`Phase8EndStatePass=True` isolation. The initial SSH hash read omitted `sudo`;
the approved retry matched the original Phase 5 screenshot and exposed a
two-character text transcription error. Codex corrected only that local text
and expected value; no guest state changed.

Codex prepared a mutually exclusive Phase 9 decision package. The recommended
`RETAIN-Q011` branch is read-only and requires safe Hyper-V GUI screenshots.
`PLAN-DISPOSAL-Q011` records intent only and grants no deletion authority;
guest/Red Hat, OPNsense reservation, and destructive Hyper-V cleanup remain
three separate future owner windows. The shared RHEL ISO is excluded from
disposal.

Claude Fable read only the Phase 9 run sheet and returned `PASS` with four
minor/informational findings. Codex made VLAN-object multiplicity explicit,
clarified the Phase 4 checksum dependency and permitted host-name screenshot
boundary, and retained exact project-scoped reservation identifiers for safe
future targeting.

**Final result:** Phase 8 is complete and historical. Phase 9 is safe to
present for one exact choice but no choice has been made. The full review is
retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase9-claude-review.md`.

**Validation:** every new Bash fence passes `bash -n`; all Phase 8/9
PowerShell fences parse in Windows PowerShell 5.1; the three Phase 8
source/copy hashes match and the manifest passes; links, retained images,
README phase-image limits, secret/conflict patterns, and tracked diff
whitespace pass.

**Safety result:** no live host/VM access by Codex or Claude, no package,
service, network, registration, OPNsense, deletion, Git/GitHub, commit, push,
merge, or publication action occurred during intake/preparation.

### 🟢 RESOLVED — Item Q011-09: Review Phase 7P intake and Phase 8 validation

**Owner:** Codex evidence intake and validation/containment design; Claude
Fable bounded read-only review; Leonel future hands-on executor

Codex copied the four reviewed Phase 7P captures byte-for-byte, recorded their
SHA-256 manifest, and documented the successful single DNF transaction, the
lost immediate exit capture, read-only DNF-history recovery, newest-kernel
reboot, healthy controls, zero final updates, and
`Phase7PEndStatePass=True` isolation. The project README displays only the two
strongest images; the linked walkthrough uses all four.

Codex prepared a separate guest-read-only Phase 8 post-patch comparison,
manual rebuild-evidence, screenshot, shutdown, and isolation window with a
paired containment plan. Claude Fable read only those two documents and
returned `CONDITIONAL` with three Medium and three Low findings. Codex
independently corrected semantic locked-root/OpenSSH alias gates,
whitespace-tolerant repository parsing, shutdown state refresh, guarded
adapter/DVD diagnostics, and immediate attachment-failure containment. The
exact DNF history command remains evidence-anchored to Phase 7P.

**Final result:** Phase 7P is a complete historical result. The Phase 8
package is reviewed and safe to present for a separate exact live approval;
it permits no package, key, cache, repository, service, firewall, SELinux,
account, NetworkManager, DHCP, or OPNsense change. Full findings are retained
in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase8-claude-review.md`.

**Validation:** all Phase 8 Bash fences pass `bash -n`; all four PowerShell
fences parse in Windows PowerShell 5.1; all four Phase 7P source/copy hashes
match and the manifest passes; Markdown links, retained images, phase image
counts, secret patterns, conflict markers, and tracked diff whitespace pass.

**Safety result:** no host/VM access, package/configuration action,
credential access, Git/GitHub operation, commit, push, merge, or publication
occurred.

### 🟢 RESOLVED — Item Q011-08: Review Phase 7K intake and Phase 7P patch retry

**Owner:** Codex evidence intake and patch/recovery design; Claude Fable
bounded read-only review; Leonel future hands-on executor

Codex copied the three reviewed Phase 7K captures byte-for-byte, recorded and
verified their SHA-256 manifest, documented the exact three packaged Red Hat
public-key handles, both cached samples changing from `NOKEY` to dual-signature
`OK` with every digest still `OK`, no DNF invocation, and final
`Phase7KEndStatePass=True` isolation.

Codex then prepared a separate Phase 7P one-transaction patch/reboot window and
paired recovery plan. Claude Fable read only those two documents and returned
`CONDITIONAL` with three Medium and two Low findings. Codex independently
accepted and corrected all five: shutdown timeout now has a power-state-
independent network-containment pass; post-check exit `100` has an explicit
`UpdatesRemain` controlled-stop disposition; transaction success no longer
incorrectly requires a newly proposed kernel; metadata/repository errors stop
explicitly; and the package-process matcher uses executable boundaries.

**Final result:** the Phase 7P package is safe to present for a separate exact
live approval. It requires fresh trust/history/service gates, one supervised
VMConnect DNF transaction, one reboot, safe screenshots, and final isolation.
It is not authority to start Q011 or run DNF. Full findings and the no-image-
backup residual risk are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase7p-claude-review.md`.

**Validation:** every Bash fence passes `bash -n`; every PowerShell fence
parses in Windows PowerShell 5.1; Phase 7K screenshot hashes pass; and the
documentation/link/secret/diff checks pass.

**Safety result:** no host/VM access, DNF action, package/service/network
change, credential access, Git/GitHub operation, commit, push, merge, or
publication occurred.

### 🟢 RESOLVED — Item Q011-07: Review Phase 7G intake and Phase 7K trust repair

**Owner:** Codex evidence intake and repair design; Claude Fable bounded
read-only review; Leonel future hands-on executor

Codex copied the three reviewed Phase 7G captures byte-for-byte, recorded and
verified their SHA-256 manifest, documented the package-owned key-file and
repository state, the empty RPM trust list, two cached RPM samples with every
digest `OK` but both signing IDs `NOKEY`, and the final
`Phase7GEndStatePass=True` isolation proof.

Codex prepared an import-only Phase 7K window and paired rollback that end
before DNF. Claude Fable read only those two documents and returned a
conditional verdict with three Medium and four Low findings. Codex
independently verified and corrected the rollback-continuity, list-parser,
identity-wording, entry-count, inherited-variable, `pipefail`, and PowerShell
error-handling issues. The import block now invokes exact rollback in the same
shell for ordinary post-import failures; rollback uses RPM's explicit
`VERSION-RELEASE` query rather than display parsing; and certificate identity
is anchored to the verified package plus pinned whole-input SHA-256 and the
three configured-source fingerprints matched with Red Hat in Phase 7G.

**Final result:** the repository-only repair package is reviewed and ready to
present for a separate exact live approval. It imports no key and invokes no
DNF command in the current state. Full findings and residual transport-loss
and two-sample coverage risks are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase7k-claude-review.md`.

**Safety result:** no host/VM access, key import, DNF action, infrastructure
change, credential access, Git/GitHub operation, commit, push, merge, or
publication occurred.

## Q011 ISOLATED RHEL 10.2 BASELINE — 2026-07-19

### 🟢 RESOLVED — Item Q011-06: Review Phase 7 stop intake and Phase 7G trust draft

**Owner:** Codex documentation and draft; Claude Fable bounded read-only
review; Leonel future hands-on executor

Codex reviewed and copied all five safe Phase 7 screenshots, recorded the
three declined Red Hat public-key prompts, `upgrade_exit=1`, unchanged DNF
history, no observed package change or reboot, and
`Phase7RecoveryPass=True`. The README now embeds two truthful Phase 7 images
inside the phase narrative, while the linked walkthrough uses all five and
explicitly records that no post-update screenshot exists.

Codex then prepared a diagnosis-only Phase 7G run sheet and containment plan.
Claude Fable reviewed the stop evidence and draft through the verified native
CLI with every Claude tool disabled. Claude found one High issue in the
VLAN/connect/start sequence, two Medium issues involving a DNF history command
and cached-sample provenance, and four Low clarifications.

Codex independently corrected the draft: it now re-reads and requires the
exact Access VLAN 70/switch state before `Start-VM`, restores disconnected
Untagged VLAN 0 on any setup error, invokes no DNF command, uses
repository-specific cached sample paths with recorded provenance, uses
`rpmkeys --list`, clarifies the off-guest fingerprint comparison and unknown
ASA managed-object boundary, and scripts the three-minute shutdown/containment
branch. Full dispositions are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase7g-claude-review.md`.

**Final result:** corrected and safe to present for a separate exact Phase 7G
live approval. It does not authorize starting Q011, attaching networking,
importing a key, retrying DNF, cleaning cached packages, or a Git/GitHub action.

**Safety result:** repository-only. No live host, VM, network, package, key,
credential, cache, Git, GitHub, commit, push, merge, or publication action
occurred.

### 🟢 RESOLVED — Item Q011-05: Review Phase 6 intake and Phase 7 patch draft

**Owner:** Codex documentation and draft; Claude bounded read-only review;
Leonel future hands-on executor

Codex completed the local Phase 6 evidence intake, retained all twelve safe
captures with exact hashes, embedded two primary images inside the Phase 6
README narrative, and documented the first failed autoconnect claim before its
narrow correction. Codex also prepared the Phase 7 single-transaction patch
window, explicit no-image-backup point-of-no-return confirmation, paired
failure-containment plan, exact final-isolation proof, and three-image
hands-on capture plan.

**Validation already complete:** all twelve Phase 6 screenshot hashes pass;
the extracted Phase 7 Bash blocks pass `bash -n`; all three Phase 7 PowerShell
blocks parse with zero Windows PowerShell 5.1 errors; and `git diff --check`
passes.

**Review result and resolution:** After Leonel reset Claude, the normal npm
wrapper remained unusable, but Codex reached the valid installed Windows
native Claude binary without changing the installation. Claude Fable returned
a conditional approval with no Critical finding, one High transaction-
continuity issue, four Medium control gaps, and three Low documentation
clarifications.

Codex independently accepted and corrected every finding. The actual package
transaction now runs interactively at VMConnect rather than over SSH;
unattended `-y` is removed; the 10-GiB root-space gate is scripted; post-reboot
exit `100` records and stops without an unsupported publication-time claim;
and a shutdown timeout disconnects only Q011 and restores Untagged VLAN 0
before separate power-state approval. Capture cropping, interactive prompt
handling, and final-output alignment were also corrected. Full dispositions
are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase7-claude-review.md`.

**Final review result:** the High and Medium findings are resolved. The Phase
7 package is safe to present for a separate hands-on approval but remains
unexecuted. Review is not live-change authority.

**Safety result:** repository-only. No live host, guest, network, credential,
package, Git, GitHub, commit, push, merge, or publication action occurred.

### 🟢 RESOLVED — Item Q011-01: Review Hyper-V owner design and ISO-staging window

**Found by:** bounded Claude read-only peer review; resolved and verified by Codex

**Evidence and resolution:**

- Leonel selected Hyper-V and moved Q011 execution ownership into this
  repository. The Proxmox record remains predecessor discovery only.
- Claude returned a conditional pass for the disconnected Generation 2 design
  and exact ISO-staging/rollback window.
- Codex accepted the rollback-provenance, immediate free-space recheck,
  cleanup-path, and explicit vNIC-disconnection recommendations.
- Codex rejected one claimed 65-character checksum defect after independently
  proving the frozen SHA-256 is exactly 64 characters and matches the prior
  verified source/published value.
- The full dispositions are in
  `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase2c-claude-review.md`.

**Safety result:** Phase 2C changed repository documentation only. No ISO was
staged, no VM or VHDX was created, no Hyper-V/network setting changed, and no
credential, commit, push, merge, or GitHub action occurred. Phase 4A remains a
separate exact approval gate.

**Phase 4A update (2026-07-19):** Leonel later approved and completed exact
local ISO staging. Final evidence passed 11,059,986,432 bytes and the pinned
SHA-256 at `D:\Hyper-V\ISO`, retained an actual File Properties screenshot,
and proved `VMCreated=False` and `NetworkChanged=False`. The screenshot-visible
Windows Unblock control was not changed and is carried into the Phase 4B
read-only preflight.

### 🟢 RESOLVED — Item Q011-02: Prepare and review Phase 4B disconnected VM creation

**Owner:** Codex design; Claude bounded review; Leonel separate approval and
hands-on execution

Before a Q011 VM exists, Phase 4B still needs an exact repository-only change
window and rollback specification. It must include fresh host/name/VHD/ISO
size/hash/capacity/load checks, read-only `Zone.Identifier` inspection, the
frozen Generation 2 settings, explicit unconnected-vNIC proof, and safe GUI
screenshot instructions. Any unblock action must be separately justified and
approved; it is not implied by VM-creation authority.

**Blocked:** VM creation, VHDX creation, ISO attachment, first power-on, and
all network attachment. No live action is authorized by this review item.

**Repository-preparation update (2026-07-19):** Codex drafted the exact
fresh preflight, GUI creation, Off-state verification, failed-creation
rollback, and two-image hands-on capture plan. The package remains unexecuted
and received the bounded Claude review required by Leonel.

**Review result and resolution:** Claude returned a conditional pass with no
Critical or High finding. Codex accepted the Medium rollback finding and made
the disk-inventory mismatch path require a fresh exact-object inspection and
recovery approval. Codex also clarified the wizard's independent configuration
and VHDX locations. The one-hash-plus-length/timestamp design remains an
explicitly accepted Low residual risk to avoid a second 11 GB full-file read
on the multi-role host. The verified dispositions are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4b-claude-review.md`.

**Final safety result:** The corrected package is ready to present for a
separate live Phase 4B approval. This preparation did not access the Hyper-V
host, inspect or unblock the live ISO, create a VM/VHDX, attach media, start a
guest, connect a switch, change another object, or perform Git/GitHub actions.
At that preparation stop point, Phase 4C remained blocked.

**Execution update (2026-07-19):** Leonel later completed the separately
approved live window. The first preflight stopped on `Zone.Identifier`; a
separately approved exact `Unblock-File` action preserved the ISO's byte size
and SHA-256. After the operator-confirmation gate was correctly entered, the
fresh preflight passed. Leonel created the VM through Hyper-V Manager and final
PowerShell verification returned `Phase4BPass=True`: Off, Generation 2, 2
vCPU, 6 GiB static memory, one 60 GiB dynamic VHDX, exact ISO/hash, Linux
Secure Boot template, DVD first, disk second, one Not Connected adapter, no
automatic checkpoints, Automatic Start Action Nothing, and zero snapshots.
All thirteen hands-on captures are retained in the linked visual walkthrough,
with only two displayed in the project README. No rollback, start, console,
network attachment, commit, push, merge, or GitHub action occurred. Phase 4C
remained blocked at that Phase 4B stop point pending separate approval.

### 🟢 RESOLVED — Item Q011-03: Prepare and review Phase 4C disconnected RHEL installation

**Owner:** Codex design; Claude bounded read-only review; Leonel hands-on
executor

Codex prepared the exact fresh preflight, first-power-on installer choices,
pre-reboot ISO-ejection gate, local-console verification, normal shutdown,
failure-containment boundary, and two-primary/three-supporting screenshot
plan. The package fixes Minimal Install, automatic LVM expectation, hostname
`q011-rhel01`, one local `leonel` administrator, root locked, no registration,
and networking off while the Hyper-V adapter remains Not connected.

Claude returned a conditional pass with no Critical or High finding. Codex
accepted the two avoidable PowerShell continuation corrections and removed a
hard dependency on `subscription-manager`: registration proof now checks the
local consumer certificate and consults Subscription Manager only when the
command exists. The deliberate before/after preflight reads remain as the
time-of-check/time-of-use control. Full dispositions are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-claude-review.md`.

**Verification:** all three embedded PowerShell blocks parse under Windows
PowerShell 5.1 with zero errors, the Bash block passes `bash -n`, and
`git diff --check` passes.

**Safety result:** repository documentation only. No live host or guest was
accessed; the VM remains Off; no VM, VHDX, ISO, network, credential, commit,
push, merge, or GitHub action occurred. At preparation close, Phase 4C first
power-on remained blocked pending Leonel's separate exact approval.

**Execution update (2026-07-19):** Leonel later supplied the exact Phase 4C
approval and completed the disconnected installation. The fresh preflight
passed, RHEL 10.2 Minimal Install used automatic LVM, and the guest booted as
`q011-rhel01` with SELinux Enforcing, locked root status `L`, `leonel` in
`wheel`, no registration, zero failed units, and no non-loopback connectivity.
The immediate DVD post-change query returned a stale attached path and stopped
the reboot; the next approved inspection found the drive already empty before
any retry, and a full ISO hash recheck passed. VMConnect rejected the long
clipboard payload, so Leonel used short manual read-only commands and retained
the limitation honestly. Normal shutdown ended with the exact VM Off,
disconnected, DVD-empty, checkpoint-free, and `Phase4CEndStatePass=True`.
The full record is
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-evidence.md`.

### 🟢 RESOLVED — Item Q011-04: Review Phase 4C intake and Phase 5 baseline preparation

**Owner:** Codex documentation and design; Claude one bounded read-only review;
Leonel future hands-on executor

Codex ingested seven safe Phase 4C PNGs, wrote searchable and visual evidence,
updated the completed run sheet for root-lock code `L`, recorded the missed
boot-menu image and VMConnect limitation, and prepared Phase 5 as a
disconnected read-only OpenSSH/firewalld/SELinux before-state.

Claude returned a conditional pass with no Critical or High finding and no
technical safety defect. Codex accepted its two Medium bridge-file
traceability findings and its memory-floor clarification. Codex also clarified
that the new 15-second eject poll is a post-execution correction and was not
part of the completed live attempt. Full dispositions are retained in
`projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase5-claude-review.md`.

**Safety result:** the intake and preparation were repository-only. Phase 5
live execution, VM start, service/package/firewall/SSH/SELinux changes,
registration, networking, commit, push, merge, and GitHub remain outside this
review.

---

## Q007 DNS FAILURE-TRIAGE SIMULATION — 2026-07-15

### 🟢 RESOLVED — Item Q007-02: Review the Windows operator practicum

**Found by:** Claude Fable read-only peer review; resolved and verified by Codex

**Evidence and resolution:**

- Codex prepared a separately gated, unexecuted practicum using one standalone
  Windows Server VM, one Hyper-V Private switch, no domain join, and no default
  route. The automated Q007 result remains Complete and unchanged.
- Claude returned GO after the change-window approval gate, with no Critical or
  High findings. It identified two Medium learner-clarity issues and three Low
  clarifications.
- Codex added Generation 2 DVD-boot and Secure Boot guidance, explained the
  expected wrong-address ping timeout, forbade adding a resolver before the DNS
  role exists, explained TTL scope, and linked a missing-record error directly
  to rollback Level 1.
- Codex also required absence of both IPv4 and IPv6 default routes, retained
  exact-record `-WhatIf` and `-RecordData` controls, and kept VM/switch deletion
  behind separate approval.
- The full review and dispositions are in
  `projects/project-03-dns-engineering/q007-dns-failure-triage-simulation/hands-on/q007-claude-fable-practicum-review-2026-07-15.md`.
- Leonel later ran the Phase 0 technical precheck. Two explicitly approved,
  read-only ISO inspections both dismounted cleanly: an untrusted-origin image
  was rejected, while the accepted evaluation image matched the pinned hash
  and passed Microsoft setup/EFI signature checks. The final screenshot shows
  both fixed names absent, 904.7 GB free, the accepted media checks, dismount,
  and `Q007Phase0Pass=True`.
- Codex inspected and ingested the original PNG without alteration or
  redaction, paired it with searchable text, and recorded the claim boundary
  in `evidence/q007-windows-hands-on-evidence-log.md`.

**Safety result:** The Hyper-V host was accessed for read-only discovery and
the two exact ISO mount/dismount inspections authorized by Leonel. No Q007 VM,
switch, VHDX, guest, route, DNS, AD, DHCP, NIC, or production configuration was
created or changed. Leonel approved the exact Phase 2 ISO copy, Private switch,
fixed VM, and standalone Windows installation scope on 2026-07-15; execution
began on 2026-07-16. The accepted ISO copy retained the pinned hash and source,
and `Q007-Private` was verified Private with no physical-adapter description.
No VM or VHDX existed at the Phase 2A stop point. Phase 2B then created the
fixed VM and dynamic 40 GB VHDX. Final host evidence shows the VM Off with
Generation 2, 2 vCPU, 4 GB static memory, one adapter on `Q007-Private`, Secure
Boot, and the staged ISO. Guest-side CIM evidence later proved Windows Server
2022 Standard Evaluation build 20348 was running in `WORKGROUP` with
`PartOfDomain=False`. After separate Phase 3 approval, Leonel renamed the
standalone guest, configured only the two fixed lab addresses and self-DNS on
its one Private-switch adapter, and passed no-default-route,
`PartOfDomain=False`, and combined `Phase3Pass=True` validation. Phase 4
was then separately approved: only DNS and its tools were installed, AD DS and
DHCP remained uninstalled, and DNS ran automatically. The file-backed,
non-AD-integrated `q007.test` primary zone has dynamic updates disabled and
exactly one A record, `files -> 10.77.7.10`; `Phase4Pass=True`. Phase 5 remains
was separately approved and passed: the exact baseline preceded one
five-minute wrong A record, DNS Manager showed both values, all six direct
queries returned both answers, the good target was reachable, and the wrong
target was not. A failed supplemental `ping.exe` exit-code assertion was
preserved and corrected with `Test-NetConnection`. Phase 6 remains unstarted
and separately approval-gated.

### 🟢 RESOLVED — Item Q007-01: Challenge and close the isolated design

**Found by:** Claude Fable read-only peer review; resolved and verified by Codex

**Evidence and resolution:**

- The canonical queue selected Q007, Q002/CUR-B1 was complete, no urgent
  preemption existed, and this review file had no conflicting OPEN claim.
- Claude returned a conditional GO for the loopback standard-library DNS
  harness. It required honest one-fault scope, evidence independent of the
  live harness summary, demonstrated user impact, a dedicated Q007 subfolder,
  and a Windows-mapped operator artifact.
- Codex limited the executed claim to the extra-A-record fault, linked the P03
  NIC/forwarder evidence, retained raw response-packet hex, added a separate
  decoder, returned the wrong address first to demonstrate client impact, and
  wrote the Windows record/NIC/forwarder/cache/rollback runbook.
- The final retained run passed eleven assertions. A second `/tmp` run and the
  independent decoder also passed. Both runs used only `127.0.0.1:10553` and
  released the port after cleanup.
- The complete review and disposition are in
  `projects/project-03-dns-engineering/q007-dns-failure-triage-simulation/evidence/q007-claude-design-review-2026-07-15.md`.

**Safety result:** No live DNS, AD, DHCP, Hyper-V, NIC, cache, resolver, or
external network change occurred. Q007 has no carried-forward review blocker.

---

## Q004 TEST-GPO BACKUP/RESTORE — 2026-07-14

### 🟢 RESOLVED — Item Q004-01: Independently review and correct the preparation package

**Found by:** Claude independent reviewer; resolved and verified by Codex

**Evidence:**

- Codex prepared the run sheet, change window, rollback/evidence plans, and a
  fail-closed four-mode PowerShell script under
  `projects/project-11-backup-disaster-recovery/q004-test-gpo-backup-restore/`.
- Claude's first independent review found that the draft used flat
  `UserVersion`/`ComputerVersion` properties not returned by the installed
  GroupPolicy module. Its read-only precheck stopped before replication and
  before any mutation.
- Codex replaced those fields with guarded User/Computer `DSVersion` and
  `SysvolVersion` captures and updated the protected-policy comparisons.
- Windows PowerShell parsing passed after correction. Claude's follow-up
  static review found no remaining Critical, High, Medium, or Low issue.
- Claude then reviewed the final current package after its subtree, canonical
  link, backup-state, transcript, and status updates; it reported no finding
  and rated preparation ready while retaining the live NO-GO.
- The follow-up live read-only precheck passed the scope, GPO collision,
  canonical default-policy/link, Quarantine, module, share, storage, and
  corrected version-shape guards.
- The exact sanitized reports are
  `evidence/q004-precheck-2026-07-14.txt` and
  `evidence/q004-claude-preexecution-review-2026-07-14.md` inside the Q004
  folder.

**Safety result:** No GPO, link, OU, identity, backup, or remote file was
created, modified, restored, or removed. No `gpupdate` ran.

### 🟢 RESOLVED — Item Q004-02: Execute, contain, resume, verify, and close

**Resolved by:** Leonel-supervised execution; Codex verification; Claude
independent final evidence review

**Evidence and disposition:**

1. Interactive precheck passed with both DCs healthy and no test-name/link or
   enabled-Quarantine-user collision. The earlier DC02 symptom was an SSH
   double-hop limitation; ADWS/firewall/authentication required no repair.
2. Leonel supplied exact approval `Q004-20260714-LEONEL`. Execute backed up all
   GPOs and the disposable baseline, then stopped before fault injection on
   the installed backup object's `Id`/`BackupId` property shape. Containment
   removed the Quarantine link and left the unlinked test GPO at baseline.
3. Codex corrected the script, pinned the exact run/GUID/backup, and added a
   fail-closed Resume mode. Claude rated the recovery `RESUME-READY`; Leonel
   supplied `Q004-20260714-LEONEL-RESUME1`.
4. Resume faulted and restored the same test GPO in 0.1 minutes. GPMC modeling
   proved `Q004-BASELINE` from the winning custom GPO. Verify and Cleanup
   passed; final state has zero test GPOs, zero Quarantine links, both defaults
   unchanged, and clean replication on both DCs.
5. Claude's read-only final review returned `COMPLETE-READY` with no Critical,
   High, or Medium issue. Codex addressed its two Low hardening observations
   by making the protected-version proof self-contained and accepting GPMC's
   `.htm` or `.html` suffix while retaining content validation.

**Final evidence:**

- `projects/project-11-backup-disaster-recovery/q004-test-gpo-backup-restore/evidence/q004-closeout.md`
- `projects/project-11-backup-disaster-recovery/q004-test-gpo-backup-restore/evidence/q004-sanitized-transcript.txt`
- `projects/project-11-backup-disaster-recovery/q004-test-gpo-backup-restore/evidence/q004-claude-final-review-2026-07-14.md`

**Final state:** Q004 is complete. Q005 is next; neither this closeout nor the
retained backups authorize Q005 execution.

---

## Q003 AD RECYCLE BIN RESTORE — 2026-07-13 to 2026-07-14

### 🟢 RESOLVED — Item Q003-01: Restore PDC reachability and run the approved read-only precheck

**Found by:** Codex primary with Claude read-only review/executor attempts

**Evidence:**

- Claude independently reviewed the Q003 scope and identified the missing
  Quarantine-OU proof, GUID-pinned delete/restore requirement,
  `msDS-DeletedObjectLifetime` check, and both-DC verification requirement.
- Codex verified the cmdlet design against Microsoft documentation and wrote
  the change window, rollback plan, screenshot plan, and fail-closed script in
  `projects/project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/`.
- Windows PowerShell parsed the script with zero syntax errors.
- A local workstation attempt stopped at `Import-Module ActiveDirectory`
  because that workstation is not the PDC and has no AD module.
- The current SSH configuration uses alias `winserver`; the older
  `winserver01` reference was stale and has been corrected in `CLAUDE.md`.
- Leonel's console evidence proved `sshd` and Tailscale were running and TCP
  22 was listening on the PDC. Claude then proved LAN SSH through
  `192.168.20.11`; the documented Tailscale endpoint still timed out.
- The first real precheck exposed two fail-closed script defects rather than an
  AD outage: zero-count replication history was counted as a current failure,
  and clean `repadmin /showrepl ... /errorsonly` output returned native status
  `234` on both DCs. Codex corrected both conditions narrowly, and Claude
  reviewed each correction before replacing the temporary PDC copy.
- Leonel ran the corrected script locally in the authenticated PDC session.
  The fresh 2026-07-14 transcript ends `Q003_PRECHECK=PASS` and is saved at
  `projects/project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/evidence/q003-precheck-2026-07-14.txt`.
- The proof confirms both writable DCs, enabled Recycle Bin scope, the existing
  Quarantine OU, 180-day effective deleted-object lifetime, zero current
  replication failures, zero nonzero partner results, clean `repadmin`
  results, and zero live or deleted name collisions.
- No AD object was created, changed, deleted, moved, enabled, or restored.

**What remained gated when the precheck closed:** Leonel's exact dated approval and all
create/delete/restore execution. Q004 had to continue waiting at that point.

**Resolution steps used:**

1. Keep the sanitized passing precheck in the Q003 evidence folder.
2. Present the exact named-object approval statement in
   `docs/q003-change-window.md` to Leonel.
3. Do not use `-Mode Execute` until that dated approval is recorded.

**Approval update:** Leonel recorded the exact `Q003-20260714-LEONEL`
delete/restore exception and object-only recovery floor on 2026-07-14.
Supervised execution and final verification then passed.

### 🟢 RESOLVED — Item Q003-02: Execute, independently review, and close the test-object restore

**Leonel:** Ran the approved script from the authenticated PDC console after
providing the exact dated approval. The run ended `Q003_RESULT=PASS`.

**Claude:** Retrieved and independently reviewed the complete transcript
against the script, change window, and rollback plan. Claude confirmed the
same GUID and SID before deletion and after restore, both-DC verification,
clean replication, zero explicit memberships, the disabled Quarantine final
state, the 0.51-minute recovery time, and a clean secret scan.

**Codex:** Coordinated the guarded workflow, wrote and corrected the script,
verified Claude's findings, maintained the project/queue state, and produced
the first-person closeout with links to technical evidence.

**Evidence:**

- `projects/project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/evidence/q003-precheck-2026-07-14.txt`
- `projects/project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/evidence/q003-sanitized-transcript.txt`
- `projects/project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/evidence/q003-closeout.md`

**Final state:** Q003 is complete. The disposable test identity remains
disabled in Quarantine. Q004 is next; default domain policies remain out of
scope.

---

## CURRENT UPDATE — 2026-07-03

`WIN-DC02` now exists at `192.168.20.12` and has been promoted as a replica
domain controller, DNS server, and Global Catalog. Project 02 Phase 7 and Project
03 Phase 9 are complete. `WIN-PRQD8TJG04M` remains the FSMO holder, and direct
DNS queries now resolve the PDC hostname to `192.168.20.11` only.

Project 03 Phase 5 is now complete with a real conditional forwarder:
`localdomain` forwards to Route10 at `192.168.20.1`, replicates to both DCs, and
has recursion disabled for that forwarded zone. Route10 configuration was not
changed.

Project 04 is complete. Windows DHCP remains active and documented, and scope
`192.168.20.0/24` now advertises both AD DNS servers (`192.168.20.11` and
`192.168.20.12`). Route10 and OPNsense configuration were not changed.

---

## P03 PHASE 5 DISCOVERY — 2026-07-03 (Claude read-only, Leonel live execution)

### 🟢 RESOLVED — Item P03-P5-01: Real conditional forwarder found — `localdomain` to Route10

**Context:** Claude verified that OPNsense `internal` was not a viable DNS
forwarder target, Pi-hole at `192.168.10.26` did not host a useful local zone,
and Route10 answered Route10-registered names under `localdomain`.

**Decision:** Configure a Windows DNS conditional forwarder for `localdomain`
to Route10 at `192.168.20.1`. This is a Windows DNS change only. It does not
modify Route10 DHCP, routing, NAT, VLAN, firewall, or DNS configuration.

**Final configuration:**

```powershell
Add-DnsServerConditionalForwarderZone `
  -Name "localdomain" `
  -MasterServers 192.168.20.1 `
  -ReplicationScope "Forest"

Set-DnsServerConditionalForwarderZone -ComputerName WIN-PRQD8TJG04M -Name "localdomain" -UseRecursion $false
Set-DnsServerConditionalForwarderZone -ComputerName WIN-DC02 -Name "localdomain" -UseRecursion $false
```

**Final verification:**

- `localdomain` exists on both `WIN-PRQD8TJG04M` and `WIN-DC02`.
- Both DCs show `MasterServers : 192.168.20.1`.
- Both DCs show `UseRecursion : False`.
- `DESKTOP-QVM6OQN.localdomain` resolves to `192.168.50.28` through both
  `192.168.20.11` and `192.168.20.12`.
- `_ldap._tcp.Chongong.local` still resolves to both DCs after the change.

**Risk and rollback:** Low risk. If Route10 DNS is unavailable, only
`*.localdomain` lookups are affected. AD DNS and public DNS forwarding remain
separate. Rollback is:

```powershell
Remove-DnsServerConditionalForwarderZone -Name "localdomain" -Force
```

---

## PROJECT 03 EXECUTION LOG — 2026-06-23 (Claude, live session)

### 🟢 RESOLVED — Item P03-01: Project 03 (AD DNS Engineering) execution against live DC

**Context:** Leonel asked Claude to execute all 10 phases of Project 03 directly against
the live DC (WIN-PRQD8TJG04M, 192.168.20.11) via SSH (administrator credential, OpenSSH
Server on the DC, plink.exe as client since local WinRM client requires elevation Claude
doesn't have). Note: Project 02 prerequisite is not fully closed (WIN-DC02 replica still
pending) — proceeding against the single DC anyway per Leonel's instruction.

**Resolution (2026-06-23):** Project 03 current-PDC work was mostly complete and documented.
Phase 5 originally had no conditional-forwarder target, and Phase 9 was blocked
until `WIN-DC02` existed. **Superseded on 2026-07-03:** `WIN-DC02` now exists,
Phase 9 is complete, and Phase 5 is complete with the Route10 `localdomain`
conditional forwarder. Documentation was corrected to include proper phase
sections, screenshot plans, and valid internal links.

**Phase 1 — Audit: DONE (read-only)**
- Zones: `_msdcs.Chongong.local`, `Chongong.local` (both AD-integrated primary), plus
  default `0/127/255.in-addr.arpa` and `TrustAnchors`. **No 192.168.20.0/24 reverse zone
  exists yet** — Phase 4 gap confirmed.
- Forwarders: correctly set to `8.8.8.8`, `1.1.1.1`, `8.8.4.4`, and `9.9.9.9`.
- Scavenging: disabled (`ScavengingState: False`, interval `00:00:00`). Zone aging off on
  all zones. Phase 6 gap confirmed.
- **Real bug found (not a staged exercise):** DC's LAN NIC `vEthernet (External-VLAN-Trunk)`
  (192.168.20.11) had DNS client servers set to `8.8.8.8, 1.1.1.1` directly — exactly the
  anti-pattern the P03 README warns against. This caused `_ldap._tcp.Chongong.local` SRV
  lookups to fail locally on the DC (it queried public DNS first for an internal-only
  record). The SRV record itself exists and is correct in the zone — confirmed via
  `Get-DnsServerResourceRecord -ZoneName Chongong.local -RRType Srv`.
- vSwitch-WAN interface (192.168.10.194) also has `1.1.1.1` on it but is out of scope for
  this project (different subnet/VLAN) — left untouched.

**Phase 2 — Fix NIC DNS addressing: DONE**
- Fixed `vEthernet (External-VLAN-Trunk)` DNS client settings to use `127.0.0.1`.
- Verified `_ldap._tcp.Chongong.local` resolves correctly.
- Verified public resolution still works through forwarders.

**Phases 3, 5, 7, 9 — current outcome**
- Phase 3 (forwarders): complete.
- Phase 5 (conditional forwarders): complete with `localdomain` forwarding to
  Route10 at `192.168.20.1`.
- Phase 7 (split-brain DNS): already effectively true — `Chongong.local` is private/internal,
  forwarders handle public resolution. Document as satisfied, no config change needed.
- Phase 9 (WIN-DC02 DNS verification): complete after `WIN-DC02` promotion on `2026-07-03`.

**Phases 4, 6, 8, 10 — DONE**
- Phase 4: created reverse lookup zone for `192.168.20.0/24` and PTR for `WIN-PRQD8TJG04M`.
- Phase 6: enabled scavenging and zone aging on `Chongong.local`.
- Phase 8: documented one real DNS incident and two safe runbooks.
- Phase 10: documented Project 03, status, break/fix evidence, and screenshot plan.

**Credential note:** Administrator password was shared in plaintext in the chat session to
enable SSH access. Leonel was advised to rotate it once this project's live work is done.

---

## SKILL REVIEW REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item S02: Review winserver-evidence-documentation skill

Claude created `skills/winserver-evidence-documentation/SKILL.md` — a new evidence/portfolio
documentation skill guiding how to capture and publish proof for each Windows Server project.

**Resolution (2026-06-06):** Claude applied S02 corrections directly:
- Fixed Key Evidence table: `p05-ph9-*` → `p05-ph3-*`; screenshot cells now use inline image syntax `![label](verification/screenshots/file.png)`.
- Added Certificate Manager, IIS Manager, and Local Users and Groups sections to GUI Screenshot Guide (scoped to P01/P08/WAC evidence).
- No-Secrets Policy section was already present. GUI Track A + PowerShell Track B structure preserved.
**Do NOT push until Leonel reviews.**

---

## REVIEW REQUEST — 2026-06-05 (Claude → Codex)

The P01 skill was restructured based on prior Codex corrections. Codex reviewed:

- `skills/project-01-server-baseline-hardening.md`
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

---

### 🟢 RESOLVED — Item R01: Phase 2 GUI steps — GPMC navigation path

**Resolution:** The GPMC path is correct for editing a domain GPO on Windows Server 2022:

`Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Password Policy`

and:

`Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Account Lockout Policy`

**Note:** The `Policies` node appears when editing a domain GPO through GPMC. A local policy editor view may look slightly different, but this project is editing the Default Domain Policy through GPMC, so the current path is correct.

---

### 🟢 RESOLVED — Item R02: Phase 3 PSO — GG-Tier0-Admins creation order

**Resolution:** The current order is functionally valid. `adm-leonel` can be created before `GG-Tier0-Admins`. The group only needs to exist before:

1. adding `adm-leonel` to `GG-Tier0-Admins`, and
2. assigning `GG-Tier0-Admins` as the PSO subject.

**Applied fix:** Phase 3 now tells Leonel to create `adm-leonel` with a 20+ character password from the start because the Tier 0 PSO requires 20 characters. Fine-grained password policy changes do not revalidate an already-set password until the next password change.

---

### 🟢 RESOLVED — Item R03: Phase 5 RDP restriction — Tailscale IP placeholder

**Resolution:** The documentation warning is good, but the PowerShell example should not allow the broad placeholder to run.

`100.64.0.0/10` is too broad for the final rule because it represents the whole carrier-grade/Tailscale range. It is acceptable in explanatory text only.

**Applied fix:** Phase 5 now hard-fails unless Leonel replaces the placeholder with one specific management Tailscale IP.

---

### 🟢 RESOLVED — Item R04: Phase 6 net use command — Type 3 logon behavior

**Resolution:** The `net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\testuser ...` pattern should generate SMB network logon attempts and normally produces failed logon events with Logon Type 3, then Event 4740 when the threshold is reached.

**Applied fix:** Phase 6 now runs a one-attempt validation and confirms Event 4625 with Logon Type 3 before starting the full lockout loop. If the event shape is not confirmed, the guide tells Leonel to run the exercise from another domain-joined client.

---

### 🟢 RESOLVED — Item R05: Free review pass

**Resolution:** Codex found four additional corrections (R06-R09). All are now patched in the phase reference files.

---

## Codex Review Corrections

### 🟢 RESOLVED — Item R06: Fix Phase 5 UDP process property

**What:** `phase-5-firewall-baseline.md` used `$_.OwningProcessId` with `Get-NetUDPEndpoint`. The standard property is `OwningProcess`.

**Applied fix:** Both UDP calculated properties now use:

```powershell
@{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}
```

---

### 🟢 RESOLVED — Item R07: Add hard-fail guard to Phase 5 RDP restriction

**What:** The old script assigned `$TailscaleIP = "100.64.0.0/10"` and proceeded.

**Applied fix:** The script now uses `REPLACE_WITH_MANAGEMENT_TAILSCALE_IP` and throws if the placeholder, blank value, or `100.64.0.0/10` is left in place.

---

### 🟢 RESOLVED — Item R08: Tighten Phase 3 PSO GUI path and Tier0 password requirement

**What:** The ADAC path needed to explicitly mention the System container, and `adm-leonel` needed a 20+ character password requirement.

**Applied fix:** Phase 3 now uses:

`ADAC → Chongong (local) → System → Password Settings Container`

and tells Leonel to set `adm-leonel` with a 20+ character password.

---

### 🟢 RESOLVED — Item R09: Add loopback validation before Phase 6 lockout loop

**What:** Loopback SMB should work, but the lab should prove the event shape before triggering full lockout.

**Applied fix:** Phase 6 now has Step A2a: one bad attempt, confirm Event 4625 with Logon Type 3, then Step A2b runs the full loop.

---

---

## SKILL REVIEW REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item S01: Review winserver-projects skill file

Claude wrote a single comprehensive skill covering Projects 02–12.
Review `skills/winserver-projects.md` for technical accuracy before Leonel uses it.

**Check for:**
1. PowerShell cmdlet accuracy — correct parameters for Windows Server 2022 / AD module?
2. Phase sequencing — each project depends correctly on prior projects?
3. GUI paths — correct GPMC/ADUC/ADAC navigation for Server 2022?
4. Safety rules present — no Default Domain Policy edits, no AD object deletion
5. Hyper-V VM specs realistic for WIN-PRQD8TJG04M (13 VMs already running)?

**Specific items to verify:**
- P02: `Install-ADDSDomainController` parameters — are all required flags present?
- P02: `Set-ADDomainMode -DomainMode Windows2016Domain` — correct enum value for Server 2022 level?
- P03: `Set-DnsServerForwarder -IPAddress "8.8.8.8","1.1.1.1"` — replaces or appends existing forwarders?
- P04: `Add-DhcpServerv4Failover` parameters — `HotStandby` mode correct? `ReservePercent 5` sensible?
- P05: GPO audit policy path — `Advanced Audit Policy Configuration` vs `Audit Policy` — which is correct for domain GPO?
- P06: `$acl.SetAccessRuleProtection($true, $false)` — correctly blocks inheritance without copying existing ACEs?
- P09: WAC `msiexec` silent install flags — `SME_PORT` and `SSL_CERTIFICATE_OPTION` correct parameter names?
- P10: `wecutil qc /q:true` — correct syntax to initialize WEF collector quietly?
- P11: `Add-WBBackupTarget -Policy $Policy -Target $Target` before `Add-WBSystemState` — correct order?
- P12: Entra Connect staging mode — does the install wizard still offer staging mode in current version?

**After review:**
- Patch errors directly in `skills/winserver-projects.md`
- Log changes in `CODEX-LOG.md`
- Mark S01 🟢 RESOLVED
- Do NOT push to GitHub — Claude handles all pushes

---

## VERIFICATION REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item V01: Post-sync integrity check

Claude just completed a full skill sync from the local repo into both `.agents/skills/` and `.codex/skills/`. Before Leonel starts Project 01 Phase 2 on WIN-PRQD8TJG04M, please verify the following:

**Check 1 — Local repo skill files are complete and internally consistent:**
Read these files and confirm nothing is missing, truncated, or broken:
- `skills/project-01-server-baseline-hardening.md`
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

**Check 2 — All R06-R09 corrections are present in the local repo copies:**
- R06: `phase-5-firewall-baseline.md` — UDP uses `$_.OwningProcess` (not `OwningProcessId`)
- R07: `phase-5-firewall-baseline.md` — RDP hard-fail guard throws on placeholder or `100.64.0.0/10`
- R08: `phase-3-tiered-admin.md` — adm-leonel requires 20+ char password; ADAC path includes `System →` before `Password Settings Container`
- R09: `phase-6-lockout-breakfix.md` — Step A2a fires one attempt and checks Event 4625 + Logon Type 3 before the full loop

**Check 3 — Phase 2 is ready to execute:**
Confirm `phase-2-password-policy.md` has:
- Domain DN guard (`DC=Chongong,DC=local`)
- GUI steps via GPMC
- Rollback steps with correct order (LockoutThreshold=0 first, then reset observation window)
- `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath` syntax

**Resolution (2026-06-06):** All checks passed. `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath` confirmed at line 127 in local repo, `.agents/skills/`, and `.codex/skills/`. V02 resolved by Codex (commit 1b72e51) + Claude sync. **Ready for Phase 2.**

---

### 🟢 RESOLVED — Item V02: Phase 2 missing Restore-GPO rollback syntax

**Codex verification result:** V01 is not fully satisfied yet.

**What passed:**
- All seven P01 skill/reference files exist in the local repo and appear complete.
- The `.agents/skills/winserver-p01/` and `.codex/skills/winserver-p01/` mirrors contain the matching Project 01 skill and phase reference files. The local mirror folder name is `references/`; the repo folder name is `p01-references/`, but the file contents match the repo copies checked.
- R06-R09 corrections are present in the repo copy and both local skill mirrors:
  - UDP uses `$_.OwningProcess`, not `OwningProcessId`.
  - RDP restriction hard-fails on `REPLACE_WITH_MANAGEMENT_TAILSCALE_IP` or `100.64.0.0/10`.
  - Phase 3 includes the 20+ character Tier 0 password requirement and `System → Password Settings Container` path.
  - Phase 6 validates Event 4625 and Logon Type 3 before running the full lockout loop.
- Phase 2 includes the domain DN guard, GPMC GUI steps, and safe rollback order with `LockoutThreshold` set to 0 first.

**What failed:**
`skills/p01-references/phase-2-password-policy.md` does not include the exact PowerShell restore command required by V01:

```powershell
Restore-GPO -Name "Default Domain Policy" -Path $BackupPath
```

The same missing command is also absent from both local skill mirrors:
- `.agents/skills/winserver-p01/references/phase-2-password-policy.md`
- `.codex/skills/winserver-p01/references/phase-2-password-policy.md`

**Required fix before Phase 2:**
Add a PowerShell restore option under the Phase 2 rollback section, after the GUI restore path and before/manual rollback commands. Suggested block:

```powershell
$BackupPath = "C:\GPO-Backups\<date-folder>"
Restore-GPO -Name "Default Domain Policy" -Path $BackupPath
```

Then sync the updated `phase-2-password-policy.md` from the repo into both local skill mirrors. After that, Codex should re-check V01 and mark V01/V02 resolved if the command is present in all three locations.

**Resolution (2026-06-06):** Fixed by Codex on GitHub (commit 1b72e51). Claude pulled, synced to both skill mirrors, and verified `Restore-GPO` present at line 127 in all three locations.

---

## DESIGN REVIEW REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item D01: Review Project READMEs 02–12

Claude designed the full content for Projects 02–12 (phases, commands, architecture decisions).
These are new files — Codex has not reviewed them yet. Before Leonel pushes to GitHub,
Codex must review all 11 READMEs for technical accuracy.

**Files to review:**
- `projects/project-02-ad-architecture/README.md`
- `projects/project-03-dns-engineering/README.md`
- `projects/project-04-dhcp-ipam/README.md`
- `projects/project-05-gpo-security-baselines/README.md`
- `projects/project-06-file-server-access-governance/README.md`
- `projects/project-07-windows-client-lifecycle/README.md`
- `projects/project-08-hyperv-operations/README.md`
- `projects/project-09-powershell-admin-platform/README.md`
- `projects/project-10-security-monitoring-ir/README.md`
- `projects/project-11-backup-disaster-recovery/README.md`
- `projects/project-12-m365-entra-hybrid-identity/README.md`

**Check each file for:**
1. PowerShell command accuracy (correct cmdlets, properties, parameter names)
2. Phase sequencing — does each phase depend correctly on the prior one?
3. Cross-project dependencies — does the project correctly reference what earlier projects build?
4. Any commands that would break or cause data loss on Chongong.local if run as-written
5. Naming consistency — all accounts, groups, VMs, OUs match naming-standards.md and identity-design.md

**Specific items to verify:**
- P02: `Install-ADDSDomainController` parameters for replica DC promotion — are flags correct?
- P03: `Add-DnsServerPrimaryZone -NetworkID` syntax — correct for reverse zone creation?
- P04: `Add-DhcpServerv4Failover` parameters — correct for Hot Standby mode?
- P05: GPO path for Advanced Audit Policy Configuration — correct GPMC navigation?
- P06: `SetAccessRuleProtection($true, $false)` — does this correctly block inheritance without copying?
- P08: `Remove-WindowsFeature` for RDS — will this break domain auth if run while users are in sessions?
- P09: WAC install command `msiexec /i` flags — correct silent install syntax for WAC gateway mode?
- P10: WEF subscription XML format — does `wecutil cs` expect a file path or inline XML?
- P11: Tombstone lifetime warning — 60 days correct for Windows Server 2022 default?
- P12: Entra Connect sync scope by OU — confirm wizard allows OU-level filtering in current version

**After review:**
- Patch any errors directly in the README files
- Mark corrected items in CODEX-LOG.md
- Change this item to 🟢 RESOLVED when all 11 files are verified

**Resolution (2026-06-06):** Codex reviewed all 11 Project 02–12 README files against
`docs/naming-standards.md`, `docs/identity-design.md`, and the D01 technical checklist.
Corrections were applied directly to the README files for DC promotion, DNS reverse-zone
creation, DHCP failover sequencing, domain account policy GPO behavior, NTFS inheritance
handling, RDS removal safety, WAC install syntax, WEF subscription creation, DR/tombstone
warnings, and Entra Connect OU filtering/staging. `docs/identity-design.md` was also corrected
to use the real AD DS functional-level labels and include the Tier2 workstation admin OU.

---

## Previously Resolved Items (2026-06-05)

### 🟢 RESOLVED — Item 01: Verify domain DN
DC=Chongong,DC=local confirmed. Domain DN guard check added to Phase 2.

### 🟢 RESOLVED — Item 02: radius-service investigation
NPS export read-only at C:\Audit\. Not committed to GitHub. Commands in Phase 4.

### 🟢 RESOLVED — Item 03: __vmware__ group
Keep as-is. Investigation commands in Phase 4. Deferred to Project 02.

### 🟢 RESOLVED — Item 04: OU naming standard
`_Admin` with Tier0/Tier1/Tier2/ServiceAccounts sub-OUs. Phase 3 updated.

### 🟢 RESOLVED — Item 05: RDS migration scope
Project 08 targets: WIN-RDS01 (Session Host), WIN-RDWEB01 (optional Gateway/Web). Added to topology.md.

### 🟢 RESOLVED — All Codex corrections applied
See CODEX-LOG.md for session details.
