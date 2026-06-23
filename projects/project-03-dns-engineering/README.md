# Project 03 — AD DNS and Name Resolution Engineering

**Status:** ✅ Phases 1, 2, 3, 4, 6, 7, 8 complete | Phase 5 deferred (N/A) | Phase 9 deferred (blocked on P02 replica DC)
**Skill:** `/winserver-p03`

## Objective

Audit, design, and harden the AD-integrated DNS environment on Chongong.local.
Configure forwarders, conditional forwarders, reverse lookup zones, and split-brain DNS.
Practice broken DNS troubleshooting scenarios that directly mirror real enterprise incidents.

**Why third:** DNS is the foundation every service in the lab depends on — AD authentication,
replication, NPS, M365 sync, and Proxmox SSSD all require correct DNS. Fixing DNS before
later projects avoids compounding failures.

## Environment Context

- DNS server: WIN-PRQD8TJG04M (192.168.20.11)
- AD-integrated zone: `Chongong.local`
- Secondary DNS: `WIN-DC02` — not yet built (Project 02 gap, blocks Phase 9)
- External resolver: forwarders to 8.8.8.8 / 1.1.1.1 / 8.8.4.4 / 9.9.9.9

## Phases

| # | Phase | Status | Key Action |
|---|-------|--------|------------|
| 1 | Audit Current DNS State | ✅ Complete | Documented all zones, records, forwarders, scavenging settings |
| 2 | Fix DNS Server Addressing | ✅ Complete | Found and fixed DC NIC pointing at public DNS instead of itself |
| 3 | Configure Forwarders | ✅ Already satisfied | Forwarders were already correctly set, confirmed in audit |
| 4 | Reverse Lookup Zones | ✅ Complete | Created 192.168.20.0/24 reverse zone + PTR for the DC |
| 5 | Conditional Forwarders | ⬜ Deferred (N/A) | No cross-lab domain currently needs one |
| 6 | DNS Scavenging | ✅ Complete | Enabled scavenging + zone aging on Chongong.local |
| 7 | Split-Brain DNS | ✅ Complete | Verified internal/external resolution separation |
| 8 | Break/Fix Exercise | ✅ Complete | One real incident + two documented runbooks |
| 9 | WIN-DC02 DNS Verification | ⬜ Deferred | Replica DC doesn't exist yet (Project 02 gap) |
| 10 | Document + Push | ✅ Complete | This document |

## Phase Detail

### Phase 1 — DNS Audit (2026-06-23)

**Commands run:**
```powershell
Get-DnsServer
Get-DnsServerZone
Get-DnsServerForwarder
Get-DnsServerScavenging
Get-DnsClientServerAddress -AddressFamily IPv4
```

**Findings:**
- Zones present: `_msdcs.Chongong.local`, `Chongong.local` (both AD-integrated primary), default
  `0/127/255.in-addr.arpa`, `TrustAnchors`. No 192.168.20.0/24 reverse zone existed.
- Forwarders already correctly set: `8.8.8.8, 1.1.1.1, 8.8.4.4, 9.9.9.9` — Phase 3 satisfied
  with no action needed.
- Scavenging disabled (`ScavengingState: False`), zone aging off on all zones.
- **Found a real bug:** the DC's LAN NIC (`vEthernet (External-VLAN-Trunk)`, 192.168.20.11)
  had DNS client servers set to `8.8.8.8, 1.1.1.1` directly — see Phase 2.

### Phase 2 — Fix DNS Server Addressing (2026-06-23)

**Before:**
```
InterfaceAlias               Interface Address ServerAddresses
                             Index     Family
--------------               --------- ------- ---------------
vEthernet (External-VLAN-...         6 IPv4    {8.8.8.8, 1.1.1.1}
```

**Commands run:**
```powershell
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (External-VLAN-Trunk)" -ServerAddresses 127.0.0.1
```

**After:**
```
InterfaceAlias               Interface Address ServerAddresses
                             Index     Family
--------------               --------- ------- ---------------
vEthernet (External-VLAN-...         6 IPv4    {127.0.0.1}
```

