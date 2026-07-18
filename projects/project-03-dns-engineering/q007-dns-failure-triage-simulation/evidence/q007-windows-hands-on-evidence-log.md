# Evidence Log — Q007 Windows Hands-On Practicum

**Captured:** 2026-07-15 to 2026-07-16 by Leonel  
**Source system:** Hyper-V host and `Q007-DNS01`, elevated Windows PowerShell,
operator-led precheck and approved Q007 object configuration  
**Redaction check done:** yes — no password, token, public WAN address,
notification, unrelated VM name, or unrelated switch name was visible

## Capture Inventory

| # | File | What it shows | Command/page it came from |
|---|---|---|---|
| 1 | [`screenshots/phase0-01-q007-hyperv-precheck.png`](screenshots/phase0-01-q007-hyperv-precheck.png) | The fixed Q007 VM and switch names were absent, storage was sufficient, the accepted ISO/hash and signed-boot checks passed, the ISO was dismounted, and the Phase 0 assertion passed | Compact Phase 0 PowerShell summary object |
| 2 | [`screenshots/phase0-01-q007-hyperv-precheck.txt`](screenshots/phase0-01-q007-hyperv-precheck.txt) | Searchable extraction of the values visible in the PNG | Manual evidence extraction, values unaltered |
| 3 | [`screenshots/phase2-01-q007-private-switch.png`](screenshots/phase2-01-q007-private-switch.png) | `Q007-Private` exists as a Private switch with no physical-adapter description | Three short `Get-VMSwitch` property checks |
| 4 | [`screenshots/phase2-01-q007-private-switch.txt`](screenshots/phase2-01-q007-private-switch.txt) | Searchable extraction of the values visible in the Phase 2A PNG | Manual evidence extraction, values unaltered |
| 5 | [`screenshots/phase2-02-q007-vm-isolated-network.png`](screenshots/phase2-02-q007-vm-isolated-network.png) | `Q007-DNS01` is an Off Generation 2 VM with 2 vCPU, 4 GB static startup memory, and one adapter on `Q007-Private` | Final host-side `Get-VM` and `Get-VMNetworkAdapter` checks |
| 6 | [`screenshots/phase2-02-q007-vm-isolated-network.txt`](screenshots/phase2-02-q007-vm-isolated-network.txt) | Searchable extraction of the exact values visible in the Phase 2B PNG | Manual evidence extraction, values unaltered |
| 7 | [`q007-phase2-guest-installation-verification.txt`](q007-phase2-guest-installation-verification.txt) | Windows Server 2022 Standard Evaluation build 20348 started inside the guest, which remained standalone in `WORKGROUP` | Leonel-pasted `Win32_OperatingSystem` and `Win32_ComputerSystem` output |
| 8 | [`screenshots/phase3-01-q007-guest-safety-precheck.png`](screenshots/phase3-01-q007-guest-safety-precheck.png) | The renamed standalone guest has exactly the two approved lab addresses, self-DNS only, no default route, and `Phase3Pass=True` | Cropped Phase 3 PowerShell validation output |
| 9 | [`screenshots/phase3-01-q007-guest-safety-precheck.txt`](screenshots/phase3-01-q007-guest-safety-precheck.txt) | Searchable extraction of the values visible in the Phase 3 PNG | Manual evidence extraction, values unaltered |
| 10 | [`screenshots/phase4-01-q007-dns-role-installed.png`](screenshots/phase4-01-q007-dns-role-installed.png) | DNS and its management tools are installed, AD DS and DHCP remain available, and the DNS service is running automatically | Cropped Phase 4A PowerShell role/service validation |
| 11 | [`screenshots/phase4-01-q007-dns-role-installed.txt`](screenshots/phase4-01-q007-dns-role-installed.txt) | Searchable extraction of the values visible in the Phase 4A PNG | Manual evidence extraction, values unaltered |
| 12 | [`screenshots/phase4-02-q007-zone-baseline-record.png`](screenshots/phase4-02-q007-zone-baseline-record.png) | DNS Manager shows the standalone `q007.test` zone and the `files` Host (A) properties for `10.77.7.10`, with PTR creation unchecked | Cropped Phase 4B DNS Manager record properties |
| 13 | [`screenshots/phase4-02-q007-zone-baseline-record.txt`](screenshots/phase4-02-q007-zone-baseline-record.txt) | Searchable extraction of the values visible in the Phase 4B PNG | Manual evidence extraction, values unaltered |
| 14 | [`q007-phase4-resume-verification-2026-07-17.txt`](q007-phase4-resume-verification-2026-07-17.txt) | The accepted isolation, DNS service, zone, and one-good-record baseline survived the overnight shutdown and restart with `ResumePass=True` | Leonel-pasted read-only PowerShell resume validation |
| 15 | [`screenshots/phase5-01-q007-baseline-resolution.png`](screenshots/phase5-01-q007-baseline-resolution.png) | The direct query returned exactly `10.77.7.10`, the wrong address did not respond, and `Phase5BaselinePass=True` before injection | Cropped Phase 5 baseline PowerShell assertion |
| 16 | [`screenshots/phase5-01-q007-baseline-resolution.txt`](screenshots/phase5-01-q007-baseline-resolution.txt) | Searchable extraction of the values visible in the Phase 5 baseline PNG | Manual evidence extraction, values unaltered |
| 17 | [`screenshots/phase5-02-q007-fault-two-a-records.png`](screenshots/phase5-02-q007-fault-two-a-records.png) | DNS Manager shows the real `q007.test` fault state with both `files` A records, `10.77.7.10` and `10.77.7.99` | Cropped Phase 5 DNS Manager zone view |
| 18 | [`screenshots/phase5-02-q007-fault-two-a-records.txt`](screenshots/phase5-02-q007-fault-two-a-records.txt) | Searchable extraction of the records visible in the Phase 5 fault PNG | Manual evidence extraction, values unaltered |
| 19 | [`q007-phase5-fault-validation-2026-07-17.txt`](q007-phase5-fault-validation-2026-07-17.txt) | Wrong-record TTL, six full-answer queries, reachability results, failed supplemental exit-code assertion, and corrected check | Leonel-pasted PowerShell validation |

