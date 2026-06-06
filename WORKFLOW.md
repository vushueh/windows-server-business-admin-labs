# WORKFLOW.md — How This Family Works

## Trigger Phrases

| Say this | Means |
|----------|-------|
| `windows server project` | Working in this repo (main trigger) |
| `windows admin project` | Alternative trigger |
| `AD project` | Focus on Active Directory work |
| `M365 project` | Focus on Microsoft 365 / Entra |
| `start project 01` through `start project 13` | Begin that specific project |
| `check what Codex did` | Claude reads CODEX-LOG.md and summarises |
| `check open items` | Claude lists OPEN items in CLAUDE-REVIEW.md |
| `push to github` | Claude compiles work and pushes |
| `relay request` | Codex writes relay request for Claude to execute |

---

## Project Cycle

Every project follows this 7-phase cycle:

```
1. Audit current state    (inventory, show commands, before-state capture)
2. Design target state    (OU structure, GPO design, IP plan, security model)
3. Build / configure      (apply configs step by step)
4. Security hardening     (least privilege, audit policy, firewall)
5. Verify                 (test users, commands, expected behaviour)
6. Break/Fix              (deliberate fault → diagnose → restore)
7. Document + Push        (configs, screenshots, runbooks → GitHub via Claude)
```

---

## Phase Guide Format

Every `phases/phase-N.md` contains:
- **Objective** — what this phase achieves
- **Design decisions** — WHY this approach was chosen
- **Pre-checks** — verify starting state
- **Steps** — numbered, with exact PowerShell/GUI steps tagged `[LEONEL]`, `[CLAUDE]`, or `[CODEX]`
- **Verification** — commands to confirm success + expected output
- **Security hardening** — least privilege, audit, firewall considerations
- **Break/fix** — deliberate fault for this phase
- **Rollback** — how to undo if something breaks

---

## Folder Structure Per Project

```
projects/project-NN-name/
├── README.md           ← Objective, design, skill links, phase list, STAR story
├── phases/
│   ├── phase-1-audit.md
│   ├── phase-2-design.md
│   ├── phase-3-build.md
│   ├── phase-4-harden.md
│   ├── phase-5-verify.md
│   ├── phase-6-breakfix.md
│   └── phase-7-document.md
├── configs/            ← PowerShell scripts, GPO exports, AD export
├── verification/       ← Command outputs, screenshots
└── troubleshooting/    ← Break/fix log, incident notes
```

---

## Who Does What

| Task | Owner |
|------|-------|
| All commands typed on Windows Server | Leonel |
| All Server Manager / GUI actions | Leonel |
| AD OU design + GPO structure | Codex |
| PowerShell script drafts | Codex |
| Architecture review + failure mode analysis | Codex |
| Troubleshooting logic + root cause | Codex |
| Write CODEX-LOG.md | Codex |
| Review before any AD/GPO/NPS change | Claude |
| All GitHub pushes | Claude |
| Cross-family design decisions | Claude |
| Write CLAUDE-REVIEW.md | Claude |
| Skills authoring | Claude |
| Final say on domain name and architecture | Leonel |

---

## Cross-Family Context

This family becomes the identity backbone. When working here, always consider:
- Does this AD change affect RADIUS auth for CML/physical gear? (Project 13)
- Does this DNS change break Proxmox/OPNsense name resolution?
- Does this NPS change affect network device login?
- Does this Entra change affect M365 users?

Flag cross-family impacts in CODEX-LOG.md every session.
