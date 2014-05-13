# Loading status

zshrc_load_status ()
{
    echo -n "\r.zshrc load: $* ... \e[0K"
}

# Options

zshrc_load_status 'setting options'

unsetopt bgnice

setopt \
        all_export \
        always_last_prompt \
     NO_always_to_end \
        append_history \
     NO_auto_cd \
        auto_list \
        auto_menu \
     NO_auto_name_dirs \
        auto_param_keys \
        auto_param_slash \
        auto_pushd \
        auto_remove_slash \
     NO_auto_resume \
        bad_pattern \
        bang_hist \
        beep \
        brace_ccl \
     NO_bsd_echo \
     NO_chase_links \
        cdable_vars \
     NO_clobber \
        complete_aliases \
        complete_in_word \
        correct \
     NO_correct_all \
        csh_junkie_history \
     NO_csh_junkie_loops \
     NO_csh_junkie_quotes \
     NO_csh_null_glob \
        equals \
        extended_glob \
        extended_history \
        function_argzero \
        glob \
     NO_glob_assign \
     NO_glob_complete \
        glob_dots \
        glob_subst \
        hash_cmds \
        hash_dirs \
        hash_list_all \
        hist_allow_clobber \
        hist_beep \
     NO_hist_expire_dups_first \
     NO_hist_ignore_all_dups \
     NO_hist_ignore_dups \
     NO_hist_no_functions \
        hist_reduce_blanks \
     NO_hist_save_no_dups \
        hist_ignore_space \
        hist_no_store \
        hist_verify \
     NO_hup \
     NO_ignore_braces \
     NO_ignore_eof \
        inc_append_history \
        interactive_comments \
     NO_ksh_glob \
     NO_list_ambiguous \
     NO_list_beep \
        list_packed \
     NO_list_types \
        long_list_jobs \
        magic_equal_subst \
        mail_warning \
     NO_mark_dirs \
     NO_menu_complete \
        multios \
        nomatch \
        notify \
     NO_null_glob \
        numeric_glob_sort \
     NO_overstrike \
        path_dirs \
        rematch_pcre \
        posix_builtins \
        print_exit_value \
     NO_prompt_cr \
        prompt_subst \
        pushd_ignore_dups \
     NO_pushd_minus \
     NO_pushd_silent \
        pushd_to_home \
        rc_expand_param \
     NO_rc_quotes \
     NO_rec_exact \
        rm_star_silent \
     NO_rm_star_wait \
     NO_sh_file_expansion \
        sh_option_letters \
     NO_sh_word_split \
        share_history \
        short_loops \
     NO_single_line_zle \
        sun_keyboard_hack \
        unset \
     NO_verbose \
     NO_xtrace \
        zle

# Environment

zshrc_load_status 'setting environment'

# Variables used by zsh

# Function path

fpath=(
    ~/{lib/zsh,.zsh,g/base/zsh}/{functions,scripts}(N)
    $fpath
)
typeset -U fpath

# Ignore these corrections

CORRECT_IGNORE='[._]*'

# Choose word delimiter characters in line editor

WORDCHARS=''

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

# ls colours

zshrc_load_status 'colours'
if which dircolors >&/dev/null; then
    source =(dircolors -b ~/dircolours)
fi

# Completions

zshrc_load_status 'completion system'

# New advanced completion system

autoload -U compinit
compinit -u
zmodload -i zsh/complist
autoload -U zargs

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
compdef _git   go=git-checkout
compdef _git   gs=git-status
compdef _git   gw=git-wtf
compdef _dzil  z=dzil

# ftp

zshrc_load_status 'ftp'
autoload -U zfinit
zfinit

# Aliases and functions

zshrc_load_status 'aliases and functions'

# Restarting zsh, reloading .zshrc or functions

restart () {
    exec $SHELL "$@"
}

reload () {
    if [[ "$#*" -eq 0 ]]; then
        . ~/.zshrc
    else
        local fn
        for fn in "$@"; do
            unfunction $fn
            autoload -U $fn
        done
    fi
}
compdef _functions reload

# Key bindings

zshrc_load_status 'key bindings'

bindkey -v -m 2> /dev/null

autoload -U history-search-end
zle -N history-beginning-search-backward-end \
     history-search-end
zle -N history-beginning-search-forward-end \
     history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
bindkey '^[OA' history-beginning-search-backward-end
bindkey '^[OB' history-beginning-search-forward-end

autoload -U history-beginning-search-menu-space-end \
       history-beginning-search-menu
zle -N history-beginning-search-menu-space-end \
       history-beginning-search-menu
bindkey '^X' history-beginning-search-menu-space-end

bindkey '^O' push-line-or-edit
bindkey '^P' accept-and-infer-next-history

# Miscellaneous

zshrc_load_status 'miscellaneous'

autoload -U url-quote-magic && zle -N self-insert url-quote-magic

REPORTTIME=15
# export TIMEFMT="  Timing report for %J
#   %E %P  %U user + %S system  %W swaps  %Mk mem
#   %X shared + %D unshared = %Kk  %F major + %R minor pf
#   %I+%O io  %r rx + %s tx messages  %w+%c waits"
TIMEFMT="  Timing report for %J
  %E %P  %U user + %S system  %W swaps  %Mk mem"

LS_OPTIONS=

zshrc_load_status 'path'

PATH=~/bin:~/g/local_base/utils:~/g/base/utils:~/g/sw/bin:$PATH:~/g/sw/powerline-daemon:~/g/base/powerline/scripts:~/.rvm/bin

