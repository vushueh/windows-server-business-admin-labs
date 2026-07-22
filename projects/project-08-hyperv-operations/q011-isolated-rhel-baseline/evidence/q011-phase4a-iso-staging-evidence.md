# Q011 Phase 4A — Local ISO-Staging Evidence

- **Date:** 2026-07-19
- **Host:** `WIN-PRQD8TJG04M`
- **Result:** pass
- **VM created:** no
- **Network changed:** no

## Final Verified Object

| Field | Result |
|---|---|
| Path | `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso` |
| Filename | `rhel-10.2-x86_64-dvd.iso` |
| Length | `11,059,986,432` bytes |
| Expected length | `11,059,986,432` bytes |
| Computed SHA-256 | `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Published SHA-256 | `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5` |
| Size pass | `True` |
| Checksum pass | `True` |
| Old plural-path file absent | `True` |
| VM created | `False` |
| Network changed | `False` |

## Execution Notes

The initial guarded PowerShell attempt did not reach destination creation. It
showed no sustained copy activity and could not be interrupted normally, so
Leonel closed only the exact PowerShell session. A fresh elevated session then
proved:

- temporary `Q011SRC` drive absent;
- intended destination file absent; and
- intended destination directory absent.

No rollback object remained. Leonel then used File Explorer to authenticate
interactively to the exact Ugreen share and copy only the selected ISO. No
credential value or prompt was retained.

The first manual destination used `D:\Hyper-V\ISOs` instead of the frozen
singular `D:\Hyper-V\ISO`. Read-only inspection proved the copied file had the
exact expected length and that the approved singular destination was absent.
Under a second exact correction approval, Leonel moved only that ISO into the
frozen path. Final PowerShell evidence proved the old plural-path file absent
and the local destination hash equal to the pinned published value.

The Windows staging attempt did not complete a second source-side hash. Q011
instead retains the earlier verified source-storage hash and independently
proved the final local file against the same pinned checksum. This distinction
prevents the canceled attempt from being described as a completed source
verification.

## Screenshot Evidence

`screenshots/q011-phase4a-01-local-rhel102-iso.png` is the reviewed original
PNG copied from Leonel's Downloads folder without image editing. It shows:

- the exact ISO filename;
- `Location: D:\Hyper-V\ISO`; and
- `Size: 10.2 GB (11,059,986,432 bytes)`.

Screenshot SHA-256:
`d4f0f1e1256dabc748e912140475dd1503460ea2b120448f4e2d943ea958bcd3`.
The same value is retained in `q011-phase4a-screenshot.sha256` for repeatable
integrity verification.

The screenshot does not prove the ISO checksum; the searchable PowerShell
result above supplies that proof. It also shows Windows' **Unblock** control,
so Phase 4B must inspect the exact file's zone/block state read-only before VM
creation. No unblock action occurred in Phase 4A.

## Claim Boundary

Phase 4A proves only that the exact RHEL 10.2 DVD is staged locally with the
expected bytes and SHA-256. It does not prove that Hyper-V can attach or boot
the ISO, that guest-visible x86-64-v3 features pass, or that a VM exists. Those
remain separately approval-gated Phase 4B/4C checks.
