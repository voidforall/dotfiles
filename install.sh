#!/usr/bin/env bash
# dotfiles/install.sh — create symlinks from this repo into $HOME
# Usage: ./install.sh [--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[dry-run] No files will be changed."
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()    { echo -e "${GREEN}[link]${NC}   $1 -> $2"; }
skip()   { echo -e "${YELLOW}[skip]${NC}   $1 (already correct symlink)"; }
backup() { echo -e "${YELLOW}[backup]${NC} $1 -> $1.bak"; }
error()  { echo -e "${RED}[error]${NC}  $1"; }

link() {
    local src="$1"   # absolute path inside dotfiles/
    local dst="$2"   # absolute path in $HOME

    # Already correct symlink — nothing to do
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        skip "$dst"
        return
    fi

    # Existing file/dir/wrong-symlink — back it up
    if [[ -e "$dst" || -L "$dst" ]]; then
        backup "$dst"
        if [[ "$DRY_RUN" == false ]]; then
            mv "$dst" "${dst}.bak"
        fi
    fi

    # Create parent directory if needed
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
    fi
    log "$src" "$dst"
}

# ── Shell ──────────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/shell/zshrc"    "$HOME/.zshrc"
link "$DOTFILES_DIR/shell/zprofile" "$HOME/.zprofile"
link "$DOTFILES_DIR/shell/zshenv"   "$HOME/.zshenv"
link "$DOTFILES_DIR/shell/profile"  "$HOME/.profile"

# ── Git ────────────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/git/gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES_DIR/git/gitignore_global" "$HOME/.config/git/ignore"

# ── Config ─────────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES_DIR/config/gh/config.yml" "$HOME/.config/gh/config.yml"

# ── Claude Code ────────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# ── Claude Skills ──────────────────────────────────────────────────────────────
link "$DOTFILES_DIR/claude/skills/leetcode-cpp/SKILL.md" "$HOME/.claude/skills/leetcode-cpp/SKILL.md"

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo "Tip: create ~/.zshrc.local for machine-specific env vars / secrets (not tracked in git)."
