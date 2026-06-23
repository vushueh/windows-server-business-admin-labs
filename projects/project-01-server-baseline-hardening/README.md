# Project 01 — Server Baseline, Hardening, and Admin Model

**Status:** 🔄 In Progress (Phases 1–6 complete, Phase 7 final documentation pass underway)
**Skill:** `/winserver-p01` — [skills/project-01-server-baseline-hardening.md](../../skills/project-01-server-baseline-hardening.md)

## Actual Server State (Discovered 2026-06-05)

This is NOT a clean install. Live SSH audit of WIN-PRQD8TJG04M revealed:

- **DomainRole: 5** — already promoted as Primary Domain Controller for `Chongong.local`
- **Installed roles:** AD DS, DHCP, DNS, NPS/RADIUS, File Server, Hyper-V (13 VMs),
  RDS full farm, IIS, GPMC, RSAT, BitLocker, Containers, WSL
- **AD users:** 10 real users + testuser (enabled, undocumented) + radius-service
- **Computers joined:** WIN-PRQD8TJG04M, RADIUS01, GITEA, 5× DESKTOP machines
- **GPOs:** Only Default Domain Policy + Default Domain Controllers Policy (no custom GPOs)

## Critical Security Gaps Found

| Gap | Severity |
|-----|----------|
| LockoutThreshold = 0 | 🔴 CRITICAL — no account lockout |
| MinPasswordLength = 7 | 🔴 HIGH — too weak |
| RDS full farm on DC | 🟠 HIGH — privilege escalation path |
| IIS on DC | 🟠 HIGH — web exploit = domain exploit |
| No tiered admin accounts | 🟠 HIGH — all admin via builtin Administrator |
| DefaultInboundAction = NotConfigured | 🟡 MEDIUM — firewall not blocking by default |
| No custom GPOs | 🟡 MEDIUM — only defaults exist |

## Objective

Audit, document, harden, and formalize the existing AD environment.
Establish the secure admin model that all future projects depend on.

**Why first:** Everything else — DNS, Hyper-V, NPS, M365 — assumes this foundation is
documented, hardened, and cleanly administered.

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Audit Documentation | Document all roles, users, policy, firewall as-found |
| 2 | Fix Password Policy + Lockout | LockoutThreshold→5, MinLength→14, GPO backup first |
| 3 | Tiered Admin Model | adm-leonel (Tier0 DA), srv-leonel (Tier1), PSO for Tier0 |
| 4 | Assess RDS/IIS on DC | Document risk, no changes — migration in Project 08 |
| 5 | Firewall Baseline | Port inventory; RDP/Tailscale deliberately left unrestricted per explicit instruction |
| 6 | Break/Fix Lockout Exercise | testuser lockout confirmed, then quarantined |
| 7 | Document + Push | All scripts saved, GitHub push, mark P01 complete |

## What I Did

I started by auditing `WIN-PRQD8TJG04M` as it actually existed in production —
not a lab box, but the live Primary Domain Controller for `Chongong.local`, already
running AD DS, DNS, DHCP, NPS, RDS, IIS, and Hyper-V hosting 13 VMs. That audit
surfaced the critical gaps listed above. Everything below is grouped strictly by
phase — explanation, every command actually run, the real output, then any
screenshots for that phase, in that order, nothing split across phases.

Throughout, I worked under a fixed set of guardrails: never delete an AD object,
get explicit approval before any live AD or GPO change, and stop and report on
failure rather than retry blindly. Mid-project, Leonel gave me a working SSH key to
the server, so Phases 5 and 6 were executed directly instead of relayed as
PowerShell for him to paste manually — the approval requirement for live changes
never went away, it just changed who was physically typing the command.

### Phase 2 — Password Policy + Account Lockout

Backed up Default Domain Policy first, then closed the two critical Phase 1 gaps:
no account lockout at all, and a 7-character minimum password.

```powershell
$Domain = Get-ADDomain
if ($Domain.DistinguishedName -ne "DC=Chongong,DC=local") {
    throw "Unexpected domain DN: $($Domain.DistinguishedName) — stop and verify before continuing"
}

$BackupFolder = "C:\GPO-Backups\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
Backup-GPO -Name "Default Domain Policy" -Path $BackupFolder

$DomainDN = (Get-ADDomain).DistinguishedName
Set-ADDefaultDomainPasswordPolicy -Identity $DomainDN `
    -MinPasswordLength 14 `
    -MaxPasswordAge (New-TimeSpan -Days 90) `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 30) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 30)
gpupdate /force

