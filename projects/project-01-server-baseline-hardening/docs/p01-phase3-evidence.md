# P01 Phase 3 — Tiered Admin Model

**Date:** 2026-06-22
**Who ran it:** Leonel, on `WIN-PRQD8TJG04M`, in PowerShell
**Script:** [`../scripts/p01-phase3-tiered-admin.ps1`](../scripts/p01-phase3-tiered-admin.ps1)

## Step 1 — Create the `_Admin` OU structure

**Command:**
```powershell
$DomainDN = (Get-ADDomain).DistinguishedName
New-ADOrganizationalUnit -Name "_Admin" -Path $DomainDN -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier0-DomainAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "Tier1-ServerAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "Tier2-WorkstationAdmins" -Path "OU=_Admin,$DomainDN"
New-ADOrganizationalUnit -Name "ServiceAccounts" -Path "OU=_Admin,$DomainDN"
```

**Verify:**
```powershell
Get-ADOrganizationalUnit -Filter * | Where-Object {$_.DistinguishedName -match "_Admin"} | Select-Object Name, DistinguishedName | Sort-Object DistinguishedName
```

**Output:**
```
_Admin                  OU=_Admin,DC=Chongong,DC=local
ServiceAccounts         OU=ServiceAccounts,OU=_Admin,DC=Chongong,DC=local
Tier0-DomainAdmins      OU=Tier0-DomainAdmins,OU=_Admin,DC=Chongong,DC=local
Tier1-ServerAdmins      OU=Tier1-ServerAdmins,OU=_Admin,DC=Chongong,DC=local
Tier2-WorkstationAdmins OU=Tier2-WorkstationAdmins,OU=_Admin,DC=Chongong,DC=local
```

## Step 2 — Create `adm-leonel` and `srv-leonel`

**Command (what was actually run, including the fix):**
```powershell
$admPwd = Read-Host -AsSecureString -Prompt "New password for adm-leonel"
New-ADUser -Name "adm-leonel" -SamAccountName "adm-leonel" -UserPrincipalName "adm-leonel@Chongong.local" `
    -Path "OU=Tier0-DomainAdmins,OU=_Admin,$DomainDN" `
    -AccountPassword $admPwd -Enabled $true -PasswordNeverExpires $false -ChangePasswordAtLogon $false
```

**This failed the first time:**
```
New-ADUser : The password does not meet the length, complexity, or history requirement of the domain.
```

Same failure for `srv-leonel`. Both accounts were created in AD anyway — disabled,
password not actually usable. No security exposure (disabled accounts can't log in).

**Cause:** `New-ADUser` with `-AccountPassword` and `-Enabled $true` in the same call
fails the enable step separately from the password-set step on this server. Fixed by
splitting it into two calls:

```powershell
Set-ADAccountPassword -Identity "adm-leonel" -Reset -NewPassword $admPwd
Enable-ADAccount -Identity "adm-leonel"

Set-ADAccountPassword -Identity "srv-leonel" -Reset -NewPassword $srvPwd
Enable-ADAccount -Identity "srv-leonel"
```

This still failed once more with the same complexity error — the actual root cause
was the password itself not meeting AD's complexity rule (needs 3 of: uppercase,
lowercase, digit, symbol — a long passphrase of plain words fails this regardless of
length). Both passwords were reset a second time, this time meeting complexity.

**Incident:** during one retry, a password was typed directly onto the command line
instead of into the masked `Read-Host` prompt, so it appeared in plaintext in the
terminal and got pasted into chat. Both `adm-leonel` and `srv-leonel` passwords were
reset again immediately afterward, properly masked this time. No password value is
stored anywhere in this repo.

**Final verify:**
```powershell
Get-ADUser -Identity "adm-leonel" -Properties Enabled, PasswordLastSet | Select-Object SamAccountName, Enabled, PasswordLastSet
Get-ADUser -Identity "srv-leonel" -Properties Enabled, PasswordLastSet | Select-Object SamAccountName, Enabled, PasswordLastSet
```

**Output:**
```
SamAccountName Enabled PasswordLastSet
-------------- ------- ---------------
adm-leonel        True 6/22/2026 9:18:46 PM

SamAccountName Enabled PasswordLastSet
-------------- ------- ---------------
srv-leonel        True 6/22/2026 9:19:07 PM
```

## Step 3 — Groups