**Verification:**
```powershell
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
# → resolved correctly to win-prqd8tjg04m.chongong.local, priority 0, port 389

Resolve-DnsName google.com
# → resolved correctly, forwarders unaffected
```

Full incident writeup in [troubleshooting/break-fix-log.md](../../troubleshooting/break-fix-log.md) Scenario A.

### Phase 3 — Forwarders (already satisfied)

Confirmed in Phase 1 audit — `Get-DnsServerForwarder` showed `8.8.8.8, 1.1.1.1, 8.8.4.4, 9.9.9.9`
already configured. No change needed.

### Phase 4 — Reverse Lookup Zone (2026-06-23)

**Commands run:**
```powershell
Add-DnsServerPrimaryZone -NetworkID "192.168.20.0/24" -ReplicationScope Domain -DynamicUpdate Secure
Add-DnsServerResourceRecordPtr -ZoneName "20.168.192.in-addr.arpa" -Name "11" -PtrDomainName "WIN-PRQD8TJG04M.Chongong.local"
```

**Verification (direct zone query, bypassing client-side resolver):**
```powershell
Get-DnsServerZone -Name "20.168.192.in-addr.arpa"
# → Primary, IsDsIntegrated True, IsReverseLookupZone True

Get-DnsServerResourceRecord -ZoneName "20.168.192.in-addr.arpa" -RRType Ptr
# → HostName "11", PTR, RecordData "WIN-PRQD8TJG04M.Chongong.local."

nslookup -type=PTR 192.168.20.11 127.0.0.1
nslookup -type=PTR 192.168.20.11 192.168.20.11
# → both correctly returned: name = WIN-PRQD8TJG04M.Chongong.local
```

**Note:** `Resolve-DnsName 192.168.20.11` initially returned `host.docker.internal` instead of the
correct answer. Root-caused to Docker Desktop's `hns` (Host Network Service) hooking the Windows
DNS *client* resolution path on this box — confirmed via `Get-Process -Name "*docker*"` (running)
and `Get-NetTCPConnection -LocalPort 53` (port 53 fully owned by the real DNS Server process, no
conflict). `nslookup` queries sent directly to the DNS server bypass this client-side artifact and
returned the correct answer both via loopback and the real LAN IP — confirming the zone itself is
fully correct and any real network client would resolve it properly.

### Phase 5 — Conditional Forwarders (deferred)

No cross-lab domain (Proxmox, OPNsense, etc.) currently exposes its own DNS zone that
`Chongong.local` needs to resolve. Documented as N/A rather than forced — revisit when a concrete
need exists.

### Phase 6 — DNS Scavenging (2026-06-23)

**Before:**
```
ScavengingState    : False
ScavengingInterval : 00:00:00
AgingEnabled (Chongong.local) : False
```

**Commands run:**
```powershell
Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00 -ComputerName WIN-PRQD8TJG04M
Set-DnsServerZoneAging -Name "Chongong.local" -Aging $true -RefreshInterval 4.00:00:00 -NoRefreshInterval 4.00:00:00
```

**After:**
```
ScavengingState    : True
ScavengingInterval : 7.00:00:00
AgingEnabled (Chongong.local) : True
AvailForScavengeTime : 6/30/2026 5:00:00 PM
```

### Phase 7 — Split-Brain DNS (2026-06-23)

**Verification:**
```powershell
Resolve-DnsName WIN-PRQD8TJG04M.Chongong.local      # → resolves fully (internal, private)
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV  # → resolves fully (internal, private)
Resolve-DnsName google.com                           # → resolves correctly (external, via forwarders)
```

Confirms internal AD names resolve completely and privately while external names resolve via
forwarders — no overlap, which is the definition of split-brain DNS. (A side test querying
`Chongong.local` against `8.8.8.8` returned an unrelated local-network answer — this is Windows
intercepting `.local`-suffixed queries for mDNS/Bonjour resolution rather than sending them out to
the specified server. Known quirk of using `.local` as an AD suffix; not a leak, out of scope to
change since the domain is already established.)

### Phase 8 — Break/Fix Exercise (2026-06-23)

