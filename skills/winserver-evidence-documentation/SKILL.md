---
name: winserver-evidence-documentation
description: >
  Windows Server evidence and portfolio documentation workflow.
  Trigger when Leonel says: "document phase", "save evidence", "take screenshots",
  "update README", "phase complete", "project complete", "portfolio update",
  "what did I build", "log the break fix", or after completing any Windows Server
  phase or project (P01-P13). This skill handles PROVING the work was done.
  The technical skills (winserver-p01, winserver-projects) handle HOW to do the work.
---

# Windows Server — Evidence and Portfolio Documentation

## Purpose

This skill guides you through capturing and organizing proof that each phase and
project was completed. The outcome is a public GitHub portfolio that shows:
- What you built (screenshots from real admin tools)
- That it works (PowerShell verification output)
- That you can troubleshoot (break/fix log)
- Why it matters (portfolio narrative in README)

## No-Secrets Policy

**Never commit to GitHub:**
```
❌ Passwords or password hashes
❌ M365 tenant credentials or secrets
❌ Entra Connect service account passwords
❌ NPS exports (contain RADIUS shared secrets)
❌ BitLocker recovery keys
❌ Screenshots showing credential fields with real values
❌ Any file from C:\Audit\ that was flagged as sensitive (e.g. NPS XML)
```

**Safe to commit:**
```
✅ PowerShell command outputs (no credentials in output)
✅ Screenshots of GUI config screens (blur password fields)
✅ AD object exports (Get-ADUser, Get-GPO, etc.)
✅ GPO backup files (XML format — settings only, no secrets)
✅ Anonymized break/fix logs
```

---

## Folder Structure Per Project

Every project uses this structure. Create it before starting Phase 1.

```
projects/project-NN-name/
├── README.md                    ← planning + STAR summary (fill Action/Result when done)
├── phases/                      ← step-by-step guides (read before each phase)
├── configs/
│   ├── pre-project-state.txt    ← export before touching anything
│   └── post-project-state.txt   ← export after project complete
├── verification/
│   ├── screenshots/             ← all GUI screenshots go here
│   └── command-outputs/         ← all PowerShell/cmd outputs go here
└── troubleshooting/
    └── break-fix-log.md         ← log every problem encountered
```

---

## Screenshot Naming Convention

```
<project>-<phase>-<what-it-shows>.png

Examples:
  p02-ph1-ou-structure-aduc.png          ← P02 Phase 1, OU tree in ADUC
  p02-ph3-tiered-accounts-aduc.png       ← P02 Phase 3, admin accounts in ADUC
  p05-ph3-password-policy-gpmc.png       ← P05 Phase 3, password settings in GPMC
  p07-ph4-adm-leonel-blocked-ws01.png    ← P07 Phase 4, Tier0 denied on workstation
  p09-ph1-wac-dashboard.png              ← P09 Phase 1, WAC main screen
```

**Always capture:**
- BEFORE screenshot (shows the default/original state)
- AFTER screenshot (shows your change applied)
- Verification screenshot (shows it working, e.g. a successful ping or policy applied)

---

## Verification Output Naming Convention

```
<project>-<phase>-<command>-output.txt

Examples:
  p02-ph7-repadmin-replsummary.txt
  p02-ph8-netdom-query-fsmo.txt
  p05-ph3-gpresult-workstation.txt     ← use real phase numbers
  p10-ph3-winevent-4740.txt
```

---

## Config File Naming Convention

```
pre-<project>-<device-or-component>.txt
post-<project>-<device-or-component>.txt

Examples:
  pre-p02-ad-users.txt       ← Get-ADUser -Filter * output before P02
  post-p02-ad-users.txt      ← Get-ADUser -Filter * output after P02
  pre-p05-gpo-list.txt       ← Get-GPO -All before P05
  post-p05-gpo-list.txt      ← Get-GPO -All after P05
```

---

## Per-Phase Documentation Loop

Run this loop for every phase:

### Step 1 — Before State (start of phase)
```powershell
# Run the appropriate before-state export for the project
# Examples:
Get-ADOrganizationalUnit -Filter * | Select DistinguishedName | Sort | Out-File configs\pre-p02-ou-state.txt
Get-GPO -All | Select DisplayName, GpoStatus | Out-File configs\pre-p05-gpo-list.txt
Get-DhcpServerv4Scope | Out-File configs\pre-p04-dhcp-scopes.txt
```
Take a **before screenshot** of the relevant GUI tool.

