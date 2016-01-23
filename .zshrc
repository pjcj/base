# Loading status
zshrc_load_status () {
    echo -n "\r.zshrc load: $* ... \e[0K"
}

zshrc_load_status "plug"

source ~/.zplug/zplug

zshrc_load_status "plugins"

zplug "pjcj/k"
# https://github.com/tj/git-extras/blob/master/Commands.md
zplug "tj/git-extras", do:"make install PREFIX=$HOME/g/sw"
zplug "zsh-users/zsh-completions"
# zplug "zsh-users/zsh-history-substring-search"
# zsh-syntax-highlighting must be loaded after executing compinit command and
# sourcing other plugins
zplug "zsh-users/zsh-syntax-highlighting", nice:10

if ! zplug check; then
    zplug install
fi

zplug load

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern root)
# To have paths coloured instead of underlined
ZSH_HIGHLIGHT_STYLES[path]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[root]="underline"

zshrc_load_status "setting options"

setopt                        \
       all_export             \
       always_last_prompt     \
    NO_always_to_end          \
       append_history         \
    NO_auto_cd                \
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

zshrc_load_status "ls colours"
if which dircolors >&/dev/null; then
    source =(dircolors -b ~/dircolours)
fi

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

# disable named-directories autocompletion
zstyle ":completion:*:cd:*" tag-order local-directories directory-stack \
                            path-directories

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
compdef _git   gb=git-branch
compdef _git   gc=git-commit
compdef _git   gd=git-diff
compdef _git   gvd=git-diff
compdef _git   gf=git-fetch
compdef _git   gg=git-grep
compdef _git   gl=git-log
compdef _git   gls=git-log
compdef _git   glsa=git-log
compdef _git   go=git-checkout
compdef _git   gs=git-status
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

zshrc_load_status "miscellaneous"

autoload -U url-quote-magic && zle -N self-insert url-quote-magic

REPORTTIME=15
# export TIMEFMT="  Timing report for %J
#   %E %P  %U user + %S system  %W swaps  %Mk mem
#   %X shared + %D unshared = %Kk  %F major + %R minor pf
#   %I+%O io  %r rx + %s tx messages  %w+%c waits"
TIMEFMT="  Timing report for %J
  %E %P  %U user + %S system  %W swaps  %Mk mem"

LS_OPTIONS=

zshrc_load_status "path"

PATH=~/.local/bin:~/g/go/bin:~/bin:~/g/sw/bin:~/g/sw/usr/bin:$PATH
PATH=~/g/local_base/utils:~/g/base/utils:$PATH
PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin

typeset -U path
typeset -U manpath
path=($^path(N))
manpath=($^manpath(N))

zshrc_load_status "aliases"

alias dm="fc -e - d=m -1"
alias h="fc -li"
alias hh="fc -li 1"
alias lu="fc -e - lsq=usq -1"
alias mkdir="nocorrect mkdir"
alias m=less
alias n=make
alias p="pp|head"
alias tf="tail -f"
alias u=popd

alias cp="cp -bv --backup=numbered"
alias mv="mv -bv --backup=numbered"

alias pl="ps -o user,pid,pgid,pcpu,pmem,osz,rss,tty,s,stime,time,args"
alias pp="pl -A | sort -k 4"

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

d() {
    if which k >&/dev/null; then
        k -h "$@"
    else
        f "$@"
    fi
}

