# Loading status
zshrc_load_status () {
    echo -n "\r.zshrc load: $* ... \e[0K"
}

zshrc_load_status "plugins"

source ~/.zplug/zplug

zplug "oknowton/zsh-dwim"                                                   # ^U
zplug "supercrabtree/k"
# https://github.com/tj/git-extras/blob/master/Commands.md
zplug "tj/git-extras", do:"make install PREFIX=$HOME/g/sw"
# zplug "plugins/git-extras", from:oh-my-zsh
zplug "zsh-users/zsh-completions"
# zsh-syntax-highlighting must be loaded after executing compinit command and
# sourcing other plugins
zplug "zsh-users/zsh-syntax-highlighting",      nice:10
# zplug "zsh-users/zsh-history-substring-search", nice:11

if ! zplug check; then zplug install; fi
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
compdef _git   gca=git-commit
compdef _git   gd=git-diff
compdef _git   gvd=git-diff
compdef _git   gf=git-fetch
compdef _git   gg=git-grep
compdef _git   gl=git-log
compdef _git   gls=git-log
compdef _git   glsa=git-log
compdef _git   go=git-checkout
compdef _git   gp=git-push
compdef _git   gpo=git-push
compdef _git   gr=git-rebase
compdef _git   gra=git-rebase
compdef _git   grc=git-rebase
compdef _git   gri=git-rebase
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
MANPATH=~/g/sw/share/man:$MANPATH

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
gca()     { git commit --amend -v "$@" }
gd()      { git diff "$@" }
gdw()     { git diffwords "$@" }
gf()      { git fetch --prune "$@" }
gg()      { git grep -n "$@" }
ggv()     { git grep -O$EDITOR "$@" }
gl()      { git lg --all "$@" }
gls()     { git lg --simplify-by-decoration "$@" }
glsa()    { git lg --all --simplify-by-decoration "$@" }
go()      { git co "$@" }
gp()      { git push "$@" }
gpo()     { git push origin "$@" }
gr()      { git rebase --preserve-merges "$@" }
gra()     { git rebase --abort "$@" }
grc()     { git rebase --continue "$@" }
gri()     { git rebase --preserve-merges -i "$@" }
gs()      { git st "$@" }
gw()      { git wtf -A "$@" }
golang()  { command go "$@" }
hg()      { fc -li 1 | grep "$@" }
ll()      { f --color "$@" | m -r -X }
mn()      { nroff -man "$@" | m }
mutt()    { command mutt }
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
= ()       { echo "$@" | bc -l }

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

export GOPATH=~/g/go
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
export LESSOPEN="|lesspipe.sh %s"
export LESS='--no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export NOPASTE_SERVICES="Gist Pastie Snitch Shadowcat"
export PAGER=less
export TERMINFO=~/.terminfo
export TOP="-I all"
export VISUAL=$EDITOR

[[ ! -d ~/g/tmp/vim ]] && mkdir -p ~/g/tmp/vim

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
    /etc/zsh_command_not_found \
    ~/.gvm/scripts/gvm         \
    ~/.zshrc.local             \
    ~/.zshrc.${HOST%%.*}

[[ -z $PERLBREW_ROOT ]] && export PERLBREW_ROOT="$HOME/perl5/perlbrew"
if [[ -e $PERLBREW_ROOT/etc/bashrc ]] then
    . $PERLBREW_ROOT/etc/bashrc 2>/dev/null
    . $PERLBREW_ROOT/etc/perlbrew-completion.bash
    PATH=$PERLBREW_ROOT/bin:$PATH
    pb() { TEST_JOBS=9 perlbrew -j9 "$@" }
    complete -F _perlbrew_compgen pb
fi

typeset -U path
typeset -U manpath
path=($^path(N))
manpath=($^manpath(N))

# from command-not-found package

zshrc_load_status "prompt"

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

if [ "$(whoami)" = "root" ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi

perlv () { perl -e '$t = -e "Makefile"; $_ = $t ? `grep "FULLPERL = " Makefile` : `which perl`; s|.*/(.*)/bin/perl.*|$1 |; s/^usr $//; s/perl-// if $t; print' }


prompt_root=$(ghq list -p zsh-git-prompt)
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

PROMPT='$(git_super_status)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '
RPROMPT='%{$fg[blue]%}$(perlv)%{$fg[green]%}%m:%~ %T%{$reset_color%}'

# Clear up after status display

echo -n "\r"