### Step 2 — Do the Work
Follow Track A (GUI) from the phase file:
- Screenshot each significant GUI screen as you configure it
- Name screenshots following the convention above

### Step 3 — After State (end of phase)
```powershell
# Run the after-state export matching Step 1
# Same command — different output file name (post- prefix)
```
Take an **after screenshot** showing the change applied.

### Step 4 — Verification
Run Track B PowerShell verification from the phase file:
```powershell
# Save output to verification/command-outputs/
<verification-command> | Out-File verification\command-outputs\<name>.txt
# Or copy-paste terminal output into the file manually
```

### Step 5 — Break/Fix Log (if anything went wrong)
Add an entry to `troubleshooting/break-fix-log.md` using the template below.

### Step 6 — Phase Completion Note
Add a short completion block to the project README.md:
```markdown
### ✅ Phase N Complete — YYYY-MM-DD
- What I configured: [1-3 bullet points]
- Key screenshot: [filename]
- Verification: [command + result in one line]
- Problem/fix: [if any — one line]
```

---

## GUI Screenshot Guide — What to Capture Per Tool

### Active Directory Users and Computers (ADUC / dsa.msc)
```
□ OU tree expanded — shows full hierarchy
□ Each OU with its contents visible
□ Tiered admin accounts in correct OUs
□ Group membership (right-click → Properties → Members tab)
□ Delegation of Control wizard screenshots
```

### Active Directory Administrative Center (ADAC)
```
□ Password Settings Container showing PSO
□ PSO properties (precedence, length, lockout settings)
□ Fine-grained password policy applied to group
```

### Group Policy Management Console (GPMC / gpmc.msc)
```
□ GPO list showing all custom GPOs created
□ GPO linked to correct OU (shown in left pane)
□ Settings tab showing configured policy values
□ Scope tab showing OU link
□ gpresult /H output opened in browser
```

### DNS Manager (dnsmgmt.msc)
```
□ Forward lookup zone showing all records
□ Reverse lookup zone
□ Forwarders list
□ Zone properties (replication scope, dynamic update)
```

### DHCP Manager (dhcpmgmt.msc)
```
□ Scope with address pool configured
□ Reservations list
□ Scope options (003 Router, 006 DNS, 015 Domain Name)
□ Failover relationship properties
□ Active leases
```

### Event Viewer
```
□ Security log filtered to specific Event ID (4740, 4625, 4728, etc.)
□ Event detail expanded showing full properties
□ Custom view created and saved
□ Forwarded Events log showing events from member servers
```

### Hyper-V Manager
```
□ VM list showing all VMs with state
□ VM settings (vCPU, RAM, network adapter, VLAN)
□ Checkpoint settings (Production selected)
□ Virtual switch manager showing switch names and types
```

### Windows Admin Center
```
□ Dashboard showing all managed servers
□ Server detail page (CPU, memory, uptime)
□ VM management showing Hyper-V VMs
□ PowerShell session opened from WAC
□ Event viewer in WAC
```

### Entra Connect / Azure AD Connect
```
□ Installation wizard — each configuration screen
□ Sync scope (OUs selected)
□ Synchronization Service Manager — successful sync shown
□ Entra admin center — users synced with cloud icon
□ Password writeback test — reset in M365, confirmed in AD
```

### Server Manager
```
□ Roles and features installed
□ Post-deployment notification (e.g. DC promotion complete)
□ All Servers view showing WIN-DC02, WIN-FS01, WIN-WS01
```

### Certificate Manager (certsrv.msc / certmgr.msc)
Capture when PKI, ADCS, or certificate-based auth is in scope (P01 IIS cert, P08 WAC SSL).
```
□ Certification Authority console showing CA name and issued certificates
□ Certificate Templates enabled on the CA
□ Issued certificate showing subject, validity, and template used
□ Personal certificate store on the server (certlm.msc) showing the bound certificate
```

