# Project 05 — Group Policy Security Baselines

**Status:** ⬜ Planned (requires Project 02 complete)
**Skill:** `/winserver-p05` — written when this project starts

## Objective

Build and deploy a complete set of custom GPOs that enforce security baselines across
all OUs. Replace reliance on the Default Domain Policy with purpose-built GPOs scoped
correctly to domain, servers, and workstations.

**Why fifth:** Project 02 builds the OU structure. Project 05 fills it with security policy.
Every GPO must be created and tested before workstations and servers join in later projects —
GPO gets applied at domain join, not after.

## Environment Context

- DC: WIN-PRQD8TJG04M (PDC); WIN-DC02 replica pending
- OU structure: built in P02 — _Admin, ManagedComputers\Servers, ManagedComputers\Workstations, ManagedUsers
- Existing GPO gap: only Default Domain Policy + Default Domain Controllers Policy exist

## GPO Architecture

| GPO Name | Scope/Link | Purpose |
|----------|-----------|---------|
| Domain-AccountPolicy | Domain root | Password length 14, complexity, history, lockout threshold 5 |
| Servers-AuditPolicy | ManagedComputers\Servers | Logon, account mgmt, privilege use, object access |
| Servers-FirewallBaseline | ManagedComputers\Servers | DefaultInboundAction=Block, allow management only |
| Workstations-LocalAdminRestriction | ManagedComputers\Workstations | Remove standard users from local admins |
| Workstations-AuditPolicy | ManagedComputers\Workstations | Logon, removable storage, process creation |
| Workstations-UserRestrictions | ManagedComputers\Workstations | Screen lock 10min, disable USB, logon banner |
| Admins-TierZeroRestriction | _Admin\Tier0-DomainAdmins | Deny logon to workstations for adm-* accounts |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Audit Current GPO State | Document all existing GPOs, links, and inheritance |
| 2 | GPO Backup | Backup Default Domain Policy and Default Domain Controllers Policy |
| 3 | Create Domain Account Policy GPO | Domain-AccountPolicy at domain root; contains password + lockout settings |
| 4 | Create Server Audit Policy GPO | Enable success+failure for all audit categories on servers |
| 5 | Create Firewall Baseline GPO | DefaultInboundAction=Block on servers; allow RDP from Tailscale only |
| 6 | Create Workstation Restriction GPOs | Local admin restriction, screen lock, logon banner |
| 7 | Create Tier 0 Logon Restriction GPO | Deny adm-* accounts from logging into workstations |
| 8 | Stage and Test | Link GPOs to test OU first, verify before domain-wide link |
| 9 | Link to Production OUs | Link verified GPOs to correct OUs |
| 10 | Verify with gpresult | Confirm RSoP on servers and workstations shows expected settings |
| 11 | Document + Push | All GPO configs exported, STAR summary written |

## Phase Detail

### Phase 3 — Domain Account Policy
```powershell
# Domain account policies for domain users must be linked at the domain root.
# OU-linked password/lockout GPOs do not set the domain account policy.
New-GPO -Name "Domain-AccountPolicy"
New-GPLink -Name "Domain-AccountPolicy" -Target "DC=Chongong,DC=local" -LinkEnabled Yes
Set-GPLink -Name "Domain-AccountPolicy" -Target "DC=Chongong,DC=local" -Order 1
# Settings: MinPasswordLength=14, PasswordComplexity=Enabled, PasswordHistory=24,
#           LockoutThreshold=5, LockoutDuration=15min, LockoutObservationWindow=15min
```

Do not stage domain account policy by linking it to a test OU; that would not test the
domain password/lockout policy for domain accounts. Back up the current domain GPOs first,
verify exact settings in GPMC, and apply during an approved maintenance window.

### Phase 4 — Audit Policy (via GPO, not auditpol directly)
```
GPO Path: Computer Configuration → Policies → Windows Settings → Security Settings →
          Advanced Audit Policy Configuration → Audit Policies
Categories: Logon/Logoff, Account Management, Privilege Use, Object Access, Policy Change
Setting: Success + Failure on all categories
```

### Phase 5 — Firewall Baseline
```powershell
# Verify DefaultInboundAction via GPO result
Get-NetFirewallProfile | Select-Object Name, DefaultInboundAction
# Target: Block on Domain, Private, Public profiles
```

### Phase 7 — Tier 0 Restriction
```
GPO Path: Computer Configuration → Policies → Windows Settings → Security Settings →
          Local Policies → User Rights Assignment
Setting: "Deny log on locally" → add GG-Tier0-Admins
Setting: "Deny log on through Remote Desktop Services" → add GG-Tier0-Admins
Link: Computers\Workstations OU only
```

### Phase 10 — Verify RSoP
```powershell
# Run on server after gpupdate
gpresult /R /Scope Computer
gpresult /H C:\Audit\gpo-rsop-server.html

# Check specific setting applied
Get-GPResultantSetOfPolicy -ReportType Html -Path C:\Audit\gpo-rsop.html
```

## Verification Commands

```powershell
# List all GPOs and links
Get-GPO -All | Select-Object DisplayName, GpoStatus
Get-GPInheritance -Target "DC=Chongong,DC=local"

# Confirm password policy
Get-ADDefaultDomainPasswordPolicy

# Confirm audit settings applied
auditpol /get /category:* /r | ConvertFrom-Csv
```

## STAR Summary

**Situation:** Only Default Domain Policy and Default Domain Controllers Policy exist.
No custom GPOs for audit, firewall, workstation restrictions, or tiered admin logon control.
Security settings are undocumented and unverified across servers and workstations.

**Task:** Build a complete custom GPO set, stage in test OU before production link, and
prove every policy with gpresult. Replace ad-hoc security with repeatable, documented baselines.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
