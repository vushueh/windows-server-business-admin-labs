# Network Topology — Windows Server Lab

## Hyper-V Host

| Component | Value |
|-----------|-------|
| Hostname | WIN-PRQD8TJG04M |
| IP | 192.168.20.11 |
| Role | Hyper-V host for all Windows Server VMs |
| OS | Windows (hosts Hyper-V) |

## Virtual Switch Design (Target — Project 08)

```
vSwitch-External   → bridged to physical NIC → internet/LAN access
vSwitch-Internal   → host-only → VM-to-VM + host communication
vSwitch-VLAN10     → trunk to Proxmox side (optional — Project 13 integration)
```

## VM Inventory (Target State)

| VM | Hostname | IP | Role | Project |
|----|----------|----|------|--------|
| VM 01 | WIN-DC01 | TBD | Primary DC, AD DS, DNS, NPS | 01–03, 13 |
| VM 02 | WIN-FS01 | TBD | File Server | 06 |
| VM 03 | WIN-WS01 | TBD | Test workstation (Win 11) | 07 |

## Network Segments

| Segment | Subnet | Gateway | Notes |
|---------|--------|---------|-------|
| Management | 192.168.20.0/24 | 192.168.20.11 | Hyper-V management |
| AD domain | TBD | TBD | Defined in Project 01 |

## DNS Design (Target — Project 03)

```
WIN-DC01 DNS server — AD-integrated zone: chongong.local
  ├── Forwarders: 8.8.8.8, 1.1.1.1 (public DNS fallback)
  ├── Conditional forwarder: proxmox.local → 192.168.10.35
  └── A records: all lab servers and key infrastructure

All domain members: DNS = WIN-DC01 IP
WIN-DC01 itself: DNS = 127.0.0.1 (loopback — critical)
```
