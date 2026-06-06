# CODEX-LOG.md — Codex Session Log

Codex writes here after every session. Claude reads this to stay in sync.

---

## Log Format

```
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

## Session — 2026-06-05 (Claude)
### What I did
- SSH'd to WIN-PRQD8TJG04M via Tailscale (100.81.197.116) using claude_winserver_2022_ed25519 key
- Ran full live audit: roles, AD users, OUs, groups, GPOs, password policy, firewall, DHCP, DNS
- Discovered server is already a promoted PDC for Chongong.local (DomainRole=5) — NOT a clean install
- Found 5 critical/high security gaps (see CLAUDE-REVIEW.md)
- Designed Project 01 as 7-phase audit/harden/formalize project (not a fresh installation)
- Wrote complete P01 skill covering all 7 phases with exact PowerShell commands
- Applied 15 self-review corrections to the skill before deploying
- Deployed skill to 4 locations: .agents/skills/, .codex/skills/, .claude/commands/, GitHub
- Updated projects/project-01-server-baseline-hardening/README.md with actual phases and audit findings
- Updated skills/README.md to mark P01 skill as ready

### Files created/modified
- `skills/project-01-server-baseline-hardening.md` — NEW: full 7-phase P01 skill
- `skills/README.md` — P01 marked ✅ Ready
- `projects/project-01-server-baseline-hardening/README.md` — updated with actual server state
- Local: `.agents/skills/winserver-p01/SKILL.md`, `.codex/skills/winserver-p01/SKILL.md`
- Local: `.claude/commands/winserver-p01.md`

### Architecture decisions made
- Project 01 is "Audit, Harden, Formalize" NOT "Install AD" — server already has everything
- Password policy hardened via Default Domain Policy (not PSO) first because it covers ALL users
- PSO-Tier0-Admins (Precedence 10, min 20 chars, lockout 3) layered on top for adm-leonel only
- RDS/IIS on DC: document risk only, migrate in Project 08 (Hyper-V Operations)
- DefaultInboundAction: document gap only, fix in Project 05 (GPO Security Baselines)
  because setting Block without AD port allowlist GPO would break domain auth for all 13 VMs
- testuser: use for lockout exercise then disable+quarantine — per family safety rules: never delete
- Groups OU verification added before PSO group creation — prevents silent failure on wrong path
- GPO rollback order: set LockoutThreshold=0 FIRST before reverting observation window
  (partial revert with threshold=5 + window=0 causes permanent bad-attempt accumulation)

### Cross-family impacts
- NPS is already installed + radius-service account exists — investigate purpose before Project 13
  NPS uses machine account (WIN-PRQD8TJG04M$) for AD lookups, NOT radius-service
- UDP 1812/1813 must be verified open in Phase 5 firewall baseline (needed for Project 13 RADIUS)
- RADIUS01 computer account already joined to domain — review in Project 13 context
- __vmware__ group (Domain Local) exists with unknown purpose — review before removing

### What Codex should review next
- See CLAUDE-REVIEW.md for 5 open items before Phase 2 work begins
- Phase 2 commands are ready in the skill — Codex should verify the password policy commands
  against the actual domain DN before Leonel runs them

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
