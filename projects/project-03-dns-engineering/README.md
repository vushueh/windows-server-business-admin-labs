# Project 03 — AD DNS and Name Resolution Engineering

**Status:** ⬜ Planned (requires Project 02 complete)
**Skill:** `/winserver-p03` — written when this project starts

## Objective

Audit, design, and harden the AD-integrated DNS environment on Chongong.local.
Configure forwarders, conditional forwarders, reverse lookup zones, and split-brain DNS.
Practice broken DNS troubleshooting scenarios that directly mirror real enterprise incidents.

**Why third:** DNS is the foundation every service in the lab depends on — AD authentication,
replication, NPS, M365 sync, and Proxmox SSSD all require correct DNS. Fixing DNS before
later projects avoids compounding failures.

## Environment Context

- DNS server: WIN-PRQD8TJG04M (192.168.20.11)
- AD-integrated zone: `Chongong.local`
- Secondary DNS after P02: `WIN-DC02` (replica DC also runs DNS)
- External resolver: forwarders to 8.8.8.8 / 1.1.1.1

## Current DNS State (from P01 Audit)

| Zone | Type | Notes |
|------|------|-------|
| Chongong.local | Primary, AD-integrated | Active |
| _msdcs.Chongong.local | Primary, AD-integrated | SRV records for AD |
| Standard reverse lookup zones | Active | Verify completeness |

**Known gap:** DC DNS must never point directly to 8.8.8.8 or 1.1.1.1 on the NIC.
After WIN-DC02 exists, each DC should use the other DC as preferred DNS and itself as secondary/loopback.
Forwarders send unresolved queries outbound. WIN-DC02 DNS must replicate after Phase 7 of P02.

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Audit Current DNS State | Document all zones, records, forwarders, and scavenging settings |
| 2 | Fix DNS Server Addressing | Confirm each DC NIC points to AD DNS servers only, never public resolvers |
| 3 | Configure Forwarders | Set 8.8.8.8 / 1.1.1.1 as forwarders for public resolution |
| 4 | Reverse Lookup Zones | Verify/create PTR records for all servers and VMs |
| 5 | Conditional Forwarders | Add forwarder for any cross-lab domain (e.g. proxmox internal zone) |
| 6 | DNS Scavenging | Enable scavenging to remove stale records automatically |
| 7 | Split-Brain DNS | Internal zone resolves privately; external DNS resolves publicly |
| 8 | Break/Fix Exercise | Simulate 3 common DNS failures and troubleshoot to resolution |
| 9 | WIN-DC02 DNS Verification | Confirm DNS replication to replica DC is healthy |
| 10 | Document + Push | All zone configs documented, STAR summary written |

## Phase Detail

### Phase 1 — DNS Audit Commands
```powershell
Get-DnsServer
Get-DnsServerZone
Get-DnsServerForwarder
Get-DnsServerScavenging
Get-DnsServerResourceRecord -ZoneName "Chongong.local" | Select-Object HostName, RecordType, RecordData
```

### Phase 4 — Reverse Lookup
```powershell
# Create reverse zone for 192.168.20.0/24 only if it does not already exist.
# -NetworkID "192.168.20.0/24" is valid syntax for IPv4 reverse-zone creation.
Add-DnsServerPrimaryZone -NetworkID "192.168.20.0/24" -ReplicationScope Domain -DynamicUpdate Secure
# Add PTR for WIN-PRQD8TJG04M
Add-DnsServerResourceRecordPtr -ZoneName "20.168.192.in-addr.arpa" -Name "11" -PtrDomainName "WIN-PRQD8TJG04M.Chongong.local"
```

### Phase 6 — Scavenging
```powershell
Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00 -ComputerName WIN-PRQD8TJG04M
Set-DnsServerZoneAging -Name "Chongong.local" -Aging $true -RefreshInterval 4.00:00:00 -NoRefreshInterval 4.00:00:00
```

### Phase 8 — Break/Fix Scenarios
| Scenario | Symptom | Root Cause | Fix |
|----------|---------|------------|-----|
| Scenario A | Domain join fails | Primary DNS on new VM set to 8.8.8.8 | Change to 192.168.20.11 |
| Scenario B | AD replication fails | _msdcs SRV record missing | Restart Netlogon to re-register |
| Scenario C | Internet resolution fails | Forwarder missing or wrong | Add/correct forwarder |

## Verification Commands

```powershell
# Confirm DNS resolves AD records
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local
nslookup Chongong.local 127.0.0.1

# Test forwarder (public resolution)
Resolve-DnsName google.com -Server 192.168.20.11

# Replication to WIN-DC02
Get-DnsServerZone -ComputerName WIN-DC02
```

## STAR Summary

**Situation:** DNS is the single AD-integrated server with no documented forwarder config,
unknown scavenging state, unverified reverse zones, and no validated secondary DNS on WIN-DC02.

**Task:** Audit, harden, and fully document DNS. Add break/fix exercises to build real
troubleshooting skill — DNS failures are the most common cause of AD and network incidents.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
