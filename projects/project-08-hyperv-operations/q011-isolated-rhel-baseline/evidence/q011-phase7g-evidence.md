# Q011 Phase 7G — Read-Only GPG Trust Investigation Evidence

**Executed:** 2026-07-21  
**Target:** `Q011-RHEL102-BASELINE` on `WIN-PRQD8TJG04M`  
**Guest:** `q011-rhel01`  
**Result:** missing RPM trust certificates confirmed; cached RPM digests passed;
no guest trust, package, cache, or configuration change occurred

## Scope And Approval Boundary

Leonel approved Phase 7G exactly as a read-only guest trust investigation.
The window allowed the already-reviewed Hyper-V preflight, temporary Access
VLAN 70 attachment while the conflicting ASA remained Off, one interactive
SSH session as `leonel`, local package/key/repository reads, checks against two
already-cached RPMs, normal shutdown, and restoration to disconnected
Untagged VLAN 0. It did not permit a key import, DNF command, cache cleanup,
download, package transaction, configuration edit, or another system change.

## Starting Gate And Network Path

The fresh host preflight passed with Q011 Off, disconnected, Untagged VLAN 0,
DVD-empty, and checkpoint-free. After the exact Access VLAN 70 attachment,
Windows 11 SSH proved `leonel@q011-rhel01`, address
`192.168.70.140/24`, and gateway `192.168.70.1`. No NetworkManager profile
was manually activated or changed.

## Package-Owned Trust Input

The guest reported:

- `redhat-release-10.2-17.el10.x86_64`;
- `rpm-4.19.1.1-23.el10.x86_64`;
- `rpm -V redhat-release` exit `0` with no verification differences;
- `/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release` owned by `root:root`, mode
  `0644`, and 20,700 bytes; and
- SHA-256
  `d5ddf4a09b2dccc41c27e06f70dc7b2009704723115b5f824873b8d5133f84e2`
  for that package-owned key file.

The filtered BaseOS and AppStream sections both reported `enabled=1`,
`gpgcheck=1`, and the same local package-owned key path. The first multiline
`awk` expression in the prepared run sheet produced a syntax error because it
split an expression after `keep=(`. It performed no write. Leonel reran only a
corrected one-line predicate, which returned exactly the two intended sections
and six trust fields. The run sheet is corrected for future reproduction.

`rpmkeys --list` returned no imported certificate and exit `0`.
`/usr/lib/pqrpm/bin/rpmkeys` was absent, which is consistent with the native
RPMv6 verification path used by RHEL 10.2 and was not treated as permission to
install anything.

## Cached Package Verification

The existing cache contained 93 RPM files. Phase 7G selected only these two
repository-scoped samples already named by the stopped Phase 7 transaction:

- BaseOS:
  `kernel-core-6.12.0-211.34.1.el10_2.x86_64.rpm`
- AppStream:
  `amd-gpu-firmware-20260609-23.el10_2.noarch.rpm`

For both files, `rpmkeys -Kv` returned:

- hybrid RPMv6 signature key ID `05707a62`: `NOKEY`;
- RPMv4 RSA signature key ID `fd431d51`: `NOKEY`;
- header SHA-256 digest: `OK`;
- header SHA-1 digest: `OK`;
- payload SHA-256 digest: `OK`;
- MD5 digest: `OK`; and
- command exit `1` because the signing certificates were not trusted.

The `NOKEY` results match the empty RPM trust list. Every retained digest
passed, so the two sampled RPM payloads show no corruption. This does not by
itself authenticate the packages; authenticity remains blocked until the
required Red Hat certificates are imported through a separately approved
change and the signatures return `OK`.

## Off-Guest Fingerprint Comparison

The three fingerprints displayed and declined during Phase 7 match Red Hat's
published Product Signing Keys record:

| Certificate | Fingerprint | Phase 7G relevance |
|---|---|---|
| Release key 2, `FD431D51` | `567E 347A D004 4ADE 55BA 8A5F 199E 2F91 FD43 1D51` | Required by the sampled RPMv4 signatures |
| Auxiliary key 3, `5A6340B3` | `7E46 2425 8C40 6535 D56D 6F13 5054 E4A4 5A63 40B3` | Included by Red Hat for RHEL 10 disaster-recovery signing |
| Release key 4, `05707A62` | `FCD355B305707A62DA143AB6E422397E50FE8467A2A95343D246D6276AFEDF8F` | Required by the sampled hybrid RPMv6 signatures |

Red Hat records all three under the RHEL 10 package-signing key path. Red Hat
also documents that RHEL 10.1 and later use an OpenPGPv6 key extended with a
post-quantum certificate in this file. The future repair therefore uses native
`rpmkeys`; it must not use the incompatible Ansible `rpm_key`/GnuPG path.

## Final Isolation

Leonel shut Q011 down normally. The host then disconnected only its adapter
and restored Untagged VLAN 0. Final proof returned:

- VM state `Off`;
- exactly one adapter;
- `Disconnected=True`;
- `OperationMode=Untagged` and `AccessVlanId=0`;
- empty DVD;
- zero checkpoints; and
- `Phase7GEndStatePass=True`.

## Visual And Integrity Evidence

The [Phase 7G visual walkthrough](q011-phase7g-visual-walkthrough.md) uses all
three reviewed screenshots. The
[screenshot manifest](q011-phase7g-screenshots.sha256) records the copied
files' exact SHA-256 hashes. No password value, Red Hat consumer identity,
organization value, token, private key, authenticated URL, or unrelated host
inventory is visible.

## Claim Boundary

Phase 7G proves the local package-owned key file is intact, BaseOS/AppStream
require that file, the RPM trust list is empty, two sampled cached RPMs have
valid digests, and their signatures cannot be authenticated because the two
observed signing key IDs are `NOKEY`. It does **not** prove a certificate has
been imported, every cached RPM is intact, patching succeeded, the candidate
kernel boots, or the guest is current.

## Primary References

- [Red Hat Product Signing Keys](https://access.redhat.com/security/team/key)
- [RHEL 10.2 known issue for the OpenPGPv6 Red Hat release key](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/10.2_release_notes/known-issues)
- [RPM keyring and signature-check operations](https://rpm.org/docs/4.20.x/man/rpmkeys.8)
