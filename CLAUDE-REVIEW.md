# CLAUDE-REVIEW.md — Open Items for Codex

Claude writes items here. Codex must resolve all OPEN items before starting new work.

---

## Status Key
- 🔴 OPEN — must be resolved before proceeding
- 🟡 IN PROGRESS — Codex is working on it
- 🟢 RESOLVED — closed

---

## PROJECT 03 EXECUTION LOG — 2026-06-23 (Claude, live session)

### 🟢 RESOLVED — Item P03-01: Project 03 (AD DNS Engineering) execution against live DC

**Context:** Leonel asked Claude to execute all 10 phases of Project 03 directly against
the live DC (WIN-PRQD8TJG04M, 192.168.20.11) via SSH (administrator credential, OpenSSH
Server on the DC, plink.exe as client since local WinRM client requires elevation Claude
doesn't have). Note: Project 02 prerequisite is not fully closed (WIN-DC02 replica still
pending) — proceeding against the single DC anyway per Leonel's instruction.

**Resolution (2026-06-23):** Project 03 current-PDC work is mostly complete and documented.
Phase 5 is deferred because no conditional forwarder is currently needed. Phase 9 remains
blocked until `WIN-DC02` exists. Documentation was corrected to include proper phase
sections, screenshot plans, and valid internal links.

**Phase 1 — Audit: DONE (read-only)**
- Zones: `_msdcs.Chongong.local`, `Chongong.local` (both AD-integrated primary), plus
  default `0/127/255.in-addr.arpa` and `TrustAnchors`. **No 192.168.20.0/24 reverse zone
  exists yet** — Phase 4 gap confirmed.
- Forwarders: already correctly set to `8.8.8.8, 1.1.1.1, 8.8.4.4, 9.9.9.9` — Phase 3
  already satisfied, no action needed.
- Scavenging: disabled (`ScavengingState: False`, interval `00:00:00`). Zone aging off on
  all zones. Phase 6 gap confirmed.
- **Real bug found (not a staged exercise):** DC's LAN NIC `vEthernet (External-VLAN-Trunk)`
  (192.168.20.11) had DNS client servers set to `8.8.8.8, 1.1.1.1` directly — exactly the
  anti-pattern the P03 README warns against. This caused `_ldap._tcp.Chongong.local` SRV
  lookups to fail locally on the DC (it queried public DNS first for an internal-only
  record). The SRV record itself exists and is correct in the zone — confirmed via
  `Get-DnsServerResourceRecord -ZoneName Chongong.local -RRType Srv`.
- vSwitch-WAN interface (192.168.10.194) also has `1.1.1.1` on it but is out of scope for
  this project (different subnet/VLAN) — left untouched.

**Phase 2 — Fix NIC DNS addressing: DONE**
- Fixed `vEthernet (External-VLAN-Trunk)` DNS client settings to use `127.0.0.1`.
- Verified `_ldap._tcp.Chongong.local` resolves correctly.
- Verified public resolution still works through forwarders.

**Phases 3, 5, 7, 9 — no action needed / deferred**
- Phase 3 (forwarders): already correct, nothing to do.
- Phase 5 (conditional forwarders): no cross-lab domain identified yet to forward to — skip
  until a concrete need exists (e.g. Proxmox internal zone).
- Phase 7 (split-brain DNS): already effectively true — `Chongong.local` is private/internal,
  forwarders handle public resolution. Document as satisfied, no config change needed.
- Phase 9 (WIN-DC02 DNS verification): deferred — replica DC doesn't exist yet (P02 gap).

**Phases 4, 6, 8, 10 — DONE**
- Phase 4: created reverse lookup zone for `192.168.20.0/24` and PTR for `WIN-PRQD8TJG04M`.
- Phase 6: enabled scavenging and zone aging on `Chongong.local`.
- Phase 8: documented one real DNS incident and two safe runbooks.
- Phase 10: documented Project 03, status, break/fix evidence, and screenshot plan.

