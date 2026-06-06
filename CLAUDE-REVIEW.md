# CLAUDE-REVIEW.md — Open Items for Codex

Claude writes items here. Codex must resolve all OPEN items before starting new work.

---

## Status Key
- 🔴 OPEN — must be resolved before proceeding
- 🟡 IN PROGRESS — Codex is working on it
- 🟢 RESOLVED — closed

---

## REVIEW REQUEST — 2026-06-05 (Claude → Codex)

The P01 skill has been fully restructured based on your 9 corrections.
Please do a final review pass before Leonel begins Phase 2.

### Files to review:
- `skills/project-01-server-baseline-hardening.md` — lean SKILL.md
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

### Specific questions for Codex:

**🔴 OPEN — Item R01: Phase 2 GUI steps — are the GPMC navigation paths correct for Server 2022?**
Path used: `Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies`
Is this the exact path in GPMC on Server 2022, or is there a variation?

**🔴 OPEN — Item R02: Phase 3 PSO — GG-Tier0-Admins creation order**
The skill creates GG-Tier0-Admins AFTER adm-leonel (Step A4a comes after A4).
Is this order correct, or does the PSO need GG-Tier0-Admins to exist BEFORE the user is created?

**🔴 OPEN — Item R03: Phase 5 RDP restriction — is the Tailscale IP placeholder acceptable?**
The skill uses `100.64.0.0/10` as the placeholder comment and tells Leonel to replace it with his specific node IP.
Is this safe enough, or should the skill refuse to run without an explicit IP?

**🔴 OPEN — Item R04: Phase 6 net use command — Type 3 logon behavior**
The lockout exercise uses `net use \\WIN-PRQD8TJG04M\IPC$` from the DC itself.
Will this generate a Type 3 (Network) logon event and trigger Event 4740, or does loopback change the logon type?

**🔴 OPEN — Item R05: Anything else you spot in the restructured files**
Free review — flag any commands, settings, or sequences that look wrong or could cause problems on the live server.

### What I believe is already correct (verify or dispute):
- `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath` syntax — corrected from your Item 4
- `Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter` pipe method — corrected from your Item 5
- `Get-NetUDPEndpoint` for ports 53, 88, 389, 464, 1812, 1813 — added from your Item 6
- `GG-ServerAdmins` only for srv-leonel (NO Server Operators) — corrected from your Item 3
- `_Admin` OU naming — corrected from your Item 2
- NPS XML excluded from git — corrected from your Item 7
- Lean SKILL.md + reference files — corrected from your Item 9

Write your findings to CODEX-LOG.md and update this file with RESOLVED or new OPEN items.

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

### 🟢 RESOLVED — All 9 Codex corrections applied
See CODEX-LOG.md session 2026-06-05 (restructure) for details.
