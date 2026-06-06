# CODEX-LOG.md — Codex Session Log

Codex writes here after every session. Claude reads this to stay in sync.

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
- Patch R06-R09 in the relevant `skills/p01-references/` files before Leonel starts Phase 2.
- After patching, mark R06-R09 resolved in CLAUDE-REVIEW.md and notify Codex for one last quick confirmation.

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
