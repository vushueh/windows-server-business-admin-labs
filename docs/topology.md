# Network Topology — Windows Server Lab

## Actual Server State (Discovered 2026-06-05; P02 updated 2026-06-23)

WIN-PRQD8TJG04M is a single physical/bare-metal host that currently runs EVERYTHING.
It is not just a Hyper-V host — it IS the Domain Controller.

| Component | Value |
|-----------|-------|
| Hostname | WIN-PRQD8TJG04M |
| LAN IP | 192.168.20.11 |
| Tailscale IP | 100.81.197.116 |
| OS | Windows Server 2022 Datacenter |
| Domain role | Primary Domain Controller (DomainRole=5) |
| Domain | Chongong.local / CHONGONG / Windows2016Domain |

## Roles Running on WIN-PRQD8TJG04M (All Active)

| Role | Service | Notes |
|------|---------|-------|
| AD-Domain-Services | AD DS (PDC) | Chongong.local domain |
| DNS | AD-integrated | Zone: Chongong.local |
| DHCP | Active scope | Lan-Network: 192.168.20.0/24, range .1–.254 |
| NPAS | NPS / RADIUS | radius-service account exists; purpose under investigation |
| FS-FileServer | File Server | Active |
| Hyper-V | 18 VMs inventoried on 2026-06-23 | This host IS the Hyper-V server |
| RDS (full farm) | Connection Broker, Gateway, Licensing, Session Host, Web Access | ⚠️ On DC — risk documented in P01 |
| IIS | Full install, ASP.NET, Windows Auth | ⚠️ On DC — likely serving RDS Web Access |

## Computers Joined to Chongong.local

| Computer account | Type | Notes |
|-----------------|------|-------|
| WIN-PRQD8TJG04M | DC | The server itself |
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

## Hyper-V VM Inventory (18 VMs — details finalized in Project 08)

Inventory to be documented in Project 08 (Hyper-V Operations).
Known from AD computer accounts: RADIUS01, GITEA are domain-joined VMs.

## Planned Migration VMs (Future Projects)

| VM | Project | Purpose |
|----|---------|--------|
| WIN-RDS01 | Project 08 | RD Session Host (migrate from DC) |
| WIN-RDWEB01 | Project 08 | RD Gateway + Web Access + Broker + Licensing (optional) |
| WIN-DC02 | Project 02 follow-up | Replica Domain Controller; VM not present as of 2026-06-23 |
| WIN-FS01 | Project 06 | Dedicated File Server |
| WIN-WS01 | Project 07 | Test Workstation (Win 11) |

## Network Segments

| Segment | Subnet | Gateway | Notes |
|---------|--------|---------|-------|
| Management / LAN | 192.168.20.0/24 | TBD | DHCP scope active |

## DNS Design (Current)

```
WIN-PRQD8TJG04M = DNS server (AD-integrated)
  Zone: Chongong.local (Primary, AD-integrated)
  Zone: _msdcs.Chongong.local (Primary, AD-integrated)
  Standard reverse lookup zones

DO NOT: set DC DNS to 8.8.8.8
Correct: DC DNS = 127.0.0.1 (loopback) + forwarders to 8.8.8.8 / 1.1.1.1 for public resolution
```

## Virtual Switch Design (Target — Project 08)

```
vSwitch-External   → bridged to physical NIC → internet/LAN access
vSwitch-Internal   → host-only → VM-to-VM + host communication  
```
