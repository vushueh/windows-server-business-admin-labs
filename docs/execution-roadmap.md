# Execution Roadmap

This repo is the Windows identity and administration family, but I will not build
it in isolation. The Windows work creates the identity backbone, then each
milestone should connect to another family so the homelab grows like one operated
environment instead of several disconnected projects.

## Operating Rule

Work in project order inside this repo, but rotate across families after each
major Windows milestone.

- Build the Windows foundation.
- Verify it with a real client, log source, network device, SOC tool, or service.
- Document the evidence.
- Move to the next family checkpoint before continuing too far ahead.

## Starting Base

The first base is Projects 01 through 05. These must be good enough before the
rest of the Windows family can be trusted.

| Order | Windows project | What must be true before moving on | Cross-family check |
|-------|-----------------|------------------------------------|--------------------|
| 1 | P01 Server Baseline | Server role inventory, admin model, lockout policy, firewall/RDP posture, and break/fix evidence are documented. | Homelab-management status reflects the DC as a critical identity platform. |
| 2 | P02 AD Architecture | Managed OU structure, tiered admin/service accounts, AGDLP groups, delegated admin, and replica-DC decision are documented. | NetOps/SOC docs know which AD groups will later control access. |
| 3 | P03 DNS Engineering | DC DNS, forwarders, reverse zones, stale-record handling, and DNS break/fix tests are documented. | NetOps tools can resolve key Windows, firewall, Proxmox, and SOC hosts by name. |
| 4 | P04 DHCP/IPAM | Scope design, reservations, options, relay planning, and IPAM records are documented. | OPNsense/NetOps topology uses the same addressing plan. |
| 5 | P05 GPO Baselines | Audit, firewall, lockout/password, workstation restrictions, and Tier 0 logon restrictions are staged and verified. | SOC/Wazuh has the audit events needed for Windows case studies. |

## Rotation Plan

Use this as the working rhythm after the starting base.

| Rotation | Windows focus | Other family to touch | Why |
|----------|---------------|-----------------------|-----|
| A | P01-P02 identity foundation | Network Operations / SOC docs | Define who can administer what before wiring more tools into AD. |
| B | P03-P04 DNS, DHCP, IPAM | OPNsense + NetOps monitoring | Routing, DHCP, DNS, and monitoring must agree on hostnames and subnets. |
| C | P05-P07 GPO, file access, client lifecycle | SOC / Wazuh | A domain client and audit policy create realistic Windows security events. |
| D | P08-P09 Hyper-V and PowerShell | Homelab automation / backup workflows | VM lifecycle, backup, and admin scripts become repeatable operations. |
| E | P10 security monitoring | SOC family | WEF, Wazuh, and incident playbooks become portfolio-ready SOC evidence. |
| F | P11 backup and DR | Homelab-management runbooks | Restore evidence proves the environment is operated, not just built. |
| G | P12 M365/Entra | ServiceNow planning | Users, groups, licenses, and mail/admin workflows feed tickets and service requests. |
| H | P13 identity integration | CML, CCNA, OPNsense, Proxmox, FreePBX, SOC | One AD identity should work across the lab with documented fallback paths. |

## Project Done Criteria

Each project is done only when these exist:

| Requirement | Evidence |
|-------------|----------|
| Plain-language summary | Project README explains what was built and why it matters. |
| Before state | Audit output, screenshots, or notes show the starting condition. |
| Build record | Commands, GUI steps, scripts, or config exports are saved without secrets. |
| Verification | Expected commands/screenshots prove the result works. |
| Rollback or recovery | A safe undo/recovery path is written. |
| Cross-family note | The README says which other family this project affects next. |
| Portfolio hook | A short STAR summary is updated with real results. |

## Immediate Work Queue

Start here:

1. Use the completed P02 AD structure as the identity base for NetOps/SOC alignment.
2. Keep `WIN-DC02` as the remaining replica-DC dependency when install media and VM details are ready.
3. Use the completed Project 03 current-PDC DNS work as the name-resolution base; extend DNS checks to `WIN-DC02` after it exists.
4. Run Project 04 DHCP/IPAM.
5. Run Project 05 GPO Security Baselines.
6. Build Project 07 `WIN-WS01` only after P05 and the required file/share pieces are ready.

This order gives the lab a stable identity, name-resolution, addressing, and
policy base before the SOC, ServiceNow, FreePBX, and case-study work depends on
it.
