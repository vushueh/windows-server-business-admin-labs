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
| 5 | Firewall Baseline | Port inventory; RDP/Tailscale deliberately left unrestricted per explicit instruction |
| 6 | Break/Fix Lockout Exercise | testuser lockout confirmed, then quarantined |
| 7 | Document + Push | All scripts saved, GitHub push, mark P01 complete |

## Evidence — Screenshots

Full-resolution images in [`screenshots/`](screenshots/). Findings behind each one are
documented in [`docs/p01-rds-iis-risk-assessment.md`](docs/p01-rds-iis-risk-assessment.md)
and [`docs/p01-phase5-firewall-baseline.md`](docs/p01-phase5-firewall-baseline.md).

### Phase 4 — RDS / IIS / NPS Risk Assessment

| | |
|---|---|
| ![RDS Overview broker error](screenshots/phase4-01-rds-overview-broker-error.jpg) | ![RDS Servers pool](screenshots/phase4-02-rds-servers-pool.jpg) |
| RDS Overview — RD Connection Broker unreachable | RDS Servers pool — host Online, broker process actually listening locally |
| ![RDS-Users members](screenshots/phase4-03-rds-users-members.jpg) | ![IIS Application Pools](screenshots/phase4-04-iis-application-pools.jpg) |
| RDS-Users group — broad, cross-department membership | IIS Application Pools — all ApplicationPoolIdentity |
| ![IIS Default Web Site](screenshots/phase4-05-iis-default-web-site.jpg) | ![IIS app pool identities](screenshots/phase4-06-iis-app-pool-identities.jpg) |
| IIS Default Web Site — bindings *:80/*:443 | IIS app pool Identity column (full, unabbreviated) |
| ![NPS Policies overview](screenshots/phase4-07-nps-policies-overview.jpg) | ![NPS Connection Request Policies](screenshots/phase4-08-nps-connection-request-policies.jpg) |
| NPS Policies overview | NPS Connection Request Policies — stock default only |
| ![NPS RADIUS Clients/Servers overview](screenshots/phase4-09-nps-radius-clients-servers-overview.jpg) | ![NPS RADIUS Clients empty](screenshots/phase4-10-nps-radius-clients-empty.jpg) |
| RADIUS Clients and Servers overview | RADIUS Clients — empty list |
| ![Remote RADIUS Server Groups empty](screenshots/phase4-11-nps-remote-radius-groups-empty.jpg) | ![NPS Network Policies](screenshots/phase4-12-nps-network-policies.jpg) |
| Remote RADIUS Server Groups — empty list | Network Policies — stock default deny rules only |
| ![NPS Connection Request Policy detail](screenshots/phase4-13-nps-connection-request-policy-detail.jpg) | |
| Connection Request Policy detail — no conditions configured | |

### Phase 5 — Firewall Baseline

| | |
|---|---|
| ![WFAS overview](screenshots/phase5-01-wfas-overview.jpg) | ![WFAS inbound rules](screenshots/phase5-02-wfas-inbound-rules.jpg) |
| Windows Firewall with Advanced Security — all 3 profiles, defaults unchanged | Inbound Rules — includes explicit VNC (vnc5800/5900) and VMware Authd rules |

## STAR Summary

**Situation:** Server is an existing production-like PDC with critical security gaps —
no account lockout, weak passwords, no tiered admin model, RDS+IIS co-located on the DC.

**Task:** Audit the as-found state, fix critical security gaps, and establish the admin
model before any other project builds on top of this server.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
