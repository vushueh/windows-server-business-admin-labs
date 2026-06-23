# Project 01 — Phase 7: Verified Final State

**Date:** 2026-06-23
**Method:** Read-only PowerShell verification via SSH (`winserver01`), confirming the
end state of every prior phase. No changes made in this step.

---

## Password Policy (Phase 2)

| Setting | Value |
|---|---|
| MinPasswordLength | 14 |
| LockoutThreshold | 5 |
| LockoutDuration | 30 minutes |
| MaxPasswordAge | 90 days |
| PasswordHistoryCount | 24 |

## Tiered Admin Model (Phase 3)

| Account | Enabled | DistinguishedName |
|---|---|---|
| adm-leonel | True | `CN=adm-leonel,OU=Tier0-DomainAdmins,OU=_Admin,DC=Chongong,DC=local` |
| srv-leonel | True | `CN=srv-leonel,OU=Tier1-ServerAdmins,OU=_Admin,DC=Chongong,DC=local` |

**PSO-Tier0-Admins:** Precedence 10, MinPasswordLength 20, confirmed as the
resultant password policy for `adm-leonel` via `Get-ADUserResultantPasswordPolicy`.

**Domain Admins membership (cleaned up in Phase 3):** exactly 3 members —
`Administrator`, `chongong.leonel` (kept by Leonel's explicit, deliberate decision —
see Phase 3 evidence), `adm-leonel`. Down from the original 12.

## RDS/IIS/NPS Risk Assessment (Phase 4)

Documented only, zero live changes. See `p01-rds-iis-risk-assessment.md`. Key
findings: RD Connection Broker unreachable via Server Manager despite the broker
process listening locally (deferred to Project 08); IIS exists solely for RD Web
Access/RPC; NPS has zero custom configuration; `__vmware__` confirmed as an empty,
unmanaged VMware Workstation artifact.

## Firewall Baseline (Phase 5)

| Profile | Enabled | DefaultInboundAction |
|---|---|---|
| Domain | True | NotConfigured |
| Private | True | NotConfigured |
| Public | True | NotConfigured |

**RDP and Tailscale were deliberately left unrestricted per Leonel's explicit
instruction.** This is intentional, not a gap — see `p01-phase5-firewall-baseline.md`.
Additional findings: VNC (winvnc) has explicit inbound firewall rules as a second
remote-access surface; NPS listens on UDP 1812/1813 despite no configured clients
(expected default behavior).

## Lockout Break/Fix (Phase 6)

| Property | Value |
|---|---|
| SamAccountName | testuser |
| Enabled | **False** |
| LockedOut | False |
| DistinguishedName | `CN=Test User,OU=Quarantine,DC=Chongong,DC=local` |

Lockout confirmed at exactly 5 failed attempts (matching `LockoutThreshold=5`),
Event 4740 logged correctly. Separate finding: failed-logon events (4625/4776/4771)
are NOT being logged despite `BadLogonCount` tracking correctly — flagged as an
audit-policy gap for future GPO/Blue Team work, not fixed in P01.

---

## Project 01 — Status: Complete

All 7 phases done. No AD objects were deleted at any point in this project.
`chongong.leonel`'s continued Domain Admins membership and the RDP/Tailscale
firewall scope were both deliberate, Leonel-approved decisions — not oversights,
and should not be "corrected" by a future session without asking first.

**Carried-forward items for later projects:**
- RD Connection Broker issue → Project 08
- IIS migration → Project 08
- `__vmware__` group confirmed again during Project 02; empty VMware artifact left untouched
- NPS/RADIUS buildout (currently empty) → Project 13
- Failed-logon audit policy gap → Project 05 / Blue Team log forwarding
- VNC exposure (winvnc, explicit firewall rules) → flagged, no project assigned yet —
  ask Leonel whether it's still needed
