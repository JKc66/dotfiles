#!/bin/bash
# ─────────────────────────────────────────────────────────────
# install.sh — Symlink/copy dotfiles to their proper locations
# Usage: ./install.sh
# ─────────────────────────────────────────────────────────────

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

info()  { echo -e "  ${CYAN}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()  { echo -e "  ${YELLOW}!${NC} $1"; }
err()   { echo -e "  ${RED}✗${NC} $1"; }

backup_and_link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        # Already a symlink — remove and re-link
        rm "$dest"
    elif [ -f "$dest" ]; then
        warn "Backing up existing $dest → ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    ln -s "$src" "$dest"
    ok "Linked $dest → $src"
}

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Dotfiles Installer               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── ZSH ────────────────────────────────────────────────────
echo -e "${CYAN}[zsh]${NC}"
backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
echo ""

# ─── GIT ─────────────────────────────────────────────────────
echo -e "${CYAN}[git]${NC}"
backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
echo ""

# ─── MOTD ───────────────────────────────────────────────────
echo -e "${CYAN}[motd]${NC}"
if [ -w /etc/update-motd.d ] || [ "$(id -u)" -eq 0 ]; then
    for f in "$DOTFILES_DIR"/motd/*; do
        fname=$(basename "$f")
        sudo cp "$f" "/etc/update-motd.d/$fname"
        sudo chmod 755 "/etc/update-motd.d/$fname"
        ok "Copied $fname → /etc/update-motd.d/$fname"
    done
else
    warn "MOTD scripts require sudo. Re-run with: sudo ./install.sh"
    info "Or run manually:"
    for f in "$DOTFILES_DIR"/motd/*; do
        fname=$(basename "$f")
        info "  sudo cp $f /etc/update-motd.d/$fname && sudo chmod 755 /etc/update-motd.d/$fname"
    done
fi
echo ""

# ─── SCRIPTS ────────────────────────────────────────────────
echo -e "${CYAN}[scripts]${NC}"
mkdir -p "$HOME/.local/bin"
for f in "$DOTFILES_DIR"/scripts/*; do
    fname=$(basename "$f")
    backup_and_link "$f" "$HOME/.local/bin/$fname"
done
echo ""

echo -e "${GREEN}Done!${NC} Restart your shell or run: ${CYAN}source ~/.zshrc${NC}"
echo ""
