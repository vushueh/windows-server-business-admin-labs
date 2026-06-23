# Project 06 — File Server, NTFS, and Access Governance

**Status:** ⬜ Planned (requires Projects 02 and 05 complete)
**Skill:** `/winserver-p06` — written when this project starts

## Objective

Build a dedicated file server (WIN-FS01) as a Hyper-V VM, migrate file serving off the DC,
create department shares with NTFS AGDLP permissions, enable file auditing, and establish
a repeatable access review process. Implement ransomware-resistant folder structure.

**Why sixth:** The DC currently runs the File Server role (a security risk — a compromised
share = a compromised DC). WIN-FS01 isolates this risk. AGDLP groups from P02 and GPOs
from P05 must exist before NTFS permission assignments make sense.

## Environment Context

- DC: WIN-PRQD8TJG04M (file server role currently on DC — to be offloaded)
- New file server: WIN-FS01 (Hyper-V VM — created in this project)
- Groups: GG-Finance-Users, GG-HR-Users, GG-IT-Users, GG-IT-Admins, GG-Management-Users, GG-Sales-Users (created in P02)
- Domain Local Groups: DL-Finance-Share-RW, DL-HR-Share-RW, DL-IT-Share-RW, DL-IT-Share-Full, DL-Management-Share-RW, DL-Sales-Share-RW (P02)

## Target Share Structure

```
\\WIN-FS01\
  ├── Finance\       → DL-Finance-Share-RW (Modify), DL-Finance-Share-RO (ReadOnly)
  ├── HR\            → DL-HR-Share-RW (Modify)
  ├── IT\            → DL-IT-Share-Full (Full Control)
  ├── Management\    → DL-Management-Share-RW (Modify)
  ├── Sales\         → DL-Sales-Share-RW (Modify)
  ├── Shared\        → Authenticated Users (Read) — company-wide read share
  └── Archives\      → Domain Admins only — retired/archived content
```

## Ransomware-Resistant Design

- Shadow Copies enabled on WIN-FS01 (2× daily snapshots, 30-day retention)
- Screened file extensions: block .exe, .bat, .ps1 uploads to shares
- File Server Resource Manager (FSRM) quotas per department share
- Access-Based Enumeration (ABE) enabled — users only see shares they can access

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Create WIN-FS01 VM | Hyper-V VM: 2 vCPU, 4GB RAM, 80GB OS + 200GB data disk |
| 2 | Domain Join WIN-FS01 | Join to Chongong.local, move to ManagedComputers\Servers OU |
| 3 | Install File Server Role | FS-FileServer, FSRM, DFS Namespaces |
| 4 | Create Department Shares | Finance, HR, IT, Management, Sales, Shared, Archives |
| 5 | Apply NTFS AGDLP Permissions | Remove inheritance, assign DL-* groups only — no direct user permissions |
| 6 | Configure Shadow Copies | Enable VSS on data volume, 2× daily schedule |
| 7 | Enable File Auditing | Object Access GPO linked to ManagedComputers\Servers — log all write/delete |
| 8 | FSRM Quotas and Screens | 10GB quota per dept, block executable extensions |
| 9 | Access-Based Enumeration | Enable ABE on all shares |
| 10 | Access Review Process | PowerShell report: who is in each DL-* group and what share does it grant |
| 11 | Migrate Files from DC | Move any existing shares from WIN-PRQD8TJG04M to WIN-FS01 |
| 12 | Document + Push | Share layout, AGDLP map, STAR summary |

## Phase Detail

### Phase 5 — NTFS AGDLP Assignment
```powershell
# Remove inherited permissions and assign DL-* groups
$Path = "D:\Shares\Finance"
$Acl = Get-Acl $Path
$Acl.SetAccessRuleProtection($true, $false)   # disable inheritance, remove inherited

# Add explicit admin and system control before adding access groups.
$Acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
  "BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))
$Acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
  "NT AUTHORITY\SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")))

# Add DL-Finance-Share-RW: Modify
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
  "CHONGONG\DL-Finance-Share-RW", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.AddAccessRule($Rule)
Set-Acl -Path $Path -AclObject $Acl
```

### Phase 10 — Access Review Report
```powershell
# Who can access Finance share?
Get-ADGroupMember "DL-Finance-Share-RW" | ForEach-Object {
  if ($_.objectClass -eq "group") { Get-ADGroupMember $_.SamAccountName }
  else { $_ }
} | Select-Object Name, SamAccountName | Sort-Object Name
```

## Verification Commands

```powershell
# Confirm share permissions
Get-SmbShareAccess -Name Finance

# Confirm NTFS (shows inherited vs explicit)
(Get-Acl "\\WIN-FS01\Finance").Access | Select-Object IdentityReference, FileSystemRights, IsInherited

# Confirm shadow copies
Get-WmiObject Win32_ShadowCopy -ComputerName WIN-FS01

# Confirm audit policy active
auditpol /get /subcategory:"File System"
```

## STAR Summary

**Situation:** File Server role runs on the DC — a compromised share grants DC-level access.
No department share structure, no AGDLP permissions, no file auditing, no shadow copies.
Access is undocumented with no review process.

**Task:** Stand up WIN-FS01 as a dedicated VM, move file serving off the DC, implement AGDLP
permissions, enable auditing and shadow copies, and create a repeatable access review process.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