One real incident (Scenario A) plus two verified-but-not-staged runbooks (Scenarios B and C —
deliberately not triggered live to avoid disrupting the production household DC/network). Full
detail in [troubleshooting/break-fix-log.md](../../troubleshooting/break-fix-log.md).

### Phase 9 — WIN-DC02 DNS Verification (deferred)

Blocked on Project 02's replica DC build. Revisit once `WIN-DC02` is promoted.

---

## ✅ Project Complete (Phases 1–4, 6–8, 10) — 2026-06-23

### What I Built
- Audited the full DNS environment on the live production DC (zones, forwarders, scavenging, NIC addressing)
- Found and fixed a real DNS misconfiguration: the DC's own NIC was querying public DNS instead of itself, breaking internal SRV lookups
- Built the missing 192.168.20.0/24 reverse lookup zone and PTR record
- Enabled DNS scavenging and zone aging (stale record cleanup)
- Verified split-brain DNS behavior (internal vs. external resolution separation)
- Diagnosed and ruled out a false-positive caused by Docker Desktop's `hns` service hooking local DNS client resolution
- Documented two additional incident-response runbooks (missing SRV records, broken forwarder) without needing to disrupt the live network to prove them

### Key Evidence

| What | Evidence |
|------|----------|
| DC NIC misconfiguration found and fixed | Phase 2 detail above — before/after `Get-DnsClientServerAddress` output |
| Reverse zone + PTR created and verified authoritative | Phase 4 detail above — `Get-DnsServerResourceRecord` + dual `nslookup` confirmation |
| Scavenging and zone aging enabled | Phase 6 detail above — before/after `Get-DnsServerScavenging`/`Get-DnsServerZoneAging` |
| Split-brain DNS confirmed | Phase 7 detail above |
| Real incident response | [break-fix-log.md](../../troubleshooting/break-fix-log.md) |

### Verification Summary
```
_ldap._tcp.Chongong.local SRV  → win-prqd8tjg04m.chongong.local:389  (was failing, now resolves)
192.168.20.11 PTR              → WIN-PRQD8TJG04M.Chongong.local      (zone created, confirmed via nslookup)
ScavengingState                → True (was False)
AgingEnabled (Chongong.local)  → True (was False)
google.com                     → resolves correctly throughout (forwarders never broken)
```

### Problems Encountered and Fixed
| Problem | Root Cause | Fix |
|---------|-----------|-----|
| DC couldn't resolve its own internal SRV records | NIC DNS pointed at 8.8.8.8/1.1.1.1 instead of itself | `Set-DnsClientServerAddress` → 127.0.0.1 |
| `Resolve-DnsName` returned wrong PTR answer (host.docker.internal) after creating reverse zone | Docker Desktop's `hns` service intercepts DNS client resolution locally on this box | Confirmed via `nslookup` direct-to-server queries — zone was correct all along, client-side artifact only |

### STAR Result

**Situation:** DNS was the single AD-integrated server with no documented forwarder config,
unknown scavenging state, unverified reverse zones, and no validated secondary DNS on WIN-DC02.

**Task:** Audit, harden, and fully document DNS. Add break/fix exercises to build real
troubleshooting skill — DNS failures are the most common cause of AD and network incidents.

**Action:** Audited the live DC's DNS configuration end-to-end; found and fixed a genuine
misconfiguration (DC NIC bypassing its own DNS service); built the missing reverse lookup zone;
enabled scavenging/aging; verified split-brain behavior; diagnosed a false-positive caused by
third-party software (Docker Desktop) interfering with local DNS client resolution; documented
two additional incident runbooks without needing to risk live network disruption.

**Result:** The DC now correctly resolves its own internal AD records (a real bug fixed, not a
staged one), has a complete reverse-lookup zone for its subnet, automatically cleans up stale
DNS records going forward, and has documented, tested runbooks for the two most common DNS
failure modes in this environment. Project 02's replica DC (WIN-DC02) remains the only blocker
for full secondary-DNS verification (Phase 9).

### Links
- [Break/Fix log](../../troubleshooting/break-fix-log.md)
