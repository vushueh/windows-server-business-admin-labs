# Project 04 — DHCP, IPAM, and Network Integration

**Status:** ⬜ Planned (requires Project 03 complete)
**Skill:** `/winserver-p04` — written when this project starts

## Objective

Audit, redesign, and document the DHCP infrastructure on WIN-PRQD8TJG04M.
Create a VLAN-aware scope structure, configure reservations for all servers and VMs,
set correct scope options, and document a repeatable IPAM process for the homelab.

**Why fourth:** Once DNS and AD structure are correct, DHCP defines how every device
gets an IP. Scopes must align with the VLAN design planned for Hyper-V (Project 08)
and the NPS/RADIUS integration (Project 13) — get the IP scheme right before VMs multiply.

## Environment Context

- DHCP server: WIN-PRQD8TJG04M (192.168.20.11)
- Active scope: `Lan-Network` — 192.168.20.0/24, range .1–.254 (from P01 audit)
- Target: redesign into meaningful scopes aligned to device types and future VLANs

## Current DHCP State (from P01 Audit)

| Item | Value |
|------|-------|
| Active scope | Lan-Network: 192.168.20.0/24 |
| Range | .1–.254 (very broad — no exclusions documented) |
| Reservations | Unknown — to be documented |
| Scope options | Unknown — to be documented |

## Planned IP Scheme

| Segment | Range | Purpose |
|---------|-------|---------|
| 192.168.20.1–10 | Static | Infrastructure (gateway, OPNsense, switches) |
| 192.168.20.11–30 | Static | Servers (WIN-PRQD8TJG04M=.11, WIN-DC02=.12, WIN-FS01=.13) |
| 192.168.20.31–50 | Static/Reserved | VMs (RADIUS01, GITEA, WIN-WS01, WIN-RDS01, WIN-RDWEB01) |
| 192.168.20.100–200 | DHCP dynamic | Workstations (DESKTOP-* machines) |
| 192.168.20.201–220 | Reserved pool | Lab/test devices |
| 192.168.20.221–254 | Excluded | Future VLAN expansion |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Audit Current DHCP State | Document active scope, leases, reservations, options |
| 2 | Design IP Scheme | Define static ranges, dynamic pool, exclusions, reservations per device |
| 3 | Redesign Scope | Shrink dynamic range, add exclusions, set correct lease duration |
| 4 | Configure Scope Options | DNS server, default gateway, domain name per scope |
| 5 | Create Reservations | MAC-based reservations for all known servers and VMs |
| 6 | DHCP Failover | Install/authorize DHCP on WIN-DC02, then configure hot standby failover |
| 7 | DHCP Relay Planning | Document relay agent config needed for future VLANs (Project 08) |
| 8 | IPAM Documentation | Create and maintain IPAM spreadsheet for the homelab |
| 9 | Document + Push | Scope config exported, STAR summary written |

## Phase Detail

### Phase 1 — Audit Commands
```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4Lease -ScopeId 192.168.20.0
Get-DhcpServerv4Reservation -ScopeId 192.168.20.0
Get-DhcpServerv4ScopeOptionValue -ScopeId 192.168.20.0
Get-DhcpServerv4ExclusionRange -ScopeId 192.168.20.0
```

### Phase 5 — Reservations
```powershell
# Example: Reserve .11 for WIN-PRQD8TJG04M
Add-DhcpServerv4Reservation -ScopeId 192.168.20.0 -IPAddress 192.168.20.11 `
  -ClientId "<MAC>" -Description "WIN-PRQD8TJG04M PDC"
```

### Phase 6 — DHCP Failover with WIN-DC02
```powershell
# Run only after WIN-DC02 has DHCP Server installed and authorized in AD.
Install-WindowsFeature DHCP -ComputerName WIN-DC02 -IncludeManagementTools
Add-DhcpServerInDC -DnsName "WIN-DC02.Chongong.local" -IPAddress 192.168.20.12

$SharedSecret = Read-Host -AsSecureString "DHCP failover shared secret"
$PlainSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SharedSecret))

Add-DhcpServerv4Failover -Name "LAN-Failover" -PartnerServer WIN-DC02 `
  -ComputerName WIN-PRQD8TJG04M -ScopeId 192.168.20.0 `
  -Mode HotStandby -ServerRole Active -ReservePercent 5 `
  -SharedSecret $PlainSecret -AutoStateTransition $true -StateSwitchInterval 02:00:00
```

### Phase 8 — IPAM Export
```powershell
# Export full scope and reservation config for documentation
Get-DhcpServerv4Scope | Export-Csv -Path C:\Audit\dhcp-scopes.csv -NoTypeInformation
Get-DhcpServerv4Reservation -ScopeId 192.168.20.0 | Export-Csv -Path C:\Audit\dhcp-reservations.csv -NoTypeInformation
```

## Verification Commands

```powershell
# Confirm scope options correct
Get-DhcpServerv4ScopeOptionValue -ScopeId 192.168.20.0

# Confirm failover status
Get-DhcpServerv4Failover

# Confirm lease from WIN-DC02 perspective
Get-DhcpServerv4Lease -ScopeId 192.168.20.0 -ComputerName WIN-DC02
```

## STAR Summary

**Situation:** DHCP has one broad scope with undocumented reservations and no failover.
No IP scheme aligns device types to ranges. A DHCP server failure would knock out all
dynamic clients with no hot standby.

**Task:** Redesign the IP scheme, create proper reservations, configure DHCP failover with
WIN-DC02, and build a reusable IPAM documentation process for the expanding homelab.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
