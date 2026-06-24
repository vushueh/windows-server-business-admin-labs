# Project 03 Screenshot and Evidence Plan

Use this plan when adding images for Project 03. Screenshots go under:

```text
projects/project-03-dns-engineering/screenshots/
```

For completed phases, capture two screenshots when possible. For deferred or
partially complete phases, capture one screenshot proving why the phase is
deferred or blocked.

## Screenshot Rules

- Do not capture passwords, private keys, recovery keys, or credential prompts.
- Hide unrelated browser tabs, notifications, and personal files.
- Use phase-based filenames so images sort naturally.
- Keep each screenshot tied to one thing it proves.

## Phase Screenshot Outline

| Phase | Status | Screenshots to capture |
|-------|--------|------------------------|
| Phase 1 | Complete | 2 screenshots |
| Phase 2 | Complete | 2 screenshots |
| Phase 3 | Complete - already satisfied | 2 screenshots |
| Phase 4 | Complete | 2 screenshots |
| Phase 5 | Deferred - not needed yet | 1 screenshot |
| Phase 6 | Complete | 2 screenshots |
| Phase 7 | Complete | 2 screenshots |
| Phase 8 | Complete | 2 screenshots |
| Phase 9 | Pending - blocked by `WIN-DC02` | 1 screenshot |
| Phase 10 | Complete | 2 screenshots |

## Phase 1 - Audit Current DNS State

### Image: `phase1-01-dns-zones-and-forwarders.png`

- **What it shows:** DNS zones and forwarders on `WIN-PRQD8TJG04M`.
- **Manual check:** DNS Manager -> server -> Forwarders and Forward Lookup Zones.
- **Why:** Proves the starting DNS configuration was audited.
- **PowerShell equivalent:**

```powershell
Get-DnsServerZone
Get-DnsServerForwarder
```

### Image: `phase1-02-dns-client-before-fix.png`

- **What it shows:** The DC LAN NIC DNS client settings before Phase 2.
- **Manual check:** Network adapter IPv4 DNS settings.
- **Why:** Shows the real problem found during audit: public DNS on the DC NIC.
- **PowerShell equivalent:**

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

## Phase 2 - Fix DNS Server Addressing

### Image: `phase2-01-dns-client-after-fix.png`

- **What it shows:** The LAN NIC now points to `127.0.0.1`.
- **Manual check:** Network adapter IPv4 DNS settings.
- **Why:** Proves the DC now queries its own AD DNS service.
- **PowerShell equivalent:**

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

### Image: `phase2-02-ad-srv-record-resolution.png`

- **What it shows:** `_ldap._tcp.Chongong.local` resolves correctly.
- **Manual check:** PowerShell result.
- **Why:** Proves AD service discovery works after the fix.
- **PowerShell equivalent:**

```powershell
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
```

## Phase 3 - Configure Forwarders

### Image: `phase3-01-dns-forwarders.png`

- **What it shows:** Configured DNS forwarders.
- **Manual check:** DNS Manager -> server properties -> Forwarders.
- **Why:** Proves public DNS resolution goes through the DNS role, not the DC NIC.
- **PowerShell equivalent:**

```powershell
Get-DnsServerForwarder
```

### Image: `phase3-02-external-resolution.png`

- **What it shows:** External name resolution works.
- **Manual check:** PowerShell result.
- **Why:** Proves forwarders were not broken by Phase 2.
- **PowerShell equivalent:**

```powershell
Resolve-DnsName google.com
```

## Phase 4 - Reverse Lookup Zones

### Image: `phase4-01-reverse-zone-created.png`

- **What it shows:** `20.168.192.in-addr.arpa` reverse zone exists.
- **Manual check:** DNS Manager -> Reverse Lookup Zones.
- **Why:** Proves reverse DNS was added for the Windows subnet.
- **PowerShell equivalent:**

```powershell
Get-DnsServerZone -Name "20.168.192.in-addr.arpa"
```

### Image: `phase4-02-ptr-record-verified.png`

