# Q011 Phase 8 — Post-Patch Validation And Rebuild Evidence

**Status:** executed successfully; historical run sheet, not repeat authority  
**Prepared and executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Paired containment:**
[Phase 8 failure-containment plan](q011-phase8-failure-containment.md)

## Objective

This window compared the patched guest with the Phase 5 service/security
baseline, proved the intended Phase 6 and Phase 7P changes, preserved a manual
rebuild record, and returned Q011 to Off, disconnected, Untagged VLAN 0 state.
Phase 8 was a validation window, not another repair or patch window.

## Evidence Basis And Expected Differences

The [Phase 5 results](../evidence/q011-phase5-sanitized-results.txt) are the
before-state. Phase 6 intentionally added the OPNsense reservation,
NetworkManager autoconnect, registration, and BaseOS/AppStream enablement.
Phase 7K intentionally added exactly three packaged Red Hat RPM trust
certificates. Phase 7P intentionally upgraded 89 packages, installed five new
kernel packages, recorded successful DNF history transaction `2`, and booted
kernel `6.12.0-211.37.1.el10_2.x86_64`.

Therefore package versions, installed kernels, registration state, RPM trust,
and DHCP persistence are expected to differ from Phase 5. The hostname,
locked root, `leonel` wheel membership, SELinux enforcing mode, service
enablement/health, effective SSH policy, firewall policy, configuration
hashes, LVM layout, one-adapter Hyper-V design, empty DVD, zero checkpoints,
and final isolation must remain stable.

## Executed Approval Boundary

The exact Phase 8 approval permitted only:

1. the fresh host preflight below;
2. temporary Access VLAN 70 attachment of only Q011 while the conflicting ASA
   remains Off;
3. starting only Q011 and one interactive Windows 11 SSH login as `leonel`;
4. the documented read-only guest checks and safe screenshots;
5. a normal guest shutdown; and
6. disconnection plus restoration to Untagged VLAN 0.

It did not permit a package transaction, DNF cache cleanup, key import or
deletion, repository edit, service restart or configuration change, firewall
or SELinux change, account change, NetworkManager change, DHCP change,
OPNsense change, checkpoint, export, backup, ISO attachment, another VM, or
another host/network object.

## Phase 8A — Fresh Host Preflight

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
    $Os = Get-CimInstance Win32_OperatingSystem
    $DVolume = Get-Volume -DriveLetter D
    $Transitioning = @(
        Get-VM | Where-Object State -in @(
            'Starting', 'Stopping', 'Saving', 'Pausing', 'Resuming'
        )
    )
    $Disconnected = (
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName)
    )
    $DvdEmpty = (
        $Dvd.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Dvd[0].Path)
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

    $Phase8PreflightPass = (
        $env:COMPUTERNAME -eq 'WIN-PRQD8TJG04M' -and
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        $Disconnected -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0 -and
        $Dvd.Count -eq 1 -and
        $DvdEmpty -and
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
        Disconnected          = $Disconnected
        OperationMode         = $Vlan.OperationMode
        AccessVlanId          = $Vlan.AccessVlanId
        DvdEmpty              = $DvdEmpty
        SnapshotCount         = $Snapshots.Count
        FreeMemoryGiB         = $FreeMemoryGiB
        DFreeGiB              = [math]::Round(
            $DVolume.SizeRemaining / 1GB,
            1
        )
        TransitioningVmCount  = $Transitioning.Count
        TargetSwitch          = $Switch.Name
        Phase8PreflightPass   = $Phase8PreflightPass
    } | Format-List

    if (-not $Phase8PreflightPass) {
        throw 'Q011 Phase 8 preflight failed; do not attach or start the VM.'
    }
}
```

Stop unless `Phase8PreflightPass=True`.

## Phase 8B — Attach And Start Only Q011

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
    $Phase8AttachmentPass = (
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
        Phase8AttachmentPass   = $Phase8AttachmentPass
    } | Format-List

    if (-not $Phase8AttachmentPass) {
        Disconnect-VMNetworkAdapter `
            -VMName $VmName `
            -ErrorAction SilentlyContinue
        Set-VMNetworkAdapterVlan `
            -VMName $VmName `
            -Untagged `
            -ErrorAction SilentlyContinue
        throw 'Q011 Phase 8 attachment verification failed.'
    }
}
```

An attachment-verification failure immediately contains only Q011's adapter
and hands off to the paired containment plan. It does not authorize forced
power-off.

From Windows 11, require one interactive SSH login to
`leonel@192.168.70.140`. Do not run manual `nmcli` activation. Run:

```bash
whoami
hostname
ip -4 -brief address show dev eth0
nmcli -g IP4.GATEWAY device show eth0
nmcli -f DHCP4 device show eth0 |
  grep -E 'dhcp_server_identifier|domain_name_servers|ip_address|routers'
