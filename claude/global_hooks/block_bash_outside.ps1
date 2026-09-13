$j = [Console]::In.ReadToEnd() | ConvertFrom-Json
$cmd = $j.tool_input.command
if (-not $cmd) { exit 0 }

$home = $env:USERPROFILE
$allowed = @(
    "D:\hnk\scripts",
    "D:\codeWork",
    "G:\",
    "$home\Documents\maya\scripts",
    "$home\.claude\projects\D--hnk-scripts\memory",
    "$home\.claude\CLAUDE.md",
    "$home\.claude\settings.json",
    "$home\.claude\access-attempts.log"
)

$pattern = '[A-Za-z]:[\\/][^\s"<>|]+'
$found = [regex]::Matches($cmd, $pattern)
$blocked = New-Object System.Collections.ArrayList

foreach ($m in $found) {
    $p = $m.Value
    $pNorm = $p.ToLower().Replace("/", "\")
    $isAllowed = $false
    foreach ($root in $allowed) {
        if ($pNorm.StartsWith($root.ToLower())) { $isAllowed = $true; break }
    }
    if (-not $isAllowed) { [void]$blocked.Add($p) }
}

if ($blocked.Count -gt 0) {
    $reason = "Blocked: path outside allowed working directories detected in command: " + ($blocked -join ", ")
    $result = @{
        hookSpecificOutput = @{
            hookEventName = "PreToolUse"
            permissionDecision = "deny"
            permissionDecisionReason = $reason
        }
    }
    $result | ConvertTo-Json -Depth 5 -Compress
}

exit 0
