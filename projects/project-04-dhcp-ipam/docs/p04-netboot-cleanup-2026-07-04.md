# Project 04 Netboot DHCP Option Cleanup

**Date:** 2026-07-04
**System:** `WIN-PRQD8TJG04M`
**Scope:** `192.168.20.0/24`
**Change level:** Windows DHCP scope option cleanup only

Leonel confirmed that the previous `netboot.xyz` service is retired and should
not be advertised by DHCP anymore.

## Removed Options

Before cleanup, the VLAN 20 Windows DHCP scope advertised:

| Option | Name | Value |
|--------|------|-------|
| 66 | Boot Server Host Name | `192.168.20.15` |
| 67 | Bootfile Name | `netboot.xyz.efi` |

Codex removed only those two options:

```powershell
Remove-DhcpServerv4OptionValue -ScopeId 192.168.20.0 -OptionId 66,67
```

## Verified Remaining Options

After cleanup, the scope has these options:

| Option | Name | Value |
|--------|------|-------|
| 3 | Router | `192.168.20.1` |
| 6 | DNS Servers | `192.168.20.11`, `192.168.20.12` |
| 15 | DNS Domain Name | `Chongong.local` |
| 51 | Lease | `2073600` |

The DHCP scope remains active. Route10 remains the VLAN 20 gateway and IPAM
source of truth. Windows remains the VLAN 20 DHCP service authority.

## Rollback

If a new netboot service is intentionally rebuilt, re-add options 66 and 67 with
the approved server address and boot file. Do not re-add the old
`192.168.20.15` value unless that host exists again and is verified.
