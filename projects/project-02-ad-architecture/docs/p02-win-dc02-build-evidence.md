# Project 02 WIN-DC02 Build Evidence

**Date:** `2026-07-03`
**Scope:** Build and promote `WIN-DC02` as a replica domain controller for `Chongong.local`.

## Objective

I needed a second domain controller so the lab would not depend on only
`WIN-PRQD8TJG04M` for AD DS and DNS. I kept FSMO roles on the original PDC and
used `WIN-DC02` only for redundancy, DNS replication, and future project
validation.

## Safety Gates

Before promotion, I confirmed the live domain was healthy enough to accept a new
DC and created a recovery point with Windows Server Backup.

```powershell
dcdiag /q
repadmin /replsummary

wbadmin start backup -backupTarget:D: -allCritical -quiet
wbadmin get versions
```

Backup result:

| Item | Value |
|------|-------|
| Backup time | `7/2/2026 9:37 PM` |
| Version identifier | `07/03/2026-03:37` |
| Backup target | Fixed disk `D:` |
| Recoverable items | Volume(s), File(s), Application(s), Bare Metal Recovery, System State |

I also protected the DC address range in the existing Windows DHCP scope:

```powershell
Add-DhcpServerv4ExclusionRange `
  -ScopeId 192.168.20.0 `
  -StartRange 192.168.20.11 `
  -EndRange 192.168.20.20
```

## DNS Cleanup Before Promotion

The original DC was multihomed and had published several bad host records for
`WIN-PRQD8TJG04M.Chongong.local`. That could make a new DC randomly contact a
host-only, Tailscale, WSL, or VLAN 10 address during promotion.

I fixed the risk by making DNS listen only on the AD VLAN address and then
removing the stale host records.

```powershell
dnscmd . /ResetListenAddresses 192.168.20.11
Restart-Service DNS -Force

Get-DnsServerResourceRecord -ZoneName "Chongong.local" -Name "WIN-PRQD8TJG04M" -RRType A |
  Where-Object { $_.RecordData.IPv4Address.IPAddressToString -ne "192.168.20.11" } |
  ForEach-Object {
    Remove-DnsServerResourceRecord -ZoneName "Chongong.local" -InputObject $_ -Force
  }

Get-DnsServerResourceRecord -ZoneName "Chongong.local" -Name "WIN-PRQD8TJG04M" -RRType AAAA -ErrorAction SilentlyContinue |
  ForEach-Object {
    Remove-DnsServerResourceRecord -ZoneName "Chongong.local" -InputObject $_ -Force
  }

Clear-DnsServerCache -Force
Clear-DnsClientCache
```

Final proof:

```powershell
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local -Server 192.168.20.11 -DnsOnly -NoHostsFile
```

Expected result: only `192.168.20.11`.

Screenshot evidence:

- `../../project-03-dns-engineering/screenshots/phase9-00-pdc-multihomed-dns-before-cleanup.png`
- `../../project-03-dns-engineering/screenshots/phase9-00-pdc-hostname-clean-after-fix.png`

## WIN-DC02 VM Build

Final VM and network values:

| Setting | Value |
|---------|-------|
| VM name | `WIN-DC02` |
| OS | Windows Server 2022 Standard Desktop Experience |
| vSwitch | `External-VLAN-Trunk` |
| VLAN mode | Untagged |
| Memory | 8 GB static |
| VHD | 80 GB |
| Checkpoints | Disabled |
| IPv4 | `192.168.20.12/24` |
| Gateway | `192.168.20.1` |
| Pre-promotion DNS | `192.168.20.11` |

Pre-join verification:

```powershell
hostname
ipconfig
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local -Server 192.168.20.11 -DnsOnly -NoHostsFile
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.11
```

Screenshot evidence:

- `../screenshots/phase7-00-win-dc02-prejoin-network-check.png`
- `../screenshots/phase7-01-win-dc02-hyperv-vm.png`

## Domain Join And Promotion

I joined the VM to `Chongong.local`, logged in with the Tier 0 admin account,
and promoted it as a replica DC with DNS and Global Catalog enabled.

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment
Install-ADDSDomainController `
  -DomainName "Chongong.local" `
  -InstallDns:$true `
  -NoGlobalCatalog:$false `
  -ReplicationSourceDC "WIN-PRQD8TJG04M.Chongong.local" `
  -Credential (Get-Credential "CHONGONG\adm-leonel") `
  -SafeModeAdministratorPassword (Read-Host "DSRM password for WIN-DC02" -AsSecureString) `
  -Force:$true
```

The DNS delegation warning was expected because `Chongong.local` is an internal
AD zone. I did not document or store the DSRM password.

## Final Verification

Service and SYSVOL checks on `WIN-DC02`:

```powershell
Get-Service NTDS,DNS,Netlogon,DFSR
Get-SmbShare -Name SYSVOL,NETLOGON
```

Replication checks:

```powershell
repadmin /syncall WIN-DC02 /AdeP
repadmin /syncall WIN-PRQD8TJG04M /AdeP
repadmin /replsummary
repadmin /showrepl WIN-DC02 /errorsonly
repadmin /showrepl WIN-PRQD8TJG04M /errorsonly
```

Final result: replication completed both ways with `0` failures.

Role placement:

```powershell
netdom query fsmo
```

Final result: all five FSMO roles remained on `WIN-PRQD8TJG04M`.

Screenshot evidence:

- `../screenshots/phase7-02-win-dc02-domain-controllers-ou.JPG`
- `../screenshots/phase7-03-replication-healthy.JPG`
- `../screenshots/phase7-04-sysvol-netlogon-shares.JPG`
- `../screenshots/phase7-05-fsmo-roles-remain-on-pdc.JPG`

## Troubleshooting Note

Immediately after promotion, `dcdiag /q` showed recent event-log warnings,
including `1084` and `2108` against the `RID Set` object on `WIN-DC02`. I did
not ignore it. I forced replication in both directions, checked for new
Directory Service warnings, and ran the targeted health checks again.

```powershell
Get-WinEvent -FilterHashtable @{
  LogName='Directory Service'
  StartTime=(Get-Date).AddMinutes(-15)
} |
Where-Object { $_.LevelDisplayName -in 'Error','Warning' }

dcdiag /s:WIN-DC02 /test:Advertising /q
dcdiag /s:WIN-DC02 /test:Services /q
dcdiag /s:WIN-DC02 /test:Replications /q
dcdiag /s:WIN-DC02 /test:DNS /q
dcdiag /s:WIN-DC02 /test:RidManager /q
dcdiag /s:WIN-PRQD8TJG04M /test:RidManager /q
```

No new Directory Service warnings appeared in the last 15 minutes, targeted
`dcdiag` checks were quiet, and replication stayed clean. I treated the earlier
warnings as promotion-time events rather than an active replication fault.

## Carried Forward

- Keep FSMO roles on `WIN-PRQD8TJG04M` unless Project 11 explicitly tests DR.
- Keep Hyper-V checkpoints disabled for domain controllers.
- Use Project 03 Phase 9 as the DNS-specific evidence for `WIN-DC02`.
- Use Project 04 to decide the long-term DHCP authority model.
