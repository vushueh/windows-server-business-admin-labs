# CLAUDE.md — windows-server-business-admin-labs

Shared rules: [../AGENTS.md](../AGENTS.md) ·
[../AI-HOMELAB-PLAYBOOK.md](../AI-HOMELAB-PLAYBOOK.md). Repo-specific facts
below. Last updated: 2026-07-04.

## What this repo owns (source of truth for)

- Domain `Chongong.local` / CHONGONG: AD architecture, OUs, AGDLP, tiering
  (`docs/identity-design.md`, `docs/naming-standards.md`)
- Both DCs: WIN-PRQD8TJG04M (PDC, 192.168.20.11, FSMO holder, Hyper-V host)
  and WIN-DC02 (192.168.20.12, replica DC + DNS + GC, built 2026-07-03)
- Windows DNS (zones, forwarders, `localdomain` conditional forwarder →
  192.168.20.1), Windows DHCP for VLAN 20, GPO work, `docs/topology.md`

## What this repo must NOT touch

- Route10/Alta config and the homelab-wide IPAM plan → route10 repo
- OPNsense → homelab-opnsense · PA-220 → homelab-management
- Live AD/GPO/DHCP/DNS changes without approved change-window (Tier 3);
  never edit Default Domain Policy; never delete AD objects (disable + move)

## Settled facts (2026-07-04)

- Windows owns VLAN 20 DHCP (scope options 3/6/15/51; DNS = .11 + .12;
  options 66/67 removed — netboot.xyz retired)
- DNS pollution cleanup held: PDC name resolves to 192.168.20.11 only
- Stale lease 192.168.20.21 (pre-rename WIN-DC02) expires 2026-07-27 naturally

## Known follow-ups (non-blocking, documented in CLAUDE-REVIEW.md)

- `Get-ADDomainController` reports the PDC's IPv4 as the Tailscale APIPA
  (169.254.83.107) — cosmetic per replication health, not root-caused
- Administrator password rotation recommended (shared in chat 2026-06-23 and
  2026-07-02)
- RDS/IIS still on the DC — migration is P08

## Current status source

Current project status lives in
[../docs/state.yaml](../docs/state.yaml). Keep this file focused on repo
ownership, settled facts, hazards, and standards.

## Repo standards

- Access: SSH alias `winserver` with key `claude_winserver_2022_ed25519` →
  PowerShell 5.1 (`;` not `&&`); WIN-DC02 via `Invoke-Command` from PDC with
  explicit credential. The previously referenced `winserver01` alias is not
  present in the current SSH configuration.
- Evidence: `projects/<p>/docs/` + screenshots per project (follow each
  project's existing layout); use the shared
  [portfolio documentation standard](../docs/readme-layered-documentation-standard.md)
  through the canonical
  [`homelab-project-documentation` skill](../.claude/skills/homelab-project-documentation/SKILL.md),
  plus the Windows-specific `winserver-evidence-documentation` extension;
  review file uses 🔴/🟢 emoji style
- Technical how-to lives in global skills `winserver-p01`,
  `winserver-projects`, `winserver-evidence-documentation` — some predate
  P02–P04 outcomes; flag stale guidance instead of following it blindly
- `.github/workflows/p01-safety-check.yml` exists — keep it green
- For suspected AD compromise, incident playbooks, or identity forensics, use
  the canonical
  [`homelab-incident-response` AD investigation reference](https://github.com/vushueh/family-projects-ai-playbook/blob/main/.claude/skills/homelab-incident-response/references/ad-compromise-investigation.md).
  It allows evidence-first investigation but keeps credential dumping,
  account/GPO changes, domain-controller rebuilds, and `krbtgt` rotation behind
  the approved incident change process.

## Cross-repo links

- VLAN 20 authority + gateway pair with route10 repo P02
- P10 (Wazuh/WEF) pairs with homelab-management; P11 backups pair with the
  backup workflows there; P13 NPS/RADIUS pairs with route10 P09 + CCNA AAA

## `/goal` Session Start

Run `/goal next` before project work. The local wrapper loads the canonical
skill from the family-projects root; if unavailable, read
`E:\Homelab-Repos\family-projects\docs\homelab-goals.yaml`. Return one
queue-selected project, reconcile `CLAUDE-REVIEW.md`, and do not advance past
an unresolved blocker. Windows live-change gates remain unchanged.
