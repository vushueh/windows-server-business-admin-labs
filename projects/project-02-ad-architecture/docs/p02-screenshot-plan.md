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
| `phase1-01-managed-ou-layout.JPG` | Shows the final AD structure at a glance |
| `phase4-01-global-and-domain-local-groups.JPG` | Shows the AGDLP model exists |
| `phase6-01-ad-recycle-bin-enabled.JPG` | Shows recovery protection is enabled |
| `phase7-03-replication-healthy.JPG` | Shows the second DC is replicating cleanly |

## Phase Screenshot Outline

For completed phases, capture two screenshots when possible. For partially
complete or pending phases, capture one screenshot showing why the phase is not
complete yet.

| Phase | Status | Screenshots to capture |
|-------|--------|------------------------|
| Phase 1 | Complete | 2 screenshots |
| Phase 2 | Complete | 2 screenshots |
| Phase 3 | Complete for P02 | 2 screenshots |
| Phase 4 | Complete | 2 screenshots |
| Phase 5 | Complete | 2 screenshots |
| Phase 6 | Complete | 2 screenshots |
| Phase 7 | Complete | 6 screenshots |
| Phase 8 | Complete | 2 screenshots |
| Phase 9 | Complete | 2 screenshots |

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

### Image: `phase1-02-managed-ou-powershell-proof.png`

- **What it shows:** PowerShell output listing the managed OU structure.
- **Manual check:** PowerShell on the DC.
- **Why:** Gives technical proof that matches the ADUC view.
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

### Image: `phase5-02-service-accounts-powershell-proof.png`

- **What it shows:** PowerShell output proving `svc-backup` and `svc-sync` are disabled and in the service-account OU.
- **Manual check:** PowerShell on the DC.
- **Why:** Confirms the accounts were staged safely without enabling unused credentials.
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

Phase 7 is complete. `WIN-DC02` now exists as a Windows Server 2022 VM and is
promoted as a DNS-enabled Global Catalog.

### Image: `phase7-00-win-dc02-prejoin-network-check.png`

- **What it shows:** `WIN-DC02` has static IP `192.168.20.12`, gateway
  `192.168.20.1`, and clean pre-join DNS to `WIN-PRQD8TJG04M`.
- **Manual check:** PowerShell inside `WIN-DC02`.
- **Why:** Proves the VM was on the correct network before domain join and
  promotion.
- **PowerShell equivalent:**

```powershell
ipconfig
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local -Server 192.168.20.11 -DnsOnly -NoHostsFile
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.11
```

### Image: `phase7-01-win-dc02-hyperv-vm.png`

- **What it shows:** `WIN-DC02` VM exists in Hyper-V with 8 GB memory and no
  checkpoints.
- **Manual check:** Hyper-V Manager -> `WIN-DC02`.
- **Why:** This proves the replica DC has a real VM before AD promotion.
- **PowerShell equivalent:**

```powershell
Get-VM WIN-DC02 | Select-Object Name, State, Generation, MemoryStartup
```

### Image: `phase7-02-win-dc02-domain-controllers-ou.JPG`

- **What it shows:** `WIN-DC02` appears in the `Domain Controllers` OU as a
  Global Catalog.
- **Manual check:** ADUC -> `Domain Controllers`.
- **Why:** This proves promotion created a real domain controller computer
  object.
- **PowerShell equivalent:**

```powershell
Get-ADDomainController -Filter * |
  Select-Object HostName, Site, IPv4Address, IsGlobalCatalog
```

### Image: `phase7-03-replication-healthy.JPG`

- **What it shows:** Replication between `WIN-PRQD8TJG04M` and `WIN-DC02` is
  healthy.
- **Manual check:** PowerShell or Command Prompt output from `repadmin`.
- **Why:** A second DC is only useful if replication works.
- **PowerShell equivalent:**

```powershell
repadmin /replsummary
repadmin /showrepl
```

### Image: `phase7-04-sysvol-netlogon-shares.JPG`

- **What it shows:** `SYSVOL` and `NETLOGON` shares exist on `WIN-DC02`.
- **Manual check:** PowerShell on `WIN-DC02`.
- **Why:** Proves the new DC can support Group Policy and logon script
  distribution.
- **PowerShell equivalent:**

```powershell
Get-SmbShare -Name SYSVOL,NETLOGON
```

### Image: `phase7-05-fsmo-roles-remain-on-pdc.JPG`

- **What it shows:** FSMO roles remain on `WIN-PRQD8TJG04M`.
- **Manual check:** Command Prompt or PowerShell on either DC.
- **Why:** Proves Project 02 added a replica DC without changing role ownership.
- **PowerShell equivalent:**

```powershell
netdom query fsmo
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

### Image: `phase8-02-fsmo-role-placement.png`

- **What it shows:** FSMO roles remain on `WIN-PRQD8TJG04M`.
- **Manual check:** PowerShell or Command Prompt on the DC.
- **Why:** Confirms Project 02 did not move domain roles while building the AD structure.
- **PowerShell equivalent:**

```powershell
netdom query fsmo
```

## Phase 9 - Document And Verify

### Image: `phase9-01-p02-verification-output.png`

- **What it shows:** The read-only Project 02 verification script completed and
  displayed the managed OUs, groups, computers, Recycle Bin, FSMO roles, and
  replica DC state.
- **Manual check:** PowerShell running the verification script.
- **Why:** This is the final proof that the documented state matches the live
  domain.
- **PowerShell equivalent:**

```powershell
.\scripts\p02-verify-ad-architecture.ps1
```

### Image: `phase9-02-project-02-github-files.png`

- **What it shows:** Project 02 README, scripts, and screenshot plan in the repo.
- **Manual check:** GitHub project folder.
- **Why:** Proves the configuration is documented and repeatable.
- **PowerShell equivalent:**

```bash
find projects/project-02-ad-architecture -maxdepth 3 -type f | sort
```
