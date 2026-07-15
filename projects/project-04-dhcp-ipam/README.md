# Project 04 — DHCP/IPAM Integration And Windows Client Validation

- **Status:** Complete — 2026-07-03
- **Project / Queue ID:** `Windows-P04`
- **Owner:** `windows-server-business-admin-labs`
- **Scope:** Windows DHCP for VLAN 20, AD DNS options, Hyper-V addressing, and network-authority handoff
- **Risk:** Read-only discovery plus one approved low-risk DHCP option correction

## Why This Matters

DHCP and DNS errors can prevent clients from finding the domain even when the
servers are healthy. I needed Windows to fit the real Route10 and OPNsense
network design instead of building a competing homelab-wide DHCP service.

## Portfolio Summary

**Situation:** The original project assumed Windows might own homelab DHCP, but
live evidence showed Route10 and OPNsense already owned most addressing.

**Task:** I needed to document the active Windows scope, validate client DNS
behavior, and preserve the actual authority model.

**Action:** I inventoried the role, scope, leases, exclusions, options, network
dependencies, and Hyper-V addressing, then changed option 6 to advertise both
AD DNS servers.

**Result:** VLAN 20 has a documented split: Route10 remains gateway/IPAM owner,
Windows provides its DHCP service, and clients receive both domain controllers
as DNS.

## How To Read This Project

| Reader | Start here |
|---|---|
| Hiring manager or non-technical reader | [Portfolio Summary](#portfolio-summary) and [What I Proved](#what-i-proved) |
| Technical reviewer | [Phase Status](#phase-status), [Technical Evidence](#technical-evidence), and [technical details](technical-details.md) |
| Future operator | [Reproduce Or Re-Verify](#reproduce-or-re-verify) |

## My Test Boundary

I changed only VLAN 20 DHCP option 6 after confirming the active scope. I did
not disable Windows DHCP, delete the stale lease, alter bindings, create another
scope, or change Route10, OPNsense, routing, NAT, VLANs, or firewall policy.

## Phase Status

| Phase | Work | Status |
|---:|---|---|
| 1 | DHCP role and scope discovery | Complete |
| 2 | Route10 and OPNsense dependency map | Complete |
| 3 | Client DHCP and DNS validation | Complete |
| 4 | Hyper-V addressing review | Complete |
| 5 | Optional isolated-scope design | Complete |
| 6 | NetOps and IPAM handoff | Complete |
| 7 | Evidence and closeout | Complete |

## Phase 1 — DHCP Role And Scope Discovery

I confirmed Windows DHCP is installed, AD-authorized, and serving the active
`192.168.20.0/24` scope. The
[evidence record](docs/p04-dhcp-ipam-evidence.md) captures the lease,
exclusions, bindings, and options before the change. That proved the service
could not be disabled merely because Route10 is the main router.

## Phase 2 — Route10 And OPNsense Dependency Map

I mapped VLAN 20's Route10 gateway, both static DC addresses, the OPNsense
interface, and the `localdomain` DNS relationship. The
[IPAM handoff](docs/p04-ipam-handoff.md) keeps network ownership in the Route10
family while recording Windows dependencies. This corrected the project scope
before I changed a DHCP option.

## Phase 3 — Client DHCP And DNS Validation

I verified AD, SRV, Route10 household, and external lookups through both DCs,
then changed DHCP option 6 from one DNS server to `.11` and `.12`. The
[post-change output](docs/p04-post-change-verification.txt) records the final
option and resolution checks. That added DNS redundancy without changing the
gateway or another platform.

## Phase 4 — Hyper-V Addressing Review

I inventoried the Hyper-V switches, VM adapters, and observed IP assignments so
future reservations and monitoring do not guess which network a VM uses. The
handoff identifies `External-VLAN-Trunk`, `vSwitch-LAN`, and `vSwitch-WAN`
dependencies. This provided the evidence needed to separate current service
from optional lab design.

## Phase 5 — Optional Isolated-Scope Design

I documented Windows DHCP as a future option only for disconnected recovery,
training, or classroom-style Hyper-V networks. I created no scope and did not
compete with Route10 or OPNsense. That kept design exploration from changing
the live authority model.

## Phase 6 — NetOps And IPAM Handoff

I published the [Windows-side IPAM handoff](docs/p04-ipam-handoff.md) with
infrastructure addresses, VM observations, reservation candidates, and cleanup
items. It lets NetOps, SOC, and later Windows projects consume the same facts.
The handoff also preserves the stale lease as an observed item rather than an
unapproved deletion.

## Phase 7 — Evidence And Closeout

I documented the final role, scope, option, DNS, Hyper-V, and ownership state
without overstating Windows authority. The [technical details](technical-details.md)
retain the PowerShell commands and decision context. That closed Project 04
and left the GPO project with a stable identity and DNS base.

## What I Proved

- Windows DHCP is authorized and active for VLAN 20.
- The scope advertises both AD DNS servers and no longer advertises retired
  netboot options 66/67.
- Route10 remains the VLAN 20 gateway and homelab IPAM authority.
- Route10 and OPNsense were unchanged during the Windows correction.
- Hyper-V network dependencies and cleanup candidates are documented.

## Technical Evidence

- [Complete commands, decisions, and final state](technical-details.md)
- [DHCP/IPAM evidence](docs/p04-dhcp-ipam-evidence.md)
- [Windows-side IPAM handoff](docs/p04-ipam-handoff.md)
- [Netboot option cleanup](docs/p04-netboot-cleanup-2026-07-04.md)
- [AD DNS follow-up](docs/p04-ad-dns-followup-2026-07-04.md)
- [Sanitized discovery output](docs/p04-live-discovery-raw.txt)
- [Post-change verification](docs/p04-post-change-verification.txt)

## How We Worked Together

### My Input And How I Helped

I approved the scoped DHCP option correction and supplied the network and
Windows evidence. I accepted the decision to keep the active scope and stale
lease until a later maintenance review.

### What Codex Did And How

Codex collected the live read-only inventory, applied the approved option 6
correction, verified DNS through both DCs, and wrote the Hyper-V and IPAM
handoff records.

### What Claude Did And How

The retained project record does not document a separate Claude review for the
completed Project 04 work, so I do not claim one.

### How We Communicated And Completed The Project

I provided approval and operating context, then Codex returned the discovery,
single change, and post-change proof in separate artifacts. The ownership model
was reconciled with the Route10 and central status records.

### Pushback And How We Resolved It

The original project design treated Windows as a possible homelab-wide DHCP
owner. Live evidence contradicted that assumption, so I narrowed Windows to
VLAN 20 service and left the broader IPAM authority with Route10.

## Reproduce Or Re-Verify

1. Read the [IPAM handoff](docs/p04-ipam-handoff.md) and confirm the current
   owner for every network in scope.
2. Query the Windows DHCP authorization, scope, exclusions, leases, bindings,
   and options read-only.
3. Verify option 6 and resolve AD, SRV, `localdomain`, and external names
   directly through both DCs.
4. Do not delete a lease, change a binding, create a scope, or alter Route10 or
   OPNsense without a separate approved change and rollback.

## What Happens Next

Project 04 is closed. [Project 05](../project-05-gpo-security-baselines/)
uses the verified OU, DNS, and DHCP foundation to stage custom security GPOs.
This closeout and link do not start or authorize a GPO change.
