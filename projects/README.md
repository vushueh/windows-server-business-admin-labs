# Projects

Work through projects in order inside this Windows family, but do not work only
inside this family until all 13 projects are done. Each Windows milestone should
connect back to another family: NetOps, SOC, OPNsense, FreePBX, ServiceNow,
Microsoft 365, Proxmox, or case studies.

Project 13 (capstone) requires all previous projects complete.

See [../docs/execution-roadmap.md](../docs/execution-roadmap.md) for the
starting base, cross-family rotation plan, and done criteria.

## Master Queue Projects Assigned To This Family

The tables below keep the P01-P13 portfolio structure, while the master queue
controls cross-repository order. Special recovery and simulation items are
listed here so they remain visible and clickable instead of existing only in
the central YAML registry.

| Queue | Project | Related family project | Status |
|---|---|---|---|
| Q003 | [AD Recycle Bin test-object restore](project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/) | P11 recovery test 1 | ✅ Complete — restored the GUID-pinned disabled test user through both DCs in 0.51 minutes |
| Q004 | [Test-GPO backup and restore](project-11-backup-disaster-recovery/q004-test-gpo-backup-restore/) | P11 recovery test 3 | ✅ Complete — exact custom-GPO restore, RSoP, cleanup, and final review passed |
| Q007 | [DNS failure-triage simulation](project-03-dns-engineering/q007-dns-failure-triage-simulation/) | P03 follow-on break/fix proof | ✅ Complete — isolated wrong-record fault, repair, repeated retest, NXDOMAIN, cleanup, and reusable runbook passed |
| Q011 | [Isolated RHEL 10.2 baseline on Hyper-V](project-08-hyperv-operations/q011-isolated-rhel-baseline/) | Frozen historical P08 mirror; [canonical Linux record](https://github.com/vushueh/enterprise-linux-administration-labs/tree/main/projects/q011-isolated-rhel-baseline) (private until publication review) | ✅ Complete — mirror retained until the new repository becomes public |
| Q012 | [RHEL systemd break-fix lab](https://github.com/vushueh/enterprise-linux-administration-labs/tree/main/projects/q012-systemd-breakfix-lab) (private until publication review) | Linux portfolio project with a Windows-owned Hyper-V platform boundary | 🟡 Design complete — live clone/baseline approval pending |

Later Windows portfolio queue positions are P05/Q031, P06/Q032, P07/Q033,
P08/Q034, P09/Q035, P10/Q036, full P11/Q037, P12/Q041, and P13/Q079.
Additional Windows simulations are Q038 LAPS/gMSA, Q039 JEA/ASR, Q040 the
RDS/IIS move-off-DC rehearsal, and Q086 the onboarding capstone.
The canonical order and dependencies remain in `../../docs/homelab-goals.yaml`.

## Starting Base

Start with Projects 01-05 before building higher-level services:

| Order | Project | Why it comes first |
|-------|---------|--------------------|
| 1 | P01 Server Baseline | Confirms what the live server is doing and secures admin access. |
| 2 | P02 AD Architecture | Creates the OU, account, service-account, and group model every later project depends on. |
| 3 | P03 DNS Engineering | Makes name resolution reliable before more VMs and services are added. |
| 4 | P04 DHCP/IPAM Integration | Verifies Windows clients and Hyper-V VMs work with the Route10/OPNsense addressing design. |
| 5 | P05 GPO Baselines | Applies audit, firewall, account policy, and logon controls before client and SOC tests. |

After P05, rotate into client, SOC, backup, M365, NPS/RADIUS, FreePBX, and
ServiceNow work in smaller loops instead of finishing every Windows project
without touching the other families.

## Cross-Family Rotation Points

| After Windows milestone | Touch this family next | Purpose |
|-------------------------|------------------------|---------|
| P02 AD Architecture | NetOps + SOC docs | Record AD groups and admin tiers before they control devices/tools. |
| P03/P04 DNS + DHCP/IPAM integration | Route10 + OPNsense + NetOps | Align VLANs, hostnames, DHCP authority, reservations, and monitoring inventory. |
| P05/P07 GPO + client | SOC/Wazuh | Confirm Windows security events and client behavior are visible. |
| P08/P09 Hyper-V + PowerShell | Homelab automation | Tie VM inventory, backups, and scripts into operated workflows. |
| P10 Security Monitoring | SOC case workflow | Build one incident path from Windows event to Wazuh/TheHive evidence. |
| P12 M365/Entra | ServiceNow planning | Users, groups, licenses, and mail workflows become ticket/service-request sources. |
| P13 Identity Integration | CML, CCNA, OPNsense, Proxmox, FreePBX | Prove one AD identity across the whole lab with local fallback. |

## Core Projects

| Project | Focus | Status |
|---------|-------|--------|
| [project-01-server-baseline-hardening](project-01-server-baseline-hardening/) | Role inventory, secure admin access, firewall posture, privileged account separation | ✅ Complete |
| [project-02-ad-architecture](project-02-ad-architecture/) | Managed OU design, delegated admin, tiered accounts, AGDLP groups, service accounts, replica DC | ✅ Complete — 2026-07-03 |
| [project-03-dns-engineering](project-03-dns-engineering/) | AD-integrated DNS, Route10 `localdomain` forwarding, split DNS, secondary DNS, broken DNS troubleshooting | ✅ Complete — 2026-07-03 |
| [project-04-dhcp-ipam](project-04-dhcp-ipam/) | Route10/OPNsense DHCP authority validation, AD DNS client behavior, Hyper-V VM addressing, optional Windows DHCP design | ✅ Complete — 2026-07-03 |
| [project-05-gpo-security-baselines](project-05-gpo-security-baselines/) | Password/lockout policy, Windows Firewall GPO, audit policy, logon restrictions | ⬜ Planned |
| [project-06-file-server-access-governance](project-06-file-server-access-governance/) | Department shares, AGDLP groups, auditing, access reviews, ransomware-resistant structure | ⬜ Planned |
| [project-07-windows-client-lifecycle](project-07-windows-client-lifecycle/) | Domain join, RSAT, local admin control, baseline GPOs, test users, workstation hardening | ⬜ Planned |
| [project-08-hyperv-operations](project-08-hyperv-operations/) | Virtual switch design, VLANs, checkpoints policy, VM inventory, backup, recovery; historical Q011 and Q012 Hyper-V platform proof | 🟡 Q011 migrated and Q012 completed in the Linux portfolio; full P08 planned |
| [project-09-powershell-admin-platform](project-09-powershell-admin-platform/) | User provisioning, AD reports, stale account cleanup, Hyper-V reports, repeatable scripts | ⬜ Planned |
| [project-10-security-monitoring-ir](project-10-security-monitoring-ir/) | Event forwarding, lockout tracking, account lockout investigation, Defender, Wazuh/SIEM | ⬜ Planned |
| [project-11-backup-disaster-recovery](project-11-backup-disaster-recovery/) | System state backup, file restore, AD recovery planning, tested restore runbooks; [Q003](project-11-backup-disaster-recovery/q003-ad-recycle-bin-test-object-restore/) and [Q004](project-11-backup-disaster-recovery/q004-test-gpo-backup-restore/) are earlier master-queue proofs | 🟡 Q003/Q004 proofs complete; full P11 planned |
| [project-12-m365-entra-hybrid-identity](project-12-m365-entra-hybrid-identity/) | Custom domain, UPN alignment, Entra sync, license workflow, onboarding/offboarding | ⬜ Planned |
| [project-13-enterprise-identity-integration](project-13-enterprise-identity-integration/) | **CAPSTONE** — AD as central auth for CML, physical Cisco, Proxmox, OPNsense, Wazuh, M365 | ⬜ Planned |

> **Project 13** is the capstone that proves the whole homelab is one connected enterprise environment.
> It integrates Windows AD identity across CML routers, physical Cisco gear, Proxmox Linux VMs,
> OPNsense firewall, Wazuh SIEM, and Microsoft 365.
> It also now holds the imported AD/SSSD Linux integration reference from the
> former `homelab-projects` repo, because that work belongs with the Windows
> identity backbone.
