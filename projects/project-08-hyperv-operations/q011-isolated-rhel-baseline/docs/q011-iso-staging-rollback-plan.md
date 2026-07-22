# Q011 Phase 4A — ISO-Staging Rollback Plan

This rollback applies only to the separately approved Phase 4A staging window.
The primary script performs this exact cleanup automatically after a normal
PowerShell failure. The manual steps below are for a separately approved
inspection/cleanup after abnormal termination or for verification of the
automatic result.

## Rollback Triggers

- The copy fails or is interrupted.
- The destination length is not 11,059,986,432 bytes.
- The destination SHA-256 does not equal
  `e15cb333529c332e76e4b1b946efe3515c99f996546675aec18e8effdf2540a5`.
- An unexpected destination object appears during the window.
- The operator cannot prove which file was created by this window.

## Exact Scope

Rollback may remove only:

1. `D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso`, and only when the preflight
   proved it absent before the window; and
2. `D:\Hyper-V\ISO`, only when Phase 4A created it and it is empty after the
   exact file is removed.

Never remove the source ISO, another local ISO, the parent `D:\Hyper-V`
directory, a VHDX, or a VM.

## Exact Rollback

Do not run manual cleanup after power loss, forced process termination, or a
new console session until a new approval confirms object provenance. Once
approved, close any File Explorer window using the destination and run on the
approved host:

```powershell
$ExpectedHost = 'WIN-PRQD8TJG04M'
$Destination = 'D:\Hyper-V\ISO\rhel-10.2-x86_64-dvd.iso'
$DestinationDirectory = 'D:\Hyper-V\ISO'

if ($env:COMPUTERNAME -ne $ExpectedHost) {
    throw "Wrong host. Expected $ExpectedHost."
}

if (Test-Path -LiteralPath $Destination -PathType Leaf) {
    Remove-Item -LiteralPath $Destination -Force
}

# Run this directory-removal block only when the staging output/operator notes
# prove Phase 4A created the directory.
if ((Test-Path -LiteralPath $DestinationDirectory -PathType Container) -and
    -not (Get-ChildItem -LiteralPath $DestinationDirectory -Force)) {
    Remove-Item -LiteralPath $DestinationDirectory -Force
}

[pscustomobject]@{
    ComputerName      = $env:COMPUTERNAME
    DestinationAbsent = -not (Test-Path -LiteralPath $Destination)
    VMChanged          = $false
    NetworkChanged     = $false
} | Format-List
```

The conditional directory-removal block is forbidden if the directory existed
before the window or the operator cannot prove its origin.

## Rollback Verification

- The exact destination file is absent.
- No temporary `Q011SRC` PSDrive remains.
- No VM, VHDX, switch, service, or source file was changed.
- Record the failure reason and stop; do not retry without reviewing the cause
  and obtaining a new or still-valid approval.

## Recovery Point

The source ISO on the Ugreen share is the integrity anchor and is read-only in
this window. No system-state recovery point is necessary because the proposed
change is an additive file copy with an exact, local rollback target.
