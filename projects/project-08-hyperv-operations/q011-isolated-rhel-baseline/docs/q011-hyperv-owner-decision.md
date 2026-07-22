# Q011 Hyper-V Execution-Owner Decision

- **Decision date:** 2026-07-19
- **Decision:** accepted
- **Owner:** `windows-server-business-admin-labs`
- **Predecessor evidence:** `homelab-proxmox-management`

## Context

Q011 began as a Proxmox-owned Linux baseline. Read-only discovery found that
the Proxmox node's Intel Xeon L5520 processors do not meet RHEL 10's required
x86-64-v3 feature level. The verified RHEL 10.2 DVD was retained, but no VM was
created.

A separately approved Hyper-V discovery found dual Intel Xeon E5-2687W v3
processors, sufficient discovered memory and local-disk headroom, and no
collision for the proposed VM name. Hyper-V is therefore the selected execution
platform.

## Decision

Execution ownership moves to this Windows repository because it owns the
Hyper-V host, its VM lifecycle, its local storage paths, and its evidence
standards. Q011 remains a Linux learning project, but its live control plane is
Windows Hyper-V.

The minimum Proxmox discovery facts and safe policy images move into this
Windows-owned record. The obsolete Proxmox draft worktree must not retain a
competing active run sheet after coordinated publication.

## Consequences

- The exact VM design and all future Hyper-V change windows live here.
- Source ISO verification performed through Proxmox remains valid discovery
  evidence; the file must be independently rechecked after local staging.
- This early Q011 lab does not mark the broader Project 08 Hyper-V Operations
  portfolio project complete or authorize its later switch/RDS work.
- The project-scoped display name `Q011-RHEL102-BASELINE` and Linux hostname
  `q011-rhel01` are frozen for this disposable lab. They do not amend the
  Windows server naming standard.
- No existing RHEL VM is a Q011 source or migration target.

## Alternatives Rejected

1. **Keep RHEL 10.2 on Proxmox:** rejected by the CPU compatibility gate.
2. **Downgrade Q011 to RHEL 9.6 on Proxmox:** not selected by Leonel.
3. **Attach the new VM to VLAN 70 during install:** rejected because the
   observed first-match firewall rule does not demonstrate the required
   isolation boundary.
4. **Reuse an existing RHEL VM:** rejected because Q011 requires a fresh,
   attributable baseline and must not modify unrelated guests.

## Publication Gate

This decision remains local until Leonel separately approves commit/push. The
owner, predecessor, canonical state, and vault links must publish together so
there is only one active execution owner.
