# AGENTS.md — Codex Standing Orders
## Windows Server Business Admin Labs

**Read this file before doing any work in this repo.**

---

## What This Repo Is

Advanced Windows Server 2022 lab. Goal: build a real small-business Microsoft environment
and integrate it as the identity backbone for all other homelab families.
Platform: Hyper-V host (WIN-PRQD8TJG04M / 192.168.20.11).
Domain Controller VM: WIN-DC01 (IP assigned in Project 01).

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
2. Read the relevant project README.md and current phase file
3. Read `docs/identity-design.md` for AD architecture reference
4. Read `docs/naming-standards.md` for naming conventions

## Critical Safety Rules

- **NEVER modify Default Domain Policy or Default Domain Controllers Policy** without explicit approval
- **NEVER delete AD objects (OUs, users, groups, computers)** — disable/move only
- **NEVER run `gpupdate /force` affecting all users** without staging and approval
- **NEVER change NPS/RADIUS policy** without approval — it controls auth for all network devices
- **ALWAYS recommend system state backup before Domain Controller changes**
- **NEVER push to GitHub** — write files locally, Claude pushes
- All scripts must be reviewed by Claude before running in production AD

## Environment Reference

| Component | IP / Location | Notes |
|-----------|--------------|-------|
| Hyper-V Host | 192.168.20.11 | WIN-PRQD8TJG04M |
| WIN-DC01 | TBD (Project 01) | Primary DC, DNS, NPS |
| WIN-FS01 | TBD (Project 06) | File Server |
| WIN-WS01 | TBD (Project 07) | Test workstation |
| OPNsense | Hyper-V VM | Will authenticate to NPS (Project 13) |

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
