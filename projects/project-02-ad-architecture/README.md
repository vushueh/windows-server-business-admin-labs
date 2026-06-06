# Project 02 — Active Directory Architecture

**Status:** ⬜ Planned (requires Project 01 complete)
**Skill:** `/winserver-p02` — written when this project starts

## Objective

Design and implement the full Active Directory structure for Chongong.local — OU hierarchy,
tiered admin accounts, AGDLP group model, service accounts, delegated administration, and
a replica Domain Controller for redundancy and DC skills practice.

**Why second:** P01 hardens the server and establishes the admin model. P02 builds the
proper AD structure that all users, computers, GPOs, and file shares in later projects depend on.

## Environment Context

- Domain: `Chongong.local` / `CHONGONG`
- Existing PDC: `WIN-PRQD8TJG04M` (192.168.20.11)
- Replica DC: `WIN-DC02` — new Hyper-V VM created in this project
- Functional level: Windows2016Domain / Windows2016Forest
  - Windows Server 2022 still uses the Windows Server 2016 AD DS functional-level labels.
  - Do not attempt a non-existent "Windows Server 2022" functional-level upgrade.

## Critical Security Gaps from P01

| Gap | Fix in this project |
|-----|-------------------|
| No tiered admin accounts | Create adm-leonel (Tier0), srv-leonel (Tier1), ws-leonel (Tier2) |
| No custom OU structure | Build full _Admin / Computers / Users / Groups hierarchy |
| No AGDLP groups | Create GG-* global groups and DL-* domain local groups |
| No delegated admin | Delegate password reset to GG-Helpdesk OU |
| Single DC — no redundancy | Deploy WIN-DC02 as replica DC |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | OU Structure Design | Build _Admin, Computers, Users, Groups OUs per identity-design.md |
| 2 | Move Existing Objects | Move existing users and computers into correct OUs |
| 3 | Tiered Admin Accounts | Create adm-leonel, srv-leonel, ws-leonel with correct group memberships |
| 4 | AGDLP Group Model | Create GG-* and DL-* groups for each department and access scenario |
| 5 | Service Account Provisioning | Create svc-backup, svc-sync with minimum permissions; deny interactive logon |
| 6 | Delegated Administration + Recycle Bin | Delegate password reset to GG-Helpdesk on Users OU; verify/enable AD Recycle Bin |
| 7 | Replica DC Deployment | Create WIN-DC02 Hyper-V VM, promote as replica DC, verify replication |
| 8 | Functional Level Verification | Confirm Windows2016Domain / Windows2016Forest; no upgrade action expected |
| 9 | Document + Verify | AD topology confirmed, replication healthy, STAR summary written |

## Phase Detail

### Phase 1 — OU Structure
Build per `docs/identity-design.md`:
```
Chongong.local
  ├── _Admin
  │   ├── Tier0-DomainAdmins
  │   ├── Tier1-ServerAdmins
  │   ├── Tier2-WorkstationAdmins
  │   └── ServiceAccounts
  ├── Computers
  │   ├── Servers
  │   └── Workstations
  ├── Users
  │   ├── IT
  │   ├── Finance
  │   └── Operations
  └── Groups
      ├── GlobalGroups
      └── DomainLocalGroups
```

### Phase 3 — Tiered Admin Accounts
| Account | OU | Groups | Tier |
|---------|----|--------|------|
| adm-leonel | _Admin\Tier0-DomainAdmins | Domain Admins, GG-Tier0-Admins | 0 |
| srv-leonel | _Admin\Tier1-ServerAdmins | GG-ServerAdmins | 1 |
| ws-leonel | _Admin\Tier2-WorkstationAdmins | GG-WorkstationAdmins | 2 |

### Phase 4 — AGDLP Groups
| Global Group | Domain Local Group | Permission |
|---|---|---|
| GG-Finance-Users | DL-Finance-Share-RW | Modify on \\WIN-FS01\Finance |
| GG-IT-Users | DL-IT-Share-RW | Modify on \\WIN-FS01\IT |
| GG-IT-Admins | DL-IT-Share-Full | Full Control on \\WIN-FS01\IT |
| GG-Operations-Users | DL-Operations-Share-RW | Modify on \\WIN-FS01\Operations |
| GG-NetAdmins | (used in P13 NPS policy) | Cisco privilege 15 |
| GG-Net-ReadOnly | (used in P13 NPS policy) | Cisco privilege 5 |
| GG-Helpdesk | (delegation only) | Password reset on Users OU |

### Phase 6 — AD Recycle Bin
```powershell
# Verify before enabling. Enabling is forest-wide and irreversible, but safe for this lab.
Get-ADOptionalFeature "Recycle Bin Feature" | Select-Object Name, EnabledScopes

Enable-ADOptionalFeature "Recycle Bin Feature" `
  -Scope ForestOrConfigurationSet `
  -Target "Chongong.local"
```

### Phase 7 — Replica DC (WIN-DC02)
- Create Hyper-V VM: WIN-DC02, Windows Server 2022, 2 vCPU, 4GB RAM, 80GB disk
- Join WIN-DC02 to Chongong.local
- Promote as additional DC:
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSDomainController `
  -DomainName "Chongong.local" `
  -Credential (Get-Credential "CHONGONG\adm-leonel") `
  -InstallDns `
  -NoGlobalCatalog:$false `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password") `
  -Force
```
- Verify replication: `repadmin /replsummary`, `repadmin /showrepl`
- FSMO roles stay on WIN-PRQD8TJG04M during normal operation.
- Do not practice FSMO seizure or forced failover against the live domain. That belongs in P11 DR testing only, with backups and approval.

## Verification Commands

```powershell
# OU structure
Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName | Sort-Object

# Tiered accounts in correct OUs
Get-ADUser -Filter * -SearchBase "OU=_Admin,DC=Chongong,DC=local" -Properties MemberOf

# Replication health
repadmin /replsummary
repadmin /showrepl
Get-ADReplicationPartnerMetadata -Target WIN-DC02

# FSMO roles
netdom query fsmo
```

## STAR Summary

**Situation:** Domain has no OU structure, no tiered admin accounts, no AGDLP groups, and a single DC with no redundancy — a single point of failure for all 10 users and 13 VMs.

**Task:** Build the full AD architecture that all future projects depend on. Add a replica DC for redundancy and DC-skills practice without touching the production PDC.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
