---
name: winserver-evidence-documentation
description: >
  Windows Server Business Admin documentation standard. Trigger whenever creating,
  rewriting, reviewing, or updating project README files, evidence docs, screenshots,
  scripts, phase completion notes, portfolio summaries, status tables, or final
  project documentation for P01-P13. Enforces layered documentation: readable public
  summary first, technical evidence behind links, no secrets, and consistent status.
---

# Windows Server Documentation Standard

Use this skill whenever documenting any Windows Server Business Admin project.
The goal is a portfolio that a hiring manager can understand quickly, while still
giving technical reviewers proof of the exact configuration.

## Core Rule

Do not turn the project README into a command transcript.

The README is the public-facing project story. Detailed commands, raw output,
screenshots, rollback notes, and troubleshooting evidence belong in linked files
under the project folder.

## Required Read Order

Before editing documentation, read:

1. `AGENTS.md`
2. The project `README.md`
3. Existing files under that project's `docs/`, `scripts/`, and `screenshots/`
4. The relevant technical project skill
5. This skill

## Layered Documentation Model

Every project has three layers:

| Layer | Audience | Where it lives | Purpose |
|-------|----------|----------------|---------|
| Public summary | Hiring manager, recruiter, non-technical reader | Project `README.md` | What I built, why it matters, what changed, proof links |
| Technical evidence | Engineer, architect, future me | `docs/*.md`, `scripts/`, `screenshots/` | Exact commands, output, screenshots, verification, rollback |
| Operator handoff | Claude/Codex/Leonel | `CODEX-LOG.md`, `CLAUDE-REVIEW.md`, phase skills | What to do next, blockers, safety notes |

## Project README Standard

Keep project READMEs direct. Target 70-130 lines unless the project truly needs
more. Use first-person portfolio language for completed work.

Required section order:

1. Title, status, completion date if complete, system or scope
2. Short plain-language summary that includes why it matters
3. Starting point or problem found
4. What I changed
5. What I proved
6. Evidence links
7. Decisions intentionally deferred or not changed
8. Next project impact or carried-forward items
9. Portfolio STAR summary

Allowed in the README:

- Short tables
- 1-3 screenshots, each in its own evidence block
- Links to technical evidence
- Short command names when they clarify verification

Do not put these in the README:

- Long PowerShell blocks
- Full terminal output
- Step-by-step GUI click transcripts
- Stacked screenshots with no explanation
- Every screenshot from the project unless each one has a reason
- Raw troubleshooting logs
- Secrets, tokens, passwords, private keys, shared secrets, or NPS XML exports

## Evidence File Standard

Use evidence files for technical depth. A good evidence file includes:

1. Objective
2. Date and method
3. Approval or safety gate if live infrastructure changed
4. Before state
5. Commands or GUI path used
6. Output or screenshot proof
7. Verification result
8. Rollback or recovery path
9. Findings carried forward

Evidence files may include long command blocks and command output, but keep them
organized by phase and redact sensitive data.

## Screenshot Standard

Screenshots must prove something. Do not add screenshots just to make the repo look
busy.

Good screenshots show:

- Before and after state
- A policy value
- A membership list
- A service/tool status
- A verified error or break/fix result

Naming pattern:

```text
phaseN-NN-short-description.jpg
```

## Screenshot Upload Workflow

Use this workflow every time Leonel provides screenshots for a Windows project.

1. Save screenshots under the project folder:

```text
projects/project-NN-project-name/screenshots/
```

2. Rename each screenshot with the phase-based pattern:

```text
phaseN-NN-short-description.png
phaseN-NN-short-description.jpg
```

Examples:

```text
phase2-01-password-lockout-policy.png
phase4-02-sample-agdlp-nesting.png
phase9-01-final-verification-output.png
```

3. Check every image before committing:

- no passwords
- no private keys
- no recovery keys
- no shared secrets
- no unredacted credential fields
- no unrelated personal files, browser tabs, or notifications

4. Link screenshots with relative Markdown paths only:

```markdown
![short alt text](screenshots/phaseN-NN-short-description.png)
```

5. Do not upload screenshots to external image hosts for repo documentation.
Commit the reviewed image files into the repo with the README/evidence update.

6. If a project needs many screenshots, create or update a project-specific
screenshot plan:

```text
projects/project-NN-project-name/docs/pNN-screenshot-plan.md
```

That plan must list each screenshot filename, what it proves, where Leonel
captures it manually, and the PowerShell command that proves the same result.

For the README, preview only the strongest screenshots. Link the full screenshot
folder for technical reviewers.

Every screenshot shown in a README must use this block:

````markdown
### Short Evidence Title

![short alt text](screenshots/file.jpg)

- **What it shows:** One direct sentence.
- **Manual check:** GUI path Leonel used.
- **Why:** Why this configuration or finding matters.
- **PowerShell equivalent:**

```powershell
# PowerShell command that proves the same point
```
````

Do not group several images together and explain them later. Image, description,
manual path, PowerShell equivalent, and reason must stay together.

## No-Secrets Policy

Never commit:

- Passwords or generated passwords
- Password hashes
- Private keys
- Microsoft 365 or Entra credentials
- RADIUS shared secrets
- NPS XML exports
- BitLocker recovery keys
- Screenshots showing unredacted credential fields
- Any `C:\Audit` export marked sensitive

Safe to commit when reviewed:

- Redacted command output
- AD object summaries without passwords
- Screenshots of settings with credential fields hidden
- Scripts without embedded secrets
- Markdown evidence summaries

## Status Consistency

When a project status changes, update all relevant places in the same commit:

- Root `README.md`
- `projects/README.md`
- Project `README.md`
- Relevant project skill checklist
- `AGENTS.md` current status if it mentions the project
- `CODEX-LOG.md` session note

Do not leave one file saying "In Progress" while the final evidence says
"Complete."

## Voice and Attribution

Use first person for portfolio work:

- "I audited..."
- "I configured..."
- "I verified..."
- "I deferred..."

Use tool/operator names only where they matter:

- Approval source
- Who executed a live command
- Handoff notes
- Safety gate history

Avoid making the public README read like a Claude/Codex transcript.

## Final Review Checklist

Before committing documentation:

- README can be understood without opening a technical evidence file
- Technical readers have clear links to exact proof
- No secrets or sensitive exports are present
- Status matches across indexes and skills
- Deferred risks point to the correct future project
- Markdown links are relative and valid
- The README does not duplicate entire evidence files