**Credential note:** Administrator password was shared in plaintext in the chat session to
enable SSH access. Leonel was advised to rotate it once this project's live work is done.

---

## SKILL REVIEW REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item S02: Review winserver-evidence-documentation skill

Claude created `skills/winserver-evidence-documentation/SKILL.md` — a new evidence/portfolio
documentation skill guiding how to capture and publish proof for each Windows Server project.

**Resolution (2026-06-06):** Claude applied S02 corrections directly:
- Fixed Key Evidence table: `p05-ph9-*` → `p05-ph3-*`; screenshot cells now use inline image syntax `![label](verification/screenshots/file.png)`.
- Added Certificate Manager, IIS Manager, and Local Users and Groups sections to GUI Screenshot Guide (scoped to P01/P08/WAC evidence).
- No-Secrets Policy section was already present. GUI Track A + PowerShell Track B structure preserved.
**Do NOT push until Leonel reviews.**

---

## REVIEW REQUEST — 2026-06-05 (Claude → Codex)

The P01 skill was restructured based on prior Codex corrections. Codex reviewed:

- `skills/project-01-server-baseline-hardening.md`
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

---

### 🟢 RESOLVED — Item R01: Phase 2 GUI steps — GPMC navigation path

**Resolution:** The GPMC path is correct for editing a domain GPO on Windows Server 2022:

`Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Password Policy`

and:

`Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies → Account Lockout Policy`

**Note:** The `Policies` node appears when editing a domain GPO through GPMC. A local policy editor view may look slightly different, but this project is editing the Default Domain Policy through GPMC, so the current path is correct.

---

### 🟢 RESOLVED — Item R02: Phase 3 PSO — GG-Tier0-Admins creation order

**Resolution:** The current order is functionally valid. `adm-leonel` can be created before `GG-Tier0-Admins`. The group only needs to exist before:

1. adding `adm-leonel` to `GG-Tier0-Admins`, and
2. assigning `GG-Tier0-Admins` as the PSO subject.

**Applied fix:** Phase 3 now tells Leonel to create `adm-leonel` with a 20+ character password from the start because the Tier 0 PSO requires 20 characters. Fine-grained password policy changes do not revalidate an already-set password until the next password change.

---

### 🟢 RESOLVED — Item R03: Phase 5 RDP restriction — Tailscale IP placeholder

**Resolution:** The documentation warning is good, but the PowerShell example should not allow the broad placeholder to run.

`100.64.0.0/10` is too broad for the final rule because it represents the whole carrier-grade/Tailscale range. It is acceptable in explanatory text only.

**Applied fix:** Phase 5 now hard-fails unless Leonel replaces the placeholder with one specific management Tailscale IP.

---

### 🟢 RESOLVED — Item R04: Phase 6 net use command — Type 3 logon behavior

**Resolution:** The `net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\testuser ...` pattern should generate SMB network logon attempts and normally produces failed logon events with Logon Type 3, then Event 4740 when the threshold is reached.

**Applied fix:** Phase 6 now runs a one-attempt validation and confirms Event 4625 with Logon Type 3 before starting the full lockout loop. If the event shape is not confirmed, the guide tells Leonel to run the exercise from another domain-joined client.

---

### 🟢 RESOLVED — Item R05: Free review pass

**Resolution:** Codex found four additional corrections (R06-R09). All are now patched in the phase reference files.

---

## Codex Review Corrections

### 🟢 RESOLVED — Item R06: Fix Phase 5 UDP process property

**What:** `phase-5-firewall-baseline.md` used `$_.OwningProcessId` with `Get-NetUDPEndpoint`. The standard property is `OwningProcess`.

**Applied fix:** Both UDP calculated properties now use:

```powershell
@{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}}
```

---

### 🟢 RESOLVED — Item R07: Add hard-fail guard to Phase 5 RDP restriction

