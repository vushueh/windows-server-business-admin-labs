# Q003 Closeout — I Restored a Deleted Active Directory Test User

**Completed:** 2026-07-14
**Result:** PASS
**Recovery time:** 0.51 minutes from deletion to verified restore
**Final state:** The test user is disabled in the Quarantine OU

## What I Proved

I proved that I can recover one deliberately deleted Active Directory user
with the AD Recycle Bin. I used a new disposable account, not a real person's
account. The same account came back with the same unique identity, remained
disabled, stayed in Quarantine, and was visible through both domain
controllers.

This closes Q003. It does not claim that the full Project 11 backup and
disaster-recovery program is complete. Q004, the test-GPO backup and restore,
is next in the master queue.

## Who Did What

| Person or assistant | What they did |
|---|---|
| **Leonel (me)** | I supplied the physical console checks, ran the read-only prechecks from my authenticated PDC session, reviewed the exact scope and rollback plan, gave the dated approval `Q003-20260714-LEONEL`, launched the reviewed live script, and supplied the final PASS result. I alone made the approval decision. |
| **Claude** | Claude independently challenged the plan, rollback, verification, and stop conditions. Claude tested the available SSH paths, identified the SSH credential-delegation limitation, reviewed every script correction, copied only reviewed scripts after matching their hashes, retrieved the evidence files, and independently checked the complete execution transcript for safety, consistency, and secrets. Claude did not approve its own work and did not run an unapproved AD change. |
| **Codex** | Codex acted as the primary assistant. Codex designed the change window, rollback ladder, screenshot plan, and fail-closed PowerShell script; coordinated Leonel and Claude; diagnosed the precheck failures; corrected and retested the script; verified the technical findings; maintained the queue order; and wrote the first-person project documentation and closeout. |

## What Happened, In Plain Language

1. I confirmed the two domain controllers, AD Recycle Bin, Quarantine OU,
   deleted-object lifetime, replication, and proposed name were safe to use.
2. I approved exactly one disposable account:
   `q003-restore-0713`.
3. The script created that account disabled, without setting a password, and
   without adding any explicit group membership.
4. The script recorded the account's unique GUID and SID before deletion.
5. It deleted only that captured GUID.
6. It confirmed the deleted record still belonged in Quarantine and had the
   expected name.
7. It restored that exact deleted object.
8. It verified the restored object through both domain controllers and stopped
   successfully with `Q003_RESULT=PASS`.

## Final Verification

| Check | Verified result |
|---|---|
| Test account | `q003-restore-0713` |
| Object GUID | `2386a6b1-8830-4457-bc5f-56da1ac493a1` before deletion and after restore |
| SID | `S-1-5-21-3193592578-3103812925-2486053872-1161` before deletion and after restore |
| Domain controllers | `WIN-PRQD8TJG04M` and `WIN-DC02` |
| Enabled state | `False` |
| Final location | `OU=Quarantine,DC=Chongong,DC=local` |
| Explicit group memberships | `0` |
| Delete-to-verified-restore time | `0.51` minutes, below the 30-minute objective |
| Final script result | `Q003_RESULT=PASS` |

No real user, group, computer, default Group Policy object, DNS setting, DHCP
setting, NPS policy, or service configuration was changed by this workflow.
The account remains disabled in Quarantine intentionally as the safe retained
proof. Removing it later would require its own reviewed change; I did not add a
second deletion merely for cleanup.

## Rollback And Stop Conditions

I did not need rollback because every gate passed. The script would have
stopped before deletion on a name collision, missing OU, unhealthy replication,
disabled Recycle Bin, unexpected membership, enabled account, or GUID mismatch.
After deletion it would have stopped without improvising if the deleted-object
guards, restore, both-DC verification, or 30-minute recovery objective failed.

The recovery floor for this exercise was the AD Recycle Bin plus the captured
object baseline. I did not restore a domain-controller checkpoint or system
state to recover one disposable account.

## What We Learned

- Claude's SSH key could reach the PDC over LAN but could not delegate Leonel's
  domain credential to query `WIN-DC02`. Running the approved script from
  Leonel's existing authenticated PDC console solved that safely.
- A replication history record can remain visible with `FailureCount=0`. The
  script now records that history but treats only a count above zero as a
  current failure, while still requiring independent replication checks.
- On both DCs, clean `repadmin /showrepl ... /errorsonly` output returned native
  status `234` (`ERROR_MORE_DATA`). The script accepts that one status only when
  the structured output is complete, contains no failed result, and the other
  replication checks are clean.
- The Tailscale endpoint remained unreachable, but LAN SSH worked. That
  connectivity issue remains a separate maintenance follow-up and did not
  weaken the supervised console execution.

## Technical Evidence

- [Change window and approval boundary](../docs/q003-change-window.md)
- [Rollback plan](../docs/q003-rollback-plan.md)
- [Reviewed PowerShell script](../scripts/q003-ad-recycle-bin-test.ps1)
- [Fresh passing precheck](q003-precheck-2026-07-14.txt)
- [Complete sanitized execution transcript](q003-sanitized-transcript.txt)
- [Final readable PASS screenshot](../screenshots/phase5-02-q003-both-dc-verification.png)
- [Screenshot plan](../docs/q003-screenshot-plan.md)

The final summary visibly prints one set of restored attributes and names both
DCs under `VerifiedThrough`. The reviewed script also compares the restored
object from each DC and throws before PASS on any mismatch. Readers who need
that implementation detail can inspect the script and full transcript above.

## Queue Handoff

Q003 is complete. Q004 — the test-GPO backup and restore proof — is now the
next master-queue project. The default domain policies remain out of scope and
must never be used as Q004's test object.
