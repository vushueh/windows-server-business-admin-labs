# Project 02 - Active Directory Architecture

**Status:** AD architecture complete on `2026-06-23`; replica DC build pending

**Domain:** `Chongong.local` / `CHONGONG`

**Primary DC:** `WIN-PRQD8TJG04M` (`192.168.20.11`)

## What I Built

I cleaned up the live domain so users, computers, admin accounts, and security
groups now have predictable locations. This gives the rest of the Windows,
NetOps, SOC, Proxmox, Microsoft 365, and FreePBX work a stable identity base.

Project 02 now provides:

| Area | Result |
|------|--------|
| Managed computer OUs | `ManagedComputers/Servers` and `ManagedComputers/Workstations` |
| Managed user OUs | `ManagedUsers/Finance`, `HR`, `IT`, `Management`, `Sales` |
| Group structure | `Groups/GlobalGroups` and `Groups/DomainLocalGroups` |
| AGDLP groups | `GG-*` global groups nested into `DL-*` domain local groups |
| Admin/service accounts | `ws-leonel`, `svc-backup`, and `svc-sync` staged disabled |
| Helpdesk delegation | `GG-Helpdesk` can reset passwords, force password change, and unlock users under `ManagedUsers` |
| AD Recycle Bin | Enabled for the forest |
| FSMO roles | Still on `WIN-PRQD8TJG04M` |

No AD objects were deleted.

## Project Phases

Project 02 has 9 phases. Phases 1-6 and 8-9 are complete. Phase 7 is pending
because the `WIN-DC02` VM does not exist yet.

| Phase | Name | Status | What happened |
|-------|------|--------|---------------|
| 1 | OU Structure Design | Complete | Built `ManagedUsers`, `ManagedComputers`, `Groups/GlobalGroups`, and `Groups/DomainLocalGroups` |
| 2 | Move Existing Objects | Complete | Moved department OUs, workstations, and member servers into the managed OUs |
| 3 | Tiered Admin Accounts | Complete for P02 | Kept the P01 admin model and staged `ws-leonel` disabled for Tier 2 workstation admin use |
| 4 | AGDLP Group Model | Complete | Created `GG-*` global groups and `DL-*` domain local groups |
| 5 | Service Account Provisioning | Complete | Created disabled `svc-backup` and `svc-sync` accounts |
| 6 | Delegated Administration + AD Recycle Bin | Complete | Enabled AD Recycle Bin and delegated reset/unlock rights to `GG-Helpdesk` |
| 7 | Replica DC Deployment | Pending | `WIN-DC02` VM is not present in Hyper-V yet |
| 8 | Functional Level Verification | Complete | Verified `Windows2016Domain` / `Windows2016Forest`, which is correct for Windows Server 2022 AD DS |
| 9 | Document + Verify | Complete | Added apply/verify scripts and updated the project docs |

## Why The OU Names Are ManagedUsers And ManagedComputers

The domain already has built-in root containers named `CN=Users` and
`CN=Computers`. Active Directory does not allow a root OU with the same leaf
name, so I used:

```text
OU=ManagedUsers,DC=Chongong,DC=local
OU=ManagedComputers,DC=Chongong,DC=local
```

That keeps the built-in containers intact and gives new GPO-ready OUs for the
real lab objects.

## Current OU Layout

```text
Chongong.local
  _Admin
    Tier0-DomainAdmins
    Tier1-ServerAdmins
    Tier2-WorkstationAdmins
    ServiceAccounts
  ManagedComputers
    Servers
    Workstations
  ManagedUsers
    Finance
    HR
    IT
    Management
    Sales
  Groups
    GlobalGroups
    DomainLocalGroups
  Quarantine
  Domain Controllers
```

## How I Applied It

Manual equivalent:

1. Open **Active Directory Users and Computers**.
2. Create `ManagedComputers`, `ManagedUsers`, `GlobalGroups`, and
   `DomainLocalGroups`.
3. Move existing department OUs under `ManagedUsers`.
4. Move domain-joined servers and workstations under `ManagedComputers`.
5. Create `GG-*` and `DL-*` groups.
6. Nest global groups into the matching domain local groups.
7. Stage disabled admin/service accounts.
8. Enable AD Recycle Bin.
9. Delegate helpdesk reset/unlock rights on `ManagedUsers`.

Scripted path:

```powershell
# Plan only
.\scripts\p02-apply-ad-architecture.ps1 -Mode Plan

# Apply after approval
.\scripts\p02-apply-ad-architecture.ps1 -Mode Apply
```

The script is idempotent. A later `Plan` run should show existing OUs, groups,
memberships, delegation, and computer placement instead of trying to recreate
or move the same objects again.

