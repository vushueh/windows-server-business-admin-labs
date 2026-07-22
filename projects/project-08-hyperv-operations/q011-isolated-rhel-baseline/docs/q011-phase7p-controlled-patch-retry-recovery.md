# Recovery Plan — Q011 Phase 7P Controlled Patch Retry

**Status:** historical prepared recovery; package/kernel rollback not invoked  
**Prepared and evaluated:** 2026-07-21  
**Paired change:**
[Phase 7P controlled patch retry](q011-phase7p-controlled-patch-retry-change-window.md)

## Safety Model

Q011 has no current checkpoint, VM export, or image-level backup. The upgrade
is not assumed to be transactionally reversible. This plan prioritizes
stopping, preserving evidence, using an already-installed prior kernel once
when available, and restoring network isolation. It does not authorize blind
`dnf history undo`, a second upgrade, package removal, cache cleanup, kernel
erasure, ISO attachment, VHDX replacement, or VM deletion.

## Actual Recovery Outcome

The package transaction displayed `Complete!`, but the immediate `$?`
assignment was mistyped and Bash attempted to execute `0`. Phase 7P stopped
before reboot and used only the read-only ambiguity checks in this plan. DNF
history proved a completed transaction `2`, `Return-Code: Success`, command
line `upgrade --refresh`, and 94 altered packages; RPM queries proved both the
old and new kernels remained installed. No DNF retry, history undo, package
removal, key change, or repository change ran.

Because the evidence removed ambiguity, neither prior-kernel recovery nor
package rollback was needed. The one approved reboot loaded the newest
installed kernel, all post-reboot gates passed, normal shutdown succeeded,
and `Phase7PEndStatePass=True` restored Off/disconnected/Untagged VLAN 0
state. This historical procedure remains useful as a record of the stop and
recovery boundaries but grants no new authority.

## Triggers

Invoke this plan when:

- a preflight or guest readiness gate fails;
- temporary attachment, DHCP, or SSH verification fails;
- the DNF proposal includes an unexpected repository, product, removal,
  downgrade, or new key import;
- DNF returns nonzero, is interrupted, or its history is ambiguous;
- a newly installed candidate kernel does not boot;
- post-reboot SELinux, service, failed-unit, registration, repository, trust,
  DHCP, SSH, kernel, or update-state validation fails; or
- normal shutdown or final isolation cannot be proved.

## Before DNF Changes A Package

Do not start the transaction. If the guest is running and healthy, shut it
down normally:

```bash
sudo systemctl poweroff
```

After it is Off, disconnect only Q011 and restore Untagged VLAN 0. Record the
failed gate. No package or trust rollback is needed.

## Transaction Proposal Is Unsafe

Answer `N`. Do not alter repositories, accept a new key, remove a package, or
run a different DNF command. Capture only the safe unexpected package/source
fact, then shut down and isolate Q011.

## Transaction Fails Or Becomes Ambiguous

Do not retry and do not run `dnf history undo`. At the same VMConnect console,
retain only:

```bash
pgrep -a -f '[d]nf upgrade --refresh'
sudo dnf history list --reverse | tail -5
sudo dnf history info last
systemctl --failed --no-legend --plain
```

If the original DNF process remains active, allow that one process to finish.
Do not start another. If it is not active and history is failed, incomplete,
or ambiguous, stop package work.

