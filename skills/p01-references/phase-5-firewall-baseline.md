# Phase 5 — Firewall Baseline and Open Port Review

## Goal
Document all TCP and UDP listeners. Restrict RDP to Tailscale-only.
DefaultInboundAction is documented but NOT changed — requires a full AD port allowlist GPO
which belongs in Project 05 (GPO Security Baselines).

---

## Track A — GUI Steps (Windows Firewall with Advanced Security)

Open: **Start → Windows Administrative Tools → Windows Firewall with Advanced Security**
*(or: `wf.msc` in Run)*

### Step A1 — Check firewall profile defaults
1. Click the root node **Windows Firewall with Advanced Security**
2. Note all three profiles: Domain / Private / Public — state and Inbound default

**Screenshot to capture:** Overview panel showing all three profiles with Inbound default = NotConfigured

### Step A2 — Review inbound rules
1. Click **Inbound Rules**
2. Sort by **Protocol** column
3. Look for rules allowing inbound from **Any** remote address with no source restriction

**Screenshot to capture:** Inbound Rules sorted by Protocol showing enabled rules

### Step A3 — Restrict RDP to Tailscale
1. Find all rules with "Remote Desktop" in the name
2. For each enabled RDP rule: double-click → **Scope** tab
3. Under "Remote IP address" → **These IP addresses:** → Add your exact management Tailscale IP
   *(Run `tailscale ip -4` on your management machine to get the exact IP)*
4. OK → Apply

**Screenshot to capture:** RDP rule → Scope tab showing the specific management Tailscale IP as Remote IP address

> **Use your specific Tailscale node IP, not 100.64.0.0/10.**
> The /10 covers the whole Tailscale carrier-grade NAT range. Your node IP is tighter and safer.

---

## Track B — PowerShell Verification

### TCP listeners with process names:
```powershell
Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}},
        OwningProcess |
    Sort-Object LocalPort | Format-Table -AutoSize
```

### UDP listeners — NPS, DNS, Kerberos (critical — add this, it was missing before):
```powershell
Get-NetUDPEndpoint |
    Where-Object {$_.LocalPort -in @(53, 88, 389, 464, 1812, 1813)} |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort | Format-Table -AutoSize
```

**Expected UDP listeners:**
| Port | Service |
|------|---------|
| 53 | DNS |
| 88 | Kerberos |
| 389 | LDAP |
| 464 | kpasswd |
| 1812 | RADIUS auth (NPS) |
| 1813 | RADIUS accounting (NPS) |

If 1812/1813 missing: `Get-Service -Name IAS` — NPS service may not be running.

### Restrict RDP via PowerShell (correct method — via AddressFilter):
```powershell
$RdpRules = Get-NetFirewallRule -DisplayName "*Remote Desktop*" -ErrorAction SilentlyContinue |
    Where-Object {$_.Direction -eq "Inbound" -and $_.Enabled -eq "True"}

if (-not $RdpRules) {
    Write-Warning "No enabled inbound Remote Desktop rules found — check manually"
} else {
    # Replace this with the exact management Tailscale IP that should be allowed to RDP.
    # Do not use 100.64.0.0/10 here.
    $TailscaleIP = "REPLACE_WITH_MANAGEMENT_TAILSCALE_IP"

    if ($TailscaleIP -eq "REPLACE_WITH_MANAGEMENT_TAILSCALE_IP" -or
        $TailscaleIP -eq "100.64.0.0/10" -or
        [string]::IsNullOrWhiteSpace($TailscaleIP)) {
        throw "Refusing to restrict RDP: replace the placeholder with one specific management Tailscale IP first."
    }

    $RdpRules | Get-NetFirewallAddressFilter |
        Set-NetFirewallAddressFilter -RemoteAddress $TailscaleIP

    Write-Host "RDP restricted to: $TailscaleIP"
    $RdpRules | Get-NetFirewallAddressFilter | Select-Object RemoteAddress
}
```

### Export baselines:
```powershell
New-Item -ItemType Directory -Path "C:\Audit" -Force | Out-Null

Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort |
    Export-Csv "C:\Audit\tcp-listeners-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation

Get-NetUDPEndpoint |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort |
    Export-Csv "C:\Audit\udp-endpoints-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation

Get-NetFirewallRule -Direction Inbound |
    Select-Object DisplayName, Enabled, Profile, Action |
    Export-Csv "C:\Audit\firewall-inbound-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation

Write-Host "Baselines saved to C:\Audit\"
```

### DefaultInboundAction — document and defer to P05:
```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```
Currently `NotConfigured`. Do NOT set to Block without a GPO that first allows all AD ports.
Deferred to Project 05 (GPO Security Baselines).

---

## Documentation Checklist — Phase 5

- [ ] Screenshot: WFAS overview — all three profiles and inbound default
- [ ] Screenshot: RDP rule → Scope tab with exact management Tailscale IP
- [ ] TCP listeners CSV in docs/
- [ ] UDP endpoints CSV — confirm 1812/1813 present
- [ ] Firewall inbound rules CSV in docs/
- [ ] DefaultInboundAction NOT changed — P05 GPO noted
- [ ] Any unexpected listeners documented