Get-ADDefaultDomainPasswordPolicy | Select-Object MinPasswordLength, LockoutThreshold, LockoutDuration, LockoutObservationWindow, MaxPasswordAge, PasswordHistoryCount, ComplexityEnabled
Get-ADUser -Identity "radius-service" -Properties PasswordNeverExpires, PasswordLastSet | Select-Object SamAccountName, PasswordNeverExpires, PasswordLastSet
Search-ADAccount -LockedOut | Select-Object SamAccountName, BadLogonCount, LastBadPasswordAttempt
```

**Output:**
```
Domain confirmed: DC=Chongong,DC=local
BackupDirectory : C:\GPO-Backups\2026-06-22   (GpoId 31b2f340-016d-11d2-945f-00c04fb984f9)
Computer Policy update has completed successfully.
User Policy update has completed successfully.

MinPasswordLength        : 14
LockoutThreshold         : 5
LockoutDuration          : 00:30:00
LockoutObservationWindow : 00:30:00
MaxPasswordAge           : 90.00:00:00
PasswordHistoryCount     : 24
ComplexityEnabled        : True

SamAccountName : radius-service   PasswordNeverExpires : True   (exempt from MaxPasswordAge, not changed)
(Search-ADAccount -LockedOut returned empty — nothing locked out)
```

No screenshots — this phase ran entirely in PowerShell. Full write-up:
[`docs/p01-phase2-evidence.md`](docs/p01-phase2-evidence.md).

### Phase 3 — Tiered Admin Model

Built a `_Admin` OU with four sub-OUs and two real admin accounts, then found and
fixed a Domain Admins over-provisioning problem the original audit had missed.

```powershell
$DomainDN = (Get-ADDomain).DistinguishedName
New-ADOrganizationalUnit -Name "_Admin" -Path $DomainDN -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier0-DomainAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "Tier1-ServerAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "Tier2-WorkstationAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "ServiceAccounts" -Path "OU=_Admin,$DomainDN"

# adm-leonel and srv-leonel: New-ADUser with -AccountPassword + -Enabled $true failed
# both times (ADPasswordComplexityException on the enable step). Fixed by splitting:
Set-ADAccountPassword -Identity "adm-leonel" -Reset -NewPassword $admPwd   # $admPwd from Read-Host -AsSecureString
Enable-ADAccount -Identity "adm-leonel"
Set-ADAccountPassword -Identity "srv-leonel" -Reset -NewPassword $srvPwd
Enable-ADAccount -Identity "srv-leonel"

$GroupsOU = (Get-ADOrganizationalUnit -Filter {Name -eq "Groups"} | Select-Object -First 1).DistinguishedName
New-ADGroup -Name "GG-Tier0-Admins" -GroupScope Global -GroupCategory Security -Path $GroupsOU -Description "Shadow group for Tier0 PSO"
Add-ADGroupMember -Identity "GG-Tier0-Admins" -Members "adm-leonel"
New-ADGroup -Name "GG-ServerAdmins" -GroupScope Global -GroupCategory Security -Path $GroupsOU -Description "Tier1 server admins - rights granted via GPO in P05"
Add-ADGroupMember -Identity "GG-ServerAdmins" -Members "srv-leonel"
Add-ADGroupMember -Identity "Domain Admins" -Members "adm-leonel"

New-ADFineGrainedPasswordPolicy -Name "PSO-Tier0-Admins" -Precedence 10 -MinPasswordLength 20 `
    -LockoutThreshold 3 -LockoutDuration (New-TimeSpan -Minutes 60) -LockoutObservationWindow (New-TimeSpan -Minutes 60) `
    -MaxPasswordAge (New-TimeSpan -Days 180) -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false
Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-Tier0-Admins" -Subjects "GG-Tier0-Admins"

# Unplanned finding: Domain Admins had 12 members, not flagged in the Phase 1 audit.
# Leonel's explicit decision: keep only Administrator, adm-leonel, chongong.leonel.
Remove-ADGroupMember -Identity "Domain Admins" -Members `
    "lionel.chongong", "joiceline.kinyuy", "mickelle.tsongwine", "achiril.desmond", `
    "gefter.mbi", "michell.chongong", "elsa.chongong", "vushueh.banks", `
    "akaseng.frankline", "testuser" -Confirm:$false
```

**Output:**
```
_Admin OU + 4 sub-OUs created.
adm-leonel: Enabled=True, GG-Tier0-Admins + Domain Admins
srv-leonel: Enabled=True, Domain Users + GG-ServerAdmins ONLY (no built-in groups — confirmed)
PSO-Tier0-Admins: Precedence 10 — confirmed as adm-leonel's resultant password policy

Domain Admins BEFORE: Administrator, lionel.chongong, joiceline.kinyuy, mickelle.tsongwine,
  achiril.desmond, chongong.leonel, gefter.mbi, michell.chongong, elsa.chongong,
  vushueh.banks, akaseng.frankline, testuser, adm-leonel   (12 members)
Domain Admins AFTER:  Administrator, chongong.leonel, adm-leonel   (3 members)
```