If the guest remains stable, shut down normally. If normal shutdown times out,
disconnect Q011 and restore Untagged VLAN 0 while leaving its power state
unchanged. Verify that limited containment with this elevated host-side block:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'

    Disconnect-VMNetworkAdapter -VMName $VmName
    Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

    $Adapter = Get-VMNetworkAdapter -VMName $VmName
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Phase7PNetworkContainmentPass = (
        [string]::IsNullOrWhiteSpace($Adapter.SwitchName) -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0
    )

    [pscustomobject]@{
        VmName                         = $VmName
        State                          = (Get-VM -Name $VmName).State
        Disconnected                   = [string]::IsNullOrWhiteSpace(
            $Adapter.SwitchName
        )
        OperationMode                  = $Vlan.OperationMode
        AccessVlanId                    = $Vlan.AccessVlanId
        Phase7PNetworkContainmentPass   = $Phase7PNetworkContainmentPass
    } | Format-List

    if (-not $Phase7PNetworkContainmentPass) {
        throw 'Q011 Phase 7P network containment failed.'
    }
}
```

`Phase7PNetworkContainmentPass=True` proves only network isolation; it is not
`Phase7PRecoveryPass` and makes no claim that the VM is Off. Hyper-V **Turn
Off** requires separate approval. Run the final recovery verification below
only after the VM is Off through normal or separately approved action.

## Newly Installed Candidate Kernel Does Not Boot

Keep VMConnect open. If GRUB already offers a previously installed kernel,
select that prior kernel once. Do not change the default, edit GRUB, or erase
the candidate kernel. After the prior kernel boots, run only:

```bash
uname -r
getenforce
systemctl is-system-running
systemctl --failed --no-legend --plain
systemctl is-active sshd firewalld
```

Record that recovery used the prior kernel, shut down normally, and isolate
Q011. The patch window is not successful and later diagnosis requires a new
approval.

If no prior kernel boots, disconnect Q011 on the Hyper-V host and restore
Untagged VLAN 0. Do not attach the ISO, replace the VHDX, delete the VM, or
force power Off without separate approval. The retained verified ISO and
Phase 4–7 evidence support a later rebuild decision but do not authorize it.

## Guest Boots But Validation Fails

Do not weaken SELinux, disable firewalld, edit SSH or NetworkManager, import or
delete a key, change repositories, remove a package, or run a second update.
Capture only the failing gate and safe unit/package names. Shut down normally
and restore isolation.

If `post_check_update_exit=100`, retain the safe package-name/version list and
stop. Do not speculate about publication timing and do not run another
transaction in this window.

## Restore Hyper-V Isolation After The VM Is Off

After Q011 is Off, run in elevated PowerShell on `WIN-PRQD8TJG04M`. Do not
run this Off-state gate against a still-running, network-contained guest:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'

    Disconnect-VMNetworkAdapter -VMName $VmName
    Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Dvd = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(
        Get-VMSnapshot -VMName $VmName -ErrorAction SilentlyContinue
    )

    $Phase7PRecoveryPass = (
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName) -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0 -and
        $Dvd.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Dvd[0].Path) -and
        $Snapshots.Count -eq 0
    )

    [pscustomobject]@{
        VmName                 = $Vm.Name
        State                  = $Vm.State
        AdapterCount           = $Adapters.Count
        Disconnected           = [string]::IsNullOrWhiteSpace(
            $Adapters[0].SwitchName
        )
        OperationMode          = $Vlan.OperationMode
        AccessVlanId           = $Vlan.AccessVlanId
        DvdEmpty               = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
        SnapshotCount          = $Snapshots.Count
        Phase7PRecoveryPass    = $Phase7PRecoveryPass
    } | Format-List

    if (-not $Phase7PRecoveryPass) {
        throw 'Q011 Phase 7P recovery isolation failed.'
    }
}
```

Keep the OPNsense reservation, existing `eth0` autoconnect setting, Red Hat
registration, BaseOS/AppStream configuration, and Phase 7K trust set unless a
later exact approval says otherwise.

## Evidence To Retain

Retain only the failing gate, DNF exit, last transaction status, selected
kernel if prior-kernel recovery was used, and final isolation result. Do not
retain password prompts, Red Hat identity values, tokens, complete repository
URLs, or unrelated host/VM inventory.

The completed result and actual read-only recovery are preserved in the
[Phase 7P evidence](../evidence/q011-phase7p-evidence.md) and
[sanitized results](../evidence/q011-phase7p-sanitized-results.txt).
