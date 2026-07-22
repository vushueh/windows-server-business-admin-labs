# Q011 Phase 5 — Disconnected Service Baseline Run Sheet

**Prepared:** 2026-07-19  
**Executed:** 2026-07-20  
**Mode:** completed `HANDS-ON` baseline with separately approved Phase 5N
network-diagnosis extensions  
**Target host:** `WIN-PRQD8TJG04M`  
**Target VM:** `Q011-RHEL102-BASELINE`  
**Current state:** Phase 5 passed; VM Off, one adapter Not connected and
Untagged at VLAN 0, DVD empty, zero checkpoints  
**Purpose:** measure the unpatched local OpenSSH, firewalld, SELinux, service,
listener, package, and configuration baseline before any network or patching
design

This preserved run sheet is not continuing approval to start the VM. It
authorized no package,
service, firewall, SSH, SELinux, registration, repository, network, checkpoint,
or configuration change. A finding is recorded for the next phase; it is not
repaired here.

## Execution Outcome And Approved Variance

The original disconnected baseline passed. Later, separately approved Phase 5N
windows temporarily superseded only the disconnected-network restriction to
identify the unexpected VLAN 70 DHCP authority and prove a bounded SSH path.
Every failed attempt restored disconnected VLAN 0.

The first fresh lease was `172.16.70.52/24` from legacy authority
`172.16.70.1`. After Leonel confirmed the legacy ASA was powered off, the
existing `eth0` profile received `192.168.70.140/24` from OPNsense
`192.168.70.1`. Windows 11 completed interactive SSH as `leonel` and
proved `q011-rhel01`. The lease is dynamic and is not persistent evidence.

The final host verification returned `Phase5EndStatePass=True`. Exact
outputs, limitations, screenshots, and hashes are retained in:

- [Phase 5 evidence](../evidence/q011-phase5-evidence.md)
- [searchable sanitized results](../evidence/q011-phase5-sanitized-results.txt)
- [visual walkthrough](../evidence/q011-phase5-visual-walkthrough.md)
- [screenshot manifest](../evidence/q011-phase5-screenshots.sha256)

## Why Phase 5 Stays Disconnected

Q011 must eventually prove a patched baseline plus SSH, firewalld, and SELinux
tests. The installed guest is currently unregistered and deliberately has no
network path. Phase 5 captures the clean local before-state first so a later
network/registration/patch window can compare against attributable evidence.

No switch, VLAN, DHCP, DNS, gateway, repository, subscription, activation key,
or credential is needed for this phase.

## Retained Future Approval Text

The following text is a template, not active authority merely because it is
stored here:

> I approve Q011 Phase 5 only on WIN-PRQD8TJG04M: run the documented fresh
> read-only preflight and stop unless Phase5PreflightPass=True; then use
> VMConnect to start only Q011-RHEL102-BASELINE while its one adapter remains
> Not connected and its DVD remains empty. Log in locally as leonel, collect
> only the documented read-only release, hostname, SELinux, root-lock, wheel,
> system-health, package, OpenSSH, firewalld, listener, configuration-hash,
> registration, LVM, and offline-network baseline, and capture the planned
> safe screenshots. Do not use VMConnect clipboard injection. Do not change a
> package, service, firewall rule, SSH setting, SELinux setting, account,
> subscription, repository, file, VM, VHDX, DVD, network, or checkpoint. Shut
> down normally and require Phase5EndStatePass=True. No other action is
> approved.

## Stop Conditions

Stop before power-on if the preflight fails. After start, stop and preserve the
guest if:

- the console title is not the exact Q011 VM;
- the DVD contains media or the Hyper-V adapter is connected;
- the release is not RHEL 10.2 or the hostname is not `q011-rhel01`;
- root has a usable password rather than locked status `L` or `LK`;
- `leonel` is not in `wheel`, SELinux is not Enforcing, the system is not
  running, or a failed unit appears;
- a non-loopback address, route, or connected interface appears;
- a command would need a missing package, configuration change, registration,
  or network access to continue;
