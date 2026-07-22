# Rollback Plan — Q011 Phase 6 Network And Registration

**Written:** 2026-07-20  
**Paired change:** [Phase 6 controlled network and registration](q011-phase6-network-registration-change-window.md)

## Pre-change State Snapshot

| Item | Value before change | Evidence |
|---|---|---|
| VM state | Off | `q011-phase5-07-offline-end-state.png` |
| Adapter | One, disconnected, Untagged, VLAN 0 | Phase 5 final evidence |
| DVD | Empty | Phase 5 final evidence |
| Checkpoints | Zero; automatic checkpoints disabled | Phase 5 final evidence |
| Registration | No consumer certificate; unregistered | Phase 5 sanitized results |
| Packages | No Phase 6 transaction permitted | Phase 5 package baseline |

## Rollback Triggers

- the lease is outside `192.168.70.100-192.168.70.200`;
- DHCP server or gateway is not `192.168.70.1`;
- SSH validation fails;
- registration fails, is ambiguous, or unexpectedly selects an organization;
- BaseOS or AppStream is absent after one refresh;
- secret material appears or would need to be retained;
- any package, service, firewall, profile, switch, DHCP, or unrelated object
  would need modification; or
- the final Off/disconnected verification fails.

## Rollback Steps

This rollback was not invoked after the successful Phase 6 result. The
accepted Dnsmasq reservation, `connection.autoconnect=yes`, registration, and
enabled repositories are intentional retained state. The final adapter
disconnection and VLAN-zero restoration are normal containment, not reversal
of those accepted outcomes.

### If A New Registration Identity Was Created

From the Q011 console or the still-open SSH session, run only:

```bash
sudo subscription-manager identity >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  sudo subscription-manager unregister
fi

sudo subscription-manager identity >/dev/null 2>&1
printf 'identity_after_rollback_exit=%s\n' "$?"
```

Require a nonzero final identity exit. Do not print or capture the consumer
UUID or organization fields. Do not use `clean`, delete certificates manually,
or change RHSM configuration without a separate reviewed approval.

### Restore The Hyper-V Network Boundary

Shut down Q011 normally if it is running:

```bash
sudo systemctl poweroff
```

After Hyper-V reports `Off`, run on `WIN-PRQD8TJG04M`:

```powershell
$VmName = 'Q011-RHEL102-BASELINE'

Disconnect-VMNetworkAdapter -VMName $VmName
Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

$Vm = Get-VM -Name $VmName
$Adapter = Get-VMNetworkAdapter -VMName $VmName
$Vlan = Get-VMNetworkAdapterVlan -VMName $VmName

[pscustomobject]@{
    VmName          = $Vm.Name
    State           = $Vm.State
    SwitchName      = $Adapter.SwitchName
    OperationMode   = $Vlan.OperationMode
    AccessVlanId    = $Vlan.AccessVlanId
    RollbackPass    = (
        $Vm.State -eq 'Off' -and
        [string]::IsNullOrWhiteSpace($Adapter.SwitchName) -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0
    )
} | Format-List
```

Require `RollbackPass=True`.

## Restore-From-Backup Path

| Backup | Restore procedure | Estimated time |
|---|---|---|
| Phase 5 state evidence | Reapply the exact disconnected/VLAN-zero rollback; compare service and configuration hashes at the next approved boot | 10 minutes |
| Registration record | Run the Red Hat-supported `subscription-manager unregister` command | 5 minutes |

No Hyper-V checkpoint or VHDX replacement is authorized or required.

The configuration evidence is not a restorable backup. If a later patch
window damages the guest, its recovery plan must use a previously installed
kernel or a separately approved rebuild from the verified ISO rather than
claiming that Phase 5 evidence can restore a disk.

## Post-Rollback Validation

- registration identity returns nonzero if registration had been created;
- VM is Off;
- the only adapter is disconnected, Untagged, and VLAN 0;
- DVD is empty;
- checkpoint count is zero; and
- no package transaction was run.

## Notes

- **Point of no return:** none.
- **Who can execute:** Leonel using VMConnect and elevated Windows PowerShell.
- If unregister fails, leave the VM Off and disconnected and record a review
  item. Do not manually delete RHSM identity files.
