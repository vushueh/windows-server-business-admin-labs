# CODEX-LOG.md — Codex Session Log

Codex writes here after every session. Claude reads this to stay in sync.

---

## Session — 2026-07-22 — Q012 final platform closeout

### Verified result

- Claude proved the exact pre-fault Hyper-V state and preserved Q011 Off and
  unchanged throughout the Linux guest fault/repair work.
- After Leonel's repaired reboot proof, Claude isolated Q012 and restored only
  the clean Standard checkpoint; Leonel independently proved the restored
  guest healthy.
- Claude isolated Q012 again, removed only the named checkpoint, and observed
  the merge complete with zero checkpoints and zero `.avhdx` files.
- Final platform state: Q011 Off on `vSwitch-LAN`/Access VLAN 70 with zero
  checkpoints; Q012 Off/disconnected/Untagged/GSI-disabled/DVD-free/
  checkpoint-free with one merged base VHDX.

### Gate

- The Linux owner has closed Q012 and canonical state advances to Q013.
- No commit or push occurred.

## Session — 2026-07-22 — Q012 Phase 4 platform completion

### Verified result

- Q012's copied disk, unique guest identity, healthy reboot proof, and exact
  temporary-media cleanup passed under the Linux owner.
- Claude used the Windows-owned Hyper-V boundary to attach Q012 only after
  identity sanitation, then later isolated the powered-off VM and created the
  single Standard checkpoint `Q012-CLEAN-BEFORE-FAULT`.
- Leonel kept SSH enabled for continued work. Claude restored Q012 Running on
  `vSwitch-LAN`/Access VLAN 70 with a valid DHCP lease.
- Q011 remains Off on its approved Access VLAN 70 attachment and has zero
  checkpoints. Q012 has GSI disabled, zero DVDs, and exactly one checkpoint.

### Gate

- No systemd fault has been injected.
- The Linux-owned Phase 5–6 window requires separate exact approval and must
  isolate Q012 before checkpoint restore and final cleanup.
- No commit or push occurred.

## Session — 2026-07-22 — Q012 source-isolation preflight and restoration

### What I did

- Used the Windows-owned Hyper-V boundary for a read-only Q012 Phase 4
  preflight.
- Verified Q011 is Off, automatic checkpoints are disabled, and it has one
  adapter and zero checkpoints; Q012 and its target path do not exist.
- Found Q011 attached to `vSwitch-LAN` on access VLAN 70 instead of its
  completed disconnected, Untagged retention state.
- Stopped without mutation and recorded the exact platform-owner blocker.

### Approved restoration result

- Leonel approved restoring only Q011's adapter isolation and explicitly
  excluded Q012 creation.
- Exact prechecks matched. Q011's single adapter was disconnected and set
  Untagged/VLAN 0.
- Immediate verification and a separate fresh preflight proved Q011 remained
  Off with one adapter and zero checkpoints; Q012 and its target path remained
  absent.
- `Q011IsolationRestorePass=True` and `FreshPhase4PreflightPass=True` returned.
- The cause of the drift remains unknown.

### Safety boundary

- Only Q011's adapter connection and VLAN mode changed within the exact
  approval. No VM was started; no VHDX, checkpoint, guest, credential, Q012 VM,
  or Q012 target path changed or was created.
- Leonel later clarified that the future post-copy attachment applies to Q011,
  not Q012. The revised plan returns Q011 to `vSwitch-LAN`/Access VLAN 70 only
  after the offline copy hash matches, keeps Q011 Off and checkpoint-free, and
  keeps Q012 disconnected.
- This clarification changed repository plans only. It did not authorize or
  perform the clone, source reattachment, or another live action.

### Approved Phase 4 host stage

- Leonel approved the exact revised Phase 4 window on 2026-07-22.
- Claude executed the first host block with exit code 0. The offline VHDX
  hashes matched, Q011 returned Off to `vSwitch-LAN`/Access VLAN 70 with zero
  checkpoints, and Q012 was created Off with the planned Generation 2
  hardware, Secure Boot, one disconnected Untagged adapter, and zero
  checkpoints.
- A separate readback and second full hash comparison passed. Claude stopped
  before Q012 start, guest access, reboot, or checkpoint creation and removed
  both temporary helper scripts.
- Leonel's credentialed Q012 console baseline is next; no fault is authorized.

### Approved disconnected transfer attempts

- Q012 was started manually and remained disconnected/Untagged with zero
  checkpoints. Leonel could not enter the multiline baseline through VMConnect.
- One approved Guest Service Interface copy stopped with `0x800710DF` while the
  guest FCOPY daemon was inactive. After a console check and separate approval,
  Leonel started the existing disabled daemon and reported it active.
- Claude made the single permitted hash-verified retry. `Copy-VMFile` returned
  `0x80004005`; no second retry occurred. The failure branch disabled Guest
  Service Interface, removed host staging, and preserved Q012 isolation.
- Guest evidence showed FCOPY `pread` I/O errors. Leonel stopped the daemon and
  proved it inactive/disabled. No third VMBus attempt is authorized.
- Read-only fallback inspection found Q012 has no DVD drive and the host lacks
  `oscdimg`. A clarification directly proved IMAPI2FS and ADODB COM objects are
  available, so a no-install temporary ISO/DVD fallback is viable but awaits
  Leonel's exact approval.
- Leonel then supplied the exact ISO/DVD approval. The first executor stopped
  before host prechecks or mutation because the Linux source exists only on the
  workstation. No staging directory, ISO, or DVD was created. Fresh Claude CLI
  contexts rejected Codex-relayed approval for SCP staging, so direct
  Claude-addressed confirmation is now required.
- Leonel subsequently addressed Claude directly. The root Tier 3 rule required
  a formal plan, so the Linux owner now carries the approved ISO/DVD change
  window and rollback using the current `winserver` alias. Claude's mechanics
  review corrections—one-time executor assignment, case-normalized hashes, and
  GUID staging—are applied. No live artifact exists yet.
- Claude executed the approved ADODB-based ISO window through `winserver`.
  Every source and VM precheck passed, but the host exposed the IMAPI result as
  an IUnknown-only stream that ADODB could not write. No ISO/mount/DVD existed;
  GUID staging was removed and final containment passed.
- The Linux owner now carries a reviewed in-memory C# IStream/FileStream retry.
  Claude's required Seek removal and compiler-temp-file wording corrections are
  applied; the retry awaits a new exact approval.
- Leonel approved the corrected IStream retry. Claude created and host-mounted
  the 1,179,648-byte ISO, proved the one root script and pinned hash, dismounted
  host validation, and added exactly one Q012 DVD at controller 0/location 1.
- Final platform proof preserved Q011 Off on its approved LAN/VLAN and Q012
  Running/disconnected/Untagged/GSI-disabled/checkpoint-free. One empty
  literal-`$GUID` directory was cleaned before staging. Claude stopped before
  guest execution; the temporary ISO/DVD remains for Leonel's console step.
- Leonel passed the console baseline and unmounted the media. Under a separate
  exact approval Claude removed only the verified DVD and ISO/GUID directory.
  Q012 is Running/disconnected/GSI-disabled/checkpoint-free with zero DVDs;
  Q011 is unchanged. Reboot proof is next.

## Session — 2026-07-22 — Q012 owner reconciliation and repository design

### What I did

- Recovered Q012 as the dependency-ready successor to completed Q011.
- Reconciled the stale Proxmox owner with the actual retained Hyper-V baseline,
  prepared Q012 under Project 08, then moved it before commit into Leonel's
  approved `enterprise-linux-administration-labs` portfolio.
- Prepared a disconnected clone design, healthy custom systemd fixture,
  intentional wrong-`ExecStart` override, two exact live change windows,
  rollback plan, evidence expectations, and stop conditions.
- Used one bounded read-only Claude consultation for the owner/platform
  decision, then independently verified the material claims against the local
  repository instructions and queue state.

### Files created/modified

- Windows root, project index, Project 08 navigation, Q011 frozen-mirror
  banner, `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- Q011 remains off, disconnected, checkpoint-free, and unmodified.
- Q012 uses a hash-verified offline VHDX copy and remains disconnected.
- The custom oneshot unit touches only a lab marker file; the sole fault is a
  drop-in that points `ExecStart` to a nonexistent executable.
- Phase 4 clone/baseline and Phase 5–6 fault/repair/revert require separate
  exact approvals. No live authority is implied by this design.

### Cross-family impacts

- Q011/Q012 and Q042-Q047 transfer into the dedicated Linux portfolio. Windows
  remains the Hyper-V platform owner, not the Linux project owner.
- The complete Q011 tree remains here only as a frozen public mirror until the
  new repository passes its public-visibility gate.

### Open questions for Claude

- None for Q012 design. Live Phase 4 remains approval-gated.

## Session — 2026-07-21 — Q011 successor handoff correction

### What I did

- Kept the completed Q011 documentation and evidence unchanged.
- Replaced its generic future-work paragraph with the required immediate
  successor handoff to Q012 — systemd Break/Fix Lab.
- Migrated the two safe Phase 1 OPNsense policy screenshots and their hashes
  from the obsolete Proxmox draft worktree before retiring it.
- Kept Q012 plain text because it is planned, not completed, and made clear
  that Q011 closure grants no live authority.
- Coordinated the owner change with the Proxmox predecessor, canonical queue,
  and vault relationship records.

### Safety boundary

- Repository-only documentation update; no Hyper-V host, VM, VHDX, ISO,
  network, credential, Git history, or live-system action occurred.

## Session — 2026-07-21 — Q011 Phase 9 retention intake and closure

### What I did

- Copied both reviewed safe Phase 9 Hyper-V screenshots byte-for-byte into
  Q011 evidence and recorded their exact SHA-256 manifest.
- Documented `RETAIN-Q011`, the complete structured read-only retention
  result, and `Phase9RetentionPass=True` without claiming a VM change.
- Embedded the two Phase 9 images inside the phase narrative and retained the
  linked two-image walkthrough and searchable result.
- Converted the Phase 9 decision run sheet and screenshot plan into historical
  records, marked Q011 complete, and added its final collaboration
  retrospective and next-step boundary.
- Synchronized Q011, Project 08, project-index, root navigation, review, and
  session status while keeping the broader P08 project planned.
- Re-parsed the Phase 9 Windows PowerShell fence, matched both source/copy
  hashes, verified the screenshot manifest and links/images, enforced the
  README phase-image limit, and passed stale-status, secret, conflict, and
  diff-whitespace checks.
- Performed no live host/VM access, infrastructure change, credential access,
  commit, push, merge, GitHub action, or publication during local closure.

### Files created/modified

- two Phase 9 PNGs under Q011 `evidence/screenshots/`
- `evidence/q011-phase9-evidence.md`
- `evidence/q011-phase9-sanitized-results.txt`
- `evidence/q011-phase9-visual-walkthrough.md`
- `evidence/q011-phase9-screenshots.sha256`
- Phase 9 decision and screenshot-plan historical status
- Q011 README, Project 08, project/root navigation, `CLAUDE-REVIEW.md`, and
  this log

### Architecture decisions made

- Q011 is retained because no backup/export proof or replayed rebuild exists.
- Retention preserves the verified VM, VHDX, RHEL lifecycle state, OPNsense
  reservation, and shared ISO without authorizing a start or mutation.
- Backup/restore, replayed rebuild, future patching, cloning, repurposing, and
  disposal are separate change windows outside completed Q011.
- The broader Project 08 inventory, switch, RDS, checkpoint, and backup work
  remains planned; Q011 completion does not complete P08.

### Open questions for Claude

- None. Q011-11 is resolved and Q011 is complete locally. Publication remains
  separately approval-gated.

## Session — 2026-07-21 — Q011 Phase 8 intake and Phase 9 preparation

### What I did

- Copied all three reviewed safe Phase 8 screenshots byte-for-byte into Q011
  evidence and recorded their exact SHA-256 manifest.
- Documented passing host/network gates, stable controls, intended
  registration/trust/network/kernel/history changes,
  `Phase8GuestBaselinePass=true`, and `Phase8EndStatePass=True` isolation.
- Recorded the initial unprivileged empty SSH-hash collection and the approved
  retry. The current hash matched the original Phase 5 screenshot, so Codex
  corrected only the two-character local text transcription and expected
  value; no guest state changed.
- Embedded the two strongest Phase 8 images inside the phase narrative and
  used all three in the linked visual walkthrough.
- Created an evidence-linked manual rebuild record that does not overclaim a
  replayed rebuild, export, backup, or unattended build.
- Prepared a mutually exclusive Phase 9 decision run sheet. Retention is
  recommended and read-only; disposal intent stops before deletion and
  requires three later owner-specific windows.
- Ran one bounded read-only Claude Fable review. Claude returned `PASS` with
  four minor/informational findings; Codex applied VLAN, ISO-evidence, and
  screenshot-boundary clarifications and retained exact lifecycle identifiers
  for safe targeting.
- Re-parsed every new Bash and Windows PowerShell fence, matched all Phase 8
  source/copy hashes, verified the manifest and links/images, enforced the
  README phase-image limit, and passed secret/conflict/diff checks.
- Performed no live host/VM access, package/service/network change,
  registration/OPNsense/deletion action, credential access, commit, push,
  merge, GitHub action, or publication during local intake/preparation.

### Files created/modified

- three Phase 8 PNGs under Q011 `evidence/screenshots/`
- `evidence/q011-phase8-evidence.md`
- `evidence/q011-phase8-sanitized-results.txt`
- `evidence/q011-phase8-visual-walkthrough.md`
- `evidence/q011-phase8-screenshots.sha256`
- `docs/q011-manual-rebuild-record.md`
- `docs/q011-phase9-retention-disposal-decision.md`
- `evidence/q011-phase9-claude-review.md`
- Phase 8 run-sheet status, Q011 README, screenshot plan, Project 08,
  family/root navigation, `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- Retention is recommended because the verified baseline has no backup/export
  and the manual rebuild record has not been replayed.
- The retention branch is read-only; the disposal branch records intent only.
- Red Hat lifecycle, OPNsense reservation cleanup, and destructive Hyper-V
  VM/VHDX cleanup require separate future owner-specific windows.
- The verified shared RHEL ISO is never a disposable Q011 object.
- Phase 9 hands-on retention uses two safe Hyper-V GUI captures; repository-
  only planning has no screenshot because it proves no live state.

### Open questions for Claude

- None. Q011-10 is resolved. Leonel must choose exactly `RETAIN-Q011` or
  `PLAN-DISPOSAL-Q011` before Phase 9 can proceed.

## Session — 2026-07-21 — Q011 Phase 7P intake and Phase 8 preparation

### What I did

