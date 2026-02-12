# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Key bindings
bindkey -e # Use emacs key bindings
bindkey '^[[A' up-line-or-beginning-search # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow
bindkey '^[[1;5A' history-search-backward # Ctrl+Up arrow
bindkey '^[[1;5B' history-search-forward # Ctrl+Down arrow

# Move by word with Ctrl+Left and Ctrl+Right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Delete by word with Ctrl+Backspace and Ctrl+Delete
bindkey '^H' backward-kill-word   # Ctrl+Backspace deletes the previous word
bindkey '^[[3;5~' kill-word       # Ctrl+Delete deletes the next word

# Ensure the functions are loaded
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Initialize Zinit
export ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load Zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# Load fzf and fzf-tab
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

zinit ice wait lucid
zinit load Aloxaf/fzf-tab

# Load Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Initialize zoxide with cd replacement
eval "$(zoxide init zsh --cmd cd)"
export _ZO_RESOLVE_SYMLINKS=1

# Configure fzf-tab
# Using eza for preview here already
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# Optional: Enable extended globbing and other useful options
setopt extended_glob

# Additional settings for autocompletion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{A-Z}={a-z}' 'm:{a-z}={a-z}'

# --- EZA Aliases ---
# Use eza for ls with icons and automatic color
alias ls='eza --icons --color=auto'
# Alias for long listing format with icons
alias lsa='eza -la --icons --color=auto'

# Enable colored output for other commands (ls is handled above)
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Set up LS_COLORS for ls and other utilities (eza respects LS_COLORS)
export LS_COLORS='di=94:ln=36:so=32:pi=33:ex=35:bd=34;46:cd=34;43:su=37;41:sg=30;43:tw=30;42:ow=30;43:'

# Additional aliases
alias mypython='~/.mypython_script.sh'

# Ensure compinit is called at the end
autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Force compinit to run again
zinit cdreplay -q

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/ubuntu/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/ubuntu/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/ubuntu/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/ubuntu/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
