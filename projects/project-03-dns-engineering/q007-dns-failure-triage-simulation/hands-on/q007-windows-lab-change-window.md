# Q007 Windows Hands-On Change Window

| Field | Prepared value |
|---|---|
| Status | Phases 0–5 complete / wrong record active / Phase 6 not approved |
| Change owner and operator | Leonel |
| Guide and validation | Codex |
| Target host | Existing Hyper-V host; exact current state to be recorded privately at Phase 0 |
| New host objects | `Q007-Private` and `Q007-DNS01` only |
| Production service change | None intended |
| Earliest execution | 2026-07-15 after the recorded approval below |

## Purpose

Create one disposable Windows Server DNS lab that mirrors the completed Q007
extra-A-record simulation. The lab gives Leonel real Hyper-V, Server Manager,
DNS Manager, and PowerShell practice while remaining separated from production
DNS, AD, DHCP, domain controllers, and physical networks.

## Exact Scope

The approved change, when granted, may include only:

- creating a Private Hyper-V switch named `Q007-Private`;
- creating one Generation 2 VM named `Q007-DNS01` with 2 vCPU, 4 GB startup
  memory, one 40 GB dynamically expanding VHDX, one DVD drive, and one adapter
  connected only to `Q007-Private`;
- installing Windows Server from the already-owned, validated ISO;
- configuring two private guest addresses with no gateway;
- installing the DNS Server role in the standalone guest;
- creating, testing, and removing the file-backed `q007.test` zone; and
- powering off and retaining the VM after evidence collection.

It does not include attaching any existing switch, adding an External or
Internal adapter, joining a domain, contacting production DNS, changing a
domain controller, uninstalling Hyper-V, deleting host objects, or publishing
evidence.

## Phase 0 Current-State Record

Complete before approval:

| Check | Required result | Actual result |
|---|---|---|
| `Q007-DNS01` exists | `False` | Pass — `False` |
| `Q007-Private` exists | `False` | Pass — `False` |
| Windows Server ISO exists | `True`; exact path kept private if necessary | Pass — `SERVER_EVAL_x64FRE_en-us.iso`; accepted hash, signed setup/EFI, and dismount checks passed |
| Q007 VM storage root exists | `True` | Pass — VHD root is on `D:` |
| Storage free space | Sufficient for 40 GB dynamic VHDX and working headroom | Pass — 904.7 GB free |
| Host health | No active Hyper-V/storage incident | Pass — Leonel confirmed no backup, migration, storage maintenance, or active host incident immediately before approval |
| Execution window | Date, start, and stop time recorded | 2026-07-15; start is Leonel's first Phase 2A action; stop at Phase 2 validation or any stop trigger |

## Recorded Approval

Leonel approved this exact scope on 2026-07-15:

> I confirm no Hyper-V backup, migration, storage maintenance, or active host
> incident is underway. I approve the previously defined Q007 Phase 2 switch,
> ISO copy, VM creation, and standalone Windows Server installation scope. No
> other changes are approved.

The approved implementation is limited to copying the hash-validated
`SERVER_EVAL_x64FRE_en-us.iso` to `D:\Hyper-V\ISOs` without deleting its
source; creating `Q007-Private`; and creating/installing `Q007-DNS01` with the
fixed resources, Private-only adapter, and standalone workgroup boundary in
the reviewed guide.

Approval for guest IP/DNS configuration after Phase 2, documentation
publication, commit, push, merge, or later deletion remains separate.

Leonel granted a narrow Phase 2B boot-remediation approval on 2026-07-16:

> am giving you approval to fix that and start the installation

This permits powering off only the uninstalled `Q007-DNS01` if necessary,
reasserting its already approved staged DVD attachment, Windows Secure Boot
template, and DVD-first boot order, restarting that VM, and completing the
standalone Windows Server installation. It does not permit changing another
VM, switch, disk, adapter, ISO, host service, production system, or Phase 3
guest networking/DNS configuration.

Leonel granted the exact Phase 3 approval on 2026-07-16:

> I approve Q007 Phase 3 only: rename the guest to Q007-DNS01, restart it,
> create the evidence transcript, configure 10.77.7.2/24 and 10.77.7.10/24 on
> its single Private-switch adapter, use no default gateway, and set its DNS
> client to 10.77.7.2. No other changes are approved.

