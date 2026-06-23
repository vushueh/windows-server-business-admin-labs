# Project 01 — Phase 5: Firewall Baseline and Open Port Review

**Date:** 2026-06-22
**Method:** GUI (Windows Firewall with Advanced Security, screenshots) + direct
read-only PowerShell queries over SSH (`winserver01`) for TCP/UDP listener inventory.
**Scope:** Document only — no firewall rules, profiles, or RDP/Tailscale configuration
were changed. **Per explicit instruction, RDP and Tailscale were left untouched** —
the RDP-In rule remains unscoped (All profiles, no remote-address restriction). This
is a deliberate decision, not an oversight; do not "fix" it in a later phase without
asking first.

---

## 1. Windows Firewall with Advanced Security — profile overview

All three profiles enabled and using Windows' built-in default behavior, unchanged:

| Profile | Firewall | Inbound default | Outbound default |
|---------|----------|------------------|-------------------|
| Domain (active) | On | Block (unmatched) | Allow (unmatched) |
| Private | On | Block (unmatched) | Allow (unmatched) |
| Public | On | Block (unmatched) | Allow (unmatched) |

![WFAS overview — all three profiles](../screenshots/phase5-01-wfas-overview.jpg)

Confirmed via PowerShell: `Get-NetFirewallProfile` → `DefaultInboundAction` =
`NotConfigured` on all three (i.e., using the OS default shown above). **Not changed.**
Setting this to an explicit `Block` requires a full AD port allowlist GPO first —
deferred to Project 05 (GPO Security Baselines), per the existing do-not-touch list.

---

## 2. Inbound rules (enabled, partial list captured)

| Rule | Profile |
|------|---------|
| Firefox (x2) | Private |
| HNS Container Networking — DNS / ICS DNS (x4) | All |
| Microsoft Office Outlook | Domain |
| **RDP-In** | **All — unscoped, left as-is (explicit instruction, no Tailscale/RDP changes)** |
| Tailscale-In (x2), Tailscale-Process | Domain/Private — left as-is |
| VMware Authd Service (x2) | Domain/Private |
| vnc5800, vnc5900 | Domain |

![WFAS inbound rules](../screenshots/phase5-02-wfas-inbound-rules.jpg)

```
FINDING: VNC (winvnc) has explicit, enabled inbound firewall rules (vnc5800,
  vnc5900, Domain profile) — a second remote-access surface into the PDC besides
  RDP and Tailscale. This is deliberately configured (explicit named rules), not
  an accidental leak.
SEVERITY: Medium — worth knowing about, no action taken this phase.
RECOMMENDATION: Confirm with Leonel whether VNC access is still needed; if so,
  scope it the same way RDP/Tailscale already are managed. Defer scoping decision
  to Leonel — not touched in Phase 5.
```

---

## 3. TCP listener inventory (via SSH, read-only)

Full inventory captured `2026-06-22`. Notable items beyond the expected AD/DC set
(`lsass` on 88/389/464/3268/3269, `dns` on 53, `svchost` on 135/3389/etc.):

| Port(s) | Process | Note |
|---------|---------|------|
| 22 | sshd | Claude's new SSH access (`winserver_claude_ed25519`) |
| 51175 | **tssdis** | RD Connection Broker process **is actually running and listening locally** — refines the Phase 4 finding. The Server Manager "cannot connect to RD Connection Broker" error is more likely a name-resolution/binding issue reaching `WIN-PRQD8TJG04M.Chongong.local` than the broker being fully down. Worth a closer look in Project 08, not this phase. |
| 902, 912 | vmware-authd | Confirms the VMware product tied to the `__vmware__` AD group (Phase 4) is installed and running |
| 5800, 5900 | winvnc | VNC server — see Section 2 finding above |
| 6600–6602 | WindowsAdminCenter | Windows Admin Center listening |
| 1801, 2103, 2105, 2107 | mqsvc | Message Queuing service |
| 2179 | vmms | Hyper-V Virtual Machine Management (expected — 13 VMs hosted here) |
| 9389 | Microsoft.ActiveDirectory.WebServices | Expected AD Web Services |
| 11434, 52925 | ollama / ollama app | Local AI tooling on the host — not infra-relevant, noted for completeness |
| 35771, 65218 | tailscaled | Tailscale control — left untouched |
| 42050 | OneDrive.Sync.Service | Background sync, not infra-relevant |

No action taken on any of these. Full raw output available in session log; not
exported to a CSV in this pass since the SSH query output was already structured
and complete.

---

## 4. UDP listener inventory (via SSH, read-only)

All expected ports present and correctly bound:

| Port | Service | Status |
|------|---------|--------|
| 53 | DNS | Present |
| 88 | Kerberos | Present (`lsass`) |
| 389 | LDAP | Present (`lsass`) |
| 464 | kpasswd | Present (`lsass`) |
| 1812 | RADIUS auth (NPS) | Present (`svchost`) |
| 1813 | RADIUS accounting (NPS) | Present (`svchost`) |

Note: 1812/1813 are listening via the IAS/NPS service even though, per Phase 4,
**zero RADIUS clients are configured**. This is normal default service behavior
(the listener binds on service start regardless of client config), not a
misconfiguration — consistent with the Phase 4 finding that RADIUS/NPS buildout
hasn't started.

---

## 5. Documentation Checklist — Phase 5

- [x] Screenshot: WFAS overview — all three profiles and inbound default
- [x] Screenshot: Inbound Rules list
- [x] TCP listener inventory captured (via SSH, structured output)
- [x] UDP endpoint inventory captured — 1812/1813 confirmed present
- [x] DefaultInboundAction confirmed NOT changed — deferred to Project 05
- [x] RDP / Tailscale explicitly left untouched per instruction — not a gap
- [x] Unexpected listeners documented (VNC, Windows Admin Center, vmware-authd,
      mqsvc, ollama, OneDrive)

**Phase 5 complete. Proceeding to Phase 6 (lockout break/fix exercise).**
