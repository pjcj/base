# Loading status
zshrc_load_status () {
    echo -n "\r.zshrc load: $* ... \e[0K"
}

zshrc_load_status "plugins"

# zsh-autoenv
AUTOENV_FILE_ENTER=.autoenv.zsh
AUTOENV_FILE_LEAVE=.autoenv.zsh
AUTOENV_HANDLE_LEAVE=1
AUTOENV_LOOK_UPWARDS=1

source ~/.zplug/init.zsh

# https://github.com/tj/git-extras/blob/master/Commands.md
zplug "zsh-users/zsh-completions"
zplug "zdharma/fast-syntax-highlighting"
zplug "Tarrasch/zsh-autoenv"
# zplug "agkozak/agkozak-zsh-prompt"
zplug "woefe/git-prompt.zsh"
zplug "woefe/vi-mode.zsh"

if ! zplug check; then zplug install; fi
zplug load

zshrc_load_status "setting options"

setopt                        \
       all_export             \
       always_last_prompt     \
    NO_always_to_end          \
       append_history         \
       auto_cd                \
       auto_list              \
       auto_menu              \
    NO_auto_name_dirs         \
       auto_param_keys        \
       auto_param_slash       \
       auto_pushd             \
       auto_remove_slash      \
    NO_auto_resume            \
       bad_pattern            \
       bang_hist              \
       beep                   \
    NO_bgnice                 \
       brace_ccl              \
    NO_bsd_echo               \
    NO_chase_links            \
       cdable_vars            \
    NO_clobber                \
       complete_aliases       \
       complete_in_word       \
       correct                \
    NO_correct_all            \
       csh_junkie_history     \
    NO_csh_junkie_loops       \
    NO_csh_junkie_quotes      \
    NO_csh_null_glob          \
       equals                 \
       extended_glob          \
       extended_history       \
       function_argzero       \
       glob                   \
    NO_glob_assign            \
    NO_glob_complete          \
       glob_dots              \
       glob_subst             \
       hash_cmds              \
       hash_dirs              \
       hash_list_all          \
       hist_allow_clobber     \
       hist_beep              \
    NO_hist_expire_dups_first \
    NO_hist_ignore_all_dups   \
    NO_hist_ignore_dups       \
    NO_hist_no_functions      \
       hist_reduce_blanks     \
    NO_hist_save_no_dups      \
       hist_ignore_space      \
       hist_no_store          \
       hist_verify            \
    NO_hup                    \
    NO_ignore_braces          \
    NO_ignore_eof             \
       inc_append_history     \
       interactive_comments   \
    NO_ksh_glob               \
    NO_list_ambiguous         \
    NO_list_beep              \
       list_packed            \
    NO_list_types             \
       long_list_jobs         \
       magic_equal_subst      \
       mail_warning           \
    NO_mark_dirs              \
    NO_menu_complete          \
       multios                \
       nomatch                \
       notify                 \
    NO_null_glob              \
       numeric_glob_sort      \
    NO_overstrike             \
       path_dirs              \
       rematch_pcre           \
       posix_builtins         \
       print_exit_value       \
    NO_prompt_cr              \
       prompt_subst           \
       pushd_ignore_dups      \
    NO_pushd_minus            \
    NO_pushd_silent           \
       pushd_to_home          \
       rc_expand_param        \
    NO_rc_quotes              \
    NO_rec_exact              \
       rm_star_silent         \
    NO_rm_star_wait           \
    NO_sh_file_expansion      \
       sh_option_letters      \
    NO_sh_word_split          \
       share_history          \
       short_loops            \
    NO_single_line_zle        \
       sun_keyboard_hack      \
       unset                  \
    NO_verbose                \
    NO_xtrace                 \
       zle

zshrc_load_status "setting environment"

fpath=(
    ~/{lib/zsh,.zsh,g/base/zsh}/{functions,scripts}(N)
    ~/g/go/src/github.com/motemen/ghq/zsh(N)
    $fpath
)
typeset -U fpath

# Ignore these corrections
CORRECT_IGNORE="[._]*"

# Choose word delimiter characters in line editor
WORDCHARS=""