- Copied all four reviewed safe Phase 7P screenshots byte-for-byte into Q011
  evidence and recorded their exact SHA-256 manifest.
- Documented the one successful DNF history transaction, newest installed
  kernel, one reboot, healthy post-reboot controls, zero final updates, and
  `Phase7PEndStatePass=True` final isolation.
- Recorded the lost immediate shell-exit capture honestly and based the
  success claim on DNF history `Return-Code: Success`, installed kernels, and
  post-reboot evidence; no exit value was reconstructed.
- Embedded the two strongest Phase 7P images inside the phase narrative and
  used all four in the linked visual walkthrough.
- Updated the Phase 7P change/recovery sheets to historical executed records
  and synchronized Q011, Project 08, family, and root status links.
- Prepared a separate repository-only Phase 8 read-only post-patch comparison,
  manual rebuild-evidence, safe screenshot, shutdown, and isolation run sheet
  with a paired failure-containment plan.
- Ran one bounded read-only Claude Fable review. Claude returned
  `CONDITIONAL` with three Medium and three Low findings; Codex corrected the
  semantic output gates, repository parser, shutdown polling, guarded object
  diagnostics, and attachment-failure containment.
- Re-parsed every new Bash and Windows PowerShell fence, matched all source
  and destination screenshot hashes, verified the manifest and links/images,
  enforced the README image limit, and passed secret/conflict/diff checks.
- Performed no live host/VM access, package/configuration action, credential
  access, commit, push, merge, GitHub action, or publication.

### Files created/modified

- four Phase 7P PNGs under Q011 `evidence/screenshots/`
- `evidence/q011-phase7p-evidence.md`
- `evidence/q011-phase7p-sanitized-results.txt`
- `evidence/q011-phase7p-visual-walkthrough.md`
- `evidence/q011-phase7p-screenshots.sha256`
- `docs/q011-phase8-postpatch-validation-and-rebuild-evidence.md`
- `docs/q011-phase8-failure-containment.md`
- `evidence/q011-phase8-claude-review.md`
- Phase 7P run-sheet status, Q011 README, screenshot plan, Project 08,
  family/root navigation, `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- Phase 8 is guest-read-only; a comparison failure is evidence and
  containment, never authority to repair.
- Phase 5 remains the stable-control baseline, while Phase 6 registration,
  DHCP persistence, Phase 7K trust, and Phase 7P package/kernel/history state
  are classified as intended differences.
- A Markdown screenshot is not rebuild proof. The manual rebuild record must
  cite the existing hands-on installation, networking, trust, patch, and
  validation evidence.
- Phase 8 requires three safe hands-on images, with no more than two embedded
  in the project README.

### Open questions for Claude

- None. Q011-09 is resolved. Live Phase 8 remains separately approval-gated.

## Session — 2026-07-21 — Q011 Phase 7K intake and Phase 7P preparation

### What I did

- Copied all three reviewed safe Phase 7K screenshots byte-for-byte into Q011
  evidence and recorded their exact SHA-256 manifest.
- Documented the passing zero-key preflight, exact imported three-certificate
  Red Hat trust set, both retained cached RPM samples returning dual-signature
  and digest `OK`, no DNF invocation, and
  `Phase7KEndStatePass=True` final isolation.
- Embedded the two strongest Phase 7K images inside the phase narrative and
  used all three in the linked visual walkthrough.
- Updated the Phase 7K run sheet from a prepared plan to a historical executed
  record and synchronized Q011, Project 08, family, and root status links.
- Prepared a separate repository-only Phase 7P single-transaction patch,
  reboot validation, failure containment, final isolation, and four-image
  future hands-on capture plan.
- Ran one bounded read-only Claude Fable review. Claude returned `CONDITIONAL`
  with three Medium and two Low findings; Codex corrected timeout containment,
  update-state disposition, kernel-optional transaction handling,
  repository-error handling, and package-process matching.
- Performed no host/VM access, DNF command, package/service/network change,
  credential access, commit, push, merge, GitHub action, or publication.

### Files created/modified

- three Phase 7K PNGs under Q011 `evidence/screenshots/`
- `evidence/q011-phase7k-evidence.md`
- `evidence/q011-phase7k-sanitized-results.txt`
- `evidence/q011-phase7k-visual-walkthrough.md`
- `evidence/q011-phase7k-screenshots.sha256`
- `docs/q011-phase7p-controlled-patch-retry-change-window.md`
- `docs/q011-phase7p-controlled-patch-retry-recovery.md`
- `evidence/q011-phase7p-claude-review.md`
- Phase 7K run-sheet status, Q011 README, screenshot plan, Project 08,
  family/root navigation, `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- Trust repair and package transaction remain separate executed/approval
  boundaries; Phase 7K makes no patch claim.
- A successful DNF transaction does not require repository content still to
  include the originally proposed kernel. `new_kernel_present` is recorded
  separately, while post-reboot success requires the newest installed kernel.
- Final update exit `100` is an explicit `UpdatesRemain` controlled stop, not
  a currentness claim or authority for a second transaction.
- Shutdown timeout proves network containment separately from Off-state
  recovery; forced power-off remains outside the prepared window.
- Phase 7P hands-on work must capture the transaction review, transaction
  success, post-reboot validation, and final safe state without secrets.

### Open questions for Claude

- None. Q011-08 is resolved. Live Phase 7P remains separately
  approval-gated.

## Session — 2026-07-21 — Q011 Phase 7G intake and Phase 7K preparation

### What I did

- Copied the three reviewed safe Phase 7G screenshots byte-for-byte into Q011
  evidence and verified their exact SHA-256 manifest.
- Documented the passing package/key-file integrity, filtered BaseOS and
  AppStream trust fields, empty RPM trust list, 93 cached RPMs, two exact
  repository-scoped samples with all digests `OK` and signatures `NOKEY`, and
  final `Phase7GEndStatePass=True` isolation.
- Corrected the previously split read-only `awk` predicate in the historical
  Phase 7G run sheet and synchronized Q011, Project 08, family, and root status
  links.
- Prepared a repository-only Phase 7K native-RPM trust import, same-block
  exact rollback, two-sample signature verification, final isolation, and
  three-image future hands-on capture plan. The window contains no DNF action.
- Ran one bounded read-only Claude Fable review with one exact-path
  clarification. Claude returned `CONDITIONAL` with three Medium and four Low
  findings. Codex independently corrected the rollback continuity,
  display-parser, identity wording, entry count, inherited paths, `pipefail`
  probes, and final PowerShell terminating-error behavior.
- Verified RPM's documented `KEYHASH` delete contract and upstream
  `rpmkeys.c` list/delete implementation before replacing display parsing with
  the machine-readable `%{VERSION}-%{RELEASE}` query.
- Performed no host/VM access, key import, DNF command, infrastructure change,
  credential access, commit, push, merge, GitHub action, or publication.

### Files created/modified

- three Phase 7G PNGs under Q011 `evidence/screenshots/`
- `evidence/q011-phase7g-evidence.md`
- `evidence/q011-phase7g-sanitized-results.txt`
- `evidence/q011-phase7g-visual-walkthrough.md`
- `evidence/q011-phase7g-screenshots.sha256`
- `evidence/q011-phase7k-claude-review.md`
- `docs/q011-phase7g-gpg-trust-read-only-investigation.md`
- `docs/q011-phase7k-rpm-trust-repair-change-window.md`
- `docs/q011-phase7k-rpm-trust-repair-rollback.md`
- Q011, Project 08, family/root status/navigation, screenshot plan,
  `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- Trust repair and DNF retry remain separate approvals and change windows.
- The exact installed-package verification and pinned whole-bundle SHA-256 are
  the primary input-identity controls; the configured-source fingerprint
  comparison supplies the published trust link, while short IDs are
  post-import set evidence rather than standalone authentication.
- Ordinary post-import gate failures invoke rollback within the same pasted
  shell block. An SSH transport loss or RPM query failure stops and requires
  isolation plus exact recovery rather than a broad erase.
- Future Phase 7K hands-on work captures safe trust-list, cached-signature, and
  final-isolation screenshots; repository-only preparation has an explicit
  no-screenshot rationale.

### Open questions for Claude

- None. Q011-07 is resolved. Live Phase 7K remains separately approval-gated.

## Session — 2026-07-20 — Q011 Phase 7 stop intake and Phase 7G preparation

### What I did

- Visually reviewed all five Phase 7 screenshots for safe retention, copied
  them byte-for-byte into the Q011 evidence directory, and recorded exact
  SHA-256 hashes.
- Documented the passing preflight and pre-update baseline, reviewed
  five-install/88-upgrade transaction, three declined Red Hat signing-key
  prompts, `upgrade_exit=1`, unchanged original DNF history, no observed
  package modification or reboot, and `Phase7RecoveryPass=True`.
- Embedded the two strongest truthful images inside the Phase 7 README
  narrative at width 900 and placed all five in the linked walkthrough with
  explicit proves/does-not-prove text. The uncreated post-update screenshot is
  explicitly recorded rather than fabricated.
- Converted the Phase 7 change window and recovery plan into historical
  stopped-window records and synchronized the Q011, Project 08, family, and
  root status/navigation files.
- Prepared a repository-only Phase 7G read-only GPG trust investigation and
  paired containment plan. The future window inspects only the package-owned
  key file, filtered repository trust fields, RPM public-key state, and two
  existing repository-scoped cached RPM signatures.
- Used the verified native Claude CLI with the Fable model for one bounded
  review and one response-format clarification. Every Claude tool was
  disabled. Codex resolved its VLAN start-gating, DNF side-effect,
  cached-sample provenance, option clarity, fingerprint wording, ASA boundary,
  and shutdown-wait findings.
- Performed no live host/VM access, key import, DNF retry, cache cleanup,
  package action, Git/GitHub operation, commit, push, merge, or publication.

### Files created/modified

- five Phase 7 PNGs under the Q011 `evidence/screenshots/` directory
- `evidence/q011-phase7-evidence.md`
- `evidence/q011-phase7-sanitized-results.txt`
- `evidence/q011-phase7-visual-walkthrough.md`
- `evidence/q011-phase7-screenshots.sha256`
- `docs/q011-phase7-controlled-patching-change-window.md`
- `docs/q011-phase7-controlled-patching-rollback.md`
- `docs/q011-phase7g-gpg-trust-read-only-investigation.md`
- `docs/q011-phase7g-gpg-trust-investigation-containment.md`
- `evidence/q011-phase7g-claude-review.md`
- Q011, Project 08, family/root navigation, screenshot plan,
  `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- An unexpected signing-key import is a fail-closed stop, not an implicit
  extension of package-change authority.
- Phase 7G contains no DNF invocation, repository contact, download, import,
  package transaction, or cache cleanup.
- Q011 cannot start until the temporary adapter is re-read and proves the exact
  `vSwitch-LAN` Access VLAN 70 state; any setup error restores disconnected
  Untagged VLAN 0.
- A successful Phase 7G diagnosis still ends Off and isolated. Any later key
  import or patch retry requires a separate supported change window.

### Open questions for Claude

- None. Q011-06 is resolved. Live Phase 7G remains separately approval-gated.

## Session — 2026-07-20 — Q011 Phase 6 intake and Phase 7 preparation

### What I did

- Reviewed and copied all twelve safe Phase 6 practice captures into the Q011
  evidence directory without altering their pixels. The two strongest images
  appear inside the Phase 6 README narrative at width 900; all twelve appear
  with explicit claim boundaries in the linked visual walkthrough.
- Recorded the complete Phase 6A–6E result, including the OPNsense reservation,
  the first failed automatic-activation claim, the narrow existing-profile
  autoconnect correction, automatic reboot persistence, Windows 11 SSH,
  Boolean-only registration/repository checks, and final isolation.
- Created searchable Phase 6 results and an exact SHA-256 screenshot manifest;
  all twelve retained images pass the manifest.
- Prepared a repository-only Phase 7 controlled-patching draft and paired
  recovery plan. The draft requires the Phase 6 safe state, one package
  transaction, explicit acceptance that no current image backup/checkpoint
  exists, repository checks, one reboot, exact final isolation verification,
  and three planned hands-on screenshots.
- The normal Claude npm wrapper remained broken after reset, so Codex used the
  valid installed Windows native binary without changing the installation.
  Claude Fable returned a conditional approval with one High, four Medium,
  and three Low findings. Codex verified and corrected all eight findings.
- Moved the actual package transaction from SSH to VMConnect, removed
  unattended `-y`, scripted the root-space gate, narrowed post-reboot exit
  `100`, added lost-console accounting, and made a shutdown timeout contain
  Q011's network before stopping. Phase 7 is now reviewed and prepared but
  remains unexecuted and separately approval-gated.
- Updated the Windows family and Project 08 indexes through the completed
  Phase 6 result. No host, VM, network, credential, Git, GitHub, commit, push,
  merge, or publication action occurred.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase6-evidence.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase6-sanitized-results.txt`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase6-visual-walkthrough.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase6-screenshots.sha256`
- twelve Phase 6 PNGs under `evidence/screenshots/`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase7-controlled-patching-change-window.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase7-controlled-patching-rollback.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase7-claude-review.md`
- Q011, Project 08, family navigation, screenshot plan, review bridge, and this
  log

### Architecture decisions made

- The OPNsense reservation and existing-profile autoconnect correction remain
  the accepted persistence design; no guest static address is introduced.
- Phase 7 does not call evidence a backup and does not promise a blind
  `dnf history undo`. A failed update is contained; a prior kernel may be
  selected once, while a rebuild from the verified ISO requires new approval.
- Crossing the package-transaction boundary requires a separate exact operator
  confirmation that no current checkpoint, VM export, or image backup exists.
- The package transaction runs interactively at VMConnect, not SSH, so Leonel
  can inspect the transaction and an SSH interruption cannot kill it.
- The Phase 7 README will display at most two primary screenshots; final
  Off/disconnected proof is retained in the linked walkthrough.

### Cross-family impacts

- The live OPNsense Dnsmasq reservation already created during Phase 6 is
  documented here as Q011 evidence. No OPNsense, canonical, vault, Proxmox, or
  other repository was changed in this local intake.

### Open questions for Claude

- None. The bounded Phase 7 review is resolved. Live execution still requires
  Leonel's separate exact approval.

## Session — 2026-07-19 (Q011 Phase 4A ISO staged and evidenced)

### What I did

- Guided Leonel through exact host/admin/destination preflight, safe
  cancellation of a non-responsive scripted attempt, and fresh-session cleanup
  verification.
- Guided the manual exact-file copy and a separately approved correction from
  accidental `D:\Hyper-V\ISOs` to frozen `D:\Hyper-V\ISO`.
- Verified the final 11,059,986,432-byte local ISO against the pinned SHA-256;
  `SizePass=True`, `ChecksumPass=True`, `OldFileAbsent=True`,
  `VMCreated=False`, and `NetworkChanged=False`.
- Reviewed Leonel's final File Properties screenshot, copied the original PNG
  unchanged into phase evidence, recorded its SHA-256, and embedded it inside
  the Phase 4A narrative at width 900.
- Recorded the visible Windows Unblock control as a Phase 4B read-only
  preflight item. No unblock, VM, VHDX, switch, network, commit, push, merge,
  or GitHub action occurred.

### Cross-family impacts

- Proxmox remains predecessor evidence. Canonical and vault state now show
  Phase 4A complete in the Windows owner and Phase 4B separately gated.

### Open questions for Claude

- None for Phase 4A. Phase 4B requires a new exact design/preflight approval.

## Session — 2026-07-19 (Q011 Phase 2C Hyper-V owner/design)

### What I did

- Recorded Leonel's decision to use Hyper-V and moved Q011 execution ownership
  into the Project 08 family without claiming the broader P08 project complete.
- Created the frozen disconnected Generation 2 VM specification, exact local
  ISO-staging change window, exact rollback plan, screenshot instructions,
  owner decision, and sanitized imported discovery summary.
- Used a bounded no-tools Claude review. Applied its useful rollback,
  cleanup, just-in-time capacity, and explicit vNIC-disconnection findings;
  independently disproved its checksum-length concern.
- Prepared coordinated predecessor, canonical, and vault link/status updates.
  No media, VM, Hyper-V, network, credential, commit, push, merge, publication,
  or GitHub action occurred.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/`
