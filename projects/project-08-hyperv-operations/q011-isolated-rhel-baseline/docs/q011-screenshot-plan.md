# Q011 Screenshot Plan

Every hands-on phase must capture safe proof of Leonel's actual practice.
Command-only or documentation-only phases must state why an image would not be
meaningful. Screenshots supplement searchable text; they do not replace it.

## Phase 2C — Design

**Screenshot:** not appropriate.  
**Reason:** Phase 2C changes repository documentation only. No VM, ISO,
Hyper-V setting, or network state exists to capture. A screenshot of Markdown
or PowerShell text would add no independent evidence.

## Phase 4A — Local ISO Staging

**Status:** captured, reviewed, and accepted on 2026-07-19.

**Required filename:**
`evidence/screenshots/q011-phase4a-01-local-rhel102-iso.png`

After `ChecksumPass=True`:

1. Open File Explorer on `WIN-PRQD8TJG04M`.
2. Browse directly to `D:\Hyper-V\ISO`.
3. Select **View → Details**.
4. Make the **Name**, **Type**, and **Size** columns visible.
5. Show only `rhel-10.2-x86_64-dvd.iso` and enough of the address bar to prove
   the local `D:\Hyper-V\ISO` location.
6. Crop out the desktop, taskbar account details, unrelated files, mapped
   shares, notifications, and other VM information.
7. Ensure no credential dialog or username is visible.
8. Save as PNG with the exact filename above. Do not enlarge or upscale it.

The accepted Properties capture proves the full name, singular local path, and
exact byte size. The matching hash stays in sanitized text evidence because
File Explorer does not prove SHA-256.

## Phase 4B — Disconnected VM Creation

**Status:** captured, reviewed, integrity-manifested, and accepted on
2026-07-19.

**Primary README filenames:**

1. `evidence/screenshots/q011-phase4b-01-hyperv-disconnected-network.png`
2. `evidence/screenshots/q011-phase4b-02-hyperv-firmware-media.png`

After the build passed and while the VM remained Off:

1. After the PowerShell result reports `Phase4BPass=True`, leave the VM Off.
2. Open **Server Manager → Tools → Hyper-V Manager** and select the local host.
3. In **Virtual Machines**, select only `Q011-RHEL102-BASELINE`, then open
   **Settings**.
4. Select **Network Adapter**. Confirm **Virtual switch: Not connected** and
   capture the Settings dialog so its title also proves the Q011 VM name.
5. Still in Settings, select **Firmware**. Capture the DVD drive before the
   hard drive in the boot order and the disconnected adapter last. Retain the
   separate Security page as supporting evidence for the exact Microsoft UEFI
   Certificate Authority template.
6. Crop each image to the Q011 Settings dialog. Do not expose the Hyper-V
   Manager VM inventory behind it, unrelated VM names, host notifications,
   credentials, accounts, or desktop content.
7. Save the original PNGs with the exact filenames above. Do not enlarge or
   upscale them.

The paired searchable PowerShell result proves processor, memory, VHDX type
and size, checkpoint state, ISO path/hash, Secure Boot template, boot order,
and the same disconnected-vNIC controls. The project README intentionally
displays only the two strongest images. All thirteen reviewed process and
final-state captures are used in the linked
[Phase 4B visual walkthrough](../evidence/q011-phase4b-visual-walkthrough.md),
with exact hashes in the
[screenshot manifest](../evidence/q011-phase4b-screenshots.sha256).

## Phase 4C — RHEL Installer

**Status:** captured, reviewed, integrity-manifested, and accepted on
2026-07-19.

**Primary README filenames:**

1. `evidence/screenshots/q011-phase4c-01-rhel-installation-summary.png`
2. `evidence/screenshots/q011-phase4c-02-installed-offline-verification.png`

**Supporting walkthrough filenames:**

1. `evidence/screenshots/q011-phase4c-process-01-rhel102-welcome.png`
2. `evidence/screenshots/q011-phase4c-process-02-installation-complete-before-eject.png`
3. `evidence/screenshots/q011-phase4c-process-03-hyperv-dvd-ejected.png`
4. `evidence/screenshots/q011-phase4c-process-04-vmconnect-clipboard-limit.png`
5. `evidence/screenshots/q011-phase4c-process-05-offline-network-health.png`

