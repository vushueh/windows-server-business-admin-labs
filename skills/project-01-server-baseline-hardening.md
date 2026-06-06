---
name: winserver-p01
description: >
  Windows Server Project 01 — Server Baseline Audit, Hardening, and Tiered Admin Model.
  Trigger: "windows server p01", "server baseline", "AD hardening", "start phase".
  WIN-PRQD8TJG04M is already the live PDC for Chongong.local — NOT a clean install.
  Every phase has a GUI track (screenshots) and a PowerShell track (verification).
  Read the relevant p01-references/ file at the start of each phase session.
---

# Windows Server Project 01 — Server Baseline + Hardening

**Repo:** https://github.com/vushueh/windows-server-business-admin-labs
**SSH:** `ssh -i "$env:USERPROFILE\.ssh\claude_winserver_2022_ed25519" Administrator@100.81.197.116`

---

## Pre-Flight: Confirmed Server State (Audit: 2026-06-05)

WIN-PRQD8TJG04M IS the live PDC. There is no separate "future WIN-DC01" — this machine runs everything.

| Component | Fact |
|-----------|------|
| Hostname | WIN-PRQD8TJG04M |
| Role | Primary Domain Controller (DomainRole=5) |
| Domain | Chongong.local / CHONGONG / Windows2016Domain |
| Tailscale | 100.81.197.116 |
| LAN IP | 192.168.20.11 |
| Installed roles | AD DS, DHCP, DNS, NPS, File Server, Hyper-V (13 VMs), RDS full farm, IIS |
| AD users | 10 real users + testuser (enabled) + radius-service |
| Computers joined | RADIUS01, GITEA, 5× DESKTOP machines |
| GPOs | Default Domain Policy + Default Domain Controllers Policy only |

**Critical gaps found:**
| Gap | Severity |
|-----|----------|
| LockoutThreshold = 0 | 🔴 CRITICAL |
| MinPasswordLength = 7 | 🔴 HIGH |
| No tiered admin accounts | 🟠 HIGH |
| RDS + IIS on DC | 🟠 HIGH |
| No custom GPOs | 🟡 MEDIUM |
| DefaultInboundAction = NotConfigured | 🟡 MEDIUM |

---

## Phase Map

| # | Phase | Goal | Reference File |
|---|-------|------|----------------|
| 1 | Audit Documentation | Record as-found state | *(completed — data above)* |
| 2 | Password Policy + Lockout | Fix LockoutThreshold=0, MinLength=14 | [phase-2-password-policy.md](p01-references/phase-2-password-policy.md) |
| 3 | Tiered Admin Model | _Admin OU, adm-leonel (Tier0), srv-leonel (Tier1) | [phase-3-tiered-admin.md](p01-references/phase-3-tiered-admin.md) |
| 4 | Assess RDS/IIS on DC | Document risk, NPS audit — do NOT remove | [phase-4-rds-iis-risk.md](p01-references/phase-4-rds-iis-risk.md) |
| 5 | Firewall Baseline | TCP + UDP port inventory, RDP → Tailscale | [phase-5-firewall-baseline.md](p01-references/phase-5-firewall-baseline.md) |
| 6 | Break/Fix Lockout | Exercise + testuser quarantine | [phase-6-lockout-breakfix.md](p01-references/phase-6-lockout-breakfix.md) |
| 7 | Document + Push | Scripts saved, GitHub push | [phase-7-document-push.md](p01-references/phase-7-document-push.md) |

**Phase structure in every reference file:**
Goal → GUI Steps (Track A) → Screenshots to Capture → PowerShell Verification (Track B) → Rollback → Documentation Checklist

---

## AD Design for This Project

```
Chongong.local
  ├── _Admin                        ← tiered admin accounts (Phase 3)
  │   ├── Tier0-DomainAdmins       ← adm-leonel (Domain Admins)
  │   ├── Tier1-ServerAdmins       ← srv-leonel (GG-ServerAdmins — NO built-in groups)
  │   ├── Tier2-WorkstationAdmins  ← ws-leonel (Project 07)
  │   └── ServiceAccounts          ← svc-* accounts
  ├── Domain Controllers            ← existing
  ├── Management / IT / HR / Sales / Finance  ← existing flat OUs (restructure P02)
  ├── Groups                        ← existing
  └── Quarantine                    ← disabled accounts (Phase 6)
```

**Tier 1 rule:** `srv-leonel` goes into `GG-ServerAdmins` only.
Do NOT add to built-in `Server Operators` — that group has DC-level power.
Project 05 (GPO Security Baselines) grants local admin rights on member servers via GPO.

---

## Quick Reference

```powershell
# SSH to server
ssh -i "$env:USERPROFILE\.ssh\claude_winserver_2022_ed25519" Administrator@100.81.197.116

dcdiag /test:all /q                    # Domain health
netdom query fsmo                      # FSMO roles (all on WIN-PRQD8TJG04M)
Search-ADAccount -LockedOut | Select-Object SamAccountName, BadLogonCount
Unlock-ADAccount -Identity <username>
gpupdate /force                        # Local GP refresh only
Get-Service -Name IAS                  # NPS service
repadmin /showrepl                     # Replication (no partners — single DC)
```

---

## Do-Not-Touch List (This Project)

| Item | Reason | When |
|------|--------|------|
| RDS roles (all 5) | Active farm — removing breaks RDS | Project 08 |
| IIS / Web Server | Serves RDS Web Access | Project 08 |
| DHCP scope 192.168.20.0/24 | All VMs and workstations depend on it | Project 04 |
| DNS zones (Chongong.local) | Breaking DNS breaks the domain | Project 03 |
| radius-service password | Investigate NPS purpose first | Project 13 |
| Default Domain Controllers Policy | Can lock out AD completely | Project 05 |
| Hyper-V VMs | 13 running VMs | Project 08 |
| DefaultInboundAction = Block | Needs full AD port allowlist GPO first | Project 05 |
| __vmware__ group | Unknown purpose — investigate before touching | Project 02 |

---

## Project 01 Completion Checklist

- [ ] Phase 1: Audit in docs/p01-audit-baseline.md
- [ ] Phase 2: LockoutThreshold=5, MinPasswordLength=14, GPO backup saved
- [ ] Phase 3: _Admin OU + sub-OUs, adm-leonel (Tier0 DA), srv-leonel (GG-ServerAdmins only)
- [ ] Phase 3: PSO-Tier0-Admins active (precedence 10, min 20 chars, lockout 3)
- [ ] Phase 4: RDS/IIS risk assessment documented — no roles changed
- [ ] Phase 5: TCP + UDP baseline CSVs in docs/, RDP restricted to Tailscale
- [ ] Phase 6: Lockout exercise confirmed, testuser quarantined
- [ ] Phase 7: All scripts saved, docs complete, NPS XML NOT in repo, GitHub push done
- [ ] Parent skill (/winserver) marked P01 ✅
