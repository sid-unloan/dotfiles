#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing dotfiles from $DOTFILES_DIR"

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing Homebrew packages..."
brew install starship \
  zsh-autosuggestions \
  zsh-completions \
  zsh-syntax-highlighting \
  zsh-you-should-use

# Fix zsh-completions permissions
chmod go-w "$(brew --prefix)/share" 2>/dev/null || true
chmod -R go-w "$(brew --prefix)/share/zsh" 2>/dev/null || true

# --- Symlinks ---
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "    Backing up $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "    $dst -> $src"
}

echo "==> Creating symlinks..."
link "$DOTFILES_DIR/zsh/.zshrc"              "$HOME/.zshrc"
link "$DOTFILES_DIR/starship/starship.toml"  "$HOME/.config/starship.toml"
link "$DOTFILES_DIR/ghostty/config"          "$HOME/.config/ghostty/config"

# --- Local config ---
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  echo "==> Creating ~/.zshrc.local template..."
  cat > "$HOME/.zshrc.local" << 'EOF'
# Machine-specific environment variables and secrets
# This file is sourced by .zshrc and is NOT tracked in git

# export MY_SECRET_KEY=xxx
# export PATH=$HOME/.some-tool/bin:$PATH
EOF
fi

# --- Clean up stale completion cache ---
rm -rf ~/.zcompdump* 2>/dev/null || true

echo ""
echo "==> Done! Open a new terminal or run: exec zsh"
