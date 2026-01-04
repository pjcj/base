#!/usr/bin/env bash
# Termux .bashrc - portable version of .zshrc
# Copy to ~/.bashrc on Termux

# Exit if not interactive
[[ $- != *i* ]] && return

# Shell options

shopt -s autocd           # cd by typing directory name
shopt -s cdspell          # autocorrect cd typos
shopt -s checkwinsize     # update LINES and COLUMNS after each command
shopt -s cmdhist          # save multi-line commands as single history entry
shopt -s direxpand        # expand directory names
shopt -s dirspell         # autocorrect directory typos
shopt -s dotglob          # include dotfiles in globbing
shopt -s extglob          # extended pattern matching
shopt -s globstar         # ** matches all files and directories
shopt -s histappend       # append to history, don't overwrite
shopt -s nocaseglob       # case-insensitive globbing

# History

HISTFILE=~/.bash_history
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "

# Environment

export EDITOR=vim
export VISUAL=$EDITOR
export PAGER="less"
export LESS='--LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export BAT_THEME="Solarized (dark)"
# Termux only has C.UTF-8 by default
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Termux-specific paths
if [[ -d /data/data/com.termux ]]; then
  PREFIX=/data/data/com.termux/files/usr
  export PATH=$HOME/bin:$PREFIX/bin:$PATH
  export TERMUX=1
fi

# Vi mode

