# Phase 5 -- TCP/UDP listener inventory and firewall profile check (read-only)

Get-NetTCPConnection -State Listen |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort | Format-Table -AutoSize

Get-NetUDPEndpoint |
    Where-Object {$_.LocalPort -in @(53, 88, 389, 464, 1812, 1813)} |
    Select-Object LocalAddress, LocalPort,
        @{N="ProcessName";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
    Sort-Object LocalPort | Format-Table -AutoSize

Write-Host "---DefaultInboundAction---"
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
