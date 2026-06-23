# Handoff — Project 01, resuming at Phase 4, manual GUI mode

**Date:** 2026-06-22
**From:** Claude (this session ends here)
**For:** a new session (Claude or Codex) picking this up cold

Read this whole file before doing anything. It has full context, current live state,
and exactly where we stopped.

---

## 0. What changed for this handoff

Leonel wants to **stop running PowerShell commands pasted from chat** and instead do
the rest of Project 01 (Phases 4–7) **manually through the Windows GUI** — Server
Manager, IIS Manager, NPS console, Event Viewer, ADUC, GPMC, Windows Firewall with
Advanced Security. Every phase reference file already has a **Track A (GUI steps)**
section written for exactly this — use those, not the PowerShell Track B blocks,
unless Leonel asks for a specific verification command.

The working model from here: give Leonel the **GUI click-path**, he does it on the
server, reports back what he saw (and screenshots if he takes them), you verify
against the expected state described in each phase file, then move to the next step.
Only fall back to a PowerShell verification command if a GUI-only check can't
confirm the result (e.g., confirming radius-service appears in an NPS export — that's
inherently a file-search action).

---

## 1. Project guardrails (binding — read `AGENTS.md` in full, this is a summary)

- **Tier 3 (live infra) rule:** Leonel executes everything on the server. Claude
  coordinates and reviews, never executes directly (no SSH key for this server exists
  on the machine Claude is running from — confirmed during this session, only the
  homelab-management automation key exists locally, not the WIN-PRQD8TJG04M one).
- **Explicit approval before every live AD/GPO change** — state what will change, why,
  and the rollback, before Leonel does it.
- **Never delete AD objects** (OUs, users, groups, computers) — disable/move/remove-
  from-group only.
- **Never modify Default Domain Policy or Default Domain Controllers Policy** without
  explicit approval (Phase 2 already did this once, with a GPO backup first — see
  Section 3).
- **Never touch NPS/RADIUS policy, DHCP scopes, DNS zones, RDS/IIS role removal, or
  Hyper-V VMs** in this project. Those belong to Projects 13, 04, 03, 08, 08
  respectively.
- **Stop and report on any failure — do not retry blindly.** This was tested for real
  in Phase 3 (see Section 4, account creation incident) and worked as intended.
