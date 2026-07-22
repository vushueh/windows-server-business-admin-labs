# Q011 Phase 6 — Controlled Network And RHEL Registration Change Window

**Executed:** 2026-07-20 (household impact: none observed)  
**Approved by Leonel:** approved in chat as Phase 6A–6E, then extended by
separate Phase 6C-R and Phase 6C-A approvals  
**Executor:** Leonel, manually and supervised  
**Systems touched:** `WIN-PRQD8TJG04M`, `Q011-RHEL102-BASELINE`, existing
`vSwitch-LAN` access path for VLAN 70, existing OPNsense VLAN 70 DHCP service,
and Red Hat Subscription Management

## Objective

Temporarily connect only Q011 to the already-proved OPNsense VLAN 70 path,
register RHEL 10.2 interactively, prove the enabled BaseOS and AppStream
repositories without installing or updating anything, then return the VM to
Off, disconnected, untagged, DVD-empty, checkpoint-free state.

The initial Phase 6 approval deliberately excluded persistent addressing.
After the correct dynamic lease and SSH path passed, Leonel separately
approved one Dnsmasq reservation and one existing-profile autoconnect change.
The final result therefore retains a persistent DHCP identity without a guest
static address.

## Execution Outcome And Approved Extensions

Phase 6A and 6B passed the fresh safe-state gate, Access VLAN 70 attachment,
OPNsense DHCP authority, and Windows 11 SSH proof. The guest received
`192.168.70.140/24`, with DHCP server, gateway, and DNS `192.168.70.1`.

Phase 6C-R proved the Dnsmasq Hosts table was empty and the active lease
belonged to MAC `00:15:5d:14:0b:3e`, then created only the approved
`q011-rhel01` reservation. The first reboot showed link but no IPv4 address
until manual profile activation. Phase 6C-A then proved
`connection.autoconnect=no` and changed only that field to `yes`; a second
normal reboot returned the reserved address and working SSH without manual
activation.

Phase 6D registered interactively and returned only Boolean evidence that
registration, BaseOS, AppStream, and the combined gate passed. Phase 6E shut
down normally and returned `Phase6EndStatePass=True`. No package transaction
ran. The complete evidence is in
[the Phase 6 record](../evidence/q011-phase6-evidence.md).

## Current Decision And Preconditions

- Phase 5 passed and ended with `Phase5EndStatePass=True`.
- The only approved guest is `Q011-RHEL102-BASELINE`.
- The conflicting legacy ASA DHCP authority must remain powered off for the
  entire window.
- A valid lease is only `192.168.70.100` through `192.168.70.200`, with DHCP
  server and gateway both `192.168.70.1`.
- The existing `eth0` NetworkManager profile was initially activated without
  modification; `connection.autoconnect=yes` was later approved separately.
- Credentials are entered only in the interactive registration prompt. They
  are never placed in a command, variable, transcript, screenshot, or file.
- No update, package installation, firewall change, SSH change, DHCP-range or
  option change, switch change, or checkpoint was part of Phase 6. The one
  host reservation and autoconnect field are the only persistent changes.

## Retained Future Approval Text

The following block is a template. It is not active authority merely because
it is stored here:

> I approve Q011 Phase 6 only on WIN-PRQD8TJG04M: run the documented fresh
> preflight and stop unless Phase6PreflightPass=True; keep the conflicting ASA
> powered off; set only Q011-RHEL102-BASELINE's existing adapter to access VLAN
> 70 on vSwitch-LAN, start only that VM, and activate only its existing eth0
> profile. Require a DHCP address from 192.168.70.100-192.168.70.200 with DHCP
> server and gateway 192.168.70.1, then permit one interactive SSH login as
> leonel. Run sudo subscription-manager register interactively without putting
> credentials in a command or retained evidence; verify registration identity
> only as a pass/fail result and require the RHEL 10 x86_64 BaseOS and AppStream
> repositories to be enabled. Do not install, update, or remove a package;
> change DHCP, NetworkManager, SSH, firewalld, SELinux, an account, switch,
> another VM, or host setting; create a reservation or checkpoint; or expose a
> credential, consumer UUID, organization ID, token, or authenticated URL.
> Capture only the planned safe screenshots, shut down Q011 normally, disconnect
> only its adapter, restore it to Untagged VLAN 0, and require
> Phase6EndStatePass=True. If DHCP, SSH, registration, or repository validation
> fails, use the documented Phase 6 rollback. No other action is approved.

## Stop Conditions

Stop without registering, or start rollback if:

- the fresh preflight is false or the ASA cannot be confirmed Off;
- the lease, DHCP server, or gateway is outside the required values;
- `eth0` would need profile creation or modification;
- TCP 22 or interactive `leonel` SSH login fails;
- registration fails twice or exposes secret material;
- BaseOS or AppStream is absent after one registration refresh;
- a command would install, update, remove, or repair a package; or
- another VM, network object, host setting, backup, or maintenance operation
  becomes involved.

