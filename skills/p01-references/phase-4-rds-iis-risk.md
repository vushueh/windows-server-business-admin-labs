# Phase 4 — Assess RDS, IIS, and NPS on DC (Document Only)

## Goal
Document what RDS, IIS, and NPS are doing on this DC. Investigate `radius-service` and `__vmware__`.
Write the risk assessment. Make NO changes to any role or service.

---

## Track A — GUI Steps

### Console 1: Server Manager — RDS overview
Open: **Start → Server Manager** → click **Remote Desktop Services**
1. Click **Overview** — screenshot the deployment topology
2. Click **Collections** — note any collection names

**Screenshot to capture:** RDS Overview topology diagram

### Console 2: ADUC — RDS-Users membership
1. ADUC → Groups OU → double-click **RDS-Users** → **Members** tab

**Screenshot to capture:** RDS-Users → Members tab

### Console 3: IIS Manager
Open: **Start → Windows Administrative Tools → IIS Manager**
1. Expand **WIN-PRQD8TJG04M → Sites** — note all sites and bindings
2. Expand **Application Pools** — note identity type for each pool

**Screenshot to capture:** Sites list showing names, state, and bindings

### Console 4: Network Policy Server
Open: **Start → Windows Administrative Tools → Network Policy Server** (or `nps.msc`)

> **DO NOT export NPS config to a file you commit to GitHub.**
> NPS XML exports contain RADIUS shared secrets in plaintext.

1. Expand **Policies → Network Policies** — screenshot the list
2. Expand **Policies → Connection Request Policies** — screenshot
3. Click each policy → **Conditions** tab — note if `radius-service` appears
4. Expand **RADIUS Clients and Servers → RADIUS Clients** — screenshot client list

**Screenshots to capture:** Network Policies list, Connection Request Policies list, each Conditions tab

### Console 5: __vmware__ group
In ADUC → find `__vmware__` → double-click → note Description, Members, ManagedBy

---

## Track B — PowerShell Verification

### NPS export (read-only — do NOT commit to GitHub):
```powershell
New-Item -ItemType Directory -Path "C:\Audit" -Force | Out-Null
$Path = "C:\Audit\nps-config-$(Get-Date -Format 'yyyy-MM-dd').xml"
Export-NpsConfiguration -Path $Path
Write-Host "NPS config at $Path — DO NOT push to GitHub (may contain shared secrets)"

$found = Select-String -Path $Path -Pattern "radius-service" -ErrorAction SilentlyContinue
if ($found) {
    Write-Host "radius-service FOUND in NPS config at lines: $($found.LineNumber -join ', ')"
} else {
    Write-Host "radius-service NOT found in NPS config — may be unused or legacy"
}
```

### Investigate __vmware__ group:
```powershell
Get-ADGroup "__vmware__" -Properties Description, whenCreated, ManagedBy |
    Select-Object Name, GroupScope, Description, whenCreated, ManagedBy

Get-ADGroupMember "__vmware__" -ErrorAction SilentlyContinue | Select-Object SamAccountName, ObjectClass

# Check for VMware services on the host
Get-Service | Where-Object {$_.Name -match "vmware|vmauth|vmnet|vmtools"} |
    Select-Object Name, DisplayName, Status
```
**Recommendation:** Keep `__vmware__` as-is until the VMware product is identified.
Do NOT remove — if a VMware product owns it, removal breaks that product's AD integration.
Defer investigation to Project 02 (AD Architecture).

### Document IIS app pool identities:
```powershell
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-WebConfiguration "system.applicationHost/applicationPools/add" |
    Select-Object name, @{N="IdentityType";E={$_.processModel.identityType}},
                       @{N="UserName";E={$_.processModel.userName}}
```
Flag: any pool running as a named domain account needs documentation.

---

## Risk Assessment (write to docs/p01-rds-iis-risk-assessment.md)

```
RISK: RDS Session Host co-located on PDC
SEVERITY: High
MITIGATION: Project 08 — create WIN-RDS01 (Session Host) + optional WIN-RDWEB01 (Gateway/Web/Broker/Licensing)
DO NOT TOUCH NOW: Removing Session Host without a target server breaks the farm.

RISK: IIS on PDC  
SEVERITY: High
MITIGATION: IIS migrates with RDS to WIN-RDS01/WIN-RDWEB01 in Project 08.
DO NOT TOUCH NOW: Stopping IIS may break RDS Web Access.

radius-service: [fill in from NPS export search above]
__vmware__: [fill in from group investigation above]
```

---

## Documentation Checklist — Phase 4

- [ ] Screenshot: RDS Overview deployment topology
- [ ] Screenshot: RDS-Users group members
- [ ] Screenshot: IIS sites list
- [ ] Screenshot: NPS Network Policies list
- [ ] Screenshot: NPS Conditions tab (radius-service reference or absence)
- [ ] PowerShell: radius-service NPS search result documented
- [ ] PowerShell: __vmware__ group metadata documented
- [ ] NO changes made to any role, service, or group
- [ ] NPS XML at C:\Audit\ only — NOT committed to GitHub
- [ ] docs/p01-rds-iis-risk-assessment.md written
