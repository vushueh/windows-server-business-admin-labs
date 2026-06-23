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

## NPS/RADIUS Starting Plan

NPS/RADIUS is the first cross-family identity bridge because it connects Windows
AD to CML, physical Cisco, OPNsense, and later firewall/admin workflows.

| Step | Scope | Evidence |
|------|-------|----------|
| 1 | Audit current NPS role, policies, clients, and the existing `radius-service` account. | Exported NPS config saved outside public docs if secrets exist; redacted summary committed. |
| 2 | Create AD groups `GG-NetAdmins` and `GG-Net-ReadOnly` if they do not already exist. | Group membership screenshot or PowerShell output. |
| 3 | Add one test RADIUS client first, preferably a lab/CML device before physical devices. | NPS client entry with shared secret redacted. |
| 4 | Build read-only network policy before admin policy. | Read-only login gets limited privilege. |
| 5 | Build admin network policy. | Admin login gets intended privilege only for approved AD group. |
| 6 | Confirm local fallback on every device before enabling AD-backed login broadly. | Break/fix test: NPS unavailable, local device login still works. |
| 7 | Expand to physical Cisco, OPNsense, then Palo Alto only after each earlier target is verified. | One row per device family: configured, verified, rollback path. |

Guardrail: never reuse the same RADIUS shared secret for every device family.
Use unique shared secrets and keep full NPS exports out of public GitHub if they
contain secrets.

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
3. Audit existing NPS/RADIUS role, clients, policies, and secrets-handling risk
4. Deploy NPS/RADIUS to one lab/CML device first
5. Expand NPS/RADIUS to physical Cisco gear after fallback is verified
6. Deploy SSSD on Proxmox Linux VMs
7. Configure OPNsense RADIUS admin auth
8. Deploy Wazuh agent on WIN-DC01 for event forwarding
9. Verify Entra sync includes NPS/RADIUS groups
10. End-to-end test: one user, all systems
11. Break/fix: take AD/NPS offline — verify fallback on every system
12. Document + push to GitHub

## STAR Summary

**Situation:** 6 lab families with isolated authentication — network, Windows, Linux, cloud all separate.
**Task:** Unify authentication under one AD identity source with tested fallback.
**Action:** _(completed when project runs)_
**Result:** _(completed when project runs)_
