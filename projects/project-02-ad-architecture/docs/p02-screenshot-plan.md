# Project 02 Screenshot and Evidence Plan

Use this file when adding images to the Project 02 documentation. Each image
should prove one phase, not just decorate the page.

## Screenshot Rules

- Do not capture passwords, private keys, recovery keys, or credential prompts.
- Crop only if needed to hide unrelated personal data.
- Use the filename pattern below so images sort by phase.
- Put screenshots under `projects/project-02-ad-architecture/screenshots/`.
- For the public README, use only the strongest 2-4 images and link here for
  the full evidence plan.

## Best Images For The README

If you only want a clean portfolio page, use these first:

| Image | Why it belongs in the README |
|-------|-------------------------------|
| `phase1-01-managed-ou-layout.png` | Shows the final AD structure at a glance |
| `phase4-01-global-and-domain-local-groups.png` | Shows the AGDLP model exists |
| `phase6-01-ad-recycle-bin-enabled.png` | Shows recovery protection is enabled |
| `phase9-01-p02-verification-output.png` | Shows the final verification result |

## Phase 1 - OU Structure Design

### Image: `phase1-01-managed-ou-layout.png`

- **What it shows:** `ManagedUsers`, `ManagedComputers`, `_Admin`, `Groups`,
  `Quarantine`, and `Domain Controllers` in Active Directory Users and Computers.
- **Manual check:** ADUC -> `Chongong.local`.
- **Why:** This proves the domain now has a clean OU structure for GPOs, users,
  computers, admin accounts, and security groups.
- **PowerShell equivalent:**

```powershell
Get-ADOrganizationalUnit -Filter * |
  Select-Object Name, DistinguishedName |
  Sort-Object DistinguishedName
```

## Phase 2 - Move Existing Objects

### Image: `phase2-01-managed-users-departments.png`

- **What it shows:** `Finance`, `HR`, `IT`, `Management`, and `Sales` under
  `ManagedUsers`.
- **Manual check:** ADUC -> `Chongong.local` -> `ManagedUsers`.
- **Why:** This proves the real departments were moved from the domain root into
  the managed user structure.
- **PowerShell equivalent:**

```powershell
Get-ADOrganizationalUnit -SearchBase "OU=ManagedUsers,DC=Chongong,DC=local" -Filter * |
  Select-Object Name, DistinguishedName |
  Sort-Object Name
```

### Image: `phase2-02-managed-computers-placement.png`

- **What it shows:** `Servers` and `Workstations` under `ManagedComputers`, with
  domain-joined systems placed in the correct OU.
- **Manual check:** ADUC -> `Chongong.local` -> `ManagedComputers`.
- **Why:** This proves servers and workstations can receive different GPOs later.
- **PowerShell equivalent:**

```powershell
Get-ADComputer -Filter * -Properties OperatingSystem |
  Select-Object Name, OperatingSystem, DistinguishedName |
  Sort-Object Name
```

## Phase 3 - Tiered Admin Accounts

### Image: `phase3-01-admin-ou-layout.png`

- **What it shows:** `_Admin` with `Tier0-DomainAdmins`,
  `Tier1-ServerAdmins`, `Tier2-WorkstationAdmins`, and `ServiceAccounts`.
- **Manual check:** ADUC -> `Chongong.local` -> `_Admin`.
- **Why:** This proves admin and service accounts are separated from normal
  users.
- **PowerShell equivalent:**

```powershell
Get-ADOrganizationalUnit -SearchBase "OU=_Admin,DC=Chongong,DC=local" -Filter * |
  Select-Object Name, DistinguishedName |
  Sort-Object Name
```

### Image: `phase3-02-workstation-admin-staged-disabled.png`

- **What it shows:** `ws-leonel` exists under `Tier2-WorkstationAdmins` and is
  disabled.
- **Manual check:** ADUC -> `_Admin` -> `Tier2-WorkstationAdmins`.
- **Why:** This proves the Tier 2 account is staged without enabling new admin
  access before it is needed.
- **PowerShell equivalent:**

```powershell
Get-ADUser ws-leonel -Properties Enabled, DistinguishedName |
  Select-Object SamAccountName, Enabled, DistinguishedName
```

## Phase 4 - AGDLP Group Model

### Image: `phase4-01-global-and-domain-local-groups.png`

- **What it shows:** `GlobalGroups` and `DomainLocalGroups` under `Groups`.
- **Manual check:** ADUC -> `Chongong.local` -> `Groups`.
- **Why:** This proves the domain has a place for "who the user is" groups and
  "what the resource allows" groups.
- **PowerShell equivalent:**

```powershell
Get-ADGroup -Filter 'Name -like "GG-*" -or Name -like "DL-*"' |
  Select-Object Name, GroupScope, DistinguishedName |
  Sort-Object Name
```

### Image: `phase4-02-sample-agdlp-nesting.png`

- **What it shows:** One domain local group, for example
  `DL-Finance-Share-RW`, with `GG-Finance-Users` as a member.
- **Manual check:** ADUC -> `Groups` -> `DomainLocalGroups` ->
  double-click `DL-Finance-Share-RW` -> Members tab.
- **Why:** This proves the AGDLP model is actually nested, not just named.
- **PowerShell equivalent:**

