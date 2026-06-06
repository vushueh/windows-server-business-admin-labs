# Security Model

## Design Principles

1. **Least privilege everywhere** — no account has more access than the job requires
2. **Tiered admin model** — Tier 0 for DCs only, never used on workstations
3. **No standing privilege** — admin tasks use dedicated admin accounts, not daily accounts
4. **Audit everything** — logon, account changes, file access, privilege use all logged
5. **Test before production** — GPO changes staged in test OU before domain-wide roll-out
6. **DR tested not just planned** — backup is only proven when you've restored from it

## Admin Access Rules

| Rule | Enforcement |
|------|------------|
| Tier 0 accounts cannot log into workstations | GPO: Deny logon to workstations |
| Standard users have no local admin | GPO: Restrict local admin group |
| Service accounts cannot log on interactively | AD: Deny interactive logon |
| Remote Desktop only for admins | GPO: Restrict RDP to server admins group |
| All DC admin actions audited | GPO: Audit privilege use + account management |

## Network Device Auth Security (Project 13)

```
Cisco device → RADIUS to NPS → NPS policy → AD group check → privilege level

Fallback: local account (if RADIUS unreachable)
Fallback account: read-only privilege 1 only
Test: verify RADIUS fails gracefully — local fallback works
```

## GPO Security Baselines (Project 05)

| Policy | Setting |
|--------|---------|
| Password length | 12+ characters |
| Password complexity | Enabled |
| Lockout threshold | 5 attempts |
| Lockout duration | 15 minutes |
| Audit logon events | Success + Failure |
| Audit account management | Success + Failure |
| Audit privilege use | Success + Failure |
| Windows Firewall | Enabled on all profiles |

## Cross-Family Security Boundaries

| Boundary | Rule |
|----------|------|
| NPS/RADIUS shared secrets | Never reuse across devices — unique per device type |
| AD service account for Entra sync | Dedicated account `svc-sync`, minimum permissions |
| Wazuh agent | Read-only event log access only |
| PowerShell remoting | Only from Tier 0/1 admin accounts |