- **No secrets in chat, logs, or the repo.** NPS XML exports go in `C:\Audit\` only,
  never committed. Passwords are typed directly into GUI dialogs or masked
  `Read-Host` prompts — never pasted into chat. (A real near-miss happened this
  session — see Section 4 — handled correctly by immediate password rotation.)

---

## 2. Where things physically are

- **Repo:** `vushueh/windows-server-business-admin-labs` on GitHub, branch `main`.
- **Two local clones exist** on this machine — `C:\Projects\windows-server-business-
  admin-labs\` (used this session) and `E:\Homelab-Repos\family-projects\windows-
  server-business-admin-labs\` (the path `AGENTS.md` calls canonical). They're just
  two clones of the same GitHub repo — `git pull` in either picks up everything
  pushed this session. Pick whichever is open; no functional difference.
- **Server:** `WIN-PRQD8TJG04M`, 192.168.20.11 / Tailscale `100.81.197.116`. Already
  the live PDC for `Chongong.local` — not a fresh install.
- **Latest pushed commit:** `76628a0` — "P01 Phase 2 + Phase 3 complete."

---

## 3. Current live AD/server state (verified this session, all confirmed via PowerShell output Leonel pasted back)

| Item | State |
|---|---|
| Default Domain Policy backup | `C:\GPO-Backups\2026-06-22` (GpoId `31b2f340-016d-11d2-945f-00c04fb984f9`, backup Id `18bfe113-2d60-47ec-b044-8a931085ba17`) — rollback point if Phase 2 ever needs to be undone |
| Password policy | `MinPasswordLength=14`, `MaxPasswordAge=90d`, `LockoutThreshold=5`, `LockoutDuration=30min`, `LockoutObservationWindow=30min`, `PasswordHistoryCount=24` (unchanged), `ComplexityEnabled=True` (unchanged) |
| `_Admin` OU | Created with 4 sub-OUs: `Tier0-DomainAdmins`, `Tier1-ServerAdmins`, `Tier2-WorkstationAdmins`, `ServiceAccounts` |
| `adm-leonel` | Tier 0 account, in `Tier0-DomainAdmins` OU, member of `GG-Tier0-Admins` + `Domain Admins`, **Enabled=True**, governed by `PSO-Tier0-Admins` (confirmed via `Get-ADUserResultantPasswordPolicy`) |
| `srv-leonel` | Tier 1 account, in `Tier1-ServerAdmins` OU, member of **only** `Domain Users` + `GG-ServerAdmins` (confirmed no built-in groups), **Enabled=True** |
| `GG-Tier0-Admins`, `GG-ServerAdmins` | Created, correct membership |
| `PSO-Tier0-Admins` | Precedence 10, min 20 chars, lockout threshold 3, 60-min duration/window, applies to `GG-Tier0-Admins` |
| **`Domain Admins` group** | **Just cleaned up this session.** Was 12 members (massive over-provisioning, not caught in the original Phase 1 audit). Now exactly 3: `Administrator`, `adm-leonel`, `chongong.leonel`. The other 9 personal accounts + `testuser` were removed from the group only — **no accounts were deleted**, they still exist and work normally outside Domain Admins. |
| `testuser` | No longer a Domain Admin (was, until this session — removed along with the others). Still enabled, not yet touched otherwise. Phase 6 will lock it out, then disable + quarantine it. |
| Quarantine OU | Does not exist yet — Phase 6 creates it. |

**Important design note for whoever does Phase 4 onward:** the original P01 plan
assumed `chongong.leonel` (Leonel's day-to-day account) would also be removed from
Domain Admins, since the point of `adm-leonel` is to separate everyday login from
admin actions. Leonel made an **explicit, informed decision** to keep
`chongong.leonel` as a Domain Admin too. Don't "fix" this by removing it again —
that was a deliberate choice, not an oversight. It's documented in
`docs/p01-phase3-evidence.md`.

---

## 4. Notable incidents this session (both fully resolved, included for context)

**Account creation quirk:** `New-ADUser -AccountPassword ... -Enabled $true` failed
both times with `ADPasswordComplexityException` on the simultaneous enable step,
even though the password attribute was actually written (`PasswordLastSet` was
populated). Root cause: a separate enable-time complexity re-check failing
independently of the password-set step. Resolved by splitting into
`Set-ADAccountPassword -Reset` (interactive masked prompt) followed by a standalone
`Enable-ADAccount`. Worth knowing if Phase 4+ involves any more account creation —
prefer the GUI "Reset Password" dialog in ADUC instead, which doesn't have this
quirk (this is actually part of why Leonel wants to switch to GUI-only from here).

**Password exposure near-miss:** during one retry, a password got pasted directly
onto the command line instead of into a masked `Read-Host` prompt, so it appeared in
plaintext in the terminal and in the chat transcript. Handled correctly in the
moment: flagged immediately, both potentially-affected passwords (`adm-leonel` and
`srv-leonel`) were reset again via properly masked prompts before continuing. No
plaintext credential exists in the repo. This is exactly the kind of mistake GUI-only
work (Reset Password dialog) avoids — reinforces why Leonel's ask to switch to manual
GUI mode for the rest of the project is reasonable.

**Unplanned critical finding:** see Domain Admins over-provisioning in Section 3 —
discovered mid-Phase-3, not part of the original Phase 1 audit scope, remediated with
Leonel's explicit approval mid-session.

---

## 5. Where we stopped — Phase 4, not yet started

**Phase 4 (RDS/IIS/NPS Risk Assessment — document only, zero live changes)** was
about to begin when Leonel asked to switch to manual/GUI mode. **No Phase 4 commands
have been run yet.** Read `skills/p01-references/phase-4-rds-iis-risk.md` in full —
it already has the complete GUI Track A steps:

1. **Server Manager → Remote Desktop Services → Overview** — screenshot the
   deployment topology; **Collections** — note collection names.
2. **ADUC → Groups OU → RDS-Users → Members tab** — screenshot.
3. **IIS Manager → WIN-PRQD8TJG04M → Sites** — note all sites/bindings;
   **Application Pools** — note identity type per pool.
4. **Network Policy Server (`nps.msc`) → Policies → Network Policies** — screenshot
   list; **Connection Request Policies** — screenshot; click each policy →
   **Conditions** tab, note if `radius-service` appears; **RADIUS Clients and
   Servers → RADIUS Clients** — screenshot.
   **Do NOT export NPS config to a file that gets committed to GitHub** — if an
   export is needed, it goes in `C:\Audit\` only, per the existing pattern.
5. **ADUC → find `__vmware__` group** → double-click → note Description, Members,
   ManagedBy.

**This phase makes zero changes** — pure documentation. Write findings into
`projects/project-01-server-baseline-hardening/docs/p01-rds-iis-risk-assessment.md`
(create it; doesn't exist yet). Use the template in `phase-4-rds-iis-risk.md`'s "Risk
Assessment" section.

---

## 6. Remaining phases after Phase 4

All have full GUI Track A steps already written — read each file before starting
that phase:

- **Phase 5** — `skills/p01-references/phase-5-firewall-baseline.md`. Document
  TCP/UDP listeners (GUI: Windows Firewall with Advanced Security), restrict RDP
  inbound rule to **one specific Tailscale management IP** (never the broad
  `100.64.0.0/10` range — get the exact IP via `tailscale ip -4` on the management
  machine). **Do not set `DefaultInboundAction=Block`** — deferred to Project 05.
- **Phase 6** — `skills/p01-references/phase-6-lockout-breakfix.md`. Prove the Phase 2
  lockout policy works: reset `testuser`'s password (ADUC GUI), trigger 5 failed
  logon attempts (validate Event 4625/Logon Type 3 with **one** attempt first before
  the full loop), observe lockout in ADUC + Event Viewer (Event 4740), unlock,
  disable, move to a new **Quarantine** OU. `testuser` is no longer a Domain Admin
  (already fixed this session), so this exercise is lower-risk than originally
  scoped.
- **Phase 7** — `skills/p01-references/phase-7-document-push.md`. Final screenshot
  pass, final PowerShell state capture (or GUI-equivalent verification), confirm NPS
  XML was never committed, update the parent skill/README to mark P01 ✅, update
  `CODEX-LOG.md`, push to GitHub.

---

## 7. Task tracking

A task list exists in this session (TaskCreate/TaskUpdate) with 6 tasks:
`#1 Phase 2` (completed), `#2 Phase 3` (completed), `#3 Phase 4` (in_progress, not yet
started), `#4 Phase 5`, `#5 Phase 6`, `#6 Phase 7` (all pending). That task list is
session-local and won't carry over — recreate it if useful, or just track progress
directly in the docs/checklists each phase file already has.