- Windows root/project navigation, this log, and `CLAUDE-REVIEW.md`
- Local predecessor/canonical/vault Q011 handoff records

### Architecture decisions made

- `WIN-PRQD8TJG04M` is the selected host; `pve` remains rejected for RHEL 10.
- Q011 installs disconnected with one unconnected vNIC and a locally staged,
  independently verified DVD.
- The next live action is Phase 4A media staging only, not VM creation.
- Phase 2C has a written screenshot exception; every hands-on phase has a
  named actual-practice screenshot and safe-capture instructions.

### Cross-family impacts

- The Proxmox record becomes predecessor discovery/handoff evidence.
- Canonical queue and vault ownership move to this Windows repository.

### Open questions for Claude

- None. Phase 4A awaits Leonel's separate exact approval.

## Session — 2026-07-18 (Q007 successor handoff updated after Q008 closeout)

### What I did

- Replaced Q007's plain selected-Q008 handoff with a direct GitHub `main` link
  to the completed Q008 DNS incident postmortem documentation.
- Preserved Q008 as the immediate successor and left the later queue handoff to
  Q008, as required by the sequential documentation standard.
- Documentation only; no Windows, DNS, AD, DHCP, network, VM, credential, live
  system, commit, push, merge, or publication action occurred.

## Session — 2026-07-17 (Q007 screenshot documentation repair)

### What I did

- Re-read the canonical project-documentation, evidence-intake, Windows
  evidence-documentation, screenshot-wrapper, and redaction standards after
  Leonel reported that Q007 screenshots were poorly integrated.
- Removed the standalone Markdown gallery and embedded reviewed screenshots
  inside the phases they prove, using the shared HTML wrapper at `width="900"`.
- Limited the README and practicum to two images per phase, placed every proof
  sentence and paired text note beside its image, and routed Phase 2/4 overflow
  to `evidence/q007-windows-evidence-details.md`.
- Reconciled stale practicum, change-window, screenshot-plan, and evidence-log
  status text through the Phase 9 powered-off result while preserving the
  missing empty-zone screenshot limitation.
- Asked Claude for a bounded read-only review of the actual corrected README,
  practicum, and details file. Claude returned PASS with no blocking finding
  after checking counts, sizing, pairing, placement, overflow, and Phase 9.

### Files created/modified

- `projects/project-03-dns-engineering/q007-dns-failure-triage-simulation/README.md`
- `projects/project-03-dns-engineering/q007-dns-failure-triage-simulation/evidence/q007-windows-evidence-details.md`
- Q007 hands-on practicum, change-window, screenshot-plan, evidence-log, and
  both integrity manifests

### Architecture decisions made

- The project README displays only the strongest two images per phase. Extra
  GUI views remain visible in one linked evidence-details page instead of a
  detached gallery.

### Cross-family impacts

- None. This repair changes only Windows Q007 documentation presentation and
  does not alter the already-published Q006-to-Q007 handoff link.

### Open questions for Claude

- None. The final bounded read-only review passed.

## Session — 2026-07-15 (Q007 complete)

### What I did

- Passed the Q007 entry, dependency, WIP, and repository-lock gates.
- Built and executed a loopback-only DNS responder/client that injected an
  extra wrong A record, demonstrated wrong-first client selection, repaired
  the record set, passed three positive retests and an NXDOMAIN negative test,
  survived malformed input, and released its port after cleanup.
- Added a separate raw-packet verifier, Windows operator runbook, complete
  portfolio README, closeout, evidence, and exact dedicated Q007 links.
- Incorporated Claude Fable's read-only conditional-GO findings and preserved
  the honest boundary between isolated protocol proof and live Windows DNS.

### Files created/modified

- `projects/project-03-dns-engineering/q007-dns-failure-triage-simulation/`
- `projects/project-03-dns-engineering/README.md`
- `README.md`
- `projects/README.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`

### Architecture decisions made

- Q007 is a dedicated P03 follow-on folder; it does not reopen or relabel the
  completed core P03 project.
- The executed fault is one extra wrong A record. P03 supplies the real NIC
  pollution context, while the reusable runbook retains the forwarder branch.
- Raw response hex plus a separate decoder substitutes for unavailable
  `dig`/`nslookup` against the nonstandard high-port loopback target.
- Final protocol review corrected the responder from a recursion-available
  claim to authoritative-answer flags and regenerated all retained evidence.

### Cross-family impacts

- Q007 closes `SIM-N3-DNS` and selects Q008 in `homelab-management` without
  starting it. Q006's immediate-successor text becomes a direct Q007 link.

### Open questions for Claude

- None. Q007 has no open review item or live follow-up required for closure.

---

## Session — 2026-07-15 (Q007 queue handoff only)

### What I did

- Reconciled the Windows family indexes after Q006 closed in
  `homelab-management`.
- Marked Q007 / `SIM-N3-DNS` selected and not started in `README.md` and
  `projects/README.md`.
- Preserved the ISO entry checks and all separate DNS/Windows live-change
  approvals; no Q007 design or execution began.

### Files created/modified

- `README.md`
- `projects/README.md`
- `CODEX-LOG.md`

### Architecture decisions made

- Q007 remains a Project 03 follow-on simulation, while the completed Project
  03 baseline remains unchanged.

### Cross-family impacts

- Q006 recovery-order evidence in `homelab-management` is complete and the
  canonical family queue now points to this Windows-owned simulation.

### Open questions for Claude

- None. This was a documentation-only status handoff.

## Session — 2026-07-14 (P01 safety-check false-positive correction)

### What I did

- Replaced the file-wide Default Domain Policy text check with a PowerShell
  AST-based command check.
- Kept the safety gate focused on protected mutating commands that directly
  reference the protected policy name, canonical GUID, or protected variable.
- Preserved Q004's disposable-GPO proof without adding a path allowlist.

### Verification

- The checker passes the current tracked scripts, including Q004.
- A synthetic direct Default Domain Policy mutation fails with its file, line,
  and command name, while a disposable-GPO mutation passes.
- Workflow and checker changes are repository-only; no AD or GPO state changed.

### Claude review

- Claude independently marked the checker and workflow ready to publish.
- The checker intentionally detects direct protected targets. Variable or splat
  indirection and dynamically invoked command names remain static-analysis limits;
  the existing human approval gate remains the backstop for live GPO changes.

## Session — 2026-07-14 (completed-project README migration)

### What I did

- Rewrote completed Projects 01-04 with the canonical first-person,
  phase-by-phase portfolio structure.
- Preserved each original long-form README as `technical-details.md` and linked
  the new story to the existing scripts, evidence, screenshots, and runbooks.
- Added the direct Q004-to-Q005 handoff link without changing Q005 approval state.

### Verification

- Documentation only; no AD, DNS, DHCP, GPO, account, host, or replication state changed.
- Cross-repository structure, link, secret, and independent Claude review gates
  run before commit and push.

### Open questions for Claude

- None beyond the bounded final migration review.

## Session — 2026-07-12 (Canonical AD incident reference linked)
### What I did
- Linked the shared `homelab-incident-response` AD compromise investigation
  reference from the Windows skill table and Claude operating rules.
- Kept evidence-first investigation separate from credential dumping, GPO or
  account changes, domain-controller rebuilds, and `krbtgt` rotation.

### Verification
- Documentation-only cross-repo link; no AD, DNS, DHCP, GPO, account,
  credential, or Windows host changed.

### Open questions for Claude
- None.

## Session — 2026-07-03 (Codex — Project 04 DHCP/IPAM completion)
### What I did
- Connected to `WIN-PRQD8TJG04M` over SSH as `CHONGONG\adm-leonel`.
- Collected Project 04 read-only DHCP/IPAM discovery output.
- Verified Windows DHCP is installed, AD-authorized, and has an active `192.168.20.0/24` scope.
- Updated Windows DHCP option 6 for scope `192.168.20.0/24` so it advertises both AD DNS servers: `192.168.20.11` and `192.168.20.12`.
- Verified AD DNS, Route10 `localdomain`, and external DNS through both DCs.
- Documented Hyper-V switch/VM addressing and created the Windows-side IPAM handoff.

### Files created/modified
- `README.md`
- `AGENTS.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`
- `docs/execution-roadmap.md`
- `docs/topology.md`
- `projects/README.md`
- `projects/project-04-dhcp-ipam/README.md`
- `projects/project-04-dhcp-ipam/docs/p04-dhcp-ipam-evidence.md`
- `projects/project-04-dhcp-ipam/docs/p04-ipam-handoff.md`
- `projects/project-04-dhcp-ipam/docs/p04-live-discovery-raw.txt`
- `projects/project-04-dhcp-ipam/docs/p04-post-change-verification.txt`
- `projects/project-04-dhcp-ipam/docs/p04-screenshot-plan.md`
- `projects/project-04-dhcp-ipam/screenshots/.gitkeep`
- `skills/windows-server-business-admin.md`
- `skills/winserver-projects.md`

### Architecture decisions made
- Route10 remains the main homelab DHCP/IPAM authority.
- Windows DHCP was not disabled because it is active and still has a lease; disabling it needs a separate maintenance decision after Route10 VLAN 20 ownership is fully documented.
- The only live configuration change was scope option 6, which is low-risk and aligns DHCP clients with the two-DC DNS design.
- The stale `192.168.20.21` lease and DHCP bindings on WSL/VirtualBox interfaces are cleanup candidates, not Project 04 blockers.

### Cross-family impacts
- Route10 and NetOps now have a Windows-side IPAM handoff with reservation candidates and Hyper-V VM addressing.
- SOC/Wazuh planning can use the captured VM/IP inventory.
- Project 05 can proceed with GPO security baselines.

### Open questions for Claude
- None.

---

## Session — 2026-07-03 (Codex — Project 03 Route10 localdomain conditional forwarder)
### What I did
- Documented the completed Project 03 Phase 5 conditional forwarder.
- Added the two Phase 5 screenshots proving the `localdomain` forwarder exists on both DCs and resolves through both DNS servers.
- Updated Project 03 evidence, screenshot plan, topology, project indexes, operator notes, and skill guidance.
- Removed the obsolete screenshot that showed Conditional Forwarders as empty because that is no longer the final design.

### Files created/modified
- `README.md`
- `AGENTS.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`
- `docs/topology.md`
- `projects/README.md`
- `projects/project-03-dns-engineering/README.md`
- `projects/project-03-dns-engineering/docs/p03-screenshot-plan.md`
- `projects/project-03-dns-engineering/docs/p03-win-dc02-secondary-dns-evidence.md`
- `projects/project-03-dns-engineering/screenshots/phase5-01-conditional-forwarder-localdomain.png`
- `projects/project-03-dns-engineering/screenshots/phase5-02-localdomain-resolution-both-dcs.png`
- `skills/winserver-projects.md`

### Architecture decisions made
- `localdomain` is a real forwarding target because Route10 answers DHCP client hostnames under that zone.
- Windows DNS forwards only `*.localdomain` to Route10 at `192.168.20.1`.
- Recursion is disabled for the conditional forwarder so `localdomain` queries do not fall through to public DNS if Route10 cannot answer.
- This was a Windows DNS change only; Route10 routing, DHCP, NAT, VLAN, firewall, and DNS configuration were not changed.

### Cross-family impacts
- Project 04 can now validate DHCP/IPAM and DNS option behavior knowing that AD DNS can resolve Route10-registered household names.
- Route10 remains the authority for the `localdomain` records; Windows AD DNS only forwards that namespace.
- OPNsense `internal` and Pi-hole `192.168.10.26` were documented as discovered but not used as conditional-forwarder targets.

### Open questions for Claude
- None.

---

## Session — 2026-07-03 (Codex — Portfolio summaries and Project 03 Phase 5 cleanup)
### What I did
- Moved the Portfolio Summary section near the top of every project README.
- Renamed remaining `STAR Summary` headers to `Portfolio Summary` for consistency.
- Updated the evidence documentation skill so future project READMEs keep the Portfolio Summary near the top.
- Cleaned up Project 03 Phase 3 status to simply `Complete`.
- Changed Project 03 Phase 5 from deferred wording to complete-as-designed based on what was known at that point. Superseded later the same day by the Route10 `localdomain` discovery and configuration.
- Documented what information was required before adding a conditional forwarder; that requirement was later satisfied by Route10 `localdomain`.

### Files created/modified
- `README.md`
- `AGENTS.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`
- `projects/README.md`
- `projects/project-01-server-baseline-hardening/README.md`
- `projects/project-02-ad-architecture/README.md`
- `projects/project-03-dns-engineering/README.md`
- `projects/project-03-dns-engineering/docs/p03-screenshot-plan.md`
- `projects/project-03-dns-engineering/docs/p03-win-dc02-secondary-dns-evidence.md`
- `projects/project-04-dhcp-ipam/README.md`
- `projects/project-05-gpo-security-baselines/README.md`
- `projects/project-06-file-server-access-governance/README.md`
- `projects/project-07-windows-client-lifecycle/README.md`
- `projects/project-08-hyperv-operations/README.md`
- `projects/project-09-powershell-admin-platform/README.md`
- `projects/project-10-security-monitoring-ir/README.md`
- `projects/project-11-backup-disaster-recovery/README.md`
- `projects/project-12-m365-entra-hybrid-identity/README.md`
- `projects/project-13-enterprise-identity-integration/README.md`
- `skills/winserver-evidence-documentation/SKILL.md`
- `skills/winserver-projects.md`