- **What it shows:** PTR record for `192.168.20.11`.
- **Manual check:** DNS Manager -> reverse zone -> PTR record.
- **Why:** Proves the DC has a reverse record.
- **PowerShell equivalent:**

```powershell
Get-DnsServerResourceRecord -ZoneName "20.168.192.in-addr.arpa" -RRType Ptr
nslookup -type=PTR 192.168.20.11 127.0.0.1
```

## Phase 5 - Conditional Forwarders

### Image: `phase5-01-conditional-forwarders-none-needed.png`

- **What it shows:** No conditional forwarder is currently needed.
- **Manual check:** DNS Manager -> Conditional Forwarders.
- **Why:** Proves the phase was intentionally deferred, not forgotten.
- **PowerShell equivalent:**

```powershell
Get-DnsServerConditionalForwarderZone
```

## Phase 6 - DNS Scavenging

### Image: `phase6-01-scavenging-enabled.png`

- **What it shows:** DNS scavenging enabled on the server.
- **Manual check:** DNS Manager -> server -> Set Aging/Scavenging for All Zones.
- **Why:** Proves stale-record cleanup is enabled.
- **PowerShell equivalent:**

```powershell
Get-DnsServerScavenging
```

### Image: `phase6-02-zone-aging-enabled.png`

- **What it shows:** Aging enabled on `Chongong.local`.
- **Manual check:** DNS Manager -> `Chongong.local` zone properties -> Aging.
- **Why:** Scavenging only works correctly when records/zones are aging.
- **PowerShell equivalent:**

```powershell
Get-DnsServerZoneAging -Name "Chongong.local"
```

## Phase 7 - Split-Brain DNS

### Image: `phase7-01-internal-ad-resolution.png`

- **What it shows:** Internal AD names resolve.
- **Manual check:** PowerShell result.
- **Why:** Proves private AD DNS is working.
- **PowerShell equivalent:**

```powershell
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
```

### Image: `phase7-02-external-forwarder-resolution.png`

- **What it shows:** External public names resolve.
- **Manual check:** PowerShell result.
- **Why:** Proves public DNS still works through forwarders.
- **PowerShell equivalent:**

```powershell
Resolve-DnsName google.com
```

## Phase 8 - Break/Fix Exercise

### Image: `phase8-01-real-dns-incident-fixed.png`

- **What it shows:** The real NIC DNS incident is fixed.
- **Manual check:** PowerShell output showing NIC DNS and SRV resolution.
- **Why:** This is portfolio evidence of a real break/fix event.
- **PowerShell equivalent:**

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
```

### Image: `phase8-02-break-fix-log.png`

- **What it shows:** The break/fix log in the repo.
- **Manual check:** Open `troubleshooting/break-fix-log.md`.
- **Why:** Proves the troubleshooting process was documented.
- **PowerShell equivalent:** Not applicable; documentation evidence.

## Phase 9 - `WIN-DC02` DNS Verification

### Image: `phase9-01-win-dc02-dns-verification-pending.png`

- **What it shows:** `WIN-DC02` does not exist yet, so secondary DNS verification is pending.
- **Manual check:** Hyper-V Manager and ADUC Domain Controllers OU.
- **Why:** Proves the phase is blocked by the missing replica DC, not by DNS work.
- **PowerShell equivalent:**

```powershell
Get-VM WIN-DC02
Get-ADComputer -LDAPFilter '(name=WIN-DC02)'
```

## Phase 10 - Document And Push

### Image: `phase10-01-project-03-github-status.png`

- **What it shows:** Project 03 documentation committed and pushed.
- **Manual check:** GitHub project folder or local `git log`.
- **Why:** Proves the work is documented in the repo.
- **PowerShell equivalent:**

```bash
git log --oneline -5
```

### Image: `phase10-02-project-03-files.png`

- **What it shows:** Project 03 README, troubleshooting log, and screenshot plan files.
- **Manual check:** GitHub project folder.
- **Why:** Proves technical evidence is organized under the project.
- **PowerShell equivalent:**

```bash
find projects/project-03-dns-engineering -maxdepth 3 -type f | sort
```