# Save a large history
HISTFILE=~/.zshhistory
HISTSIZE=100000000
SAVEHIST=100000000

# Maximum size of completion listing
# Only ask if line would scroll off screen
LISTMAX=0

# Watching for other users
LOGCHECK=60
WATCHFMT="[%B%t%b] %B%n%b has %a %B%l%b from %B%M%b"

# The time the shell waits, in hundredths of seconds, for another key
# to be pressed when reading bound multi-character sequences.
#
# Set to shortest possible delay is 1/100 second.
# This allows escape sequences like cursor/arrow keys to work,
# while eliminating the delay exiting vi insert mode.

KEYTIMEOUT=1

zshrc_load_status "completion system"

autoload -U compinit
compinit -u
zmodload -i zsh/complist
autoload -U zargs

zstyle ":completion:*" menu select
zstyle ":completion:*" show-ambiguity true
zstyle ":completion:*" ambiguous true
zstyle ":completion:*" list-colors ""
# _ and - are interchangeable
zstyle ":completion:*" matcher-list "m:{a-zA-Z-_}={A-Za-z_-}" \
                                    "r:|[._-]=* r:|=*" "l:|=* r:|=*"

zstyle ":completion:*:*:kill:*:processes" list-colors \
           "=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01"
zstyle ":completion:*:*:*:*:processes" \
           command "ps -u $USER -o pid,user,comm -w -w"

zstyle ":completion::complete:*" use-cache 1

# Don't complete uninteresting users
zstyle ":completion:*:*:*:users" ignored-patterns                             \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna     \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm        \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm    \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios    \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn    \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp   \
        usbmux uucp vcsa wwwrun xfs "_*"
# ... unless we really want to.
zstyle "*" single-ignored show

# Local completion

compdef _which wh
compdef _make  n
compdef _git   g=git
compdef _git   ga=git-add
compdef _git   gb=git-branch
compdef _git   gc=git-commit
compdef _git   gca=git-commit
compdef _git   gcae=git-commit
compdef _git   gd=git-diff
compdef _git   gds=git-diff
compdef _git   gvd=git-diff
compdef _git   gf=git-fetch
compdef _git   gg=git-grep
compdef _git   gl=git-log
compdef _git   gld=git-log
compdef _git   gll=git-log
compdef _git   gls=git-log
compdef _git   glsa=git-log
compdef _git   go=git-checkout
compdef _git   gp=git-push
compdef _git   gpf=git-push
compdef _git   gpo=git-push
compdef _git   gpof=git-push
compdef _git   gr=git-rebase
compdef _git   gra=git-rebase
compdef _git   grc=git-rebase
compdef _git   grh=git-reset
compdef _git   gri=git-rebase
compdef _git   gs=git-status
compdef _git   gsh=git-show
compdef _git   gw=git-wtf
compdef _dzil  z=dzil

_git-branch-full-delete() { __git_branch_names }
zstyle ":completion:*:*:git:*" user-commands \
    branch-full-delete:"delete local and remote branches"

_git-origin-branch-move() { __git_branch_names }
zstyle ":completion:*:*:git:*" user-commands \
    origin-branch-move:"move branch to its origin"

_git-fpush() { __git_branch_names }
zstyle ":completion:*:*:git:*" user-commands \
    fpush:"force push even when the remote forbids it"

zshrc_load_status "ftp"
autoload -U zfinit
zfinit

zshrc_load_status "key bindings"

bindkey -v -m 2> /dev/null

autoload -U history-search-end
zle -N history-beginning-search-backward-end \
     history-search-end
zle -N history-beginning-search-forward-end \
     history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
bindkey "^[OA" history-beginning-search-backward-end
bindkey "^[OB" history-beginning-search-forward-end

# zmodload zsh/terminfo
# bindkey "$terminfo[kcuu1]" history-substring-search-up
# bindkey "$terminfo[kcud1]" history-substring-search-down
# bindkey "^[[A" history-substring-search-up
# bindkey "^[[B" history-substring-search-down

autoload -U history-beginning-search-menu-space-end \
       history-beginning-search-menu
zle -N history-beginning-search-menu-space-end \
       history-beginning-search-menu
bindkey "^X" history-beginning-search-menu-space-end

