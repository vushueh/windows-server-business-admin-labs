# Q011 Phase 7 — Controlled RHEL Patching Change Window (Stopped)

**Executed:** 2026-07-20  
**Approved by Leonel:** 2026-07-20, exact reviewed Phase 7 window  
**Executor:** Leonel, manually and supervised  
**Systems touched:** `WIN-PRQD8TJG04M`, `Q011-RHEL102-BASELINE`, existing
`vSwitch-LAN` Access VLAN 70 path, existing OPNsense reservation, and Red Hat
BaseOS/AppStream repositories

## Objective

The approved objective was to reconnect only Q011 to its proved VLAN 70 path, capture a fresh
pre-update baseline, apply one supported RHEL package upgrade transaction,
reboot once, validate the resulting kernel and service/security state, then
return Q011 to Off, disconnected, Untagged VLAN 0 state.

This is now a historical record, not authority to retry. Execution stopped at
an unexpected GPG-key import gate before any package transaction was recorded.
All keys were declined, `upgrade_exit=1`, no reboot occurred, and Q011 returned
to the required safe state with `Phase7RecoveryPass=True`. The exact evidence
is in the [Phase 7 stop record](../evidence/q011-phase7-evidence.md).

## Decisions And Known Starting State

- Phase 6 ended with `Phase6EndStatePass=True`.
- Q011 is registered and the RHEL 10 x86_64 BaseOS and AppStream repositories
  are enabled.
- OPNsense reserves `192.168.70.140` for Q011's existing adapter.
- The existing `eth0` profile uses DHCP and `connection.autoconnect=yes`.
- The legacy ASA must remain powered off throughout the window.
- Windows 11 is the proved SSH administration path; the Hyper-V host is not.
- No Phase 7 checkpoint or VM export is currently approved. Recovery depends
  on a previously installed kernel or a separately approved ISO rebuild.
- The operator must explicitly accept that point of no return again before
  the package transaction begins; evidence is not a backup.

## Fresh Phase 7A Preflight

Run on elevated PowerShell directly on `WIN-PRQD8TJG04M`:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'
    $TargetSwitch = 'vSwitch-LAN'

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Dvd = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(Get-VMSnapshot -VMName $VmName -ErrorAction SilentlyContinue)
    $Switch = Get-VMSwitch -Name $TargetSwitch
    $DVolume = Get-Volume -DriveLetter D

    $Confirmation = Read-Host (
        'After confirming the ASA is Off and no competing backup, storage, ' +
        'maintenance, Hyper-V, or Q011 work is active, type ' +
        'ASA-OFF-NO-COMPETING-WORK'
    )

    $Phase7PreflightPass = (
        $env:COMPUTERNAME -eq 'WIN-PRQD8TJG04M' -and
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName) -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0 -and
        $Dvd.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Dvd[0].Path) -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing' -and
        $Switch.SwitchType -eq 'External' -and
        $DVolume.SizeRemaining -ge 100GB -and
        $Confirmation -ceq 'ASA-OFF-NO-COMPETING-WORK'
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        VmName                = $Vm.Name
        State                 = $Vm.State
        Disconnected          = [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName)
        OperationMode         = $Vlan.OperationMode
        AccessVlanId          = $Vlan.AccessVlanId
        DvdEmpty              = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
        SnapshotCount         = $Snapshots.Count
        DFreeGiB              = [math]::Round($DVolume.SizeRemaining / 1GB, 1)
        TargetSwitch          = $Switch.Name
        Phase7PreflightPass   = $Phase7PreflightPass
    } | Format-List

    if (-not $Phase7PreflightPass) {
        throw 'Q011 Phase 7 preflight failed; do not attach or start the VM.'
    }
}
```

Stop unless `Phase7PreflightPass=True`.

## Phase 7B — Attach, Start, And Prove The Existing Path

On the Hyper-V host:

```powershell
$VmName = 'Q011-RHEL102-BASELINE'
Set-VMNetworkAdapterVlan -VMName $VmName -Access -VlanId 70
Connect-VMNetworkAdapter -VMName $VmName -SwitchName 'vSwitch-LAN'
Start-VM -Name $VmName
```

From Windows 11, require SSH to `leonel@192.168.70.140` without running a
manual NetworkManager activation. In the guest, verify only:

```bash
whoami
hostname
ip -4 -brief address show dev eth0
nmcli -g IP4.GATEWAY device show eth0
```

Require `leonel`, `q011-rhel01`, `192.168.70.140/24`, and gateway
`192.168.70.1`.

## Phase 7C — Capture The Pre-Update Baseline

Run over the proved SSH session:

```bash
date --iso-8601=seconds
cat /etc/redhat-release
uname -r
rpm -q kernel
getenforce
systemctl is-system-running
systemctl --failed --no-legend --plain
systemctl is-active sshd firewalld
df -h /

