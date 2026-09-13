$j = [Console]::In.ReadToEnd() | ConvertFrom-Json
$p = $j.tool_input.file_path
if (-not $p) { $p = $j.tool_input.pattern }
if (-not $p) { $p = $j.tool_input.command }
$line = "$(Get-Date -Format o) $($j.tool_name) $p"
Add-Content -Path "$env:USERPROFILE\.claude\access-attempts.log" -Value $line
