#!/bin/bash
# dotfiles install script
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Linking dotfiles from $DOTFILES_DIR"

# zsh
ln -sf "$DOTFILES_DIR/zsh/.zshrc"   "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

# bin scripts
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR/bin/"*; do
    ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
    echo "  linked: ~/.local/bin/$(basename "$script")"
done

echo "==> Done. Reload shell: exec zsh"
echo ""
echo "NOTE: Create ~/.zshrc.secrets with your API keys (never commit this file)"
