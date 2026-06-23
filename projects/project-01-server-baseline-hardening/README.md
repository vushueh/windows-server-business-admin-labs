# Project 01 - Server Baseline, Hardening, and Admin Model

| Field | Value |
|-------|-------|
| Status | Complete |
| Completed | 2026-06-23 |
| System | `WIN-PRQD8TJG04M` - live Primary Domain Controller for `Chongong.local` |
| Goal | Secure and document the existing Windows Server foundation before building later projects. |

## Summary

I audited the live Domain Controller, fixed the critical identity gaps, documented risky services, and left larger migrations for the right future projects.

## Starting Problems

| Area | Finding |
|------|---------|
| Passwords | Minimum length was 7 |
| Lockout | Account lockout was disabled |
| Domain Admins | Too many users had Domain Admin rights |
| Admin model | No clean Tier 0 / Tier 1 separation |
| RDS/IIS | Both were running on the Domain Controller |
| Firewall | Remote-access and listener exposure needed review |

## What Changed

| Area | Result | Proof |
|------|--------|-------|
| Password policy | Minimum length now 14 | [Phase 2](docs/p01-phase2-evidence.md) |
| Account lockout | 5 bad attempts, 30-minute lockout | [Phase 2](docs/p01-phase2-evidence.md) |
| Admin model | `_Admin` OU, `adm-leonel`, `srv-leonel`, Tier 0 PSO | [Phase 3](docs/p01-phase3-evidence.md) |
| Domain Admins | Reduced from 12 to 3 approved members | [Phase 3](docs/p01-phase3-evidence.md) |
| RDS/IIS/NPS | Documented only, no roles removed | [Risk assessment](docs/p01-rds-iis-risk-assessment.md) |
| Firewall | TCP/UDP listeners and firewall profile state documented | [Firewall baseline](docs/p01-phase5-firewall-baseline.md) |
| `testuser` | Lockout tested, then account disabled and quarantined | [Break/fix](docs/p01-phase6-lockout-breakfix.md) |

## Verified State

| Check | Result |
|-------|--------|
| Password policy | `MinPasswordLength=14`, `LockoutThreshold=5` |
| Tier 0 | `adm-leonel` has the Tier 0 password policy |
| Tier 1 | `srv-leonel` is not in built-in admin groups |
| Lockout test | `testuser` locked on the 5th failed attempt |
| Quarantine | `testuser` is disabled in `OU=Quarantine` |
| NPS | Installed and listening, no custom RADIUS clients yet |

Full state: [p01-verified-final-state.md](docs/p01-verified-final-state.md)

## Visual Evidence

Each image is separated so the reader knows what the screenshot proves.

### RDS Broker Issue

![RDS overview showing broker issue](screenshots/phase4-01-rds-overview-broker-error.jpg)

- **What it shows:** Server Manager could not reach the RD Connection Broker cleanly.
- **Manual check:** Server Manager -> Remote Desktop Services -> Overview.
- **Why:** RDS needs to move off the Domain Controller in Project 08 instead of being patched randomly in P01.
- **PowerShell equivalent:**

```powershell
Get-Service -Name Tssdis,RDMS -ErrorAction SilentlyContinue
Get-NetTCPConnection -State Listen | Where-Object {$_.LocalPort -eq 51175}
```

### IIS Application Pools

![IIS application pools](screenshots/phase4-04-iis-application-pools.jpg)

- **What it shows:** IIS application pools were running on the Domain Controller.
- **Manual check:** IIS Manager -> server name -> Application Pools.
- **Why:** IIS is tied to RDS Web Access and should migrate with RDS in Project 08.
- **PowerShell equivalent:**

```powershell
Import-Module WebAdministration
Get-ChildItem IIS:\AppPools |
    Select-Object Name, State, @{Name='Identity';Expression={$_.processModel.identityType}}
```

### Windows Firewall Profiles

![Windows Firewall overview](screenshots/phase5-01-wfas-overview.jpg)

- **What it shows:** Windows Firewall profiles were enabled, but inbound default behavior was not hardened yet.
- **Manual check:** Windows Firewall with Advanced Security -> root overview page.
- **Why:** Firewall default-block needs a full AD allowlist GPO first, so it belongs in Project 05.
- **PowerShell equivalent:**

```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```

Full screenshots: [screenshots/](screenshots/)

## Deferred On Purpose

| Item | Reason | Future owner |
|------|--------|--------------|
| RDS/IIS migration | Too risky to remove from the live DC during baseline hardening | Project 08 |
| RDP/Tailscale scope | Left unchanged by explicit instruction | Project 05 or remote-access review |
| VNC exposure | Flagged, not removed | Leonel decision |
| NPS/RADIUS policies | No clients configured yet | Project 13 |
| Failed-logon audit gap | 4740 worked, but 4625/4776/4771 need audit policy work | Project 05 / SOC |
| `__vmware__` group | VMware-related artifact, left untouched | Project 02 |

## Technical Links

| Detail | Link |
|--------|------|
| Password and lockout | [docs/p01-phase2-evidence.md](docs/p01-phase2-evidence.md) |
| Admin model | [docs/p01-phase3-evidence.md](docs/p01-phase3-evidence.md) |
| RDS/IIS/NPS | [docs/p01-rds-iis-risk-assessment.md](docs/p01-rds-iis-risk-assessment.md) |
| Firewall | [docs/p01-phase5-firewall-baseline.md](docs/p01-phase5-firewall-baseline.md) |
| Lockout break/fix | [docs/p01-phase6-lockout-breakfix.md](docs/p01-phase6-lockout-breakfix.md) |
| Final state | [docs/p01-verified-final-state.md](docs/p01-verified-final-state.md) |
| Scripts | [scripts/](scripts/) |

## Portfolio Summary

**Situation:** The Domain Controller had weak account policy, too many Domain Admins, and undocumented services.

**Task:** Secure the foundation without breaking the live Windows environment.

**Action:** I backed up policy, hardened passwords and lockout, built tiered admin accounts, cleaned Domain Admins, documented RDS/IIS/NPS, captured the firewall baseline, and tested lockout with `testuser`.

**Result:** Project 01 is complete. The Windows identity foundation is safer, verified, and ready for Project 02.
