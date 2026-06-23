# Windows Server Business Admin Labs

**Status:** 🔒 Private — goes public when complete | **Platform:** Windows Server 2022, Hyper-V, Microsoft 365
**Trigger phrase:** `windows server project`

Advanced Windows Server 2022, Active Directory, Hyper-V, Microsoft 365, Hybrid Identity, and Small Business IT Operations.

**Goal:** Build, secure, automate, monitor, and recover a real small-business Microsoft environment — then integrate it as the **identity and administration backbone** for all other homelab families.

---

## Cross-Family Integration Architecture

```
Windows Server 2022 — AD DS / DNS / NPS (RADIUS) / Entra Connect
        │
        │  provides: identity, auth, DNS, RADIUS, event logs, admin accounts, M365
        │
        ├── CML Enterprise Labs       ← routers authenticate via NPS/RADIUS to AD
        ├── Physical CCNA Homelab     ← physical Cisco gear AAA auth via RADIUS
        ├── Proxmox Linux VMs         ← SSSD/AD domain join, NFS shares
        ├── Hyper-V                   ← managed by this project family
        ├── OPNsense / Palo Alto      ← admin auth via RADIUS
        ├── Blue Team / SOC           ← Windows event logs, AD telemetry to Wazuh
        ├── Automation                ← PowerShell remoting, AD/Hyper-V inventory
        └── Microsoft 365 / Entra    ← hybrid identity sync, mail, licensing
```

**Project 13 is the capstone** — it proves this integration end-to-end.

---

## How To Work This Family

This family should not be completed in isolation. I use Windows Server as the
identity backbone, then rotate through NetOps, SOC, OPNsense, FreePBX,
ServiceNow/Microsoft 365, and case-study work as each Windows milestone becomes
useful to another family.

Start with Projects 01-05 as the foundation: server baseline, AD structure, DNS,
DHCP/IPAM, and GPO baselines. After that, move in smaller cross-family loops so
each project proves something real in another part of the homelab.

Detailed order: [execution-roadmap.md](docs/execution-roadmap.md)

---

## Actual Environment (Discovered 2026-06-05)

WIN-PRQD8TJG04M is already live. It IS the Domain Controller — not just the Hyper-V host.

| Component | Platform | IP | Notes |
|-----------|----------|----|-------|
| WIN-PRQD8TJG04M | Windows Server 2022 Datacenter | 192.168.20.11 / Tailscale 100.81.197.116 | PDC for Chongong.local, DHCP, DNS, NPS, RDS farm, IIS, Hyper-V |
| WIN-RDS01 | Hyper-V VM | TBD (Project 08) | Migration target: RD Session Host (moving off DC) |
| WIN-FS01 | Hyper-V VM | TBD (Project 06) | Dedicated File Server |
| WIN-WS01 | Hyper-V VM | TBD (Project 07) | Domain-joined test workstation |
| OPNsense | Hyper-V VM | 192.168.20.x | Firewall — will authenticate to NPS (Project 13) |
| Physical CCNA gear | R1/R2/SW1/SW2 | 192.168.x.x | RADIUS auth in Project 13 |

**AD Domain:** `Chongong.local` (internal) | UPN suffix for M365: `<yourbusiness>.com` (Project 12)

---

## Project Index

