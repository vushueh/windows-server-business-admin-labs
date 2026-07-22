# Q011 Phase 7K — RPM Trust-Repair Evidence

**Executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** exact packaged Red Hat trust set imported; both retained cached RPM
samples authenticated; no DNF transaction ran; final isolation passed

## Scope And Approval Boundary

Leonel approved the reviewed Phase 7K trust-repair window exactly as
documented. It allowed a fresh host preflight, temporary Access VLAN 70
attachment while the conflicting ASA remained Off, one interactive SSH
session as `leonel`, import of only the three certificates from the already
verified package-owned Red Hat key file, verification of the same two cached
RPM samples, normal shutdown, and restoration to disconnected Untagged VLAN
0. It did not permit DNF, package-cache cleanup, a package transaction,
repository changes, or another system change.

## Starting Gate And Trust Input

The fresh host preflight passed with Q011 Off, disconnected, Untagged VLAN 0,
DVD-empty, and checkpoint-free. The exact temporary network attachment passed,
and the guest returned automatically as `192.168.70.140/24` with gateway
`192.168.70.1`.

Guest preflight re-verified the installed `redhat-release` package and the
whole package-owned key-file input established in Phase 7G. It proved:

- `release_verify_exit=0`;
- the key-file SHA-256 still matched the pinned Phase 7G value;
- the RPM trust list and machine-readable key-handle set were both empty;
- 93 cached RPMs remained available;
- native RPM supported the exact list and delete controls needed by the
  reviewed same-block rollback; and
- `Phase7KGuestPreflightPass=true`.

## Exact Trust Import

After the explicit `IMPORT-THREE-RED-HAT-KEYS` confirmation, native `rpmkeys`
imported only these three packaged Red Hat certificates:

| Certificate | Machine-readable handle | Purpose |
|---|---|---|
| Red Hat release key 2 | `fd431d51-4ae0493b` | RPMv4 package signatures |
| Red Hat auxiliary key 3 | `5a6340b3-6229229e` | RHEL 10 auxiliary/disaster-recovery signing |
| Red Hat release key 4 | `05707a62-68e6a1f3` | Hybrid RPMv6 signatures |

The import returned `import_exit=0`, exactly three handles were present, and
`exact_key_set=true`. No unrelated public key was accepted.

## Cached Signature Verification

Phase 7K rechecked the same repository-scoped cached samples used during the
read-only Phase 7G diagnosis:

- BaseOS: `kernel-core-6.12.0-211.34.1.el10_2.x86_64.rpm`
- AppStream: `amd-gpu-firmware-20260609-23.el10_2.noarch.rpm`

For both packages, native `rpmkeys -Kv` changed the two observed signature
results from `NOKEY` to `OK`:

- hybrid RPMv6 signature key ID `05707a62`: `OK`;
- RPMv4 RSA signature key ID `fd431d51`: `OK`;
- header SHA-256 digest: `OK`;
- header SHA-1 digest: `OK`;
- payload SHA-256 digest: `OK`;
- MD5 digest: `OK`; and
- command exit `0`.

The combined gate returned `Phase7KTrustPass=true` and
`phase7k_function_exit=0`. Because the trust gate passed, rollback was not
required. Phase 7K did not invoke DNF or modify any package.

## Final Isolation

Leonel shut Q011 down normally. The host disconnected only its adapter and
restored Untagged VLAN 0. Final proof returned:

- VM state `Off`;
- exactly one adapter;
- `Disconnected=True`;
- `OperationMode=Untagged` and `AccessVlanId=0`;
- empty DVD;
- zero checkpoints; and
- `Phase7KEndStatePass=True`.

## Visual And Integrity Evidence

The [Phase 7K visual walkthrough](q011-phase7k-visual-walkthrough.md) uses all
three reviewed screenshots. The
[screenshot manifest](q011-phase7k-screenshots.sha256) records the copied
files' exact SHA-256 hashes. No password value, Red Hat consumer identity,
organization value, token, private key, authenticated URL, or unrelated host
inventory is visible.

## Claim Boundary

Phase 7K proves the exact three-certificate Red Hat trust set was imported
from the previously verified package-owned file, the two retained cached RPM
samples now authenticate with both observed signing IDs, and Q011 returned to
its isolated state. It does **not** prove every cached RPM was sampled, that a
DNF transaction succeeded, that the candidate kernel boots, that all updates
are installed, or that the guest is current. Those claims require a separate
controlled patch-and-reboot window.

