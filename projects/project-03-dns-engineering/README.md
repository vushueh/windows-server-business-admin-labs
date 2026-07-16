# Project 03 — AD DNS And Name Resolution Engineering

- **Status:** Complete — 2026-07-03
- **Project / Queue ID:** `Windows-P03`
- **Owner:** `windows-server-business-admin-labs`
- **Scope:** AD-integrated DNS client settings, zones, forwarding, reverse DNS, scavenging, redundancy, and troubleshooting
- **Risk:** Approved live DNS changes on two domain controllers

## Why This Matters

Active Directory depends on DNS for authentication and service discovery. I
needed both domain controllers to answer internal, reverse, household, and
external lookups correctly without sending private AD names to public DNS.

## Portfolio Summary

**Situation:** The PDC NIC used public DNS directly, reverse DNS was missing,
scavenging was disabled, and secondary-DNS behavior was unproven.

**Task:** I needed to fix the real AD DNS fault and add safe, repeatable name-
resolution controls without disrupting the household domain.

**Action:** I audited DNS, corrected both DC client orders, preserved the
forwarder list, created the reverse zone and PTRs, added the Route10
`localdomain` conditional forwarder, enabled scavenging, and tested both DNS
servers.

**Result:** AD service records, both DC names and PTRs, Route10 household names,
and external names resolve through either DC with the intended namespace
boundaries.

## How To Read This Project

