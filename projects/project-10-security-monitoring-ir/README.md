# Project 10 — Security Monitoring and Incident Response

**Status:** ⬜ Planned (requires Projects 05 and 09 complete)
**Skill:** `/winserver-p10` — written when this project starts

## Objective

Deploy Windows Event Forwarding (WEF) to centralize security logs from all servers.
Install Wazuh agent on WIN-PRQD8TJG04M to forward AD and Windows telemetry to the
Wazuh SIEM (in the Blue Team homelab). Build and execute incident response playbooks
for account lockout and privilege escalation scenarios.

**Why tenth:** GPO audit policy (P05) and the full server fleet (P06–P09) must exist
before centralized event collection makes sense. Security monitoring is the feedback
loop that proves every security control from P01–P09 actually works.

## Environment Context

- Log source servers: WIN-PRQD8TJG04M (PDC), WIN-DC02, WIN-FS01, WIN-RDS01, WIN-WS01
- WEF collector: WIN-PRQD8TJG04M (also the DC — acceptable for lab scale)
- Wazuh SIEM: existing Wazuh server in Blue Team family (cross-family integration)
- Key event IDs to capture: 4624, 4625, 4634, 4648, 4740, 4728, 4732, 4756, 7045, 4697

## Critical Windows Event IDs

| Event ID | Meaning | Why It Matters |
|----------|---------|---------------|
| 4624 | Successful logon | Baseline — all logons |
| 4625 | Failed logon | Brute force indicator |
| 4634 | Logoff | Session duration tracking |
| 4648 | Explicit credential logon | Pass-the-hash indicator |
| 4740 | Account lockout | Operational + security |
| 4728/4732/4756 | Group membership change | Privilege escalation indicator |
| 7045 | New service installed | Malware persistence indicator |
| 4697 | Service installed via SCM | Same — different logging path |

## Phases

| # | Phase | Key Action |
|---|-------|------------|
| 1 | Audit Current Event Collection | Document what is logged today, where, and for how long |
| 2 | Configure WEF Subscriptions | Create source-initiated subscriptions for all member servers |
| 3 | Configure WEF GPO | Push WinRM and WEF settings to all servers via GPO |
| 4 | Verify Event Forwarding | Confirm forwarded events appear in Windows Logs\Forwarded Events |
| 5 | Custom Event Views | Build saved event viewer queries for key security event IDs |
| 6 | Wazuh Agent Install | Install Wazuh agent on WIN-PRQD8TJG04M, point to Wazuh server |
| 7 | Wazuh AD Rules | Confirm Wazuh receives and alerts on 4740, 4728, 4625 events |
| 8 | Account Lockout IR Playbook | Write and execute step-by-step: detect → identify source → remediate |
| 9 | Privilege Escalation IR Playbook | Write and execute: detect group change → investigate → remediate |
| 10 | Windows Defender Review | Audit Defender status across all servers, enable ASR rules |
| 11 | Document + Push | Playbooks committed, Wazuh dashboard screenshot, STAR summary |

## Phase Detail

### Phase 2 — WEF Subscription (Source-Initiated)
```powershell
# On collector (WIN-PRQD8TJG04M): initialize collector service, then create subscription.
wecutil qc /q:true

# wecutil cs expects a path to a subscription XML file, not inline XML.
wecutil cs C:\AdminScripts\WEF\SecurityEvents.xml
# SecurityEvents.xml defines:
#   SubscriptionType: SourceInitiated
#   EventFilter: Security log IDs 4624,4625,4634,4648,4740,4728,4732,4756,4697
#                System log ID 7045
#   DeliveryMode: Push (minimize latency)
```

### Phase 3 — WEF GPO Settings
```
Computer Configuration → Policies → Administrative Templates → Windows Components →
Event Forwarding → Configure target Subscription Manager:
  Server=http://WIN-PRQD8TJG04M:5985/wsman/SubscriptionManager/WEC,Refresh=60

Computer Configuration → Policies → Administrative Templates → Windows Components →
Event Log Service → Security → Configure log access:
  O:BAG:SYD:(A;;0xf0005;;;SY)(A;;0x5;;;BA)(A;;0x1;;;S-1-5-32-573)
```

### Phase 8 — Account Lockout IR Playbook
```
Step 1: Detection
  - Event 4740 fires — account locked out
  - Run: Get-ADUser <username> -Properties LockedOut, BadLogonCount, BadPasswordTime

Step 2: Identify Source
  - Find Event 4625 (failed logons) for same account in last 30 minutes
  - Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625} |
      Where-Object {$_.Properties[5].Value -eq '<username>'}
  - Check Caller Computer Name from event data

Step 3: Determine if Malicious
  - Known device? Known location? Expected time?
  - Check 4648 (explicit credential use) from same source

Step 4: Remediate
  - If benign: Unlock-ADAccount -Identity <username>; inform user
  - If suspicious: Disable-ADAccount, quarantine source machine, escalate

Step 5: Document
  - Write incident summary: who, what, when, where, action taken
```

## Verification Commands

```powershell
# WEF working — forwarded events appearing
Get-WinEvent -LogName "ForwardedEvents" -MaxEvents 20 |
  Select-Object TimeCreated, Id, Message | Format-Table -Wrap

# Wazuh agent status
Get-Service -Name WazuhSvc -ComputerName WIN-PRQD8TJG04M

# Trigger test lockout with a dedicated enabled test account, not P01 testuser
# if P01 already disabled/quarantined that account.
if (-not (Get-ADUser -Filter "SamAccountName -eq 'test-lockout-p10'")) {
  New-ADUser -Name "test-lockout-p10" -SamAccountName "test-lockout-p10" `
    -Path "OU=Quarantine,DC=Chongong,DC=local" -Enabled $true `
    -AccountPassword (Read-Host -AsSecureString "Temporary password for test-lockout-p10")
}

1..6 | ForEach-Object {
  net use \\WIN-PRQD8TJG04M\IPC$ /user:CHONGONG\test-lockout-p10 badpassword 2>&1
  net use \\WIN-PRQD8TJG04M\IPC$ /delete 2>&1
}
# Confirm Event 4740 appears in Security log and ForwardedEvents
Get-WinEvent -FilterHashtable @{LogName='Security';Id=4740} -MaxEvents 5
```

## STAR Summary

**Situation:** Security events are generated (audit policy in P05) but not collected
centrally, not forwarded to SIEM, and no IR playbooks exist. A lockout or privilege
escalation would require manual log hunting across multiple servers.

**Task:** Deploy WEF to centralize logs, connect Wazuh agent for SIEM integration,
and build + test IR playbooks for the two most common AD security incidents.

**Action:** _(completed when project runs)_

**Result:** _(completed when project runs)_