### Architecture decisions made
- Conditional forwarders should only be configured when there is a real zone name, authoritative DNS server, reachability on TCP/UDP 53, and a test record.
- Superseded later the same day: Route10 `localdomain` became the real conditional-forwarder target.

### Cross-family impacts
- Future OPNsense, Proxmox, or NetOps DNS work must still provide the target zone and DNS server before Windows AD DNS adds more conditional forwarders.

### Open questions for Claude
- None.

---

## Session — 2026-07-03 (Codex — WIN-DC02 replica DC and secondary DNS evidence)
### What I did
- Documented the `WIN-DC02` build and promotion as the Project 02 replica domain controller.
- Documented the Project 03 secondary DNS verification on `WIN-DC02`.
- Added reviewed screenshot evidence under the matching Project 02 Phase 7 and Project 03 Phase 9 sections.
- Captured the live troubleshooting path: system backup, DHCP exclusion, multihomed PDC DNS cleanup, DNS listen-address correction, DC promotion, replication checks, and final DNS verification.
- Updated root, project, topology, roadmap, operator, and skill status files so they no longer show `WIN-DC02` as pending.

### Files created/modified
- `README.md`
- `AGENTS.md`
- `CODEX-LOG.md`
- `docs/topology.md`
- `docs/execution-roadmap.md`
- `projects/README.md`
- `projects/project-02-ad-architecture/README.md`
- `projects/project-02-ad-architecture/docs/p02-screenshot-plan.md`
- `projects/project-02-ad-architecture/docs/p02-win-dc02-build-evidence.md`
- `projects/project-02-ad-architecture/screenshots/phase7-00-win-dc02-prejoin-network-check.png`
- `projects/project-02-ad-architecture/screenshots/phase7-01-win-dc02-hyperv-vm.png`
- `projects/project-02-ad-architecture/screenshots/phase7-02-win-dc02-domain-controllers-ou.JPG`
- `projects/project-02-ad-architecture/screenshots/phase7-03-replication-healthy.JPG`
- `projects/project-02-ad-architecture/screenshots/phase7-04-sysvol-netlogon-shares.JPG`
- `projects/project-02-ad-architecture/screenshots/phase7-05-fsmo-roles-remain-on-pdc.JPG`
- `projects/project-03-dns-engineering/README.md`
- `projects/project-03-dns-engineering/docs/p03-screenshot-plan.md`
- `projects/project-03-dns-engineering/docs/p03-win-dc02-secondary-dns-evidence.md`
- `projects/project-03-dns-engineering/screenshots/phase9-00-pdc-hostname-clean-after-fix.png`
- `projects/project-03-dns-engineering/screenshots/phase9-00-pdc-multihomed-dns-before-cleanup.png`
- `projects/project-03-dns-engineering/screenshots/phase9-01-win-dc02-dns-zones.JPG`
- `projects/project-03-dns-engineering/screenshots/phase9-02-win-dc02-dns-resolution.png`
- `projects/project-03-dns-engineering/screenshots/phase9-03-win-dc02-forwarders.JPG`
- `projects/project-03-dns-engineering/screenshots/phase9-04-win-dc02-ptr-record.png`
- `projects/project-03-dns-engineering/screenshots/phase9-05-pdc-dns-client-now-uses-dc02.png`
- `skills/windows-server-business-admin.md`
- `skills/winserver-projects.md`

### Architecture decisions made
- `WIN-PRQD8TJG04M` remains the FSMO holder and PDC operations anchor.
- `WIN-DC02` is the replica DC, DNS server, and Global Catalog at `192.168.20.12`.
- The PDC DNS service listens only on `192.168.20.11` to avoid publishing non-AD interface addresses.
- The PDC DNS client uses `192.168.20.12, 192.168.20.11`; `WIN-DC02` uses `192.168.20.11, 192.168.20.12`.
- Superseded later on `2026-07-03`: Project 03 Phase 5 is complete with Route10 `localdomain` forwarding to `192.168.20.1`.

### Cross-family impacts
- Project 04 can now validate DHCP/IPAM and DNS option design against two working AD DNS servers.
- NetOps, SOC, Proxmox, OPNsense, and future NPS/RADIUS work can reference a two-DC identity and DNS base.
- The stale temporary `192.168.20.21` PTR seen in DNS Manager can be cleaned later if scavenging does not remove it.

### Open questions for Claude
- None.

---

## Session — 2026-06-24 (Codex — Route10 repo handoff and Project 04 scope correction)
### What I did
- Created and pushed the new private Route10 project family repo: `homelab-route10-network-core`.
- Rewrote Windows Project 04 so it no longer assumes Windows Server should own homelab DHCP.
- Changed Project 04 into DHCP/IPAM integration and Windows client validation against the real Route10/OPNsense network design.
- Preserved Windows DHCP as a possible future design-only option for isolated Hyper-V lab scopes.
- Updated the Windows README, project index, roadmap, and skills so they point to Route10 as the full IP addressing authority source.

### Files created/modified
- `README.md`
- `projects/README.md`
- `projects/project-04-dhcp-ipam/README.md`
- `docs/execution-roadmap.md`
- `skills/windows-server-business-admin.md`
- `skills/winserver-projects.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Route10 owns the big homelab IP addressing and DHCP authority topic.
- Windows Project 04 validates that AD DNS, domain clients, and Hyper-V VMs work with the Route10/OPNsense design.
- CML DHCP migration to Route10 is possible but remains a future Route10 project, not a current change.

### Cross-family impacts
- Route10 is now a first-class project family for network core, IPAM, VLAN, routing, VPN, firewall, QoS, and future CML integration work.
- Windows, OPNsense, PA-220, CML, NetOps, SOC, FreePBX, and future case studies can reference Route10 as the network-core authority model.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — Server World style phase evidence rule)
### What I did
- Reviewed the Server World Windows Server 2022 Active Directory example page Leonel referenced.
- Updated the Windows Server evidence documentation skill so each phase follows a command-and-image flow: first-person explanation, achieved result, why it matters, PowerShell/admin command block, manual GUI path, then screenshot evidence directly under that phase.
- Added the requirement that PowerShell sections show current state, change when applicable, and verification instead of becoming a raw transcript.
- Added the requirement that every screenshot in a project phase explains when to capture it, how to capture it, what it proves, why it matters, and the matching PowerShell equivalent.

### Files created/modified
- `skills/winserver-evidence-documentation/SKILL.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Future Windows Server project pages should use the same clear command-plus-screenshot rhythm as Server World, but with stronger portfolio explanations for each screenshot.
- Screenshots still do not belong in the root README.

### Cross-family impacts
- Future Windows project documentation should be easier for non-technical readers to follow while still giving technical reviewers exact evidence.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — documentation skill screenshot placement rule)
### What I did
- Updated the Windows Server evidence documentation skill to match Leonel's documentation rule.
- Made the root README rule explicit: no screenshots on the family/index README.
- Made the individual project README rule explicit: screenshots belong under the phase they prove, with a first-person phase explanation, capture timing, GUI path, reason, and PowerShell equivalent.
- Added the requirement to plan before/after/verification screenshots before configuration starts.
- Lightly improved the root README introduction in first person without adding screenshots.

### Files created/modified
- `skills/winserver-evidence-documentation/SKILL.md`
- `README.md`
- `CODEX-LOG.md`

### Architecture decisions made
- The root README stays as the clean navigation and portfolio entry page.
- Phase-level screenshots live inside each project page after a reader clicks into that project.
- Missing screenshots should be listed as pending capture notes, not broken image links.

### Cross-family impacts
- Future Windows Server projects should document evidence consistently before those screenshots are linked from the main homelab portfolio.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — Project 03 consistency and screenshot plans)
### What I did
- Rewrote Project 03 README into the same phase-section style used for Projects 01 and 02.
- Fixed Project 03 break/fix links so they point to `troubleshooting/break-fix-log.md`.
- Added a Project 03 screenshot plan with two screenshots for completed phases and one for deferred/pending phases.
- Updated the Project 02 screenshot plan to explicitly list screenshot counts and add missing second screenshots where useful.
- Added `screenshots/.gitkeep` folders for Projects 02 and 03.
- Updated `projects/README.md`, `AGENTS.md`, `docs/execution-roadmap.md`, `CLAUDE-REVIEW.md`, and `skills/winserver-projects.md` so Project 03 status is consistent.

### Files created/modified
- `projects/project-03-dns-engineering/README.md`
- `projects/project-03-dns-engineering/docs/p03-screenshot-plan.md`
- `projects/project-03-dns-engineering/screenshots/.gitkeep`
- `projects/project-02-ad-architecture/docs/p02-screenshot-plan.md`
- `projects/project-02-ad-architecture/screenshots/.gitkeep`
- `projects/README.md`
- `AGENTS.md`
- `docs/execution-roadmap.md`
- `CLAUDE-REVIEW.md`
- `skills/winserver-projects.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Superseded again later on `2026-07-03`: Project 03 is complete; Phase 5 is complete with Route10 `localdomain` forwarding, and Phase 9 was completed after `WIN-DC02` promotion.
- Completed phases should have two screenshot targets when useful; deferred or pending phases should have one screenshot proving why they are deferred or blocked.

### Cross-family impacts
- P03 DNS is now documented as the current name-resolution base for Project 04 DHCP/IPAM, OPNsense, NetOps monitoring, and later SOC/M365 work.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — screenshot upload skill clarification)
### What I did
- Updated the Windows Server evidence documentation skill with an explicit screenshot upload workflow.
- Added where screenshots must be saved, how they must be named, how to check them for secrets, and how to link them in Markdown.
- Added the rule to create a project-specific `docs/pNN-screenshot-plan.md` when a project needs many screenshots.

### Files created/modified
- `skills/winserver-evidence-documentation/SKILL.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Screenshots for project documentation should be committed into each project repo under `screenshots/`, not hosted externally.
- Every screenshot used in a README or evidence doc needs a filename, purpose, manual capture path, and PowerShell equivalent.

### Cross-family impacts
- None. Documentation-standard update only.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — phase command and image placeholders)
### What I did
- Added PowerShell/proof command blocks inside each Project 02 phase section.
- Added image filenames/placeholders inside each Project 02 phase section for later screenshot insertion.
- Added the same command/proof and image-placeholder structure to Project 01 phase sections.

### Files created/modified
- `projects/project-01-server-baseline-hardening/README.md`
- `projects/project-02-ad-architecture/README.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Each phase section should include what was done, how it can be proven with commands, and where the image for that phase will be inserted later.

### Cross-family impacts
- None. Documentation-only update.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — phase-section README correction)
### What I did
- Corrected Project 02 so the table is only a simple phase/status summary.
- Added normal `Phase 1` through `Phase 9` sections under Project 02 explaining what was done, why it matters, and what screenshot to capture.
- Corrected Project 01 the same way by adding `Phase 1` through `Phase 7` sections explaining the completed work.

### Files created/modified
- `projects/project-01-server-baseline-hardening/README.md`
- `projects/project-02-ad-architecture/README.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Project README files should not rely only on summary tables. Each project should also have readable phase sections that explain what was actually done.

### Cross-family impacts
- None. Documentation-only update.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — Project 02 phase and screenshot documentation)
### What I did
- Updated the Project 02 README so every phase is explicitly labeled `Phase 1` through `Phase 9`.
- Added a direct Phase 7 requirements list for the pending `WIN-DC02` replica DC work.
- Added a Project 02 screenshot/evidence plan with filenames, manual GUI paths, why each screenshot matters, and PowerShell equivalents.

### Files created/modified
- `projects/project-02-ad-architecture/README.md`
- `projects/project-02-ad-architecture/docs/p02-screenshot-plan.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Keep the public README concise and link the detailed screenshot checklist as a technical evidence doc.
- Treat Phase 7 as pending until `WIN-DC02` exists, has the correct network/DNS setup, and is explicitly approved for promotion.

### Cross-family impacts
- None. Documentation-only update.

### Open questions for Claude
- None.

---

## Session — 2026-06-23 (Codex — Project 02 AD architecture live completion)
### What I did
- Applied the approved Project 02 AD architecture changes on `WIN-PRQD8TJG04M`.
- Created the managed OU layout: `ManagedUsers`, `ManagedComputers`, `Groups/GlobalGroups`, and `Groups/DomainLocalGroups`.
- Moved the five real department OUs (`Finance`, `HR`, `IT`, `Management`, `Sales`) under `ManagedUsers`.
- Moved domain-joined workstations under `ManagedComputers/Workstations` and member servers (`GITEA`, `RADIUS01`) under `ManagedComputers/Servers`.
- Created P02 `GG-*` global groups and `DL-*` domain local groups, then nested department groups into the matching DL groups.
- Created disabled staged accounts `ws-leonel`, `svc-backup`, and `svc-sync`.
- Enabled AD Recycle Bin and delegated `GG-Helpdesk` reset-password, force-password-change, and unlock rights on `ManagedUsers`.
- Confirmed `__vmware__` is still an empty Domain Local group with description `VMware User Group`; left it untouched.
- Confirmed no `WIN-DC02` VM/computer object exists yet, so replica DC remains the only P02 infrastructure dependency.
- Added idempotent apply and read-only verification scripts for future runs.

### Files created/modified
- `projects/project-02-ad-architecture/scripts/p02-apply-ad-architecture.ps1`
- `projects/project-02-ad-architecture/scripts/p02-verify-ad-architecture.ps1`
- `projects/project-02-ad-architecture/README.md`
- `docs/identity-design.md`
- `docs/topology.md`
- `docs/naming-standards.md`
- `docs/execution-roadmap.md`
- `README.md`
- `projects/README.md`
- `AGENTS.md`
- `skills/windows-server-business-admin.md`
- `skills/winserver-projects.md`
- `projects/project-03-dns-engineering/README.md`
- `projects/project-05-gpo-security-baselines/README.md`
- `projects/project-06-file-server-access-governance/README.md`
- `projects/project-07-windows-client-lifecycle/README.md`
- `projects/project-09-powershell-admin-platform/README.md`
- `projects/project-12-m365-entra-hybrid-identity/README.md`
- `projects/project-01-server-baseline-hardening/README.md`
- `projects/project-01-server-baseline-hardening/docs/p01-verified-final-state.md`
- `skills/project-01-server-baseline-hardening.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Use `ManagedUsers` and `ManagedComputers` because built-in root containers `CN=Users` and `CN=Computers` already exist.
- Keep the real five departments from the live domain: Finance, HR, IT, Management, and Sales. Do not create the old planned `Operations` department.
- Keep all FSMO roles on `WIN-PRQD8TJG04M`.
- Do not delete or rename legacy groups such as `__vmware__`; document and leave untouched unless a later approved cleanup project owns them.
- Treat `WIN-DC02` as a separate VM build/promotion step because the VM is not present.

