# Q007 Windows DNS Failure-Triage Runbook

- **Purpose:** diagnose an internal-name failure, identify whether the cause is a
  bad record, client DNS order, or a forwarder, and require positive and negative
  retests before closure.
- **Scope:** Windows DNS and Windows clients for the existing homelab design.
- **Default mode:** read-only diagnosis. Any repair is a separately approved live
  change.
- **Lab proof:** [Q007 isolated drill](../README.md)
- **Earlier Windows proof:** [P03 DNS break/fix log](../../troubleshooting/break-fix-log.md)

## Stop And Escalate

Stop before repair when any of these conditions is true:

- the affected zone, record, client adapter, or DNS server is not known;
- more than one authority may own the record;
- replication is unhealthy or the two domain controllers disagree;
- the desired full DNS-server or forwarder list is not recorded;
- removing a record could affect a real service;
- current-state evidence, backup/export, rollback, or dated approval is absent.

Do not edit Default Domain Policy, delete AD objects, or use this runbook as
blanket authority for DNS, DHCP, NIC, or domain-controller changes.

## 1. Record The User Failure

Capture the exact name, expected service, client, time, and visible symptom.
Do not start with a preferred technology fix. A useful statement is:

> The user opened the internal file-service name, but the client selected a
> stale address where the expected service was unavailable.

Preserve the original output before clearing a cache or changing anything.

## 2. Establish Client And Query State

Run from the affected client in an administrative PowerShell session only when
the local policy permits it:

```powershell
ipconfig /all
Get-DnsClientServerAddress -AddressFamily IPv4 |
  Format-Table InterfaceAlias,InterfaceIndex,ServerAddresses -AutoSize
Resolve-DnsName '<affected-name>' -Type A -DnsOnly
nslookup '<affected-name>'
```

Record every returned address, not just the first one. Compare the configured
client DNS servers with the current authoritative design. Do not treat a
successful response as proof that every returned address is correct.

## 3. Separate The Three Fault Branches

### Branch A — Extra Or Wrong A Record

Query each known authoritative DNS server directly, then inspect the exact
record name in the zone:

```powershell
Resolve-DnsName '<affected-name>' -Server '<dns-server-1>' -Type A -DnsOnly
Resolve-DnsName '<affected-name>' -Server '<dns-server-2>' -Type A -DnsOnly
Get-DnsServerResourceRecord -ComputerName '<dns-server>' `
  -ZoneName '<zone>' -Name '<record-name>' -RRType A
```

This is the Q007 exercised branch. The isolated drill returned the wrong
RFC1918 address first, demonstrated naive-client impact, removed only that
answer in memory, and proved the full post-repair answer set.

### Branch B — Client Or Server NIC DNS Order

Inspect every active adapter. A domain controller or domain client should not
use a public resolver as its domain DNS source.

```powershell
Get-NetAdapter | Where-Object Status -eq 'Up'
Get-DnsClientServerAddress -AddressFamily IPv4
Get-NetIPAddress -AddressFamily IPv4
```

The parent P03 project documented the real multi-homed PDC incident: the
Tailscale adapter registered an unwanted address and DNS client order pointed
at a public resolver before the internal DC. Use that evidence as the Windows
example; Q007 did not recreate it on a live adapter.

### Branch C — Wrong Or Incomplete Forwarder

Use this branch when internal authoritative names are healthy but external or
delegated names fail:

```powershell
Get-DnsServerForwarder -ComputerName '<dns-server>'
Get-DnsServerConditionalForwarderZone -ComputerName '<dns-server>'
Resolve-DnsName '<external-or-delegated-name>' -Server '<dns-server>' -DnsOnly
```

Do not use `Set-DnsServerForwarder` until the complete desired list is known:
that cmdlet replaces the list rather than adding one safe entry implicitly.

## 4. Prepare An Exact Repair

Before a live repair, create the normal change-window record with:

- the exact record, adapter, or forwarder list;
- before-state output from both DNS servers when applicable;
- zone export or other current backup appropriate to the change;
- the one approved command or GUI action;
- rollback using the captured before value;
- stop triggers and the positive/negative test set;
- Leonel's dated approval.

Examples below are patterns, not authorization. Replace every placeholder and
review the full command before use.

### Remove One Proven-Wrong A Record

```powershell
Remove-DnsServerResourceRecord -ComputerName '<dns-server>' `
  -ZoneName '<zone>' -Name '<record-name>' -RRType A `
  -RecordData '<wrong-private-address>' -Force