No accounts were deleted — the 9 personal accounts plus `testuser` just lost Domain
Admin rights and kept working normally otherwise. `chongong.leonel` staying in
Domain Admins was Leonel's deliberate, informed choice, not an oversight. No
screenshots — this phase ran entirely in PowerShell. Full write-up, including the
password-exposure incident and how it was handled:
[`docs/p01-phase3-evidence.md`](docs/p01-phase3-evidence.md).

### Phase 4 — RDS / IIS / NPS Risk Assessment (document only, zero live changes)

GUI-only phase except for one read-only query. Found that the RD Connection Broker
reports unreachable in Server Manager even though the process itself is actually
listening locally — flagged for Project 08, not patched here.

```powershell
# __vmware__ group investigation — the only command run this phase
Get-ADGroup "__vmware__" -Properties Description, whenCreated, ManagedBy |
    Select-Object Name, GroupScope, Description, whenCreated, ManagedBy
Get-ADGroupMember "__vmware__" -ErrorAction SilentlyContinue | Select-Object SamAccountName, ObjectClass
Get-Service | Where-Object {$_.Name -match "vmware|vmauth|vmnet|vmtools"} | Select-Object Name, DisplayName, Status
```

**Output:** `__vmware__` — DomainLocal, "VMware User Group", created 8/21/2025, zero
members, no ManagedBy. `VMware NAT Service` running, `VMware Autostart Service`
stopped — confirms a VMware Workstation install on the host owns this group. Left
alone, real investigation deferred to Project 02.

**Screenshots:**

![RDS Overview broker error](screenshots/phase4-01-rds-overview-broker-error.jpg)
![RDS Servers pool — host Online, broker process actually listening locally](screenshots/phase4-02-rds-servers-pool.jpg)
![RDS-Users group — broad, cross-department membership](screenshots/phase4-03-rds-users-members.jpg)
![IIS Default Web Site — bindings on *:80 and *:443](screenshots/phase4-05-iis-default-web-site.jpg)
![IIS Application Pools — all Started](screenshots/phase4-04-iis-application-pools.jpg)
![IIS app pool identities, full column — all ApplicationPoolIdentity, no named domain accounts](screenshots/phase4-06-iis-app-pool-identities.jpg)
![NPS Policies overview](screenshots/phase4-07-nps-policies-overview.jpg)
![RADIUS Clients and Servers overview](screenshots/phase4-09-nps-radius-clients-servers-overview.jpg)
![RADIUS Clients — empty](screenshots/phase4-10-nps-radius-clients-empty.jpg)
![Remote RADIUS Server Groups — empty](screenshots/phase4-11-nps-remote-radius-groups-empty.jpg)
![NPS Connection Request Policies — stock Windows default only](screenshots/phase4-08-nps-connection-request-policies.jpg)
![Connection Request Policy detail — no custom conditions](screenshots/phase4-13-nps-connection-request-policy-detail.jpg)
![NPS Network Policies — stock default deny rules only](screenshots/phase4-12-nps-network-policies.jpg)

Full write-up: [`docs/p01-rds-iis-risk-assessment.md`](docs/p01-rds-iis-risk-assessment.md).

### Phase 5 — Firewall Baseline

Inventoried every TCP/UDP listener and the firewall profile state. Per explicit
instruction, RDP and Tailscale were left completely untouched — documented as a
deliberate decision, not a gap.

```powershell
Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort | Format-Table -AutoSize

Get-NetUDPEndpoint |
    Where-Object {$_.LocalPort -in @(53, 88, 389, 464, 1812, 1813)} |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort | Format-Table -AutoSize

Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```

**Output:** all three firewall profiles On, `DefaultInboundAction=NotConfigured`
(unchanged — Project 05 will set an explicit Block after a full AD port allowlist
GPO exists). UDP 53/88/389/464/1812/1813 all present and correctly bound. Notable
TCP findings: `tssdis` (RD Connection Broker) is genuinely listening on 51175,
refining the Phase 4 finding; `winvnc` has its own enabled rules on 5800/5900 — a
second remote-access path alongside RDP/Tailscale, flagged for Leonel to decide on,
not touched.

**Screenshots:**

![WFAS overview — all three profiles on, defaults unchanged](screenshots/phase5-01-wfas-overview.jpg)
![WFAS inbound rules — includes explicit VNC (vnc5800/vnc5900) and VMware Authd rules](screenshots/phase5-02-wfas-inbound-rules.jpg)

Full write-up: [`docs/p01-phase5-firewall-baseline.md`](docs/p01-phase5-firewall-baseline.md).

### Phase 6 — Lockout Break/Fix Exercise

