# ------------ Terminal-Icons (deferred for fast startup) ------------ #
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Import-Module -Name Terminal-Icons
}
# ------------ oh-my-posh ------------ #
oh-my-posh --init --shell pwsh --config "$env:POSH_THEMES_PATH/minecraft.omp.json" | Invoke-Expression
# ------------ zoxide ------------ #
Invoke-Expression (& { (zoxide init powershell --cmd cd --hook pwd | Out-String) })
# ------------ PSReadLine ------------ #
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -AddToHistoryHandler { param($line); return -not $line.StartsWith(' ') } # Prevents space-prefixed commands
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
