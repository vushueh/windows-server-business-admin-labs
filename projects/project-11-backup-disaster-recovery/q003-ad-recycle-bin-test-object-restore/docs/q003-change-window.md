# Change Window — Q003 AD Recycle Bin Test-Object Restore

- **Execution date:** 2026-07-14, after a fresh precheck passed that day
- **Household impact:** None expected
- **Approved by Leonel:** YES — exact `Q003-20260714-LEONEL` statement recorded in chat on 2026-07-14
- **Executor:** Leonel launches the reviewed script from the authenticated PDC console; Claude and Codex supervise and verify because SSH key authentication cannot delegate the domain credential to `WIN-DC02`
- **Systems touched:** `Chongong.local` through `WIN-PRQD8TJG04M`; replication
  verified through `WIN-DC02`
- **Risk:** `LIVE-LOW`, with one narrowly approved test-object deletion
- **Script:** [`../scripts/q003-ad-recycle-bin-test.ps1`](../scripts/q003-ad-recycle-bin-test.ps1)
- **Rollback:** [`q003-rollback-plan.md`](q003-rollback-plan.md)

## Decision

I will prove AD Recycle Bin recovery with one new, disabled, non-privileged,
passwordless test user. I will not use, rename, disable, move, delete, or
restore any existing identity.

The proposed identity is:

| Property | Approved value |
|---|---|
| Name / display name | `Q003 Restore Test 2026-07-13` |
| `sAMAccountName` | `q003-restore-0713` |
| Starting and final OU | `OU=Quarantine,DC=Chongong,DC=local` |
| Enabled | `False` |
| Password | None is set |
| Explicit group membership | None |
| Description | `Q003 disposable disabled Recycle Bin restore proof - 2026-07-13` |

The live precheck must prove that the Quarantine OU already exists. If it does
not, I stop. Creating an OU is not part of this window.

## Recovery Objective

- **Recovery point objective:** exact captured attributes immediately before
  deletion; the test object has no business data or password.
- **Recovery time objective:** 30 minutes from deletion until the same GUID is
  verified, disabled, in Quarantine, and visible through both DCs.
- **Success:** the exact GUID is restored with the same safe attributes and no
  production identity or privileged membership is touched.
- **Failure:** the test object remains deleted, cannot be verified on both
  DCs, returns with unexpected state, or any production-side anomaly appears.

## Backup And Recovery Floor

| Protection | Purpose | Location / proof | Boundary |
|---|---|---|---|
| AD Recycle Bin | Object-level recovery method under test | Fresh `EnabledScopes` output from both DCs | Must be enabled before create/delete |
| Safe object baseline | Exact GUID, SID, DN, name, enabled state, description, primary group, and explicit memberships | Sanitized execution transcript | Captured after both DCs see the object and before deletion |
| Replicated test object | Confirms the exact object exists on both DCs before deletion | GUID readback from both DCs | No forced replication is used |
| DC system state | Deep recovery floor | Q002 records current recurring coverage as unconfirmed | Not used or restored in Q003; a production anomaly stops this test and requires a separate incident/change plan |

The missing confirmed system-state backup is an accepted limitation only for
this disposable object. If Recycle Bin recovery fails, losing this new test
object is acceptable and production state does not need to be changed to
recover it. I will never restore a DC checkpoint or system state merely to
recover this test identity.

## Fresh Read-Only Prechecks

Claude runs the script in `Precheck` mode and saves sanitized output before
Leonel approves execution:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\q003-ad-recycle-bin-test.ps1 -Mode Precheck
```

The precheck must prove:

1. the domain and forest are `Chongong.local`;
2. both named DCs answer AD queries and are writable;
3. `Get-ADReplicationFailure` returns no record whose `FailureCount` is greater
   than zero (zero-count historical records are retained in the evidence),
   `Get-ADReplicationPartnerMetadata` returns zero nonzero partner results,
   `repadmin /replsummary` contains no nonzero failure row, and each
   `/showrepl ... /errorsonly` command returns its structured headers with no
   `failed, result` line. This server build returns native status `234`
   (`ERROR_MORE_DATA`) for clean `/errorsonly` output on both DCs, even at the
   interactive console; the script records and accepts only that exact status
   under those exact output conditions. Every other nonzero status stops;
4. Recycle Bin has a non-empty enabled forest scope when queried through each
   DC;
5. `msDS-DeletedObjectLifetime` and `tombstoneLifetime` are read from the live
   Directory Service object and recorded without assuming a default;
6. `OU=Quarantine,DC=Chongong,DC=local` already exists;
7. no live or deleted object collides with the proposed name or
   `sAMAccountName`; and
8. the executor is using the expected script and no credential or secret value
   will be written to evidence.

The fresh 2026-07-14 run passed every gate and is saved as
[`q003-precheck-2026-07-14.txt`](../evidence/q003-precheck-2026-07-14.txt).
No AD mutation occurred during the precheck.

## Approval Gate

After the precheck passes, Leonel must approve this exact statement in chat:

> I approve Q003-20260714-LEONEL for Claude to create, delete by GUID, and
> restore only the disabled test user q003-restore-0713 in the existing
> Quarantine OU. I accept the documented object-only recovery floor and
> rollback plan. Stop on any mismatch.

The approval date and executor are copied into the evidence record. General
project approval is not substituted for this named delete/restore exception.

## Implementation

Only after the approval line above is recorded:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\q003-ad-recycle-bin-test.ps1 `
  -Mode Execute `
  -ApprovalId Q003-20260714-LEONEL
```

