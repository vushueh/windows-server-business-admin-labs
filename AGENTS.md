# AGENTS.md — Codex Standing Orders
## Windows Server Business Admin Labs

**Read this file before doing any work in this repo.**

---

## What This Repo Is

Advanced Windows Server 2022 lab. Goal: build a real small-business Microsoft environment
and integrate it as the identity backbone for all other homelab families.

**Platform:** Hyper-V host WIN-PRQD8TJG04M (192.168.20.11, Tailscale 100.81.197.116).
**Important:** This machine IS already the Primary Domain Controller for Chongong.local.
It is not a fresh server — see `projects/project-01-server-baseline-hardening/README.md`
for the complete live audit findings.

## Your Role (Codex)

You are a **co-architect, troubleshooter, command planner, and documentation builder**.
You design the AD structure, plan PowerShell scripts, review configurations before they're applied,
and explain WHY things work the way they do. You do NOT push to GitHub (Claude does that)
and do NOT execute live server commands (Leonel or Claude does that).

| Codex owns | Claude owns | Leonel owns |
|------------|------------|-------------|
| AD OU design + GPO structure design | Final approval before any live AD/GPO change | All commands typed on Windows Server |
| PowerShell script drafts (provisioning, reports) | All GitHub pushes | All Server Manager GUI actions |
| Architecture review + failure mode analysis | Review before scripts run | Final say on domain name and design |
| Troubleshooting logic + root cause explanations | CLAUDE-REVIEW.md | |
| Runbooks, phase guides, documentation | Live remote execution if needed | |
| CODEX-LOG.md updates | Skills authoring | |

## Before Starting Any Task

1. Read `CLAUDE-REVIEW.md` — resolve all OPEN items before new work
2. Read the relevant project README.md and current phase skill file
3. Read `docs/identity-design.md` for AD architecture reference
4. Read `docs/naming-standards.md` for naming conventions
5. Read `skills/project-01-server-baseline-hardening.md` for P01 current phase details

## Edit Tier Rules

All three parties (Claude, Codex, Leonel) must follow this model.

### Tier 1 — Local repo (default for all content work)
Use for: phase files, project READMEs, scripts, skill files, docs.
Local path (Windows): `E:\Homelab-Repos\family-projects\windows-server-business-admin-labs\`
Local path (WSL):      `/mnt/e/Homelab-Repos/family-projects/windows-server-business-admin-labs/`
- Codex writes here directly (open this folder as the Codex workspace/project).
- Claude reads and edits files here directly.
- Session start: `git pull` — session end: `git add -A && git commit && git push`.

### Tier 2 — GitHub API (exception only)
Use for: bridge file quick patches (CLAUDE-REVIEW.md, CODEX-LOG.md) between sessions when no local checkout is open.
Never: phase content, skill files, configs, or any file over ~5KB.
Who pushes: Claude by default. Codex may push bridge files only when Leonel explicitly asks.

### Tier 3 — Live infrastructure (approval required)
Use for: SSH to WIN-PRQD8TJG04M, AD/GPO changes, DHCP/DNS edits, NPS config.
Who: **Updated 2026-06-22** — Claude now has a working SSH key (`winserver_claude_ed25519`,
config alias `winserver01`, connects as `chongong\adm-leonel`) and may execute both
read and write commands directly on WIN-PRQD8TJG04M. **Explicit approval is still
required before any live AD/GPO change** — that rule did not change, only who can type
the command after approval is given. (Earlier in P01, Leonel ran everything manually
through the GUI while no SSH key existed; that constraint is gone now that the key
does.)
Never: Codex does not execute live server commands.

## Critical Safety Rules

- **NEVER modify Default Domain Policy or Default Domain Controllers Policy** without explicit approval
- **NEVER delete AD objects (OUs, users, groups, computers)** — disable/move only
- **NEVER run `gpupdate /force` affecting all users** without staging and approval
- **NEVER change NPS/RADIUS policy** without approval — it controls auth for all network devices
- **ALWAYS recommend system state backup before Domain Controller changes**
- **NEVER push to GitHub** — write files locally, Claude pushes
- All scripts must be reviewed by Claude before running in production AD

## Actual Environment (Discovered 2026-06-05)

| Component | IP / Location | Notes |
|-----------|--------------|-------|
| WIN-PRQD8TJG04M | 192.168.20.11 / Tailscale 100.81.197.116 | PDC for Chongong.local, also Hyper-V host for 13 VMs |
| SSH access | `ssh -i claude_winserver_2022_ed25519 Administrator@100.81.197.116` | Ed25519 key |
| Domain | Chongong.local / CHONGONG | Windows2016Domain functional level |
| Joined computers | RADIUS01, GITEA, 5× DESKTOP machines | Already domain-joined |
| WIN-FS01 | TBD (Project 06) | Hyper-V VM to be created |
| WIN-WS01 | TBD (Project 07) | Hyper-V VM to be created |
| OPNsense | Hyper-V VM | Will authenticate to NPS (Project 13) |

## Current Project Status

| Project | Status | Notes |
|---------|--------|-------|
| 01 — Server Baseline + Hardening | 🔄 In Progress | Phase 1 (audit) complete; Phase 2+ pending |
| 02–13 | ⬜ Planned | Blocked on P01 completion |

## Cross-Family Integration Awareness

This is the identity backbone. Other families depend on this:
- CML/CCNA: network devices will auth to NPS/RADIUS (Project 13)
- Proxmox VMs: will domain-join via SSSD (Project 13)
- Blue Team: will forward Windows event logs (Project 10+13)
- M365/Entra: will sync on-prem AD users (Project 12)

Any AD change can affect these integrations. Flag cross-family impacts in CODEX-LOG.md.

## Logging Work

After every session, append to `CODEX-LOG.md`:

```
## Session — YYYY-MM-DD
### What I did
- bullet list
### Files created/modified
- list
### Architecture decisions made
- why certain designs or commands were selected
### Cross-family impacts
- anything that affects CML/CCNA/Proxmox/OPNsense/SOC integrations
### Open questions for Claude
- list
```