## Pre-checks — Run First On The Hyper-V Host

Run the complete block in elevated Windows PowerShell directly on
`WIN-PRQD8TJG04M`. Paste the block before responding to `Read-Host`.

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $TargetSwitch = 'vSwitch-LAN'

    $IsAdmin = (
        [Security.Principal.WindowsPrincipal]::new(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )
    ).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
    $Dvd = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $Switch = Get-VMSwitch -Name $TargetSwitch

    $NoCompetingWorkConfirmed = (
        Read-Host (
            'Type NO-COMPETING-WORK only after confirming no backup, ' +
            'maintenance, storage, Hyper-V, or other Q011 work is active'
        )
    ) -ceq 'NO-COMPETING-WORK'

    $AsaOffConfirmed = (
        Read-Host (
            'Type ASA-OFF only after confirming the conflicting legacy ' +
            'VLAN 70 ASA remains powered off'
        )
    ) -ceq 'ASA-OFF'

    $Phase6PreflightPass = (
        $env:COMPUTERNAME -eq $ExpectedHost -and
        $IsAdmin -and
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
        $NoCompetingWorkConfirmed -and
        $AsaOffConfirmed
    )

    [pscustomobject]@{
        ComputerName             = $env:COMPUTERNAME
        VmName                   = $Vm.Name
        State                    = $Vm.State
        AdapterCount             = $Adapters.Count
        SwitchName               = $Adapters[0].SwitchName
        OperationMode            = $Vlan.OperationMode
        AccessVlanId             = $Vlan.AccessVlanId
        DvdEmpty                 = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
        SnapshotCount            = $Snapshots.Count
        TargetSwitch             = $Switch.Name
        TargetSwitchType         = $Switch.SwitchType
        NoCompetingWorkConfirmed = $NoCompetingWorkConfirmed
        AsaOffConfirmed          = $AsaOffConfirmed
        Phase6PreflightPass      = $Phase6PreflightPass
    } | Format-List

    if (-not $Phase6PreflightPass) {
        throw 'Q011 Phase 6 preflight failed; no change is authorized.'
    }
}
```

Do not continue unless `Phase6PreflightPass=True`.

## Backup Taken

| What | How | Where stored | Verified restorable? |
|---|---|---|---|
| Pre-registration configuration record | Phase 5 service, hash, registration, LVM, and final-host evidence | Q011 `evidence/` | No; evidence is not a backup |
| Registration reversal | Red Hat-supported `subscription-manager unregister` | Guest command path | Documented |
| Network reversal | Disconnect Q011 and restore Untagged VLAN 0 | Exact commands below | Proved in Phase 5 |

No Hyper-V checkpoint is created. Registration can be reversed through the
paired plan if the window fails before acceptance. The accepted final state
also retains one DHCP reservation and `connection.autoconnect=yes`; neither is
rolled back after a successful Phase 6.

## Implementation Steps

### 1. Attach And Start Only Q011

On the Hyper-V host:

```powershell
$VmName = 'Q011-RHEL102-BASELINE'

Set-VMNetworkAdapterVlan -VMName $VmName -Access -VlanId 70
Connect-VMNetworkAdapter -VMName $VmName -SwitchName 'vSwitch-LAN'
Start-VM -Name $VmName

Get-VM -Name $VmName | Select-Object Name,State
Get-VMNetworkAdapter -VMName $VmName |
    Select-Object VMName,SwitchName,Status
Get-VMNetworkAdapterVlan -VMName $VmName |
    Select-Object VMName,OperationMode,AccessVlanId
```

Require `Running`, `vSwitch-LAN`, `Access`, and VLAN `70`.

### 2. Activate The Existing Profile And Prove DHCP Authority

In VMConnect, log in locally as `leonel` and run only:

```bash
sudo nmcli connection up eth0
nmcli -g IP4.ADDRESS,IP4.GATEWAY device show eth0
nmcli -f DHCP4 device show eth0
```

Require one address in `192.168.70.100-192.168.70.200` and both DHCP server
and gateway `192.168.70.1`. Any other value triggers rollback.

### 3. Prove Interactive SSH From The Windows 11 Workstation

From the workstation PowerShell window that proved the path in Phase 5:

```powershell
ssh leonel@<Q011-DHCP-ADDRESS>
```

Inside the SSH session:

```bash
whoami
hostname
```

Require `leonel` and `q011-rhel01`. Do not capture the password prompt.

### 4. Register Interactively Without Recording Credentials

Confirm the expected unregistered before-state without displaying identity
details:

```bash
sudo subscription-manager identity >/dev/null 2>&1
printf 'identity_before_exit=%s\n' "$?"
```

Then run:

```bash
sudo subscription-manager register
```

Enter the Red Hat Customer Portal username and password only when prompted.
Never use `--username`, `--password`, variables, transcript capture, or a
screenshot. Make at most two interactive attempts.

### 5. Verify Registration And Repositories Without Identity Values

```bash
sudo subscription-manager identity >/dev/null 2>&1
identity_exit=$?
sudo subscription-manager refresh >/dev/null 2>&1
refresh_exit=$?