The fresh Phase 2 precheck immediately before this approval proved Windows
Server 2022 Standard Evaluation build 20348, `WORKGROUP`, and
`PartOfDomain=False`. The approved executor is Leonel at the guest console.
The rollback is to stop at the first failed assertion, preserve the output,
shut down only `Q007-DNS01`, and leave it Off for review. This approval does
not include installing the DNS role, creating a zone or record, injecting a
fault, attaching another switch, deleting anything, committing, or pushing.

Leonel granted the exact Phase 4 approval on 2026-07-16:

> I approve Q007 Phase 4 only: install the DNS Server role and management
> tools on the isolated standalone guest, create the file-backed primary zone
> q007.test with dynamic updates disabled, and create only the files A record
> for 10.77.7.10. Do not install AD DS, DHCP, or another role; do not create a
> PTR, forwarder, delegation, or production DNS object. No other changes are
> approved.

The fresh entry evidence is the accepted Phase 3 output: one Up Private-switch
adapter, exactly the two fixed lab addresses, self-DNS only, no IPv4 or IPv6
default route, `PartOfDomain=False`, and `Phase3Pass=True`. The approved
executor is Leonel in Server Manager, DNS Manager, and guest PowerShell. If
the role, service, zone, or baseline record differs from the fixed design,
preserve the output, shut down only `Q007-DNS01`, and leave it Off for review.
This approval does not include fault injection, record removal, cleanup,
deletion, commit, or push.

Leonel granted the exact Phase 5 approval on 2026-07-17:

> I approve Q007 Phase 5 only: query files.q007.test directly against
> 10.77.7.2 and require the exact baseline 10.77.7.10; confirm 10.77.7.99 does
> not respond; add only one extra files A record for 10.77.7.99 with a
> five-minute TTL in q007.test; clear only the guest DNS client cache; then run
> six direct full-answer queries and reachability tests for the good and wrong
> addresses. Do not create a PTR, remove or repair a record, change another
> zone or DNS setting, or contact production. No other changes are approved.

The fresh entry evidence is the accepted 2026-07-17 resume output: exactly the
two fixed interface addresses, self-DNS only, no default route,
`PartOfDomain=False`, DNS running, the unchanged file-backed non-AD zone, one
good A record, and `ResumePass=True`. Leonel remains the manual guest executor.
Stop before injection if the baseline is not exactly `10.77.7.10` or the wrong
address responds. This approval does not include repair/removal, cleanup,
deletion, commit, or push.

## Implementation And Validation Gates

### Execution Record

- **2026-07-16 — Media staging:** destination ISO exists under
  `D:\Hyper-V\ISOs`, its SHA-256 equals the approved hash, and the source still
  exists.
- **2026-07-16 — Phase 2A:** `Q007-Private` was created and validated as type
  Private with no physical-adapter interface description.
- **2026-07-16 — Phase 2B:** `Q007-DNS01` and its dynamic 40 GB VHDX were
  created. Initial validation found 1 vCPU, non-fixed startup-memory entries,
  and the source ISO path; Leonel corrected them within the approved VM scope.
  Final host output showed an Off Generation 2 VM with 2 vCPU, 4 GB static
  startup memory, one adapter on `Q007-Private`, Secure Boot using the
  Microsoft Windows template, and the staged ISO path.
- **2026-07-16 — Phase 3:** Leonel renamed the standalone guest to
  `Q007-DNS01`, restarted it, started the evidence transcript, and configured
  only `10.77.7.2/24` plus `10.77.7.10/24` with `SkipAsSource=True` on the one
  Up adapter. Final output showed DNS client `10.77.7.2`, no IPv4 or IPv6
  default route, `PartOfDomain=False`, and `Phase3Pass=True`.
- **2026-07-16 — Phase 4A:** Leonel installed only the DNS Server role and
  management tools. Validation showed both installed, AD DS and DHCP still
  available, and the DNS service running automatically.
- **2026-07-16 — Phase 4B:** Leonel created the file-backed, non-AD-integrated
  `q007.test` primary zone with dynamic updates disabled and only the `files`
  A record for `10.77.7.10`. PowerShell returned `Phase4Pass=True`; DNS Manager
  showed the exact record properties and no PTR selection.
