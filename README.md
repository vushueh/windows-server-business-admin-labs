# Windows Server Business Admin Labs

**Status:** 🔒 Private — goes public when complete | **Platform:** Windows Server 2022, Hyper-V, Microsoft 365
**Trigger phrase:** `windows server project`

Advanced Windows Server 2022, Active Directory, Hyper-V, Microsoft 365, Hybrid Identity, and Small Business IT Operations.

**Goal:** Build, secure, automate, monitor, and recover a real small-business Microsoft environment — then integrate it as the **identity and administration backbone** for all other homelab families.

Every other family consumes services from this one: network devices authenticate against AD via RADIUS, Linux VMs join the domain, the SOC pulls Windows event logs, Entra ID syncs on-prem users to Microsoft 365.

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

## Environment Reference

| Component | Platform | IP / Location | Notes |
|-----------|----------|--------------|-------|
| Hyper-V Host | WIN-PRQD8TJG04M | 192.168.20.11 | Runs all Windows Server VMs |
| WIN-DC01 | Windows Server 2022 VM | TBD (Project 01) | Domain Controller, DNS, NPS |
| WIN-FS01 | Windows Server 2022 VM | TBD (Project 06) | File Server |
| WIN-WS01 | Windows 11 VM | TBD (Project 07) | Domain-joined test workstation |
| OPNsense | Hyper-V VM | 192.168.20.x | Firewall — will authenticate to NPS |
| Physical CCNA gear | R1/R2/SW1/SW2 | 192.168.x.x | Will use RADIUS (Project 13) |

**AD Domain:** TBD — defined in Project 01. Recommended: `chongong.local` (internal), `yourbusiness.com` (UPN suffix for M365).

---

## Project Index

### Core Projects — Windows Server Track

| # | Project | Focus | Status |
|---|---------|-------|--------|
| [01](projects/project-01-server-baseline-hardening/) | **Server Baseline, Hardening, and Admin Model** | Role inventory, secure admin access, firewall posture, privileged account separation | ⬜ Planned |
| [02](projects/project-02-ad-architecture/) | **Active Directory Architecture** | OU design, delegated admin, tiered accounts, naming standards, service accounts, least privilege | ⬜ Planned |
| [03](projects/project-03-dns-engineering/) | **AD DNS and Name Resolution Engineering** | AD-integrated DNS, split DNS, forwarders, conditional forwarders, broken DNS troubleshooting | ⬜ Planned |
| [04](projects/project-04-dhcp-ipam/) | **DHCP, IPAM, and Network Integration** | Scopes, reservations, options, relay, VLAN-aware design, tied to physical CCNA lab | ⬜ Planned |
| [05](projects/project-05-gpo-security-baselines/) | **Group Policy Security Baselines** | Password/lockout policy, Windows Firewall GPO, audit policy, logon restrictions, security baselines | ⬜ Planned |
| [06](projects/project-06-file-server-access-governance/) | **File Server, NTFS, and Access Governance** | Department shares, AGDLP groups, auditing, access reviews, ransomware-resistant structure | ⬜ Planned |
| [07](projects/project-07-windows-client-lifecycle/) | **Windows Client Lifecycle** | Domain join, RSAT, local admin control, baseline GPOs, test users, workstation hardening | ⬜ Planned |
| [08](projects/project-08-hyperv-operations/) | **Hyper-V Operations** | Virtual switch design, VLANs, checkpoints policy, VM inventory, backup, recovery, resource planning | ⬜ Planned |
| [09](projects/project-09-powershell-admin-platform/) | **PowerShell Administration Platform** | User provisioning, AD reports, stale account cleanup, Hyper-V reports, repeatable scripts | ⬜ Planned |
| [10](projects/project-10-security-monitoring-ir/) | **Security Monitoring and Incident Response** | Event forwarding, failed logon tracking, account lockout investigation, Defender, Wazuh/SIEM forwarding | ⬜ Planned |
| [11](projects/project-11-backup-disaster-recovery/) | **Backup, Restore, and Disaster Recovery** | System state backup, file restore, AD recovery planning, tested restore runbooks | ⬜ Planned |
| [12](projects/project-12-m365-entra-hybrid-identity/) | **Microsoft 365 and Entra Hybrid Identity** | Custom domain, UPN alignment, Entra sync, license workflow, small-business onboarding/offboarding | ⬜ Planned |
| [13](projects/project-13-enterprise-identity-integration/) | **Enterprise Identity Integration Across Lab Families** | AD as central identity for network devices, servers, cloud accounts, and security monitoring — capstone | ⬜ Planned |

> Projects build on each other in order. Project 13 requires Projects 01–12 complete.
> Each project follows: Audit → Design → Build → Harden → Verify → Break/Fix → Document → Push

---

## Skills

| Skill | Purpose | Slash command |
|-------|---------|---------------|
| [windows-server-business-admin](skills/windows-server-business-admin.md) | Main family skill — all 13 projects, AD design, cross-family integration | `/winserver` |
| project-01-server-hardening | Project 01 phase skill | `/winserver-p01` — written when P01 starts |
| project-12-m365-hybrid | M365/Entra integration skill | `/winserver-p12` — written when P12 starts |
| project-13-identity-integration | Cross-family capstone skill | `/winserver-p13` — written when P13 starts |

---

## Docs

| Document | Contents |
|----------|---------|
| [topology.md](docs/topology.md) | Server/VM layout, Hyper-V design, network segments |
| [identity-design.md](docs/identity-design.md) | AD OU structure, account tiers, AGDLP model |
| [naming-standards.md](docs/naming-standards.md) | Server/VM/user/group naming conventions |
| [security-model.md](docs/security-model.md) | Security boundaries, admin tiers, least privilege design |

---

## Related Families

| Family | Repo | How This Project Connects |
|--------|------|---------------------------|
| CML Enterprise Labs | [enterprise-network-labs](https://github.com/vushueh/enterprise-network-labs) | Project 13: CML routers authenticate to AD via NPS/RADIUS |
| CCNA Physical Expansion | [Homelab_CCNA](https://github.com/vushueh/Homelab_CCNA) | Project 13: Physical Cisco gear AAA to NPS/RADIUS |
| OPNsense Labs | [homelab-opnsense](https://github.com/vushueh/homelab-opnsense) | Project 13: OPNsense admin RADIUS auth |
| Proxmox Management | [homelab-proxmox-management](https://github.com/vushueh/homelab-proxmox-management) | Project 13: Linux VM SSSD/AD join |
| **Master Hub** | [homelab-management](https://github.com/vushueh/homelab-management) | Navigation hub for all families |

---

## Who Does What

| Codex | Claude | Leonel |
|-------|--------|--------|
| Architecture review + failure mode analysis | Final approval before any AD/GPO/M365 change | CLI typing on Windows Server + PowerShell |
| PowerShell script drafts (provisioning, reports, automation) | All GitHub pushes | Final say on domain/naming decisions |
| GPO design + AD OU structure design | Review before changes applied to live AD | |
| CODEX-LOG.md updates | CLAUDE-REVIEW.md | |
| Runbooks, phase guides, documentation | Live remote execution if needed | |

## Bridge Files

| File | Purpose |
|------|--------|
| [AGENTS.md](AGENTS.md) | Codex standing orders — read before any work |
| [CLAUDE-REVIEW.md](CLAUDE-REVIEW.md) | Claude open items for Codex to resolve |
| [CODEX-LOG.md](CODEX-LOG.md) | Codex action log — Claude reads to stay in sync |
| [WORKFLOW.md](WORKFLOW.md) | Trigger phrases, project cycle, who does what |