### Verification
- `p02-apply-ad-architecture.ps1 -Mode Plan` now recognizes all objects as already in place.
- `p02-verify-ad-architecture.ps1` ran successfully from `C:\Windows\Temp` on `WIN-PRQD8TJG04M`.
- PowerShell parser check passed for both P02 scripts.
- Verification confirmed Recycle Bin enabled and all five FSMO roles still on `WIN-PRQD8TJG04M`.

### Cross-family impacts
- NetOps/NPS groups now exist: `GG-NetAdmins` and `GG-Net-ReadOnly`.
- SOC group now exists: `GG-SOC-Analysts`.
- Project 06 file-share groups now match the real department list.
- Project 12 Entra sync planning now scopes to `ManagedUsers`, excluding `_Admin` and service accounts.

### Open questions for Claude
- Review and push the Project 02 commit if Leonel wants Claude to own the GitHub publish step.
- Build/promotion of `WIN-DC02` remains the next P02 infrastructure item after Windows Server install media and VM details are ready.

---

## Session — 2026-06-23 (Codex — Project 01 documentation cleanup)
### What I did
- Pulled latest `main` and reviewed the new Project 01 evidence/documentation set.
- Rewrote `projects/project-01-server-baseline-hardening/README.md` as a direct portfolio page instead of a long command transcript.
- Separated README screenshots into evidence blocks with description, manual GUI path, PowerShell equivalent, and reason.
- Reworked `skills/winserver-evidence-documentation/SKILL.md` into the required documentation standard for future project README/evidence updates.
- Updated status references so Project 01 is consistently marked complete.

