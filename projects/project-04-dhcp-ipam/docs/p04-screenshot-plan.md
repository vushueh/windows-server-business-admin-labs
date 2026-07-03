# Project 04 Screenshot Plan

Screenshots are optional for this project because the primary evidence was
captured through SSH command output. If screenshots are added later, save them
under:

```text
projects/project-04-dhcp-ipam/screenshots/
```

## Planned Screenshots

| Phase | Filename | What it proves |
|-------|----------|----------------|
| Phase 1 | `phase1-01-windows-dhcp-scope-discovery.png` | Windows DHCP role, scope, leases, exclusions, and options were discovered |
| Phase 2 | `phase2-01-windows-ipam-dependencies.png` | Windows IP, route, DNS client, and AD computer dependencies were mapped |
| Phase 3 | `phase3-01-dhcp-option6-and-dns-validation.png` | DHCP option 6 includes both DCs and DNS validation works |
| Phase 4 | `phase4-01-hyperv-addressing-review.png` | Hyper-V switches and VM IP placement were reviewed |
| Phase 6 | `phase6-01-ipam-handoff.png` | Windows-side IPAM handoff is documented |

## Capture Commands

### Phase 1

```powershell
Get-DhcpServerv4Scope
Get-DhcpServerv4Lease -ScopeId 192.168.20.0
Get-DhcpServerv4ExclusionRange -ScopeId 192.168.20.0
Get-DhcpServerv4OptionValue -ScopeId 192.168.20.0
```

### Phase 2

```powershell
Get-NetIPAddress -AddressFamily IPv4
Get-NetRoute -DestinationPrefix "0.0.0.0/0"
Get-DnsClientServerAddress -AddressFamily IPv4
```

### Phase 3

```powershell
Get-DhcpServerv4OptionValue -ScopeId 192.168.20.0 -OptionId 6
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.11
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV -Server 192.168.20.12
Resolve-DnsName DESKTOP-QVM6OQN.localdomain -Server 192.168.20.11 -DnsOnly -NoHostsFile
Resolve-DnsName DESKTOP-QVM6OQN.localdomain -Server 192.168.20.12 -DnsOnly -NoHostsFile
```

### Phase 4

```powershell
Get-VMSwitch
Get-VMNetworkAdapter -VMName *
```

### Phase 6

Open [p04-ipam-handoff.md](p04-ipam-handoff.md) and capture the infrastructure
address and DHCP scope tables.