set -o vi
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[6 q\2'
bind 'set vi-cmd-mode-string \1\e[2 q\2'

# Faster escape
bind 'set keyseq-timeout 50'

# Key bindings

# Ctrl-L to clear screen (works in vi mode)
bind -m vi-insert '\C-l:clear-screen'

# History search with arrow keys
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Colours

# Solarized colours
s_base03="#002b36"
s_base02="#073642"
s_base01="#586e75"
s_base00="#657b83"
s_base0="#839496"
s_base1="#93a1a1"
s_base2="#eee8d5"
s_base3="#fdf6e3"
s_yellow="#b58900"
s_orange="#cb4b16"
s_red="#dc322f"
s_magenta="#d33682"
s_violet="#6c71c4"
s_blue="#268bd2"
s_cyan="#2aa198"
s_green="#859900"

# LS colours
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Prompt

__git_prompt() {
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  if [[ -n $branch ]]; then
    local status_flags=""
    local git_status
    git_status=$(git status --porcelain 2>/dev/null)

    # Check for changes
    [[ -n $git_status ]] && status_flags+="*"

    # Check for staged changes
    git diff --cached --quiet 2>/dev/null || status_flags+="+"

    # Check for untracked files
    [[ $git_status == *"??"* ]] && status_flags+="?"

    if [[ -n $status_flags ]]; then
      echo " $branch $status_flags"
    else
      echo " $branch"
    fi
  fi
}

__set_prompt() {
  local exit_code=$?
  local reset='\[\e[0m\]'
  local cyan='\[\e[36m\]'
  local yellow='\[\e[33m\]'
  local green='\[\e[32m\]'
  local red='\[\e[31m\]'
  local blue='\[\e[34m\]'
  local magenta='\[\e[35m\]'

  # Exit code indicator
  local prompt_char
  if [[ $exit_code -eq 0 ]]; then
    prompt_char="${green}❯${reset}"
  else
    prompt_char="${red}❯${reset}"
  fi

  # Git info
  local git_info
  git_info=$(__git_prompt)

  PS1="${cyan}[termux]${reset} "
  PS1+="${yellow}\w${reset}"
  PS1+="${magenta}${git_info}${reset}"
  PS1+="\n${prompt_char} "
}

PROMPT_COMMAND=__set_prompt

# Aliases - General

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias v='vim'
alias m='bat --tabs=2'

# ls/eza
if command -v eza &>/dev/null; then
  alias f='eza -lagH --git --icons --colour=always'
  alias d='eza -lagH --git --icons --colour=always'
  alias dt='eza -lagH --git --icons --colour=always -T'
else
  alias f='ls -lAh --color=auto'
  alias d='ls -lAh --color=auto'
fi

alias ll='f | less -r'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Aliases - Git

alias g='git'
alias ga='git add'
alias gb='git branch'
alias gbl='git blame -wMC'
alias gc='git commit'
alias gca='git commit --amend'
alias gcae='git commit --amend --no-edit'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --stat'
alias gf='git fetch --prune --prune-tags'
alias gg='git grep -n'
alias gh='git checkout'
alias gl='git log --oneline --graph --all'
alias gll='git log --oneline --graph'
alias gm='git merge --no-commit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias gpof='git push origin --force-with-lease'
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias grh='git reset HEAD'
alias grs='git restore --staged'
alias gs='git status'
alias gsh='git show --remerge-diff'

# Aliases - SSH to Mac

alias mac='ssh mac'
alias mactm='ssh -t mac "tmux new-session -t base"'

# Functions

# Change directory and list
c() {
  if [[ -d "$1" ]]; then
    cd "$1" && f
  elif [[ -f "$1" ]]; then
    cd "$(dirname "$1")" && f
  else
    cd "$1"
  fi
}

# Go up directories
u() {
  local count=${1:-1}
  local path=""
  for ((i = 0; i < count; i++)); do
    path="../$path"
  done
  cd "$path" || return
}

# tmux helper (from your zsh config)
tm() {
  if [[ -z "$1" ]]; then
    tmux
  else
    if tmux has-session -t "$1" 2>/dev/null; then
      tmux attach-session -t "$1"
    else
      tmux new-session -s "$1"
    fi
  fi
}

# Quick history search
h() {
  history | grep "$@"
}

hh() {
  history
}

# Which with path info
wh() {
  echo "PATH is $PATH"
  echo
  type -a "$@"
}

# FZF

if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS="
    --height 80% --reverse --inline-info
    --color fg:-1,bg:-1,hl:$s_blue,fg+:$s_base3,bg+:$s_base02,hl+:$s_blue
    --color info:$s_cyan,prompt:$s_violet,pointer:$s_green,marker:$s_base3
    --bind 'ctrl-/:toggle-preview'
  "

  # Use fd if available
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi

  # Source fzf keybindings if available
  [[ -f $PREFIX/share/fzf/key-bindings.bash ]] && source "$PREFIX/share/fzf/key-bindings.bash"
  [[ -f $PREFIX/share/fzf/completion.bash ]] && source "$PREFIX/share/fzf/completion.bash"

  # fzf history search
  fh() {
    local cmd
    cmd=$(history | fzf --tac +s | sed 's/^ *[0-9]* *//')
    if [[ -n $cmd ]]; then
      echo "$cmd"
      eval "$cmd"
    fi
  }

  # fzf cd
  fcd() {
    local dir
    dir=$(fd --type d --hidden --exclude .git | fzf --preview 'ls -la {}')
    [[ -n $dir ]] && cd "$dir"
  }
fi

# Zoxide

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash --cmd q)"
fi

# Completions

# Git completion
if [[ -f $PREFIX/share/bash-completion/completions/git ]]; then
  source "$PREFIX/share/bash-completion/completions/git"

  # Add completion to aliases
  __git_complete g __git_main
  __git_complete ga _git_add
  __git_complete gb _git_branch
  __git_complete gc _git_commit
  __git_complete gd _git_diff
  __git_complete gf _git_fetch
  __git_complete gh _git_checkout
  __git_complete gl _git_log
  __git_complete gm _git_merge
  __git_complete gp _git_push
  __git_complete gr _git_rebase
  __git_complete gs _git_status
fi

# General bash completion
[[ -f $PREFIX/share/bash-completion/bash_completion ]] && \
  source "$PREFIX/share/bash-completion/bash_completion"

# Local customisations

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

# Startup message

echo "bash loaded - $(date '+%H:%M')"
