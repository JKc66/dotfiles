
#region conda initialize (lazy-loaded for fast startup)
# bots env is always on PATH, full conda hook deferred until first use
$env:CONDA_AUTO_ACTIVATE_BASE = "false"
$env:CONDA_CHANGEPS1 = "false"
$env:PATH = "C:\Users\jk\miniconda3\envs\bots;C:\Users\jk\miniconda3\envs\bots\Scripts;C:\Users\jk\miniconda3\envs\bots\Library\bin;C:\Users\jk\miniconda3;C:\Users\jk\miniconda3\Scripts;C:\Users\jk\miniconda3\Library\bin;$env:PATH"
$env:CONDA_DEFAULT_ENV = "bots"
$env:CONDA_PREFIX = "C:\Users\jk\miniconda3\envs\bots"

function conda {
    # Remove this stub and load the real conda hook on first use
    Remove-Item Function:\conda
    If (Test-Path "C:\Users\jk\miniconda3\Scripts\conda.exe") {
        (& "C:\Users\jk\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
    }
    conda @args
}
#endregion
