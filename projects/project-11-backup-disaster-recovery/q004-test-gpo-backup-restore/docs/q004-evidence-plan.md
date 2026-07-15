# Q004 Evidence And Screenshot Plan

| Artifact | What it proves |
|---|---|
| `evidence/q004-read-only-discovery-2026-07-14.txt` | Historical planning facts and the initial SSH replication gate |
| `evidence/q004-precheck-2026-07-14.txt` | Historical fail-closed corrections and DC02 SSH-context diagnosis |
| `evidence/q004-claude-preexecution-review-2026-07-14.md` | Independent plan/script review and dispositions |
| `evidence/q004-sanitized-transcript.txt` | Ordered precheck, containment, resume, restore, verification, and cleanup |
| `evidence/q004-backup-inventory.txt` | Exact custom/default GPO and backup identities |
| `evidence/q004-run-state.json` | Machine-readable pinned run state and protected-default baseline |
| `evidence/q004-evidence-manifest.sha256` | Integrity hashes for the retained closeout evidence |
| `evidence/reports/q004-{baseline,fault,restored}.xml` | Setting lifecycle on the same custom GPO |
| `evidence/reports/q004-rsop-modeling.html` | Winning restored GPO and baseline marker |
| `evidence/q004-final-live-state-2026-07-14.txt` | Disposable object/link absent and clean two-DC state |
| `evidence/q004-closeout.md` | RTO, final state, limitations, lessons, Q005 handoff |
| `evidence/q004-claude-final-review-2026-07-14.md` | Independent final evidence/redaction decision |

All planned text, XML, HTML, JSON, and screenshot evidence exists. The first
Execute exception and the `.htm`/`.html` mismatch are retained in the sanitized
record rather than hidden. Claude's independent final review returned
`COMPLETE-READY` with no material blocker.

## Screenshots

| Filename | Proof |
|---|---|
| `phase7-01-q004-rsop-restored-policy.png` | GPMC model shows winning GPO/marker |
| `phase7-02-q004-rsop-modeling-scope.png` | Disabled Quarantine user, applied test GUID, successful processing |

The two reviewed images contain no credentials, prompts, key material,
passwords, public WAN addresses, browser tabs, or notifications. Cleanup and
precheck are represented by exact text evidence rather than extra screenshots.
