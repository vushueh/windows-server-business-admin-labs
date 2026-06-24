---
name: winserver-evidence-documentation
description: >
  Windows Server Business Admin documentation standard. Trigger whenever creating,
  rewriting, reviewing, or updating project README files, evidence docs, screenshots,
  scripts, phase completion notes, portfolio summaries, status tables, or final
  project documentation for P01-P13. Enforces layered documentation: readable public
  summary first, root README without screenshots, project phase evidence with
  screenshots under the matching phase, no secrets, and consistent status.
---

# Windows Server Documentation Standard

Use this skill whenever documenting any Windows Server Business Admin project.
The goal is a portfolio that a hiring manager can understand quickly, while still
giving technical reviewers proof of the exact configuration.

## Core Rule

Do not turn the project README into a command transcript.

The root/family README is the public navigation page. It must not show screenshots.
It should explain why I am building the family, what the family proves, and where
to click next.

Each individual project README is the project story. It may show screenshots, but
only under the phase they prove. Detailed raw output, rollback notes, and long
troubleshooting records still belong in linked files under the project folder.

## Required Read Order

Before editing documentation, read:

1. `AGENTS.md`
2. The project `README.md`
3. Existing files under that project's `docs/`, `scripts/`, and `screenshots/`
4. The relevant technical project skill
5. This skill

## Layered Documentation Model

Every Windows Server family/project has these layers:

| Layer | Audience | Where it lives | Purpose |
|-------|----------|----------------|---------|
| Family index | Hiring manager, recruiter, non-technical reader | Root `README.md` | First-person reason for the family, project index, and navigation links. No screenshots. |
| Project story + phase evidence | Hiring manager first, technical reviewer second | Individual project `README.md` | What I built, why it matters, phase-by-phase results, and embedded screenshot proof under each phase. |
| Technical evidence | Engineer, architect, future me | Project `docs/*.md`, `scripts/`, `screenshots/` | Exact commands, output, screenshot plans, verification, rollback, and deeper notes. |
| Operator handoff | Claude/Codex/Leonel | `CODEX-LOG.md`, `CLAUDE-REVIEW.md`, phase skills | What to do next, blockers, safety notes |

## Root README Standard

The root README is the clean front door for the whole Windows Server family.
Keep it readable and attractive, but do not embed screenshots there.

Required root README content:

1. Title, status, platform, and trigger phrase
2. First-person introduction explaining why I am building the family
3. Plain-language purpose: what this family proves in the homelab
4. Architecture or integration overview
5. Project index with links and status
6. Skills, docs, related families, and bridge files

Root README rules:

- No screenshots or image embeds
- No long PowerShell blocks
- No raw terminal output
- No phase-by-phase execution transcript
- Link to project folders for technical evidence
- Use first-person language where it explains motivation and portfolio value

## Individual Project README Standard

Keep each project README direct but complete. It can be longer than the root
README because it owns the phase-level evidence. Use first-person portfolio
language for completed work.

Required section order:

1. Title, status, completion date if complete, system or scope
2. Short plain-language summary that includes why it matters
3. Starting point or problem found
4. What I changed
5. What I proved
6. Simple phase/status table
7. Phase sections with explanation, commands, and screenshot evidence
8. Evidence links for deeper technical proof
9. Decisions intentionally deferred or not changed
10. Next project impact or carried-forward items
11. Portfolio STAR summary

Every phase section must include:

- Phase title and status
- Brief first-person explanation of what I did in that phase
- What was achieved and why it matters
- How I did it manually, when a GUI was used
- PowerShell command used or verification command, when applicable
- Screenshot block under that same phase once the image exists
- Screenshot-to-capture note if the image has not been taken yet

Do not add broken image links. If Leonel has not provided the screenshot yet,
write the filename, exact capture path, and PowerShell equivalent as a pending
screenshot note. After the image exists under `screenshots/`, embed it directly
under the matching phase.

Allowed in the README:

- Short tables
- Screenshots embedded under the phase they prove
- Links to technical evidence
- Short command names when they clarify verification

Do not put these in the individual project README:

- Long PowerShell blocks
- Full terminal output
- Stacked screenshots with no explanation
- Raw troubleshooting logs
- Secrets, tokens, passwords, private keys, shared secrets, or NPS XML exports

Concise click paths are allowed beside screenshots, for example:

```text
Start -> Windows Tools -> Active Directory Users and Computers -> Chongong.local -> ManagedUsers
```

Longer click-by-click walkthroughs belong in a project screenshot plan under
`docs/`.

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

Plan screenshots before configuration starts. For each phase, decide:

- whether a before screenshot is needed
- whether an after screenshot is needed
- whether one verification screenshot is enough
- the exact filename
- the exact GUI path or command Leonel will use to capture it
- the matching PowerShell proof command, if one exists

Take before screenshots before changing the system. Take after screenshots after
the change is verified. If a phase is deferred or blocked, capture one screenshot
that proves why.

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
captures it manually, when to capture it, and the PowerShell command that proves
the same result.

Never embed screenshots in the root README.

For an individual project README, place screenshot evidence under the matching
phase. A technical reviewer should be able to read Phase 2, see the Phase 2
image, and understand the before/after or verification result without searching
elsewhere.

Every screenshot shown in an individual project README must use this block:

````markdown
### Short Evidence Title

![short alt text](screenshots/file.jpg)

- **What it shows:** One direct sentence.
- **Capture timing:** Before change, after change, verification, or deferred proof.
- **Manual check:** GUI path Leonel used.
- **Why:** Why this configuration or finding matters.
- **PowerShell equivalent:**

```powershell
# PowerShell command that proves the same point
```
````

Do not group several images together and explain them later. Image, description,
capture timing, manual path, PowerShell equivalent, and reason must stay
together.

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

- Root README has no screenshots and still explains why the family exists
- Individual project README can be understood without opening a technical evidence file
- Phase screenshots sit under the phase they prove, or the phase has a clear pending screenshot note
- Technical readers have clear links to exact proof
- No secrets or sensitive exports are present
- Status matches across indexes and skills
- Deferred risks point to the correct future project
- Markdown links are relative and valid
- The README does not duplicate entire evidence files
