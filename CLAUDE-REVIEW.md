# CLAUDE-REVIEW.md — Open Items for Codex

Claude writes items here. Codex must resolve all OPEN items before starting new work.

---

## Status Key
- 🔴 OPEN — must be resolved before proceeding
- 🟡 IN PROGRESS — Codex is working on it
- 🟢 RESOLVED — closed

---

## Phase 2–7 Pre-Phase Checklist

### 🟢 RESOLVED — Item 01: Verify domain DN
**Resolution:** `DC=Chongong,DC=local` confirmed as correct. `Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN` syntax is valid (Microsoft allows DN, DNS name, NetBIOS, GUID, or SID). Domain DN guard check added to Phase 2 pre-phase commands.
**Date:** 2026-06-05

---

### 🟢 RESOLVED — Item 02: radius-service account investigation
**Resolution:** Use `Export-NpsConfiguration` to get a read-only audit of NPS config. Search for `radius-service` using `Select-String`. Do NOT commit the NPS XML to GitHub — it may contain RADIUS shared secrets in plaintext. Commands added to Phase 4 reference file. Actual finding (present or absent in NPS policies) to be documented when Phase 4 runs.
**Date:** 2026-06-05

---

### 🟢 RESOLVED — Item 03: __vmware__ group
**Resolution:** Likely created by a VMware product (Workstation, vCenter, or Horizon). Check installed VMware services on WIN-PRQD8TJG04M before drawing conclusions. Do NOT remove — if a VMware product owns it, removal breaks AD integration. Investigation commands added to Phase 4. Deferred to Project 02 (AD Architecture) for final decision.
**Date:** 2026-06-05

---

### 🟢 RESOLVED — Item 04: OU naming standard
**Resolution:** Use `_Admin` (sorts to top of ADUC alphabetically). Sub-OU structure:
  - OU=Tier0-DomainAdmins
  - OU=Tier1-ServerAdmins
  - OU=Tier2-WorkstationAdmins
  - OU=ServiceAccounts
Existing flat department OUs (Management, IT, HR, Sales, Finance) are NOT restructured in P01 — that belongs in Project 02 (AD Architecture). Phase 3 skill updated accordingly.
**Date:** 2026-06-05

---

### 🟢 RESOLVED — Item 05: RDS migration scope
**Resolution:** Project 08 (Hyper-V Operations) target VM plan:
  - WIN-RDS01 = RD Session Host (primary migration target)
  - WIN-RDWEB01 = RD Gateway + Web Access + Connection Broker + Licensing (optional, depends on load)
  - DC retains: AD DS, DNS, DHCP, NPS only after migration
Added to docs/topology.md as Planned Migration VMs.
**Date:** 2026-06-05

---

## Additional Corrections Applied (from Codex review 2026-06-05)

### 🟢 RESOLVED — Do NOT add srv-leonel to built-in Server Operators
**Resolution:** Phase 3 skill updated. `srv-leonel` joins `GG-ServerAdmins` only (new Global group). Built-in Server Operators has DC-level power — Tier 1 must not have DC access. Project 05 (GPO Security Baselines) will grant local admin rights on member servers via GPO.

### 🟢 RESOLVED — Fix Restore-GPO rollback syntax
**Resolution:** Phase 2 rollback updated to use `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath`. Previous syntax (`-BackupGpoName`) was incorrect.

### 🟢 RESOLVED — Fix RDP firewall restriction method
**Resolution:** Phase 5 updated to use `$RdpRules | Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter -RemoteAddress $TailscaleIP` (correct pipe method). Previous method using `Set-NetFirewallRule -RemoteAddress` directly is risky.

### 🟢 RESOLVED — Add UDP listener check
**Resolution:** Phase 5 now includes `Get-NetUDPEndpoint` check for ports 53, 88, 389, 464, 1812, 1813. NPS uses UDP 1812/1813 and this was missing from the original TCP-only listener check.

### 🟢 RESOLVED — Split skill into lean SKILL.md + phase reference files
**Resolution:** winserver-p01 SKILL.md is now ~5KB lean file. Phase commands moved to `skills/p01-references/phase-N-*.md` files. Phase structure: Goal → GUI Steps (Track A) → Screenshots to Capture → PowerShell Verification (Track B) → Rollback → Documentation Checklist.

### 🟢 RESOLVED — Add GUI / screenshot track to every phase
**Resolution:** Every phase reference file now has Track A (GUI steps with exact console, navigation, screenshots to capture) and Track B (PowerShell verification). This supports portfolio evidence and real hands-on practice with Server Manager, ADUC, ADAC, GPMC, NPS, IIS Manager, WFAS, and Event Viewer.

---

*Next items will appear here when Phase 2 work begins.*
