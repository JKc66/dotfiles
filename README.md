# dotfiles

Personal dotfiles and configs for Linux (Ubuntu AArch64 VM) and Windows (PowerShell).

## What's Included

```
dotfiles/
├── git/.gitconfig              # Git user config (GitHub noreply email)
├── zsh/.zshrc                  # Zsh — Zinit, Powerlevel10k, fzf, zoxide, eza
├── motd/
│   ├── 90-custom-info          # Custom MOTD with JK logo, system stats & bars
│   └── 95-last-login           # Last login with geo-IP lookup
├── powershell/
│   ├── Microsoft.PowerShell_profile.ps1  # Oh My Posh, zoxide, PSReadLine, Terminal-Icons
│   ├── profile.ps1             # Conda lazy-load & default env setup
│   └── minecraft.omp.json      # Custom Oh My Posh theme
├── scripts/
│   └── mypython_script.sh      # View running Python processes in a formatted table
├── install.sh                  # Linux installer — symlinks & copies everything
└── README.md
```

## Quick Start

### Linux

```bash
git clone https://github.com/JKc66/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer will:
- Symlink `.gitconfig` to `~/.gitconfig`
- Symlink `.zshrc` to `~/.zshrc`
- Copy MOTD scripts to `/etc/update-motd.d/` (needs sudo)
- Symlink utility scripts to `~/.local/bin/`

### Windows (PowerShell)

Copy or symlink the PowerShell configs manually:
- `powershell/Microsoft.PowerShell_profile.ps1` → your `$PROFILE` path
- `powershell/profile.ps1` → `$PSHOME/profile.ps1` (all-users profile)
- `powershell/minecraft.omp.json` → `$env:POSH_THEMES_PATH/minecraft.omp.json`

## Notes

- MOTD scripts are **copied** (not symlinked) since `/etc/update-motd.d/` runs as root at login
- Existing files are backed up as `*.bak` before being replaced
- **Linux requires:** `zsh`, `zinit`, `eza`, `fzf`, `zoxide`, `gawk`, `geoiplookup` (optional)
- **Windows requires:** `oh-my-posh`, `zoxide`, `Terminal-Icons` module, `PSReadLine`
