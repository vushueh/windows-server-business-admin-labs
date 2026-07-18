# Q007 Windows Hands-On Rollback Plan

- **Status:** prepared; not executed.
- **Scope:** `Q007-DNS01`, `Q007-Private`, and the standalone `q007.test` zone
  only.
- **Primary rule:** stop at the first failed assertion, preserve the output,
  and do not touch a production or pre-existing object.

## Rollback Levels

### Level 1 — Wrong Record Exists Or Repair Validation Fails

List the exact current record set:

```powershell
Get-DnsServerResourceRecord -ZoneName 'q007.test' -Name 'files' -RRType A |
  Select-Object HostName,RecordType,@{
    Name='IPv4Address';Expression={$_.RecordData.IPv4Address}
  }
```

If and only if `10.77.7.99` exists in this disposable zone, remove that exact
value:

```powershell
Remove-DnsServerResourceRecord -ComputerName 'localhost' `
  -ZoneName 'q007.test' -Name 'files' -RRType A `
  -RecordData '10.77.7.99' -WhatIf
Remove-DnsServerResourceRecord -ComputerName 'localhost' `
  -ZoneName 'q007.test' -Name 'files' -RRType A `
  -RecordData '10.77.7.99' -Force
Clear-DnsClientCache
```

Do not use a name-only removal: without `-RecordData`, every same-name A record
could be selected. If the good record is missing, stop and send the before and
current output to Codex before restoring it.

### Level 2 — Zone Or DNS Role Is Not In The Expected State

Do not create additional zones or install additional roles. Capture:

```powershell
Get-WindowsFeature -Name DNS
Get-Service -Name DNS -ErrorAction SilentlyContinue
Get-DnsServerZone -ErrorAction SilentlyContinue
```

If the Q007 zone exists but cannot be validated, leave it in place, stop the
transcript, and shut down the guest normally. Rebuilding this disposable VM is
safer than guessing at a repair. Do not remove any zone whose exact name is not
`q007.test`.

### Level 3 — Guest Isolation Is Wrong

If the VM is attached to any switch other than `Q007-Private`, has multiple
adapters, is domain joined, or has a default gateway:

1. do not install DNS or inject the fault;
2. capture the unexpected state without exposing unrelated names;
3. shut down `Q007-DNS01` normally; and
4. leave the VM Off for review.

Do not attempt a domain leave, adapter deletion, route removal, or switch
change unless Codex first reviews the exact current state and Leonel approves
the corrected action.

### Level 4 — Hyper-V Creation Is Partial Or Host Health Changes

Stop creating objects. Record whether `Q007-Private`, `Q007-DNS01`, its VHDX,
and DVD attachment exist. Power off only `Q007-DNS01` if it is running. Do not
use `Remove-VM`, `Remove-VMSwitch`, `Remove-Item`, or Hyper-V reset commands.

Deletion of the Q007 VM, VHDX, or switch is a destructive follow-up requiring
an exact inventory and separate dated approval. No rollback condition grants
permission to alter an existing VM, switch, disk, ISO, physical adapter, DNS
server, or domain controller.

## Rollback Success Criteria

Rollback is stable when:

- `Q007-DNS01` is Off;
- no Q007 guest is connected to a non-private switch;
- no production DNS, AD, DHCP, NIC, route, or Hyper-V object was changed;
- the wrong record is absent or the guest is safely powered off before further
  work;
- transcript and error evidence are retained; and
- the remaining Q007 objects are inventoried for a separately approved retry
  or deletion.

