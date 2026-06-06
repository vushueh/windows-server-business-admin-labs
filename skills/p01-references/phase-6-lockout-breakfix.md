# Phase 6 — Break/Fix: Account Lockout Exercise

## Goal
Prove Phase 2 lockout policy works. Lock `testuser` deliberately, observe in ADUC and Event Viewer,
unlock, then disable permanently and quarantine.

---

## Pre-Phase Check

```powershell
Get-ADUser -Identity "testuser" -Properties Enabled, LockedOut, BadLogonCount |
    Select-Object SamAccountName, Enabled, LockedOut, BadLogonCount
```
**Expected:** Enabled=True, LockedOut=False, BadLogonCount=0

---

## Track A — GUI Steps

### Step A1 — Set testuser password (run in RDP session — Read-Host unreliable over SSH)

1. ADUC → find `testuser` → right-click → **Reset Password**
2. Set password: 14+ characters (Phase 2 policy is active)
3. Uncheck "User must change password at next logon" → OK

**Screenshot to capture:** Reset Password dialog

### Step A2a — Validate that the test method creates a network logon failure

Preferred method: run the bad-login test from another domain-joined Windows machine.
Fallback method: run it from the DC against `\\WIN-PRQD8TJG04M\IPC$`, but validate one failed attempt first.

```powershell
$Start = Get-Date

net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\testuser "WrongPassword123!" 2>&1
net use \\WIN-PRQD8TJG04M\IPC$ /delete 2>&1 | Out-Null
Start-Sleep -Seconds 3

$Event = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$Start} |
    Where-Object {$_.Message -match 'testuser'} |
    Select-Object -First 1

if (-not $Event -or $Event.Message -notmatch 'Logon Type:\s+3') {
    throw "Expected Event 4625 with Logon Type 3 was not confirmed. Run this exercise from a different domain-joined client."
}

$Event | Select-Object TimeCreated, Id,
    @{N="Summary";E={$_.Message.Split("`n")[0..8] -join " | "}}
```

**Screenshot to capture:** Event Viewer → Security → Event 4625 showing `testuser` and `Logon Type: 3`

### Step A2b — Trigger the lockout (5 bad attempts)

After Step A2a confirms Event 4625 / Logon Type 3, run the full lockout loop:

```powershell
1..6 | ForEach-Object {
    $attempt = $_
    $result = net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\testuser "WrongPassword123!" 2>&1
    Write-Host "Attempt ${attempt}: $result"
    net use \\WIN-PRQD8TJG04M\IPC$ /delete 2>&1 | Out-Null
    Start-Sleep -Seconds 1
}
```

### Step A3 — Observe in ADUC

1. In ADUC, find `testuser` — a small padlock icon appears on the user object
2. Double-click `testuser` → **Account** tab — verify "Unlock account" checkbox

**Screenshot to capture:** testuser in ADUC showing the locked padlock icon

### Step A4 — Find the lockout in Event Viewer

Open: **Start → Windows Administrative Tools → Event Viewer**

1. Expand **Windows Logs → Security**
2. Click **Filter Current Log** → enter Event ID `4740` → OK
3. Click the most recent event — details show Account Name = testuser

**Screenshot to capture:** Event Viewer → Security → Event 4740 details pane

Also filter for **4625** (failed logons) to show the bad attempts before the lockout.

### Step A5 — Unlock in ADUC

1. Double-click `testuser` → **Account** tab → check **Unlock account** → Apply → OK

**Screenshot to capture:** Account tab before unlock (Unlock account checked)

### Step A6 — Disable and quarantine testuser

1. Right-click `testuser` → **Disable Account**
2. Create **Quarantine** OU if it doesn't exist:
   - Right-click Chongong.local → New → Organizational Unit → `Quarantine`
   - Uncheck "Protect from accidental deletion" → OK
3. Right-click disabled `testuser` → **Move** → select **Quarantine** → OK

**Screenshot to capture:** testuser in Quarantine OU with disabled account indicator

---

## Track B — PowerShell Verification

```powershell
# Verify lockout
Get-ADUser -Identity "testuser" -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt |
    Select-Object SamAccountName, LockedOut, BadLogonCount, LastBadPasswordAttempt

# Event 4740 in Security log
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740} -MaxEvents 5 |
    Select-Object TimeCreated, @{N="Info";E={$_.Message.Split("`n")[0..2] -join " | "}}

# Failed logon evidence: 4625 / Logon Type 3
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 20 |
    Where-Object {$_.Message -match 'testuser' -and $_.Message -match 'Logon Type:\s+3'} |
    Select-Object TimeCreated, Id,
        @{N="Info";E={$_.Message.Split("`n")[0..8] -join " | "}}

# Unlock
Unlock-ADAccount -Identity "testuser"
Get-ADUser -Identity "testuser" -Properties LockedOut | Select-Object SamAccountName, LockedOut

# Disable + quarantine
Disable-ADAccount -Identity "testuser"
$DomainDN = (Get-ADDomain).DistinguishedName
try {
    Get-ADOrganizationalUnit -Identity "OU=Quarantine,$DomainDN" -ErrorAction Stop | Out-Null
} catch {
    New-ADOrganizationalUnit -Name "Quarantine" -Path $DomainDN `
        -Description "Disabled accounts awaiting deletion review" -ProtectedFromAccidentalDeletion $false
}
Move-ADObject -Identity (Get-ADUser -Identity "testuser").DistinguishedName `
    -TargetPath "OU=Quarantine,$DomainDN"
Get-ADUser -Identity "testuser" -Properties Enabled, DistinguishedName |
    Select-Object SamAccountName, Enabled, DistinguishedName
```
**Expected:** Enabled=False, DN shows OU=Quarantine

**Key Event IDs:** 4625=failed logon, 4740=locked out, 4767=unlocked, 4771=Kerberos pre-auth failed

---

## Documentation Checklist — Phase 6

- [ ] Screenshot: validation Event 4625 showing testuser and Logon Type 3 before full loop
- [ ] Screenshot: testuser locked padlock icon in ADUC
- [ ] Screenshot: Event Viewer → Event 4740 details (testuser locked out)
- [ ] Screenshot: Event 4625 (failed logons before lockout)
- [ ] Screenshot: ADUC Account tab before unlock
- [ ] Screenshot: testuser in Quarantine OU (disabled)
- [ ] PowerShell: LockedOut=True confirmed
- [ ] PowerShell: Unlock confirmed
- [ ] PowerShell: testuser disabled + in Quarantine
- [ ] Quarantine OU created
