#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

echo "==> Installing dotfiles from $DOTFILES_DIR (os: $OS)"

# --- Helpers ---

# Idempotent git clone-or-update
clone_or_pull() {
  local url="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    echo "    Updating $dest"
    git -C "$dest" pull --ff-only --quiet || true
  else
    echo "    Cloning $url -> $dest"
    mkdir -p "$(dirname "$dest")"
    git clone --depth 1 --quiet "$url" "$dest"
  fi
}

# Pick a sudo command if needed and available
sudo_if_needed() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    echo "ERROR: this step needs root, but no sudo found: $*" >&2
    return 1
  fi
}

# --- Package install ---

if [[ "$OS" == "macos" ]]; then
  if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "==> Installing Homebrew packages..."
  for pkg in starship zsh-autosuggestions zsh-completions zsh-syntax-highlighting zsh-you-should-use; do
    if brew list --formula "$pkg" &>/dev/null; then
      echo "    $pkg already installed"
    else
      brew install "$pkg"
    fi
  done

  # Fix zsh-completions permissions (compinit complains about world-writable dirs)
  chmod go-w "$(brew --prefix)/share" 2>/dev/null || true
  chmod -R go-w "$(brew --prefix)/share/zsh" 2>/dev/null || true

elif [[ "$OS" == "linux" ]]; then
  if ! command -v apt-get &>/dev/null; then
    echo "ERROR: Linux install requires apt-get (Ubuntu/Debian). Install packages manually for your distro." >&2
    exit 1
  fi

  echo "==> Installing apt packages..."
  sudo_if_needed apt-get update -qq
  sudo_if_needed apt-get install -y --no-install-recommends \
    zsh git curl ca-certificates \
    zsh-autosuggestions zsh-syntax-highlighting

  # zsh-completions and you-should-use aren't in apt — clone them
  echo "==> Cloning extra zsh plugins..."
  clone_or_pull https://github.com/zsh-users/zsh-completions.git \
    "$HOME/.local/share/zsh/zsh-completions"
  clone_or_pull https://github.com/MichaelAquilina/zsh-you-should-use.git \
    "$HOME/.local/share/zsh/zsh-you-should-use"

  if ! command -v starship &>/dev/null; then
    echo "==> Installing starship..."
    curl -fsSL https://starship.rs/install.sh | sudo_if_needed sh -s -- -y
  else
    echo "    starship already installed"
  fi
fi

# --- Symlinks ---

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "    $dst -> $src (already linked)"
    return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "    Backing up $dst -> $bak"
    mv "$dst" "$bak"
  fi
  ln -snf "$src" "$dst"
  echo "    $dst -> $src"
}

echo "==> Creating symlinks..."
link "$DOTFILES_DIR/zsh/.zshrc"             "$HOME/.zshrc"
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# Ghostty is macOS-only — skip on Linux
if [[ "$OS" == "macos" ]]; then
  link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
fi

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