### Files created/modified
- `projects/project-01-server-baseline-hardening/README.md`
- `skills/winserver-evidence-documentation/SKILL.md`
- `README.md`
- `projects/README.md`
- `skills/README.md`
- `skills/project-01-server-baseline-hardening.md`
- `AGENTS.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Project READMEs should be direct portfolio summaries, not full execution transcripts.
- Detailed commands, outputs, screenshots, and rollback notes belong in linked evidence docs under each project.
- Any screenshot shown in a README must sit beside what it proves, how it was checked manually, the PowerShell equivalent, and why it matters.
- The documentation standard is now required for every Windows Server project documentation update.

### Cross-family impacts
- Improves portfolio readability for the Windows identity backbone before it is linked from homelab-management and future case studies.

### Open questions for Claude
- Review the rewritten Project 01 README for tone and screenshots, then push if Leonel approves Codex's local commit or asks Claude to publish it.

---

## Session — 2026-06-22 (Claude — P01 Phase 4, manual GUI mode + SSH access change)
### What I did
- Resumed P01 at Phase 4 (RDS/IIS/NPS risk assessment) in manual-GUI mode per Leonel's
  request — gave GUI click-paths for Server Manager, ADUC, IIS Manager, NPS console;
  Leonel executed each step and reported back via screenshots.
- Walked through all 5 Phase 4 consoles: RDS Overview/Servers, RDS-Users membership,
  IIS Sites/Application Pools, NPS Policies/RADIUS Clients, and `__vmware__` group.
- Discovered mid-session that a new SSH key (`winserver_claude_ed25519`, alias
  `winserver01`, connects as `chongong\adm-leonel`) now exists and works — this
  contradicts the prior handoff doc's "no SSH key exists" statement. Asked Leonel how
  to use it; he chose to let Claude execute both read and write commands directly going
  forward, with approval still required before any live AD/GPO change. Used it
  read-only to confirm `__vmware__` group metadata and host VMware services.
- Wrote `docs/p01-rds-iis-risk-assessment.md` covering all Phase 4 findings.

### Files created/modified
- `projects/project-01-server-baseline-hardening/docs/p01-rds-iis-risk-assessment.md` (new)
- `AGENTS.md` — Tier 3 rule updated to reflect working SSH access
- `skills/project-01-server-baseline-hardening.md` — SSH quick-reference fixed (stale
  key path removed), Phases 2–4 marked complete in checklist, `__vmware__` do-not-touch
  entry filled in with confirmed findings
- `CODEX-LOG.md` (this entry)

### Architecture decisions made
- RDS Connection Broker is failing on the PDC (server reachable, broker unreachable) —
  documented as a finding, not fixed; remediation deferred to Project 08 (dedicated
  RDS server) rather than patched in place on the PDC.
- IIS on the PDC confirmed to exist solely for RD Web Access/RPC-over-HTTPS — no
  general-purpose hosting, no named-account app pool identities.
- NPS confirmed to have zero custom configuration (stock defaults only, no RADIUS
  clients) — `radius-service` is not referenced anywhere, resolved via GUI inspection
  alone, no XML export needed.
- `__vmware__` confirmed as an empty, unmanaged artifact of a VMware desktop product
  (NAT/Autostart services present) — left untouched, deferred to Project 02.

### Cross-family impacts
- None this session — Phase 4 made zero live changes by design.

### Open questions for Claude/Codex
- Confirm with Leonel whether the two clones (`C:\Projects\...` and
  `E:\Homelab-Repos\family-projects\...`) should be reconciled now that Claude can SSH
  directly — may reduce need for keeping both in sync manually.
- Phase 5 (firewall baseline) needs the exact Tailscale management IP via `tailscale
  ip -4` before restricting the RDP inbound rule — not yet captured.

## Session — 2026-06-22 (Imported AD/SSSD project into Project 13)
### What I did
- Imported the full AD UNIX Attributes + SSSD Linux VM Integration plan from the former `homelab-projects` repo.
- Placed it under Project 13 references because Linux SSSD domain join belongs to the enterprise identity capstone.
- Updated the Project 13 README and project index so the imported reference is discoverable.

### Files created/modified
- `projects/project-13-enterprise-identity-integration/references/ad-sssd-linux-integration-full-spec.md`
- `projects/project-13-enterprise-identity-integration/README.md`
- `projects/README.md`
- `CODEX-LOG.md`

### Architecture decisions made
- `homelab-projects` should not remain a separate repo for this item. The work is part of the Windows Server identity family and should be maintained with AD/NPS/RADIUS planning.

### Cross-family impacts
- Project 13 now explicitly covers Linux VM authentication through SSSD in addition to network-device RADIUS, OPNsense admin auth, Wazuh telemetry, and Microsoft 365 identity.

### Open questions for Claude
- None.

---

## Log Format

```text
## Session — YYYY-MM-DD
### What I did
- bullet list
### Files created/modified
- list
### Architecture decisions made
- reasoning behind key choices
### Cross-family impacts
- anything that affects CML/CCNA/Proxmox/OPNsense/SOC integrations
### Open questions for Claude
- list
```

---

## Session — 2026-06-06 (Claude — S02 winserver-evidence-documentation patch)
### What I did
- Applied S02 corrections to `skills/winserver-evidence-documentation/SKILL.md`.
- Fixed Key Evidence table: `p05-ph9-*` corrected to `p05-ph3-*`; screenshot links converted to inline image syntax `![label](verification/screenshots/file.png)`.
- Added Certificate Manager, IIS Manager, and Local Users and Groups sections to the GUI Screenshot Guide (relevant to P01 baseline hardening, P08 WAC/IIS, and certificate evidence).
- Confirmed No-Secrets Policy section was already present — no change needed.
- Confirmed GUI Track A + PowerShell Track B structure preserved.
- Marked S02 🟢 RESOLVED in `CLAUDE-REVIEW.md`.

### Files created/modified
- `skills/winserver-evidence-documentation/SKILL.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`

### Architecture decisions made
- Key Evidence table screenshot cells use `![label](verification/screenshots/file.png)` so GitHub renders inline previews in the completed project README. Text file cells remain plain markdown links.
- Phase number `p05-ph9` was a placeholder that does not map to any real P05 phase — replaced with `p05-ph3` (Password Policy GPO result phase). Future entries should use the real phase number or the generic `<phase>` token.
- Certificate Manager / IIS / Local Users and Groups added with scope guards so they are only used when those tools are in the project's evidence scope.

### Open questions for Claude
- None. Do not push until Leonel reviews.

## Session — 2026-06-06 (Codex — D01 Project 02-12 README review)
### What I did
- Reviewed all 11 Project 02-12 README files against D01, `docs/identity-design.md`, and `docs/naming-standards.md`.
- Patched unsafe or inaccurate runbook items directly in the project README files.
- Confirmed the D01-specific checks and corrected the items that needed guardrails:
  - P02 replica DC promotion now has a safe `Install-ADDSDomainController` command; removed fake Server 2022 functional-level upgrade and live FSMO seizure practice.
  - P03 reverse zone creation keeps valid `Add-DnsServerPrimaryZone -NetworkID` syntax and clarifies AD DNS-only NIC settings.
  - P04 DHCP failover now installs/authorizes DHCP on WIN-DC02 before `Add-DhcpServerv4Failover`.
  - P05 Advanced Audit Policy GPMC path remains correct; account policy GPO behavior now warns that OU staging does not test domain password/lockout policy.
  - P06 confirms `SetAccessRuleProtection($true, $false)` disables inheritance without copying and adds explicit Administrators/SYSTEM ACLs.
  - P08 RDS removal now drains sessions, requires backup/maintenance approval, and uses a parse-safe `Remove-WindowsFeature` command.
  - P09 WAC install updated for current `WindowsAdminCenter.exe` silent install syntax, with legacy MSI syntax kept as a comment.
  - P10 WEF now states `wecutil cs` expects an XML file path and splits Security/System event IDs correctly.
  - P11 tombstone guidance no longer assumes 60 days; it now requires querying the live tombstoneLifetime value.
  - P12 Entra Connect now uses Custom install / Domain and OU filtering / staging mode before export.
- Updated `CLAUDE-REVIEW.md` D01 to 🟢 RESOLVED.

### Files created/modified
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
- `docs/identity-design.md` — corrected AD DS functional-level labels and added Tier2-WorkstationAdmins to the OU reference.
- `CLAUDE-REVIEW.md` — D01 marked resolved.
- `CODEX-LOG.md` — this session entry.

### Architecture decisions made
- Keep FSMO roles on WIN-PRQD8TJG04M during normal P02 work; FSMO seizure belongs only in DR testing with backups and approval.
- Treat password/lockout policy as a domain-root account policy; do not imply OU-linked staging validates domain account policy.
- Prefer disposable test objects for restore/offboarding/lockout drills instead of using Leonel's real user, P01 `testuser`, production GPOs, or working VMs.
- Require P11 backup/DR completion before P12 hybrid identity because Entra sync can create broad cloud-side impact.

### Cross-family impacts
- P10 WEF/Wazuh wording now separates Security and System event sources, improving Blue Team/SOC integration accuracy.
- P12 OU filtering/staging reduces the chance of accidentally syncing admin/service identities into Entra before Project 13 cross-family auth.
- P04 DHCP failover sequencing protects downstream CML/CCNA, Proxmox, OPNsense, and SOC systems that depend on stable DHCP/DNS.

### Open questions for Claude
- None. D01 is resolved locally; Claude can review and push when ready.

---

## Session — 2026-06-05 (Codex — applied P01 review patches)
### What I did
- Patched the remaining Codex review items R06 through R09 after Claude ran out of tokens.
- Updated Phase 3 so `adm-leonel` is created with a 20+ character password before receiving the Tier 0 PSO.
- Tightened the ADAC navigation path to `Chongong (local) → System → Password Settings Container`.
- Fixed Phase 5 UDP listener commands to use `OwningProcess` instead of `OwningProcessId`.
- Replaced the executable RDP `100.64.0.0/10` placeholder with a hard-fail guard requiring one specific management Tailscale IP.
- Updated Phase 6 to validate Event 4625 / Logon Type 3 before running the full lockout loop.
- Marked R06-R09 resolved in `CLAUDE-REVIEW.md`.

### Files created/modified
- `skills/p01-references/phase-3-tiered-admin.md` — Tier0 password and ADAC path corrections.
- `skills/p01-references/phase-5-firewall-baseline.md` — UDP process property fix and RDP hard-fail guard.
- `skills/p01-references/phase-6-lockout-breakfix.md` — one-attempt validation before full lockout loop.
- `CLAUDE-REVIEW.md` — R06-R09 marked resolved.
- `CODEX-LOG.md` — this session entry.

### Architecture decisions made
- P01 remains GUI-first for screenshots, with PowerShell used for verification and repeatable exports.
- RDP restriction must never be runnable with a broad Tailscale placeholder. The operator must provide a specific management node IP before the rule changes.
- Lockout testing should prove the event pattern before intentionally locking the account. This avoids confusing results if loopback SMB does not behave like a normal network client in a given environment.
- Tier 0 accounts should satisfy the stricter fine-grained password policy from creation time, not after the PSO is attached.

### Cross-family impacts
- Safer RDP scoping protects the Windows identity backbone used later by CML, physical Cisco, OPNsense, Proxmox, SOC, and M365 labs.
- Correct UDP listener capture supports the later NPS/RADIUS capstone because UDP 1812/1813 visibility matters.
- The lockout exercise becomes a reusable incident-response pattern for the SOC/Wazuh project family.

### Open questions for Claude
- None from Codex. P01 review items are resolved in the repo.
- If Claude has local slash-command copies, sync them from the GitHub `skills/p01-references/` files before running Phase 2.

---

## Session — 2026-06-05 (Codex — P01 final review)
### What I did
- Reviewed the restructured P01 skill and all phase reference files.
- Answered CLAUDE-REVIEW items R01 through R05.
- Confirmed the GPMC Account Policies navigation path is correct for editing the Default Domain Policy in GPMC on Windows Server 2022.
- Confirmed the PSO creation order is valid: `adm-leonel` can exist before `GG-Tier0-Admins`; the group must exist before assigning it as the PSO subject.
- Confirmed Phase 5 should hard-fail if the RDP Tailscale placeholder is not replaced with a specific management IP.
- Confirmed the Phase 6 SMB `net use` test should generate network logon behavior, but should validate Event 4625 Logon Type 3 before running the full lockout loop.
- Found additional corrections in the phase references and added new OPEN items R06 through R09 to CLAUDE-REVIEW.md.

### Files created/modified
- `CLAUDE-REVIEW.md` — updated R01-R05 with Codex resolutions and added R06-R09 as new OPEN corrections.
- `CODEX-LOG.md` — this session entry.

### Architecture decisions made
- GUI-first workflow is appropriate for this project. PowerShell remains the verification and export path.
- Phase 2 can proceed only after the remaining command-level cleanup items are patched.
- `adm-leonel` should be created with a 20+ character password immediately because the Tier 0 PSO requires 20 characters and password policy changes do not retroactively validate an existing password until next change.
- RDP restriction should not accept the broad `100.64.0.0/10` placeholder in executable PowerShell. Use a specific Tailscale management node IP or explicitly approved list.
- Loopback SMB lockout testing is acceptable as fallback, but the lab should prove the event shape first with a single bad attempt and Event 4625 Logon Type 3 verification.

### Cross-family impacts
- The RDP/Tailscale guard protects future Claude/Codex remote access while avoiding an overly broad RDP exposure.
- The PSO/Tier0 password correction protects the identity backbone that later CML, physical Cisco, OPNsense, Proxmox, and Microsoft 365 projects will consume.
- The UDP listener correction matters for Project 13 because NPS/RADIUS depends on UDP 1812/1813 visibility.

### Open questions for Claude
- Superseded by the Codex patch session above. R06-R09 are now resolved.

---

## Session — 2026-06-05 (Claude — restructure + corrections)
### What I did
- Applied all 9 Codex corrections from review
- Split flat 37KB skill file into lean SKILL.md (~5KB) + 6 phase reference files
- Added GUI/screenshot track (Track A) to every phase alongside PowerShell (Track B)
- Phase structure: Goal → GUI Steps (Track A) → Screenshots to Capture → PowerShell Verification (Track B) → Rollback → Documentation Checklist
- Fixed Restore-GPO rollback syntax: `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath`
- Fixed RDP firewall restriction: use `Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter` (not `Set-NetFirewallRule -RemoteAddress`)
- Fixed OU naming: `_Admin` (sorts to top) with Tier0-DomainAdmins/Tier1-ServerAdmins/Tier2-WorkstationAdmins/ServiceAccounts
- Fixed srv-leonel groups: GG-ServerAdmins ONLY — removed Server Operators reference entirely
- Added UDP listener check (Get-NetUDPEndpoint) for ports 53, 88, 389, 464, 1812, 1813
- Added NPS export security warning: XML contains RADIUS shared secrets — DO NOT commit to GitHub
- Added __vmware__ investigation commands — keep as-is until VMware product identified
- Updated README.md: WIN-PRQD8TJG04M IS the live PDC (removed false WIN-DC01 as future VM)
- Updated docs/topology.md: reflects actual discovered state
- All CLAUDE-REVIEW.md items marked 🟢 RESOLVED

### Files created/modified
- `skills/project-01-server-baseline-hardening.md` — lean SKILL.md (replaces 37KB flat file)
- `skills/p01-references/phase-2-password-policy.md` — NEW reference file
- `skills/p01-references/phase-3-tiered-admin.md` — NEW reference file
- `skills/p01-references/phase-4-rds-iis-risk.md` — NEW reference file
- `skills/p01-references/phase-5-firewall-baseline.md` — NEW reference file
- `skills/p01-references/phase-6-lockout-breakfix.md` — NEW reference file
- `skills/p01-references/phase-7-document-push.md` — NEW reference file
- `README.md` — environment table corrected, P01 status = 🔄 In Progress
- `docs/topology.md` — rewritten to reflect actual server state
- `CLAUDE-REVIEW.md` — all items resolved
- Local: `.agents/skills/winserver-p01/` — 7 files (SKILL.md + 6 references)
- Local: `.codex/skills/winserver-p01/` — synced

### Architecture decisions made
- Lean SKILL.md is the session entrypoint — Claude reads SKILL.md first, then the relevant phase reference file
- Track A (GUI) is the primary path for all phases — Leonel does the clicking and takes screenshots
- Track B (PowerShell) is verification/automation alternative — not the only path
- NPS XML export: read-only at C:\Audit\ only — never committed to GitHub
- srv-leonel: GG-ServerAdmins only — built-in Server Operators on a DC = DC-level power = Tier 0 equivalent
- __vmware__: defer investigation to Project 02 (AD Architecture review)

### Cross-family impacts
- Same as previous session — no new cross-family changes in this restructure

### Open questions for Claude
- Phase 2 is the next live work. All corrections applied. Skill is ready.
- When Leonel runs Phase 2: GUI steps in phase-2-password-policy.md Track A

---

## Session — 2026-06-05 (Claude — initial audit + skill)
### What I did
- SSH'd to WIN-PRQD8TJG04M via Tailscale (100.81.197.116) using claude_winserver_2022_ed25519 key
- Ran full live audit: roles, AD users, OUs, groups, GPOs, password policy, firewall, DHCP, DNS
- Discovered server is already a promoted PDC for Chongong.local (DomainRole=5) — NOT a clean install
- Found 5 critical/high security gaps (see CLAUDE-REVIEW.md)
- Designed Project 01 as 7-phase audit/harden/formalize project (not a fresh installation)
- Wrote complete P01 skill covering all 7 phases with exact PowerShell commands
- Applied 15 self-review corrections to the skill before deploying
- Deployed skill to 4 locations: .agents/skills/, .codex/skills/, .claude/commands/, GitHub

### Files created/modified
- `skills/project-01-server-baseline-hardening.md` — initial 37KB flat skill
- `projects/project-01-server-baseline-hardening/README.md` — updated with actual phases

### Architecture decisions made
- Project 01 is "Audit, Harden, Formalize" NOT "Install AD"
- Password policy hardened via Default Domain Policy first (covers ALL users)
- PSO-Tier0-Admins (Precedence 10) layered on top for adm-leonel only
- RDS/IIS on DC: document risk only, migrate in Project 08
- DefaultInboundAction: document gap only, fix in Project 05
- testuser: lockout exercise then disable+quarantine — never delete
- GPO rollback order: set LockoutThreshold=0 FIRST before reverting observation window

### Cross-family impacts
- NPS is already installed + radius-service account exists — investigate before Project 13
- UDP 1812/1813 must be verified open in Phase 5 (needed for Project 13 RADIUS)
- RADIUS01 computer account already joined to domain — review in Project 13 context
- __vmware__ group (Domain Local) exists — review before removing

---

## Session — 2026-06-05 (initialization)
### What I did
- Repo initialized by Claude. Family framework created.
### Files created
- README.md, AGENTS.md, CLAUDE-REVIEW.md, CODEX-LOG.md, WORKFLOW.md
- skills/windows-server-business-admin.md, skills/README.md
- docs/topology.md, docs/identity-design.md, docs/naming-standards.md, docs/security-model.md
- projects/README.md + all 13 project folder READMEs
### Status
- Framework complete. Awaiting Project 01 start.

---

## Session - 2026-06-08 (Codex - workflow review + P01 handoff)
### What I reviewed
- Read homelab standing orders and automation context from `C:\Projects\homelab-management`.
- Reviewed `daily-health-check.yml` in `homelab-management` and `p01-safety-check.yml` in this repo.
- Checked pending commits in both repos, the self-hosted runner scheduled task, runner directory contents, Windows Server P01 skills, and current AD password/lockout state.

### Current state
- Self-hosted runner task `GitHubActionsRunner` is Running and `C:\actions-runner` contains the expected runner files (`config.cmd`, `run.cmd`, `bin`, `externals`, `_work`, `_diag`).
- Pending `homelab-management` commit: `7612871 wip: workflow ready to push once token has workflow scope`.
- Pending `windows-server-business-admin-labs` commit: `d65dd25 feat: add P01 safety check GitHub Actions workflow`.
- AD password policy is still weak: `MinPasswordLength=7`, `LockoutThreshold=0`, `LockoutDuration=00:10:00`.
- `_Admin` OU does not exist yet.
- P01 Phase 2 remains the critical next live security fix.

### Workflow corrections made locally
- `homelab-management/.github/workflows/daily-health-check.yml`: removed hardcoded SSH passwords and switched Linux checks to SSH aliases/key-based BatchMode checks; added permissions, concurrency, AD policy warnings, and failure handling.
- `.github/workflows/p01-safety-check.yml`: added `pull_request` and manual triggers, permissions, concurrency, tracked-file based scanning, PowerShell parser-based syntax checks, NPS XML protection, and a fixed Default Domain Policy guard.
- Ran P01 safety logic locally: secret scan OK, PowerShell syntax OK, NPS XML check OK, Default Domain Policy guard OK.

### Next session - P01 Phase 2
- Read `C:\Skills\agents-skills\winserver-p01\p01-references\phase-2-password-policy.md` before live changes.
- Capture before-state evidence for password policy and GPO state.
- Fix the domain security gap: target `MinPasswordLength=14` and `LockoutThreshold=5` using the approved Phase 2 method with rollback documented.
- Verify with `Get-ADDefaultDomainPasswordPolicy` and save evidence under the project verification structure.
- Do not proceed to Phase 3 tiered admin work until Phase 2 evidence is complete.

---

## Session — 2026-06-22 (Codex — stale DC naming cleanup)
### What I did
- Pulled Claude's latest commit `84aade9` before editing.
- Fixed stale `WIN-DC01` references in `skills/windows-server-business-admin.md`.
- Left `docs/naming-standards.md` unchanged because `WIN-DC01` there is only a generic naming-pattern example.

### Files created/modified
- `skills/windows-server-business-admin.md`
- `CODEX-LOG.md`

### Architecture decisions made
- The live PDC remains `WIN-PRQD8TJG04M` at `192.168.20.11`.
- The planned replica DC remains `WIN-DC02` from Project 02.
- Cisco RADIUS examples now use `<NPS-SERVER-IP>` instead of a stale DC-specific placeholder because NPS placement must be confirmed during Project 13.

### Cross-family impacts
- Keeps the Windows identity skill aligned with NetOps, CML/CCNA, OPNsense, and SOC documentation that will later consume AD/NPS details.

### Open questions for Claude
- Local changes are ready for review/commit/push. Codex did not push because `AGENTS.md` says Claude owns GitHub pushes for this repo unless Leonel explicitly asks Codex to push.

---

## Session — 2026-07-13 (Codex primary with Claude peer — Q003 preparation)

### What I did

- Closed the U0-RUNNER-R01 local-only prerequisite with the shared workflow
  inventory, public `windows-latest` patch, and parity checklist; no push or
  runner change occurred.
- Asked Claude for an independent read-only challenge of Q003 safety,
  rollback, stop conditions, and evidence.
- Verified the material findings against Microsoft AD cmdlet documentation.
- Wrote Q003's change window, rollback plan, screenshot plan, and fail-closed
  PowerShell script.
- Corrected the stale `winserver01` reference to the configured `winserver`
  SSH alias.
- Reconciled Q003 as In Progress across the Windows indexes and central state.
- Raised `CLAUDE-REVIEW.md` item Q003-01 for the reachability/precheck gate.

### Verification

- Windows PowerShell AST parser: zero script errors.
- YAML parse: central state and goal registry passed.
- Relative Markdown links: passed.
- Git whitespace checks: passed.
- Claude's first precheck stopped on the wrong workstation before any AD
  query. The corrected PDC Tailscale attempt timed out before hostname
  verification. A LAN fallback produced no usable result and was stopped.
- No test object was created, deleted, restored, moved, or enabled. No AD,
  runner, service, task, or workflow state changed.

### Architecture decisions made

- The test identity is `q003-restore-0713`, disabled, passwordless,
  non-privileged, and pinned by GUID after creation.
- The proposed starting and final location is the existing Quarantine OU, but
  execution stops unless fresh prechecks prove that OU exists.
- The rollback floor is object-level: baseline plus Recycle Bin. Q003 never
  restores a DC checkpoint or system state for one disposable object.
- A failed/partial object remains disabled in Quarantine or safely in Deleted
  Objects. There is no routine second deletion and no forced replication.
- RTO is 30 minutes from deletion to both-DC verified restore.

### Cross-family impacts

- Q004 and Q005 remain waiting for Q003.
- The public P01 workflow patch remains local and requires separate
  commit/push approval and hosted-run parity proof.

### Needed from Leonel

- Restore `WIN-PRQD8TJG04M` Tailscale/OpenSSH reachability or run the prepared
  script locally with `-Mode Precheck`.
- After a clean precheck, approve or reject the exact
  `Q003-20260713-LEONEL` live exception in the change-window document.

---

## Session — 2026-07-14 (Codex primary with Claude peer — Q003 precheck passed)

### What I did

- Used Leonel's console evidence to confirm the PDC hostname, running
  OpenSSH/Tailscale services, and TCP 22 listener.
- Worked with Claude to prove LAN SSH at `192.168.20.11`; the Tailscale path
  remained unreachable and was not required for the supervised local run.
- Diagnosed the SSH credential-delegation limit that prevented Claude's
  key-authenticated session from querying `WIN-DC02` through ADWS.
- Corrected two fail-closed precheck defects: zero-count replication history is
  no longer treated as a current failure, and native `repadmin` status `234` is
  accepted only for complete structured errors-only output with no failed
  result and clean independent replication gates.
- Had Claude independently review each correction and hash-match each temporary
  PDC script copy.
- Saved the fresh passing transcript at
  `projects/project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/evidence/q003-precheck-2026-07-14.txt`.
- Resolved `CLAUDE-REVIEW.md` item Q003-01 and reconciled the Windows indexes.

### Verification

- Final read-only result: `Q003_PRECHECK=PASS`.
- Domain and forest: `Chongong.local`.
- Writable DCs: `WIN-PRQD8TJG04M` and `WIN-DC02`.
- Recycle Bin enabled through both DCs; effective deleted-object lifetime is
  180 days.
- Existing Quarantine OU confirmed; no live or deleted test-name collision.
- Current replication failures: 0; nonzero partner results: 0; `repadmin`
  summary: 0/5 failures in both directions.
- Evidence scan found no password, key, token, credential prompt, public WAN
  address, or unrelated identity list.
- No AD object was created, changed, deleted, moved, enabled, or restored.

### Current gate

- Leonel supplied the exact `Q003-20260714-LEONEL` approval and launched the
  reviewed script from the authenticated PDC console.
- The same GUID was created disabled, captured, deleted, restored, and verified
  through both DCs in 0.51 minutes. The run ended `Q003_RESULT=PASS`.
- Claude retrieved and independently reviewed the complete transcript, found
  no discrepancy or secret, and approved the execution evidence.
- Codex wrote the readable role-based closeout, reconciled the Windows indexes,
  and advanced the master queue without marking full Project 11 complete.
- Q003 is complete. Q004 is next.

---

## Session — 2026-07-14 (Codex primary with Claude peer — Q004 preparation)

### What I did

- Recovered Q004 as the deterministic next queue item and kept Q005/P05
  waiting behind it.
- Ran fresh Claude-assisted LIVE-RO discovery for the domain, two default
  GPOs, direct links, OUs, backup directory, modules, SYSVOL/NETLOGON, storage,
  replication, and test-name collision.
- Designed a custom-GPO-only restore proof at the existing Quarantine OU using
  a harmless user registry marker and GPMC Group Policy Modeling; no client
  move or `gpupdate` is part of the exercise.
- Wrote the Q004 README, run sheet, change window, rollback/evidence plans,
  fail-closed PowerShell script, and sanitized preparation evidence.
- Corrected the parent Project 11 guidance: PowerShell `Restore-GPO` targets
  an existing GPO, so Q004 faults and restores the same disposable GUID rather
  than deleting it first.
- Had Claude independently review the package and invoke only the in-memory
  read-only precheck twice.

### Verification

- Windows PowerShell AST parser: passed after every script correction.
- Claude's first precheck found the installed module's nested GPO version
  shape; Codex changed the script to guard and compare User/Computer AD and
  SYSVOL versions. Claude verified the correction and found no remaining
  static issue.
- Claude's final read-only pass over the current package found no Critical,
  High, Medium, or Low issue and rated it preparation ready, not execution
  ready.
- The corrected precheck passed host/domain/PDC, writable-DC identity,
  module/cmdlet, share, storage, exact GPO/collision, canonical link,
  Quarantine safety, and default-policy version guards.
- It then stopped fail-closed because WIN-DC02 ADWS was unreachable during the
  replication cmdlet check. The exact root cause remains open.
- `Execute` and `Cleanup` are still locked by
  `Q004-APPROVAL-NOT-RECORDED`.
- No backup, GPO, link, OU, identity, remote file, service, or client state was
  created or changed. No commit or push occurred.

### Architecture decisions made

- The test GPO is `Q004-GPO-Restore-Test`; both default-policy GUIDs are
  protected by explicit name, GUID, version, status, modification-time, and
  canonical-link guards.
- Quarantine must have no enabled user anywhere in its subtree; the one link
  is enabled but not enforced and contains only a test user setting.
- The exact test-GPO backup ID is the only restore target. All-GPO backup is a
  recovery floor, not authority to restore defaults.
- The disabled Q003 identity and Workstations OU are modeling inputs only;
  no user/computer is moved, enabled, refreshed, or treated as disposable.
- Execution evidence must include a supervised transcript, baseline/fault/
  restored reports, saved RSoP model, cleanup proof, redaction scan, and final
  independent Claude review.

### Current gate

- Restore/confirm WIN-DC02 ADWS and require a fresh passing precheck.
- Leonel must then accept the exact dated Q004 change window.
- Q004 remains In Progress and Q005 stays queued; final live evidence does not
  yet exist.

---

## Session — 2026-07-14 (Codex primary with Claude peer — Q004 closeout)

### Outcome

- Leonel's interactive precheck passed; both DCs, protected policies,
  Quarantine scope, replication, storage, and collision guards were healthy.
- The first approved Execute backed up all policies and created/backed up the
  disposable baseline, then stopped before fault injection on the installed
  `GpoBackup.Id` versus drafted `BackupId` property shape. Automatic
  containment removed the link; defaults remained untouched.
- After exact resume approval and Claude's independent `RESUME-READY` review,
  the pinned custom backup restored the same GPO from
  `Q004-FAULT-INJECTED` to `Q004-BASELINE` in 0.1 minutes.
- Group Policy Modeling named the custom GPO as the winning source. Verify and
  Cleanup passed. The disposable GPO/link are absent; the original two-policy
  state and clean two-DC replication remain.
- Claude independently reviewed the complete final evidence and returned
  `COMPLETE-READY` with no material blocker. Codex validated PowerShell/JSON/
  XML syntax, links, identifiers, marker lifecycle, screenshots, redaction,
  and worktree scope.
- Claude's final read-only cross-repository documentation review returned
  `PUBLISH-READY`: all 14 evidence hashes, first-person story, technical links,
  900-pixel screenshot wrappers, and Q004 Complete/Q005 Selected status passed.

### Handoff

- Q004 / SIM-B3-GPO-RESTORE is complete with evidence under its project
  folder. Full Project 11 remains planned at Q037.
- Q005 / SIM-B4-VM-RESTORE is the next deterministic queue item but is not
  started or authorized by this closeout.
- All repository changes remain local; no commit or push occurred.

---

## Session — 2026-07-14 (Q004 documentation-standard adoption)

### What changed

- Reworked Q004 into the canonical completed-project structure without
  changing its technical claims or evidence.
- Added one short section for each of its ten phases, moved both screenshots
  into Phase 7, added a re-verification path, and recorded Leonel's input,
  Codex's work, Claude's independent reviews, communication, and resolved
  pushback.
- Replaced the repo-local Windows documentation skill with a Windows-specific
  extension of the family-level canonical skill, removing conflicting section
  and screenshot rules.

### Verification

- The Q004 phase table and phase sections are one-to-one.
- Phase 7 is the only phase with inline screenshots and contains exactly two.
- Existing Q004 evidence links, status, risk boundary, and final claims remain
  unchanged.
- This was repository documentation work only; no AD, GPO, client, backup, or
  other live system was accessed or changed.

---

## Session — 2026-07-14 (Q004 narrative-phase refinement)

- Applied Leonel's presentation correction: phase status now appears only in
  the table, never inside a phase breakdown.
- Rewrote Q004 Phases 0–9 as concise first-person story sections without
  repeated What/How/Result/Connection/Details labels.
- Preserved one concrete method or artifact and a natural evidence link in
  every phase, plus the result and handoff to the next phase.
- Updated the canonical standard, templates, documentation skill, closeout
  checks, and Windows extension to make this the rule for future projects.
- Claude independently reviewed the revised pattern and returned `READY` with
  no fix. No live system was accessed or changed.

---

## Session — 2026-07-14 (Q003 canonical documentation rewrite)

- Rebuilt the completed Q003 README with the canonical first-person portfolio
  structure while preserving the original evidence and recovery result.
- Added the STAR summary, reader paths, test boundary, six-row phase table,
  six matching narrative phase sections, technical evidence, collaboration
  record, pushback resolution, and safe reproduction guidance.
- Moved the one reviewed screenshot into Phase 5 and retained the shared
  900-pixel evidence wrapper.
- Verified `Q003 / SIM-W2-AD-RESTORE` against the central goal registry and
  corrected the stale wording that previously called Q004 the next item; Q004
  later completed separately.
- Claude independently checked the rewrite against the change window,
  rollback, script, transcript, screenshot, closeout, and review record and
  returned `READY` with no material fix.
- This was documentation-only work. No AD object, DC, replication setting,
  policy, identity, or other live system was accessed or changed.

## Session — 2026-07-15 (Q007 Windows hands-on practicum preparation)

- Preserved the completed Q007 automated proof and added a separately gated,
  unexecuted Windows operator practicum that mirrors its phases 0–9.
- Selected one standalone Generation 2 Windows Server VM on a Hyper-V Private
  switch, with no domain join, external adapter, default route, production DNS,
  AD, or DHCP contact.
- Defined Leonel's hands-on role across Hyper-V Manager, Server Manager, DNS
  Manager, and PowerShell; Codex validation gates; an exact change window;
  four rollback levels; and a phase-aligned screenshot plan.
- Claude Fable performed one bounded read-only review and returned GO after
  five clarifications. Codex applied all five and added dual-stack default-route
  validation.
- No live system was accessed or changed. No screenshot was claimed, and no
  commit, push, merge, deletion, or execution approval was inferred.

## Session — 2026-07-15 (Q007 hands-on Phase 0 evidence intake)

- Leonel ran the operator-led Phase 0 Hyper-V and media precheck. Both fixed
  Q007 names were unused and the VHD volume had 904.7 GB free.
- The first ISO candidate was rejected because its origin was not trusted and
  its hash could not be corroborated. Each exact ISO inspection was separately
  approved, read-only, and ended dismounted.
- The accepted `SERVER_EVAL_x64FRE_en-us.iso` matched the pinned SHA-256,
  contained the Windows installation/boot images, and passed Microsoft setup
  and EFI signature checks.
- Codex visually inspected Leonel's Phase 0 screenshot, found no secret or
  unrelated infrastructure, preserved it byte-for-byte, paired it with a text
  extraction, and linked it from the hands-on Phase 0 guide and evidence log.
- No Q007 switch, VM, VHDX, guest, role, DNS object, or fault was created.
  Phase 2 remains separately approval-gated. No commit, push, or merge occurred.

### Phase 2 approval update

- Leonel confirmed no active Hyper-V backup, migration, storage maintenance,
  or host incident and approved the previously reviewed Phase 2 scope on
  2026-07-15.
- Authority is limited to the accepted ISO copy, `Q007-Private`, the fixed
  `Q007-DNS01` VM, and standalone Windows Server installation. Guest IP/DNS
  configuration, deletion, publication, commit, push, and merge remain outside
  that approval.

### Phase 2A execution update — 2026-07-16

- Leonel copied the accepted ISO into the existing Hyper-V ISO library. The
  destination hash exactly matched the pinned source, and the source remained.
- Leonel created `Q007-Private` in Hyper-V Manager. PowerShell showed the exact
  name, type `Private`, and no physical-adapter interface description.
- Codex inspected and ingested the screenshot without alteration or redaction,
  paired it with text, and stopped before VM/VHDX creation.

### Phase 2B host-configuration evidence update — 2026-07-16

- Leonel created `Q007-DNS01` and its dynamic 40 GB VHDX under the approved
  Phase 2 scope. Incremental validation caught 1 vCPU, incorrect startup-memory
  values, and the source ISO attachment before startup; Leonel corrected all
  three while the VM remained Off.
- Final host output showed Generation 2, 2 vCPU, 4 GB static startup memory,
  one adapter on `Q007-Private`, Secure Boot using the Microsoft Windows
  template, and the staged ISO path.
- Codex inspected the Phase 2B PNG, found no secret or unrelated Hyper-V
  object, preserved it byte-for-byte, paired it with searchable text, and
  limited the claim to host-side configuration. Windows installation inside
  the guest remains unverified.
- No guest IP, default route, DNS role, zone, record, fault, production object,
  deletion, commit, push, or merge was performed or claimed by Codex.

### Phase 2B boot-remediation approval — 2026-07-16

- The first installer start reached a Generation 2 boot summary: the DVD boot
  loader did not continue, network boot had no image, and the empty VHDX had no
  operating system. The clean screenshot was inspected but not promoted as a
  success capture.
- Leonel explicitly approved fixing only that Q007 VM boot path and starting
  the standalone installation. The permitted repair is limited to powering
  off the uninstalled VM, reasserting the staged DVD, Microsoft Windows Secure
  Boot template, and DVD-first order, then restarting and completing Setup.
- Leonel remains the manual console executor. Phase 3 guest IP/DNS work and all
  deletion, commit, push, and merge actions remain unapproved.

### Overnight handoff — 2026-07-16

- After the approved DVD/Secure Boot/first-boot repair, Windows Setup started
  successfully and reached 50%.
- Leonel paused for the night with `Q007-DNS01` left running and isolated on
  `Q007-Private`. Setup may finish, reboot, and wait at its next interactive
  screen; no key should be pressed during an automatic DVD-boot prompt.
- Resume by connecting to the VM, completing local Administrator setup if
  necessary, signing in, and proving the OS edition plus `PartOfDomain=False`.
  Do not repeat Phase 0–2, rename the guest, configure its IP/DNS, or start
  Phase 3 before Codex accepts that output and records separate authority.
- All current repository edits remain local and uncommitted. No push or merge
  occurred.

### Phase 2 guest-installation verification — 2026-07-16

- Leonel resumed `Q007-DNS01`, signed in, and supplied read-only CIM output
  from elevated Windows PowerShell inside the guest.
- The output proved Microsoft Windows Server 2022 Standard Evaluation version
  10.0.20348, build 20348, was running. The guest reported `WORKGROUP` and
  `PartOfDomain=False`.
- Codex preserved the pasted output as text evidence, updated the Phase 2
  claim boundary, and accepted the guest-installation gate. No redaction was
  needed.
- Phase 3 guest rename, IP, and DNS-client configuration remain unapproved and
  unstarted. No role, zone, record, fault, repair, deletion, commit, push, or
  merge occurred.

### Phase 3 approval — 2026-07-16

- Leonel explicitly approved only the standalone guest rename/restart,
  evidence transcript, `10.77.7.2/24` and `10.77.7.10/24` on the single
  Private-switch adapter, no default gateway, and DNS client `10.77.7.2`.
- The fresh precheck was the accepted Phase 2 output: Windows Server 2022
  Standard Evaluation build 20348, `WORKGROUP`, and `PartOfDomain=False`.
- Leonel remains the manual guest-console executor. DNS role, zone, record,
  fault, repair, deletion, commit, and push remain outside this approval.

### Phase 3 execution and evidence — 2026-07-16

- Leonel renamed the standalone guest to `Q007-DNS01`, restarted it, created
  the evidence transcript, and passed a fresh preconfiguration check with one
  Up adapter, an APIPA address, no default route, and
  `PartOfDomain=False`.
- He configured only `10.77.7.2/24` and `10.77.7.10/24` on that adapter, set
  the secondary address to `SkipAsSource=True`, and set the DNS client only to
  `10.77.7.2`.
- Final output showed exactly the two approved addresses, no IPv4 or IPv6
  default route, `PartOfDomain=False`, and `Phase3Pass=True`.
- Codex rejected the first screenshot because it included the local account
  path. Leonel recaptured only the technical output; Codex inspected it, found
  no secret or unrelated infrastructure, preserved it byte-for-byte, and
  paired it with searchable text.
- Phase 4 DNS-role and zone work remain unapproved and unstarted. No production
  DNS, role, zone, record, fault, repair, deletion, commit, push, or merge
  occurred.

### Phase 4 approval — 2026-07-16

- Leonel explicitly approved only installing the DNS Server role and tools in
  the isolated standalone guest, creating file-backed primary zone
  `q007.test` with dynamic updates disabled, and creating only the `files` A
  record for `10.77.7.10`.
- The accepted Phase 3 output is the fresh entry evidence: one Up adapter,
  exactly two fixed lab addresses, self-DNS only, no default route,
  `PartOfDomain=False`, and `Phase3Pass=True`.
- Leonel remains the manual guest executor. AD DS, DHCP, other roles, PTRs,
  forwarders, delegations, production DNS, fault injection, deletion, commit,
  and push remain outside this approval.

### Phase 4A execution and evidence — 2026-07-16

- Leonel used Server Manager to install only the DNS Server role and its
  management tools in `Q007-DNS01`.
- PowerShell showed `DNS` and `RSAT-DNS-Server` Installed, while
  `AD-Domain-Services` and `DHCP` remained Available. The DNS service was
  Running with Automatic start.
- Codex inspected the cropped capture, found no secret or unrelated content,
  preserved it byte-for-byte, and paired it with searchable text.
- Phase 4B zone and baseline-record creation remain approved but unstarted;
  no zone, record, fault, repair, deletion, commit, push, or merge occurred.

### Phase 4B execution, evidence, and overnight handoff — 2026-07-16

- Leonel used DNS Manager to create file-backed primary zone `q007.test` with
  dynamic updates disabled and only the `files` A record for `10.77.7.10`.
- PowerShell proved the zone was Primary, non-AD-integrated, backed by
  `q007.test.dns`, and contained exactly that one A record;
  `Phase4Pass=True`.
- Codex inspected the DNS Manager capture showing the zone, FQDN, exact IP,
  and unchecked PTR option. It exposed no sensitive identifier, was preserved
  byte-for-byte, and was paired with searchable text.
- Leonel stopped for the day before Phase 5. The handoff is to stop the guest
  transcript, shut down only `Q007-DNS01` normally, and retain it Off on
  `Q007-Private`. Resume by starting the VM, appending to the same transcript,
  and rerunning the Phase 4 baseline validation.
- Phase 5 baseline query and fault injection are unapproved and unstarted. No
  wrong record, repair, cleanup, deletion, commit, push, or merge occurred.

### Phase 4 resume validation — 2026-07-17

- Leonel started the retained `Q007-DNS01`, appended to the existing guest
  transcript, and supplied the complete read-only resume output.
- The guest still had exactly the two fixed addresses, self-DNS only, no
  default route, `PartOfDomain=False`, and a running DNS service. The
  file-backed non-AD zone still had dynamic updates disabled and exactly the
  one good `files -> 10.77.7.10` A record; `ResumePass=True`.
- Codex preserved the pasted output as dated text evidence. No redaction was
  needed. Phase 5 remains unapproved and unstarted; no query, fault, record
  change, repair, cleanup, deletion, commit, push, or merge occurred.

### Phase 5 approval — 2026-07-17

- Leonel explicitly approved only the exact direct baseline query,
  `10.77.7.99` liveness check, one five-minute-TTL wrong A record, guest-only
  cache clear, six full-answer direct queries, and good/wrong reachability
  tests.
- The fresh entry evidence is the accepted resume assertion with unchanged
  isolation, service, zone, and one-good-record state.
- Leonel remains the manual guest executor. PTR creation, other zones/settings,
  production contact, repair/removal, cleanup, deletion, commit, and push
  remain outside this approval. Injection waits for the baseline gate.

### Phase 5 baseline gate and evidence — 2026-07-17

- The direct `files.q007.test` query returned exactly `10.77.7.10`, the wrong
  address `10.77.7.99` did not respond, and `Phase5BaselinePass=True`.
- Codex rejected the first screenshot because it exposed the local account
  path. Leonel recaptured only the six validation values; Codex found no
  sensitive or unrelated content, preserved it byte-for-byte, and paired it
  with searchable text.
- Leonel requested GUI screenshots for actual Windows administrative state.
  Future captures prefer Server Manager or DNS Manager; PowerShell remains for
  proof the GUI cannot show, such as full answer sets and NXDOMAIN.
- The approved one-record fault injection and full-answer tests remain
  unstarted. No wrong record, repair, cleanup, deletion, commit, push, or merge
  occurred.

### Phase 5 fault execution and evidence — 2026-07-17

- Leonel added only the approved `files -> 10.77.7.99` A record with a
  five-minute TTL and cleared only the guest DNS-client cache.
- DNS Manager showed the good and wrong records. All six direct queries
  returned both values, the good address was reachable, the wrong address was
  not, and `Phase5FaultPass=True`.
- A supplemental `ping.exe` assertion incorrectly relied on process exit code;
  the wrong target timed out and produced ICMP Destination host unreachable,
  but ping exited zero. Codex preserved that failed assertion and replaced the
  bad assumption with `Test-NetConnection`, which passed good `True`, bad
  `False`, and `ReachabilityPass=True`.
- Codex rejected the first GUI capture because it exposed the Hyper-V host in
  the outer console title. Leonel cropped to DNS Manager only; Codex found no
  sensitive or unrelated content, preserved the image byte-for-byte, and
  paired it with searchable text and the full command-output record.
- The wrong record remains active only in the isolated guest. Phase 6 repair
  is unapproved and unstarted. No record removal, cleanup, deletion, commit,
  push, or merge occurred.

## Session — 2026-07-19 — Q011 Phase 4B repository preparation

### What I did

- Confirmed the prior read-only Hyper-V inventory supports the frozen 2-vCPU,
  6-GiB-static, 60-GiB-dynamic VM design, while retaining fresh live capacity
  and load gates.
- Prepared the exact Phase 4B fresh preflight, Hyper-V Manager creation,
  Off-state verification, failed-creation rollback, and two-image hands-on
  capture instructions.
- Corrected the Phase 2C example to use the supported `Set-VMProcessor` and
  `Set-VMMemory -DynamicMemoryEnabled $false` cmdlets.
- Sent the bounded package through the verified direct Claude CLI bridge for
  one read-only review. Claude returned a conditional pass with no Critical or
  High finding.
- Applied the rollback mismatch and wizard-location clarifications, recorded
  the accepted Low residual hash timing risk, and resolved Q011-02.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4b-disconnected-vm-change-window.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4b-rollback-plan.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase2c-disconnected-vm-design.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-screenshot-plan.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4b-claude-review.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/README.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`

