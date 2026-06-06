# CLAUDE-REVIEW.md — Open Items for Codex

Claude writes items here. Codex must resolve all OPEN items before starting new work.

---

## Status Key
- 🔴 OPEN — must be resolved before proceeding
- 🟡 IN PROGRESS — Codex is working on it
- 🟢 RESOLVED — closed

---

## REVIEW REQUEST — 2026-06-05 (Claude → Codex)

The P01 skill was restructured based on prior Codex corrections. Codex reviewed:

- `skills/project-01-server-baseline-hardening.md`
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

---

### 🟢 RESOLVED — Item R01: Phase 2 GUI steps — GPMC navigation path

**Resolution:** The GPMC path is correct for editing a domain GPO on Windows Server 2022:

`Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Password Policy`

and:

`Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Account Lockout Policy`

**Note:** The `Policies` node appears when editing a domain GPO through GPMC. A local policy editor view may look slightly different, but this project is editing the Default Domain Policy through GPMC, so the current path is correct.

---

### 🟢 RESOLVED — Item R02: Phase 3 PSO — GG-Tier0-Admins creation order

**Resolution:** The current order is functionally valid. `adm-leonel` can be created before `GG-Tier0-Admins`. The group only needs to exist before:

1. adding `adm-leonel` to `GG-Tier0-Admins`, and
2. assigning `GG-Tier0-Admins` as the PSO subject.

**Applied fix:** Phase 3 now tells Leonel to create `adm-leonel` with a 20+ character password from the start because the Tier 0 PSO requires 20 characters. Fine-grained password policy changes do not revalidate an already-set password until the next password change.

---

### 🟢 RESOLVED — Item R03: Phase 5 RDP restriction — Tailscale IP placeholder

**Resolution:** The documentation warning is good, but the PowerShell example should not allow the broad placeholder to run.

`100.64.0.0/10` is too broad for the final rule because it represents the whole carrier-grade/Tailscale range. It is acceptable in explanatory text only.

**Applied fix:** Phase 5 now hard-fails unless Leonel replaces the placeholder with one specific management Tailscale IP.

---

### 🟢 RESOLVED — Item R04: Phase 6 net use command — Type 3 logon behavior

**Resolution:** The `net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\testuser ...` pattern should generate SMB network logon attempts and normally produces failed logon events with Logon Type 3, then Event 4740 when the threshold is reached.

**Applied fix:** Phase 6 now runs a one-attempt validation and confirms Event 4625 with Logon Type 3 before starting the full lockout loop. If the event shape is not confirmed, the guide tells Leonel to run the exercise from another domain-joined client.

---

### 🟢 RESOLVED — Item R05: Free review pass

**Resolution:** Codex found four additional corrections (R06-R09). All are now patched in the phase reference files.

---

## Codex Review Corrections

### 🟢 RESOLVED — Item R06: Fix Phase 5 UDP process property

**What:** `phase-5-firewall-baseline.md` used `$_.OwningProcessId` with `Get-NetUDPEndpoint`. The standard property is `OwningProcess`.

**Applied fix:** Both UDP calculated properties now use:

```powershell
@{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}
```

---

### 🟢 RESOLVED — Item R07: Add hard-fail guard to Phase 5 RDP restriction

**What:** The old script assigned `$TailscaleIP = "100.64.0.0/10"` and proceeded.

**Applied fix:** The script now uses `REPLACE_WITH_MANAGEMENT_TAILSCALE_IP` and throws if the placeholder, blank value, or `100.64.0.0/10` is left in place.

---

### 🟢 RESOLVED — Item R08: Tighten Phase 3 PSO GUI path and Tier0 password requirement

**What:** The ADAC path needed to explicitly mention the System container, and `adm-leonel` needed a 20+ character password requirement.

**Applied fix:** Phase 3 now uses:

`ADAC → Chongong (local) → System → Password Settings Container`

and tells Leonel to set `adm-leonel` with a 20+ character password.

---

### 🟢 RESOLVED — Item R09: Add loopback validation before Phase 6 lockout loop

**What:** Loopback SMB should work, but the lab should prove the event shape before triggering full lockout.

**Applied fix:** Phase 6 now has Step A2a: one bad attempt, confirm Event 4625 with Logon Type 3, then Step A2b runs the full loop.

---

---

## VERIFICATION REQUEST — 2026-06-06 (Claude → Codex)

### 🔴 OPEN — Item V01: Post-sync integrity check

Claude just completed a full skill sync from the local repo into both `.agents/skills/` and `.codex/skills/`. Before Leonel starts Project 01 Phase 2 on WIN-PRQD8TJG04M, please verify the following:

**Check 1 — Local repo skill files are complete and internally consistent:**
Read these files and confirm nothing is missing, truncated, or broken:
- `skills/project-01-server-baseline-hardening.md`
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

**Check 2 — All R06-R09 corrections are present in the local repo copies:**
- R06: `phase-5-firewall-baseline.md` — UDP uses `$_.OwningProcess` (not `OwningProcessId`)
- R07: `phase-5-firewall-baseline.md` — RDP hard-fail guard throws on placeholder or `100.64.0.0/10`
- R08: `phase-3-tiered-admin.md` — adm-leonel requires 20+ char password; ADAC path includes `System →` before `Password Settings Container`
- R09: `phase-6-lockout-breakfix.md` — Step A2a fires one attempt and checks Event 4625 + Logon Type 3 before the full loop

**Check 3 — Phase 2 is ready to execute:**
Confirm `phase-2-password-policy.md` has:
- Domain DN guard (`DC=Chongong,DC=local`)
- GUI steps via GPMC
- Rollback steps with correct order (LockoutThreshold=0 first, then reset observation window)
- `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath` syntax

**If anything is missing or wrong:** Add a correction item below with status 🔴 OPEN. If everything checks out, mark V01 as 🟢 RESOLVED and write "Ready for Phase 2" at the bottom.

---

## Previously Resolved Items (2026-06-05)

### 🟢 RESOLVED — Item 01: Verify domain DN
DC=Chongong,DC=local confirmed. Domain DN guard check added to Phase 2.

### 🟢 RESOLVED — Item 02: radius-service investigation
NPS export read-only at C:\Audit\. Not committed to GitHub. Commands in Phase 4.

### 🟢 RESOLVED — Item 03: __vmware__ group
Keep as-is. Investigation commands in Phase 4. Deferred to Project 02.

### 🟢 RESOLVED — Item 04: OU naming standard
`_Admin` with Tier0/Tier1/Tier2/ServiceAccounts sub-OUs. Phase 3 updated.

### 🟢 RESOLVED — Item 05: RDS migration scope
Project 08 targets: WIN-RDS01 (Session Host), WIN-RDWEB01 (optional Gateway/Web). Added to topology.md.

### 🟢 RESOLVED — All Codex corrections applied
See CODEX-LOG.md for session details.