| Reader | Start here |
|---|---|
| Hiring manager or non-technical reader | [Portfolio Summary](#portfolio-summary) and [What I Proved](#what-i-proved) |
| Technical reviewer | [Phase Status](#phase-status), [Technical Evidence](#technical-evidence), and [technical details](technical-details.md) |
| Future operator | [Reproduce Or Re-Verify](#reproduce-or-re-verify) |

## Q007 Follow-On Simulation

The completed core P03 project remains unchanged. Its later queue-selected
follow-on is [Q007 — DNS Failure-Triage
Simulation](q007-dns-failure-triage-simulation/), which safely recreates an
extra wrong A record on loopback, proves diagnosis/repair/retest/cleanup, and
publishes the reusable Windows operator runbook without touching live DNS.

## My Test Boundary

I changed Windows DNS only after read-only discovery and retained rollback
commands. I did not rewrite the working public forwarder list, change Route10,
or deliberately break live household DNS to manufacture an incident.

## Phase Status

| Phase | Work | Status |
|---:|---|---|
| 1 | DNS audit | Complete |
| 2 | DC DNS client correction | Complete |
| 3 | Public-forwarder verification | Complete |
| 4 | Reverse lookup zones | Complete |
| 5 | Route10 conditional forwarding | Complete |
| 6 | Scavenging and zone aging | Complete |
| 7 | Internal and external resolution | Complete |
| 8 | Break/fix documentation | Complete |
| 9 | Secondary-DNS verification | Complete |
| 10 | Evidence and closeout | Complete |

## Phase 1 — DNS Audit

I inspected zones, forwarders, scavenging, records, and NIC client settings
before changing anything. The audit found the PDC's AD-facing NIC querying
public DNS directly, which explained failed local SRV lookups. That real fault
gave Phase 2 a narrow, evidence-backed target.

## Phase 2 — DC DNS Client Correction

I moved the PDC off public NIC resolvers and, after `WIN-DC02` existed, set the
PDC to use `.12` then `.11` while the replica uses `.11` then `.12`. The
[break/fix log](troubleshooting/break-fix-log.md) records the original failure
and successful AD SRV readback. This restored the correct internal query path
without changing public forwarding.

## Phase 3 — Public-Forwarder Verification

I read the existing forwarder list and confirmed external resolution worked. I
did not run `Set-DnsServerForwarder` merely to restate a correct configuration
because it replaces the full list. That preserved the known-good external path
before I added reverse DNS.

## Phase 4 — Reverse Lookup Zones

I created `20.168.192.in-addr.arpa` and PTR records for both DCs, then queried
the server directly to avoid local resolver artifacts. The resulting reverse
lookups support monitoring and troubleshooting. With forward and reverse AD
records verified, I could evaluate non-AD local namespaces.

## Phase 5 — Route10 Conditional Forwarding

I rejected OPNsense `internal` and Pi-hole because discovery did not prove a
usable authoritative target. After Route10 answered a real `localdomain`
record, I added an AD-integrated conditional forwarder to `192.168.20.1` and
disabled recursion for that zone. The
[secondary-DNS evidence](docs/p03-win-dc02-secondary-dns-evidence.md) proves
the forwarder works through both DCs without changing Route10.

## Phase 6 — Scavenging And Zone Aging

I enabled server scavenging on both DNS servers and aging on the
`Chongong.local` zone with documented intervals. This adds controlled stale-
record cleanup rather than an immediate destructive purge. The final state
could then be tested for both internal and external behavior.

## Phase 7 — Internal And External Resolution

I verified AD host and SRV records stay inside AD DNS while public names resolve
through forwarders. The tests show the internal namespace and normal internet
resolution can coexist. That provided the healthy baseline for the break/fix
record.

## Phase 8 — Break/Fix Documentation

I used the real NIC-DNS fault as the executed incident and wrote two additional
safe runbooks for missing SRV records and broken forwarders. I did not inject a
second live outage merely for evidence. The
[break/fix log](troubleshooting/break-fix-log.md) turns the incident into a
repeatable troubleshooting path.

## Phase 9 — Secondary-DNS Verification

I verified zones, forwarders, scavenging, PTRs, internal names, SRV records,
Route10 names, and external names directly through `WIN-DC02`. The
[secondary-DNS record](docs/p03-win-dc02-secondary-dns-evidence.md) also proves
the PDC hostname returns only its AD VLAN address. That confirmed the second DC
is a usable DNS server, not merely a promoted replica.

## Phase 10 — Evidence And Closeout

I saved the screenshot plan, incident record, two-DC proof, commands, and final
state. The [technical details](technical-details.md) retain the full
implementation and rollback commands while this README carries the project
story. That handed a verified DNS foundation to DHCP/IPAM validation.

## What I Proved

- Both DNS servers answer AD host, SRV, reverse, Route10 `localdomain`, and
  external queries.
- DC NICs use AD DNS in a reciprocal order rather than public resolvers.
- `localdomain` forwards only to Route10 and has recursion disabled.
- Reverse DNS and controlled stale-record cleanup are enabled.
- The executed break/fix used a real fault and did not create an unnecessary
  household outage.

## Technical Evidence

- [Complete implementation, commands, screenshots, and rollback](technical-details.md)
- [WIN-DC02 secondary-DNS evidence](docs/p03-win-dc02-secondary-dns-evidence.md)
- [DNS break/fix log](troubleshooting/break-fix-log.md)
- [Screenshot checklist](docs/p03-screenshot-plan.md)
- [Reviewed screenshots](screenshots/)

## How We Worked Together

### My Input And How I Helped

I authorized the scoped live DNS work, chose not to manufacture a second
outage, and supplied the Windows and Route10 evidence needed to settle the
conditional-forwarder target.

### What Codex Did And How

Codex reviewed the DNS design, corrected unsafe command assumptions, integrated
the Route10 discovery and two-DC evidence, and maintained the final technical
and portfolio records.

### What Claude Did And How

Claude performed the approved live Project 03 session, found and fixed the PDC
NIC DNS fault, created the reverse zone, enabled scavenging, and recorded the
initial verification. Claude later performed read-only target discovery for
the conditional forwarder.

### How We Communicated And Completed The Project

Live command output and screenshots moved from audit to correction, readback,
target discovery, two-DC verification, and documentation. The bridge record
marked the initially deferred phases complete only after real evidence existed.

### Pushback And How We Resolved It

The original plan expected a conditional forwarder but had no proven target.
I deferred it rather than inventing one, then completed it only after Route10
answered a real `localdomain` record from both DC paths.

## Reproduce Or Re-Verify

1. Run read-only queries for zones, forwarders, scavenging, zone aging, and
   both DC NIC resolver orders.
2. Query AD host/SRV records, both PTRs, one `localdomain` record, and one
   external name directly against each DC.
3. Compare the results with the [two-DC evidence](docs/p03-win-dc02-secondary-dns-evidence.md)
   and incident record.
4. Do not replace forwarders, remove a zone, or alter client addresses without
   a fresh backup, approved change window, and the rollback commands in the
   technical details.

## What Happens Next

Project 03 is closed. [Project 04](../project-04-dhcp-ipam/) validates how
Windows DHCP and AD DNS fit the Route10/OPNsense authority model. This closeout
and link do not start or authorize a DHCP or IPAM change.
