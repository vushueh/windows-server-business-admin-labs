# Project 11 — Backup, Restore, and Disaster Recovery

**Status:** ⬜ Full P11 planned at Q037; early Q003 proof selected separately and not started
**Skill:** `/winserver-p11` — written when this project starts

## Master Queue Placement

The complete Project 11 remains planned at Q037. Two smaller recovery proofs
are deliberately scheduled earlier so later Windows changes have tested
rollback evidence:

| Queue | Recovery proof | Status |
|---|---|---|
| Q003 | [AD Recycle Bin test-object restore](q003-ad-recycle-bin-test-object-restore/) | ▶ Selected — not started |
| Q004 | Test-GPO backup and restore | ⏳ Waiting for Q003 |
| Q037 | Full Project 11 backup and disaster recovery | ⬜ Planned |

Completing Q003 will satisfy one early restore proof; it will not mark this
entire project complete or bypass Q037's master-queue dependencies. The Q003
plan, approval, evidence, and closeout remain inside its linked folder so the
proof can be reused when Q037 begins.

## Objective

Implement a tested backup strategy for all critical Windows Server components — system state,
file server data, AD objects, and Hyper-V VMs. Execute real restore tests, not just backup jobs.
Write DR runbooks that prove recovery is possible, not just planned.

**Why eleventh:** Backup without a tested restore is not a backup. By P11, all infrastructure
is running and the risk of loss is real. This project proves the lab can survive failures
before the M365 and cross-family integrations in P12–P13 make recovery even more complex.

## Portfolio Summary

**Situation:** No documented backup strategy exists. System state is not backed up. File server
data (from P06) has shadow copies but no off-box backup. No DR runbook exists. A DC failure
or ransomware event would cause extended outage with uncertain recovery.

**Task:** Implement daily system state backups on both DCs, file server backup, and VM export.
Execute all five restore tests to prove recovery works. Write DR runbooks with real time estimates.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_

## Backup Targets

| What | Tool | Frequency | Location |
|------|------|-----------|----------|
| DC system state (WIN-PRQD8TJG04M) | Windows Server Backup | Daily | Local + external |
| DC system state (WIN-DC02) | Windows Server Backup | Daily | Local |
| File server data (WIN-FS01) | Windows Server Backup | Daily | External drive or network share |
| AD object-level (recycle bin) | AD Recycle Bin | Continuous (enabled in P02) | AD database |
| Hyper-V VMs | Windows Server Backup + export | Weekly | External storage |
| GPOs | Backup-GPO PowerShell | Before every GPO change | C:\GPO-Backups\ |

## Restore Tests (All Must Be Executed)

| Test | What It Proves |
|------|---------------|
| Restore disposable deleted AD user | AD Recycle Bin works |
| Restore single file from shadow copy | WIN-FS01 VSS works |
| Restore disposable test GPO from backup | GPO rollback runbook works |
| Restore DC system state (bare metal) | Full DC recovery possible |
| Restore Hyper-V VM from export | VM recovery possible |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Verify AD Recycle Bin | Confirm enabled (should be from P02); test delete and restore |
| 2 | Install Windows Server Backup | Install on WIN-PRQD8TJG04M, WIN-DC02, WIN-FS01 |
| 3 | Configure System State Backup | Daily system state backup on both DCs |
| 4 | Configure File Server Backup | Daily data volume backup on WIN-FS01 to network share |
| 5 | Configure VM Export | Weekly Hyper-V VM export for all critical VMs |
| 6 | Test 1: AD Recycle Bin | Create disposable restore-test user → delete → restore via ADAC → confirm intact |
| 7 | Test 2: File Restore | Delete a file from WIN-FS01 → restore from shadow copy |
| 8 | Test 3: GPO Restore | Delete disposable test GPO → restore from C:\GPO-Backups\ → verify links |
| 9 | Test 4: DC System State | Lab exercise: restore system state on WIN-DC02 (not PDC) |
| 10 | Test 5: VM Restore | Restore WIN-WS01 export as isolated test copy; do not delete the working VM |
| 11 | DR Runbook | Write recovery procedures for each scenario, including time estimates |
| 12 | Document + Push | Backup config, test results, DR runbook committed |

## Phase Detail

### Phase 3 — System State Backup
```powershell
# Install Windows Server Backup feature
Install-WindowsFeature Windows-Server-Backup

# Create daily system state backup job
$Policy = New-WBPolicy
$Target = New-WBBackupTarget -VolumePath D:
Add-WBBackupTarget -Policy $Policy -Target $Target
Add-WBSystemState -Policy $Policy
Set-WBSchedule -Policy $Policy -Schedule 02:00   # 2am daily
Set-WBPolicy -Policy $Policy
```

### Phase 1 — AD Recycle Bin Verify
```powershell
# Confirm enabled
Get-ADOptionalFeature -Filter 'Name -like "Recycle*"' | Select-Object Name, EnabledScopes

# Test only with a disposable account created for this restore drill.
New-ADUser -Name "restore-test-p11" -SamAccountName "restore-test-p11" `
  -Path "OU=Quarantine,DC=Chongong,DC=local" -Enabled $false

Remove-ADUser -Identity "restore-test-p11" -Confirm:$false

# Restore from recycle bin
Get-ADObject -Filter {SamAccountName -eq 'restore-test-p11'} -IncludeDeletedObjects |
  Restore-ADObject
```

### Phase 8 — GPO Restore Test
```powershell
# Backup all GPOs before test
$BackupPath = "C:\GPO-Backups\$(Get-Date -Format yyyyMMdd)"
New-Item -ItemType Directory -Path $BackupPath
Backup-Gpo -All -Path $BackupPath

# Simulate disaster with a disposable GPO, not a production baseline GPO
New-GPO -Name "P11-Restore-Test"
Backup-GPO -Name "P11-Restore-Test" -Path $BackupPath
Remove-GPO -Name "P11-Restore-Test"

# Restore
Restore-GPO -Name "P11-Restore-Test" -Path $BackupPath

# Optional: link only to a test OU if needed, then remove the test GPO after verification
```

### Phase 11 — DR Runbook Template
```
Scenario: DC failure (WIN-PRQD8TJG04M goes offline)
Estimated recovery time: <document after test>

Step 1: WIN-DC02 continues serving AD DS/DNS for normal queries if it is healthy
Step 2: Verify WIN-DC02 responds to AD queries: nltest /dsgetdc:Chongong.local
Step 3: Seize FSMO roles only if WIN-PRQD8TJG04M is permanently lost and recovery is approved
Step 4: Restore WIN-PRQD8TJG04M from system state backup when hardware is available
Step 5: Re-join as replica DC and re-sync replication
Step 6: Transfer FSMO roles back to WIN-PRQD8TJG04M

Critical: NEVER restore a DC from backup if the DC has been offline longer than the tombstone lifetime.
Do not assume 60 days. Modern forests are commonly 180 days, but verify the live value:
Get-ADObject "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=Chongong,DC=local" `
  -Properties tombstoneLifetime | Select-Object tombstoneLifetime
```

## Verification Commands

```powershell
# Confirm backup job ran
Get-WBSummary

# Confirm last successful system state backup
Get-WBJob -Previous 5

# Confirm shadow copy on WIN-FS01
Get-WmiObject Win32_ShadowCopy -ComputerName WIN-FS01 |
  Select-Object InstallDate, VolumeName | Sort-Object InstallDate -Descending

# Confirm AD Recycle Bin scope
Get-ADOptionalFeature "Recycle Bin Feature" | Select-Object EnabledScopes
```
