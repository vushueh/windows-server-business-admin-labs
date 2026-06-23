# Break/Fix Log — Project 03 (AD DNS Engineering)

## Break/Fix — DC NIC Pointed at Public DNS Instead of Itself — 2026-06-23

**Phase:** P03 Phase 2 (discovered during Phase 1 audit)
**Status:** Real incident — actually occurred and was fixed live.

**What I did:** Ran the Phase 1 DNS audit against the live DC (WIN-PRQD8TJG04M, 192.168.20.11).

**Symptom:**
```
PS> Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
Resolve-DnsName : _ldap._tcp.Chongong.local : DNS name does not exist
```
This is the AD authentication/replication failure symptom described in the project's Scenario B —
except it surfaced for real, unprompted, during a routine audit.

**Diagnosis:**
```powershell
Get-DnsServerResourceRecord -ZoneName "_msdcs.Chongong.local" -RRType Srv
Get-DnsServerResourceRecord -ZoneName "Chongong.local" -RRType Srv
```
Confirmed the SRV records existed and were correct in the zone. So the failure wasn't a missing
record — it was a resolution-path problem. Checked the NIC's own DNS client configuration:
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
# vEthernet (External-VLAN-Trunk) [192.168.20.11] → ServerAddresses {8.8.8.8, 1.1.1.1}
```

**Root cause:** The DC's own LAN-facing NIC was configured to query public DNS resolvers directly
instead of itself. Any query for an internal-only name (like an AD SRV record) was sent to Google/
Cloudflare first, which correctly have no knowledge of a private AD zone, and the DC never fell
back to asking itself.

**Fix applied:**
```powershell
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (External-VLAN-Trunk)" -ServerAddresses 127.0.0.1
```

**Verification:**
```powershell
Clear-DnsClientCache
Resolve-DnsName _ldap._tcp.Chongong.local -Type SRV
# → win-prqd8tjg04m.chongong.local, priority 0, weight 100, port 389

Resolve-DnsName google.com
# → resolved correctly (142.251.45.14) — confirms forwarders/internet resolution unaffected
```

**Lesson:** A DNS zone and its records can be completely correct while the server itself still
can't resolve them, if the server's own NIC-level DNS client settings bypass its own DNS role.
Always check NIC addressing on a DC during any DNS audit, not just the zone contents.

---

## Runbook — AD Replication Failure from Missing `_msdcs` SRV Records

**Status:** Documented runbook, not staged live. Deliberately not triggered against the production
household DC to avoid disrupting real authentication/replication while testing.

**Symptom:** AD replication or authentication failures; `dcdiag` or `nltest /dsgetdc:Chongong.local`
report DC location failures; `_ldap._tcp.dc._msdcs.Chongong.local` SRV lookups fail.

**Diagnosis:**
```powershell
Get-DnsServerResourceRecord -ZoneName "_msdcs.Chongong.local" -RRType Srv
dcdiag /test:DNS
```

**Fix:** Force the DC to re-register its SRV records:
```powershell
Restart-Service Netlogon
ipconfig /registerdns
```

**Verification:** Re-run the SRV query above and confirm the expected records (`_ldap._tcp.dc`,
`_kerberos._tcp.dc`, etc.) reappear.

---

## Runbook — Internet Resolution Failure from Missing/Wrong Forwarder

**Status:** Documented runbook, not staged live. Deliberately not triggered against the production
household DC to avoid a real (even if brief) internet outage for anyone on the network during
testing.

**Symptom:** Internal AD names resolve fine, but anything external (`google.com`, Windows Update,
M365) fails to resolve from inside the network.

**Diagnosis:**
```powershell
Get-DnsServerForwarder
Resolve-DnsName google.com
```

**Fix:** Re-add or correct the forwarder list:
```powershell
Set-DnsServerForwarder -IPAddress 8.8.8.8,1.1.1.1,8.8.4.4,9.9.9.9
```

**Verification:** `Resolve-DnsName google.com` succeeds again; internal AD resolution
(`Resolve-DnsName Chongong.local`) remains unaffected, since forwarders only apply to
non-authoritative names.
