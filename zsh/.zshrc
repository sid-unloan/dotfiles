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

# --- zsh plugins (cross-platform: brew on macOS, apt + ~/.local/share/zsh on Linux) ---

# Candidate dirs that may contain plugin shares
typeset -a _plugin_dirs
if command -v brew &>/dev/null; then
  _plugin_dirs+=("$(brew --prefix)/share")
fi
_plugin_dirs+=(/usr/share /usr/local/share "$HOME/.local/share/zsh")

# Add zsh-completions to FPATH (apt and brew use slightly different layouts)
for _d in $_plugin_dirs; do
  if [[ -d "$_d/zsh-completions/src" ]]; then
    FPATH="$_d/zsh-completions/src:$FPATH"
  elif [[ -d "$_d/zsh-completions" ]]; then
    FPATH="$_d/zsh-completions:$FPATH"
  fi
done
autoload -Uz compinit && compinit

# Source the first existing path for each plugin
_load_plugin() {
  local p
  for p in "$@"; do
    if [[ -r "$p" ]]; then
      source "$p"
      return 0
    fi
  done
  return 1
}

_brew_share=""
command -v brew &>/dev/null && _brew_share="$(brew --prefix)/share"

_load_plugin \
  "${_brew_share:+$_brew_share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$HOME/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

_load_plugin \
  "${_brew_share:+$_brew_share/zsh-you-should-use/you-should-use.plugin.zsh}" \
  "$HOME/.local/share/zsh/zsh-you-should-use/you-should-use.plugin.zsh" \
  /usr/share/zsh-you-should-use/you-should-use.plugin.zsh

# syntax-highlighting MUST be sourced last
_load_plugin \
  "${_brew_share:+$_brew_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$HOME/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

unset _brew_share _plugin_dirs _d

# Prompt
eval "$(starship init zsh)"

# zoxide — smarter cd (`z <dir>`); aliased to `cd` for ergonomics
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# fzf — fuzzy finder; key bindings (Ctrl-R history, Ctrl-T files, Alt-C cd) + completions
if command -v fzf &>/dev/null; then
  # macOS (brew) ships shell integrations under $(brew --prefix)/opt/fzf/shell
  # Linux apt ships them under /usr/share/doc/fzf/examples
  for _fzf_dir in \
    "${_brew_share_unset:-}" \
    "$(command -v brew &>/dev/null && echo $(brew --prefix)/opt/fzf/shell)" \
    /usr/share/doc/fzf/examples \
    /usr/share/fzf
  do
    [[ -z "$_fzf_dir" || ! -d "$_fzf_dir" ]] && continue
    [[ -r "$_fzf_dir/key-bindings.zsh" ]]    && source "$_fzf_dir/key-bindings.zsh"
    [[ -r "$_fzf_dir/completion.zsh"  ]]    && source "$_fzf_dir/completion.zsh"
    break
  done
  unset _fzf_dir
fi

# `just` — fall through to ~/.justfile (personal recipes like `just dozzle`)
# when there's no justfile in the current dir or any ancestor.
if command -v just &>/dev/null; then
  just() {
    local d="$PWD"
    while [[ "$d" != "/" ]]; do
      for f in justfile Justfile .justfile; do
        if [[ -f "$d/$f" ]]; then
          command just "$@"
          return $?
        fi
      done
      d="$(dirname "$d")"
    done
    command just --justfile "$HOME/.justfile" --working-directory "$PWD" "$@"
  }
fi

# Force blinking bar cursor (DECSCUSR 5) — prevents starship/zsh from resetting to block
_fix_cursor() { echo -ne '\e[5 q'; }
precmd_functions+=(_fix_cursor)