- VMConnect clipboard injection is attempted; or
- another Hyper-V, storage, backup, or maintenance operation begins.

An inactive or disabled `sshd` or `firewalld`, a missing baseline package, or
an unexpected effective setting is a Phase 5 finding. Do not repair it inside
this read-only window.

## Step 1 — Fresh Host And VM Preflight

Run the complete block in elevated Windows PowerShell directly on
`WIN-PRQD8TJG04M`. Paste the whole block before responding to `Read-Host`.
Manually type the ASCII phrase only at the final question, never at a `>>`
continuation prompt.

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdPath = 'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'
    $MemoryFloor = [int64]12GB
    $DriveFloor = [int64]100GB

    $IsAdmin = (
        [Security.Principal.WindowsPrincipal]::new(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )
    ).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }
    if (-not $IsAdmin) {
        throw 'Run this preflight in elevated Windows PowerShell.'
    }

    $Vmms = Get-Service -Name vmms
    $Vm = Get-VM -Name $VmName
    $Processor = Get-VMProcessor -VMName $VmName
    $Memory = Get-VMMemory -VMName $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $Vhd = Get-VHD -Path $VhdPath
    $OperatingSystem = Get-CimInstance Win32_OperatingSystem
    $FreeMemoryBytes = [int64]$OperatingSystem.FreePhysicalMemory * 1KB
    $DVolume = Get-Volume -DriveLetter D
    $CpuLoad = [double](
        Get-CimInstance Win32_Processor |
            Measure-Object -Property LoadPercentage -Average
    ).Average

    $TransitionStates = @(
        'Starting','Stopping','Saving','Pausing','Resuming','Restoring'
    )
    $TransitioningVmCount = @(
        Get-VM | Where-Object {
            $_.State.ToString() -in $TransitionStates
        }
    ).Count

    $NoCompetingWorkConfirmed = (
        Read-Host (
            'After checking the host, type NO-COMPETING-WORK only if no ' +
            'backup, maintenance, storage task, or other Hyper-V/Q011 ' +
            'operation is active'
        )
    ) -ceq 'NO-COMPETING-WORK'

    # Re-read exact state after the operator confirmation.
    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $SwitchName = if ($Adapters.Count -eq 1) {
        $Adapters[0].SwitchName
    }

    $Phase5PreflightPass = (
        $Vmms.Status -eq 'Running' -and
        $Vm.State -eq 'Off' -and
        $Vm.Generation -eq 2 -and
        $Processor.Count -eq 2 -and
        -not $Memory.DynamicMemoryEnabled -and
        $Memory.Startup -eq 6GB -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($SwitchName) -and
        $HardDisks.Count -eq 1 -and
        $HardDisks[0].Path -eq $VhdPath -and
        $Vhd.VhdType -eq 'Dynamic' -and
        $Vhd.Size -eq 60GB -and
        $DvdDrives.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($DvdDrives[0].Path) -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing' -and
        $FreeMemoryBytes -ge $MemoryFloor -and
        $DVolume.SizeRemaining -ge $DriveFloor -and
        $CpuLoad -le 70 -and
        $TransitioningVmCount -eq 0 -and
        $NoCompetingWorkConfirmed
    )

    [pscustomobject]@{
        ComputerName              = $env:COMPUTERNAME
        VmName                    = $Vm.Name
        State                     = $Vm.State
        Generation                = $Vm.Generation
        ProcessorCount            = $Processor.Count
        StartupMemoryGiB          = $Memory.Startup / 1GB
        DynamicMemoryEnabled      = $Memory.DynamicMemoryEnabled
        Disconnected              = [string]::IsNullOrWhiteSpace($SwitchName)
        VhdVirtualSizeGiB         = $Vhd.Size / 1GB
        DvdEmpty                  = [string]::IsNullOrWhiteSpace(
            $DvdDrives[0].Path
        )
        SnapshotCount             = $Snapshots.Count
        AutomaticCheckpoints      = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction      = $Vm.AutomaticStartAction
        FreeMemoryGiB             = [math]::Round(
            $FreeMemoryBytes / 1GB, 1
        )
        DFreeGiB                  = [math]::Round(
            $DVolume.SizeRemaining / 1GB, 1
        )
        CpuLoadPercent            = [math]::Round($CpuLoad, 1)
        TransitioningVmCount      = $TransitioningVmCount
        NoCompetingWorkConfirmed  = $NoCompetingWorkConfirmed
        Phase5PreflightPass       = $Phase5PreflightPass
    } | Format-List

    if (-not $Phase5PreflightPass) {
        throw 'Q011 Phase 5 preflight failed; do not start the VM.'
    }
}
```

Phase 5 uses a 12-GiB free-memory floor because it boots the installed 6-GiB
guest only for read-only inspection; Phase 4C retained the higher 16-GiB floor
for the first boot and installer workload. This deliberate difference is not a
capacity-policy change for another VM.

Stop and return the structured output. Do not start unless
`Phase5PreflightPass=True`.

## Step 2 — Start Only The Disconnected Q011 Guest

1. Open **Server Manager -> Tools -> Hyper-V Manager**.
2. Select local host `WIN-PRQD8TJG04M` and only
   `Q011-RHEL102-BASELINE`.
3. Confirm the state is **Off**, then select **Connect**.
4. Confirm the VMConnect title names only the Q011 VM.
5. Select **Action -> Start** and wait for the `q011-rhel01` login prompt.
6. Log in locally as `leonel`, run `sudo -v`, enter the local password
   privately, and run `clear`.

Do not use **Clipboard -> Type clipboard text**. Phase 4C proved that this path
does not reliably translate the required keycodes. Type the following short
commands manually, one line at a time.

## Step 3 — Core Identity, Health, And Package Baseline

```bash
cat /etc/redhat-release
hostnamectl --static
getenforce
sudo passwd -S root
id leonel
systemctl is-system-running
systemctl --failed --no-legend --plain
rpm -q openssh-server firewalld policycoreutils selinux-policy-targeted
```

Hard gates are RHEL 10.2, `q011-rhel01`, SELinux Enforcing, root state `L` or
`LK`, `leonel` in `wheel`, system state `running`, and no failed-unit rows.
Record package versions exactly. Do not install a missing package.

After `clear`, rerun only the safe core lines needed for the first screenshot
and capture:

`q011-phase5-01-rhel-service-baseline.png`

The image must show the Q011 VMConnect title, no password prompt, no credential
value, and no unrelated host content.

## Step 4 — OpenSSH, Firewalld, SELinux, And Listener Baseline

Run each line manually:

```bash
systemctl is-enabled sshd firewalld
systemctl is-active sshd firewalld
sudo firewall-cmd --state
sudo firewall-cmd --check-config
sudo firewall-cmd --get-default-zone
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all
sudo /usr/sbin/sshd -T | grep '^permitrootlogin '
sudo /usr/sbin/sshd -T | grep '^passwordauthentication '
sudo /usr/sbin/sshd -T | grep '^pubkeyauthentication '
sudo ss -lntup
sestatus
sudo sha256sum /etc/ssh/sshd_config /etc/selinux/config
```

These commands observe effective state. They do not authorize `systemctl
enable`, `systemctl start`, `firewall-cmd` changes, `sshd_config` edits,
`setsebool`, `semanage`, or package installation.

After `clear`, rerun the shortest firewalld and OpenSSH lines that show the
observed service state and capture:

`q011-phase5-02-firewall-ssh-baseline.png`

If the output is too long for one safe frame, keep the first image as primary
and store a second supporting capture in the later Phase 5 evidence
walkthrough. Never omit a surprising result merely to make the screenshot
look cleaner.

## Step 5 — Re-Prove Isolation, Storage, And Registration

```bash
ip -br address
ip route
nmcli device status
sudo pvs
sudo vgs
sudo lvs
findmnt /
sudo test ! -s /etc/pki/consumer/cert.pem
echo CertificateAbsentExit=$?
sudo subscription-manager identity
```

The isolation gate requires only loopback addressing, no route, and no active
non-loopback device. `CertificateAbsentExit=0` and an unregistered identity
must remain true. Do not register the system or contact a repository.

Retain one optional supporting screenshot as
`q011-phase5-process-01-offline-network-recheck.png` when the network output is
clean and contains no credential prompt. It belongs in a linked walkthrough,
not as a third README image.

## Step 6 — Normal Shutdown And Host End-State Proof

After all read-only results are captured, run:

```bash
sudo systemctl poweroff
```

Do not use Hyper-V **Turn Off** during normal closeout. After VMConnect reports
the stop, run this block in elevated Windows PowerShell:

```powershell
& {
    $ErrorActionPreference = 'Stop'

    $ExpectedHost = 'WIN-PRQD8TJG04M'
    $VmName = 'Q011-RHEL102-BASELINE'
    $VhdPath = 'D:\Hyper-V\Virtual Hard Disks\Q011-RHEL102-BASELINE.vhdx'

    if ($env:COMPUTERNAME -ne $ExpectedHost) {
        throw "Wrong host. Expected $ExpectedHost."
    }

    $Deadline = (Get-Date).AddMinutes(3)
    do {
        $Vm = Get-VM -Name $VmName
        if ($Vm.State -eq 'Off') {
            break
        }
        Start-Sleep -Seconds 2
    } while ((Get-Date) -lt $Deadline)

    $Vm = Get-VM -Name $VmName
    $Adapters = @(Get-VMNetworkAdapter -VMName $VmName)
    $HardDisks = @(Get-VMHardDiskDrive -VMName $VmName)
    $DvdDrives = @(Get-VMDvdDrive -VMName $VmName)
    $Snapshots = @(Get-VMSnapshot -VMName $VmName)
    $SwitchName = if ($Adapters.Count -eq 1) {
        $Adapters[0].SwitchName
    }

    $Phase5EndStatePass = (
        $Vm.State -eq 'Off' -and
        $Adapters.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($SwitchName) -and
        $HardDisks.Count -eq 1 -and
        $HardDisks[0].Path -eq $VhdPath -and
        $DvdDrives.Count -eq 1 -and
        [string]::IsNullOrWhiteSpace($DvdDrives[0].Path) -and
        $Snapshots.Count -eq 0 -and
        -not $Vm.AutomaticCheckpointsEnabled -and
        $Vm.AutomaticStartAction -eq 'Nothing'
    )

    [pscustomobject]@{
        ComputerName          = $env:COMPUTERNAME
        VmName                = $Vm.Name
        State                 = $Vm.State
        Disconnected          = [string]::IsNullOrWhiteSpace($SwitchName)
        DvdEmpty              = [string]::IsNullOrWhiteSpace(
            $DvdDrives[0].Path
        )
        SnapshotCount         = $Snapshots.Count
        AutomaticCheckpoints  = $Vm.AutomaticCheckpointsEnabled
        AutomaticStartAction  = $Vm.AutomaticStartAction
        Phase5EndStatePass    = $Phase5EndStatePass
    } | Format-List

    if (-not $Phase5EndStatePass) {
        throw 'Q011 Phase 5 end-state verification failed; stop.'
    }
}
```

Required end state: `State=Off`, `Disconnected=True`, `DvdEmpty=True`, zero
snapshots, and `Phase5EndStatePass=True`.

## Failure Containment

Phase 5 makes no in-guest configuration change, so there is no configuration
rollback. If a hard gate fails, retain the sanitized output, do not repair it,
and shut down normally when local administration still works. If normal
shutdown fails, preserve the observed state and request a new exact approval;
do not automatically use **Turn Off**, reset, attach media, or connect a
switch.

## Screenshot Boundary

The future hands-on execution has two primary screenshots and one optional
supporting image. This repository-only preparation has no screenshot because
no live GUI or console state changed; a picture of this Markdown file would not
prove the future baseline collection.

## Phase 5 Claim Boundary

Phase 5 will prove only the installed, unpatched, disconnected before-state.
It will not prove remote SSH reachability, firewall enforcement across a
network, subscription entitlement, available updates, patch completion,
hardening, backup, or production readiness. Those require later separately
designed and approved phases.