### Architecture decisions made

- Leonel remains the hands-on Hyper-V Manager operator; searchable PowerShell
  supplies the fail-closed preflight and exact final proof.
- The VM stays Off with exactly one Not Connected adapter. VM start, console,
  RHEL installation, and network attachment remain separate gates.
- A present `Zone.Identifier` is a hard stop. Phase 4B does not imply or
  authorize an unblock operation.

### Cross-family impacts

- None. The Proxmox Q011 record remains predecessor discovery only, and no
  live system or cross-repository status was changed in this session.

### Open questions for Claude

- None. The bounded Phase 4B preparation review is resolved; live execution
  still requires Leonel's exact separate approval.

## Session — 2026-07-19 — Q011 Phase 4B execution evidence intake

### What I did

- Guided Leonel screen-by-screen through the separately approved Hyper-V
  creation while keeping the VM Off and the one adapter Not connected.
- Validated the initial preflight stop on `Zone.Identifier`, the separately
  approved exact metadata removal with unchanged bytes/hash, two safe
  operator-confirmation stops, and the final passing preflight.
- Caught Generation 1 selected in the wizard before creation; Leonel corrected
  it to Generation 2 and completed the frozen 2-vCPU, 6-GiB-static,
  60-GiB-dynamic design.
- Reviewed images 001 through 013. Copied all thirteen Q011 captures
  byte-for-byte into the evidence folder, selected two final-state images for
  the project narrative, and used the full set in a linked visual walkthrough.
