# Phase 7 — Document Verified State + Push to GitHub

## Goal
Capture final verified state, save all scripts, write project summary, push to GitHub.

---

## Track A — Final Screenshot Pass

| Console | What to screenshot |
|---------|--------------------|
| GPMC → Default Domain Policy → Account Policies | MinPasswordLength=14, Threshold=5 |
| ADUC → _Admin OU tree | All 4 sub-OUs visible |
| ADUC → adm-leonel → Member Of | Domain Admins |
| ADUC → srv-leonel → Member Of | GG-ServerAdmins only |
| ADAC → PSO-Tier0-Admins | Settings + Directly Applies To = GG-Tier0-Admins |
| ADUC → Quarantine OU | testuser disabled |
| WFAS → RDP rule → Scope tab | Tailscale IP as Remote IP |
| Event Viewer → Security → Filter 4740 | testuser lockout event |

---

## Track B — PowerShell Final State

```powershell
Write-Host "=== Password Policy ===" -ForegroundColor Cyan
Get-ADDefaultDomainPasswordPolicy | Select-Object MinPasswordLength, LockoutThreshold, LockoutDuration

Write-Host "=== Tiered Admin Accounts ===" -ForegroundColor Cyan
Get-ADUser -Filter {SamAccountName -like "adm-*" -or SamAccountName -like "srv-*"} `
    -Properties Enabled, DistinguishedName, MemberOf |
    Select-Object SamAccountName, Enabled, DistinguishedName

Write-Host "=== PSO ===" -ForegroundColor Cyan
Get-ADFineGrainedPasswordPolicy -Filter * | Select-Object Name, Precedence, MinPasswordLength
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel" | Select-Object Name, Precedence

Write-Host "=== testuser ===" -ForegroundColor Cyan
Get-ADUser -Identity "testuser" -Properties Enabled, DistinguishedName |
    Select-Object SamAccountName, Enabled, DistinguishedName

Write-Host "=== Firewall ==" -ForegroundColor Cyan
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```

Save output to `docs/p01-verified-final-state.md`.

---

## Project Documentation Structure

```
projects/project-01-server-baseline-hardening/
├── README.md
├── docs/
│   ├── p01-audit-baseline.md
│   ├── p01-rds-iis-risk-assessment.md
│   ├── p01-verified-final-state.md
│   ├── tcp-listeners-YYYY-MM-DD.csv
│   ├── udp-endpoints-YYYY-MM-DD.csv
│   └── firewall-inbound-YYYY-MM-DD.csv
└── scripts/
    ├── p01-phase2-password-policy.ps1
    ├── p01-phase3-tiered-admin.ps1
    ├── p01-phase5-firewall-baseline.ps1
    └── p01-phase6-lockout-exercise.ps1
```

> **Do NOT commit:** `C:\Audit\nps-config-*.xml` (may contain RADIUS shared secrets)

---

## Git Push from WSL

```bash
cd /home/leonel/code/windows-server-business-admin-labs
git remote -v
git add projects/project-01-server-baseline-hardening/
git commit -m "feat: P01 server baseline + hardening complete

- Password policy: 14-char min, threshold=5, 30-min lockout
- _Admin OU: Tier0-DomainAdmins, Tier1-ServerAdmins
- adm-leonel (Domain Admins), srv-leonel (GG-ServerAdmins only)
- PSO-Tier0-Admins: min 20 chars, lockout 3, precedence 10
- RDS/IIS risk documented
- Firewall baseline captured, RDP restricted to Tailscale
- testuser quarantined"
git push origin main
```

---

## Documentation Checklist — Phase 7

- [ ] All screenshots in project screenshots/ subfolder
- [ ] All scripts saved as .ps1 files
- [ ] All docs written
- [ ] NPS XML NOT committed to GitHub
- [ ] GitHub push confirmed
- [ ] Parent skill (/winserver) P01 = ✅
- [ ] CODEX-LOG.md updated
- [ ] CLAUDE-REVIEW.md items resolved
