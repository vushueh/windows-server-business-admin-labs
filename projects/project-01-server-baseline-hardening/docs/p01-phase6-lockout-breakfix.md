# Project 01 — Phase 6: Break/Fix Lockout Exercise

**Date:** 2026-06-23
**Method:** Executed directly over SSH (`winserver01`) per Leonel's approval for this
batch of live AD changes. `testuser` was already removed from Domain Admins in Phase 3
and from RDS-Users access is lost as a side effect of disabling it here — no separate
action needed for that.
**Scope:** Live AD changes made — see below. Approved in advance as a batch (password
reset, lockout test, unlock, disable, OU creation, move). No deletions of any AD object.

---

## 1. Baseline state (before)

```
SamAccountName    : testuser
DistinguishedName : CN=Test User,OU=IT,DC=Chongong,DC=local
Enabled           : True
LockedOut         : False
BadLogonCount     : 0
```

## 2. Password reset

`Set-ADAccountPassword -Identity testuser -Reset` with a randomly generated 24-char
password. **Value was never displayed, logged, or stored anywhere** — generated,
applied, and discarded in the same script execution. Confirmed via
`PasswordLastSet` updating to `6/22/2026 11:58:51 PM`.

## 3. Single failed-logon test (before full loop)

Ran one deliberate bad-password attempt (`net use \\localhost\IPC$ /user:CHONGONG\testuser
"WrongPassword1!"`) to confirm the lockout mechanism responds before running the full
5-attempt loop.

- `BadLogonCount` incremented from 0 → 1. Confirmed AD registered the failure.
- **Finding:** No corresponding Security event (4625, 4776, or 4771) was found in the
  Security log for this attempt, despite `BadLogonCount` incrementing. Checked a 20+
  minute window across all three failure-logon event IDs — nothing matched.

```
FINDING: Failed-logon events (4625/4776/4771) are not being logged for failed
  network authentication attempts against this DC, even though AD internally
  tracks BadLogonCount correctly.
SEVERITY: Medium — does not affect the lockout policy itself (which works,
  see Section 4), but limits visibility/alerting on failed-logon attempts via
  the Security event log. Relevant to future SIEM/log-forwarding work
  (Blue Team integration, Project 10/13).
LIKELY CAUSE: Advanced Audit Policy subcategories for Credential Validation /
  Logon failure auditing are not enabled in the Default Domain Controllers
  Policy (only basic/legacy auditing categories appear active). Not
  investigated further or changed this phase — flagging for whoever picks up
  GPO/audit policy work (Project 05 or Blue Team integration).
DO NOT TOUCH NOW: changing audit policy is a GPO change requiring its own
  explicit approval, out of scope for this break/fix exercise.
```

## 4. Full lockout loop

Ran 4 more failed attempts (5 total), checking `BadLogonCount`/`LockedOut` after each:

| Attempt | BadLogonCount | LockedOut |
|---------|---------------|-----------|
| 1 (single test, above) | 1 | False |
| 2 | 2 | False |
| 3 | 3 | False |
| 4 | 4 | False |
| 5 | 5 | **True** |

Lockout triggered exactly at the 5th failed attempt, matching `LockoutThreshold=5`
set in Phase 2. **The lockout policy works as designed.**

- `Search-ADAccount -LockedOut` confirmed `testuser` → `LockedOut: True`.
- **Event 4740 fired correctly** — `TimeCreated: 6/23/2026 12:03:29 AM`,
  `TargetAccount: testuser`. Unlike the failed-logon events above, the account
  lockout event itself **is** properly audited and logged. The audit gap is
  specific to failed-attempt logging, not lockout-event logging.

## 5. Unlock, disable, quarantine

1. `Unlock-ADAccount -Identity testuser` — unlocked.
2. `Disable-ADAccount -Identity testuser` — disabled.
3. `New-ADOrganizationalUnit -Name "Quarantine" -Path "DC=Chongong,DC=local"
   -ProtectedFromAccidentalDeletion $true` — new OU created (no existing OU
   touched or deleted).
4. `Move-ADObject` — `testuser` moved from `OU=IT` to the new `OU=Quarantine`.

**Final state (confirmed):**
```
SamAccountName    : testuser
DistinguishedName : CN=Test User,OU=Quarantine,DC=Chongong,DC=local
Enabled           : False
LockedOut         : False
```

No AD objects were deleted at any point in this phase, per the project's permanent
guardrail.

---

## 6. Documentation Checklist — Phase 6

- [x] testuser password reset (value never exposed)
- [x] Single failed-attempt test run first, confirmed before full loop
- [x] Full 5-attempt lockout loop run, BadLogonCount/LockedOut tracked at each step
- [x] Lockout confirmed via `Search-ADAccount -LockedOut`
- [x] Event 4740 confirmed in Security log
- [x] Account unlocked
- [x] Account disabled
- [x] Quarantine OU created (protected from accidental deletion)
- [x] testuser moved to Quarantine OU
- [x] No AD objects deleted
- [x] Audit-logging gap for failed-attempt events (4625/4776/4771) documented as a
      finding, not fixed — deferred to GPO/audit-policy work

**Phase 6 complete. Proceeding to Phase 7 (final documentation + push).**