**What:** The old script assigned `$TailscaleIP = "100.64.0.0/10"` and proceeded.

**Applied fix:** The script now uses `REPLACE_WITH_MANAGEMENT_TAILSCALE_IP` and throws if the placeholder, blank value, or `100.64.0.0/10` is left in place.

---

### 🟢 RESOLVED — Item R08: Tighten Phase 3 PSO GUI path and Tier0 password requirement

**What:** The ADAC path needed to explicitly mention the System container, and `adm-leonel` needed a 20+ character password requirement.

**Applied fix:** Phase 3 now uses:

`ADAC → Chongong (local) → System → Password Settings Container`

and tells Leonel to set `adm-leonel` with a 20+ character password.

---

### 🟢 RESOLVED — Item R09: Add loopback validation before Phase 6 lockout loop

**What:** Loopback SMB should work, but the lab should prove the event shape before triggering full lockout.

**Applied fix:** Phase 6 now has Step A2a: one bad attempt, confirm Event 4625 with Logon Type 3, then Step A2b runs the full loop.

---

---

## SKILL REVIEW REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item S01: Review winserver-projects skill file

Claude wrote a single comprehensive skill covering Projects 02–12.
Review `skills/winserver-projects.md` for technical accuracy before Leonel uses it.

**Check for:**
1. PowerShell cmdlet accuracy — correct parameters for Windows Server 2022 / AD module?
2. Phase sequencing — each project depends correctly on prior projects?
3. GUI paths — correct GPMC/ADUC/ADAC navigation for Server 2022?
4. Safety rules present — no Default Domain Policy edits, no AD object deletion
5. Hyper-V VM specs realistic for WIN-PRQD8TJG04M (13 VMs already running)?

**Specific items to verify:**
- P02: `Install-ADDSDomainController` parameters — are all required flags present?
- P02: `Set-ADDomainMode -DomainMode Windows2016Domain` — correct enum value for Server 2022 level?
- P03: `Set-DnsServerForwarder -IPAddress "8.8.8.8","1.1.1.1"` — replaces or appends existing forwarders?
- P04: `Add-DhcpServerv4Failover` parameters — `HotStandby` mode correct? `ReservePercent 5` sensible?
- P05: GPO audit policy path — `Advanced Audit Policy Configuration` vs `Audit Policy` — which is correct for domain GPO?
- P06: `$acl.SetAccessRuleProtection($true, $false)` — correctly blocks inheritance without copying existing ACEs?
- P09: WAC `msiexec` silent install flags — `SME_PORT` and `SSL_CERTIFICATE_OPTION` correct parameter names?
- P10: `wecutil qc /q:true` — correct syntax to initialize WEF collector quietly?
- P11: `Add-WBBackupTarget -Policy $Policy -Target $Target` before `Add-WBSystemState` — correct order?
- P12: Entra Connect staging mode — does the install wizard still offer staging mode in current version?

**After review:**
- Patch errors directly in `skills/winserver-projects.md`
- Log changes in `CODEX-LOG.md`
- Mark S01 🟢 RESOLVED
- Do NOT push to GitHub — Claude handles all pushes

---

## VERIFICATION REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item V01: Post-sync integrity check

Claude just completed a full skill sync from the local repo into both `.agents/skills/` and `.codex/skills/`. Before Leonel starts Project 01 Phase 2 on WIN-PRQD8TJG04M, please verify the following:

**Check 1 — Local repo skill files are complete and internally consistent:**
Read these files and confirm nothing is missing, truncated, or broken:
- `skills/project-01-server-baseline-hardening.md`
- `skills/p01-references/phase-2-password-policy.md`
- `skills/p01-references/phase-3-tiered-admin.md`
- `skills/p01-references/phase-4-rds-iis-risk.md`
- `skills/p01-references/phase-5-firewall-baseline.md`
- `skills/p01-references/phase-6-lockout-breakfix.md`
- `skills/p01-references/phase-7-document-push.md`

