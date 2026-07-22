# Q011 Phase 7P — Controlled Patch Retry And Reboot Change Window

**Status:** executed successfully; historical run sheet, not repeat authority  
**Prepared and executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Paired recovery:**
[Phase 7P recovery plan](q011-phase7p-controlled-patch-retry-recovery.md)

## Objective

Starting from the proved Phase 7K Off/disconnected state, this window
re-established only Q011's bounded VLAN 70 path, proved the retained Red Hat
trust set and original unpatched baseline, ran one supervised
`dnf upgrade --refresh` transaction at VMConnect, rebooted once into the
newest installed kernel, validated the guest, and returned it to Off,
disconnected, Untagged VLAN 0 state.

The exact Phase 7P approval authorized this historical execution. This file
does not authorize a repeat transaction or another live action.

## Evidence Basis

Phase 7 established:

- the pre-update service, SELinux, registration, repository, disk, DHCP, and
  SSH gates passed;
- five installs and 88 upgrades from BaseOS/AppStream were proposed;
- all three unexpected key prompts were declined;
- `upgrade_exit=1`, DNF history still ended at the original installation, no
  package transaction was observed, and no reboot ran; and
- `Phase7RecoveryPass=True` restored isolation.

Phase 7K then established:

- exactly the three allowlisted packaged Red Hat certificates are trusted;
- the retained BaseOS and AppStream samples authenticate both observed
  signature schemes and all digests;
- no DNF command or package transaction ran; and
- `Phase7KEndStatePass=True` restored Off/disconnected/Untagged VLAN 0 state.

## Executed Approval Boundary

The exact live approval included:

1. fresh read-only host and guest gates;
2. temporary Q011-only Access VLAN 70 attachment while the conflicting ASA is
   confirmed Off;
3. one interactive SSH session for pre- and post-transaction verification;
4. one interactive `sudo dnf upgrade --refresh` transaction at VMConnect;
5. one normal reboot after and only after transaction success;
6. one prior-kernel boot selection only if a newly installed candidate kernel
   fails and GRUB already offers the previous kernel;
7. safe screenshots; and
8. normal shutdown and restoration to disconnected Untagged VLAN 0.

It did not authorize a second DNF transaction, key import or deletion, cache
cleanup, package removal, kernel erasure, repository edit, checkpoint, VM
export, ISO attachment, OPNsense change, another VM, or another host setting.

## Point Of No Return

No current Q011 checkpoint, VM export, or image-level backup existed. The DNF
transaction was not treated as atomically reversible. Leonel explicitly
accepted that condition immediately before running DNF. After package
changes, the recovery promise was evidence, containment, and one existing
prior-kernel boot if necessary—not blind `dnf history undo`.

## Phase 7P-A — Fresh Host Preflight

