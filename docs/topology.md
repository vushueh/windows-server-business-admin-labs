# Network Topology — Windows Server Lab

## Actual Server State (Discovered 2026-06-05; P02/P03 updated 2026-07-03)

WIN-PRQD8TJG04M is the original physical/bare-metal host. It is still the FSMO
holder and primary operations DC, but the domain now has a second DC:
`WIN-DC02`.

| Component | Value |
|-----------|-------|
| Hostname | WIN-PRQD8TJG04M |
| LAN IP | 192.168.20.11 |
| Tailscale IP | 100.81.197.116 |
| OS | Windows Server 2022 Datacenter |
| Domain role | PDC/FSMO holder |
| Domain | Chongong.local / CHONGONG / Windows2016Domain |

## Roles Running on WIN-PRQD8TJG04M (All Active)

| Role | Service | Notes |
|------|---------|-------|
| AD-Domain-Services | AD DS (PDC/FSMO holder) | Chongong.local domain |
| DNS | AD-integrated | Zones replicated to `WIN-DC02` |
| DHCP | Active scope | Lan-Network: 192.168.20.0/24, range .1–.254 |
| NPAS | NPS / RADIUS | radius-service account exists; purpose under investigation |
| FS-FileServer | File Server | Active |
| Hyper-V | VM inventory to refresh in Project 08; `WIN-DC02` added on 2026-07-03 | This host IS the Hyper-V server |
| RDS (full farm) | Connection Broker, Gateway, Licensing, Session Host, Web Access | ⚠️ On DC — risk documented in P01 |
| IIS | Full install, ASP.NET, Windows Auth | ⚠️ On DC — likely serving RDS Web Access |

## Computers Joined to Chongong.local

| Computer account | Type | Notes |
|-----------------|------|-------|
| WIN-PRQD8TJG04M | DC | The server itself |
| WIN-DC02 | DC | Replica DC, DNS, Global Catalog |
| RADIUS01 | Server/VM | Unknown VM — investigate in P13 |
| GITEA | Server/VM | Gitea instance |
| DESKTOP-QVM6OQN | Workstation | Domain-joined client |
| DESKTOP-576LPTN | Workstation | Domain-joined client |
| DESKTOP-PGMHP9F | Workstation | Domain-joined client |
| DESKTOP-VHPSR2K | Workstation | Domain-joined client |
| DESKTOP-5ISQOPR | Workstation | Domain-joined client |
| DESKTOP-HD87LV2 | Workstation | Domain-joined client |

## AD Placement After Project 02

| Object type | Current OU |
|-------------|------------|
| Department OUs | `OU=<Department>,OU=ManagedUsers,DC=Chongong,DC=local` |
| Workstations | `OU=Workstations,OU=ManagedComputers,DC=Chongong,DC=local` |
| Member servers | `OU=Servers,OU=ManagedComputers,DC=Chongong,DC=local` |
| Global groups | `OU=GlobalGroups,OU=Groups,DC=Chongong,DC=local` |
| Domain local groups | `OU=DomainLocalGroups,OU=Groups,DC=Chongong,DC=local` |

## Hyper-V VM Inventory (Details finalized in Project 08)

Inventory to be documented in Project 08 (Hyper-V Operations). Known from AD
computer accounts: `RADIUS01`, `GITEA`, and `WIN-DC02` are domain-joined VMs.

## Domain Controllers

| DC | IP | Roles |
|----|----|-------|
| WIN-PRQD8TJG04M | 192.168.20.11 | FSMO holder, AD DS, DNS, Global Catalog |
| WIN-DC02 | 192.168.20.12 | Replica DC, AD DS, DNS, Global Catalog |

## Planned Migration VMs (Future Projects)

| VM | Project | Purpose |
|----|---------|--------|
| WIN-RDS01 | Project 08 | RD Session Host (migrate from DC) |
| WIN-RDWEB01 | Project 08 | RD Gateway + Web Access + Broker + Licensing (optional) |
| WIN-FS01 | Project 06 | Dedicated File Server |
| WIN-WS01 | Project 07 | Test Workstation (Win 11) |

## Network Segments

| Segment | Subnet | Gateway | Notes |
|---------|--------|---------|-------|
| Management / LAN | 192.168.20.0/24 | 192.168.20.1 | Windows DHCP scope exists; first 20 addresses excluded/reserved for infrastructure |

## Network DNS And Gateway Dependencies

| Device / service | IP | Role in this Windows project |
|------------------|----|------------------------------|
| Route10 | 192.168.20.1 | VLAN 20 gateway and DNS target for the `localdomain` conditional forwarder |
| Route10 | 192.168.10.1 / 192.168.1.1 | Additional Route10 DNS listener addresses discovered during Phase 5 validation |
| Pi-hole | 192.168.10.26 | Existing DNS resolver on VLAN 10; discovered but not used as a conditional forwarder target |
| OPNsense | 192.168.20.253 | VLAN 20 interface discovered during Phase 5 validation; not used for DNS forwarding |

## DNS Design (Current)

```
WIN-PRQD8TJG04M = DNS server (AD-integrated)
  IP: 192.168.20.11
  DNS service listens on: 192.168.20.11
  DNS client order: 192.168.20.12, 192.168.20.11

WIN-DC02 = DNS server (AD-integrated)
  IP: 192.168.20.12
  DNS client order: 192.168.20.11, 192.168.20.12

  Zone: Chongong.local (Primary, AD-integrated)
  Zone: _msdcs.Chongong.local (Primary, AD-integrated)
  Zone: 20.168.192.in-addr.arpa (Primary, AD-integrated)
  Conditional forwarder: localdomain -> Route10 192.168.20.1
  Forwarders: 8.8.8.8, 1.1.1.1, 8.8.4.4, 9.9.9.9

DO NOT: set DC DNS to 8.8.8.8
Correct: DC DNS clients use AD DNS servers. Public resolvers belong only in DNS
server forwarders.

Route10 localdomain forwarding note:
  Windows DNS forwards only *.localdomain to Route10 at 192.168.20.1.
  Route10 DHCP/DNS, routing, NAT, VLAN, and firewall configuration were not
  changed by Project 03.
```

## Virtual Switch Design (Target — Project 08)

```
vSwitch-External   → bridged to physical NIC → internet/LAN access
vSwitch-Internal   → host-only → VM-to-VM + host communication  
```
