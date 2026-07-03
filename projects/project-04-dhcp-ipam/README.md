# Project 04 - DHCP/IPAM Integration and Windows Client Validation

**Status:** Planned - scope corrected for Route10 ownership
**Skill:** `/winserver-p04` - written when this project starts

## Summary

I am using this project to verify that Windows Server, Active Directory DNS, and
Hyper-V clients work correctly with the real homelab IP addressing design.

This project does **not** make Windows Server the main DHCP authority for the
homelab. Route10 is the main router and long-term DHCP/IP addressing authority.
OPNsense manages selected lab VLANs. Windows Server provides AD DNS, identity,
and validation that domain clients receive the correct network settings.

The full homelab IP addressing design now belongs in the Route10 project family:

- `homelab-route10-network-core`
- Route10 Project 02: Homelab IP Addressing and DHCP Authority
- Route10 Project 11: CML Integration and DHCP Migration Options

## Portfolio Summary

**Situation:** The original Windows Project 04 assumed Windows Server would own
homelab DHCP, but the real network design uses Route10 as the main router and
long-term DHCP/IP authority, with OPNsense managing selected lab VLANs.

**Task:** Correct the Windows project so it validates AD/DNS/client behavior
against the real network design instead of replacing Route10.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_

## Why This Project Still Belongs In Windows

Windows Server depends on correct IP addressing even when it does not own DHCP.
This project proves that:

- AD clients receive DNS settings that can resolve `Chongong.local`.
- Hyper-V VMs land on the correct network and can reach AD services.
- Any Windows DHCP role currently installed is understood before it is changed.
- Windows DHCP remains available as an optional future tool for isolated Hyper-V
  lab scopes, if that design is ever useful.

## Authority Model

| Area | Owner | Windows Project 04 role |
|------|-------|-------------------------|
| Main homelab routing | Route10 | Validate Windows reachability through the real network core. |
| Main homelab DHCP/IPAM | Route10 | Consume and verify correct DHCP options, not replace Route10. |
| Selected lab VLANs | OPNsense | Verify Windows/SOC/NetOps reachability where those VLANs interact with AD. |
| AD DNS and identity | Windows Server | Provide `Chongong.local`, SRV records, domain services, and verification. |
| CML isolated DHCP | CML lab | Leave as-is unless a future Route10 project intentionally changes it. |
| Optional isolated Hyper-V DHCP | Windows Server, future only | Document how it could be done for a lab-only vSwitch, not production. |

## Project Phases

| Phase | Name | Status |
|-------|------|--------|
| Phase 1 | Discover Current DHCP Roles | Planned |
| Phase 2 | Map Windows Dependencies To Route10/OPNsense IPAM | Planned |
| Phase 3 | Validate Domain Client DHCP/DNS Behavior | Planned |
| Phase 4 | Hyper-V VM Addressing Review | Planned |
| Phase 5 | Optional Windows DHCP Use Case Design | Planned - design only |
| Phase 6 | NetOps/IPAM Handoff | Planned |
| Phase 7 | Document Evidence And Push | Planned |

## Phase Details

### Phase 1 - Discover Current DHCP Roles

I will verify whether `WIN-PRQD8TJG04M` is currently authorized as a DHCP server
and whether it is serving any scopes or leases.

This is discovery only. I will not disable or redesign DHCP in this phase.

PowerShell / verification:

```powershell
# show whether the DHCP role is installed
Get-WindowsFeature DHCP

# show authorized DHCP servers in AD
Get-DhcpServerInDC

# show local IPv4 scopes if the DHCP role is present
Get-DhcpServerv4Scope

# show leases, reservations, exclusions, and options for any discovered scope
Get-DhcpServerv4Lease -ScopeId <scope-id>
Get-DhcpServerv4Reservation -ScopeId <scope-id>
Get-DhcpServerv4ExclusionRange -ScopeId <scope-id>
Get-DhcpServerv4ScopeOptionValue -ScopeId <scope-id>
```

Screenshots to capture:

- DHCP console or PowerShell output showing whether Windows DHCP is active.
- Any discovered scope/lease page, if Windows DHCP is serving something.

### Phase 2 - Map Windows Dependencies To Route10/OPNsense IPAM

I will map the Windows systems to the real network authority model instead of
assuming Windows owns DHCP.

What I need to document:

- which subnet each Windows server/client lives on
- which device provides gateway/DHCP for that subnet
- which DNS servers clients receive
- whether the subnet is Route10-owned or OPNsense-owned
- which addresses should be static or reserved

