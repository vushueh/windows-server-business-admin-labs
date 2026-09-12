## Shared workflow

Read `E:/Homelab-Repos/family-projects/AGENTS.md` once per session
(`/mnt/e/Homelab-Repos/family-projects/AGENTS.md` in WSL). If working outside
this workspace, fetch the shared contract from
`vushueh/family-projects-ai-playbook` before homelab operations.
It owns task-scoped reads and publication authority; this repo owns technical
constraints. For a named file task, read target files and related OPEN items.
For project selection/status/resume, use the shared goal skill and freshness
checks; preserve the active item, dependencies, queue order and WIP limits.
Either operating agent may publish the authorized package. Use explicit paths
and relevant checks, preserve dirty work and intentionally unpublished overlays.

# AGENTS.md — Codex Standing Orders
## Windows Server Business Admin Labs

**Read this file before doing any work in this repo.**

---

## What This Repo Is

Advanced Windows Server 2022 lab. Goal: build a real small-business Microsoft environment
and integrate it as the identity backbone for all other homelab families.

**Platform:** Hyper-V host WIN-PRQD8TJG04M (192.168.20.11, Tailscale 100.81.197.116).
**Important:** This machine is the original Primary Domain Controller and FSMO holder for Chongong.local.
`WIN-DC02` (192.168.20.12) is now the replica DC and secondary DNS server.
It is not a fresh server — see `projects/project-01-server-baseline-hardening/README.md`
for the complete live audit findings.

## Agent role

Design, troubleshoot, document and verify the approved task. Either agent may
publish authorized work. Live execution restrictions and production review
requirements in this repo continue to apply.

## Before Starting Any Task

1. Search relevant OPEN items in `CLAUDE-REVIEW.md`; respect related blockers and claims
2. Read the relevant project README.md and current phase skill file
3. For AD architecture changes, read `docs/identity-design.md`
4. For naming changes, read `docs/naming-standards.md`
5. For documentation work, read `skills/winserver-evidence-documentation/SKILL.md`
6. For P01 work, read `skills/project-01-server-baseline-hardening.md`

## Edit Tier Rules

All three parties (Claude, Codex, Leonel) must follow this model.

### Tier 1 — Local repo (default for all content work)
Use for: phase files, project READMEs, scripts, skill files, docs.
Local path (Windows): `E:\Homelab-Repos\family-projects\windows-server-business-admin-labs\`
Local path (WSL):      `/mnt/e/Homelab-Repos/family-projects/windows-server-business-admin-labs/`
- Codex writes here directly (open this folder as the Codex workspace/project).
- Claude reads and edits files here directly.
- Start with scoped Git status; commit explicit reviewed paths and publish only when authorized.

### Tier 2 — GitHub API (exception only)
Use for: bridge file quick patches (CLAUDE-REVIEW.md, CODEX-LOG.md) between sessions when no local checkout is open.
Never: phase content, skill files, configs, or any file over ~5KB.
Either agent may publish the user-authorized package using available Git/GitHub tools.

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
- **Publish only the authorized scope** using the shared Git/GitHub rule
- All scripts must be reviewed by Claude before running in production AD

## Actual Environment (Discovered 2026-06-05)

| Component | IP / Location | Notes |
|-----------|--------------|-------|
| WIN-PRQD8TJG04M | 192.168.20.11 / Tailscale 100.81.197.116 | PDC/FSMO holder for Chongong.local, also Hyper-V host |
| WIN-DC02 | 192.168.20.12 | Replica DC, DNS, Global Catalog |
| SSH access | `ssh -i claude_winserver_2022_ed25519 Administrator@100.81.197.116` | Ed25519 key |
| Domain | Chongong.local / CHONGONG | Windows2016Domain functional level |
| Joined computers | RADIUS01, GITEA, 5× DESKTOP machines | Already domain-joined |
| WIN-FS01 | TBD (Project 06) | Hyper-V VM to be created |
| WIN-WS01 | TBD (Project 07) | Hyper-V VM to be created |
| OPNsense | Hyper-V VM | Will authenticate to NPS (Project 13) |

## Current Project Status

| Project | Status | Notes |
|---------|--------|-------|
| 01 — Server Baseline + Hardening | ✅ Complete | Password/lockout hardened, tiered admin model created, RDS/IIS/NPS/firewall risk documented |
| 02 — AD Architecture | ✅ Complete | Managed OUs, AGDLP groups, disabled staged accounts, AD Recycle Bin, helpdesk delegation, and `WIN-DC02` replica DC are live |
| 03 — DNS Engineering | ✅ Complete | DC DNS client fixed, reverse zone/PTR records created, scavenging enabled, split-brain DNS and `WIN-DC02` secondary DNS verified; Route10 `localdomain` conditional forwarder added |
| 04 — DHCP/IPAM Integration | ✅ Complete | Windows DHCP documented, option 6 corrected to both DCs, Route10/OPNsense authority model preserved, Hyper-V addressing captured |
| 05–13 | ⬜ Planned | Follow the cross-family execution roadmap |

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

## Master Program Selection

Before selecting or advancing work, invoke the local `/goal` wrapper or read
`../docs/homelab-goals.yaml`. Resume the active primary item or take exactly
the lowest-sequence ready item; never offer a project menu. Reconcile this
repo's README/project state and `CLAUDE-REVIEW.md` lock first. A blocker must
be repaired, safely rescoped, or closed Deferred with a precise trigger before
advancing. Windows live-change and identity safety gates remain unchanged.