- **Current stop point:** Phase 4 evidence is accepted. Stop the transcript,
  shut down only `Q007-DNS01` normally, and retain the VM Off on
  `Q007-Private` overnight. Phase 5 is not started or approved. Resume with a
  fresh read-only Phase 4 validation and append to the same transcript before
  any new approval.
- **2026-07-17 — Resume validation:** Leonel started the retained VM, appended
  to the transcript, and passed the full isolation, DNS service, zone, and
  single-good-record check with `ResumePass=True` before the Phase 5 approval.
- **Current stop point:** Phase 5 is approved, but its baseline query and
  bad-address liveness gate have not started. Fault injection must wait for
  Codex to accept that output.
- **2026-07-17 — Phase 5 baseline gate:** the direct query returned exactly
  `10.77.7.10`, `10.77.7.99` did not respond, and
  `Phase5BaselinePass=True`. Codex accepted the clean screenshot. The approved
  one-record injection and six-query fault proof remain unstarted.
- **2026-07-17 — Phase 5 fault:** Leonel added only
  `files -> 10.77.7.99` at five minutes and cleared only the guest cache. Both
  records appeared in DNS Manager, all six direct queries returned both
  values, the good target was reachable, the bad target was not, and
  `Phase5FaultPass=True`. A failed supplemental `ping.exe` exit-code assertion
  was preserved and corrected with passing `Test-NetConnection` semantics.
- **Current stop point:** the wrong record is intentionally active only in the
  isolated guest. Phase 6 exact preview/removal and repaired-state tests are
  not started or approved. Do not remove either record without that approval.
- **2026-07-17 — Resume validation:** Leonel started the retained VM, appended
  to the transcript, and passed the full isolation, DNS service, zone, and
  single-good-record check with `ResumePass=True`. Phase 5 remains unstarted
  and unapproved.

| Gate | Change | Required validation before continuing |
|---:|---|---|
| 0 | None; read-only precheck | Names unused, paths valid, capacity and host health acceptable |
| 1 | None; scenario review | Expected good, bad, and negative answers fixed in writing |
| 2 | Create switch and VM | Private switch, one VM adapter, no existing object altered |
| 3 | Configure standalone guest | Not domain joined, two lab IPs, no default route, one DNS client address |
| 4 | Install DNS and create zone | Local DNS running; file-backed, non-AD-integrated zone; one good record |
| 5 | Add one wrong record | Full answer set contains exactly good and wrong values |
| 6 | Remove only wrong record | Three exact positive passes and one NXDOMAIN result |
| 7 | Read-only operator validation | Service, zone, record, and isolation state pass |
| 8 | Evidence intake | Screenshots and transcript inspected before cleanup |
| 9 | Remove zone and power off | Zone absent; VM Off and retained |

## Stop Triggers

Stop the window without improvising when:

- a fixed Q007 object name already exists;
- any existing Hyper-V object would be edited;
- the switch is not Private or a physical adapter appears;
- the guest has multiple adapters, a default gateway, or domain membership;
- the wrong IP is already in use;
- role or zone creation targets anything other than the standalone guest;
- a validation assertion fails or output differs from the guide;
- evidence exposes a secret or unrelated system; or
- rollback would require deleting a host object or changing production.

Use the [rollback plan](q007-windows-lab-rollback-plan.md) and preserve the
failed output. A failed assertion is evidence and must not be edited into a
pass.

## Expected Impact

- **Hyper-V host:** small storage, memory, processor, and configuration use
  during the approved window; no physical NIC binding is intended.
- **Production network:** no route or switch path from the guest.
- **Identity and DNS:** no domain join, AD integration, delegation, forwarder,
  conditional forwarder, DHCP, or production-zone change.
- **User impact:** none expected outside the disposable guest.

## Evidence And Closure

The [operator practicum](q007-windows-dns-operator-practicum.md) and
[screenshot plan](q007-windows-screenshot-plan.md) name every required result.
Close the change window only after the test zone is absent, the transcript is
stopped, and the Q007 VM is Off. Retain the VM, VHDX, switch, and evidence until
separate acceptance and deletion decisions are recorded.
