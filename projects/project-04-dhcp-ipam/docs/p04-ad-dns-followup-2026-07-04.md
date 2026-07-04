# Project 04 AD DNS Follow-Up

**Date:** 2026-07-04
**System queried:** `WIN-PRQD8TJG04M`
**Change level:** Read-only discovery; no DNS, DHCP, or AD configuration changed

This follow-up was run while closing Route10 Project 02 Phase 4. It checks
whether the earlier AD/DC locator APIPA anomaly still affects the VLAN 20 DHCP
authority decision.

## Findings

`Get-ADDomainController` now reports the correct VLAN 20 addresses:

| Domain controller | Reported IPv4 |
|-------------------|---------------|
| `WIN-PRQD8TJG04M.Chongong.local` | `192.168.20.11` |
| `WIN-DC02.Chongong.local` | `192.168.20.12` |

The original APIPA value was not reproduced by `Get-ADDomainController`.

However, resolving `WIN-PRQD8TJG04M.Chongong.local` returned multiple A records:

| Address | Meaning |
|---------|---------|
| `192.168.20.11` | Correct VLAN 20 DC address |
| `192.168.10.194` | Windows host VLAN 10/WAN-side address |
| `100.81.197.116` | Tailscale address |
| `192.168.56.1`, `172.28.128.1`, `172.30.144.1` | Host-only/NAT/virtual adapter addresses |
| `169.254.7.146`, `169.254.67.11` | APIPA/link-local addresses |

`WIN-DC02.Chongong.local` resolved only to `192.168.20.12`.

`repadmin /replsummary` showed `0 / 5` failures, but still reported operational
error `110` while retrieving information from `WIN-DC02`. Direct port checks
from `WIN-PRQD8TJG04M` to `WIN-DC02.Chongong.local` succeeded on TCP `135`,
`389`, and `445`.

`nltest /dsgetdc:Chongong.local` selected `WIN-PRQD8TJG04M` but returned a
Tailscale IPv6 address as the locator address.

## Decision Impact

This does not change the VLAN 20 DHCP authority decision:

- Windows remains the DHCP service authority for VLAN 20.
- DHCP option 6 is still correct: `192.168.20.11`, `192.168.20.12`.
- Route10 remains gateway and IPAM source of truth.

It creates a Windows-side DNS/DC locator cleanup item before declaring AD DNS
fully clean, but Leonel approved leaving it alone unless it becomes a practical
problem. The likely cleanup area is DNS registration behavior on non-AD
interfaces and stale `WIN-PRQD8TJG04M` A records. No cleanup was performed in
this follow-up.
