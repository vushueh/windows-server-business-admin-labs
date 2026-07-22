# Q011 Phase 7G — GPG Trust Investigation Containment Plan

**Written:** 2026-07-20  
**Paired run sheet:**
[Phase 7G read-only investigation](q011-phase7g-gpg-trust-read-only-investigation.md)

## Starting State

- Phase 7 installed no key and recorded no package transaction.
- `upgrade_exit=1`; cached RPMs remain intentionally untouched.
- Q011 is Off, disconnected, Untagged VLAN 0, DVD-empty, and checkpoint-free.
- The OPNsense reservation, NetworkManager autoconnect, registration, and
  BaseOS/AppStream repository configuration remain retained.

## Containment Principle

Phase 7G is read-only. Its rollback is therefore restoration of temporary VM
power/network exposure, not reversal of a guest change. No result in this
window authorizes importing a key, cleaning the cache, reinstalling a package,
editing repository configuration, or retrying DNF.

## Stop Triggers

- preflight, DHCP, or SSH gate fails;
- the local key file is not owned by `redhat-release` or package verification
  differs;
- a repository trust field is missing or unexpected;
- a fingerprint already recorded in the Phase 7 evidence, compared off-guest
  against Red Hat's public record, differs;
- a cached sample is absent or has an invalid digest/signature;
- a required read-only tool is absent;
- a command requests a write, repository contact, or import; or
- Q011 cannot shut down normally or final isolation cannot be proved.

## Guest-Side Stop

If any read-only check fails:

1. Do not rerun it with a modifying flag.
2. Do not use `rpmkeys --import`, `rpm --import`, `dnf clean`, `dnf upgrade`,
   `dnf reinstall`, or a repository refresh.
3. Retain only the sanitized failed check and its exit status.
4. Request normal shutdown with `sudo systemctl poweroff`.

## Network Containment If Shutdown Does Not Complete

If Q011 does not become Off within three minutes, do not use Hyper-V **Turn
Off** automatically. On the host, disconnect only Q011 and restore Untagged
VLAN 0:

```powershell
$VmName = 'Q011-RHEL102-BASELINE'
Disconnect-VMNetworkAdapter -VMName $VmName
Set-VMNetworkAdapterVlan -VMName $VmName -Untagged
```

Verify its only adapter has no switch, `OperationMode=Untagged`, and
`AccessVlanId=0`. Leave console-only power-state diagnosis or forced power-off
for a separate approval.

## Successful Read-Only End State

Even if every diagnostic check passes, shut Q011 down normally, disconnect
its adapter, restore Untagged VLAN 0, and require
`Phase7GEndStatePass=True`. Preserve the cached packages exactly as found.

## Explicit Non-Actions

This containment plan does not authorize:

- trusting or importing any public key;
- modifying the package database or keyring;
- cleaning, deleting, moving, or reusing cached RPMs;
- retrying the failed transaction;
- changing Red Hat registration or repository configuration;
- changing NetworkManager, OPNsense, the DHCP reservation, a switch, another
  VM, a checkpoint, the ISO, or the VHDX; or
- any Git or GitHub operation.