Run in elevated Windows PowerShell directly on `WIN-PRQD8TJG04M`:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'
    $TargetSwitch = 'vSwitch-LAN'

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Dvd = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(
        Get-VMSnapshot -VMName $VmName -ErrorAction SilentlyContinue
    )
    $Switch = Get-VMSwitch -Name $TargetSwitch
    $DVolume = Get-Volume -DriveLetter D
    $Os = Get-CimInstance Win32_OperatingSystem
    $Transitioning = @(
        Get-VM | Where-Object State -in @(
            'Starting', 'Stopping', 'Saving', 'Pausing', 'Resuming'
        )
    )

    $Confirmation = Read-Host (
        'After confirming the ASA is Off and no competing backup, storage, ' +
        'maintenance, Hyper-V, or Q011 work is active, type ' +
        'ASA-OFF-NO-COMPETING-WORK'
    )

    $FreeMemoryGiB = [math]::Round(
        ($Os.FreePhysicalMemory * 1KB) / 1GB,
        1
    )

    $Phase7PPreflightPass = (
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
        $FreeMemoryGiB -ge 8 -and
        $Transitioning.Count -eq 0 -and
        $Confirmation -ceq 'ASA-OFF-NO-COMPETING-WORK'
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        VmName                = $Vm.Name
        State                 = $Vm.State
        Disconnected          = [string]::IsNullOrWhiteSpace(
            $Adapters[0].SwitchName
        )
        OperationMode         = $Vlan.OperationMode
        AccessVlanId          = $Vlan.AccessVlanId
        DvdEmpty              = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
        SnapshotCount         = $Snapshots.Count
        FreeMemoryGiB         = $FreeMemoryGiB
        DFreeGiB              = [math]::Round(
            $DVolume.SizeRemaining / 1GB,
            1
        )
        TransitioningVmCount  = $Transitioning.Count
        TargetSwitch          = $Switch.Name
        Phase7PPreflightPass  = $Phase7PPreflightPass
    } | Format-List

    if (-not $Phase7PPreflightPass) {
        throw 'Q011 Phase 7P preflight failed; do not attach or start the VM.'
    }
}
```

Stop unless `Phase7PPreflightPass=True`.

## Phase 7P-B — Attach And Start Only Q011

Run on the same elevated Hyper-V host console:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'
    $TargetSwitch = 'vSwitch-LAN'

    try {
        Set-VMNetworkAdapterVlan `
            -VMName $VmName `
            -Access `
            -VlanId 70 `
            -ErrorAction Stop
        Connect-VMNetworkAdapter `
            -VMName $VmName `
            -SwitchName $TargetSwitch `
            -ErrorAction Stop

        $Adapter = Get-VMNetworkAdapter -VMName $VmName
        $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
        $AttachmentPass = (
            $Adapter.SwitchName -eq $TargetSwitch -and
            $Vlan.OperationMode -eq 'Access' -and
            $Vlan.AccessVlanId -eq 70
        )

        if (-not $AttachmentPass) {
            throw 'Exact Q011 Access VLAN 70 attachment did not verify.'
        }

        Start-VM -Name $VmName -ErrorAction Stop
    }
    catch {
        Disconnect-VMNetworkAdapter `
            -VMName $VmName `
            -ErrorAction SilentlyContinue
        Set-VMNetworkAdapterVlan `
            -VMName $VmName `
            -Untagged `
            -ErrorAction SilentlyContinue
        throw
    }

    $Vm = Get-VM -Name $VmName
    $Adapter = Get-VMNetworkAdapter -VMName $VmName
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Phase7PAttachmentPass = (
        $Vm.State -eq 'Running' -and
        $Adapter.SwitchName -eq $TargetSwitch -and
        $Vlan.OperationMode -eq 'Access' -and
        $Vlan.AccessVlanId -eq 70
    )

    [pscustomobject]@{
        VmName                 = $Vm.Name
        State                  = $Vm.State
        SwitchName             = $Adapter.SwitchName
        OperationMode          = $Vlan.OperationMode
        AccessVlanId           = $Vlan.AccessVlanId
        Phase7PAttachmentPass  = $Phase7PAttachmentPass
    } | Format-List

    if (-not $Phase7PAttachmentPass) {
        throw 'Q011 Phase 7P attachment verification failed.'
    }
}
```

From Windows 11, require one interactive SSH login to
`leonel@192.168.70.140`. Do not run manual `nmcli`. Verify:

```bash
whoami
hostname
ip -4 -brief address show dev eth0
nmcli -g IP4.GATEWAY device show eth0
```

Require `leonel`, `q011-rhel01`, `192.168.70.140/24`, and
`192.168.70.1`.

## Phase 7P-C — Guest Readiness And Trust Gate

Run this read-only block over the proved SSH session. It may read repository
metadata but must not change a package:

```bash
expected_keys=$(printf '%s\n' \
  'fd431d51-4ae0493b' \
  '5a6340b3-6229229e' \
  '05707a62-68e6a1f3' | sort)
actual_keys=$(rpm -qa 'gpg-pubkey*' \
  --qf '%{VERSION}-%{RELEASE}\n' | sort)

exact_key_set=false
if test "$actual_keys" = "$expected_keys"; then
  exact_key_set=true
fi

baseos_sample=/var/cache/dnf/rhel-10-for-x86_64-baseos-rpms-4b93e6b3052700d7/packages/kernel-core-6.12.0-211.34.1.el10_2.x86_64.rpm
appstream_sample=/var/cache/dnf/rhel-10-for-x86_64-appstream-rpms-7e19683532cf4c23/packages/amd-gpu-firmware-20260609-23.el10_2.noarch.rpm

baseos_verify=$(sudo rpmkeys -Kv "$baseos_sample" 2>&1)
baseos_verify_exit=$?
appstream_verify=$(sudo rpmkeys -Kv "$appstream_sample" 2>&1)
appstream_verify_exit=$?

sample_trust_pass=false
if test "$baseos_verify_exit" -eq 0 && \
   test "$appstream_verify_exit" -eq 0 && \
   printf '%s\n' "$baseos_verify" | grep -qi 'key ID 05707a62: OK' && \
   printf '%s\n' "$baseos_verify" | grep -qi 'key ID fd431d51: OK' && \
   printf '%s\n' "$appstream_verify" | grep -qi 'key ID 05707a62: OK' && \
   printf '%s\n' "$appstream_verify" | grep -qi 'key ID fd431d51: OK'; then
  sample_trust_pass=true
fi

system_state=$(systemctl is-system-running)
failed_units=$(systemctl --failed --no-legend --plain)
sshd_state=$(systemctl is-active sshd)
firewalld_state=$(systemctl is-active firewalld)
selinux_state=$(getenforce)
root_avail_bytes=$(df --output=avail -B1 / | awk 'NR == 2 {print $1}')
active_package_processes=$(
  pgrep -a -f '(^|/)([d]nf|[r]pm|[y]um)([[:space:]]|$)' || true
)

sudo subscription-manager status >/dev/null 2>&1
registration_exit=$?
sudo dnf repolist --enabled -q 2>/dev/null |
  grep -q '^rhel-10-for-x86_64-baseos-rpms[[:space:]]'
baseos_repo_exit=$?
sudo dnf repolist --enabled -q 2>/dev/null |
  grep -q '^rhel-10-for-x86_64-appstream-rpms[[:space:]]'
appstream_repo_exit=$?

pre_history_id=$(
  sudo dnf history list --reverse -q |
    awk '$1 ~ /^[0-9]+$/ {last=$1} END {print last}'
)

sudo dnf check-update
check_update_exit=$?

Phase7PGuestPreflightPass=false
if test "$exact_key_set" = true && \
   test "$sample_trust_pass" = true && \
   test "$system_state" = running && \
   test -z "$failed_units" && \
   test "$sshd_state" = active && \
   test "$firewalld_state" = active && \
   test "$selinux_state" = Enforcing && \
   test "$root_avail_bytes" -ge $((10 * 1024 * 1024 * 1024)) && \
   test -z "$active_package_processes" && \
   test "$registration_exit" -eq 0 && \
   test "$baseos_repo_exit" -eq 0 && \
   test "$appstream_repo_exit" -eq 0 && \
   test "$pre_history_id" = 1 && \
   test "$check_update_exit" -eq 100; then
  Phase7PGuestPreflightPass=true
fi

cat /etc/redhat-release
printf 'running_kernel=%s\n' "$(uname -r)"
rpm -q kernel
printf 'exact_key_set=%s\n' "$exact_key_set"
printf 'sample_trust_pass=%s\n' "$sample_trust_pass"
printf 'system_state=%s\n' "$system_state"
printf 'failed_unit_count=%s\n' "$(printf '%s' "$failed_units" | grep -c . || true)"
printf 'sshd_state=%s\n' "$sshd_state"
printf 'firewalld_state=%s\n' "$firewalld_state"
printf 'selinux_state=%s\n' "$selinux_state"
printf 'root_available_bytes=%s\n' "$root_avail_bytes"
printf 'active_package_process_count=%s\n' "$(printf '%s' "$active_package_processes" | grep -c . || true)"
printf 'registration_pass=%s\n' "$([ "$registration_exit" -eq 0 ] && echo true || echo false)"
printf 'baseos_repo_enabled=%s\n' "$([ "$baseos_repo_exit" -eq 0 ] && echo true || echo false)"
printf 'appstream_repo_enabled=%s\n' "$([ "$appstream_repo_exit" -eq 0 ] && echo true || echo false)"
printf 'pre_history_id=%s\n' "$pre_history_id"
printf 'check_update_exit=%s\n' "$check_update_exit"
printf 'Phase7PGuestPreflightPass=%s\n' "$Phase7PGuestPreflightPass"
```

Stop unless `Phase7PGuestPreflightPass=true`. The expected history ID `1`
proves no package transaction was recorded after installation and before this
retry. If updates are no longer available (`check_update_exit=0`), do not run
an empty transaction; shut down and request a documentation decision. Any
other exit, including `1`, is a repository/metadata error: stop, shut down,
restore isolation, and retain only the failed gate.

## Phase 7P-D — One Supervised Transaction At VMConnect

Open VMConnect to the existing Q011 console. Do **not** run the transaction
over SSH. Type the confirmation block separately so pasted text cannot satisfy
the prompt:

```bash
printf '%s\n' 'There is no current checkpoint, VM export, or image backup.'
read -r -p 'Type PATCH-NO-IMAGE-BACKUP-ACCEPTED to continue: ' patch_confirmation
if test "$patch_confirmation" != 'PATCH-NO-IMAGE-BACKUP-ACCEPTED'; then
  printf '%s\n' 'Point-of-no-return confirmation failed; do not patch.'
  exit 2
fi
```

Then run only this transaction block:

```bash
pre_running_kernel=$(uname -r)
pre_history_id=$(
  sudo dnf history list --reverse -q |
    awk '$1 ~ /^[0-9]+$/ {last=$1} END {print last}'
)

sudo dnf upgrade --refresh
upgrade_exit=$?

post_history_id=$(
  sudo dnf history list --reverse -q |
    awk '$1 ~ /^[0-9]+$/ {last=$1} END {print last}'
)
candidate_kernel=$(
  rpm -q kernel --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' |
    sort -V | tail -1
)

new_kernel_present=false
if test -n "$candidate_kernel" && \
   test "$candidate_kernel" != "$pre_running_kernel"; then
  new_kernel_present=true
fi

Phase7PTransactionPass=false
if test "$upgrade_exit" -eq 0 && \
   test -n "$post_history_id" && \
   test "$post_history_id" != "$pre_history_id" && \
   test -n "$candidate_kernel"; then
  Phase7PTransactionPass=true
fi

printf 'pre_running_kernel=%s\n' "$pre_running_kernel"
printf 'pre_history_id=%s\n' "$pre_history_id"
printf 'upgrade_exit=%s\n' "$upgrade_exit"
printf 'post_history_id=%s\n' "$post_history_id"
printf 'candidate_kernel=%s\n' "$candidate_kernel"
printf 'new_kernel_present=%s\n' "$new_kernel_present"
printf 'Phase7PTransactionPass=%s\n' "$Phase7PTransactionPass"

sudo dnf history info last |
  grep -E '^(Transaction ID|Begin time|End time|Command Line|Packages Altered)'
```

Review the complete transaction summary before answering `y`. Stop and answer
`N` if it proposes a removal, downgrade, unexpected repository/product, or
any new key import. Require `upgrade_exit=0`, a new history ID, a nonempty
newest installed-kernel result, and `Phase7PTransactionPass=true`.
`new_kernel_present` records whether this transaction installed a candidate
newer than the pre-transaction running kernel; it is not itself a transaction
success gate because repository content can change after the original Phase 7
proposal. A successful transaction reboots once in either case and must boot
the newest installed kernel. A nonzero result or ambiguous history ends this
attempt; do not retry and do not run `dnf history undo`.

If VMConnect closes, reopen only the same Q011 console. Do not start a second
DNF command. If the foreground command is no longer visible, inspect only:

```bash
pgrep -a -f '[d]nf upgrade --refresh'
sudo dnf history info last
```

Allow the original process to finish if it is still active. Otherwise invoke
the paired recovery boundary.

## Phase 7P-E — One Reboot And Post-Patch Validation

Only after `Phase7PTransactionPass=true`, reboot once from VMConnect:

```bash
sudo systemctl reboot
```

Keep VMConnect open. Require the installed guest to boot normally. Windows 11
SSH must return automatically at `192.168.70.140` without manual `nmcli`.
Then run this validation over SSH:

```bash
running_kernel=$(uname -r)
latest_installed_kernel=$(
  rpm -q kernel --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' |
    sort -V | tail -1
)
system_state=$(systemctl is-system-running)
failed_units=$(systemctl --failed --no-legend --plain)
sshd_state=$(systemctl is-active sshd)
firewalld_state=$(systemctl is-active firewalld)
selinux_state=$(getenforce)

expected_keys=$(printf '%s\n' \
  'fd431d51-4ae0493b' \
  '5a6340b3-6229229e' \
  '05707a62-68e6a1f3' | sort)
actual_keys=$(rpm -qa 'gpg-pubkey*' \
  --qf '%{VERSION}-%{RELEASE}\n' | sort)
exact_key_set=false
if test "$actual_keys" = "$expected_keys"; then
  exact_key_set=true
fi

sudo subscription-manager status >/dev/null 2>&1
registration_exit=$?
sudo dnf repolist --enabled -q 2>/dev/null |
  grep -q '^rhel-10-for-x86_64-baseos-rpms[[:space:]]'
baseos_repo_exit=$?
sudo dnf repolist --enabled -q 2>/dev/null |
  grep -q '^rhel-10-for-x86_64-appstream-rpms[[:space:]]'
appstream_repo_exit=$?

sudo dnf check-update
post_check_update_exit=$?

Phase7PControlsPass=false
if test "$running_kernel" = "$latest_installed_kernel" && \
   test "$system_state" = running && \
   test -z "$failed_units" && \
   test "$sshd_state" = active && \
   test "$firewalld_state" = active && \
   test "$selinux_state" = Enforcing && \
   test "$exact_key_set" = true && \
   test "$registration_exit" -eq 0 && \
   test "$baseos_repo_exit" -eq 0 && \
   test "$appstream_repo_exit" -eq 0; then
  Phase7PControlsPass=true
fi

Phase7PPostRebootDisposition=ValidationFailed
Phase7PPostRebootPass=false
if test "$Phase7PControlsPass" = true && \
   test "$post_check_update_exit" -eq 0; then
  Phase7PPostRebootDisposition=CurrentAtFinalCheck
  Phase7PPostRebootPass=true
elif test "$Phase7PControlsPass" = true && \
     test "$post_check_update_exit" -eq 100; then
  Phase7PPostRebootDisposition=UpdatesRemain
elif test "$Phase7PControlsPass" = true; then
  Phase7PPostRebootDisposition=RepositoryCheckError
fi

cat /etc/redhat-release
printf 'running_kernel=%s\n' "$running_kernel"
printf 'latest_installed_kernel=%s\n' "$latest_installed_kernel"
rpm -q kernel
printf 'system_state=%s\n' "$system_state"
printf 'failed_unit_count=%s\n' "$(printf '%s' "$failed_units" | grep -c . || true)"
printf 'sshd_state=%s\n' "$sshd_state"
printf 'firewalld_state=%s\n' "$firewalld_state"
printf 'selinux_state=%s\n' "$selinux_state"
printf 'exact_key_set=%s\n' "$exact_key_set"
printf 'registration_pass=%s\n' "$([ "$registration_exit" -eq 0 ] && echo true || echo false)"
printf 'baseos_repo_enabled=%s\n' "$([ "$baseos_repo_exit" -eq 0 ] && echo true || echo false)"
printf 'appstream_repo_enabled=%s\n' "$([ "$appstream_repo_exit" -eq 0 ] && echo true || echo false)"
printf 'post_check_update_exit=%s\n' "$post_check_update_exit"
printf 'Phase7PControlsPass=%s\n' "$Phase7PControlsPass"
printf 'Phase7PPostRebootDisposition=%s\n' "$Phase7PPostRebootDisposition"
printf 'Phase7PPostRebootPass=%s\n' "$Phase7PPostRebootPass"

sudo dnf history info last |
  grep -E '^(Transaction ID|Begin time|End time|Command Line|Packages Altered)'
```

Require `Phase7PPostRebootPass=true` and disposition
`CurrentAtFinalCheck` for Phase 7P success. If `post_check_update_exit=100`,
the explicit disposition is `UpdatesRemain`: the completed transaction and
healthy reboot may be recorded, but Phase 7P remains incomplete and no patch-
currency claim is allowed. Retain only the safe package-name/version list, do
not run a second transaction, and proceed to normal shutdown and isolation.
Any other nonzero update check is `RepositoryCheckError`; any other failed
gate is `ValidationFailed`. Both are controlled stops followed by isolation,
not success or authority to repair.

## Phase 7P-F — Normal Shutdown And Final Isolation

From the guest:

```bash
sudo systemctl poweroff
```

Then run in elevated PowerShell on the Hyper-V host:

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $VmName = 'Q011-RHEL102-BASELINE'
    $Deadline = (Get-Date).AddMinutes(3)

    do {
        $Vm = Get-VM -Name $VmName
        if ($Vm.State -eq 'Off') { break }
        Start-Sleep -Seconds 5
    } while ((Get-Date) -lt $Deadline)

    if ($Vm.State -ne 'Off') {
        Disconnect-VMNetworkAdapter -VMName $VmName
        Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

        $ContainedAdapter = Get-VMNetworkAdapter -VMName $VmName
        $ContainedVlan = Get-VMNetworkAdapterVlan -VMName $VmName
        $Phase7PNetworkContainmentPass = (
            [string]::IsNullOrWhiteSpace($ContainedAdapter.SwitchName) -and
            $ContainedVlan.OperationMode -eq 'Untagged' -and
            $ContainedVlan.AccessVlanId -eq 0
        )

        [pscustomobject]@{
            VmName                         = $Vm.Name
            State                          = $Vm.State
            Disconnected                   = [string]::IsNullOrWhiteSpace(
                $ContainedAdapter.SwitchName
            )
            OperationMode                  = $ContainedVlan.OperationMode
            AccessVlanId                    = $ContainedVlan.AccessVlanId
            Phase7PNetworkContainmentPass   = $Phase7PNetworkContainmentPass
        } | Format-List

        if (-not $Phase7PNetworkContainmentPass) {
            throw 'Q011 Phase 7P shutdown-timeout containment failed.'
        }

        throw (
            'Q011 did not shut down within three minutes. Its network was ' +
            'contained, but Off-state verification did not run; forced ' +
            'power-off requires separate approval.'
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

    $Phase7PEndStatePass = (
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
        Phase7PEndStatePass    = $Phase7PEndStatePass
    } | Format-List

    if (-not $Phase7PEndStatePass) {
        throw 'Q011 Phase 7P final isolation verification failed.'
    }
}
```

Patch success requires all of:

- `Phase7PPreflightPass=True`;
- `Phase7PAttachmentPass=True`;
- `Phase7PGuestPreflightPass=true`;
- `Phase7PTransactionPass=true`;
- `Phase7PPostRebootPass=true`; and
- `Phase7PEndStatePass=True`.

## Screenshot Result

Leonel captured actual hands-on proof with credentials and unrelated content
excluded:

1. `q011-phase7p-process-01-transaction-review.png` — the final reviewed DNF
   summary before answering `y`; supporting walkthrough only.
2. `q011-phase7p-01-transaction-success.png` — DNF completion and the
   read-only recovery result proving history ID `2`, `Return-Code: Success`,
   the new installed kernel, and `Phase7PTransactionPass=true`. The immediate
   `upgrade_exit` capture was lost to a shell-entry typo and was not
   reconstructed.
3. `q011-phase7p-02-postreboot-validation.png` — running kernel equals newest
   installed kernel, system/services/SELinux/trust/repositories pass,
   `post_check_update_exit=0`, and `Phase7PPostRebootPass=true`.
4. `q011-phase7p-03-safe-end-state.png` — final Off, disconnected, Untagged
   VLAN 0, DVD-empty, checkpoint-free state and `Phase7PEndStatePass=True`.

The project README displays transaction success and post-reboot validation.
The [visual walkthrough](../evidence/q011-phase7p-visual-walkthrough.md) uses
all four retained images, and the
[screenshot manifest](../evidence/q011-phase7p-screenshots.sha256) records
their exact hashes. The original transaction-review source omitted the
leading `q`; the canonical copy changed only that filename and retained
identical bytes. No retained image contains a password or sudo prompt, Red Hat
identity, consumer UUID, organization value, token, complete repository URL,
authenticated URL, or unrelated VM inventory.

## Stop Conditions

Stop and use the paired recovery plan if:

- any host, DHCP, SSH, trust, history, registration, repository, disk,
  SELinux, service, failed-unit, or process gate fails;
- the pre-update check returns anything other than `100`;
- the transaction proposes a removal, downgrade, unexpected source/product,
  or new key import;
- DNF returns nonzero, VMConnect loses the transaction, or history is
  ambiguous;
- a newly installed candidate kernel does not boot, or the guest does not
  boot the newest installed kernel;
- SSH does not return automatically at the reserved address;
- the post-update check returns `100` or another nonzero result;
- normal shutdown times out; or
- another VM, switch, host task, backup, or network object becomes involved.

## Historical Approval Statement

This is the approval used for the completed window. Stored text is not
authority to repeat it:

> I approve Q011 Phase 7P only on WIN-PRQD8TJG04M and
> Q011-RHEL102-BASELINE: execute the reviewed Phase 7P change window exactly
> as documented. Run the fresh host and guest gates; keep the conflicting ASA
> Off; temporarily attach only Q011 to vSwitch-LAN as Access VLAN 70; require
> the reserved 192.168.70.140 DHCP and Windows 11 SSH path; verify the exact
> three-key Red Hat trust set and two retained cached samples; explicitly
> accept that no checkpoint, VM export, or image backup exists; use VMConnect
> to review and run one interactive sudo dnf upgrade --refresh transaction;
> reboot only Q011 once after transaction success; validate the newest kernel,
> package history, update state, SELinux, services, repositories, trust, DHCP,
> and SSH; capture the planned safe screenshots; then shut down normally,
> disconnect only Q011, restore Untagged VLAN 0, and require
> Phase7PEndStatePass=True. If a newly installed candidate kernel fails and
> GRUB already offers the previous kernel, select that prior kernel once for
> containment only. Do not
> run a second DNF transaction, import or delete a key, clean cache, remove a
> package, erase a kernel, edit a repository or service, create a checkpoint
> or export, attach an ISO, change OPNsense, another VM, switch, or host
> setting, expose credentials or Red Hat identity values, or perform Git or
> GitHub operations. Follow the paired recovery plan on any stop condition.
> No other action is approved.

## Success And Next Boundary

Phase 7P passed every required gate. One supported package transaction
completed as DNF history transaction `2` with `Return-Code: Success`; the
guest rebooted into `6.12.0-211.37.1.el10_2.x86_64`; required controls
remained healthy; `dnf check-update` returned `0`; and
`Phase7PEndStatePass=True` restored Hyper-V isolation. The immediate shell
exit variable was lost after `Complete!`, so transaction success is claimed
from DNF history and installed-package evidence, not from a fabricated exit
value.

See the [execution evidence](../evidence/q011-phase7p-evidence.md),
[searchable results](../evidence/q011-phase7p-sanitized-results.txt),
[visual walkthrough](../evidence/q011-phase7p-visual-walkthrough.md), and
[screenshot manifest](../evidence/q011-phase7p-screenshots.sha256). Phase 8
post-patch comparison and rebuild-evidence work remains a separate approval.
