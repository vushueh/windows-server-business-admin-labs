# Project 01 — Server Baseline, Hardening, and Admin Model

**Status:** 🔄 In Progress
**Skill:** `/winserver-p01` — [skills/project-01-server-baseline-hardening.md](../../skills/project-01-server-baseline-hardening.md)

## Actual Server State (Discovered 2026-06-05)

This is NOT a clean install. Live SSH audit of WIN-PRQD8TJG04M revealed:

- **DomainRole: 5** — already promoted as Primary Domain Controller for `Chongong.local`
- **Installed roles:** AD DS, DHCP, DNS, NPS/RADIUS, File Server, Hyper-V (13 VMs),
  RDS full farm, IIS, GPMC, RSAT, BitLocker, Containers, WSL
- **AD users:** 10 real users + testuser (enabled, undocumented) + radius-service
- **Computers joined:** WIN-PRQD8TJG04M, RADIUS01, GITEA, 5× DESKTOP machines
- **GPOs:** Only Default Domain Policy + Default Domain Controllers Policy (no custom GPOs)

## Critical Security Gaps Found

| Gap | Severity |
|-----|----------|
| LockoutThreshold = 0 | 🔴 CRITICAL — no account lockout |
| MinPasswordLength = 7 | 🔴 HIGH — too weak |
| RDS full farm on DC | 🟠 HIGH — privilege escalation path |
| IIS on DC | 🟠 HIGH — web exploit = domain exploit |
| No tiered admin accounts | 🟠 HIGH — all admin via builtin Administrator |
| DefaultInboundAction = NotConfigured | 🟡 MEDIUM — firewall not blocking by default |
| No custom GPOs | 🟡 MEDIUM — only defaults exist |

## Objective

Audit, document, harden, and formalize the existing AD environment.
Establish the secure admin model that all future projects depend on.

**Why first:** Everything else — DNS, Hyper-V, NPS, M365 — assumes this foundation is
documented, hardened, and cleanly administered.

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Audit Documentation | Document all roles, users, policy, firewall as-found |
| 2 | Fix Password Policy + Lockout | LockoutThreshold→5, MinLength→14, GPO backup first |
| 3 | Tiered Admin Model | adm-leonel (Tier0 DA), srv-leonel (Tier1), PSO for Tier0 |
| 4 | Assess RDS/IIS on DC | Document risk, no changes — migration in Project 08 |
| 5 | Firewall Baseline | Port inventory, RDP restricted to Tailscale |
| 6 | Break/Fix Lockout Exercise | testuser lockout confirmed, then quarantined |
| 7 | Document + Push | All scripts saved, GitHub push, mark P01 complete |

## STAR Summary

**Situation:** Server is an existing production-like PDC with critical security gaps —
no account lockout, weak passwords, no tiered admin model, RDS+IIS co-located on the DC.

**Task:** Audit the as-found state, fix critical security gaps, and establish the admin
model before any other project builds on top of this server.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
