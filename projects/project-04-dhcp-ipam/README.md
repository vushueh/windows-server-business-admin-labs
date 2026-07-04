# Project 04 - DHCP/IPAM Integration and Windows Client Validation

**Status:** Complete on `2026-07-03`

**System:** `WIN-PRQD8TJG04M`, `WIN-DC02`, Route10, OPNsense, and Hyper-V VM
network inventory

**Skill:** `/winserver-p04`

## Summary

I completed Project 04 by validating how Windows Server fits into the real
homelab IP addressing model. I did not make Windows Server the main DHCP
authority. Route10 remains the main router and long-term DHCP/IPAM authority,
with OPNsense handling selected lab VLANs.

The live work was intentionally conservative. I discovered the current Windows
DHCP state, verified AD DNS behavior across both DCs, reviewed Hyper-V VM
addressing, and made one safe Windows-side DHCP correction: VLAN 20 DHCP option
6 now advertises both AD DNS servers, `192.168.20.11` and `192.168.20.12`.

## Portfolio Summary

**Situation:** The earlier Project 04 design assumed Windows Server might own
homelab DHCP, but the live network uses Route10 and OPNsense for the real
addressing model.

**Task:** Validate DHCP/IPAM and DNS behavior without breaking working routing,
Route10, OPNsense, or current Hyper-V lab networks.

**Action:** I connected to `WIN-PRQD8TJG04M`, audited the Windows DHCP role,
scope, bindings, leases, exclusions, and options; mapped Windows and Hyper-V IP
dependencies; verified AD DNS and Route10 `localdomain` forwarding through both
DCs; and updated the Windows DHCP scope DNS option to include both DCs.

**Result:** Windows DHCP is documented instead of assumed, AD DNS redundancy is
included in the Windows DHCP scope, Route10 remains untouched, and the project
now has a Windows-side IPAM handoff for future Route10, NetOps, SOC, and Hyper-V
work.

## What Changed

| Area | Result |
|------|--------|
| Windows DHCP role | Installed, AD-authorized, and active on `WIN-PRQD8TJG04M` |
| Windows DHCP scope | `192.168.20.0/24`, named `Lan-Network`, still active |
| DHCP option 6 | Updated from `192.168.20.11` only to `192.168.20.11, 192.168.20.12` |
| DHCP exclusions | `192.168.20.1-10` and `192.168.20.11-20` reserved/excluded |
| Current leases | One temporary lease remains: `192.168.20.21` from the original `WIN-DC02` install name |
| Route10 | No configuration changed; remains gateway/IPAM authority |
| OPNsense | No configuration changed; VLAN 20 interface documented as `192.168.20.253` |
| Hyper-V addressing | VM switch and VM IP inventory captured |

## Authority Model

| Area | Owner | Project 04 result |
|------|-------|-------------------|
| Main homelab routing | Route10 | Left unchanged |
| Main homelab DHCP/IPAM | Route10 | Left unchanged and linked as the authority family |
| Selected lab VLANs | OPNsense | Left unchanged; interface/IP placement documented |
| AD DNS and identity | Windows Server | Verified through both DCs |
| Windows DHCP scope | Windows Server | Documented and corrected to advertise both AD DNS servers |
| Optional isolated Hyper-V DHCP | Future design only | Documented as possible but not implemented |

## Project Phases

| Phase | Name | Status |
|-------|------|--------|
| Phase 1 | Discover Current DHCP Roles | Complete |
| Phase 2 | Map Windows Dependencies To Route10/OPNsense IPAM | Complete |
| Phase 3 | Validate Domain Client DHCP/DNS Behavior | Complete |
| Phase 4 | Hyper-V VM Addressing Review | Complete |
| Phase 5 | Optional Windows DHCP Use Case Design | Complete - design only |
| Phase 6 | NetOps/IPAM Handoff | Complete |
| Phase 7 | Document Evidence And Push | Complete |

Technical evidence:

