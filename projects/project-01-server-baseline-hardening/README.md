# Project 01 — Server Baseline, Hardening, and Admin Model

**Status:** ⬜ Planned
**Skill:** `/winserver-p01` — written when this project starts

## Objective

Document exactly what the Windows Server has, what roles are installed, how the server
is reached, what accounts exist, and what firewall rules are open.
Then establish a secure admin model before any other project builds on top.

**Why first:** Everything depends on this. AD, DNS, Hyper-V, NPS, and M365 all assume
the server foundation is documented, hardened, and cleanly administered.

## Key Deliverables

- Role and feature inventory
- Tiered admin accounts created (Tier 0 / Tier 1 / standard)
- Windows Firewall baseline configured
- Remote management (RDP, WinRM, WMI) secured and tested
- Before-state configuration exported

## STAR Summary

**Situation:** Server has unknown baseline state — roles, accounts, firewall posture undocumented.
**Task:** Audit and harden the server before building any production services on it.
**Action:** _(completed when project runs)_
**Result:** _(completed when project runs)_

## Phases

1. Audit current roles, services, accounts, firewall
2. Design admin model (account tiers, naming standard)
3. Build tiered accounts + secure remote access
4. Harden firewall and remote management
5. Verify admin model works correctly
6. Break/fix: lockout Tier 0 account, recover via Tier 1
7. Document + push to GitHub
