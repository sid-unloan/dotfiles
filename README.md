# dotfiles

Terminal configuration for **macOS** and **Linux (Ubuntu/Debian)** — Starship prompt, Ghostty/Cmux, and Zsh.

## What's included

| Config | Description |
|--------|-------------|
| **Starship** | Powerline prompt with Catppuccin Mocha theme — git, AWS, Azure, Docker, direnv, Node.js, Python, memory usage |
| **Ghostty** | Catppuccin Mocha theme, blinking bar cursor (macOS only — Ghostty is macOS-exclusive) |
| **Zsh** | Lean config with autosuggestions, syntax highlighting, completions, you-should-use |

## Requirements

**macOS:**
- [Homebrew](https://brew.sh)
- [Ghostty](https://ghostty.org/) or [Cmux](https://github.com/manaflow-ai/cmux)
- A [Nerd Font](https://www.nerdfonts.com/) installed in your terminal

**Linux (Ubuntu/Debian):**
- `apt-get` and `sudo` (or run as root)
- A [Nerd Font](https://www.nerdfonts.com/) installed in your terminal

## Install

```bash
git clone https://github.com/sid-unloan/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh
```

The install script is **idempotent** — safe to re-run any time. It will:

1. Detect the OS (macOS/Linux) and install required packages
   - macOS: Homebrew (`starship`, zsh plugins)
   - Linux: `apt-get` (`zsh-autosuggestions`, `zsh-syntax-highlighting`) + git clones for `zsh-completions` and `zsh-you-should-use` + the official starship installer
2. Symlink configs from this repo into `$HOME` (timestamped backup of any existing non-symlink files; no-op if already correctly linked)
3. Create `~/.zshrc.local` for machine-specific secrets (not tracked) — only if it doesn't exist
4. Skip the Ghostty symlink on Linux (Ghostty is macOS-only)

## Machine-specific config

Put secrets and local environment variables in `~/.zshrc.local` — it's sourced by `.zshrc` and gitignored.

## CI

`.github/workflows/test-install.yml` runs `install.sh` twice (idempotency check) on both `ubuntu-latest` and `macos-latest` GitHub-hosted runners on every push/PR, then verifies the symlinks and boots zsh + starship.

## Structure

```
dotfiles/
├── install.sh
├── zsh/.zshrc
├── starship/starship.toml
├── ghostty/config           # macOS only
└── .github/workflows/test-install.yml
```
