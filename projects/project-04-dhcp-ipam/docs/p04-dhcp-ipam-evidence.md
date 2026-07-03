# Project 04 DHCP/IPAM Evidence

**Date:** `2026-07-03`

**Method:** SSH to `WIN-PRQD8TJG04M` as `CHONGONG\adm-leonel`.

**Change level:** One Windows DHCP scope option was changed. Route10, OPNsense,
routing, NAT, VLANs, and firewall settings were not changed.

## Objective

I needed to validate how Windows Server participates in DHCP/IPAM now that
Project 03 has two working AD DNS servers. The goal was to avoid replacing
Route10 while still making sure any Windows-provided lease points clients at
the correct AD DNS servers.

## Discovery Summary

Windows DHCP is installed, authorized in AD, and active:

```powershell
Get-WindowsFeature DHCP
Get-DhcpServerInDC
Get-DhcpServerv4Scope
```

Important discovered state:

| Item | Result |
|------|--------|
| DHCP server | `win-prqd8tjg04m.chongong.local` |
| DHCP server IP | `192.168.20.11` |
| Scope | `192.168.20.0/24` |
| Scope name | `Lan-Network` |
| Scope state | Active |
| Range | `192.168.20.1-192.168.20.254` |
| Exclusions | `192.168.20.1-10`, `192.168.20.11-20` |
| Active leases found | One lease: `192.168.20.21` |

Raw evidence:

- [p04-live-discovery-raw.txt](p04-live-discovery-raw.txt)

## Configuration Change

Before Project 04, Windows DHCP scope option 6 advertised only the original DNS
server:

```text
DNS Servers: 192.168.20.11
```

After Project 03, the domain has two DNS servers. I updated option 6 so any
future Windows DHCP lease receives both AD DNS servers:

```powershell
Set-DhcpServerv4OptionValue `
  -ScopeId 192.168.20.0 `
  -DnsServer 192.168.20.11,192.168.20.12
```

Post-change verification:

```powershell
Get-DhcpServerv4OptionValue -ScopeId 192.168.20.0 -OptionId 6
```

Final result:

```text
DNS Servers: 192.168.20.11, 192.168.20.12
```

Raw evidence:

- [p04-post-change-verification.txt](p04-post-change-verification.txt)

## DNS Validation

I verified both DCs resolve:

- `Chongong.local`
- `_ldap._tcp.Chongong.local`
- `DESKTOP-QVM6OQN.localdomain`
- `google.com`

This proves Windows DHCP clients can receive AD DNS servers and still resolve
internal AD, Route10 `localdomain`, and external names.

## Hyper-V Addressing Review

I captured Hyper-V switches and VM NIC/IP data:

```powershell
Get-VMSwitch
Get-VM
Get-VMNetworkAdapter -VMName *
```

Key observations:

| VM / component | Switch | IP evidence |
|----------------|--------|-------------|
| `WIN-DC02` | `External-VLAN-Trunk` | `192.168.20.12` |
| `OPNsense` management | `External-VLAN-Trunk` | `192.168.20.253` |
| `OPNsense` WAN | `vSwitch-WAN` | `192.168.10.32` |
| `hyperv-test-01` | `vSwitch-LAN` | `192.168.10.213` |
| `hyperv-test-02` | `vSwitch-LAN` | `192.168.10.214` |
| `Kali-VLAN40` | `vSwitch-LAN` | `192.168.40.124` |
| `netflow01` | `vSwitch-LAN` | `192.168.10.216` |
| `rhel10-vlan10` | `vSwitch-LAN` | `192.168.10.211` |

## Cleanup Candidates

These are intentionally not changed in Project 04:

| Candidate | Why not changed now |
|-----------|---------------------|
| Temporary DHCP lease `192.168.20.21` | Not harmful; can expire or be removed in a maintenance cleanup |
| DHCP bindings on WSL/VirtualBox interfaces | Cleanup candidate, but binding changes can have side effects and should be reviewed separately |
| Windows DHCP service/scope deactivation | Not safe to disable while active until Route10 ownership for VLAN 20 DHCP is fully documented |

## Final Decision

Windows DHCP remains active and documented. The scope is safer now because it
advertises both AD DNS servers. Route10 remains the main IPAM authority for the
homelab, and no Route10 or OPNsense changes were made.