```

Require `leonel`, `q011-rhel01`, `192.168.70.140/24`, gateway and DHCP server
`192.168.70.1`, and DNS `192.168.70.1`. Stop and contain if the profile needs
manual activation or another address/authority appears.

## Phase 8C — Read-Only Post-Patch Control Baseline

At the proved SSH session, run `sudo -v` interactively, then clear the screen
before capturing evidence. Never place a password in a command or image.

Run this read-only block exactly. Its only DNF call is local history lookup;
it does not run a package transaction, refresh/check repository metadata, or
change a package or configuration:

```bash
set -u

expected_sshd_hash=a7329525af126b8280fd52036f81df62a8f893ce8d917d787ac06ad6d6d1adaf
expected_selinux_hash=80134a263d874d1687a43513a09b6cc8fdc2998e623c1c1670cb5769a85ce942
expected_kernel=6.12.0-211.37.1.el10_2.x86_64
expected_keys=$(printf '%s\n' \
  'fd431d51-4ae0493b' \
  '5a6340b3-6229229e' \
  '05707a62-68e6a1f3' | sort)

release=$(cat /etc/redhat-release)
guest_hostname=$(hostname)
running_kernel=$(uname -r)
latest_kernel=$(rpm -q kernel --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' |
  sort -V | tail -1)
root_state=$(sudo passwd -S root | awk '{print $2}')
root_locked=false
case "$root_state" in
  L|LK) root_locked=true ;;
esac
wheel_member=false
if id -nG leonel | tr ' ' '\n' | grep -qx wheel; then
  wheel_member=true
fi
system_state=$(systemctl is-system-running 2>/dev/null || true)
failed_units=$(systemctl --failed --no-legend --plain)
failed_unit_count=$(printf '%s' "$failed_units" | grep -c . || true)
sshd_enabled=$(systemctl is-enabled sshd 2>/dev/null || true)
sshd_state=$(systemctl is-active sshd 2>/dev/null || true)
firewalld_enabled=$(systemctl is-enabled firewalld 2>/dev/null || true)
firewalld_state=$(systemctl is-active firewalld 2>/dev/null || true)
selinux_state=$(getenforce)

firewall_state=$(sudo firewall-cmd --state 2>/dev/null || true)
firewall_check_exit=0
sudo firewall-cmd --check-config >/dev/null 2>&1 || firewall_check_exit=$?
firewall_default_zone=$(sudo firewall-cmd --get-default-zone)
firewall_services=$(sudo firewall-cmd --zone=public --list-services |
  tr ' ' '\n' | sed '/^$/d' | sort | paste -sd, -)
firewall_ports=$(sudo firewall-cmd --zone=public --list-ports |
  tr ' ' '\n' | sed '/^$/d' | sort | paste -sd, -)
firewall_forward=$(sudo firewall-cmd --zone=public --query-forward)

sshd_effective=$(sudo sshd -T)
permit_root_login=$(printf '%s\n' "$sshd_effective" |
  awk '$1=="permitrootlogin" {print $2; exit}')