**Command:**
```powershell
$GroupsOU = (Get-ADOrganizationalUnit -Filter {Name -eq "Groups"} | Select-Object -First 1).DistinguishedName
New-ADGroup -Name "GG-Tier0-Admins" -GroupScope Global -GroupCategory Security -Path $GroupsOU -Description "Shadow group for Tier0 PSO"
Add-ADGroupMember -Identity "GG-Tier0-Admins" -Members "adm-leonel"
New-ADGroup -Name "GG-ServerAdmins" -GroupScope Global -GroupCategory Security -Path $GroupsOU -Description "Tier1 server admins - rights granted via GPO in P05"
Add-ADGroupMember -Identity "GG-ServerAdmins" -Members "srv-leonel"
Add-ADGroupMember -Identity "Domain Admins" -Members "adm-leonel"
```

**Verify `srv-leonel` has no built-in admin group:**
```powershell
Get-ADPrincipalGroupMembership -Identity "srv-leonel" | Select-Object Name, GroupScope
```

**Output:**
```
Name            GroupScope
----            ----------
Domain Users        Global
GG-ServerAdmins     Global
```

Only `Domain Users` and `GG-ServerAdmins`. No `Server Operators`, no
`Administrators`. This is the whole point of Tier 1 — confirmed.

## Step 4 — PSO (Fine-Grained Password Policy for Tier 0)

**Command:**
```powershell
New-ADFineGrainedPasswordPolicy -Name "PSO-Tier0-Admins" -Precedence 10 -MinPasswordLength 20 `
    -LockoutThreshold 3 -LockoutDuration (New-TimeSpan -Minutes 60) -LockoutObservationWindow (New-TimeSpan -Minutes 60) `
    -MaxPasswordAge (New-TimeSpan -Days 180) -MinPasswordAge (New-TimeSpan -Days 1) `
    -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false
Add-ADFineGrainedPasswordPolicySubject -Identity "PSO-Tier0-Admins" -Subjects "GG-Tier0-Admins"
```

**Verify:**
```powershell
Get-ADUserResultantPasswordPolicy -Identity "adm-leonel" | Select-Object Name, Precedence
```

**Output:**
```
Name             Precedence
----             ----------
PSO-Tier0-Admins         10
```

`adm-leonel` is governed by the Tier 0 policy (20-char min, lockout after 3), not the
Default Domain Policy.

## Step 5 — Unplanned finding: Domain Admins had 12 members

While checking `adm-leonel`'s group membership, `Domain Admins` turned out to have
12 members — not flagged anywhere in the original Phase 1 audit:

```powershell
Get-ADGroupMember -Identity "Domain Admins" | Select-Object SamAccountName
```

**Output (before fix):**
```
Administrator
lionel.chongong
joiceline.kinyuy
mickelle.tsongwine
achiril.desmond
chongong.leonel
gefter.mbi
michell.chongong
elsa.chongong
vushueh.banks
akaseng.frankline
testuser
adm-leonel
```

10 personal accounts plus `testuser` had full Domain Admin rights. Leonel decided
who stays: `Administrator`, `adm-leonel`, `chongong.leonel`. Everyone else comes out
of the group — **accounts are not deleted**, they keep working normally, they just
lose Domain Admin rights.

**Command:**
```powershell
Remove-ADGroupMember -Identity "Domain Admins" -Members `
    "lionel.chongong", "joiceline.kinyuy", "mickelle.tsongwine", "achiril.desmond", `
    "gefter.mbi", "michell.chongong", "elsa.chongong", "vushueh.banks", `
    "akaseng.frankline", "testuser" -Confirm:$false
```

**Verify:**
```powershell
Get-ADGroupMember -Identity "Domain Admins" | Select-Object SamAccountName
```

**Output (after fix):**
```
Administrator
chongong.leonel
adm-leonel
```

Exactly the three accounts Leonel chose. Note: the original P01 design assumed
`chongong.leonel` (the everyday account) would also come out of Domain Admins, since
the point of `adm-leonel` is to separate daily login from admin actions. Leonel chose
to keep `chongong.leonel` as Domain Admin too. That's his explicit call, not an
oversight, and it's not being revisited here.

**Rollback if ever needed** (re-adds membership only, doesn't touch anything else):
```powershell
Add-ADGroupMember -Identity "Domain Admins" -Members `
    "lionel.chongong", "joiceline.kinyuy", "mickelle.tsongwine", "achiril.desmond", `
    "gefter.mbi", "michell.chongong", "elsa.chongong", "vushueh.banks", `
    "akaseng.frankline", "testuser"
```

## Result

Phase 3 is done: `_Admin` OU live, `adm-leonel`/`srv-leonel` created and verified
clean, PSO active, Domain Admins cut from 12 members down to 3. No screenshots —
this phase ran entirely in PowerShell.