The script fails closed and performs these steps in order:

1. repeats every precheck;
2. creates the exact disabled, passwordless user in Quarantine;
3. waits for the same GUID to be readable through both DCs;
4. captures the safe before-state and refuses to continue if the account is
   enabled or has any explicit group membership;
5. deletes only that captured GUID on the PDC;
6. proves that exact GUID is deleted and restorable through both DCs;
7. checks `lastKnownParent` and `msDS-LastKnownRDN` against the approved values;
8. restores that exact deleted object with `Restore-ADObject -PassThru`;
9. waits for the same GUID to be live through both DCs; and
10. verifies the final disabled state, Quarantine DN, SID, description,
    primary group, and explicit memberships against the baseline.

There is no second deletion and no forced replication.

## Validation

All of these must pass:

- the script returns `Q003_RESULT=PASS`;
- the restored GUID and SID equal the captured baseline;
- `Get-ADUser -Identity <GUID> -Server WIN-PRQD8TJG04M` succeeds;
- `Get-ADUser -Identity <GUID> -Server WIN-DC02` succeeds;
- both reads show `Enabled=False`, the approved `sAMAccountName`, the approved
  Quarantine DN, the same description, the same primary group, and no explicit
  group membership;
- no deleted copy of that GUID remains restorable;
- the measured delete-to-verified-restore time is no more than 30 minutes; and
- fresh replication error-only checks remain clean.

## Stop Conditions

Stop before deletion if any precheck fails, the object name already exists,
the OU is missing, the object is enabled, explicit membership appears, the
GUID differs between DCs, replication is unhealthy, Recycle Bin scope is
empty, or evidence capture would reveal a secret.

Stop after deletion without improvising if the deleted object cannot be
identified uniquely by GUID, it is recycled rather than restorable,
`lastKnownParent` or `msDS-LastKnownRDN` differs, restore reports an error, the
restored object has unexpected attributes, replication diverges, or 30 minutes
elapse before verification.

If any real user, privileged group, default policy, DNS, DHCP, NPS, or service
shows unexpected impact, stop immediately. Do not force replication, recreate
the name, perform metadata cleanup, restore system state, or restore a DC
checkpoint under this window.

## Evidence And Screenshots

- Sanitized transcript: `../evidence/q003-sanitized-transcript.txt`
- Passing precheck: [`q003-precheck-2026-07-14.txt`](../evidence/q003-precheck-2026-07-14.txt)
- Closeout evidence: [`q003-closeout.md`](../evidence/q003-closeout.md)
- Screenshot plan: [`q003-screenshot-plan.md`](q003-screenshot-plan.md)

No password, key, token, credential prompt, public WAN address, or unrelated
identity list may appear in the evidence.

## Outcome

- **Result:** PASS — the same GUID was restored and verified through both DCs
- **Measured restore time:** 0.51 minutes from deletion to verified restore
- **Evidence:** [Passing precheck](../evidence/q003-precheck-2026-07-14.txt), [execution transcript](../evidence/q003-sanitized-transcript.txt), and [plain-language closeout](../evidence/q003-closeout.md)
- **Rollback used:** No — every gate passed; the restored account remains disabled in Quarantine
- **Review disposition:** Claude independently reviewed the full transcript; Q003 closed 2026-07-14

## Microsoft Command References

- [Restore-ADObject](https://learn.microsoft.com/en-us/powershell/module/activedirectory/restore-adobject)
- [Get-ADObject](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adobject)
- [msDS-DeletedObjectLifetime](https://learn.microsoft.com/en-us/windows/win32/adschema/a-msds-deletedobjectlifetime)
