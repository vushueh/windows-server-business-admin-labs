# Project 08 — Hyper-V Operations

**Status:** ⬜ Planned (requires Projects 06 and 07 complete)
**Skill:** `/winserver-p08` — written when this project starts

## Objective

Audit and properly configure the Hyper-V infrastructure on WIN-PRQD8TJG04M.
Design virtual switch architecture with VLAN awareness, enforce checkpoint policy,
migrate the RDS farm off the DC onto dedicated VMs, and establish a VM backup strategy.

**Why eighth:** Projects 06 and 07 create new VMs (WIN-FS01, WIN-WS01). By Project 08,
the 13 existing VMs need to be properly inventoried and organized before more are added.
The RDS migration off the DC is the highest-risk remediation item from P01 — it requires
proper Hyper-V virtual switch design to execute safely.

## Portfolio Summary

**Situation:** Hyper-V hosts 13 undocumented VMs with no inventory, no formal virtual switch
design, automatic checkpoints running on production VMs, and the RDS farm on the DC — the
highest-risk security finding from P01.

**Task:** Inventory and organize all VMs, design proper virtual switch architecture, enforce
checkpoint policy, migrate the RDS farm off the DC onto dedicated VMs, and establish a tested
VM backup process.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_

## Environment Context

- Hyper-V host: WIN-PRQD8TJG04M (also the DC — this is the risk)
- Known VMs from AD: RADIUS01, GITEA (domain-joined); 11 others unknown
- RDS farm currently on DC: Connection Broker, Gateway, Licensing, Session Host, Web Access
- Target: migrate RDS to WIN-RDS01 + WIN-RDWEB01 (optional)

## Virtual Switch Target Design

| Switch | Type | Purpose |
|--------|------|---------|
| vSwitch-External | External | Bridges to physical NIC — internet/LAN access for VMs |
| vSwitch-Internal | Internal | VM-to-VM + host communication — isolated lab segment |

## RDS Migration Target

| Component | Current location | Target VM |
|-----------|-----------------|-----------|
| RD Session Host | WIN-PRQD8TJG04M (DC) | WIN-RDS01 |
| RD Connection Broker | WIN-PRQD8TJG04M (DC) | WIN-RDWEB01 (optional) |
| RD Gateway | WIN-PRQD8TJG04M (DC) | WIN-RDWEB01 (optional) |
| RD Web Access | WIN-PRQD8TJG04M (DC) | WIN-RDWEB01 (optional) |
| RD Licensing | WIN-PRQD8TJG04M (DC) | WIN-RDS01 or WIN-RDWEB01 |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Full VM Inventory | Document all 13 VMs: name, state, vCPU, RAM, disk, network, purpose |
| 2 | Virtual Switch Audit | Document current switch config, identify any broken VLAN assignments |
| 3 | Virtual Switch Redesign | Create vSwitch-External and vSwitch-Internal per naming-standards.md |
| 4 | Checkpoint Policy | Set ProductionCheckpoint on all production VMs, disable AutomaticCheckpoints |
| 5 | Create WIN-RDS01 VM | New Hyper-V VM for RD Session Host role |
| 6 | RDS Migration — Session Host | Move RD Session Host to WIN-RDS01, verify sessions work |
| 7 | Create WIN-RDWEB01 VM | New Hyper-V VM for Broker, Gateway, Web Access, Licensing |
| 8 | RDS Migration — Broker/GW/Web | Move remaining RDS roles off DC, verify full RDS farm on VMs |
| 9 | Remove RDS from DC | Drain sessions, back up system state, then uninstall RDS roles during maintenance |
| 10 | VM Backup Strategy | Configure Windows Server Backup for all VMs; test restore one VM |
| 11 | Document + Push | VM inventory sheet, switch design diagram, STAR summary |

## Phase Detail

### Phase 1 — VM Inventory
```powershell
Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned, Uptime |
  Format-Table -AutoSize

# Full detail per VM
Get-VM | ForEach-Object {
  [PSCustomObject]@{
    Name        = $_.Name
    State       = $_.State
    vCPU        = $_.ProcessorCount
    RAM_GB      = [math]::Round($_.MemoryAssigned/1GB, 1)
    Disks_GB    = ($_ | Get-VMHardDiskDrive | Get-VHD | Measure-Object -Property Size -Sum).Sum / 1GB
    Network     = ($_ | Get-VMNetworkAdapter).SwitchName -join ","
  }
} | Format-Table -AutoSize
```

### Phase 4 — Checkpoint Policy
```powershell
# Enforce Production checkpoints (VSS-consistent, no saved state)
Get-VM | Set-VM -CheckpointType Production -AutomaticCheckpointsEnabled $false
```

### Phase 9 — Remove RDS from DC
```powershell
# Do not run while users are in active RDS sessions.
# Preconditions:
#   1. WIN-RDS01/WIN-RDWEB01 verified serving the farm
#   2. No active sessions remain on WIN-PRQD8TJG04M
#   3. DC system state backup completed
#   4. Maintenance window approved because rebooting the DC affects AD/DNS/DHCP/NPS

$RdsFeatures = @(
  "Remote-Desktop-Services",
  "RDS-RD-Server",
  "RDS-Connection-Broker",
  "RDS-Gateway",
  "RDS-Licensing",
  "RDS-Web-Access"
)

Remove-WindowsFeature -Name $RdsFeatures -ComputerName WIN-PRQD8TJG04M -Restart:$false
# Reboot manually during the maintenance window after reviewing removal output.
```

## Verification Commands

```powershell
# Confirm RDS no longer on DC post-removal
Get-WindowsFeature Remote-Desktop-Services -ComputerName WIN-PRQD8TJG04M

# Confirm RDS farm healthy on new VMs
Get-RDServer -ConnectionBroker WIN-RDWEB01.Chongong.local

# Confirm switch assignments
Get-VMNetworkAdapter -VMName * | Select-Object VMName, SwitchName, IPAddresses

# Confirm checkpoint type
Get-VM | Select-Object Name, CheckpointType, AutomaticCheckpointsEnabled
```