bindkey "^O" push-line-or-edit
bindkey "^P" accept-and-infer-next-history

bindkey "^E" undefined-key
bindkey "^Y" undefined-key

zshrc_load_status "miscellaneous"

# url-quote-magic breaks fast-syntax-highlighting
# autoload -U url-quote-magic && zle -N self-insert url-quote-magic

REPORTTIME=10
TIMEFMT="  %J  %E %P  %U user + %S system  %W swaps  %Mk mem"

LS_OPTIONS=

export NPM_PACKAGES=~/g/sw/.npm-packages

zshrc_load_status "path"

PATH=~/.local/bin:~/g/go/bin:~/bin:~/g/sw/bin:~/g/sw/usr/bin:$PATH
PATH=$NPM_PACKAGES/bin:$PATH
PATH=$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH
PATH=$HOME/.cargo/bin:$PATH
PATH=~/g/local_base/utils:~/g/base/utils:$PATH
PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
MANPATH=/usr/share/man:${MANPATH:-manpath}
MANPATH=~/g/sw/share/man:$NPM_PACKAGES/share/man:$MANPATH

zshrc_load_status "aliases"

alias mkdir "nocorrect mkdir"

zshrc_load_status "functions"

if which nvim >&/dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

c() {
    local DIR="$1:h"
    local STRIP="$1:r"
    local EXT="$1:e"

    if [[ "$EXT" == .(gz|bz2) && "$STRIP" == *.tar ]]; then
        STRIP="$STRIP:r"
        EXT=".tar$EXT"
    fi
    if [[ -d "$1" ]]; then
        builtin pushd "$1"
    elif [[ "$EXT" == .(tar.(gz|bz2)|tgz|zip|TGZ|ZIP) &&
            -d "$STRIP" ]]; then
        builtin pushd "$STRIP"
    elif [[ -f "$1" ]]; then
        builtin pushd "$DIR"
    else
        builtin pushd "$1"
    fi
}

d() { f "$@" }

u() { popd }

v() {
    if [ "$EDITOR" = "nvim" ]; then
        command $EDITOR "$@"
    else
        command $EDITOR -u NONE "$@"
    fi
}

man() {
    env \
        LESS_TERMCAP_mb=$'\e[1;31m'      \
        LESS_TERMCAP_md=$'\e[1;31m'      \
        LESS_TERMCAP_me=$'\e[0m'         \
        LESS_TERMCAP_se=$'\e[0m'         \
        LESS_TERMCAP_so=$'\e[0;37;102m'  \
        LESS_TERMCAP_ue=$'\e[0m'         \
        LESS_TERMCAP_us=$'\e[4;32m'      \
        _NROFF_U=1                       \
        PATH=${HOME}/bin:${PATH}         \
    man "$@"
}