| # | Project | Focus | Status |
|---|---------|-------|--------|
| [01](projects/project-01-server-baseline-hardening/) | **Server Baseline, Hardening, and Admin Model** | Role inventory, tiered admin, lockout policy, firewall baseline | ✅ Complete |
| [02](projects/project-02-ad-architecture/) | **Active Directory Architecture** | Managed OUs, delegated admin, AGDLP groups, naming standards | 🔄 AD complete; WIN-DC02 pending |
| [03](projects/project-03-dns-engineering/) | **AD DNS and Name Resolution Engineering** | AD-integrated DNS, split DNS, forwarders | 🔄 Mostly complete — 2026-06-23 (Phase 5 N/A, Phase 9 blocked on P02) |
| [04](projects/project-04-dhcp-ipam/) | **DHCP, IPAM, and Network Integration** | Scopes, reservations, VLAN-aware design | ⬜ Planned |
| [05](projects/project-05-gpo-security-baselines/) | **Group Policy Security Baselines** | Firewall GPO, audit policy, DefaultInboundAction | ⬜ Planned |
| [06](projects/project-06-file-server-access-governance/) | **File Server, NTFS, and Access Governance** | Dept shares, AGDLP, auditing | ⬜ Planned |
| [07](projects/project-07-windows-client-lifecycle/) | **Windows Client Lifecycle** | Domain join, RSAT, workstation hardening | ⬜ Planned |
| [08](projects/project-08-hyperv-operations/) | **Hyper-V Operations** | VM inventory, RDS farm migration, virtual switch, backup | ⬜ Planned |
| [09](projects/project-09-powershell-admin-platform/) | **PowerShell Administration Platform** | User provisioning, AD reports, repeatable scripts | ⬜ Planned |
| [10](projects/project-10-security-monitoring-ir/) | **Security Monitoring and Incident Response** | Event forwarding, lockout tracking, Wazuh/SIEM | ⬜ Planned |
| [11](projects/project-11-backup-disaster-recovery/) | **Backup, Restore, and Disaster Recovery** | System state backup, tested runbooks | ⬜ Planned |
| [12](projects/project-12-m365-entra-hybrid-identity/) | **Microsoft 365 and Entra Hybrid Identity** | Custom domain, UPN, Entra sync | ⬜ Planned |
| [13](projects/project-13-enterprise-identity-integration/) | **Enterprise Identity Integration** | AD as central identity for all lab families — capstone | ⬜ Planned |

---

## Skills

| Skill | Purpose | Slash command |
|-------|---------|---------------|
| [windows-server-business-admin](skills/windows-server-business-admin.md) | Main family skill | `/winserver` |
| [project-01-server-hardening](skills/project-01-server-baseline-hardening.md) | P01 lean skill + phase references | `/winserver-p01` ✅ Ready |
| [winserver-evidence-documentation](skills/winserver-evidence-documentation/SKILL.md) | Documentation standard: readable README first, technical evidence behind links | Use for every project/phase documentation update |
| project-12-m365-hybrid | M365/Entra skill | `/winserver-p12` — written when P12 starts |
| project-13-identity-integration | Capstone skill | `/winserver-p13` — written when P13 starts |

---

## Docs

| Document | Contents |
|----------|----------|
| [topology.md](docs/topology.md) | Actual server state, VM inventory, network segments |
| [identity-design.md](docs/identity-design.md) | AD OU structure, account tiers, AGDLP model |
| [naming-standards.md](docs/naming-standards.md) | Server/VM/user/group naming conventions |
| [security-model.md](docs/security-model.md) | Security boundaries, admin tiers, least privilege |
| [execution-roadmap.md](docs/execution-roadmap.md) | Starting base, cross-family rotation plan, done criteria, and immediate work queue |

---

## Related Families

| Family | Repo | Connection |
|--------|------|------------|
| CML Enterprise Labs | enterprise-network-labs | Project 13: CML routers → NPS/RADIUS |
| CCNA Physical Expansion | Homelab_CCNA | Project 13: Physical Cisco AAA → NPS |
| OPNsense Labs | homelab-opnsense | Project 13: OPNsense admin RADIUS |
| Proxmox Management | homelab-proxmox-management | Project 13: Linux SSSD/AD join |
| **Master Hub** | homelab-management | Navigation hub for all families |

---

## Who Does What

| Codex | Claude | Leonel |
|-------|--------|--------|
| Architecture review + failure mode analysis | Final approval before any AD/GPO/M365 change | CLI typing + GUI on Windows Server |
| PowerShell script drafts | All GitHub pushes | Final say on domain/naming decisions |
| GPO design + AD OU structure | Review before changes applied to live AD | Screenshots + verification |
| CODEX-LOG.md updates | CLAUDE-REVIEW.md | |

## Bridge Files

| File | Purpose |
|------|----------|
| [AGENTS.md](AGENTS.md) | Codex standing orders |
| [CLAUDE-REVIEW.md](CLAUDE-REVIEW.md) | Claude open items for Codex |
| [CODEX-LOG.md](CODEX-LOG.md) | Codex action log |
| [WORKFLOW.md](WORKFLOW.md) | Trigger phrases and project cycle |