```

Never delete every record merely because one answer is wrong. Verify the exact
record data and preserve the intended answer.

### Correct One Adapter's DNS Server Order

```powershell
Set-DnsClientServerAddress -InterfaceIndex <approved-index> `
  -ServerAddresses @('<internal-dns-1>','<internal-dns-2>')
```

Capture the prior list first so rollback can restore it exactly. Treat a
domain controller as a high-impact target even when the command looks small.

### Replace The Forwarder List

```powershell
Set-DnsServerForwarder -ComputerName '<dns-server>' `
  -IPAddress @('<approved-forwarder-1>','<approved-forwarder-2>')
```

Because this replaces the complete list, an omitted working forwarder is a new
fault. Confirm the before and desired lists before approval.

## 5. Handle Caches Only After The Source Is Correct

The loopback harness intentionally has no cache layer. Real Windows clients
and DNS servers may retain the wrong answer after the zone is repaired.

```powershell
Clear-DnsClientCache
# Use only when approved and necessary on the named DNS server:
Clear-DnsServerCache -ComputerName '<dns-server>' -Force
```

Clearing a cache before preserving evidence can hide the symptom without
repairing the source. Capture first, fix the authority, then clear only the
necessary cache.

## 6. Positive, Negative, And Failure Retests

Closure requires the full set:

1. Query each authoritative DNS server and the affected client.
2. Repeat the affected-name query at least three times.
3. Confirm the complete answer set contains only the intended address or
   addresses.
4. Confirm the proven-wrong address is absent.
5. Query a deliberately unknown name and require NXDOMAIN rather than a false
   positive answer.
6. Recheck DNS replication/zone agreement when an AD-integrated record changed.
7. Test the actual affected service separately; name resolution alone does not
   prove SMB, HTTPS, or another application is healthy.

## 7. Roll Back Or Close

Roll back when the wrong answer remains, a good record disappears, the two DNS
servers disagree, replication degrades, or a previously healthy name fails.
Restore the exact captured record, adapter list, or complete forwarder list;
then repeat every test.

Close only when the user-visible service works, the intended answer set is
stable, the bad address is absent, the negative test remains negative, and the
evidence identifies the exact cause and repair. Record remaining uncertainty
instead of claiming that one corrected query proves the entire DNS service.

## Q007 Lab-To-Windows Mapping

| Isolated drill action | Windows operational equivalent |
|---|---|
| Query raw A response | `Resolve-DnsName` and `nslookup` |
| Inspect all returned answers | `Resolve-DnsName -Type A -DnsOnly` plus zone record inspection |
| Inject extra wrong A record | Approved test-zone record addition only; not performed in Q007 |
| Remove wrong answer in memory | Exact `Remove-DnsServerResourceRecord` after approval |
| Repeat three positive tests | Query each DNS server and the affected client repeatedly |
| Require wrong address absent | Compare the full answer list against the approved state |
| Require RCODE 3 for unknown name | `Resolve-DnsName '<unknown>'` should report nonexistence |
| Stop server and release port | Remove disposable test objects and verify no residual change |

## Limitations

Q007 proves DNS packet and record-set triage for one extra-A-record fault. It
does not prove Windows DNS administration, AD replication, cache timing,
forwarder behavior, NIC configuration, or live service recovery in this run.
The P03 evidence covers the earlier Windows incident, while any future live
proof remains separately gated.
