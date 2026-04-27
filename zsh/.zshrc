# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Key bindings (emacs mode — arrow keys, home/end, delete work as expected)
bindkey -e
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias gp='git push'
alias gst='git status'
alias glog='git log --oneline --graph --decorate'

# Environment
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Machine-specific config (secrets, env vars) — not tracked in git
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# zsh plugins (Homebrew)
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
autoload -Uz compinit && compinit
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Prompt
eval "$(starship init zsh)"

# Force blinking bar cursor (DECSCUSR 5) — prevents starship/zsh from resetting to block
_fix_cursor() { echo -ne '\e[5 q'; }
precmd_functions+=(_fix_cursor)

# fnm (Fast Node Manager) — replaces nvm; near-instant shell startup
# Auto-switches Node version on cd into dirs with .nvmrc / .node-version
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