Leonel captured the images during his actual VMConnect/Hyper-V practice:

1. The intended DVD boot-menu image was missed. The retained Welcome image
   proves the exact Q011 VM reached the RHEL 10.2 installer and is named as a
   Welcome capture rather than mislabeled as boot-menu proof.
2. On **Installation Summary**, after every no-write gate passes but before
   **Begin Installation**, show local media, `Minimal Install`, automatic
   storage on the one target disk, network disconnected/off, hostname
   `q011-rhel01`, root disabled, a local administrator configured, and no Red
   Hat registration. Do not open or capture a password-entry page. The
   non-secret project username may appear only as a summary label.
3. When installation completes, capture the completion screen before selecting
   **Reboot System**. This image proves the ISO-ejection checkpoint, not that
   the installed guest boots.
4. After `Phase4CEjectPass=True`, open only the Q011 VM's **Settings -> SCSI
   Controller -> DVD Drive** and show that no media is attached. Do not select
   Apply or expose another VM. If the running VM does not permit this clean
   view, omit this image and retain the searchable eject result instead.
5. VMConnect rejected the long clipboard payload. The retained diagnostic
   image proves that safe stop, and the offline-network capture proves wheel
   membership, zero failed units, loopback-only addressing, no routes, and
   `eth0` unavailable.
6. The final primary capture shows release, hostname, SELinux, locked-root
   status `L`, wheel membership, system health, and the combined reviewed
   manual verification marker. One mistyped command is visibly corrected by
   the successful command immediately below it.

The project README displays only the Installation Summary and final installed
verification images. The other five captures belong in the linked
[Phase 4C visual walkthrough](../evidence/q011-phase4c-visual-walkthrough.md),
and exact hashes are retained in the
[Phase 4C screenshot manifest](../evidence/q011-phase4c-screenshots.sha256).

The direct Network & Host Name capture was excluded because it displayed the
adapter hardware address. Three diagnostic console images with sudo
password-prompt text were also excluded. None contained the password itself,
but retaining them would violate the planned clean-evidence boundary.

The repository-only preparation of this plan has no screenshot: it changes no
live GUI or console state, and a picture of Markdown would not prove the future
installation.

## Phase 5 — Disconnected Service Baseline

**Status:** captured, reviewed, integrity-manifested, and accepted on
2026-07-20.

**Primary README filenames:**

1. `evidence/screenshots/q011-phase5-03-core-baseline-via-ssh-clean.png`
2. `evidence/screenshots/q011-phase5-07-offline-end-state.png`

The first image proves the clean release, hostname, SELinux, locked-root,
wheel, health, and package baseline. The second proves the final
Off/disconnected/VLAN-zero/DVD-empty/checkpoint-free host state and
`Phase5EndStatePass=True`.

The approved Phase 5N extension also retained the unexpected DHCP authority,
the NetworkManager lease evidence, the corrected OPNsense lease, and Windows
11 SSH proof. All fourteen reviewed images are embedded in the
[Phase 5 visual walkthrough](../evidence/q011-phase5-visual-walkthrough.md);
their exact hashes are in the
[Phase 5 screenshot manifest](../evidence/q011-phase5-screenshots.sha256).

Images containing an empty sudo or SSH password prompt are supporting evidence
only. No password value is visible. The initial console package observation
that appeared to show the targeted SELinux package absent is superseded by the
later clean repeat proving the installed package without a package change.

## Phase 6 — Controlled Network And Registration

**Status:** captured, reviewed, integrity-manifested, and accepted on
2026-07-20.

**Primary README filenames:**

1. `evidence/screenshots/q011-phase6d-01-registration-repositories-pass.png`
2. `evidence/screenshots/q011-phase6e-01-safe-end-state.png`

The first primary image contains only Boolean registration and BaseOS/AppStream
results. The second proves normal shutdown and the final Off, disconnected,
Untagged VLAN-zero, DVD-empty, checkpoint-free state.

Ten additional safe captures preserve the preflight, DHCP options, SSH login,
empty reservation precheck, active lease, one new reservation, automatic
activation failure, manual recovery, narrow autoconnect change, and successful
automatic reboot persistence. All twelve appear in the
[Phase 6 visual walkthrough](../evidence/q011-phase6-visual-walkthrough.md),
with exact hashes in the
[Phase 6 screenshot manifest](../evidence/q011-phase6-screenshots.sha256).

