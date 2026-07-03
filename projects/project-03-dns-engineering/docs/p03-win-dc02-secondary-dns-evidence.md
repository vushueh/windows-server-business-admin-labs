# Project 03 WIN-DC02 Secondary DNS Evidence

**Date:** `2026-07-03`
**Scope:** Verify `WIN-DC02` as the second AD-integrated DNS server for
`Chongong.local`.

## Objective

I needed to prove that the new replica DC was not only present in Active
Directory, but also usable as a DNS server. The goal was to validate internal
host records, AD SRV records, reverse DNS, forwarders, and DC DNS client
settings without breaking the working household network.

## Pre-Check: Multihomed PDC DNS Problem

Before promotion, `WIN-PRQD8TJG04M.Chongong.local` returned multiple IP
addresses from non-AD interfaces. That included VLAN 10, Tailscale, WSL, and
host-only adapter addresses. This mattered because a new DC can use DNS during
promotion and replication. If DNS returns the wrong address, promotion can fail
or replication can become unreliable.

Evidence:

- `../screenshots/phase9-00-pdc-multihomed-dns-before-cleanup.png`

Final PDC hostname proof after cleanup:

```powershell
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local -Server 192.168.20.11 -DnsOnly -NoHostsFile
```

Expected result: only `192.168.20.11`.

Evidence:

- `../screenshots/phase9-00-pdc-hostname-clean-after-fix.png`

## DNS Server Listen Address

The key change was making the DNS service on the PDC listen only on the AD VLAN
address:

```powershell
dnscmd . /ResetListenAddresses 192.168.20.11
Restart-Service DNS -Force
```

This intentionally stopped DNS service on `192.168.10.194`. I accepted that
tradeoff because the supported AD DNS address for this domain is
`192.168.20.11`, and the goal was to avoid ambiguous DC identity during
replication.

## WIN-DC02 DNS Zone Verification

After promotion, I verified that AD-integrated DNS zones existed on `WIN-DC02`.

```powershell
Get-DnsServerZone -ComputerName WIN-DC02 |
  Select-Object ZoneName,ZoneType,IsDsIntegrated
```

Expected important zones:

| Zone | Expected |
|------|----------|
| `_msdcs.Chongong.local` | AD-integrated primary |
| `Chongong.local` | AD-integrated primary |
| `20.168.192.in-addr.arpa` | AD-integrated primary |

Evidence:

- `../screenshots/phase9-01-win-dc02-dns-zones.JPG`

## Forwarders And Scavenging On WIN-DC02

Forwarders are server-level settings, so I copied them to `WIN-DC02`. I also
enabled server-level scavenging on the new DNS server.

```powershell
$forwarders = (Get-DnsServerForwarder -ComputerName WIN-PRQD8TJG04M).IPAddress

Set-DnsServerForwarder `
  -ComputerName WIN-DC02 `
  -IPAddress $forwarders

Set-DnsServerScavenging `
  -ComputerName WIN-DC02 `
  -ScavengingState $true `
  -ScavengingInterval 7.00:00:00
```

Forwarders applied to `WIN-DC02`:

| Forwarder |
|-----------|
| `8.8.8.8` |
| `1.1.1.1` |
| `8.8.4.4` |
| `9.9.9.9` |

Evidence:

- `../screenshots/phase9-03-win-dc02-forwarders.JPG`

## PTR Record For WIN-DC02

I added the reverse record for the new DC:

```powershell
Add-DnsServerResourceRecordPtr `
  -ZoneName "20.168.192.in-addr.arpa" `
  -Name "12" `
  -PtrDomainName "WIN-DC02.Chongong.local" `
  -ErrorAction SilentlyContinue
```

Verification:

```powershell
Resolve-DnsName 192.168.20.12 -Server 192.168.20.12
```

Expected result: `WIN-DC02.Chongong.local`.

Evidence:

- `../screenshots/phase9-04-win-dc02-ptr-record.png`

Note: the DNS Manager screenshot also shows a stale temporary `192.168.20.21`
record from the VM before the static IP was assigned. The PowerShell verification
above is the final proof for the correct `192.168.20.12` PTR. The stale record
can be cleaned later if it remains after scavenging.

## Final DNS Resolution Tests

I queried `WIN-DC02` directly for internal AD, SRV, external, and reverse
resolution.

```powershell
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local -Server 192.168.20.12 -DnsOnly -NoHostsFile
Resolve-DnsName WIN-DC02.Chongong.local -Server 192.168.20.12 -DnsOnly -NoHostsFile
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.12
Resolve-DnsName google.com -Server 192.168.20.12
Resolve-DnsName 192.168.20.12 -Server 192.168.20.12
```

Expected results:

| Query | Expected result |
|-------|-----------------|
| `WIN-PRQD8TJG04M.Chongong.local` | `192.168.20.11` |
| `WIN-DC02.Chongong.local` | `192.168.20.12` |
| `_ldap._tcp.Chongong.local` | both DCs |
| `google.com` | public A/AAAA answer through forwarders |
| `192.168.20.12` | PTR to `WIN-DC02.Chongong.local` |

Evidence:

- `../screenshots/phase9-02-win-dc02-dns-resolution.png`

## DC DNS Client Settings

After the second DC was verified, I updated the PDC DNS client settings so the
PDC can use `WIN-DC02` first and itself second.

```powershell
Set-DnsClientServerAddress `
  -InterfaceAlias "vEthernet (External-VLAN-Trunk)" `
  -ServerAddresses 192.168.20.12,192.168.20.11

Get-DnsClientServerAddress `
  -InterfaceAlias "vEthernet (External-VLAN-Trunk)" `
  -AddressFamily IPv4
```

Evidence:

- `../screenshots/phase9-05-pdc-dns-client-now-uses-dc02.png`

## Final Result

`WIN-DC02` is now a working secondary DNS server for `Chongong.local`. It
answers internal AD records, advertises AD SRV records with the original DC,
resolves external names through the same forwarders, and has a working PTR
record.

## Carried Forward

- Phase 5 is complete as a design decision: no current conditional-forwarder
  target exists.
- Project 04 should decide the long-term DHCP authority and DNS option design.
- If the stale `192.168.20.21` PTR remains after scavenging, remove it during
  cleanup; it is not part of the final DC design.