- DHCP/IPAM evidence: [docs/p04-dhcp-ipam-evidence.md](docs/p04-dhcp-ipam-evidence.md)
- IPAM handoff: [docs/p04-ipam-handoff.md](docs/p04-ipam-handoff.md)
- Netboot DHCP option cleanup: [docs/p04-netboot-cleanup-2026-07-04.md](docs/p04-netboot-cleanup-2026-07-04.md)
- AD DNS follow-up: [docs/p04-ad-dns-followup-2026-07-04.md](docs/p04-ad-dns-followup-2026-07-04.md)
- Raw discovery output: [docs/p04-live-discovery-raw.txt](docs/p04-live-discovery-raw.txt)
- Post-change verification: [docs/p04-post-change-verification.txt](docs/p04-post-change-verification.txt)
- Screenshot plan: [docs/p04-screenshot-plan.md](docs/p04-screenshot-plan.md)

## Phase Details

### Phase 1 - Discover Current DHCP Roles

I verified the Windows DHCP role before changing anything.

What I found:

- DHCP Server is installed on `WIN-PRQD8TJG04M`.
- The server is AD-authorized as `win-prqd8tjg04m.chongong.local` at
  `192.168.20.11`.
- The active scope is `192.168.20.0/24`, named `Lan-Network`.
- The scope had one active lease: `192.168.20.21`, tied to the temporary
  `WIN-DC02` install hostname.

Why it matters: Windows DHCP exists and is active, so it must be documented
before any future cleanup. I did not disable it because that would be a broader
maintenance decision.

PowerShell proof:

```powershell
Get-WindowsFeature DHCP
Get-DhcpServerInDC
Get-DhcpServerv4Scope
Get-DhcpServerv4Lease -ScopeId 192.168.20.0
Get-DhcpServerv4ExclusionRange -ScopeId 192.168.20.0
Get-DhcpServerv4OptionValue -ScopeId 192.168.20.0
```

Optional screenshot if GUI evidence is added:
`screenshots/phase1-01-windows-dhcp-scope-discovery.png`

### Phase 2 - Map Windows Dependencies To Route10/OPNsense IPAM

I mapped the Windows dependencies to the real network authority model.

What I found:

- VLAN 20 gateway is Route10 at `192.168.20.1`.
- `WIN-PRQD8TJG04M` is static at `192.168.20.11`.
- `WIN-DC02` is static at `192.168.20.12`.
- OPNsense has a VLAN 20 interface at `192.168.20.253`.
- Route10 `localdomain` DNS works through AD DNS after Project 03 Phase 5.

Why it matters: this keeps Windows aligned with the real network instead of
creating a competing DHCP/IPAM design.

PowerShell proof:

```powershell
Get-NetIPAddress -AddressFamily IPv4
Get-NetRoute -DestinationPrefix "0.0.0.0/0"
Get-DnsClientServerAddress -AddressFamily IPv4
Get-ADComputer -Filter * -Properties IPv4Address,OperatingSystem,LastLogonDate
```

Optional screenshot if GUI evidence is added:
`screenshots/phase2-01-windows-ipam-dependencies.png`

### Phase 3 - Validate Domain Client DHCP/DNS Behavior

I validated the DNS path clients need after receiving network settings.

What I proved:

- `Chongong.local` resolves through both DCs.
- `_ldap._tcp.Chongong.local` returns both domain controllers.
- `DESKTOP-QVM6OQN.localdomain` resolves through AD DNS to Route10's
  `localdomain` record.
- External DNS still resolves through both DCs.

I also corrected the Windows DHCP scope so any future client that receives a
lease from the Windows scope gets both AD DNS servers.

PowerShell change:

```powershell
Set-DhcpServerv4OptionValue `
  -ScopeId 192.168.20.0 `
  -DnsServer 192.168.20.11,192.168.20.12
```

PowerShell verification:

```powershell
Get-DhcpServerv4OptionValue -ScopeId 192.168.20.0 -OptionId 6
Resolve-DnsName Chongong.local -Server 192.168.20.11 -DnsOnly -NoHostsFile
Resolve-DnsName Chongong.local -Server 192.168.20.12 -DnsOnly -NoHostsFile
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.11
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.12
Resolve-DnsName DESKTOP-QVM6OQN.localdomain -Server 192.168.20.11 -DnsOnly -NoHostsFile
Resolve-DnsName DESKTOP-QVM6OQN.localdomain -Server 192.168.20.12 -DnsOnly -NoHostsFile
```

