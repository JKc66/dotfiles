# ------------ Terminal-Icons (deferred for fast startup) ------------ #
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    $null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue
    }
}

# ------------ oh-my-posh ------------ #
if ((-not [Console]::IsOutputRedirected) -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    $theme = Join-Path $env:POSH_THEMES_PATH 'minecraft.omp.json'
    if (Test-Path -LiteralPath $theme) {
        oh-my-posh --init --shell pwsh --config $theme | Invoke-Expression
    }
}

# ------------ zoxide ------------ #
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd --hook pwd | Out-String) })
}

# ------------ PSReadLine ------------ #
if ($Host.Name -eq 'ConsoleHost' -and (-not [Console]::IsOutputRedirected)) {
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue

        try {
            Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
            Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
        } catch {
            Set-PSReadLineOption -PredictionSource None -ErrorAction SilentlyContinue
        }

        Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue
        Set-PSReadLineOption -AddToHistoryHandler {
            param($line)
            return -not $line.StartsWith(' ')
        } -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ErrorAction SilentlyContinue
    }
}
