# CLAUDE-REVIEW.md — Open Items for Codex

Claude writes items here. Codex must resolve all OPEN items before starting new work.

---

## Status Key
- 🔴 OPEN — must be resolved before proceeding
- 🟡 IN PROGRESS — Codex is working on it
- 🟢 RESOLVED — closed

---

## Pre-Phase 2 Checklist (before running password policy changes)

### 🔴 OPEN — Item 01: Verify domain DN before running Phase 2 commands

**What:** Phase 2 uses `(Get-ADDomain).DistinguishedName` as the identity for
`Set-ADDefaultDomainPasswordPolicy`. This should resolve to `DC=Chongong,DC=local`.

**Codex action:** Confirm the expected DN string and verify the `Set-ADDefaultDomainPasswordPolicy`
command in `skills/project-01-server-baseline-hardening.md` Phase 2.3 is syntactically correct
for this domain.

**Expected value:** `DC=Chongong,DC=local`

---

### 🔴 OPEN — Item 02: Investigate radius-service account purpose

**What:** The audit found a `radius-service` account in AD. NPS is already installed.
NPS uses the machine account (WIN-PRQD8TJG04M$) for AD lookups — NOT a service account.
The purpose of `radius-service` is unknown: it could be a condition account used in NPS
Network Policies, or a legacy entry.

**Risk:** If `radius-service` is used in an active NPS policy, changing its password or
moving it without investigating will break RADIUS auth for any currently configured clients.

**Codex action:**
1. Review the NPS configuration on the server (NPS console → Policies → Connection Request Policies
   and Network Policies) to determine if `radius-service` appears in any policy condition
2. Document the finding in `docs/p01-audit-baseline.md`
3. If it IS referenced in an NPS policy, flag this as a dependency for Project 13

---

### 🔴 OPEN — Item 03: Investigate __vmware__ group

**What:** The audit found a Domain Local security group named `__vmware__` in AD.
This naming pattern (double underscore prefix) is atypical for a Windows AD group and
suggests it was created by a VMware product (possibly VMware vCenter, VMware Workstation
with Horizon, or a VMware-integrated SSO connector).

**Risk:** Deleting or modifying this group without understanding its purpose could break
a VMware product's AD integration.

**Codex action:**
1. Research what VMware products create a `__vmware__` group in Active Directory
2. Cross-reference with Hyper-V host (WIN-PRQD8TJG04M) — does it also run VMware Workstation?
3. Document the finding and recommend: keep as-is, or investigate further before Project 02

---

### 🔴 OPEN — Item 04: Review Phase 3 OU structure against family skill design

**What:** The family skill (`skills/windows-server-business-admin.md`) defines this target
OU structure:
```
chongong.local
  ├── _Admin (Tier0-DomainAdmins, Tier1-ServerAdmins, ServiceAccounts)
  ├── Computers (Servers, Workstations)
  ├── Users (IT, Finance, Operations)
  └── Groups (GlobalGroups: GG-*, DomainLocalGroups: DL-*)
```

But the P01 skill creates `OU=Admin Accounts` with `OU=Tier0` and `OU=Tier1` sub-OUs.
The existing domain already has flat OUs: Management, IT, HR, Sales, Finance, Groups.

**Codex action:**
1. Reconcile the P01 skill OU naming (`Admin Accounts`) with the family skill design (`_Admin`)
2. Decide: should the tiered admin OU be named `_Admin` (family standard) or `Admin Accounts`
   (P01 skill name)? Naming it `_Admin` sorts it to the top in ADUC alphabetically.
3. The existing department OUs (Management, IT, HR, Sales, Finance) will need restructuring
   in Project 02 (AD Architecture). Note this dependency.
4. Recommend which naming to use in the P01 skill and update the skill accordingly

---

### 🔴 OPEN — Item 05: Verify RDS farm scope before Phase 4 documentation

**What:** The audit confirmed RDS full farm installed (Connection Broker, Gateway, Licensing,
Session Host, Web Access) on WIN-PRQD8TJG04M. The RDS-Users AD group controls access.

**Codex action:**
1. In Phase 4, when Leonel runs the RDS audit commands, Codex should review the output
   and help document: what collections exist, who is in RDS-Users, is there an active
   RDS licensing server configured, is there a valid certificate on the gateway?
2. Prepare the Project 08 migration plan outline (which VMs to create: WIN-RDS01,
   what roles to migrate, in what order) so it is ready when Project 08 starts.

---

## How to Mark Items Resolved

```
### 🟢 RESOLVED — Item 01: [title]
**Resolution:** [what was found/decided/done]
**Date:** YYYY-MM-DD
```