Optional screenshot if GUI evidence is added:
`screenshots/phase3-01-dhcp-option6-and-dns-validation.png`

### Phase 4 - Hyper-V VM Addressing Review

I reviewed the Hyper-V switch layout and VM IP inventory.

What I found:

- `External-VLAN-Trunk` carries the Windows DC VLAN 20 path.
- `vSwitch-LAN` carries multiple lab VLAN workloads.
- `vSwitch-WAN` carries VLAN 10/WAN-side lab workloads.
- `WIN-DC02` is attached to `External-VLAN-Trunk` at `192.168.20.12`.
- OPNsense has adapters on `External-VLAN-Trunk`, `vSwitch-LAN`, and
  `vSwitch-WAN`.

Why it matters: future DHCP/IPAM, monitoring, and reservation work needs to know
which Hyper-V networks each VM uses before moving or reserving addresses.

PowerShell proof:

```powershell
Get-VMSwitch
Get-VM
Get-VMNetworkAdapter -VMName *
```

Optional screenshot if GUI evidence is added:
`screenshots/phase4-01-hyperv-addressing-review.png`

### Phase 5 - Optional Windows DHCP Use Case Design

I documented Windows DHCP as an optional future design, not as the main homelab
DHCP authority.

Appropriate future use cases:

- isolated Hyper-V training subnet
- disconnected recovery lab
- temporary classroom subnet
- lab-only network that should not depend on Route10 or OPNsense

Decision: I did not create a new scope. Any future Windows DHCP scope should be
isolated from the production/home VLANs and approved separately.

### Phase 6 - NetOps/IPAM Handoff

I created the Windows-side IPAM handoff for Route10, NetOps, monitoring, and
future case-study work.

Handoff file:

- [docs/p04-ipam-handoff.md](docs/p04-ipam-handoff.md)

It lists static infrastructure addresses, discovered Hyper-V VM addresses,
reservation candidates, and cleanup candidates.

### Phase 7 - Document Evidence And Push

I documented the final state without overstating Windows ownership of DHCP.

What I documented:

- Windows DHCP role and scope state.
- The DNS option correction from one DC to both DCs.
- Route10/OPNsense authority model.
- Domain DNS verification.
- Hyper-V addressing inventory.
- Optional isolated Windows DHCP design.

## Verified State

| Check | Result |
|-------|--------|
| Windows DHCP role | Installed and AD-authorized |
| Windows DHCP scope | `192.168.20.0/24`, active, documented |
| DHCP option 6 | `192.168.20.11, 192.168.20.12` |
| DHCP options 66/67 | Removed on `2026-07-04`; retired `netboot.xyz` is no longer advertised |
| DHCP exclusions | `.1-.10` and `.11-.20` reserved |
| Route10 gateway | `192.168.20.1` |
| AD DNS | Functional for DHCP option targets, but `WIN-PRQD8TJG04M` has multiple A records that need Windows-side cleanup |
| Hyper-V addressing | Switches and VM IPs documented |
| Route10 configuration | Not changed |
| OPNsense configuration | Not changed |

## Decisions Not Changed

- I did not disable Windows DHCP because it is active and still has a lease.
- I did not delete the temporary `192.168.20.21` lease.
- I did not change Route10 DHCP/IPAM, routing, NAT, VLAN, or firewall settings.
- I did not change OPNsense DHCP/DNS settings.
- I did not unbind DHCP from non-production adapters yet; that is a cleanup
  candidate after a maintenance review.
- I did not clean up the extra `WIN-PRQD8TJG04M` DNS A records found during the
  2026-07-04 Route10 Project 02 follow-up.

## Next Project Impact

Project 05 can proceed with GPO security baselines. Project 04 also gives
Route10/NetOps a Windows-side inventory for future reservation and monitoring
work.