## Command Output

### Compact Phase 0 Summary

```text
VMExists          : False
SwitchExists      : False
FreeSpaceGB       : 904.7
ISOFile           : SERVER_EVAL_x64FRE_en-us.iso
SHA256Match       : True
SetupSigned       : True
EfiBootSigned     : True
ISOIsDismounted   : True
Q007Phase0Pass    : True
```

### Phase 2A ISO Copy

```text
Destination ISO exists: True
Destination SHA256: 3E4FA6D8507B554856FC9CA6079CC402DF11A8B79344871669F0251535255325
Destination hash equals approved hash: True
Source ISO still exists: True
```

### Phase 2A Private Switch

```text
Switch name: Q007-Private
Switch type: Private
Physical-adapter description is empty: True
```

### Phase 2B VM Validation And Correction

Initial operator checks found that the new VM had 1 vCPU, startup memory that
did not equal 4096 MB, and a DVD path pointing to the source ISO. Leonel kept
the VM Off and corrected those values within the already approved VM-creation
scope. No existing VM, switch, disk, or physical adapter was named or changed.

Final operator output:

```text
Name                 : Q007-DNS01
State                : Off
Generation           : 2
ProcessorCount       : 2
MemoryStartup        : 4294967296
DynamicMemoryEnabled : False
Network adapter count: 1
SwitchName           : Q007-Private
VHD type             : Dynamic
VHD size             : 42949672960
DVD path             : D:\Hyper-V\ISOs\SERVER_EVAL_x64FRE_en-us.iso
SecureBoot           : On
SecureBootTemplate   : MicrosoftWindows
```

### Phase 2 Guest Installation And Workgroup Verification

Leonel signed in to the completed guest and ran two read-only CIM queries in
elevated Windows PowerShell. The accepted text output is preserved in
[`q007-phase2-guest-installation-verification.txt`](q007-phase2-guest-installation-verification.txt).

```text
Caption     : Microsoft Windows Server 2022 Standard Evaluation
Version     : 10.0.20348
BuildNumber : 20348

Name         : WIN-6FI395OD8C6
Domain       : WORKGROUP
PartOfDomain : False
```

### Phase 3 Guest Rename, Addressing, And Isolation

After Leonel's exact Phase 3 approval, the guest was renamed and restarted.
A fresh preconfiguration check showed `Q007-DNS01`, `PartOfDomain=False`, one
Up adapter named `Ethernet`, only an APIPA address, and no IPv4 or IPv6 default
route. Leonel then assigned the two fixed addresses and the self-DNS value.

Final validation:

```text
IPAddress   PrefixLength SkipAsSource
---------   ------------ ------------
10.77.7.10            24         True
10.77.7.2             24        False

ComputerName      : Q007-DNS01
AdapterName       : Ethernet
DnsServers        : 10.77.7.2
DefaultRouteCount : 0
PartOfDomain      : False
Phase3Pass        : True
```

### Phase 4A DNS Role And Tool Validation

After Leonel's exact Phase 4 approval, he used Server Manager to install only
the DNS Server role and its management tools. The accepted validation output
showed:

```text
Name               InstallState
----               ------------
AD-Domain-Services    Available
DHCP                  Available
DNS                   Installed
RSAT-DNS-Server       Installed

Name Status  StartType
---- ------  ---------
DNS  Running Automatic
```

### Phase 4B Standalone Zone And Baseline Record

Leonel used DNS Manager to create the file-backed `q007.test` primary zone
with dynamic updates disabled and only the approved `files` A record. Final
PowerShell validation returned:

```text
ZoneName       : q007.test
ZoneType       : Primary
IsDsIntegrated : False
DynamicUpdate  : None
ZoneFile       : q007.test.dns

HostName RecordType IPv4Address
-------- ---------- -----------
files    A          10.77.7.10

TotalARecordCount FilesAddresses Phase4Pass
----------------- -------------- ----------
                1 10.77.7.10           True
```

### 2026-07-17 Resume Validation

