# CODEX-LOG.md — Codex Session Log

Codex writes here after every session. Claude reads this to stay in sync.

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
