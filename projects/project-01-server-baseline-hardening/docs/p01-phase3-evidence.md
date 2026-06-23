# P01 Phase 3 — Tiered Admin Model — Evidence

**Date:** 2026-06-22
**Executed by:** Leonel (PowerShell, on WIN-PRQD8TJG04M)
**Reviewed by:** Claude (per-step approval, AGENTS.md Tier 3)

## OU structure created
```
_Admin                  OU=_Admin,DC=Chongong,DC=local
ServiceAccounts         OU=ServiceAccounts,OU=_Admin,DC=Chongong,DC=local
Tier0-DomainAdmins      OU=Tier0-DomainAdmins,OU=_Admin,DC=Chongong,DC=local
Tier1-ServerAdmins      OU=Tier1-ServerAdmins,OU=_Admin,DC=Chongong,DC=local
Tier2-WorkstationAdmins OU=Tier2-WorkstationAdmins,OU=_Admin,DC=Chongong,DC=local
```

## Account creation incident (resolved, no lasting impact)
`New-ADUser -AccountPassword ... -Enabled $true` failed both times with
`ADPasswordComplexityException` on the simultaneous enable step, even though
`PasswordLastSet` showed the password attribute was actually written. Both accounts
were left in AD as **disabled, no real login possible** — no security exposure.

Resolved by separating the steps: `Set-ADAccountPassword -Identity <user> -Reset
-NewPassword <SecureString>` followed by a standalone `Enable-ADAccount`.

**Incident note:** during one retry, a password was pasted directly onto the command
line instead of into a masked `Read-Host` prompt, exposing it in plaintext in the
terminal scrollback and chat transcript. Both `adm-leonel` and `srv-leonel` passwords
were immediately reset again via properly masked `Read-Host -AsSecureString` prompts.
Final state confirmed clean — see verification below. No secret values are recorded
in this repo.

## Final account state
| Account | Enabled | PasswordLastSet (final) | Tier |
|---|---|---|---|
| adm-leonel | True | 6/22/2026 9:18:46 PM | 0 (Domain Admins) |
| srv-leonel | True | 6/22/2026 9:19:07 PM | 1 (GG-ServerAdmins only) |

## Group membership verification
```
srv-leonel -> Domain Users, GG-ServerAdmins   (NO built-in groups — confirmed clean)
adm-leonel -> GG-Tier0-Admins, Domain Admins
```

## PSO verification
```
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel"
Name: PSO-Tier0-Admins   Precedence: 10
```
Confirms `adm-leonel` is governed by the Tier 0 fine-grained password policy
(min 20 chars, lockout threshold 3, 60-min duration/window), not the Default Domain
Policy.

## Unplanned critical finding — Domain Admins over-provisioning
While verifying `adm-leonel`'s membership, `Domain Admins` was found to contain
**12 members**, not the expected 1-2:
```
Administrator, lionel.chongong, joiceline.kinyuy, mickelle.tsongwine, achiril.desmond,
chongong.leonel, gefter.mbi, michell.chongong, elsa.chongong, vushueh.banks,
akaseng.frankline, testuser, adm-leonel
```
This gap was **not captured in the original Phase 1 audit findings table** — it was
discovered mid-Phase-3 while verifying the new tiered model. Notably `testuser` (the
account planned for the Phase 6 lockout exercise) was a Domain Admin.

**Decision (Leonel, explicit):** keep only `Administrator`, `adm-leonel`, and
`chongong.leonel` as Domain Admins. Remove the remaining 9 personal accounts plus
`testuser`. **No accounts were deleted** — this is a group-membership change only;
every account continues to exist and function normally outside of Domain Admins.

**Design note:** the original P01 plan assumed the day-to-day account (`chongong.leonel`)
would be removed from Domain Admins too, since the purpose of `adm-leonel` is to
separate everyday login from admin actions. Leonel made an informed, explicit
decision to keep `chongong.leonel` as a Domain Admin as well — documented here as a
deliberate deviation from the original tiered-admin design, not an oversight.

**Result after remediation:**
```
Get-ADGroupMember -Identity "Domain Admins" | Select-Object SamAccountName
Administrator
chongong.leonel
adm-leonel
```
Confirmed exactly as intended.

## Documentation Checklist — Phase 3
- [x] _Admin OU + 4 sub-OUs created
- [x] adm-leonel: Domain Admins + GG-Tier0-Admins, enabled, PSO-Tier0-Admins applies
- [x] srv-leonel: Domain Users + GG-ServerAdmins only, enabled, no built-in groups
- [x] GG-Tier0-Admins, GG-ServerAdmins created
- [x] PSO-Tier0-Admins active, precedence 10, applies to adm-leonel
- [x] Domain Admins over-provisioning found and remediated (unplanned, documented above)
- [ ] Screenshots not captured — this phase was executed entirely via PowerShell/SSH,
      not the GPMC/ADUC GUI track. Acceptable for evidence purposes (all state is
      independently verifiable via the PowerShell output above); add GUI screenshots
      later only if the portfolio writeup needs visual evidence.
