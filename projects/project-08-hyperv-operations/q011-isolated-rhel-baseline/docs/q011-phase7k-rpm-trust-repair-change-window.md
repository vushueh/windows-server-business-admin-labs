# Q011 Phase 7K — RPM Trust Repair Change Window

**Status:** executed successfully; exact trust and final-isolation gates passed  
**Prepared:** 2026-07-21  
**Executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Paired rollback:**
[Phase 7K rollback plan](q011-phase7k-rpm-trust-repair-rollback.md)

## Objective

Import only the three Red Hat signing certificates already supplied by the
verified installed `redhat-release` package, require an exact three-certificate
allowlist, and prove that the same two cached BaseOS/AppStream RPM samples
change from `NOKEY` to authenticated signatures while every digest remains
`OK`.

Execution ended after trust verification and final Hyper-V isolation. It did
**not** retry DNF, refresh metadata, install or update a package, clean the
cache, reboot the guest, edit a repository, or change another system. This
document is now the historical run sheet and is not authority to repeat the
import.

## Evidence Basis

Phase 7G proved:

- `rpm -V redhat-release` exit `0` with no package-file difference;
- exact key file
  `/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release`, 20,700 bytes, SHA-256
  `d5ddf4a09b2dccc41c27e06f70dc7b2009704723115b5f824873b8d5133f84e2`;
- BaseOS and AppStream both use that file with `gpgcheck=1`;
- RPM's trust list is empty;
- 93 cached RPMs remain;
- one BaseOS and one AppStream sample have all digests `OK` but signatures
  `NOKEY` for key IDs `05707a62` and `fd431d51`; and
- `Phase7GEndStatePass=True` after normal shutdown and isolation.

The three DNF fingerprints retained from Phase 7 match Red Hat's
[Product Signing Keys](https://access.redhat.com/security/team/key):

| Allowed certificate | Exact published fingerprint |
|---|---|
| Release key 2, `fd431d51` | `567E347AD0044ADE55BA8A5F199E2F91FD431D51` |
| Auxiliary key 3, `5a6340b3` | `7E4624258C406535D56D6F135054E4A45A6340B3` |
| Release key 4, `05707a62` | `FCD355B305707A62DA143AB6E422397E50FE8467A2A95343D246D6276AFEDF8F` |

RHEL 10.2 carries the post-quantum OpenPGPv6 certificate in the same Red Hat
release-key file. Its documented Ansible `rpm_key`/GnuPG incompatibility means
this run sheet uses only native `rpmkeys`. The RHEL 10.2 release notes also
describe a bundle-import failure when a certificate contains an algorithm
disallowed by crypto policy, so any import error or unexpected post-import
key set triggers exact rollback before package work.

## Executed Approval Boundary

The exact live approval named all of these actions:

1. temporary Q011-only Access VLAN 70 attachment while the conflicting ASA is
   confirmed Off;
2. starting only Q011 and one interactive SSH login as `leonel`;
3. importing only the exact package-owned Red Hat release-key file with native
   `rpmkeys`;
4. retaining exactly the three allowlisted Red Hat certificates only after
   verification succeeds;
5. deleting only certificates newly imported by this window if any gate
   fails; and
6. normal Q011 shutdown and restoration to disconnected Untagged VLAN 0.

The approval did not imply a DNF invocation, package transaction, cache
cleanup, repository edit, OPNsense change, checkpoint, another VM, Git, or
GitHub action. None of those actions occurred in Phase 7K.

## Hard Stop Conditions

Stop before import if:

- the host or VM preflight differs from the Phase 7G final state;
- the conflicting ASA is not positively confirmed Off or competing work is
  active;
- Q011 does not automatically restore `192.168.70.140/24`, gateway
  `192.168.70.1`, and SSH as `leonel`;
- the installed package versions, key-file metadata/hash, repository trust
  fields, empty key list, cache count, sample paths, or pre-import `NOKEY` plus
  digest results differ from Phase 7G;
- native `rpmkeys` does not advertise both `--list` and `--delete`;
- the operator confirmation is not exact; or
- any command would contact a repository or modify anything other than the
  approved RPM trust entries.

After import, the same pasted block must immediately invoke the paired
rollback and stop if:

- `rpmkeys --import` returns nonzero;
- the RPM key-package query does not contain exactly three entries;
- the native list does not contain every allowlisted key ID or any queried
  key-package entry is outside this window;
- either cached RPM lacks `OK` for both recorded signature key IDs;
- any digest is not `OK`, either verification returns nonzero, or output
  contains `NOKEY`, `NOTTRUSTED`, or `NOT OK`; or
- an unexpected result makes the trust state ambiguous.

## Phase 7K-A — Fresh Host Preflight

Run in elevated Windows PowerShell on `WIN-PRQD8TJG04M`:

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
    $Confirmation = Read-Host (
        'After confirming the ASA is Off and no competing backup, storage, ' +
        'maintenance, Hyper-V, or Q011 work is active, type ' +
        'ASA-OFF-NO-COMPETING-WORK'
    )

    $Phase7KPreflightPass = (
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
        $Confirmation -ceq 'ASA-OFF-NO-COMPETING-WORK'
    )

    [pscustomobject]@{
        ComputerName         = $env:COMPUTERNAME
        VmName               = $Vm.Name
        State                = $Vm.State
        Disconnected         = [string]::IsNullOrWhiteSpace(
            $Adapters[0].SwitchName
        )
        OperationMode        = $Vlan.OperationMode
        AccessVlanId         = $Vlan.AccessVlanId
        DvdEmpty             = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
        SnapshotCount        = $Snapshots.Count
        TargetSwitch         = $Switch.Name
        Phase7KPreflightPass = $Phase7KPreflightPass
    } | Format-List

    if (-not $Phase7KPreflightPass) {
        throw 'Q011 Phase 7K preflight failed; do not attach or start the VM.'
    }
}
```

Stop unless `Phase7KPreflightPass=True`.

## Phase 7K-B — Restore Only The Proved Temporary Path

On the Hyper-V host:

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
        $Phase7KAttachmentPass = (
            $Adapter.SwitchName -eq $TargetSwitch -and
            $Vlan.OperationMode -eq 'Access' -and
            $Vlan.AccessVlanId -eq 70
        )

        [pscustomobject]@{
            VmName                = $VmName
            SwitchName            = $Adapter.SwitchName
            OperationMode         = $Vlan.OperationMode
            AccessVlanId          = $Vlan.AccessVlanId
            Phase7KAttachmentPass = $Phase7KAttachmentPass
        } | Format-List

        if (-not $Phase7KAttachmentPass) {
            throw 'Q011 Phase 7K attachment verification failed.'
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
}
```

