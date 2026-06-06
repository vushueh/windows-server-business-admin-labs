# Identity Design — Active Directory Architecture

## Domain

| Setting | Value |
|---------|-------|
| Internal domain | `chongong.local` |
| NetBIOS name | `CHONGONG` |
| UPN suffix (M365) | `<yourbusiness>.com` (added Project 12) |
| Functional level | Windows Server 2022 |

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
  │   └── ServiceAccounts
  ├── Computers
  │   ├── Servers
  │   └── Workstations
  ├── Users
  │   ├── IT
  │   ├── Finance
  │   └── Operations
  └── Groups
      ├── GlobalGroups    ← GG-* (who people are)
      └── DomainLocalGroups  ← DL-* (what they can access)
```

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