```powershell
Get-ADGroupMember DL-Finance-Share-RW |
  Select-Object Name, SamAccountName, ObjectClass
```

## Phase 5 - Service Account Provisioning

### Image: `phase5-01-disabled-service-accounts.png`

- **What it shows:** `svc-backup` and `svc-sync` exist under
  `_Admin/ServiceAccounts` and are disabled.
- **Manual check:** ADUC -> `_Admin` -> `ServiceAccounts`.
- **Why:** This proves service accounts were staged safely without enabling
  unused credentials.
- **PowerShell equivalent:**

```powershell
Get-ADUser -LDAPFilter '(|(sAMAccountName=svc-backup)(sAMAccountName=svc-sync))' -Properties Enabled, DistinguishedName |
  Select-Object SamAccountName, Enabled, DistinguishedName
```

## Phase 6 - Delegated Administration And AD Recycle Bin

### Image: `phase6-01-ad-recycle-bin-enabled.png`

- **What it shows:** AD Recycle Bin is enabled.
- **Manual check:** Active Directory Administrative Center -> domain
  `Chongong (local)`. The Recycle Bin option should show as enabled or no
  longer available to enable.
- **Why:** This proves accidental AD deletions have a safer recovery path.
- **PowerShell equivalent:**

```powershell
Get-ADOptionalFeature "Recycle Bin Feature" |
  Select-Object Name, EnabledScopes
```

### Image: `phase6-02-helpdesk-delegation.png`

- **What it shows:** `GG-Helpdesk` has delegated reset/unlock permissions on
  `ManagedUsers`.
- **Manual check:** ADUC -> View -> Advanced Features -> right-click
  `ManagedUsers` -> Properties -> Security -> Advanced -> look for
  `GG-Helpdesk` reset-password, `pwdLastSet`, and `lockoutTime` entries.
- **Why:** This proves helpdesk-style administration exists without giving
  Domain Admin access.
- **PowerShell equivalent:**

```powershell
dsacls "OU=ManagedUsers,DC=Chongong,DC=local" | findstr /i "GG-Helpdesk Reset pwdLastSet lockoutTime"
```

## Phase 7 - Replica DC Deployment

Phase 7 is pending. I cannot complete it until `WIN-DC02` exists as a Windows
Server VM.

### What I Need Before Phase 7

| Need | Why |
|------|-----|
| Windows Server 2022 ISO or prepared source VM | To install the replica DC operating system |
| Hyper-V switch/VLAN decision | The DC must land on the correct network segment |
| Static IP for `WIN-DC02` | AD DS and DNS need stable addressing |
| DNS pointed to `192.168.20.11` before domain join | Domain join and promotion depend on AD DNS |
| DSRM password typed by Leonel | Do not put this password in chat or the repo |
| Approval before promotion | Promoting a DC changes live domain replication |
| System state backup plan | DC changes should have a recovery path |

### Future Image: `phase7-01-win-dc02-hyperv-vm.png`

- **What it will show:** `WIN-DC02` VM exists in Hyper-V.
- **Manual check:** Hyper-V Manager -> `WIN-DC02`.
- **Why:** This proves the replica DC has a real VM before AD promotion.
- **PowerShell equivalent:**

```powershell
Get-VM WIN-DC02 | Select-Object Name, State, Generation, MemoryStartup
```

### Future Image: `phase7-02-win-dc02-domain-controllers-ou.png`

- **What it will show:** `WIN-DC02` appears in the `Domain Controllers` OU.
- **Manual check:** ADUC -> `Domain Controllers`.
- **Why:** This proves promotion created a real domain controller computer
  object.
- **PowerShell equivalent:**

```powershell
Get-ADDomainController -Filter * |
  Select-Object HostName, Site, IPv4Address, IsGlobalCatalog
```

### Future Image: `phase7-03-replication-healthy.png`

- **What it will show:** Replication between `WIN-PRQD8TJG04M` and `WIN-DC02`
  is healthy.
- **Manual check:** PowerShell or Command Prompt output from `repadmin`.
- **Why:** A second DC is only useful if replication works.
- **PowerShell equivalent:**

```powershell
repadmin /replsummary
repadmin /showrepl
```

## Phase 8 - Functional Level Verification

### Image: `phase8-01-functional-level.png`

- **What it shows:** Domain and forest mode are `Windows2016Domain` and
  `Windows2016Forest`.
- **Manual check:** PowerShell output or AD Domains and Trusts properties.
- **Why:** This proves the functional level is correct. Windows Server 2022 AD
  DS still uses the Windows Server 2016 functional-level labels.
- **PowerShell equivalent:**

```powershell
Get-ADDomain | Select-Object DNSRoot, DomainMode
Get-ADForest | Select-Object Name, ForestMode
```

## Phase 9 - Document And Verify

### Image: `phase9-01-p02-verification-output.png`

- **What it shows:** The read-only Project 02 verification script completed and
  displayed the managed OUs, groups, computers, Recycle Bin, FSMO roles, and
  pending `WIN-DC02` status.
- **Manual check:** PowerShell running the verification script.
- **Why:** This is the final proof that the documented state matches the live
  domain.
- **PowerShell equivalent:**

```powershell
.\scripts\p02-verify-ad-architecture.ps1
```
