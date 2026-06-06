# Phase 3 — Create Tiered Admin Model

## Goal
Create the `_Admin` OU structure and two named admin accounts:
- **adm-leonel (Tier 0):** Full domain admin — DC-level changes only
- **srv-leonel (Tier 1):** Added to GG-ServerAdmins only — NO built-in groups, NO DC power

> **Why NOT Server Operators?** Server Operators is a built-in privileged group on DCs.
> Members can log on locally, shut down the DC, manage services. This is Tier 0 equivalent power.
> Tier 1 accounts must NOT have DC access.
> Project 05 (GPO Security Baselines) will grant local admin on member servers via GPO.

---

## Track A — GUI Steps

### Console 1: Active Directory Users and Computers (ADUC)
Open: **Start → Windows Administrative Tools → Active Directory Users and Computers** or `dsa.msc`

### Step A1 — Create _Admin OU structure

1. Right-click **Chongong.local** → **New → Organizational Unit**
   - Name: `_Admin` — check **Protect container from accidental deletion** → OK
2. Right-click `_Admin` → **New → Organizational Unit** → Name: `Tier0-DomainAdmins` → OK
3. Right-click `_Admin` → **New → Organizational Unit** → Name: `Tier1-ServerAdmins` → OK
4. Right-click `_Admin` → **New → Organizational Unit** → Name: `Tier2-WorkstationAdmins` → OK
5. Right-click `_Admin` → **New → Organizational Unit** → Name: `ServiceAccounts` → OK

**Screenshot to capture:** `_Admin` OU expanded showing all 4 sub-OUs

### Step A2 — Create adm-leonel (Tier 0 — run in RDP session, not SSH)

1. Click into **_Admin → Tier0-DomainAdmins**
2. Right-click → **New → User**
3. First name: `adm-leonel` / User logon: `adm-leonel` → Next
4. Set password (minimum 14 chars — policy active from Phase 2)
   - Uncheck: User must change password at next logon → Next → Finish
5. Double-click **adm-leonel** → **Member Of** tab → **Add** → `Domain Admins` → OK

**Screenshot to capture:** adm-leonel → Member Of tab showing Domain Admins

### Step A3 — Create srv-leonel (Tier 1 — run in RDP session)

1. Click into **_Admin → Tier1-ServerAdmins**
2. Right-click → **New → User**
3. First name: `srv-leonel` / User logon: `srv-leonel` → Next
4. Set password (14+ chars) → Next → Finish

**Do NOT add srv-leonel to any built-in group.** Only GG-ServerAdmins (Step A4).

**Screenshot to capture:** srv-leonel → Member Of tab (only Domain Users)

### Step A4 — Create GG-Tier0-Admins and GG-ServerAdmins groups

1. Click into **Groups** OU
2. Right-click → **New → Group**
   - Name: `GG-Tier0-Admins` / Scope: Global / Type: Security → OK
   - Double-click it → Members → Add → `adm-leonel` → OK
3. Right-click → **New → Group**
   - Name: `GG-ServerAdmins` / Scope: Global / Type: Security → OK
   - Double-click it → Members → Add → `srv-leonel` → OK

**Screenshot to capture:** GG-ServerAdmins → Members tab showing srv-leonel

### Step A5 — Create PSO (Active Directory Administrative Center)

Open: **Start → Windows Administrative Tools → Active Directory Administrative Center**

1. Click **Chongong (local)** → scroll to **Password Settings Container** → double-click
2. Tasks pane → **New → Password Settings**
3. Fill:
   - Name: `PSO-Tier0-Admins` / Precedence: `10`
   - Min password length: `20` / Enforce lockout: `3`
   - Lockout duration: `60 min` / Reset after: `60 min`
   - Password history: `24` / Complexity: checked
   - **Directly Applies To** → Add → `GG-Tier0-Admins`
4. OK

**Screenshot to capture:** PSO-Tier0-Admins in ADAC showing settings and Directly Applies To = GG-Tier0-Admins

---

## Track B — PowerShell Verification

### Verify OU structure:
```powershell
Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "_Admin"} |
    Select-Object Name, DistinguishedName | Sort-Object DistinguishedName
```
**Expected:** _Admin, Tier0-DomainAdmins, Tier1-ServerAdmins, Tier2-WorkstationAdmins, ServiceAccounts

### Verify adm-leonel:
```powershell
Get-ADUser -Identity "adm-leonel" -Properties MemberOf, DistinguishedName |
    Select-Object SamAccountName, DistinguishedName,
        @{N="Groups";E={($_.MemberOf | ForEach-Object {($_ -split ',')[0] -replace 'CN=',''}) -join ', '}}
```
**Expected:** DN in Tier0-DomainAdmins, Groups includes Domain Admins

### Verify srv-leonel has NO built-in groups:
```powershell
Get-ADPrincipalGroupMembership -Identity "srv-leonel" | Select-Object Name, GroupScope
```
**Expected:** ONLY Domain Users and GG-ServerAdmins — no Server Operators, no Administrators

### Create groups via PowerShell (alternative to GUI):
```powershell
$GroupsOU = (Get-ADOrganizationalUnit -Filter {Name -eq "Groups"} | Select-Object -First 1).DistinguishedName
if (-not $GroupsOU) { throw "Groups OU not found" }

try {
    New-ADGroup -Name "GG-Tier0-Admins" -GroupScope Global -GroupCategory Security `
        -Path $GroupsOU -Description "Shadow group for Tier0 PSO" -ErrorAction Stop
    Add-ADGroupMember -Identity "GG-Tier0-Admins" -Members "adm-leonel"
} catch { throw "GG-Tier0-Admins creation failed: $_" }

try {
    New-ADGroup -Name "GG-ServerAdmins" -GroupScope Global -GroupCategory Security `
        -Path $GroupsOU -Description "Tier1 server admins — rights granted via GPO in P05" -ErrorAction Stop
    Add-ADGroupMember -Identity "GG-ServerAdmins" -Members "srv-leonel"
} catch { throw "GG-ServerAdmins creation failed: $_" }
```

### Create PSO via PowerShell:
```powershell
New-ADFineGrainedPasswordPolicy `
    -Name "PSO-Tier0-Admins" -Precedence 10 -MinPasswordLength 20 `
    -LockoutThreshold 3 -LockoutDuration (New-TimeSpan -Minutes 60) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 60) `
    -MaxPasswordAge (New-TimeSpan -Days 180) -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false

Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-Tier0-Admins" -Subjects "GG-Tier0-Admins"
```

### Verify PSO applies to adm-leonel:
```powershell
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel"
```
**Expected:** Returns PSO-Tier0-Admins (Precedence 10) — NOT Default Domain Policy.

---

## Documentation Checklist — Phase 3

- [ ] Screenshot: _Admin OU expanded showing all 4 sub-OUs
- [ ] Screenshot: adm-leonel → Member Of = Domain Admins
- [ ] Screenshot: srv-leonel → Member Of = Domain Users + GG-ServerAdmins ONLY (not Server Operators)
- [ ] Screenshot: GG-ServerAdmins → Members = srv-leonel
- [ ] Screenshot: PSO-Tier0-Admins in ADAC — settings + Directly Applies To
- [ ] PowerShell: Get-ADUserResultantPasswordPolicy returns PSO-Tier0-Admins
- [ ] PowerShell: Get-ADPrincipalGroupMembership srv-leonel shows NO built-in server groups
- [ ] chongong.leonel confirmed NOT in Domain Admins
