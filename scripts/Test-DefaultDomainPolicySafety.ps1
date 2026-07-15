[CmdletBinding()]
param(
    [Parameter()]
    [string[]]$Path = @(git ls-files '*.ps1')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$mutatingCommands = @(
    'Set-GPRegistryValue'
    'Set-GPLink'
    'Set-GPPermission'
)

$protectedTargetPatterns = @(
    '(?i)\bDefault Domain Policy\b'
    '(?i)\b31b2f340-016d-11d2-945f-00c04fb984f9\b'
    '(?i)\$DefaultDomainPolicyId\b'
)

$violations = [System.Collections.Generic.List[object]]::new()

foreach ($file in $Path) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "PowerShell file not found: $file"
    }

    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $file,
        [ref]$tokens,
        [ref]$parseErrors
    )

    if ($parseErrors.Count -gt 0) {
        throw "Cannot inspect a script with parse errors: $file"
    }

    $commands = $ast.FindAll({
        param($node)

        if ($node -isnot [System.Management.Automation.Language.CommandAst]) {
            return $false
        }

        $commandName = $node.GetCommandName()
        return $null -ne $commandName -and $mutatingCommands -contains $commandName
    }, $true)

    foreach ($command in $commands) {
        foreach ($pattern in $protectedTargetPatterns) {
            if ($command.Extent.Text -match $pattern) {
                $violations.Add([pscustomobject]@{
                    Path = $file
                    Line = $command.Extent.StartLineNumber
                    Command = $command.GetCommandName()
                })
                break
            }
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object {
        Write-Error (
            'Protected Default Domain Policy mutation detected: ' +
            "$($_.Path):$($_.Line) [$($_.Command)]"
        )
    }
    exit 1
}

Write-Host 'No tracked script directly targets Default Domain Policy with a protected mutating command.' -ForegroundColor Green
