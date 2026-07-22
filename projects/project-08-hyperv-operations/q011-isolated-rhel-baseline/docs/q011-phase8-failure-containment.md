# Q011 Phase 8 — Failure Containment

**Status:** historical prepared containment; no guest repair invoked  
**Prepared and evaluated:** 2026-07-21  
**Paired validation:**
[Phase 8 post-patch validation](q011-phase8-postpatch-validation-and-rebuild-evidence.md)

## Safety Model

Phase 8 is read-only inside the guest. A failed comparison is evidence, not
authority to repair it. Other than the exact read-only
`dnf -q history info 2` lookup, do not run DNF; import or delete a key; clean
cache; edit a repository; restart or reconfigure a service; change
firewall/SELinux, an account, or NetworkManager; create a
checkpoint/export/backup; attach media; or alter another system.

## Actual Outcome

The first stable-control comparison stopped because the planned SSH
configuration hash was collected without `sudo`, producing an empty value.
The approved read-only retry returned a hash that differed from the Phase 5
text record but matched the original Phase 5 screenshot exactly. A separately
approved local-only correction fixed that transcription and recomputed the
already collected Booleans. This was evidence recovery, not a guest repair:
no file, package, key, service, policy, account, or network setting changed.

All guest gates then passed, normal shutdown completed, and
`Phase8EndStatePass=True` restored final isolation. Shutdown-timeout,
attachment-failure, and configuration-repair branches were not invoked.

## Before Q011 Starts

If the host preflight fails, do not attach or start Q011. Record only the
failed gate. No rollback is required because the VM was not changed.

## Attachment, DHCP, Or SSH Failure

If Q011 cannot verify Access VLAN 70, automatic reserved DHCP
`192.168.70.140`, DHCP server/gateway `192.168.70.1`, or Windows 11 SSH:

1. do not run manual `nmcli` activation;
2. do not inspect or change OPNsense in this window;
3. shut the guest down normally if it is reachable at VMConnect; and
4. after it is Off, disconnect only Q011 and restore Untagged VLAN 0.

If the guest cannot shut down normally, contain its adapter immediately and
leave the power state unchanged. Forced Off requires separate approval.

## Guest Validation Failure

Record only the failed Boolean, safe package/unit name, expected/observed
hash, or control value. Do not weaken policy or try a second command intended
to repair the result. Shut down normally, restore isolation, and prepare a
separately approved diagnosis.

Expected differences from Phase 5 are package/kernel versions, registration,
repository state, exact RPM trust, and DHCP persistence. Do not classify
those intended changes as regressions. Any unexpected configuration-hash,
effective SSH policy, firewall policy, SELinux, root/wheel, LVM, service, or
health difference is a controlled stop.

## Shutdown Timeout Network Containment

If normal shutdown does not reach Off within three minutes, run only this
elevated host-side containment block:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'

    Disconnect-VMNetworkAdapter -VMName $VmName
    Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

    $Vm = Get-VM -Name $VmName
    $Adapter = Get-VMNetworkAdapter -VMName $VmName
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Phase8NetworkContainmentPass = (
        [string]::IsNullOrWhiteSpace($Adapter.SwitchName) -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0
    )

    [pscustomobject]@{
        VmName                        = $Vm.Name
        State                         = $Vm.State
        Disconnected                  = [string]::IsNullOrWhiteSpace(
            $Adapter.SwitchName
        )
        OperationMode                 = $Vlan.OperationMode
        AccessVlanId                  = $Vlan.AccessVlanId
        Phase8NetworkContainmentPass  = $Phase8NetworkContainmentPass
    } | Format-List

    if (-not $Phase8NetworkContainmentPass) {
        throw 'Q011 Phase 8 network containment failed.'
    }
}
```

`Phase8NetworkContainmentPass=True` proves only network containment. It does
not prove the VM is Off or that Phase 8 passed. Do not run the Off-state final
gate until Q011 is Off through a normal or separately approved action.

## Final Isolation Failure

If Q011 is Off but the final adapter state does not verify, retry only the
exact Q011 disconnection and Untagged setting once, then rerun the read-only
final gate. Do not change `vSwitch-LAN`, another adapter, or another VM. If the
DVD, checkpoint, automatic-checkpoint, or automatic-start state differs,
record the failure and stop; those objects are outside Phase 8 repair scope.

## Evidence To Retain

Retain only the failed gate, safe expected/observed control, VM power state,
adapter containment state, and whether normal shutdown completed. Do not
retain a password prompt, Red Hat consumer/organization identity, token,
authenticated URL, full unrelated inventory, or secret-bearing output.