Images with an empty password prompt are supporting evidence only. No password,
consumer UUID, organization value, token, certificate, or authenticated URL is
visible. The first post-reservation reboot is correctly labeled as a failed
automatic-activation claim followed by manual recovery, not as persistence
proof.

## Phase 7 — Controlled Patching

**Status:** stopped safely on 2026-07-20; five screenshots captured, reviewed,
copied byte-for-byte, and integrity-manifested.

**Originally planned filenames:**

1. `evidence/screenshots/q011-phase7-01-preupdate-readiness.png`
2. `evidence/screenshots/q011-phase7-02-postupdate-reboot-validation.png`
3. `evidence/screenshots/q011-phase7-03-safe-end-state.png`

The first and third planned images were captured. The second does not exist
because the transaction stopped at the GPG trust gate before package changes
or reboot; it must not be fabricated. Three additional safe process images
preserve updates available, the reviewed transaction, and the failed exit with
unchanged history:

1. `evidence/screenshots/q011-phase7-process-01-updates-available.png`
2. `evidence/screenshots/q011-phase7-process-02-dnf-transaction-review.png`
3. `evidence/screenshots/q011-phase7-process-03-gpg-key-stop-no-transaction.png`

The README displays the two strongest truthful images: pre-update readiness
and the GPG-stop/unchanged-history result. All five images appear in the
[Phase 7 visual walkthrough](../evidence/q011-phase7-visual-walkthrough.md),
and exact hashes are retained in the
[Phase 7 screenshot manifest](../evidence/q011-phase7-screenshots.sha256).

## Phase 7G — Read-Only GPG Trust Investigation

**Status:** all three hands-on images captured, reviewed, copied byte-for-byte,
and integrity-manifested on 2026-07-21.

**Retained hands-on filenames:**

1. `evidence/screenshots/q011-phase7g-01-key-and-repo-readonly-state.png`
2. `evidence/screenshots/q011-phase7g-02-cache-signature-readonly-state.png`
3. `evidence/screenshots/q011-phase7g-03-safe-end-state.png`

The first image shows only the package-owned key-file verification, filtered
BaseOS/AppStream trust settings, and empty RPM trust list. The second shows
valid digests plus `NOKEY` for the two repository-scoped cached RPM samples.
The third proves the final Off/disconnected/Untagged state and appears in the
[Phase 7G visual walkthrough](../evidence/q011-phase7g-visual-walkthrough.md).
Exact hashes are retained in the
[Phase 7G screenshot manifest](../evidence/q011-phase7g-screenshots.sha256).
No captured image contains a password value, consumer identity, entitlement
data, complete repository URL, credential, or token.

The repository-only preparation has no screenshot because Markdown and
unexecuted commands do not prove the guest's trust state.

## Phase 7K — RPM Trust Repair

**Status:** all three hands-on images captured, reviewed, copied byte-for-byte,
and integrity-manifested on 2026-07-21.

**Retained hands-on filenames:**

1. `evidence/screenshots/q011-phase7k-01-trusted-red-hat-key-list.png`
2. `evidence/screenshots/q011-phase7k-02-cached-signatures-ok.png`
3. `evidence/screenshots/q011-phase7k-03-safe-end-state.png`

The first image proves three queried trust entries from the exact pinned
package-owned Red Hat bundle and `exact_key_set=true`. The second proves both
cached RPM signatures and all digests return `OK` with
`Phase7KTrustPass=true`. The third proves normal shutdown and final Hyper-V
isolation. The project README displays the first two; all three appear in the
[Phase 7K walkthrough](../evidence/q011-phase7k-visual-walkthrough.md), with
exact hashes in the
[Phase 7K screenshot manifest](../evidence/q011-phase7k-screenshots.sha256).

No retained image contains the import confirmation before acceptance, an
empty sudo prompt, password, consumer identity, entitlement data, repository
URL, token, or unrelated VM inventory.

## Phase 7P — Controlled Patch Retry And Reboot

**Status:** all four hands-on images captured, reviewed, copied byte-for-byte,
and integrity-manifested on 2026-07-21.

**Retained hands-on filenames:**

