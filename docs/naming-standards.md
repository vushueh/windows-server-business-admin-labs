# Naming Standards

## Servers

| Pattern | Example | Notes |
|---------|---------|-------|
| WIN-[ROLE][NN] | WIN-DC01 | Windows servers |
| WIN-FS01 | File server 01 | |
| WIN-WS01 | Workstation 01 | Test workstations |

## AD Accounts

| Type | Pattern | Example |
|------|---------|--------|
| Standard user | firstname | `leonel` |
| Tier 0 admin | `adm-firstname` | `adm-leonel` |
| Tier 1 server admin | `srv-firstname` | `srv-leonel` |
| Tier 2 workstation admin | `ws-firstname` | `ws-leonel` |
| Service account | `svc-purpose` | `svc-backup`, `svc-sync` |

## AD Groups

| Type | Prefix | Example |
|------|--------|--------|
| Global group | `GG-` | `GG-Finance-Users` |
| Domain Local group | `DL-` | `DL-Finance-Share-RW` |
| Network device auth | `GG-Net` | `GG-NetAdmins`, `GG-Net-ReadOnly` |

## GPO Names

| Pattern | Example |
|---------|--------|
| `[Scope]-[Purpose]` | `Domain-PasswordPolicy` |
| | `Computers-FirewallBaseline` |
| | `Workstations-LocalAdminRestriction` |
| | `Servers-AuditPolicy` |

## Hyper-V Virtual Switches

| Name | Type | Purpose |
|------|------|---------|
| `vSwitch-External` | External | Internet/LAN access |
| `vSwitch-Internal` | Internal | VM-to-VM + host |

## File Shares

| Pattern | Example |
|---------|--------|
| `\\WIN-FS01\[Department]` | `\\WIN-FS01\Finance` |
| `\\WIN-FS01\IT` | IT department share |
| `\\WIN-FS01\HR` | HR department share |
| `\\WIN-FS01\Management` | Management department share |
| `\\WIN-FS01\Sales` | Sales department share |
