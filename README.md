# dotfiles

Terminal configuration for macOS — Starship prompt, Ghostty/Cmux, and Zsh.

## What's included

| Config | Description |
|--------|-------------|
| **Starship** | Powerline prompt with Catppuccin Mocha theme — git, AWS, Azure, Docker, direnv, Node.js, Python, memory usage |
| **Ghostty** | Catppuccin Mocha theme, blinking bar cursor |
| **Zsh** | Lean config with Homebrew plugins — autosuggestions, syntax highlighting, completions, you-should-use |

## Requirements

- macOS with [Homebrew](https://brew.sh)
- A [Nerd Font](https://www.nerdfonts.com/) installed in your terminal
- [Ghostty](https://ghostty.org/) or [Cmux](https://github.com/manaflow-ai/cmux)

## Install

```bash
git clone https://github.com/sid-unloan/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
chmod +x install.sh
./install.sh
```

The install script will:
1. Install Homebrew packages (starship, zsh plugins)
2. Back up existing configs (`.bak` suffix)
3. Symlink configs from this repo
4. Create `~/.zshrc.local` for machine-specific secrets (not tracked)

## Machine-specific config

Put secrets and local environment variables in `~/.zshrc.local` — it's sourced by `.zshrc` and gitignored.

## Structure

```
dotfiles/
├── install.sh
├── zsh/.zshrc
├── starship/starship.toml
└── ghostty/config
```
