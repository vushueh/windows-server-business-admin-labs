# Projects

Work through projects in order inside this Windows family, but do not work only
inside this family until all 13 projects are done. Each Windows milestone should
connect back to another family: NetOps, SOC, OPNsense, FreePBX, ServiceNow,
Microsoft 365, Proxmox, or case studies.

Project 13 (capstone) requires all previous projects complete.

See [../docs/execution-roadmap.md](../docs/execution-roadmap.md) for the
starting base, cross-family rotation plan, and done criteria.

## Starting Base

Start with Projects 01-05 before building higher-level services:

| Order | Project | Why it comes first |
|-------|---------|--------------------|
| 1 | P01 Server Baseline | Confirms what the live server is doing and secures admin access. |
| 2 | P02 AD Architecture | Creates the OU, account, service-account, and group model every later project depends on. |
| 3 | P03 DNS Engineering | Makes name resolution reliable before more VMs and services are added. |
| 4 | P04 DHCP/IPAM | Makes addressing and reservations predictable across Windows, OPNsense, NetOps, and SOC. |
| 5 | P05 GPO Baselines | Applies audit, firewall, account policy, and logon controls before client and SOC tests. |

After P05, rotate into client, SOC, backup, M365, NPS/RADIUS, FreePBX, and
ServiceNow work in smaller loops instead of finishing every Windows project
without touching the other families.

## Cross-Family Rotation Points

| After Windows milestone | Touch this family next | Purpose |
|-------------------------|------------------------|---------|
| P02 AD Architecture | NetOps + SOC docs | Record AD groups and admin tiers before they control devices/tools. |
| P03/P04 DNS + DHCP | OPNsense + NetOps | Align VLANs, hostnames, reservations, and monitoring inventory. |
| P05/P07 GPO + client | SOC/Wazuh | Confirm Windows security events and client behavior are visible. |
| P08/P09 Hyper-V + PowerShell | Homelab automation | Tie VM inventory, backups, and scripts into operated workflows. |
| P10 Security Monitoring | SOC case workflow | Build one incident path from Windows event to Wazuh/TheHive evidence. |
| P12 M365/Entra | ServiceNow planning | Users, groups, licenses, and mail workflows become ticket/service-request sources. |
| P13 Identity Integration | CML, CCNA, OPNsense, Proxmox, FreePBX | Prove one AD identity across the whole lab with local fallback. |

## Core Projects

| Project | Focus | Status |
|---------|-------|--------|
| [project-01-server-baseline-hardening](project-01-server-baseline-hardening/) | Role inventory, secure admin access, firewall posture, privileged account separation | ✅ Complete |
| [project-02-ad-architecture](project-02-ad-architecture/) | OU design, delegated admin, tiered accounts, naming standards, service accounts, least privilege | ⬜ Planned |
| [project-03-dns-engineering](project-03-dns-engineering/) | AD-integrated DNS, split DNS, forwarders, conditional forwarders, broken DNS troubleshooting | ⬜ Planned |
| [project-04-dhcp-ipam](project-04-dhcp-ipam/) | DHCP scopes, reservations, options, relay, VLAN-aware design, documentation | ⬜ Planned |
| [project-05-gpo-security-baselines](project-05-gpo-security-baselines/) | Password/lockout policy, Windows Firewall GPO, audit policy, logon restrictions | ⬜ Planned |
| [project-06-file-server-access-governance](project-06-file-server-access-governance/) | Department shares, AGDLP groups, auditing, access reviews, ransomware-resistant structure | ⬜ Planned |
| [project-07-windows-client-lifecycle](project-07-windows-client-lifecycle/) | Domain join, RSAT, local admin control, baseline GPOs, test users, workstation hardening | ⬜ Planned |
| [project-08-hyperv-operations](project-08-hyperv-operations/) | Virtual switch design, VLANs, checkpoints policy, VM inventory, backup, recovery | ⬜ Planned |
| [project-09-powershell-admin-platform](project-09-powershell-admin-platform/) | User provisioning, AD reports, stale account cleanup, Hyper-V reports, repeatable scripts | ⬜ Planned |
| [project-10-security-monitoring-ir](project-10-security-monitoring-ir/) | Event forwarding, lockout tracking, account lockout investigation, Defender, Wazuh/SIEM | ⬜ Planned |
| [project-11-backup-disaster-recovery](project-11-backup-disaster-recovery/) | System state backup, file restore, AD recovery planning, tested restore runbooks | ⬜ Planned |
| [project-12-m365-entra-hybrid-identity](project-12-m365-entra-hybrid-identity/) | Custom domain, UPN alignment, Entra sync, license workflow, onboarding/offboarding | ⬜ Planned |
| [project-13-enterprise-identity-integration](project-13-enterprise-identity-integration/) | **CAPSTONE** — AD as central auth for CML, physical Cisco, Proxmox, OPNsense, Wazuh, M365 | ⬜ Planned |

> **Project 13** is the capstone that proves the whole homelab is one connected enterprise environment.
> It integrates Windows AD identity across CML routers, physical Cisco gear, Proxmox Linux VMs,
> OPNsense firewall, Wazuh SIEM, and Microsoft 365.
> It also now holds the imported AD/SSSD Linux integration reference from the
> former `homelab-projects` repo, because that work belongs with the Windows
> identity backbone.
