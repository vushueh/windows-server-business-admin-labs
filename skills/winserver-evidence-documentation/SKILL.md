---
name: winserver-evidence-documentation
description: Document Windows Server Business Admin projects P01-P13 using the canonical family-projects documentation standard plus Windows-specific PowerShell, GUI, screenshot, evidence, and redaction rules. Use for project READMEs, phase evidence, screenshots, scripts, status tables, portfolio summaries, completed-project collaboration, or publication review in this repository.
---

# Windows Server Evidence Documentation

This skill extends the canonical
[`homelab-project-documentation` skill](../../../.claude/skills/homelab-project-documentation/SKILL.md).
Read that skill and the
[`Portfolio Documentation Standard`](../../../docs/readme-layered-documentation-standard.md)
first. They own the project structure, first-person voice, phase coverage,
two-screenshot limit, collaboration record, and reproduction path.

## Required Read Order

1. Closest `AGENTS.md` and `CLAUDE.md`
2. Canonical `homelab-project-documentation` skill and standard
3. Project README, `docs/`, `scripts/`, `screenshots/`, and evidence
4. Relevant Windows technical skill and review/closeout records

## Windows-Specific Layering

| Layer | Purpose |
|---|---|
| Root README | Screenshot-free family navigation and project index |
| Project README | Short first-person story, every phase, and no more than two screenshots per phase |
| `docs/`, `scripts/`, `screenshots/`, `evidence/` | Exact PowerShell, click paths, reports, screenshot 3+, troubleshooting, rollback, and re-verification |
| `CODEX-LOG.md` and `CLAUDE-REVIEW.md` | Agent handoff, review state, and unresolved items |

Do not paste long PowerShell output or raw troubleshooting into the project
README. Use descriptive links to the technical files.

## Windows Phase Detail

Keep status only in the project phase table. Write each phase breakdown as a
short first-person story without `What I did`, `How`, `Result`, `Connection`,
or `Details` labels. Weave the shortest reproducible method into the prose:

- the PowerShell cmdlet or verification command;
- the concise GUI path when Leonel used a graphical tool;
- the before/change/verify sequence when a setting changed; and
- the linked report, transcript, rollback, or evidence file.

Use comments in longer PowerShell examples and keep those examples in `docs/`
or `scripts/`. A click path may use this compact form:

```text
Start -> Windows Tools -> Group Policy Management -> <object> -> <action>
```

## Screenshot Rules

- Store reviewed images under the project's existing `screenshots/` or
  `evidence/screenshots/` layout.
- Name images `phaseN-NN-short-description.png` or `.jpg`.
- Display them with the shared HTML wrapper and `width="900"`.
- Put each image inside the phase it proves.
- Display no more than two images per phase in the project README. Put image 3+
  and long click-by-click walkthroughs in a linked details or evidence file.
- Never add a broken image link. A planned screenshot stays a text-only capture
  note until the reviewed image exists.
- Never publish passwords, recovery keys, shared secrets, private keys,
  unredacted credential fields, NPS XML exports, unrelated tabs, or
  notifications.

## Evidence File Content

Use linked evidence files for objective, absolute date, approval/safety gate,
before state, exact commands or GUI path, output, verification, rollback, and
carried-forward findings. State what each artifact proves and what it does not
prove.

## Complete-Project Check

Before a Windows project is published as Complete, confirm:

- every phase-table row has a matching short narrative and status is not
  repeated inside it;
- the technical evidence and reproduction links resolve;
- every screenshot is redaction-checked and the two-per-phase cap holds;
- default or protected objects were not changed unless exact evidence and
  approval prove otherwise; and
- `How We Worked Together` precisely records Leonel's input, Codex's work,
  Claude's work, communication, and pushback/resolution or `None.`

Do not redefine the shared documentation structure here. If this skill and the
canonical standard disagree, follow the canonical standard and flag this file
for correction.