## Department Groups

| Department | Global group | Domain local group |
|------------|--------------|--------------------|
| Finance | `GG-Finance-Users` | `DL-Finance-Share-RW` |
| HR | `GG-HR-Users` | `DL-HR-Share-RW` |
| IT | `GG-IT-Users` | `DL-IT-Share-RW` |
| IT admins | `GG-IT-Admins` | `DL-IT-Share-Full` |
| Management | `GG-Management-Users` | `DL-Management-Share-RW` |
| Sales | `GG-Sales-Users` | `DL-Sales-Share-RW` |

These groups are staged for Project 06 file shares. Project 02 created the AD
groups and nesting only; it did not create shares or NTFS permissions.

## Cross-Family Groups

| Group | Used later by |
|-------|---------------|
| `GG-NetAdmins` | Project 13 NPS/RADIUS for Cisco, CML, OPNsense, and firewall admin auth |
| `GG-Net-ReadOnly` | Project 13 read-only network device access |
| `GG-SOC-Analysts` | Project 10 SOC/Wazuh access model |
| `GG-ServerAdmins` | Server administration model from Project 01 |
| `GG-Helpdesk` | Password reset/unlock delegation |
| `GG-WorkstationAdmins` | Tier 2 workstation administration |

## Verification

Run the read-only verification script from this project folder:

```powershell
.\scripts\p02-verify-ad-architecture.ps1
```

Useful individual checks:

```powershell
Get-ADOrganizationalUnit -Filter * |
  Select-Object Name, DistinguishedName |
  Sort-Object DistinguishedName

Get-ADGroup -Filter 'Name -like "GG-*" -or Name -like "DL-*"' |
  Select-Object Name, GroupScope, DistinguishedName |
  Sort-Object Name

Get-ADComputer -Filter * -Properties OperatingSystem |
  Select-Object Name, OperatingSystem, DistinguishedName |
  Sort-Object Name

Get-ADOptionalFeature "Recycle Bin Feature" |
  Select-Object Name, EnabledScopes

netdom query fsmo
```

Verified results on `2026-06-23`:

| Check | Result |
|-------|--------|
| Department OUs | Finance, HR, IT, Management, and Sales are under `ManagedUsers` |
| Computers | `DESKTOP-*` systems are under `Workstations`; `GITEA` and `RADIUS01` are under `Servers` |
| Staged accounts | `ws-leonel`, `svc-backup`, and `svc-sync` exist and are disabled |
| Recycle Bin | Enabled |
| FSMO roles | All five roles remain on `WIN-PRQD8TJG04M` |
| `__vmware__` group | Empty Domain Local group, description `VMware User Group`; left untouched |
| `WIN-DC02` | No VM found in Hyper-V; replica DC build remains pending |

## Remaining Work - WIN-DC02

The replica DC part is not complete because Hyper-V does not currently have a
`WIN-DC02` VM. I verified the Hyper-V VM list and did not find it.

Next safe build:

1. Create a Windows Server 2022 VM named `WIN-DC02`.
2. Give it a static IP and point DNS to `192.168.20.11`.
3. Join it to `Chongong.local`.
4. Promote it as an additional domain controller with DNS installed.
5. Verify `repadmin /replsummary`, `repadmin /showrepl`, DNS health, and FSMO
   role placement.
6. Keep FSMO roles on `WIN-PRQD8TJG04M` unless a later DR project explicitly
   approves a transfer.

Do not practice FSMO seizure or forced failover against the live domain in this
project. That belongs in Project 11 backup and disaster recovery.

## Rollback / Recovery

There is no delete-based rollback for this project. The safe recovery approach
is:

- Move objects back only if a specific GPO/application dependency requires it.
- Disable newly staged accounts if they are not needed.
- Remove group memberships only after confirming the dependent project does not
  use them.
- Use AD Recycle Bin for accidental deletions after this point.
- Restore from system state backup for domain-wide failure.

## STAR Summary

**Situation:** The domain had users, computers, and groups spread across default
containers and root-level department OUs, which made future GPOs, file shares,
RADIUS policies, and SOC logging harder to manage.

**Task:** Build a predictable AD structure without deleting objects or breaking
the live primary domain controller.

**Action:** I created managed user/computer OUs, moved existing objects into the
right places, created AGDLP groups, staged disabled service/admin accounts,
enabled AD Recycle Bin, and delegated helpdesk reset/unlock rights.

**Result:** The domain now has a clean identity structure ready for DNS, DHCP,
GPO, file server, SOC, and NPS/RADIUS projects. The only remaining Project 02
infrastructure item is building and promoting `WIN-DC02`.