PowerShell / verification:

```powershell
Get-NetIPAddress -AddressFamily IPv4
Get-DnsClientServerAddress -AddressFamily IPv4
Get-ADComputer -Filter * -Properties IPv4Address,OperatingSystem |
  Select-Object Name, IPv4Address, OperatingSystem, DistinguishedName
```

Screenshots to capture:

- Windows network adapter IP/DNS settings.
- Route10 or OPNsense DHCP/IPAM page that owns the matching subnet.

### Phase 3 - Validate Domain Client DHCP/DNS Behavior

I will verify that domain clients receive network settings that support Active
Directory.

What I need to prove:

- the client gets an IP from the correct authority
- the client can resolve `Chongong.local`
- the client can resolve AD SRV records
- the client can still resolve public internet names through the approved DNS path

PowerShell / verification:

```powershell
ipconfig /all
Resolve-DnsName Chongong.local
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
Resolve-DnsName google.com
nltest /dsgetdc:Chongong.local
```

Screenshots to capture:

- `ipconfig /all` from a domain client.
- PowerShell DNS/SRV/DC locator verification.

### Phase 4 - Hyper-V VM Addressing Review

I will check how Hyper-V VMs are currently getting addresses and whether any VM
network should stay static, use Route10 reservations, use OPNsense DHCP, or use
a future isolated Windows DHCP scope.

PowerShell / verification:

```powershell
Get-VM | Select-Object Name, State
Get-VMNetworkAdapter -VMName * |
  Select-Object VMName, SwitchName, MacAddress, IPAddresses
Get-VMSwitch | Select-Object Name, SwitchType, NetAdapterInterfaceDescription
```

Screenshots to capture:

- Hyper-V Manager showing VM network placement.
- PowerShell output showing VM switch and adapter information.

### Phase 5 - Optional Windows DHCP Use Case Design

This is design-only unless Leonel explicitly approves a future implementation.

Windows DHCP could still be useful for a small isolated Hyper-V lab network, for
example:

- an internal-only vSwitch used for Windows testing
- a temporary classroom-style lab
- a disconnected training subnet
- a recovery/test environment that should not depend on Route10 or OPNsense

If we ever build that, it should be separate from the main homelab DHCP model.
It should not compete with Route10.

Example design pattern:

```powershell
# example only - do not run without an approved future phase
Add-DhcpServerv4Scope -Name "HyperV-Isolated-Lab" `
  -StartRange 172.20.40.100 `
  -EndRange 172.20.40.200 `
  -SubnetMask 255.255.255.0 `
  -Description "Optional isolated Hyper-V lab DHCP scope"
```

Screenshots to capture:

- Design diagram or table showing where an isolated Hyper-V DHCP scope would sit.
- No live scope screenshot unless a future approved implementation creates one.

### Phase 6 - NetOps/IPAM Handoff

I will turn the Windows-side findings into data that Route10, NetBox, LibreNMS,
ntopng, and future case studies can use.

What I need to produce:

- Windows server/client IP list
- DNS dependency list
- DHCP authority per subnet
- reservation candidates
- monitoring names and IPs
- cross-link to the Route10 IP addressing authority project

PowerShell / verification:

```powershell
Get-ADComputer -Filter * -Properties IPv4Address,OperatingSystem |
  Select-Object Name, IPv4Address, OperatingSystem, DistinguishedName |
  Export-Csv C:\Audit\windows-ipam-inventory.csv -NoTypeInformation
```

Screenshots to capture:

- Export command result or inventory table.
- Route10/NetOps handoff document once created.

### Phase 7 - Document Evidence And Push

I will document the final state without overstating Windows ownership of DHCP.

The final documentation should show:

- Windows DHCP discovery result
- real DHCP/IP authority map
- client DNS verification
- Hyper-V VM addressing review
- optional Windows DHCP design note
- links to the Route10 project family for the full IPAM strategy

Screenshots to capture:

- Project 04 README/evidence page after documentation is complete.
- GitHub project folder showing docs, scripts, and screenshots.

## Done Criteria

Project 04 is done when:

- We know whether Windows DHCP is active and for what.
- Windows clients are proven to work with the Route10/OPNsense DHCP design.
- Hyper-V VM addressing is documented.
- Optional Windows DHCP use is documented as design-only unless separately approved.
- The full homelab IP addressing strategy is linked to the Route10 repo.