1. `evidence/screenshots/q011-phase7p-process-01-transaction-review.png`
2. `evidence/screenshots/q011-phase7p-01-transaction-success.png`
3. `evidence/screenshots/q011-phase7p-02-postreboot-validation.png`
4. `evidence/screenshots/q011-phase7p-03-safe-end-state.png`

The process image preserves the final reviewed DNF summary before the
operator answered `y`. The first primary image proves DNF completion and the
read-only history recovery: transaction `2`, `Return-Code: Success`, the new
installed kernel, and `Phase7PTransactionPass=true`. It does not claim an
immediate exit value because that shell capture was lost. The second primary
image proves the guest booted its newest installed kernel and passed health,
SELinux, service, trust, repository, and final update-state gates. The final
image proves normal shutdown and Hyper-V isolation.

The project README displays transaction success and post-reboot validation.
The transaction-review and safe-end-state captures remain in the linked
[Phase 7P walkthrough](../evidence/q011-phase7p-visual-walkthrough.md), with
all four hashes in the
[Phase 7P screenshot manifest](../evidence/q011-phase7p-screenshots.sha256).
The source transaction-review filename began with `011`; its canonical copy
adds only the missing leading `q` and preserves identical bytes. No retained
image contains a password or sudo prompt, Red Hat identity, consumer UUID,
organization value, token, complete repository URL, authenticated URL, or
unrelated VM inventory.

## Phase 8 — Post-Patch Validation And Rebuild Evidence

**Status:** all three hands-on images captured, reviewed, copied byte-for-byte,
and integrity-manifested on 2026-07-21.

**Retained hands-on filenames:**

1. `evidence/screenshots/q011-phase8-01-postpatch-control-baseline.png`
2. `evidence/screenshots/q011-phase8-02-trust-history-storage-validation.png`
3. `evidence/screenshots/q011-phase8-03-safe-end-state.png`

The first image proves stable post-patch identity, account, SELinux, service,
hash, health, and kernel controls. The second proves the expected
registration, repository, exact trust, DNF-history, and LVM state. The third
proves normal shutdown and final Hyper-V isolation. The project README
displays the first and third; all three appear in the
[Phase 8 walkthrough](../evidence/q011-phase8-visual-walkthrough.md), with
exact hashes in the
[Phase 8 screenshot manifest](../evidence/q011-phase8-screenshots.sha256).

The manual rebuild record is repository-only and needs no screenshot: a
picture of Markdown does not prove a rebuild. It must instead cite the actual
Phase 4–8 hands-on images and searchable evidence. Do not capture a password
or sudo prompt, Red Hat identity value, consumer UUID, organization value,
token, full repository URL, authenticated URL, or unrelated VM inventory.

## Phase 9 — Retention Or Disposal Decision

**Status:** `RETAIN-Q011` selected; both hands-on images captured, reviewed,
copied byte-for-byte, and integrity-manifested on 2026-07-21.

**Retained hands-on filenames:**

1. `evidence/screenshots/q011-phase9-01-retained-vm-off.png` — Hyper-V Manager
   cropped to Q011's name and Off state, excluding unrelated VM rows.
2. `evidence/screenshots/q011-phase9-02-retained-network-isolation.png` — Q011
   Settings showing the single adapter Not connected and VLAN identification
   disabled.

Both appear inside the completed Phase 9 narrative and the
[Phase 9 walkthrough](../evidence/q011-phase9-visual-walkthrough.md), with
exact hashes in the
[Phase 9 screenshot manifest](../evidence/q011-phase9-screenshots.sha256).
The documented host name `WIN-PRQD8TJG04M` is permitted; IP addresses,
credentials, and unrelated inventory are not present.

`PLAN-DISPOSAL-Q011` was not selected. No cleanup occurred and no disposal
screenshot exists. Every later separately approved decommission window must
define its own hands-on before/after screenshots.

## Presentation Standard

- Place screenshots inside the phase narrative they prove, never in a detached
  gallery.
- Use the repository's 900-pixel HTML wrapper when rendering screenshots:

```html
<p align="center">
  <img src="../evidence/screenshots/example.png"
       alt="Concise description of the verified state"
       width="900">
</p>
```

- Add a nearby sentence stating exactly what the image proves and what it does
  not prove.
- Display at most two images in one phase; route additional useful proof to a
  linked evidence-details page.
- Retain original PNGs without cosmetic editing beyond safe cropping or
  redaction. Record any redaction explicitly.