### IIS Manager (inetmgr)
Capture only when IIS is relevant (P01 RDS/IIS risk documentation, P08 WAC gateway).
```
□ Sites list showing bound sites, ports, and state
□ Bindings dialog showing HTTP/HTTPS and certificate selected
□ Application pool list showing identity accounts and state
□ Authentication settings (Windows Auth enabled/disabled as required)
```

### Local Users and Groups (lusrmgr.msc)
Capture for P01 baseline hardening and local account audit.
```
□ Users list showing built-in accounts (Administrator, Guest, DefaultAccount)
□ Groups list — confirm no unexpected members in Administrators
□ Administrator account Properties → account is disabled (if applicable)
□ Guest account Properties → account is disabled
```

---

## Break/Fix Log Template

File: `troubleshooting/break-fix-log.md`

```markdown
## Break/Fix — [Short Title] — YYYY-MM-DD

**Phase:** P0X Phase Y
**What I did:** [The action that caused the problem]

**Symptom:**
[What I observed — error message, failed command output, unexpected behavior]

**Screenshot:** [filename if captured]

**Diagnosis:**
[Commands I ran to find the root cause]
[Output that revealed the issue]

**Root cause:**
[One sentence — what was actually wrong]

**Fix applied:**
[Commands or GUI steps that resolved it]

**Verification:**
[How I confirmed it was fixed]

**Lesson:**
[One sentence — what to remember for next time]
```

---

## Completed Project README Template

When a project is fully complete, add this section to the project README.md
directly below the Phases table:

```markdown
---

## ✅ Project Complete — YYYY-MM-DD

### What I Built
- [Bullet 1 — specific thing configured]
- [Bullet 2]
- [Bullet 3]
- [etc.]

### Key Evidence

| What | Screenshot / Output |
|------|-------------------|
| [e.g. OU structure] | ![OU structure](verification/screenshots/p02-ph1-ou-structure-aduc.png) |
| [e.g. Replication healthy] | [repadmin output](verification/command-outputs/p02-ph7-repadmin-replsummary.txt) |
| [e.g. GPO applied] | ![GPO applied](verification/screenshots/p05-ph3-gpresult-workstation.png) |

### Verification Summary
```
[Key command output pasted inline — 5-10 lines max]
[The most important proof — e.g. repadmin /replsummary showing 0 failures]
```

### Problems Encountered and Fixed
| Problem | Root Cause | Fix |
|---------|-----------|-----|
| [e.g. adm-leonel could log into WS] | GPO not linked to Workstations OU | Linked GPO → confirmed blocked |

### STAR Result
**Result:** [2-3 sentences describing the outcome — what works now that didn't before]

### Links
- [Phase detail](phases/) | [Screenshots](verification/screenshots/) | [Configs](configs/) | [Break/Fix log](troubleshooting/break-fix-log.md)
```

---

## Main Family README Update

When a project is complete, update the project index table in the main
`windows-server-business-admin-labs/README.md`:

```markdown
| [02](projects/project-02-ad-architecture/) | Active Directory Architecture | ✅ Complete — 2026-07-15 |
```

Then add a completed project summary section under the index table:

```markdown
## ✅ Project 02 — Active Directory Architecture

**Built:** 2026-07-15 | [Full detail →](projects/project-02-ad-architecture/)

| OU Structure | Tiered Accounts | DC Replication |
|---|---|---|
| ![OU](verification/screenshots/p02-ph1-ou-structure-aduc.png) | ![Accounts](verification/screenshots/p02-ph3-tiered-accounts-aduc.png) | ![Repadmin](verification/screenshots/p02-ph7-repadmin-replsummary.png) |

Built full AD OU hierarchy, tiered admin model (Tier 0/1/2), AGDLP group structure,
delegated password reset, and replica DC with healthy replication.
[→ Screenshots](projects/project-02-ad-architecture/verification/screenshots/) |
[→ Verification](projects/project-02-ad-architecture/verification/command-outputs/) |
[→ Break/Fix log](projects/project-02-ad-architecture/troubleshooting/break-fix-log.md)
```

---

## Trigger Phrases

Load this skill when Leonel says:
- "document this phase" / "phase X is done"
- "project complete" / "time to document"
- "what screenshots do I need"
- "update the README"
- "save the evidence"
- "how do I prove this"
- After completing any Windows Server phase or project
