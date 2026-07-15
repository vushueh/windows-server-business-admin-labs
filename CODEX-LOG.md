# CODEX-LOG.md — Codex Session Log

Codex writes here after every session. Claude reads this to stay in sync.

---

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