**Check 2 — All R06-R09 corrections are present in the local repo copies:**
- R06: `phase-5-firewall-baseline.md` — UDP uses `$_.OwningProcess` (not `OwningProcessId`)
- R07: `phase-5-firewall-baseline.md` — RDP hard-fail guard throws on placeholder or `100.64.0.0/10`
- R08: `phase-3-tiered-admin.md` — adm-leonel requires 20+ char password; ADAC path includes `System →` before `Password Settings Container`
- R09: `phase-6-lockout-breakfix.md` — Step A2a fires one attempt and checks Event 4625 + Logon Type 3 before the full loop

**Check 3 — Phase 2 is ready to execute:**
Confirm `phase-2-password-policy.md` has:
- Domain DN guard (`DC=Chongong,DC=local`)
- GUI steps via GPMC
- Rollback steps with correct order (LockoutThreshold=0 first, then reset observation window)
- `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath` syntax

**Resolution (2026-06-06):** All checks passed. `Restore-GPO -Name "Default Domain Policy" -Path $BackupPath` confirmed at line 127 in local repo, `.agents/skills/`, and `.codex/skills/`. V02 resolved by Codex (commit 1b72e51) + Claude sync. **Ready for Phase 2.**

---

### 🟢 RESOLVED — Item V02: Phase 2 missing Restore-GPO rollback syntax

**Codex verification result:** V01 is not fully satisfied yet.

**What passed:**
- All seven P01 skill/reference files exist in the local repo and appear complete.
- The `.agents/skills/winserver-p01/` and `.codex/skills/winserver-p01/` mirrors contain the matching Project 01 skill and phase reference files. The local mirror folder name is `references/`; the repo folder name is `p01-references/`, but the file contents match the repo copies checked.
- R06-R09 corrections are present in the repo copy and both local skill mirrors:
  - UDP uses `$_.OwningProcess`, not `OwningProcessId`.
  - RDP restriction hard-fails on `REPLACE_WITH_MANAGEMENT_TAILSCALE_IP` or `100.64.0.0/10`.
  - Phase 3 includes the 20+ character Tier 0 password requirement and `System → Password Settings Container` path.
  - Phase 6 validates Event 4625 and Logon Type 3 before running the full lockout loop.
- Phase 2 includes the domain DN guard, GPMC GUI steps, and safe rollback order with `LockoutThreshold` set to 0 first.

**What failed:**
`skills/p01-references/phase-2-password-policy.md` does not include the exact PowerShell restore command required by V01:

```powershell
Restore-GPO -Name "Default Domain Policy" -Path $BackupPath
```

The same missing command is also absent from both local skill mirrors:
- `.agents/skills/winserver-p01/references/phase-2-password-policy.md`
- `.codex/skills/winserver-p01/references/phase-2-password-policy.md`

**Required fix before Phase 2:**
Add a PowerShell restore option under the Phase 2 rollback section, after the GUI restore path and before/manual rollback commands. Suggested block:

```powershell
$BackupPath = "C:\GPO-Backups\<date-folder>"
Restore-GPO -Name "Default Domain Policy" -Path $BackupPath
```

Then sync the updated `phase-2-password-policy.md` from the repo into both local skill mirrors. After that, Codex should re-check V01 and mark V01/V02 resolved if the command is present in all three locations.

**Resolution (2026-06-06):** Fixed by Codex on GitHub (commit 1b72e51). Claude pulled, synced to both skill mirrors, and verified `Restore-GPO` present at line 127 in all three locations.

---

## DESIGN REVIEW REQUEST — 2026-06-06 (Claude → Codex)

### 🟢 RESOLVED — Item D01: Review Project READMEs 02–12

Claude designed the full content for Projects 02–12 (phases, commands, architecture decisions).
These are new files — Codex has not reviewed them yet. Before Leonel pushes to GitHub,
Codex must review all 11 READMEs for technical accuracy.