password_auth=$(printf '%s\n' "$sshd_effective" |
  awk '$1=="passwordauthentication" {print $2; exit}')
pubkey_auth=$(printf '%s\n' "$sshd_effective" |
  awk '$1=="pubkeyauthentication" {print $2; exit}')
tcp22_ipv4=false
tcp22_ipv6=false
if ss -lnt | awk '$4 ~ /^0\.0\.0\.0:22$/ {found=1} END {exit !found}'; then
  tcp22_ipv4=true
fi
if ss -lnt | awk '$4 ~ /^\[::\]:22$/ {found=1} END {exit !found}'; then
  tcp22_ipv6=true
fi

sshd_hash=$(sha256sum /etc/ssh/sshd_config | awk '{print $1}')
selinux_hash=$(sha256sum /etc/selinux/config | awk '{print $1}')
actual_keys=$(rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' | sort)
exact_key_set=false
if test "$actual_keys" = "$expected_keys"; then
  exact_key_set=true
fi

registration_pass=false
if sudo subscription-manager identity >/dev/null 2>&1; then
  registration_pass=true
fi
baseos_repo_enabled=false
if sudo subscription-manager repos --list-enabled 2>/dev/null |
   grep -qE '^Repo ID:[[:space:]]+rhel-10-for-x86_64-baseos-rpms$'; then
  baseos_repo_enabled=true
fi
appstream_repo_enabled=false
if sudo subscription-manager repos --list-enabled 2>/dev/null |
   grep -qE '^Repo ID:[[:space:]]+rhel-10-for-x86_64-appstream-rpms$'; then
  appstream_repo_enabled=true
fi

history_info=$(sudo dnf -q history info 2)
history_return=$(printf '%s\n' "$history_info" |
  sed -n 's/^Return-Code[[:space:]]*:[[:space:]]*//p' | head -1)
history_command=$(printf '%s\n' "$history_info" |
  sed -n 's/^Command Line[[:space:]]*:[[:space:]]*//p' | head -1)

root_source=$(findmnt -n -o SOURCE /)
vg_name=$(sudo vgs --noheadings -o vg_name | xargs)
lv_names=$(sudo lvs --noheadings -o lv_name |
  awk '{$1=$1; print}' | sort | paste -sd, -)

stable_controls_pass=false
if test "$release" = 'Red Hat Enterprise Linux release 10.2 (Coughlan)' && \
   test "$guest_hostname" = q011-rhel01 && \
   test "$root_locked" = true && \
   test "$wheel_member" = true && \
   test "$system_state" = running && \
   test "$failed_unit_count" -eq 0 && \
   test "$sshd_enabled" = enabled && \
   test "$sshd_state" = active && \
   test "$firewalld_enabled" = enabled && \
   test "$firewalld_state" = active && \
   test "$firewall_state" = running && \
   test "$firewall_check_exit" -eq 0 && \
   test "$firewall_default_zone" = public && \
   test "$firewall_services" = cockpit,dhcpv6-client,ssh && \
   test "$firewall_ports" = '' && \
   test "$firewall_forward" = yes && \
   { test "$permit_root_login" = without-password || \
     test "$permit_root_login" = prohibit-password; } && \
   test "$password_auth" = yes && \
   test "$pubkey_auth" = yes && \
   test "$tcp22_ipv4" = true && \
   test "$tcp22_ipv6" = true && \
   test "$selinux_state" = Enforcing && \
   test "$sshd_hash" = "$expected_sshd_hash" && \
   test "$selinux_hash" = "$expected_selinux_hash"; then
  stable_controls_pass=true
fi

expected_changes_pass=false
if test "$running_kernel" = "$expected_kernel" && \
   test "$latest_kernel" = "$expected_kernel" && \
   test "$exact_key_set" = true && \
   test "$registration_pass" = true && \
   test "$baseos_repo_enabled" = true && \
   test "$appstream_repo_enabled" = true && \
   test "$history_return" = Success && \
   test "$history_command" = 'upgrade --refresh' && \
   test "$vg_name" = rhel && \
   test "$lv_names" = home,root,swap && \
   test "$root_source" = /dev/mapper/rhel-root; then
  expected_changes_pass=true
fi

Phase8GuestBaselinePass=false
if test "$stable_controls_pass" = true && \
   test "$expected_changes_pass" = true; then
  Phase8GuestBaselinePass=true
fi

printf 'release=%s\n' "$release"
printf 'hostname=%s\n' "$guest_hostname"
printf 'running_kernel=%s\n' "$running_kernel"
printf 'latest_installed_kernel=%s\n' "$latest_kernel"
rpm -q openssh-server firewalld policycoreutils selinux-policy-targeted
printf 'root_state=%s\n' "$root_state"
printf 'root_locked=%s\n' "$root_locked"
printf 'leonel_wheel_member=%s\n' "$wheel_member"
printf 'system_state=%s\n' "$system_state"
printf 'failed_unit_count=%s\n' "$failed_unit_count"
printf 'sshd_enabled=%s\n' "$sshd_enabled"
printf 'sshd_state=%s\n' "$sshd_state"
printf 'firewalld_enabled=%s\n' "$firewalld_enabled"
printf 'firewalld_state=%s\n' "$firewalld_state"
printf 'firewall_state=%s\n' "$firewall_state"
printf 'firewall_check_exit=%s\n' "$firewall_check_exit"
printf 'firewall_default_zone=%s\n' "$firewall_default_zone"
printf 'firewall_services=%s\n' "$firewall_services"
printf 'firewall_ports=%s\n' "$firewall_ports"
printf 'firewall_forward=%s\n' "$firewall_forward"
printf 'permit_root_login=%s\n' "$permit_root_login"
printf 'password_authentication=%s\n' "$password_auth"
printf 'pubkey_authentication=%s\n' "$pubkey_auth"
printf 'tcp22_ipv4_listening=%s\n' "$tcp22_ipv4"
printf 'tcp22_ipv6_listening=%s\n' "$tcp22_ipv6"
printf 'selinux_state=%s\n' "$selinux_state"
printf 'sshd_config_sha256=%s\n' "$sshd_hash"
printf 'selinux_config_sha256=%s\n' "$selinux_hash"
printf 'exact_key_set=%s\n' "$exact_key_set"
printf 'registration_pass=%s\n' "$registration_pass"
printf 'baseos_repo_enabled=%s\n' "$baseos_repo_enabled"
printf 'appstream_repo_enabled=%s\n' "$appstream_repo_enabled"
printf 'history_id=2\n'
printf 'history_return_code=%s\n' "$history_return"
printf 'history_command=%s\n' "$history_command"
printf 'volume_group=%s\n' "$vg_name"
printf 'logical_volumes=%s\n' "$lv_names"
printf 'root_filesystem=%s\n' "$root_source"
printf 'stable_controls_pass=%s\n' "$stable_controls_pass"
printf 'expected_changes_pass=%s\n' "$expected_changes_pass"
printf 'Phase8GuestBaselinePass=%s\n' "$Phase8GuestBaselinePass"
```

Stop unless `Phase8GuestBaselinePass=true`. Phase 5 recorded root token `L`
and effective SSH token `without-password`; the gate accepts `L`/`LK` as the
same locked-root state and `without-password`/`prohibit-password` as the same
OpenSSH no-password-root policy. DNF history command
`upgrade --refresh` remains an exact expectation because Phase 7P recorded
that literal value. Do not repair a failed control in this window. Retain
package versions as post-patch facts, not as proof that every installed
package is current forever.

## Phase 8D — Comparison And Manual Rebuild Record

Repository evidence intake after the live window must compare Phase 8 output
with the Phase 5 before-state using these classifications:

| Area | Phase 5 | Required Phase 8 disposition |
|---|---|---|
| Release and hostname | RHEL 10.2; `q011-rhel01` | Unchanged |
| Root and administrator | root `L`; `leonel` in `wheel` | Unchanged |
| SELinux | Enforcing; config hash recorded | Enforcing and identical config hash |
| OpenSSH | enabled/active; effective policy and config hash recorded | Same policy/hash; package version may advance |
| firewalld | enabled/active; public zone, services, ports, forwarding recorded | Same policy; package version may advance |
| Health | running; zero failed units | Unchanged |
| LVM | VG `rhel`; `home,root,swap`; root mapper path | Unchanged |
| Network | corrected but nonreserved DHCP lease | Intended change: reserved `.140` and autoconnect |
| Registration | false | Intended change: true; BaseOS/AppStream enabled |
| RPM trust | not yet established | Intended change: exact three packaged certificates |
| Kernel/history | original kernel; original transaction `1` | Intended change: `.37.1` running/latest; transaction `2` success |

The manual rebuild record must cite, rather than silently reinterpret, the
existing evidence for:

- Hyper-V Generation 2, 2 vCPU, 6 GiB static RAM, one 60-GiB dynamic VHDX;
- Microsoft UEFI Certificate Authority Secure Boot;
- automatic checkpoints disabled and Automatic Start Action `Nothing`;
- one adapter initially Not Connected and Untagged VLAN 0;
- exact ISO filename, 11,059,986,432 bytes, and published/matching SHA-256;
- Minimal Install, automatic LVM, hostname `q011-rhel01`, locked root, local
  `leonel` administrator, no installation-time registration, and networking
  Off;
- the later approved VLAN 70 reservation/autoconnect sequence;
- interactive Red Hat registration without retained identity or credentials;
- the exact three-certificate RPM trust repair; and
- one successful `upgrade --refresh` transaction and final kernel.

This repository-only rebuild section needs no screenshot: a picture of
Markdown is not proof of a rebuild. The cited hands-on installation,
configuration, trust, patch, and validation images are the evidence.

## Phase 8E — Normal Shutdown And Final Isolation

From the guest:

```bash
sudo systemctl poweroff
```

Then run in elevated PowerShell on `WIN-PRQD8TJG04M`:

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

    $Vm = Get-VM -Name $VmName
    if ($Vm.State -ne 'Off') {
        Disconnect-VMNetworkAdapter -VMName $VmName
        Set-VMNetworkAdapterVlan -VMName $VmName -Untagged
        throw (
            'Q011 did not shut down within three minutes. Its adapter was ' +
            'contained; forced power-off requires separate approval.'
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
    $Disconnected = (
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName)
    )
    $DvdEmpty = (
        $Dvd.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($Dvd[0].Path)
    )

    $Phase8EndStatePass = (
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        $Disconnected -and
        $Vlan.OperationMode -eq 'Untagged' -and
        $Vlan.AccessVlanId -eq 0 -and
        $Dvd.Count -eq 1 -and
        $DvdEmpty -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing'
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        VmName                = $Vm.Name
        State                 = $Vm.State
        AdapterCount          = $Adapters.Count
        Disconnected          = $Disconnected
        OperationMode         = $Vlan.OperationMode
        AccessVlanId          = $Vlan.AccessVlanId
        DvdEmpty              = $DvdEmpty
        SnapshotCount         = $Snapshots.Count
        AutomaticCheckpoints  = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction  = $Vm.AutomaticStartAction
        Phase8EndStatePass    = $Phase8EndStatePass
    } | Format-List

    if (-not $Phase8EndStatePass) {
        throw 'Q011 Phase 8 final isolation verification failed.'
    }
}
```

Phase 8 success requires `Phase8PreflightPass=True`,
`Phase8AttachmentPass=True`, `Phase8GuestBaselinePass=true`, a completed
comparison/rebuild record, and `Phase8EndStatePass=True`.

## Screenshot Result

Leonel captured only actual hands-on state, with credential prompts and
unrelated content excluded:

1. `q011-phase8-01-postpatch-control-baseline.png` — release, hostname,
   running/latest kernel, core health, SELinux, root/wheel, service state, and
   `stable_controls_pass=true`.
2. `q011-phase8-02-trust-history-storage-validation.png` — exact trust,
   registration/repositories, history transaction `2`, LVM, expected changes,
   and `Phase8GuestBaselinePass=true`.
3. `q011-phase8-03-safe-end-state.png` — Off, disconnected, Untagged VLAN 0,
   DVD-empty, checkpoint-free state and `Phase8EndStatePass=True`.

The project README displays the first and third images. The
[visual walkthrough](../evidence/q011-phase8-visual-walkthrough.md) uses all
three, and the
[screenshot manifest](../evidence/q011-phase8-screenshots.sha256) records
their exact hashes. No retained image contains a password or sudo prompt,
consumer UUID, organization value, token, full repository URL, authenticated
URL, or unrelated VM inventory.

## Stop Conditions

Stop and use the paired containment plan if:

- a host, attachment, DHCP, SSH, stable-control, expected-change, or final
  isolation gate fails;
- the guest requires manual `nmcli` activation;
- another DHCP authority or address appears;
- a command proposes or performs a package/configuration change;
- a credential or Red Hat identity value would be retained;
- normal shutdown times out; or
- another VM, host task, switch, backup, or network object becomes involved.

## Historical Approval Statement

This stored text records the completed approval and is not authority to repeat
it:

> I approve Q011 Phase 8 only on WIN-PRQD8TJG04M and
> Q011-RHEL102-BASELINE: execute the reviewed Phase 8 run sheet exactly as
> documented. Run the fresh host preflight; keep the conflicting ASA Off;
> temporarily attach only Q011 to vSwitch-LAN as Access VLAN 70; start only
> Q011; require automatic reserved DHCP at 192.168.70.140 from and through
> 192.168.70.1; permit one interactive Windows 11 SSH login as leonel; run
> only the documented read-only post-patch control, trust, history, storage,
> registration, repository, service, policy, hash, and health checks; capture
> the planned safe screenshots; shut down normally; disconnect only Q011;
> restore Untagged VLAN 0; and require Phase8EndStatePass=True. Preserve the
> manual rebuild record locally from existing and newly approved evidence.
> Do not run any DNF command other than the exact read-only
> `dnf -q history info 2` lookup; do not run a package transaction or metadata
> refresh/check; change a package, key, cache, repository, service, firewall,
> SELinux setting, account, NetworkManager profile, DHCP or OPNsense object,
> VM/VHDX/DVD/checkpoint/export/backup, another VM, switch, host, or network
> object; or perform Git/GitHub operations. Follow the paired containment
> plan on any stop condition. No other action is approved.

## Success And Next Boundary

Phase 8 passed. Required controls survived the supported patch; the expected
registration, trust, network, kernel, history, and package-version changes are
attributable; the [manual rebuild record](q011-manual-rebuild-record.md) is
evidence-linked; and `Phase8EndStatePass=True` restored exact isolation.

The initial SSH hash collection omitted `sudo` and returned an empty value.
The narrow retry proved the current hash matched the original Phase 5
screenshot, exposing a two-character transcription error in the text record.
Codex corrected only that local text and expected value; no guest state
changed. See the [execution evidence](../evidence/q011-phase8-evidence.md),
[searchable results](../evidence/q011-phase8-sanitized-results.txt),
[visual walkthrough](../evidence/q011-phase8-visual-walkthrough.md), and
[screenshot manifest](../evidence/q011-phase8-screenshots.sha256).

Phase 8 does not prove backup/restore, hardened SSH policy, production
readiness, or an actually replayed rebuild. Phase 9 retention or disposal
remains a separate approval.