cd()      { c "$@" && d }
ddl()     { ds /{dl,music}*/**/*(#i)"$@"*(N) }
dh()      { f "$@" | head }
dm()      { fc -e - d=m -1 }
g()       { git "$@" }
ga()      { git add "$@" }
gb()      { git branch "$@" }
gc()      { git commit -v "$@" }
gca()     { git commit --amend -v "$@" }
gcae()    { git commit --amend --no-edit "$@" }
gd()      { git diff "$@" }
gds()     { git diff --stat "$@" }
gdw()     { git diffwords "$@" }
gf()      { git fetch --prune --all "$@" }
gg()      { git grep -n "$@" }
ggv()     { git grep -O$EDITOR "$@" }
gl()      { git lg --all "$@" }
gll()     { git lg "$@" }
gld()     { git lg --all --date=iso "$@" }
gls()     { git lg --simplify-by-decoration "$@" }
glsa()    { git lg --all --simplify-by-decoration "$@" }
go()      { git co "$@" }
gp()      { git push "$@" }
gpf()     { git push --force-with-lease "$@" }
gpo()     { git push origin "$@" }
gpof()    { git push origin --force-with-lease "$@" }
gr()      { git rebase --rebase-merges "$@" }
gra()     { git rebase --abort "$@" }
grc()     { git rebase --continue "$@" }
grh()     { git reset HEAD "$@" }
gri()     { git rebase -i "$@" }
gs()      { git st "$@" }
gsh()     { git show "$@" }
gw()      { git wtf -A "$@" }
golang()  { command go "$@" }
h()       { fc -li "$@" }
hg()      { fc -li 1 | grep "$@" }
hh()      { fc -li 1 }
ht()      { sudo =htop }
kitty()   { ~/.local/kitty.app/bin/kitty "$@" }
ll()      { f "$@" | less -r -X }
lu()      { fc -e - lsq=usq -1 }
m()       { bat "$@" }
mn()      { nroff -man "$@" | m }
mutt()    { mkdir -p /tmp/ml && command mutt "$@" }
n()       { make "$@" }
p()       { pp | head }
pl()      { ps -o user,pid,ppid,pcpu,pmem,vsz,rss,tty,s,stime,time,args "$@" }
pm()      { pod2man "$@" | mn }
pp()      { pl -A "$@" | sort -k 4 }
restart() { exec $SHELL "$@" }
rssh()    { ssh -p 9999 "$@" localhost }
rtunnel() { ssh -N -f -R 9999:localhost:22 "$@" }
rr()      { ranger "$@" }
s()       { gnome-open "$@" }
tg()      { tcgrep -brun "$@" }
tmux()    { command tmux -u2 "$@" }
tojpg()   { for f ("$@") { echo "$f"; j=`echo $f(:r)`; convert "$f" "$j.jpg" } }
t()       { TERM=xterm-color tig --all "$@" }
tf()      { tail -f "$@" }
ud()      { u "$@"; d }
uu()      { uuencode "$@" "$@" | mailx -s "$@" paul@pjcj.net }
z()       { dzil "$@" }
zb()      { perl Makefile.PL; make clean; perl Makefile.PL; dzil build "$@" }
zt()      { perl Makefile.PL; make clean; perl Makefile.PL; dzil test "$@" }
= ()      { echo "$@" | bc -l }

setup_plenv() {
    build plenv
    build Perl-Build
}

wh() {
    echo PATH is $PATH
    echo
    command whence -cm "$@"
    echo
    command whence -afpSvm "$@"
}

tm() {
    [[ -z "$1" ]] && { echo "usage: tm <session>" >&2; return 1; }
    tmux has -t $1 && tmux attach -d -t $1 || tmux new -s $1
}
__tmux-sessions() {
    local expl
    local -a sessions
    sessions=( ${${(f)"$(command tmux list-sessions)"}/:[ $'\t']##/:} )
    _describe -t sessions "sessions" sessions "$@"
}
compdef __tmux-sessions tm

zshrc_load_status "hashed directories"

hash -d g=~/g
hash -d sw=~/g/sw
hash -d dc=~/g/perl/Devel--Cover
hash -d am=~/g/perl/AMeasure
hash -d base=~/g/base
hash -d local_base=~/g/local_base

zshrc_load_status "environment"

export BAT_THEME="Solarized"
export GOPATH=~/g/go
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
export LESSOPEN="|lesspipe.sh %s"
export LESS='--no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export NOPASTE_SERVICES="Gist Pastie Snitch Shadowcat"
export PAGER='bat -n'
export TERMINFO=~/.terminfo
export TMOUT=0
export TOP="-I all"
export TEMPLATE_DIR=~base/templates
export VISUAL=$EDITOR

if which python3 >&/dev/null; then
    export PYTHON3=python3
elif which python3.6 >&/dev/null; then
    export PYTHON3=python3.6
fi

export ISVM=
if [[ $(uname) == Darwin ]]; then
    cp() { command gcp -bv --backup=numbered "$@" }
    f()  { lsd -Ahl "$@" }
    ds() { lsd -hld "$@" }
    mv() { command gmv -bv --backup=numbered "$@" }
elif [[ $(uname) == FreeBSD ]]; then
    cp() { command cp -v "$@" }
    f()  { ls -ABGhl "$@" }
    ds() { f -d "$@" }
    mv() { command mv -v "$@" }
else
    if which dmidecode >&/dev/null; then
        (sudo dmidecode -t system | grep -q VirtualBox) && ISVM=1
    fi
    cp() { command cp -bv --backup=numbered "$@" }
    f()  { ls -ABhl --color=tty -I \*.bak -I .\*.bak "$@" }
    ds() { f -d "$@" }
    mv() { command mv -bv --backup=numbered "$@" }
fi

[[ ! -d ~/g/tmp/vim ]] && mkdir -p ~/g/tmp/vim

eval "$(thefuck --alias ff)"

function preexec {
    [[ -z $SSH_CLIENT ]] || export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
}

zshrc_load_status "colours"

export s_base03="#001920"
export s_base02="#022731"
export s_base01="#586e75"
export s_base00="#657b83"
export s_base0="#839496"
export s_base1="#93a1a1"
export s_base2="#eee8d5"
export s_base3="#fdf6e3"
export s_yellow="#b58900"
export s_orange="#cb4b16"
export s_red="#dc322f"
export s_magenta="#d33682"
export s_violet="#6c71c4"
export s_blue="#268bd2"
export s_cyan="#2aa198"
export s_green="#859900"
export s_normal="#9599dc"

export s_rgreen="#25ad2e"  # a nice green for diffs (opposite of s:red)

zshrc_load_status "external files"

load() {
    for f in $@; do
        if [[ -r $f ]]; then
            zshrc_load_status "$f"
            . $f
        fi
    done
}

load \
    /etc/zsh_command_not_found                \
    ~/.gvm/scripts/gvm                        \
    ~/g/sw/etc/zsh/*(N)                       \
    /usr/local/opt/fzf/shell/key-bindings.zsh \
    /usr/local/opt/fzf/shell/completion.zsh   \
    ~/.iterm2_shell_integration.zsh           \
    ~/.zshrc.local                            \
    ~/.zshrc.${HOST%%.*}

zshrc_load_status "perl"

[[ -z $PERLBREW_ROOT ]] && export PERLBREW_ROOT="$HOME/perl5/perlbrew"
if [[ -e $PERLBREW_ROOT/etc/bashrc ]] then
    __path=$PATH
    __manpath=$MANPATH
    . $PERLBREW_ROOT/etc/bashrc 2>/dev/null
    . $PERLBREW_ROOT/etc/perlbrew-completion.bash
    PATH=$PERLBREW_ROOT/bin:$__path
    MANPATH=${MANPATH:-manpath}:$__manpath
    pb() { TEST_JOBS=9 perlbrew -j9 "$@" }
    complete -F _perlbrew_compgen pb
fi

if [[ -e ~/.plenv ]] then
    export PATH=~/.plenv/bin:$PATH
    eval "$(plenv init - zsh)"
fi

zshrc_load_status "fzf"

# Commands:
# Ctrl-F - file
# Ctrl-N - cd
# Ctrl-R - history
# Ctrl-G - git commit
# Ctrl-B - git branch
# Ctrl-T - git tag

fh() { print -z $(fc -li 1 | fzf-tmux +s --tac | sed -r 's/ *[0-9]+.{18}//') }

if which lsd >&/dev/null; then
    tree="lsd --tree --color=always --icon=always"
else
    tree="tree -C"
fi
head="2>/dev/null | head -250"

export FZF_TMUX=1
export FZF_TMUX_HEIGHT=40%
export FZF_DEFAULT_OPTS="
    --height 40% --reverse --inline-info
    --color fg:-1,bg:-1,hl:$s_blue,fg+:$s_normal,bg+:$s_base02,hl+:$s_blue
    --color info:$s_cyan,prompt:$s_violet,pointer:$s_green,marker:$s_base3,spinner:$s_yellow
"
export FZF_DEFAULT_COMMAND="fd --hidden --no-ignore-vcs --exclude .git"
export FZF_CTRL_T_OPTS="--preview '(bat --color=always {} 2>/dev/null || cat {} || $tree {}) $head'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview '$tree {} $head'"
export FZF_ALT_C_COMMAND="fd --hidden --no-ignore-vcs --exclude .git --type d"

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
}

_fzfgv="xargs -I % sh -c 'git show --color=always % | diff-so-fancy-wrapper'"

git-commit-sel() {
    setopt localoptions pipefail 2> /dev/null
    local get_sha="grep -o '[a-f0-9]\+' | head -1"
    local cmd="echo {} | $get_sha | $_fzfgv"
    gl --color | $(__fzfcmd) --ansi --tiebreak=index --preview="$cmd" "$@" | \
        while read item; do
        echo -n "${item}" | eval "$get_sha"
    done
    local ret=$?
    echo
    return $ret
}

fzf-git-commit-widget() {
    LBUFFER="${LBUFFER}$(git-commit-sel)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle -N fzf-git-commit-widget

git-tag-sel() {
    setopt localoptions pipefail 2> /dev/null
    local cmd="echo {} | $_fzfgv"
    g tag | $(__fzfcmd) --tiebreak=index --preview="$cmd" "$@" | \
        while read item; do
        echo -n "${item}"
    done
    local ret=$?
    echo
    return $ret
}

fzf-git-tag-widget() {
    LBUFFER="${LBUFFER}$(git-tag-sel)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle -N fzf-git-tag-widget

git-branch-sel() {
    setopt localoptions pipefail 2> /dev/null
    local get_full_branch="perl -pe 's/..([^ ]+) .*/\$1/'"
    local get_branch="perl -pe 's/.*?([-\w]+) .*/\$1/'"
    local cmd="echo {} | $get_full_branch | $_fzfgv"
    local opts="-vv --sort=-committerdate --color=always"
    (eval "gb $opts; gb -r $opts") | \
        $(__fzfcmd) --ansi --tiebreak=index --preview="$cmd" "$@" | \
        while read item; do
        echo -n "${item}" | eval "$get_branch"
    done
    local ret=$?
    echo
    return $ret
}

fzf-git-branch-widget() {
    LBUFFER="${LBUFFER}$(git-branch-sel)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle -N fzf-git-branch-widget

bindkey '^F' fzf-file-widget
bindkey '^N' fzf-cd-widget
bindkey '^G' fzf-git-commit-widget
bindkey '^B' fzf-git-branch-widget
bindkey '^T' fzf-git-tag-widget

zshrc_load_status "paths"

typeset -U path
typeset -U manpath
path=($^path(N))
manpath=($^manpath(N))

# from command-not-found package

zshrc_load_status "prompt"

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

if [ 1 = 0 ]; then
    if [ "$(whoami)" = "root" ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi

    perlv () { perl -e '$t = -e "Makefile"; $_ = $t ? `grep "FULLPERL = " Makefile` : `which perl`; s|.*/(.*)/bin/perl.*|$1 |; s/^usr $//; s/perl-// if $t; print' }

    if [[ $(uname) == "FreeBSD" ]]; then
        prompt_root=~sw/zsh-git-prompt
        PROMPT='%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '
    else
        if [[ $(uname) == Linux ]]; then
            prompt_root=$(ghq list -p zsh-git-prompt)
        else
            # prompt_root=/usr/local/Cellar/zsh-git-prompt/*
            prompt_root=~sw/pkg/zsh-git-prompt
        fi

        PROMPT='$(git_super_status)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '

        load $prompt_root/zshrc.sh
        if [[ -d $prompt_root/.stack-work ]] then
            GIT_PROMPT_EXECUTABLE="haskell"
        else
            GIT_PROMPT_EXECUTABLE="python"
        fi

        ZSH_THEME_GIT_PROMPT_CACHE=
        ZSH_THEME_GIT_PROMPT_PREFIX=""
        ZSH_THEME_GIT_PROMPT_SUFFIX=" "
        ZSH_THEME_GIT_PROMPT_SEPARATOR=""
        ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
        ZSH_THEME_GIT_PROMPT_BRANCH="%{\e[38;5;13m%}"
        ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[red]%}%{⦁%G%}"
        ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{⋆%G%}"
        ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{+%G%}"
        ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[yellow]%}%{↓%G%}"
        ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[yellow]%}%{↑%G%}"
        ZSH_THEME_GIT_PROMPT_UNTRACKED="%{…%G%}"
        ZSH_THEME_GIT_PROMPT_CLEAN=""
    fi

    RPROMPT='%{$fg[blue]%}$(perlv)%{$fg[green]%}%m:%~ %T%{$reset_color%}'
elif [ 1 = 1 ]; then
    ZSH_GIT_PROMPT_FORCE_BLANK=1
    ZSH_THEME_GIT_PROMPT_PREFIX=""
    ZSH_THEME_GIT_PROMPT_SUFFIX=" "
    ZSH_THEME_GIT_PROMPT_SEPARATOR=" "
    ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_no_bold[cyan]%}:"
    ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_no_bold[grey]%}"
        ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
    ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_no_bold[cyan]%}↓"
        ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[yellow]%}%{↓%G%}"
    ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_no_bold[cyan]%}↑"
        ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[yellow]%}%{↑%G%}"
    ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}✖"
        ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}%{⋆%G%}"
    ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}●"
        ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[red]%}%{⦁%G%}"
    ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}✚"
        ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[blue]%}%{+%G%}"
    ZSH_THEME_GIT_PROMPT_UNTRACKED="…"
        ZSH_THEME_GIT_PROMPT_UNTRACKED="%{…%G%}"
    ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}⚑"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✔"

    ZSH_GIT_PROMPT_SHOW_STASH=1

    . ~/.zplug/repos/woefe/git-prompt.zsh/git-prompt.zsh

    if [ "$(whoami)" = "root" ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi
    PROMPT='$(gitprompt)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '

    perlv () { perl -e '$t = -e "Makefile"; $_ = $t ? `grep "FULLPERL = " Makefile` : `which perl`; s|.*/(.*)/bin/perl.*|$1 |; s/^usr $//; s/perl-// if $t; print' }
    RPROMPT='%{$fg[blue]%}$(perlv)%{$fg[green]%}%m:%~ %{$fg_bold[magenta]%}%T%{$reset_color%}'
else
    AGKOZAK_PROMPT_DIRTRIM=0
    AGKOZAK_MULTILINE=0
    AGKOZAK_PROMPT_CHAR=( ❯ ❯ ❮ )
    AGKOZAK_CUSTOM_SYMBOLS=( '⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' )
    if [[ $(uname) == "FreeBSD" ]]; then
        AGKOZAK_COLORS_USER_HOST=32
        AGKOZAK_COLORS_PATH=13
        AGKOZAK_COLORS_PROMPT_CHAR=13
        AGKOZAK_COLORS_BRANCH_STATUS=3
    else
        AGKOZAK_COLORS_USER_HOST=$s_blue
        AGKOZAK_COLORS_PATH=$s_violet
        AGKOZAK_COLORS_PROMPT_CHAR=$s_violet
        AGKOZAK_COLORS_BRANCH_STATUS=$s_yellow
    fi

    AGKOZAK_CUSTOM_RPROMPT='%(3V.%F{${AGKOZAK_COLORS_BRANCH_STATUS}}%3v%f.) '
    AGKOZAK_CUSTOM_RPROMPT+='%B%F{${AGKOZAK_COLORS_PATH}}%~%f%b '
    AGKOZAK_CUSTOM_RPROMPT+='%F{${AGKOZAK_COLORS_USER_HOST}}%*'

    AGKOZAK_CUSTOM_PROMPT='%(?..%B%F{${AGKOZAK_COLORS_EXIT_STATUS}}(%?%)%f%b )'
    AGKOZAK_CUSTOM_PROMPT+='%(!.%S%B.%B%F{${AGKOZAK_COLORS_USER_HOST}})%n%1v%(!.%b%s.%f%b)'
    AGKOZAK_CUSTOM_PROMPT+=' %B%F{${AGKOZAK_COLORS_PROMPT_CHAR}}%h%f%b'
    AGKOZAK_CUSTOM_PROMPT+='${AGKOZAK_PROMPT_WHITESPACE}${AGKOZAK_COLORS_PROMPT_CHAR:+%F{${AGKOZAK_COLORS_PROMPT_CHAR}\}}%(4V.${AGKOZAK_PROMPT_CHAR[3]:-:}.%(!.${AGKOZAK_PROMPT_CHAR[2]:-%#}.${AGKOZAK_PROMPT_CHAR[1]:-%#}))${AGKOZAK_COLORS_PROMPT_CHAR:+%f} '
fi

# Clear up after status display

echo -n "\r"
