# Q007 Windows Hands-On Screenshot Plan

- **Status:** Phases 0 through 7 and the Phase 9 powered-off capture were
  inspected and ingested. No separate empty-zone screenshot was captured.
- **Destination after intake:** `evidence/screenshots/`
- **Rule:** do not add image links to the project README until the real files
  exist and Codex has inspected them.
- **Maximum:** two useful screenshots per phase. Prefer a cropped technical
  result over a full desktop.

## Capture Rules

Before every capture:

1. close password, product-key, notification, email, and unrelated management
   windows;
2. show the Q007 object name and the exact property or output being proved;
3. crop unrelated VMs, switches, file paths, hostnames, and user names;
4. keep the Windows clock visible only when it adds useful date context;
5. never manufacture a success screen or hide a failed command; and
6. if redaction is necessary, keep an evidence note describing what category
   was removed and why.

Prefer Server Manager or DNS Manager for the actual Windows configuration
state. Use a PowerShell screenshot only when the required proof is not visible
in the GUI, including full DNS answer sets, repeated pass assertions, route
absence, or NXDOMAIN. Pair either capture type with searchable command output.

PNG is preferred. Use the planned lowercase filename when possible; Codex will
normalize names during evidence intake.

## Phase Mapping

| Phase | Planned filename | Capture | Proof | Exclude |
|---:|---|---|---|---|
| 0 | `phase0-01-q007-hyperv-precheck.png` | Accepted PowerShell object with `VMExists=False`, `SwitchExists=False`, ISO/signature/dismount checks, and `Q007Phase0Pass=True` | Fixed names were unused and the technical precheck passed before creation | No unrelated VM/switch name, secret, notification, or private path was present |
| 1 | None | Narrative only | Scenario was understood before action | No decorative screenshot |
| 2 | `phase2-01-q007-private-switch.png` | Accepted PowerShell checks for `Q007-Private` | Switch type is Private with no physical-adapter description | No existing switch or physical adapter detail was visible |
| 2 | `phase2-02-q007-vm-isolated-network.png` | Accepted PowerShell VM settings plus the one network adapter while the VM was Off | One Generation 2 VM with 2 vCPU and 4 GB static memory is attached only to `Q007-Private` | Other VMs and unrelated storage paths |
| 3 | `phase3-01-q007-guest-safety-precheck.png` | Cropped PowerShell safety proof | Standalone name, `PartOfDomain=False`, two lab IPs, no default route | Local account name and desktop notifications |
| 4 | `phase4-01-q007-dns-role-installed.png` | Server Manager result or `Get-WindowsFeature DNS` | DNS role and management tools are installed | Other role inventory |
| 4 | `phase4-02-q007-zone-baseline-record.png` | DNS Manager zone view plus selected `files` record | `q007.test` contains only `10.77.7.10` | Server tree outside local Q007 zone |
| 5 | `phase5-01-q007-baseline-resolution.png` | Baseline `Resolve-DnsName` output | One correct A answer before fault | Unrelated console history |
| 5 | `phase5-02-q007-fault-two-a-records.png` | Six-query table and/or DNS Manager record view | Both good and wrong values exist; full set was inspected | Claims based only on record order |
| 6 | `phase6-01-q007-repair-powershell.png` | Accepted post-removal record, three-retest, wrong-record-absence, and NXDOMAIN output | Only `10.77.7.10` remains and `Phase6Pass=True` | Any production zone tree |
| 6 | `phase6-02-q007-repaired-dns-manager.png` | Accepted DNS Manager repaired state | Exactly one `files` record remains for `10.77.7.10` | Other zones and unrelated server windows |
| 7 | `phase7-01-q007-windows-operator-validation.png` | Final role, zone, record, and route output | Runbook closeout state is correct and still isolated | Unrelated services or routes |
| 8 | None | Evidence packaging only | Transcript and screenshots are the artifacts | No folder-only screenshot |
| 9 | `phase9-01-q007-zone-cleanup.png` — not captured | Planned empty-zone verification | No independent screenshot proof is claimed | Do not substitute the powered-off capture for this missing proof |
| 9 | `phase9-02-q007-vm-powered-off-retained.png` | Cropped Hyper-V Manager or `Get-VM Q007-DNS01` | Q007 VM is Off and retained pending deletion approval | Other VM inventory |

## Evidence Intake Checklist

Codex will accept a screenshot only when:

- the filename maps to one phase and one factual claim;
- the result is legible at normal size;
- no password, product key, token, private notification, or unnecessary
  infrastructure name is visible;
- failures and deviations are preserved in the transcript;
- the screenshot agrees with the text output and expected phase order; and
- its final repository path and SHA-256 value are recorded.