From Windows 11, require the existing automatic profile to return
`192.168.70.140/24`, gateway `192.168.70.1`, and one interactive SSH login as
`leonel`. Do not manually activate or modify the profile.

## Phase 7K-C — Fresh Guest Trust Preflight

Paste this block in the proved SSH session. It performs no import.

```bash
set -o pipefail

key_file=/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
expected_key_sha=d5ddf4a09b2dccc41c27e06f70dc7b2009704723115b5f824873b8d5133f84e2
baseos_sample=/var/cache/dnf/rhel-10-for-x86_64-baseos-rpms-4b93e6b3052700d7/packages/kernel-core-6.12.0-211.34.1.el10_2.x86_64.rpm
appstream_sample=/var/cache/dnf/rhel-10-for-x86_64-appstream-rpms-7e19683532cf4c23/packages/amd-gpu-firmware-20260609-23.el10_2.noarch.rpm

release_verify=$(rpm -V redhat-release 2>&1)
release_verify_exit=$?
actual_key_sha=$(sha256sum "$key_file" | awk '{print $1}')
pre_key_list=$(rpmkeys --list 2>&1)
pre_key_list_exit=$?
cached_rpm_count=$(sudo find /var/cache/dnf /var/cache/libdnf5 \
  -xdev -type f -name '*.rpm' 2>/dev/null | wc -l)

baseos_before=$(sudo rpmkeys -Kv "$baseos_sample" 2>&1)
baseos_before_exit=$?
appstream_before=$(sudo rpmkeys -Kv "$appstream_sample" 2>&1)
appstream_before_exit=$?

printf '%s\n' "$baseos_before"
printf '%s\n' "$appstream_before"

rpmkeys --help 2>&1 | grep -- '--list' >/dev/null
list_supported=$?
rpmkeys --help 2>&1 | grep -- '--delete' >/dev/null
delete_supported=$?

pre_key_handles=$(
  rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' 2>&1
)
pre_key_handles_exit=$?

Phase7KGuestPreflightPass=false
if test "$release_verify_exit" -eq 0 && \
   test -z "$release_verify" && \
   test "$actual_key_sha" = "$expected_key_sha" && \
   test "$pre_key_list_exit" -eq 0 && \
   test -z "$pre_key_list" && \
   test "$pre_key_handles_exit" -eq 0 && \
   test -z "$pre_key_handles" && \
   test "$cached_rpm_count" -eq 93 && \
   test -f "$baseos_sample" && \
   test -f "$appstream_sample" && \
   test "$baseos_before_exit" -eq 1 && \
   test "$appstream_before_exit" -eq 1 && \
   printf '%s\n' "$baseos_before" | grep -i 'key ID 05707a62: NOKEY' >/dev/null && \
   printf '%s\n' "$baseos_before" | grep -i 'key ID fd431d51: NOKEY' >/dev/null && \
   printf '%s\n' "$appstream_before" | grep -i 'key ID 05707a62: NOKEY' >/dev/null && \
   printf '%s\n' "$appstream_before" | grep -i 'key ID fd431d51: NOKEY' >/dev/null && \
   test "$(printf '%s\n' "$baseos_before" | grep -c 'digest: OK')" -eq 4 && \
   test "$(printf '%s\n' "$appstream_before" | grep -c 'digest: OK')" -eq 4 && \
   test "$list_supported" -eq 0 && \
   test "$delete_supported" -eq 0; then
  Phase7KGuestPreflightPass=true
fi

printf 'release_verify_exit=%s\n' "$release_verify_exit"
printf 'key_sha_match=%s\n' "$([ "$actual_key_sha" = "$expected_key_sha" ] && echo true || echo false)"
printf 'pre_key_count=%s\n' "$(printf '%s' "$pre_key_list" | grep -c . || true)"
printf 'pre_key_handle_count=%s\n' "$(printf '%s' "$pre_key_handles" | grep -c . || true)"
printf 'cached_rpm_count=%s\n' "$cached_rpm_count"
printf 'list_supported=%s\n' "$list_supported"
printf 'delete_supported=%s\n' "$delete_supported"
printf 'Phase7KGuestPreflightPass=%s\n' "$Phase7KGuestPreflightPass"

if test "$Phase7KGuestPreflightPass" != true; then
  printf '%s\n' 'STOP_BEFORE_IMPORT=true'
fi
```