root_avail_bytes=$(df --output=avail -B1 / | awk 'NR == 2 {print $1}')
root_space_pass=false
if [ "$root_avail_bytes" -ge $((10 * 1024 * 1024 * 1024)) ]; then
  root_space_pass=true
fi
printf 'root_available_bytes=%s\n' "$root_avail_bytes"
printf 'root_space_pass=%s\n' "$root_space_pass"

sudo subscription-manager status >/dev/null 2>&1
printf 'registration_pass=%s\n' "$([ "$?" -eq 0 ] && echo true || echo false)"

sudo dnf repolist --enabled -q 2>/dev/null |
  grep -q '^rhel-10-for-x86_64-baseos-rpms[[:space:]]'
printf 'baseos_repo_enabled=%s\n' "$([ "$?" -eq 0 ] && echo true || echo false)"

sudo dnf repolist --enabled -q 2>/dev/null |
  grep -q '^rhel-10-for-x86_64-appstream-rpms[[:space:]]'
printf 'appstream_repo_enabled=%s\n' "$([ "$?" -eq 0 ] && echo true || echo false)"

sudo dnf check-update
printf 'check_update_exit=%s\n' "$?"
```

`dnf check-update` exit `100` means updates are available; exit `0` means no
updates. Any other exit stops the window. Stop if `/` has less than 10 GiB
available, SELinux is not Enforcing, either required service is inactive,
registration or either required repository check fails, or unexpected failed
units appear.

## Phase 7D — Apply One Package Upgrade Transaction At VMConnect

Do **not** run the package transaction over SSH. Open VMConnect to Q011 and use
the existing local `leonel` console so a Windows 11 SSH interruption cannot
send SIGHUP to the foreground package process. Closing and reopening VMConnect
does not end the guest console session.

Only after all prior gates pass, type the confirmation at the console and
answer its prompt interactively. Do not paste the entire block at once because
`read` could consume the next pasted command and fail closed.

```bash
printf '%s\n' 'There is no current checkpoint, VM export, or image backup.'
read -r -p 'Type PATCH-NO-IMAGE-BACKUP-ACCEPTED to continue: ' patch_confirmation
if [ "$patch_confirmation" != 'PATCH-NO-IMAGE-BACKUP-ACCEPTED' ]; then
  printf '%s\n' 'Point-of-no-return confirmation failed; do not patch.'
  exit 2
fi

sudo dnf upgrade --refresh
upgrade_exit=$?
printf 'upgrade_exit=%s\n' "$upgrade_exit"
```

Review the complete package transaction summary before answering `y`. Stop if
an unexpected repository, product, package removal, or GPG-key import appears.
Require `upgrade_exit=0`; a nonzero result ends the transaction attempt without
a retry. Do not install an additional package, enable another repository,
accept a new product or key, change a configuration file manually, run a
second upgrade attempt, or erase an old kernel.

After success, retain only safe transaction facts:

```bash
sudo dnf history info last |
  grep -E '^(Transaction ID|Begin time|End time|Command Line|Packages Altered)'
