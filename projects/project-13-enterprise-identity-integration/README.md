# Project 13 — Enterprise Identity Integration Across Lab Families

**Status:** ⬜ Planned (requires Projects 01–12 complete)
**Skill:** `/winserver-p13` — written when this project starts

## Objective

Use Windows Server Active Directory as the central identity source for network devices,
servers, cloud accounts, and security monitoring across ALL homelab families.

**This proves the entire homelab is one connected enterprise environment.**

## Imported Reference

The former `homelab-projects` repo had a full AD/SSSD Linux VM integration
plan. I moved that plan here because it is part of this capstone, not a separate
project family.

| Reference | Why it belongs here |
|-----------|---------------------|
| [AD UNIX Attributes + SSSD Linux VM Integration](references/ad-sssd-linux-integration-full-spec.md) | Shows how Linux VMs can authenticate against Active Directory with SSSD, Kerberos/LDAP, AD-controlled sudo groups, and centralized account management. |

## What Gets Integrated

| Service | Integration | Protocol |
|---------|------------|----------|
| CML Enterprise Labs — Cisco routers | AAA login → NPS → AD group → privilege level | RADIUS |
| Physical CCNA gear — R1/R2/SW1/SW2 | AAA login → NPS → AD group → privilege level | RADIUS |
| OPNsense admin login | Admin auth → NPS → AD group | RADIUS |
| Proxmox Linux VMs | SSSD domain join → AD users can SSH | Kerberos/LDAP |
| Wazuh SIEM | Windows event log forwarding → AD/Windows telemetry | Wazuh agent |
| Microsoft 365 | Entra Connect Sync → AD users get M365 accounts | OAuth/SAML |
| PowerShell remoting | AD admins WinRM to all Windows servers | WinRM/Kerberos |

## AD Groups for Network Auth

```
GG-NetAdmins      → RADIUS → Cisco privilege 15 (full CLI)
GG-Net-ReadOnly   → RADIUS → Cisco privilege 5 (read only)
GG-ServerAdmins   → full admin on member servers
GG-SOC-Analysts   → read-only on security tools
```

## Test Scenario (Capstone Proof)

User `leonel` signs in with one AD identity and can:
- Log into Windows Server GUI and PowerShell
- Access department file shares by group membership
- SSH into Cisco routers in CML (privilege 15) via NPS/RADIUS
- SSH into physical R1 and SW1 (privilege 15) via NPS/RADIUS
- SSH into Proxmox Linux VMs (SSSD AD auth)
- Be monitored by Wazuh (event logs forwarded)
- Log into Microsoft 365 (Entra sync)
- And recover access if AD goes down (local fallback on each system)

## Phases

1. Audit integration readiness (all P01-12 dependencies met?)
2. Design integration architecture and AD groups
3. Deploy NPS/RADIUS — configure CML and physical Cisco gear AAA
4. Deploy SSSD on Proxmox Linux VMs
5. Configure OPNsense RADIUS admin auth
6. Deploy Wazuh agent on WIN-DC01 for event forwarding
7. Verify Entra sync includes NPS/RADIUS groups
8. End-to-end test: one user, all systems
9. Break/fix: take AD offline — verify fallback on every system
10. Document + push to GitHub

## STAR Summary

**Situation:** 6 lab families with isolated authentication — network, Windows, Linux, cloud all separate.
**Task:** Unify authentication under one AD identity source with tested fallback.
**Action:** _(completed when project runs)_
**Result:** _(completed when project runs)_