- Recorded the searchable results, integrity hashes, exact claim boundary, and
  synchronized only the local Windows/Q011 owner status records.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/README.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4b-disconnected-vm-change-window.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4b-rollback-plan.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-screenshot-plan.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4b-evidence.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4b-sanitized-results.txt`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4b-visual-walkthrough.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4b-screenshots.sha256`
- thirteen Phase 4B PNGs under `evidence/screenshots/`
- `README.md`, `projects/README.md`, and
  `projects/project-08-hyperv-operations/README.md`
- `CLAUDE-REVIEW.md` and `CODEX-LOG.md`

### Architecture decisions made

- Phase 4B stops with `Q011-RHEL102-BASELINE` Off. Phase 4C start, console,
  and disconnected RHEL installation remain separate approvals.
- The project README displays only the final disconnected-adapter and firmware
  images. The linked walkthrough uses the other eleven captures, including the
  safely corrected Generation 1 near-miss, without violating the two-inline
  screenshot limit.

### Cross-family impacts

- None. No Proxmox, OPNsense, canonical, vault, or other repository record was
  changed under this owner-only intake approval.

### Open questions for Claude

- None for Phase 4B. Phase 4C must be designed and separately approved before
  first power-on.

## Session — 2026-07-19 — Q011 Phase 4C repository preparation

### What I did

- Prepared the exact disconnected RHEL 10.2 first-power-on and installation
  run sheet without accessing the Hyper-V host.
- Froze Minimal Install, automatic LVM expectation, hostname `q011-rhel01`,
  one local `leonel` administrator, root locked, no registration, and network
  off behind a fresh fail-closed host/VM/media preflight.
- Added the pre-reboot exact ISO-ejection preview/change/proof, local-console
  guest assertions, normal shutdown, host Off-state verification, and
  stage-specific failure containment.
- Planned two primary and three supporting hands-on screenshots. The
  repository-only preparation has an explicit no-screenshot exception because
  Markdown would not prove live practice.
- Sent the package through one bounded read-only Claude review. Claude returned
  a conditional pass with no Critical or High finding.
- Applied both actionable corrections: removed two fragile PowerShell
  continuation characters and made registration verification independent of
  whether Minimal Install ships `subscription-manager`.
- Revalidated three PowerShell blocks with Windows PowerShell 5.1, the Bash
  block with `bash -n`, and the documentation diff with `git diff --check`.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4c-disconnected-rhel-installation.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4c-failure-containment.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-screenshot-plan.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-claude-review.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/README.md`
- `CLAUDE-REVIEW.md`
- `CODEX-LOG.md`

### Architecture decisions made

- The ISO is detached and verified while the installer waits on its completed
  screen, before the one allowed reboot. An empty first DVD entry is retained;
  UEFI then falls through to the installed disk.
- `Begin Installation` is the irreversible boundary. Before it, the operator
  can return the existing VM to Off. After it, failed or partial VHDX state is
  preserved for a separately approved diagnosis instead of being deleted.
- Registration absence uses local identity evidence without installing a
  package. Subscription Manager adds a second signal only when present.
- Phase 4C ends with a normal in-guest poweroff and host proof that the VM is
  Off, disconnected, DVD-empty, and checkpoint-free.

### Cross-family impacts

- None. The Proxmox predecessor record, canonical state, vault, and other
  repositories were not changed under this Windows-owner preparation scope.

### Open questions for Claude

- None. Q011-03 is resolved. Live Phase 4C remains separately approval-gated.

## Session — 2026-07-19 — Q011 Phase 4C execution evidence intake

### What I did

- Guided Leonel through the separately approved fresh preflight, VMConnect
  installation, exact pre-reboot DVD ejection, local verification, normal
  shutdown, and host final-state proof.
- Verified Minimal RHEL 10.2, automatic LVM, `q011-rhel01`, SELinux Enforcing,
  locked root status `L`, `leonel` in `wheel`, zero failed units, no
  registration, and no non-loopback connectivity.
- Preserved two fail-closed deviations: the immediate DVD query returned a
  stale attached path before a later approved read found it empty, and
  VMConnect rejected the long clipboard payload before Leonel switched to
  short manual commands.
- Reviewed the Phase 4C captures, copied seven safe PNGs byte-for-byte, selected
  two for the project narrative, and used all seven in a linked walkthrough.
- Excluded the hardware-address image and three password-prompt diagnostic
  images; none contained the password itself.
- Recorded searchable results, exact image hashes, claim boundaries, and
  `Phase4CEndStatePass=True`.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/README.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase4c-disconnected-rhel-installation.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-screenshot-plan.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-evidence.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-sanitized-results.txt`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-visual-walkthrough.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase4c-screenshots.sha256`
- seven Phase 4C PNGs under `evidence/screenshots/`
- Windows root/project navigation, `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- The installed shadow-utils root-lock code `L` is accepted alongside `LK` in
  the reusable verification logic.
- The long VMConnect clipboard path is not retried; short manual console
  commands are the supported hands-on method for later phases.
- The missed boot-menu image is replaced honestly by a Welcome-screen capture,
  not relabeled as proof that was never taken.
- Phase 4C closes with the VM Off, disconnected, DVD-empty, and
  checkpoint-free; it does not claim patch, remote SSH, firewall, or network
  readiness.

### Cross-family impacts

- None. No Proxmox, OPNsense, canonical, vault, or other repository record was
  changed under this Windows-owner intake.

### Open questions for Claude

- None for the completed Phase 4C live result. Later network and patch phases
  remain separately designed and approval-gated.

## Session — 2026-07-19 — Q011 Phase 5 repository preparation

### What I did

- Prepared Phase 5 as a disconnected, read-only before-state for OpenSSH,
  firewalld, SELinux, listeners, packages, configuration hashes, registration,
  LVM, system health, and networking.
- Added a fresh Off/disconnected/DVD-empty Hyper-V preflight, short manually
  typed console commands, two primary screenshots plus one supporting capture,
  normal shutdown, final host proof, and fail-closed handling.
- Kept service/package/firewall/SSH/SELinux changes, registration, repository
  contact, network attachment, patching, checkpoints, and another VM outside
  the prepared window.
- Sent the Phase 4C intake and Phase 5 package through the requested single
  bounded read-only Claude review. Claude returned a conditional pass with no
  Critical or High finding and no technical safety defect.
- Applied both required bridge-file traceability corrections and both optional
  clarity corrections, including the deliberate 12-GiB Phase 5 memory floor
  and the unvalidated post-execution DVD polling note.

### Files created/modified

- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-phase5-disconnected-service-baseline.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/evidence/q011-phase5-claude-review.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/README.md`
- `projects/project-08-hyperv-operations/q011-isolated-rhel-baseline/docs/q011-screenshot-plan.md`
- Windows root/project navigation, `CLAUDE-REVIEW.md`, and this log

### Architecture decisions made

- Phase 5 measures the unpatched disconnected baseline before any network,
  registration, or patch design. An inactive service or missing package is a
  finding, not authority to repair it.
- The VM returns to the same Off, disconnected, DVD-empty, checkpoint-free
  state. No configuration rollback is needed because the phase changes no
  guest setting.
- The 12-GiB free-memory floor is deliberate for one installed 6-GiB guest;
  Phase 4C retained 16 GiB for the installer workload.

### Cross-family impacts

- None. This preparation changed only the local Windows-owner worktree.

### Open questions for Claude

- None. The bounded review is resolved. Phase 5 live execution remains
  separately approval-gated.
