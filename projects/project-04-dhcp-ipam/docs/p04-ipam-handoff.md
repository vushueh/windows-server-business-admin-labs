# Project 04 IPAM Handoff

**Date:** `2026-07-03`

This file is the Windows-side handoff for Route10, NetOps, monitoring, and
future reservation cleanup.

## Infrastructure Addresses

| Name | IP | Owner / role | Recommendation |
|------|----|--------------|----------------|
| Route10 | `192.168.20.1` | VLAN 20 gateway and `localdomain` DNS target | Keep static/reserved in Route10 |
| `WIN-PRQD8TJG04M` | `192.168.20.11` | PDC/FSMO, AD DNS, Hyper-V host | Keep static |
| `WIN-DC02` | `192.168.20.12` | Replica DC, AD DNS, Global Catalog | Keep static |
| OPNsense VLAN 20 | `192.168.20.253` | OPNsense management/VLAN 20 interface | Keep static/reserved |
| Temporary lease | `192.168.20.21` | Old `WIN-DC02` install hostname | Cleanup candidate |

## DHCP Scope State

| Setting | Value |
|---------|-------|
| Windows DHCP scope | `192.168.20.0/24` |
| Scope name | `Lan-Network` |
| Scope state | Active |
| Scope range | `192.168.20.1-192.168.20.254` |
| Exclusions | `.1-.10`, `.11-.20` |
| Router option | `192.168.20.1` |
| DNS option | `192.168.20.11, 192.168.20.12` |
| DNS suffix option | `Chongong.local` |

## Hyper-V VM Addressing Snapshot

| VM / component | Switch | Discovered IP |
|----------------|--------|---------------|
| `WIN-DC02` | `External-VLAN-Trunk` | `192.168.20.12` |
| `OPNsense` management | `External-VLAN-Trunk` | `192.168.20.253` |
| `OPNsense` WAN | `vSwitch-WAN` | `192.168.10.32` |
| `hyperv-test-01` | `vSwitch-LAN` | `192.168.10.213` |
| `hyperv-test-02` | `vSwitch-LAN` | `192.168.10.214` |
| `Kali-VLAN40` | `vSwitch-LAN` | `192.168.40.124` |
| `netflow01` | `vSwitch-LAN` | `192.168.10.216` |
| `rhel10-vlan10` | `vSwitch-LAN` | `192.168.10.211` |

Some VM adapters did not report guest IPs through Hyper-V integration services.
Those should be verified from the guest OS or network inventory before creating
reservations.

## Domain Computer Inventory Snapshot

| Computer | IP from AD | Notes |
|----------|------------|-------|
| `WIN-PRQD8TJG04M` | `192.168.20.11` | DC |
| `WIN-DC02` | `192.168.20.12` | DC |
| `DESKTOP-QVM6OQN` | `192.168.50.28` | Route10 `localdomain` proof record |
| `RADIUS01` | Not reported | Future Project 13 review |
| `GITEA` | Not reported | Future server inventory review |

## Reservation Candidates

| Candidate | Why |
|-----------|-----|
| `WIN-PRQD8TJG04M` | Core AD/DNS infrastructure |
| `WIN-DC02` | Core AD/DNS infrastructure |
| OPNsense VLAN 20 interface | Firewall management/routing dependency |
| Monitoring/security VMs | SOC tools should have stable monitoring targets |
| `DESKTOP-QVM6OQN` | Active domain workstation on VLAN 50; useful Route10 DNS proof target |

## Cleanup Candidates

| Candidate | Suggested timing |
|-----------|------------------|
| Remove temporary DHCP lease `192.168.20.21` | Maintenance cleanup after confirming no host uses it |
| Review Windows DHCP bindings on WSL/VirtualBox adapters | Project 08/maintenance window |
| Decide whether Windows DHCP should remain active for VLAN 20 | After Route10 DHCP/IPAM ownership is fully documented |

## Cross-Family Links

| Family | How this handoff helps |
|--------|------------------------|
| Route10 | Confirms Windows DNS/DHCP expectations and reservation candidates |
| NetOps | Provides VM/IP inventory for monitoring and diagrams |
| SOC/Wazuh | Identifies stable Windows and Hyper-V systems for log/agent planning |
| OPNsense | Records the VLAN 20 management interface and Hyper-V switch placement |