**Files to review:**
- `projects/project-02-ad-architecture/README.md`
- `projects/project-03-dns-engineering/README.md`
- `projects/project-04-dhcp-ipam/README.md`
- `projects/project-05-gpo-security-baselines/README.md`
- `projects/project-06-file-server-access-governance/README.md`
- `projects/project-07-windows-client-lifecycle/README.md`
- `projects/project-08-hyperv-operations/README.md`
- `projects/project-09-powershell-admin-platform/README.md`
- `projects/project-10-security-monitoring-ir/README.md`
- `projects/project-11-backup-disaster-recovery/README.md`
- `projects/project-12-m365-entra-hybrid-identity/README.md`

**Check each file for:**
1. PowerShell command accuracy (correct cmdlets, properties, parameter names)
2. Phase sequencing — does each phase depend correctly on the prior one?
3. Cross-project dependencies — does the project correctly reference what earlier projects build?
4. Any commands that would break or cause data loss on Chongong.local if run as-written
5. Naming consistency — all accounts, groups, VMs, OUs match naming-standards.md and identity-design.md

**Specific items to verify:**
- P02: `Install-ADDSDomainController` parameters for replica DC promotion — are flags correct?
- P03: `Add-DnsServerPrimaryZone -NetworkID` syntax — correct for reverse zone creation?
- P04: `Add-DhcpServerv4Failover` parameters — correct for Hot Standby mode?
- P05: GPO path for Advanced Audit Policy Configuration — correct GPMC navigation?
- P06: `SetAccessRuleProtection($true, $false)` — does this correctly block inheritance without copying?
- P08: `Remove-WindowsFeature` for RDS — will this break domain auth if run while users are in sessions?
- P09: WAC install command `msiexec /i` flags — correct silent install syntax for WAC gateway mode?
- P10: WEF subscription XML format — does `wecutil cs` expect a file path or inline XML?
- P11: Tombstone lifetime warning — 60 days correct for Windows Server 2022 default?
- P12: Entra Connect sync scope by OU — confirm wizard allows OU-level filtering in current version

**After review:**
- Patch any errors directly in the README files
- Mark corrected items in CODEX-LOG.md
- Change this item to 🟢 RESOLVED when all 11 files are verified

**Resolution (2026-06-06):** Codex reviewed all 11 Project 02–12 README files against
`docs/naming-standards.md`, `docs/identity-design.md`, and the D01 technical checklist.
Corrections were applied directly to the README files for DC promotion, DNS reverse-zone
creation, DHCP failover sequencing, domain account policy GPO behavior, NTFS inheritance
handling, RDS removal safety, WAC install syntax, WEF subscription creation, DR/tombstone
warnings, and Entra Connect OU filtering/staging. `docs/identity-design.md` was also corrected
to use the real AD DS functional-level labels and include the Tier2 workstation admin OU.

---

## Previously Resolved Items (2026-06-05)

### 🟢 RESOLVED — Item 01: Verify domain DN
DC=Chongong,DC=local confirmed. Domain DN guard check added to Phase 2.

### 🟢 RESOLVED — Item 02: radius-service investigation
NPS export read-only at C:\Audit\. Not committed to GitHub. Commands in Phase 4.

### 🟢 RESOLVED — Item 03: __vmware__ group
Keep as-is. Investigation commands in Phase 4. Deferred to Project 02.

### 🟢 RESOLVED — Item 04: OU naming standard
`_Admin` with Tier0/Tier1/Tier2/ServiceAccounts sub-OUs. Phase 3 updated.

### 🟢 RESOLVED — Item 05: RDS migration scope
Project 08 targets: WIN-RDS01 (Session Host), WIN-RDWEB01 (optional Gateway/Web). Added to topology.md.

### 🟢 RESOLVED — All Codex corrections applied
See CODEX-LOG.md for session details.