path=($^path(N))
manpath=($^manpath(N))

zshrc_load_status 'aliases'

alias dm='fc -e - d=m -1'
alias ds="d -d"
alias h="fc -li"
alias hh="fc -li 1"
alias lu='fc -e - lsq=usq -1'
alias mkdir="nocorrect mkdir"
alias m=less
alias n=make
alias p="pp|head"
alias tf="tail -f"
alias u=popd
alias ur='fc -e - unrar\ x=rm\ -i unrar\ x'

alias cp="cp -bv --backup=numbered"
alias mv="mv -bv --backup=numbered"

alias pl="ps -o user,pid,pgid,pcpu,pmem,osz,rss,tty,s,stime,time,args"
alias pp="pl -A | sort -k 4"

unalias d
unalias ll
unalias pu

zshrc_load_status 'functions'

c()
{
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

cd()     { c "$@" && d }
d()      { ls -ABhl --color=tty -I \*.bak -I .\*.bak "$@" }
ddl()    { ds /{dl,music}*/**/*(#i)"$@"*(N) }
dh()     { d --color "$@" | head }
g()      { git "$@" }
gb()     { git branch "$@" }
gc()     { git commit -v "$@" }
gd()     { git diff "$@" }
gf()     { git fetch "$@" }
gg()     { git grep -n "$@" }
ggv()    { git grep -Ovim "$@" }
gl()     { git lg "$@" }
go()     { git co "$@" }
gs()     { git st "$@" }
gw()     { git wtf -A "$@" }
hg()     { fc -li 1 | grep "$@" }
ll()     { d --color "$@" | m -r -X }
mutt()   { DISPLAY= command mutt }
mn()     { nroff -man "$@" | m }
pm()     { pod2man "$@" | mn }
s()      { gnome-open "$@" }
t()      { TERM=xterm-color tig --all "$@" }
tg()     { tcgrep -brun "$@" }
tmux()   { command tmux -u2 "$@" }
tojpg()  { for f ("$@") { echo "$f"; j=`echo $f(:r)`; convert "$f" "$j.jpg" } }
ud()     { u "$@"; d }
uu()     { uuencode "$@" "$@" | mailx -s "$@" paul@pjcj.net }
v()
{
    if test $# != 1 -o -r "$1"; then
        command vim "${@}"
    else
        local args
        args=(${(s.:.)1})
        [[ $#args == 2 && $args[2] == <-> ]] \
            && command vim "$args[1]" +$args[2] \
            || command vim "$args[1]"
    fi
}
wh()     { . uwh "$@" }
z()      { dzil "$@" }
zb()     { perl Makefile.PL; make clean; perl Makefile.PL; dzil build "$@" }
zt()     { perl Makefile.PL; make clean; perl Makefile.PL; dzil test "$@" }

rtunnel() { ssh -N -f -R 9999:localhost:22 "$@" }

function tm() {
    [[ -z "$1" ]] && { echo "usage: tm <session>" >&2; return 1; }
    tmux has -t $1 && tmux attach -d -t $1 || tmux new -s $1
}
function __tmux-sessions() {
    local expl
    local -a sessions
    sessions=( ${${(f)"$(command tmux list-sessions)"}/:[ $'\t']##/:} )
    _describe -t sessions 'sessions' sessions "$@"
}
compdef __tmux-sessions tm

zshrc_load_status 'hashed directories'

hash -d dc=~/g/perl/Devel--Cover
hash -d am=~/g/perl/AMeasure
hash -d base=~/g/base

zshrc_load_status 'environment'

export EDITOR=vim
export LANG=en_GB.UTF-8
export LESSOPEN="|lesspipe.sh %s"
export LESS=-RM
export NOPASTE_SERVICES='Gist Pastie Snitch Shadowcat'
export PAGER=less
export TERMINFO=~/.terminfo
export TOP="-I all"
export VISUAL=$EDITOR

[[ ! -d ~/g/tmp/vim ]] && mkdir ~/g/tmp/vim

if [[ -e ~/perl5/perlbrew/etc/bashrc ]] then
    . ~/perl5/perlbrew/etc/bashrc
    . ~/perl5/perlbrew/etc/perlbrew-completion.bash
    pb() { TEST_JOBS=9 perlbrew "$@" }
    complete -F _perlbrew_compgen pb
fi

if [[ -e ~/.rvm/scripts/rvm ]] then
    . ~/.rvm/scripts/rvm
    . ~/.rvm/gems/ruby-1.9.3-*/gems/tmuxinator-*/completion/tmuxinator.zsh
fi

# Plugins
zshrc_load_status 'oh-my-zsh plugins'

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern root)
# To have paths coloured instead of underlined
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[root]='underline'

# Command not found ...
# from command-not-found package
if [[ -r /etc/zsh_command_not_found ]]; then
  zshrc_load_status '/etc/zsh_command_not_found'
  . /etc/zsh_command_not_found
fi

# Specific to hosts
zshrc_load_status 'local environment'

if [[ -r ~/.zshrc.local ]]; then
  zshrc_load_status '.zshrc.local'
  . ~/.zshrc.local
fi

if [[ -r ~/.zshrc.${HOST%%.*} ]]; then
  zshrc_load_status ".zshrc.${HOST%%.*}"
  . ~/.zshrc.${HOST%%.*}
fi

setopt NO_ksh_glob

# start powerline daemon
powerline-daemon >& /dev/null

# Clear up after status display

echo -n "\r"