v() {
    if test $# != 1 -o -r "$1"; then
        command $EDITOR "${@}"
    else
        local args
        args=(${(s.:.)1})
        [[ $#args == 2 && $args[2] == <-> ]] \
            && command $EDITOR "$args[1]" +$args[2] \
            || command $EDITOR "$args[1]"
    fi
}

cd()      { c "$@" && d }
ddl()     { ds /{dl,music}*/**/*(#i)"$@"*(N) }
dh()      { f --color "$@" | head }
ds()      { f -d "$@" }
f()       { ls -ABhl --color=tty -I \*.bak -I .\*.bak "$@" }
g()       { git "$@" }
gb()      { git branch "$@" }
gc()      { git commit -v "$@" }
gd()      { git diff "$@" }
gdw()     { git diffwords "$@" }
gf()      { git fetch "$@" }
gg()      { git grep -n "$@" }
ggv()     { git grep -O$EDITOR"$@" }
gl()      { git lg --all "$@" }
gls()     { git lg --simplify-by-decoration "$@" }
glsa()    { git lg --all --simplify-by-decoration "$@" }
go()      { git co "$@" }
gs()      { git st "$@" }
gw()      { git wtf -A "$@" }
golang()  { /usr/bin/go "$@" }
hg()      { fc -li 1 | grep "$@" }
ll()      { f --color "$@" | m -r -X }
mn()      { nroff -man "$@" | m }
mutt()    { DISPLAY= command mutt }
pm()      { pod2man "$@" | mn }
restart() { exec $SHELL "$@" }
rtunnel() { ssh -N -f -R 9999:localhost:22 "$@" }
s()       { gnome-open "$@" }
tg()      { tcgrep -brun "$@" }
tmux()    { command tmux -u2 "$@" }
tojpg()   { for f ("$@") { echo "$f"; j=`echo $f(:r)`; convert "$f" "$j.jpg" } }
t()       { TERM=xterm-color tig --all "$@" }
ud()      { u "$@"; d }
uu()      { uuencode "$@" "$@" | mailx -s "$@" paul@pjcj.net }
wh()      { . uwh "$@" }
z()       { dzil "$@" }
zb()      { perl Makefile.PL; make clean; perl Makefile.PL; dzil build "$@" }
zt()      { perl Makefile.PL; make clean; perl Makefile.PL; dzil test "$@" }

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
hash -d dc=~/g/perl/Devel--Cover
hash -d am=~/g/perl/AMeasure
hash -d base=~/g/base
hash -d local_base=~/g/local_base

zshrc_load_status "environment"

export GOPATH=~/g/go
export LANG=en_GB.UTF-8
export LESSOPEN="|lesspipe.sh %s"
export LESS=-RM
export NOPASTE_SERVICES="Gist Pastie Snitch Shadowcat"
export PAGER=less
export TERMINFO=~/.terminfo
export TOP="-I all"
export VISUAL=$EDITOR

[[ ! -d ~/g/tmp/vim ]] && mkdir -p ~/g/tmp/vim

if [[ -e ~/perl5/perlbrew/etc/bashrc ]] then
    . ~/perl5/perlbrew/etc/bashrc 2>/dev/null
    . ~/perl5/perlbrew/etc/perlbrew-completion.bash
    pb() { TEST_JOBS=9 perlbrew "$@" }
    complete -F _perlbrew_compgen pb
fi

zshrc_load_status "prompt"

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Copied from https://gist.github.com/joshdick/4415470
# Modify the colors and symbols in these variables as desired.
# GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
# GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_PREFIX=""
GIT_PROMPT_SUFFIX="%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head.
parse_git_branch() {
    (git symbolic-ref -q HEAD || \
        git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states.
parse_git_state() {
    # Compose this value via multiple conditional appends.
    local GIT_STATE=""
    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
    fi
    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
    fi
    local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
    fi
    if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
    fi
    if ! git diff --quiet 2> /dev/null; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
    fi
    if ! git diff --cached --quiet 2> /dev/null; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
    fi
    if [[ -n $GIT_STATE ]]; then
        echo "$GIT_STATE"
    fi
}

git_prompt_info() {
    local git_where="$(parse_git_branch)"
    [ -n "$git_where" ] && \
        echo "$GIT_PROMPT_PREFIX%{$fg[blue]%}${git_where#(refs/heads/|tags/)}$(parse_git_state)$GIT_PROMPT_SUFFIX "
}

if [ "$(whoami)" = "root" ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi

perlv () { perl -e '$t = -e "Makefile"; $_ = $t ? `grep "FULLPERL = " Makefile` : `which perl`; s|.*/(.*)/bin/perl.*|$1 |; s/^usr $//; s/perl-// if $t; print' }

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '
RPROMPT='%{$fg[blue]%}$(perlv)%{$fg[green]%}%m:%~ %T%{$reset_color%}'

zshrc_load_status "command-not-found"
# from command-not-found package
if [[ -r /etc/zsh_command_not_found ]]; then
    zshrc_load_status "/etc/zsh_command_not_found"
    . /etc/zsh_command_not_found
fi

zshrc_load_status "local environment"

if [[ -r ~/.zshrc.local ]]; then
    zshrc_load_status ".zshrc.local"
    . ~/.zshrc.local
fi

if [[ -r ~/.zshrc.${HOST%%.*} ]]; then
    zshrc_load_status ".zshrc.${HOST%%.*}"
    . ~/.zshrc.${HOST%%.*}
fi

# setopt NO_ksh_glob

zshrc_load_status "application specific setup"

for f in \
    ~/.fzf.zsh
do
    [ -f $f ] && source $f
done

# Clear up after status display

echo -n "\r"