```

Do not retain credentials, entitlement identity, consumer UUID, organization
values, tokens, or authenticated URLs.

If VMConnect closes or becomes unavailable during the transaction, reconnect
to the same Q011 console. Do not start another `dnf` command. If the foreground
command is no longer visible, inspect only:

```bash
pgrep -a -f '[d]nf upgrade --refresh'
sudo dnf history info last
```

An active process remains the one approved transaction and must be allowed to
finish. An incomplete or failed history result invokes the paired recovery
plan; do not retry.

## Phase 7E — Reboot And Validate

Reboot once:

```bash
sudo systemctl reboot
```

After SSH returns automatically at `192.168.70.140`, run:

```bash
date --iso-8601=seconds
cat /etc/redhat-release
uname -r
rpm -q kernel
getenforce
systemctl is-system-running
systemctl --failed --no-legend --plain
systemctl is-active sshd firewalld
sudo dnf check-update
printf 'post_check_update_exit=%s\n' "$?"
```

Require SSH without manual `nmcli`, SELinux Enforcing, `sshd` and `firewalld`
active, no unexpected failed units, and a `dnf check-update` exit of `0` or
`100`. If exit `100` returns, retain the safe package-name/version list, stop,
and defer cause analysis; do not claim when those updates were published and
do not run a second upgrade.

## Phase 7F — Normal Shutdown And Final Isolation

Run:

```bash
sudo systemctl poweroff
```

After Hyper-V reports Off, disconnect only Q011 and restore Untagged VLAN 0.
Then run this exact final verification in elevated PowerShell on the Hyper-V
host:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'
    $Deadline = (Get-Date).AddMinutes(3)

    do {
        $Vm = Get-VM -Name $VmName
        if ($Vm.State -eq 'Off') { break }
        Start-Sleep -Seconds 3
    } while ((Get-Date) -lt $Deadline)

    if ($Vm.State -ne 'Off') {
        Disconnect-VMNetworkAdapter -VMName $VmName
        Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

        $ContainedAdapter = Get-VMNetworkAdapter -VMName $VmName
        $ContainedVlan = Get-VMNetworkAdapterVlan -VMName $VmName
        $NetworkContainmentPass = (
            [string]::IsNullOrWhiteSpace($ContainedAdapter.SwitchName) -and
            $ContainedVlan.OperationMode -eq 'Untagged' -and
            $ContainedVlan.AccessVlanId -eq 0
        )

        [pscustomobject]@{
            VmName                  = $Vm.Name
            State                   = $Vm.State
            NetworkContained        = $NetworkContainmentPass
            ContainedOperationMode  = $ContainedVlan.OperationMode
            ContainedAccessVlanId   = $ContainedVlan.AccessVlanId
        } | Format-List

        throw (
            'Q011 did not shut down normally. Its network was contained; ' +
            'do not force it Off without separate confirmation.'
        )
    }

    Disconnect-VMNetworkAdapter -VMName $VmName
    Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Dvd = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(
        Get-VMSnapshot -VMName $VmName -ErrorAction SilentlyContinue
    )

    $Phase7EndStatePass = (
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName) -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0 -and
        $Dvd.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Dvd[0].Path) -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing'
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        VmName                = $Vm.Name
        State                 = $Vm.State
        AdapterCount          = $Adapters.Count
        Disconnected          = [string]::IsNullOrWhiteSpace(
            $Adapters[0].SwitchName
        )
        OperationMode         = $Vlan.OperationMode
        AccessVlanId          = $Vlan.AccessVlanId
        DvdEmpty              = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
        SnapshotCount         = $Snapshots.Count
        AutomaticCheckpoints  = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction  = $Vm.AutomaticStartAction
        Phase7EndStatePass     = $Phase7EndStatePass
    } | Format-List

    if (-not $Phase7EndStatePass) {
        throw 'Q011 Phase 7 final isolation verification failed.'
    }
}
```

## Screenshots And Actual Capture Result

Leonel captures actual hands-on proof:

