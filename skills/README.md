# Skills

Skills are pre-phase reference guides. Read the relevant skill at the start of every project session.
Both Claude and Codex reference these before providing any commands.

## How Skills Work

- One skill file per project (written before the project begins)
- Covers all phases: device reference, exact commands, expected outputs, rollbacks, concept mapping
- Available locally as Claude slash commands: `/winserver`, `/winserver-p01`, etc.
- Copied to all four locations: `.agents/skills/`, `.codex/skills/`, `.claude/commands/`, GitHub repo

## Available Skills

| Skill | Project | Slash command | Status |
|-------|---------|--------------|--------|
| [windows-server-business-admin](windows-server-business-admin.md) | Full family overview | `/winserver` | ✅ Ready |
| project-01-server-hardening | Server Baseline + Hardening | `/winserver-p01` | ⬜ Written when P01 starts |
| project-12-m365-hybrid-identity | Microsoft 365 + Entra | `/winserver-p12` | ⬜ Written when P12 starts |
| project-13-identity-integration | Enterprise Identity Capstone | `/winserver-p13` | ⬜ Written when P13 starts |