Leonel started the retained VM, appended to the existing transcript, and ran
the planned read-only resume check. The [preserved output](q007-phase4-resume-verification-2026-07-17.txt)
showed the same two addresses, self-DNS only, no default route, DNS running,
the same file-backed non-AD zone, exactly one good A record, and
`ResumePass=True`.

### Phase 5 Baseline Query Gate

After Leonel's exact Phase 5 approval, he queried `files.q007.test` directly
against `10.77.7.2` and checked the unused wrong address before injection. The
accepted output was:

```text
QueryName           : files.q007.test
DnsServer           : 10.77.7.2
BaselineAnswerCount : 1
BaselineAnswers     : 10.77.7.10
BadAddressResponds  : False
Phase5BaselinePass  : True
```

### Phase 5 Wrong-Record Fault And Impact

Leonel added only `files -> 10.77.7.99` with a five-minute TTL and cleared only
the guest DNS-client cache. DNS Manager showed both real A records. All six
direct queries returned both values, the good address responded, and the wrong
address did not; the [full retained validation](q007-phase5-fault-validation-2026-07-17.txt)
records `Phase5FaultPass=True`.

The first supplemental `ping.exe` exit-code assertion returned False even
though its text showed the wrong target timed out and the local guest returned
Destination host unreachable. Codex identified the bad assumption—Windows
`ping.exe` can return zero after an ICMP unreachable response—and preserved the
failure. `Test-NetConnection` then returned good `True`, bad `False`, and
`ReachabilityPass=True` without changing DNS state.

## Facts This Evidence Establishes

- On 2026-07-15, `Q007-DNS01` and `Q007-Private` did not exist when Leonel ran
  the precheck.
- The VHD volume had 904.7 GB free, exceeding the 60 GB gate.
- The selected `SERVER_EVAL_x64FRE_en-us.iso` matched the accepted SHA-256
  value used by the check.
- Microsoft-signed setup and EFI boot checks passed.
- The temporary read-only ISO inspection ended with the ISO dismounted.
- The combined Phase 0 technical assertion returned `True`.
- On 2026-07-16, the approved ISO copy existed under `D:\Hyper-V\ISOs`, its
  SHA-256 matched the approved source exactly, and the source remained intact.
- `Q007-Private` was created as a Private switch with no physical-adapter
  description.
- `Q007-DNS01` and its VHDX existed by the final Phase 2B check. The VM was Off,
  Generation 2, configured with 2 vCPU and 4 GB static startup memory, and had
  exactly one adapter attached to `Q007-Private`.
- Operator-pasted checks established a dynamically expanding 40 GB VHDX,
  Secure Boot using the Microsoft Windows template, and the staged ISO path.
- The initial mismatches were detected before startup and corrected while the
  VM remained Off.
- Windows Server 2022 Standard Evaluation version 10.0.20348, build 20348,
  completed startup inside the guest.
- The guest remained standalone in `WORKGROUP` with `PartOfDomain=False`.
- The guest was renamed to `Q007-DNS01` and retained one Up adapter.
- The adapter has exactly `10.77.7.2/24` and `10.77.7.10/24`; the secondary
  address has `SkipAsSource=True`.
- The DNS client contains only `10.77.7.2`, neither an IPv4 nor IPv6 default
  route exists, and the combined assertion returned `Phase3Pass=True`.
- The DNS Server role and DNS management tools are installed; AD DS and DHCP
  remain uninstalled, and the DNS service is running automatically.
- `q007.test` is a file-backed, non-AD-integrated primary zone with dynamic
  updates disabled and zone file `q007.test.dns`.
- The zone has exactly one A record, `files` at `10.77.7.10`; the combined
  baseline assertion returned `Phase4Pass=True` and the PTR option was not
  selected.
- The complete accepted Phase 4 state survived the overnight power cycle and
  passed the dated resume assertion without mutation.
- The direct pre-injection query returned exactly the one good answer, the
  wrong address did not respond, and the combined baseline gate passed.
- The fault state contains exactly the good and wrong A records, with the wrong
  record at the approved five-minute TTL.
- All six direct queries returned both values; the good address was reachable,
  the wrong address was not, and the combined fault assertion passed.

## Facts This Evidence Does Not Establish

- It does not prove an External, Internal, or production switch was absent;
  it proves only that the fixed new name `Q007-Private` was unused.
- It does not prove that the Hyper-V host has no unrelated health event.
- It does not prove repair, cleanup, or a final powered-off state; those remain
  outside the accepted Phase 5 scope.
- It does not prove that unrelated Hyper-V objects were unchanged; it proves
  only the displayed Q007 VM and switch properties.

## Follow-Ups

- Phase 5 technical, GUI, and reachability evidence is accepted. Phase 6 then
  previewed and removed only `10.77.7.99`, cleared only the guest DNS client
  cache, passed three exact-good direct queries, confirmed the wrong record was
  absent, and verified `old-files.q007.test` returned NXDOMAIN. Phase 6 is
  complete; no further DNS change is authorized.

## Integrity

Hashes for the accepted hands-on plan and evidence files are maintained in the
[`q007-windows-hands-on-manifest.sha256`](q007-windows-hands-on-manifest.sha256)
sidecar manifest. The completed automated core retains its original project
manifest separately.