1. `q011-phase7-01-preupdate-readiness.png` — release, current kernel,
   Enforcing SELinux, healthy services, root free space, and accepted
   `check_update_exit`, with no credential or identity values. Crop away any
   scrollback above the sanitized Boolean registration/repository lines.
2. `q011-phase7-02-postupdate-reboot-validation.png` was **not created**
   because patching stopped before a transaction and reboot. It must not be
   fabricated or inferred.
3. `q011-phase7-03-safe-end-state.png` — host final Off/disconnected proof;
   this supporting image belongs in the evidence walkthrough because the
   README may display no more than two Phase 7 images.

## Stop Conditions

Stop and use the paired recovery plan if:

- any preflight, DHCP, SSH, registration, repository, disk, SELinux, service,
  or failed-unit gate fails;
- `dnf check-update` returns anything other than `0` or `100`;
- VMConnect is lost and the single approved transaction cannot be accounted
  for through the same console, process check, or last-history result;
- the upgrade returns nonzero or requests an unexpected repository, product,
  package removal, or GPG-key import;
- credentials or subscription identity would enter retained evidence;
- the reboot does not restore automatic SSH at the reserved address;
- the updated guest does not boot or a required service fails; or
- another VM, switch, network object, host task, or backup becomes involved.

## Approval Statement Template

This stored text is not authority by itself:

> I approve Q011 Phase 7 only on WIN-PRQD8TJG04M and
> Q011-RHEL102-BASELINE: run the documented fresh preflight and stop unless
> Phase7PreflightPass=True; keep the conflicting ASA powered off; temporarily
> connect only Q011 to vSwitch-LAN as Access VLAN 70; require its reserved
> 192.168.70.140 DHCP and Windows 11 SSH path; capture the documented
> pre-update baseline; use VMConnect rather than SSH for the package change;
> interactively review and run only one sudo dnf upgrade --refresh transaction;
> explicitly accept that no current checkpoint, VM export, or image backup
> exists before crossing the package-transaction point of no return;
> reboot only Q011 once; validate the documented kernel, package, SELinux,
> service, failed-unit, repository, and DHCP/SSH results; capture the planned
> safe screenshots; then shut down normally, disconnect only Q011, restore
> Untagged VLAN 0, and require Phase7EndStatePass=True. If normal shutdown
> times out, disconnect only Q011 and restore Untagged VLAN 0 while leaving the
> guest running for separate containment approval. Do not change OPNsense,
> NetworkManager, SSH, firewalld, SELinux, accounts, repositories, another VM,
> switch, host setting, checkpoint, VHDX, or ISO; install a separately named
> package; erase a kernel; run a second upgrade; expose credentials or Red Hat
> identity values; or perform Git/GitHub operations. If a stop condition
> occurs, follow the paired Phase 7 recovery plan. No other action is approved.

## Recovery

Use the paired
[Phase 7 recovery plan](q011-phase7-controlled-patching-rollback.md). The
upgrade is not described as universally reversible; failure containment and
an evidence-backed previous-kernel or rebuild decision replace unsafe blind
package reversal.

## Outcome

**Result:** stopped fail-closed at the unapproved GPG trust gate. DNF prompted
for Red Hat release key 2, auxiliary key 3, and release key 4; Leonel declined
all three. DNF installed no key, returned `upgrade_exit=1`, and retained the
downloaded RPMs in cache.  
**Transaction state:** DNF history remained at transaction `1`, the original
installation; no package modification was observed and no reboot ran.  
**Recovery:** normal guest shutdown and exact host isolation passed with
`Phase7RecoveryPass=True`.  
**Evidence:** [stop evidence](../evidence/q011-phase7-evidence.md),
[searchable results](../evidence/q011-phase7-sanitized-results.txt),
[visual walkthrough](../evidence/q011-phase7-visual-walkthrough.md), and
[screenshot hashes](../evidence/q011-phase7-screenshots.sha256).  
**Next gate:** the separate
[Phase 7G read-only GPG trust investigation](q011-phase7g-gpg-trust-read-only-investigation.md).
No key import, DNF retry, or cache cleanup is authorized.
