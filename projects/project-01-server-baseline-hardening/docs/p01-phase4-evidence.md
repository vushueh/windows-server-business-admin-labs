# P01 Phase 4 — RDS / IIS / NPS Risk Assessment (document only, no live changes)

**Date:** 2026-06-22
**Who ran it:** Leonel, on `WIN-PRQD8TJG04M`, GUI consoles
**Rule for this phase:** document only. No service starts/stops/restarts, no role
removal, no AD changes.

## Step 1 — RDS topology (Server Manager)

**Console:** Server Manager → Remote Desktop Services → Overview

![RDS Overview — broker error](../screenshots/p01-phase4-rds-overview-error.png)

**What it shows:** The server pool does not match the registered RD Connection
Brokers. Error text: *"Cannot connect to any of the specified RD Connection Broker
servers. Ensure that at least one server is available and that the Remote Desktop
Management (rdms), RD Connection Broker (tssdis), or RemoteApp and Desktop
Connection (tscpubrpc) services are running. WIN-PRQD8TJG04M.Chongong.local"*

**What this means:** the RDS deployment is already unhealthy or misconfigured —
not something this session broke, something already broken before we looked. This
confirms and sharpens the Phase 1 finding "RDS full farm on DC — HIGH risk." Do not
start/restart these services to try to fix this — that's Project 08 scope (RDS
migration off the DC), not P01.

**Service status (read-only check, do not start/stop):**
```
[ fill in from services.msc — Remote Desktop Management, RD Connection Broker,
  RemoteApp and Desktop Connection Management — Status column only ]
```

**Collections tab:**
```
[ fill in what Collections shows ]
```

## Step 2 — RDS-Users group membership (ADUC)

**Console:** ADUC → Groups OU → `RDS-Users` → Members tab

```
[ screenshot slot: ../screenshots/p01-phase4-rds-users-members.png ]
[ fill in member list ]
```

## Step 3 — IIS sites and application pools (IIS Manager)

**Console:** IIS Manager → `WIN-PRQD8TJG04M` → Sites

```
[ screenshot slot: ../screenshots/p01-phase4-iis-sites.png ]
[ fill in: site names, state, bindings ]
```

**Console:** IIS Manager → Application Pools

```
[ screenshot slot: ../screenshots/p01-phase4-iis-app-pools.png ]
[ fill in: pool name, identity type per pool — flag any running as a named domain account ]
```

## Step 4 — NPS (Network Policy Server)

**Console:** `nps.msc` → Policies → Network Policies

```
[ screenshot slot: ../screenshots/p01-phase4-nps-network-policies.png ]
```

**Console:** Policies → Connection Request Policies

```
[ screenshot slot: ../screenshots/p01-phase4-nps-connection-request-policies.png ]
```

**Per policy → Conditions tab:** note whether `radius-service` appears in any
condition.
```
[ fill in: does radius-service appear, in which policy ]
```

**Console:** RADIUS Clients and Servers → RADIUS Clients

```
[ screenshot slot: ../screenshots/p01-phase4-nps-radius-clients.png ]
[ fill in: client names/IPs — no shared secrets in this doc ]
```

**Rule:** if an NPS config export is needed to search for `radius-service`, it goes
in `C:\Audit\` on the server only. Never committed to this repo — NPS exports
contain RADIUS shared secrets in plaintext.

## Step 5 — `__vmware__` group (ADUC)

**Console:** ADUC → locate `__vmware__` → Description / Members / ManagedBy

```
[ screenshot slot: ../screenshots/p01-phase4-vmware-group.png ]
[ fill in: Description, Members, ManagedBy ]
```

**Rule:** document only, do not remove or modify this group either way.

## How to add screenshots to this file

Save each screenshot on the server, copy it onto this machine, and place it at the
exact path shown above each slot (e.g.
`projects/project-01-server-baseline-hardening/screenshots/p01-phase4-rds-overview-error.png`).
Tell me the filename once it's there and I'll confirm the markdown reference resolves,
then fill in the matching text from what you report.

## Result

In progress. Step 1 has its first screenshot slot wired up above (the file itself
still needs to be saved to the path shown — see "How to add screenshots" above).
Steps 2-5 not started yet.