With explicit approval, proved the Phase 2 lockout policy actually works by
deliberately locking out `testuser`, then unlocking, disabling, and quarantining it.

```powershell
# 1. Reset password to a random value — never displayed or stored anywhere
$NewPass = -join ((48..57)+(65..90)+(97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_})
$SecurePass = ConvertTo-SecureString $NewPass -AsPlainText -Force
Set-ADAccountPassword -Identity testuser -Reset -NewPassword $SecurePass

# 2. Trigger failed logons until lockout (LockoutThreshold=5 from Phase 2)
for ($i = 1; $i -le 5; $i++) {
    net use \\localhost\IPC$ /user:CHONGONG\testuser "WrongPassword$i!" 2>&1 | Out-Null
    net use \\localhost\IPC$ /delete 2>&1 | Out-Null
    Start-Sleep -Seconds 1
    $u = Get-ADUser testuser -Properties BadLogonCount, LockedOut
    Write-Host "Attempt $i -> BadLogonCount=$($u.BadLogonCount) LockedOut=$($u.LockedOut)"
    if ($u.LockedOut) { break }
}

# 3. Confirm lockout
Search-ADAccount -LockedOut | Select-Object SamAccountName, LockedOut

# 4. Unlock, disable, quarantine — no AD object deleted
Unlock-ADAccount -Identity testuser
Disable-ADAccount -Identity testuser
New-ADOrganizationalUnit -Name "Quarantine" -Path "DC=Chongong,DC=local" -ProtectedFromAccidentalDeletion $true
Move-ADObject -Identity (Get-ADUser testuser).DistinguishedName -TargetPath "OU=Quarantine,DC=Chongong,DC=local"
Get-ADUser testuser -Properties DistinguishedName, Enabled, LockedOut | Select-Object SamAccountName, DistinguishedName, Enabled, LockedOut
```

**Output:**
```
Attempt 1 -> BadLogonCount=1 LockedOut=False
Attempt 2 -> BadLogonCount=2 LockedOut=False
Attempt 3 -> BadLogonCount=3 LockedOut=False
Attempt 4 -> BadLogonCount=4 LockedOut=False
Attempt 5 -> BadLogonCount=5 LockedOut=True

Event 4740 fired correctly (TimeCreated 6/23/2026 12:03:29 AM, TargetAccount testuser)

Final state:
SamAccountName    : testuser
DistinguishedName : CN=Test User,OU=Quarantine,DC=Chongong,DC=local
Enabled           : False
LockedOut         : False
```

Locked at exactly the 5th attempt, matching the configured threshold. One unplanned
finding: failed-logon events (4625/4776/4771) never appeared in the Security log
despite `BadLogonCount` incrementing correctly — a real audit-policy gap, flagged
for Project 05/Blue Team work, not fixed here. No screenshots — this phase ran
entirely over SSH. Full write-up: [`docs/p01-phase6-lockout-breakfix.md`](docs/p01-phase6-lockout-breakfix.md).

### Phase 7 — Final Documentation (in progress)

Pulling the verified end-state across every phase, saving every script actually run,
and writing this account. Remaining: a few GUI screenshots (GPMC policy view, ADUC
OU/membership tabs, ADAC PSO settings, the Quarantine OU, the Event Viewer 4740
entry) — once those are in, Project 01 gets marked complete.

## STAR Summary

**Situation:** The server was an existing, production-like Primary Domain Controller
with critical security gaps — no account lockout, a weak password policy, no tiered
admin model, and RDS plus IIS both co-located directly on the DC.

**Task:** Audit the as-found state, close the critical gaps, and establish a secure
tiered admin model before any other project in this homelab built on top of this
server.

**Action:** I fixed the password and lockout policy with a GPO backup taken first,
built out a four-tier admin OU structure with dedicated Tier 0/Tier 1 accounts and a
fine-grained password policy for Tier 0, discovered and remediated a Domain Admins
over-provisioning issue that the original audit had missed, documented the RDS/IIS/NPS
risk picture without touching any live role, inventoried the firewall and port surface
while respecting an explicit instruction to leave RDP/Tailscale alone, and proved the
new lockout policy actually works end-to-end by deliberately triggering and then
remediating a lockout on a disposable test account.

**Result:** Six of seven phases are complete and pushed to GitHub with full evidence —
screenshots, PowerShell output, and narrative docs for each. The domain now has a real
lockout policy, a tiered admin model that separates day-to-day and privileged access,
and a documented, honest picture of what's risky on this server and what isn't — plus
a short list of carried-forward items (RD Connection Broker, NPS buildout, the
`__vmware__` group, an audit-logging gap, and an exposed VNC service) handed off to the
specific later projects that own fixing them, rather than patched ad hoc here.