Stop unless `Phase7KGuestPreflightPass=true`.

## Phase 7K-D — Import And Verify The Exact Trust Set

The import is the point of no return for this phase. The operator must type the
exact confirmation before running this block in the same SSH session as Phase
7K-C. The three variables are deliberately restated so a missing shell value
cannot redirect the import or sample checks.

The native `rpmkeys --list` implementation renders
`VERSION-RELEASE: SUMMARY`, but rollback does not parse that human-readable
text. It obtains deletion handles through RPM's explicit
`%{VERSION}-%{RELEASE}` query format. Upstream RPM documents `KEYHASH` as the
delete operand in the [RPM keyring manual](https://rpm.org/docs/4.20.x/man/rpmkeys.8)
and implements list/delete as queries and erases of `gpg-pubkey` entries in
[`rpmkeys.c`](https://github.com/rpm-software-management/rpm/blob/rpm-4.20.x/tools/rpmkeys.c).
This removes the output-format assumption identified in the independent
review.

The exact package-owned file identity remains the primary certificate control:
Phase 7K-C repeats both `rpm -V redhat-release` and the exact SHA-256 gate
before import. The configured BaseOS/AppStream records point to that exact
file; Phase 7's DNF prompt displayed three fingerprints from the configured
key source, and Phase 7G matched those fingerprints to Red Hat's published
record. The post-import checks therefore prove that the trusted entries came
only from the cryptographically fixed package-owned input and that all three
expected short IDs are present; they do not claim that a short ID alone
authenticates a certificate.

```bash
key_file=/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
baseos_sample=/var/cache/dnf/rhel-10-for-x86_64-baseos-rpms-4b93e6b3052700d7/packages/kernel-core-6.12.0-211.34.1.el10_2.x86_64.rpm
appstream_sample=/var/cache/dnf/rhel-10-for-x86_64-appstream-rpms-7e19683532cf4c23/packages/amd-gpu-firmware-20260609-23.el10_2.noarch.rpm

phase7k_rollback_keys() {
  rollback_handles_text=$(
    rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' 2>&1
  )
  rollback_handles_exit=$?
  mapfile -t rollback_handles < <(
    printf '%s\n' "$rollback_handles_text" |
      sed '/^[[:space:]]*$/d'
  )

  printf '%s\n' "$rollback_handles_text"
  printf 'rollback_handles_exit=%s\n' "$rollback_handles_exit"
  printf 'rollback_handle_count=%s\n' "${#rollback_handles[@]}"

  if test "$rollback_handles_exit" -ne 0; then
    printf '%s\n' 'rollback_query_gate=false'
    return 31
  fi

  rollback_delete_failed=false
  for handle in "${rollback_handles[@]}"; do
    if ! printf '%s\n' "$handle" |
         grep -E '^[[:xdigit:]]+-[[:xdigit:]]+$' >/dev/null; then
      printf 'unexpected_rollback_handle=%s\n' "$handle"
      return 31
    fi
    sudo rpmkeys --delete "$handle" || rollback_delete_failed=true
  done

  remaining_keys=$(rpmkeys --list 2>&1)
  remaining_keys_exit=$?
  remaining_handles=$(
    rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' 2>&1
  )
  remaining_handles_exit=$?

  Phase7KKeyRollbackPass=false
  if test "$rollback_delete_failed" = false && \
     test "$remaining_keys_exit" -eq 0 && \
     test -z "$remaining_keys" && \
     test "$remaining_handles_exit" -eq 0 && \
     test -z "$remaining_handles"; then
    Phase7KKeyRollbackPass=true
  fi

  printf 'rollback_delete_failed=%s\n' "$rollback_delete_failed"
  printf 'remaining_key_count=%s\n' "$(printf '%s' "$remaining_keys" | grep -c . || true)"
  printf 'remaining_handle_count=%s\n' "$(printf '%s' "$remaining_handles" | grep -c . || true)"
  printf 'Phase7KKeyRollbackPass=%s\n' "$Phase7KKeyRollbackPass"

  test "$Phase7KKeyRollbackPass" = true || return 32
}

phase7k_import_and_verify() {
  read -r -p 'Type IMPORT-THREE-RED-HAT-KEYS to continue: ' key_confirmation
  if test "$key_confirmation" != 'IMPORT-THREE-RED-HAT-KEYS'; then
    printf '%s\n' 'key_import_confirmation=false'
    return 22
  fi

  sudo rpmkeys --import "$key_file"
  import_exit=$?
  post_key_list=$(rpmkeys --list 2>&1)
  post_key_list_exit=$?
  post_key_handles=$(
    rpm -qa 'gpg-pubkey*' --qf '%{VERSION}-%{RELEASE}\n' 2>&1
  )
  post_key_handles_exit=$?
  post_key_count=$(printf '%s\n' "$post_key_handles" | grep -c . || true)

  printf '%s\n' "$post_key_list"
  printf 'import_exit=%s\n' "$import_exit"
  printf '%s\n' "$post_key_handles"
  printf 'post_key_handle_count=%s\n' "$post_key_count"

  exact_key_set=false
  if test "$import_exit" -eq 0 && \
     test "$post_key_list_exit" -eq 0 && \
     test "$post_key_handles_exit" -eq 0 && \
     test "$post_key_count" -eq 3 && \
     printf '%s\n' "$post_key_list" | grep -i 'fd431d51' >/dev/null && \
     printf '%s\n' "$post_key_list" | grep -i '5a6340b3' >/dev/null && \
     printf '%s\n' "$post_key_list" | grep -i '05707a62' >/dev/null; then
    exact_key_set=true
  fi

  printf 'exact_key_set=%s\n' "$exact_key_set"
  test "$exact_key_set" = true || return 23

  baseos_after=$(sudo rpmkeys -Kv "$baseos_sample" 2>&1)
  baseos_after_exit=$?
  appstream_after=$(sudo rpmkeys -Kv "$appstream_sample" 2>&1)
  appstream_after_exit=$?

  printf '%s\n' "$baseos_after"
  printf '%s\n' "$appstream_after"

  Phase7KTrustPass=false
  if test "$baseos_after_exit" -eq 0 && \
     test "$appstream_after_exit" -eq 0 && \
     printf '%s\n' "$baseos_after" | grep -i 'key ID 05707a62: OK' >/dev/null && \
     printf '%s\n' "$baseos_after" | grep -i 'key ID fd431d51: OK' >/dev/null && \
     printf '%s\n' "$appstream_after" | grep -i 'key ID 05707a62: OK' >/dev/null && \
     printf '%s\n' "$appstream_after" | grep -i 'key ID fd431d51: OK' >/dev/null && \
     test "$(printf '%s\n' "$baseos_after" | grep -c 'digest: OK')" -eq 4 && \
     test "$(printf '%s\n' "$appstream_after" | grep -c 'digest: OK')" -eq 4 && \
    ! printf '%s\n%s\n' "$baseos_after" "$appstream_after" | \
      grep -Ei 'NOKEY|NOTTRUSTED|NOT OK' >/dev/null; then
    Phase7KTrustPass=true
  fi

  printf 'baseos_rpmkeys_exit=%s\n' "$baseos_after_exit"
  printf 'appstream_rpmkeys_exit=%s\n' "$appstream_after_exit"
  printf 'Phase7KTrustPass=%s\n' "$Phase7KTrustPass"

  test "$Phase7KTrustPass" = true || return 24
}

phase7k_import_and_verify
phase7k_function_exit=$?
printf 'phase7k_function_exit=%s\n' "$phase7k_function_exit"

phase7k_rollback_exit=not-required
if test "$phase7k_function_exit" -eq 23 || \
   test "$phase7k_function_exit" -eq 24; then
  phase7k_rollback_keys
  phase7k_rollback_exit=$?
  printf 'phase7k_rollback_exit=%s\n' "$phase7k_rollback_exit"
fi
```

If `phase7k_function_exit` is `23` or `24`, the same block immediately invokes
the exact rollback. Require `phase7k_rollback_exit=0`; otherwise isolate Q011
without guessing and request a separately approved recovery. If the import and
signature gates pass, retain the three verified Red Hat certificates and stop
guest work. The patch retry remains separately approval-gated.

## Phase 7K-E — Normal Shutdown And Final Isolation

Capture the approved trust evidence first, then run in the guest:

```bash
sudo systemctl poweroff
```

Wait up to three minutes. Run in elevated PowerShell on the Hyper-V host:

```powershell
$ErrorActionPreference = 'Stop'
$VmName = 'Q011-RHEL102-BASELINE'
$Deadline = (Get-Date).AddMinutes(3)
do {
    $Vm = Get-VM -Name $VmName
    if ($Vm.State -eq 'Off') { break }
    Start-Sleep -Seconds 5
} while ((Get-Date) -lt $Deadline)

if ((Get-VM -Name $VmName).State -ne 'Off') {
    Disconnect-VMNetworkAdapter -VMName $VmName
    Set-VMNetworkAdapterVlan -VMName $VmName -Untagged
    throw (
        'Q011 did not shut down within three minutes. Network containment ' +
        'was restored; forced power-off requires separate approval.'
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

$Phase7KEndStatePass = (
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
    VmName              = $Vm.Name
    State               = $Vm.State
    AdapterCount        = $Adapters.Count
    Disconnected        = [string]::IsNullOrWhiteSpace(
        $Adapters[0].SwitchName
    )
    OperationMode       = $Vlan.OperationMode
    AccessVlanId        = $Vlan.AccessVlanId
    DvdEmpty            = [string]::IsNullOrWhiteSpace($Dvd[0].Path)
    SnapshotCount       = $Snapshots.Count
    Phase7KEndStatePass = $Phase7KEndStatePass
} | Format-List
```

Require `Phase7KTrustPass=true` and `Phase7KEndStatePass=True` before calling
the repair successful.

## Screenshot Result

Leonel captured the actual hands-on proof with empty password prompts and
unrelated window content excluded:

1. `q011-phase7k-01-trusted-red-hat-key-list.png` — exactly three imported
   Red Hat entries plus `exact_key_set=true`.
2. `q011-phase7k-02-cached-signatures-ok.png` — both repository-scoped cached
   samples, both recorded signature key IDs `OK`, all digests `OK`, and
   `Phase7KTrustPass=true`.
3. `q011-phase7k-03-safe-end-state.png` — Off, disconnected, Untagged VLAN 0,
   DVD-empty, checkpoint-free, and `Phase7KEndStatePass=True`.

The project README displays two Phase 7K images. All three appear in the
[visual walkthrough](../evidence/q011-phase7k-visual-walkthrough.md), with
exact hashes in the
[screenshot manifest](../evidence/q011-phase7k-screenshots.sha256). No image
contains a sudo prompt, password, consumer UUID, organization value,
entitlement data, token, complete repository URL, authenticated URL, or
unrelated VM inventory.

## Success And Next Boundary

Success proves the exact three package-owned Red Hat certificates are trusted
and the two sampled cached RPM signatures authenticate without digest change.
It does not prove all cached packages, a DNF transaction, patch currency, or a
successful new-kernel reboot. The exact outcome is retained in the
[Phase 7K evidence](../evidence/q011-phase7k-evidence.md) and
[sanitized results](../evidence/q011-phase7k-sanitized-results.txt). The later
[Phase 7P patch retry](q011-phase7p-controlled-patch-retry-change-window.md)
requires its own approval and reuses the reviewed Phase 7 transaction
controls.

## Primary References

- [Red Hat Product Signing Keys](https://access.redhat.com/security/team/key)
- [RHEL 10.2 known issues](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/10.2_release_notes/known-issues)
- [RHEL 10 package-signing documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/packaging_and_distributing_software/packaging_and_distributing_software)
- [RPM keyring operations](https://rpm.org/docs/4.20.x/man/rpmkeys.8)
