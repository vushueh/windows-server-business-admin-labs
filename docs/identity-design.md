# Identity Design — Active Directory Architecture

## Domain

| Setting | Value |
|---------|-------|
| Internal domain | `chongong.local` |
| NetBIOS name | `CHONGONG` |
| UPN suffix (M365) | `<yourbusiness>.com` (added Project 12) |
| Functional level | Windows2016Domain / Windows2016Forest |

> Windows Server 2022 uses the Windows Server 2016 AD DS functional-level labels.
> Do not plan a separate "Windows Server 2022" domain or forest functional-level upgrade.

## Account Tiers

| Tier | Account type | Example | Used for |
|------|-------------|---------|----------|
| Tier 0 | Domain Admin | `adm-leonel` | DC management only |
| Tier 1 | Server admin | `srv-leonel` | Member server management |
| Tier 2 | Workstation admin | `ws-leonel` | Workstation local admin |
| Standard | Daily user | `leonel` | Email, files, apps — no local admin |
| Service | Service account | `svc-backup` | Automated tasks — minimum permissions |

> Tier 0 accounts NEVER log into workstations.
> Standard accounts NEVER have local admin on any machine.

## OU Structure

```
chongong.local
  ├── _Admin
  │   ├── Tier0-DomainAdmins
  │   ├── Tier1-ServerAdmins
  │   ├── Tier2-WorkstationAdmins
  │   └── ServiceAccounts
  ├── ManagedComputers
  │   ├── Servers
  │   └── Workstations
  ├── ManagedUsers
  │   ├── Finance
  │   ├── HR
  │   ├── IT
  │   ├── Management
  │   └── Sales
  └── Groups
      ├── GlobalGroups    ← GG-* (who people are)
      └── DomainLocalGroups  ← DL-* (what they can access)
```

`ManagedUsers` and `ManagedComputers` are intentional. The domain already has
built-in root containers named `CN=Users` and `CN=Computers`, so Project 02 uses
managed OUs for GPO-ready objects without touching the built-in containers.

## AGDLP Model

```
A  — Account (user)
G  — Global Group (GG-Finance-Users)
DL — Domain Local Group (DL-Finance-Share-RW)
P  — Permission (NTFS on share)
```

Example flow:
- User `leonel` is member of `GG-IT-Admins`
- `GG-IT-Admins` is member of `DL-IT-Share-Full`
- `DL-IT-Share-Full` has Full Control NTFS on `\\WIN-FS01\IT`
- To add a user to IT share: add to `GG-IT-Admins` only — no direct permission grants

## Groups for Network Device Auth (Project 13)

| Group | Scope | Purpose |
|-------|-------|--------|
| `GG-NetAdmins` | Global | Full CLI access to all Cisco devices (privilege 15) |
| `GG-Net-ReadOnly` | Global | Read-only CLI access (privilege 5) |
| `GG-ServerAdmins` | Global | Local admin on member servers |
| `GG-SOC-Analysts` | Global | Read access to security tools |
| `GG-Helpdesk` | Global | Password reset delegation only |