repo_ids="$(sudo subscription-manager repos --list-enabled 2>/dev/null |
  awk -F: '/^[[:space:]]*Repo ID:/ {
    gsub(/^[[:space:]]+/, "", $2); print $2
  }')"

printf '%s\n' "$repo_ids"

baseos_pass=false
appstream_pass=false
grep -qx 'rhel-10-for-x86_64-baseos-rpms' <<<"$repo_ids" && baseos_pass=true
grep -qx 'rhel-10-for-x86_64-appstream-rpms' <<<"$repo_ids" && appstream_pass=true

phase6_registration_pass=false
if [ "$identity_exit" -eq 0 ] && [ "$refresh_exit" -eq 0 ] &&
   [ "$baseos_pass" = true ] && [ "$appstream_pass" = true ]; then
  phase6_registration_pass=true
fi

printf 'identity_pass=%s\n' "$([ "$identity_exit" -eq 0 ] && echo true || echo false)"
printf 'refresh_pass=%s\n' "$([ "$refresh_exit" -eq 0 ] && echo true || echo false)"
printf 'baseos_enabled=%s\n' "$baseos_pass"
printf 'appstream_enabled=%s\n' "$appstream_pass"
printf 'Phase6RegistrationPass=%s\n' "$phase6_registration_pass"
```

Do not run `dnf update`, `dnf upgrade`, `dnf install`, or
`dnf makecache`. Raw identity output, consumer UUID, organization data,
username, tokens, certificates, and authenticated URLs are not evidence.

### 6. Capture Safe Hands-On Evidence

1. `q011-phase6-01-registration-repositories-pass.png` — the sanitized
   five-line registration/repository result plus `hostname`.
2. `q011-phase6-02-offline-end-state.png` — the final host result below.

### 7. Shut Down Normally And Restore The Safe Network State

From Q011:

```bash
sudo systemctl poweroff
```

After Hyper-V reports `Off`, run on the Hyper-V host:

```powershell
$VmName = 'Q011-RHEL102-BASELINE'

Disconnect-VMNetworkAdapter -VMName $VmName
Set-VMNetworkAdapterVlan -VMName $VmName -Untagged

$Vm = Get-VM -Name $VmName
$Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
$Vlan = Get-VMNetworkAdapterVlan -VMName $VmName
$Dvd = @(Get-VMDvdDrive -VMName $VmName)
$Snapshots = @(Get-VMSnapshot -VMName $VmName)

$Phase6EndStatePass = (
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
    ComputerName         = $env:COMPUTERNAME
    VmName               = $Vm.Name
    State                = $Vm.State
    AdapterCount         = $Adapters.Count
    Disconnected         = [string]::IsNullOrWhiteSpace($Adapters[0].SwitchName)
    AccessVlanId         = $Vlan.AccessVlanId
    DvdEmpty             = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
    SnapshotCount        = $Snapshots.Count
    AutomaticCheckpoints = $Vm.AutomaticCheckpointsEnabled
    AutomaticStartAction = $Vm.AutomaticStartAction
    Phase6EndStatePass   = $Phase6EndStatePass
} | Format-List

if (-not $Phase6EndStatePass) {
    throw 'Q011 Phase 6 final safe-state verification failed.'
}
```

## Validation — Must All Pass

- `Phase6PreflightPass=True`.
- Correct OPNsense lease, DHCP server, and gateway.
- One interactive SSH login proves `leonel@q011-rhel01`.
- `Phase6RegistrationPass=true`.
- BaseOS and AppStream repository IDs are enabled.
- No package transaction runs.
- Both planned screenshots are captured.
- `Phase6EndStatePass=True`.

## Rollback Plan

Use the paired
[Phase 6 rollback plan](q011-phase6-network-registration-rollback.md). Any
failed network, SSH, registration, repository, secret-handling, or end-state
check triggers rollback.

## Outcome

**Result:** passed — `Phase6PreflightPass=True`, correct OPNsense DHCP and SSH,
automatic reserved-address persistence after one approved correction,
`Phase6DPass=True`, and `Phase6EndStatePass=True`  
**Evidence:** [Phase 6 evidence](../evidence/q011-phase6-evidence.md),
[searchable results](../evidence/q011-phase6-sanitized-results.txt),
[visual walkthrough](../evidence/q011-phase6-visual-walkthrough.md), and
[screenshot manifest](../evidence/q011-phase6-screenshots.sha256)  
**Docs updated:** 2026-07-20  
**Review item closed/raised:** no unresolved live defect; Phase 7 remains a
separate approval gate

## Authoritative References

- [Red Hat RHEL 10 registration guidance](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/automatically_installing_rhel/registering-your-rhel-system)
- [Red Hat RHEL 10 subscription-service rollback](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/interactively_installing_rhel_from_installation_media/changing-a-subscription-service)
