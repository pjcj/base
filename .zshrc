# Loading status
zshrc_load_status () {
    echo -n "\r.zshrc load: $* ... \e[0K"
}

load() {
    for f in $@; do
        if [[ -r $f ]]; then
            zshrc_load_status "$f"
            . $f
        fi
    done
}

load ~/.zshrc.init.local

zshrc_load_status "autoenv"

# zsh-autoenv
AUTOENV_FILE_ENTER=.autoenv.zsh
AUTOENV_FILE_LEAVE=.autoenv.zsh
AUTOENV_HANDLE_LEAVE=1
AUTOENV_LOOK_UPWARDS=1

zshrc_load_status "plugins"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing zinit…%f"
    command mkdir -p "$ZINIT_HOME" && command chmod g-rwX "$ZINIT_HOME"
    command git clone https://github.com/zdharma-continuum/zinit.git \
            "$ZINIT_HOME" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$ZINIT_HOME/zinit.zsh"

zshrc_load_status "load plugins"

zinit load "zsh-users/zsh-completions"
zinit load "Tarrasch/zsh-autoenv"
zinit load "woefe/git-prompt.zsh"
zinit load "woefe/vi-mode.zsh"
zinit load "joshskidmore/zsh-fzf-history-search"
zinit load "Aloxaf/fzf-tab"
zinit load 'zsh-users/zsh-autosuggestions'
zinit load "zdharma/fast-syntax-highlighting"

zshrc_load_status "options"

setopt                        \
    NO_all_export             \
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
       combining_chars        \
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
    NO_glob_subst             \
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

zshrc_load_status "environment"

if [ $EUID -ne 0 ]; then
    [ -e /home/linuxbrew/.linuxbrew/bin/brew ] && \
        eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    [ -e /usr/local/bin/brew ] && \
        eval $(/usr/local/bin/brew shellenv)
    [ -e /opt/homebrew/bin/brew ] && \
        eval $(/opt/homebrew/bin/brew shellenv)
    [ -e /opt/homebrew/bin/brew ] && \
        eval $(/opt/homebrew/bin/brew shellenv)
fi

fpath=(
    ~/{lib/zsh,.zsh,g/base/zsh}/{functions,scripts}(N)
    ~/g/go/src/github.com/motemen/ghq/zsh(N)
    $fpath
)
[[ -n $HOMEBREW_PREFIX ]] && fpath=(
    $HOMEBREW_PREFIX/share/zsh/site-functions
    $HOMEBREW_PREFIX/Cellar/zsh/5.9/share/zsh/functions
    $fpath
)

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

export MANPAGER="nvim +Man!"
export MANWIDTH=999

export HOMEBREW_NO_ANALYTICS=1

zshrc_load_status "path"

perldir=$(dirname $(readlink -f $(which perl)))
[[ $perldir == "/usr/bin" ]] || PATH="$perldir":$PATH
PATH=~/.local/bin:~/g/sw/bin:~/g/sw/usr/bin:$PATH
PATH=~/.cargo/bin:$NPM_PACKAGES/bin:$PATH
# PATH=~/.yarn/bin:~/.config/yarn/global/node_modules/.bin:$PATH
PATH=/snap/bin:$PATH
[[ -n $HOMEBREW_PREFIX ]] &&
  PATH=$HOMEBREW_PREFIX/bin:$PATH &&
  PATH=$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH &&
  PATH=$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH
PATH=~/g/local_base/utils:~/g/base/utils:$PATH
PATH=~/g/base/utils/${(L)$(uname)}:$PATH
PATH=/usr/local/bin:$PATH:~/g/go/bin:/usr/local/sbin:/usr/sbin:/sbin
PATH=~/bin:$PATH
MANPATH=/usr/share/man:${MANPATH:-manpath}
MANPATH=~/g/sw/share/man:$NPM_PACKAGES/share/man:$MANPATH

zshrc_load_status "compinit"

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit -u
else
    compinit -C;
fi;

zshrc_load_status "completion system"

zinit cdreplay
zmodload -i zsh/complist
autoload -U zargs

zstyle ":completion:*" menu select
zstyle ":completion:*" show-ambiguity true
zstyle ":completion:*" ambiguous true
zstyle ":completion:*" list-colors ""
zstyle ":completion:*" use-perl true
# add sort of fuzzy matching: case, and _ and - are interchangeable
zstyle ":completion:*" matcher-list "m:{a-zA-Z-_}={A-Za-z_-}" \
                                    "r:|[._-]=* r:|=*" "l:|=* r:|=*"

zstyle ":completion:*:*:kill:*:processes" list-colors \
           "=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01"
zstyle ":completion:*:*:*:*:processes" \
           command "ps -u $USER -o pid,user,comm -w -w"

zstyle ':completion::complete:*:*:targets' call-command true
zstyle ':completion:*:make:*' tag-order targets
zstyle ':completion:*:n:*' tag-order targets

zstyle ":completion::complete:*" use-cache 1

# Don't complete uninteresting users
# zstyle ":completion:*:*:*:users" ignored-patterns                             \
        # adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna     \
        # clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm        \
        # gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm    \
        # ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios    \
        # named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn    \
        # operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        # rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp   \
        # usbmux uucp vcsa wwwrun xfs "_*"
# ... unless we really want to.
# zstyle "*" single-ignored show

# Local completion

compdef wh=which
compdef n=make
compdef z=dzil
compdef _gh  ghub
compdef _git ga=git-add
compdef _git gb=git-branch
compdef _git gbl=git-blame
compdef _git gcae=git-commit
compdef _git gca=git-commit
compdef _git gc=git-commit
compdef _git gcp=git-cherry-pick
compdef _git gd=git-diff
compdef _git gds=git-diff
compdef _git gf=git-fetch
compdef _git gg=git-grep
compdef _git g=git
compdef _git gh=git-checkout
compdef _git gho=git-origin-branch-move
compdef _git gld=git-log
compdef _git gl=git-log
compdef _git gll=git-log
compdef _git glsa=git-log
compdef _git gls=git-log
compdef _git gm=git-merge
compdef _git gpf=git-push
compdef _git gp=git-push
compdef _git gpof=git-push
compdef _git gpo=git-push
compdef _git gra=git-rebase
compdef _git grc=git-rebase
compdef _git gr=git-rebase
compdef _git grh=git-reset
compdef _git gri=git-rebase
compdef _git grs=git-restore
compdef _git gs=git-status
compdef _git gsh=git-show
compdef _git gvd=git-diff
compdef _git gw=git-worktree

_git-branch-full-delete() { __git_branch_names }
zstyle ":completion:*:*:git:*" user-commands \
    branch-full-delete:"delete local and remote branches"

_git-origin-branch-move() { __git_branch_names }
zstyle ":completion:*:*:git:*" user-commands \
    origin-branch-move:"move branch to its origin"

_git-fpush() { __git_branch_names }
zstyle ":completion:*:*:git:*" user-commands \
    fpush:"force push even when the remote forbids it"

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colours
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
disable-fzf-tab

zshrc_load_status "ftp"
autoload -U zfinit
zfinit

zshrc_load_status "key bindings"

bindkey -v -m 2> /dev/null

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
# bindkey "^[[A" history-beginning-search-backward-end
# bindkey "^[[B" history-beginning-search-forward-end
# bindkey "^[OA" history-beginning-search-backward-end
# bindkey "^[OB" history-beginning-search-forward-end
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^[OA" history-beginning-search-backward
bindkey "^[OB" history-beginning-search-forward

autoload -U history-beginning-search-menu-space-end \
       history-beginning-search-menu
zle -N history-beginning-search-menu-space-end \
       history-beginning-search-menu
bindkey "^E" history-beginning-search-menu-space-end

bindkey "^O" push-line-or-edit
bindkey "^P" accept-and-infer-next-history

bindkey -r "^K"
bindkey "^Ku" undo

bindkey "^[[5~" vi-end-of-line
bindkey "^[[6~" vi-forward-blank-word-end
bindkey "^Y" vi-forward-word

autoload edit-command-line;
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# bindkey -s "§" "lC"
bindkey -s "^[[15~" "["   #f5
bindkey -s "^[[17~" "]"   #f6
bindkey -s "^[[18~" "{"   #f7
bindkey -s "^[[19~" "}"   #f8
bindkey -s "^[[20~" "~"   #f9
bindkey -s "^[[21~" "|"   #f10
bindkey -s "^[[23~" "\`"  #f11

bindkey "^[OP" fzf_git_commit_widget_k       # f1
bindkey "^[[25~" fzf_git_commit_widget_lall  # shift-f1
bindkey "^[OQ" fzf_git_commit_widget_l       # f2
bindkey -s "^[OR" "^[0Digs^M"                # f3
bindkey -s "^[OS" "^[0Digd^M"                # f4

zshrc_load_status "miscellaneous"

# url-quote-magic breaks fast-syntax-highlighting
# autoload -U url-quote-magic && zle -N self-insert url-quote-magic

export REPORTTIME=5  # 3 seconds
export TIMEFMT="  %J  %E %P  %U user + %S system  %W swaps  %Mk mem"

export LS_OPTIONS=

export NPM_PACKAGES=~/g/sw/.npm-packages

zshrc_load_status "aliases"

alias mkdir "nocorrect mkdir"

zshrc_load_status "functions"

if which nvim >&/dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

c() {
    if [[ $1 == "--" ]]; then
        shift
    fi

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
        mkdir -p $VIMTMP
        TMPDIR=$VIMTMP \
            OPENAI_API_KEY=$openai_api_key \
            CLAUDE_API_KEY=$claude_api_key \
            command $EDITOR "$@"
    else
        command $EDITOR -u NONE "$@"
    fi
}
vs() { v -S /tmp/tmp_session.vim "$@" }

vv() {
    if [ "$EDITOR" = "nvim" ]; then
        mkdir -p $VIMTMP
        TMPDIR=$VIMTMP command $EDITOR "$@"
    else
        command $EDITOR -u NONE "$@"
    fi
}
vvs() { vv -S /tmp/tmp_session.vim "$@" }

cd()      { c "$@" && d }
ddl()     { ds /{dl,music}*/**/*(#i)"$@"*(N) }
dh()      { f "$@" | head }
dht()     { dh -rs created "$@" }
dm()      { fc -e - d=m -1 }
dt()      { d -T "$@" }
fd()      { command fd -H "$@" }
g()       { git "$@" }
ga()      { git add "$@" }
gb()      { git branch "$@" }
gbl()     { git blame -wMC "$@" }
gc()      { git commit "$@" }
gca()     { git commit --amend "$@" }
gcae()    { git commit --amend --no-edit "$@" }
gcp()     { git cherry-pick "$@" }
gd()      { git diff "$@" }
gds()     { git diff --stat "$@" }
gdw()     { git diffwords "$@" }
gf()      { git fetch --prune --prune-tags "$@" }
gg()      { git grep -n "$@" }
ggv()     { git grep -O$EDITOR "$@" }
gh()      { git co "$@" }
gho()     { git omvo "${1-$(git branch-current)}" }
ghub()    { command gh "$@" }
gl()      { gll --all }
glab()    { PAGER=bat command glab "$@" }
gll()     { $(git-commit-sel "$@"); true }
gld()     { gll --all --date=iso "$@" }
gls()     { gll --simplify-by-decoration "$@" }
glsa()    { gll --all --simplify-by-decoration "$@" }
gm()      { git merge --no-commit "$@" && gc }
gp()      { git push "$@" }
gpu()     { git push --set-upstream origin $(git branch --show-current) }
gpf()     { git push --force-with-lease "$@" }
gpo()     { git push origin "$@" }
gpof()    { git push origin --force-with-lease "$@" }
gr()      { git rebase "$@" }
gra()     { git rebase --abort "$@" }
grc()     { git rebase --continue "$@" }
grh()     { git reset HEAD "$@" }
grs()     { git restore --staged "$@" }
gri()     { git rebase -i "$@" }
gs()      { git st "$@" }
gsh()     { git show --remerge-diff "$@" }
gw()      { git worktree "$@" }
gwa()     { git worktree add "$(git rev-parse --git-common-dir)/../../$@" }
gwm()     { cd "$@" }
h()       { fc -li "$@" }
hg()      { fc -li 1 | grep "$@" }
hh()      { fc -li 1 }
ht()      { sudo =htop "$@" }
kitty()   { ~/.local/kitty.app/bin/kitty "$@" }
ll()      { f "$@" | less -r -X }
lll()     { eval $(perl -Mlocal::lib=$(pwd)/local_lib) }
lu()      { fc -e - lsq=usq -1 }
m()       { bat --tabs=2 "$@" }
mn()      { nroff -man "$@" | m }
mutt()    { mkdir -p /tmp/ml && command mutt "$@" }
pm()      { pod2man "$@" | mn }
restart() { exec $SHELL "$@" }
rssh()    { ssh -p 9999 "$@" localhost }
rtunnel() { ssh -N -f -R 9999:localhost:22 "$@" }
rr()      { ranger "$@" }
tg()      { tcgrep -brun "$@" }
tojpg()   { for f ("$@") { echo "$f"; j=`echo $f(:r)`; convert "$f" "$j.jpg" } }
t()       { TERM=xterm-color tig --all "$@" }
tf()      { tail -f "$@" }
ud()      { u "$@"; d }
uu()      { uuencode "$@" "$@" | mailx -s "$@" paul@pjcj.net }
z()       { dzil "$@" }
zb()      { perl Makefile.PL; make clean; perl Makefile.PL; dzil build "$@" }
zt()      { perl Makefile.PL; make clean; perl Makefile.PL; dzil test "$@" }
= ()      { echo "$@" | bc -l }

glk() {
    if [[ -n $FZF_GIT_K ]]; then
        gl $FZF_GIT_K "$@"
    else
        gl "$@"
    fi
}

n() {
    mk=make
    which gmake >/dev/null && mk=gmake
    $mk "$@"
}

bui() {
    for p in "$@"; do
        pkg=$(echo "$p" | sed 's/,$//')
        echo "reinstalling $pkg"
        brew uninstall --ignore-dependencies "$pkg" && brew install "$pkg"
    done
}

setup_plenv() {
    brew install plenv
    brew install perl-build
}

wh() {
    echo PATH is $PATH
    echo
    command whence -cm "$@"
    echo
    command whence -afpSvm "$@"
}

tm() {
    if [[ -z "$1" || -u "$TMUX" ]]; then
        tmux
    else
        tmux has -t $1 && tmux attach -d -t $1 || tmux new -s $1
    fi
}
__tmux-sessions() {
    local expl
    local -a sessions
    sessions=( ${${(f)"$(command tmux list-sessions)"}/:[ $'\t']##/:} )
    _describe -t sessions "sessions" sessions "$@"
}
compdef __tmux-sessions tm

sshtm() {
    local server=${1?}
    ssh -t "$server" zsh -i -c "tm base"
}
compdef sshtm=ssh

__gwm() {
    local -a records=( ${(ps.\n\n.)"$(_call_program directories git worktree list --porcelain)"} )
    local -a directories descriptions
    local i hash branch
    for i in $records; do
        directories+=( ${${i%%$'\n'*}#worktree } )
        hash=${${${"${(f)i}"[2]}#HEAD }[1,9]}
        branch=${${"${(f)i}"[3]}#branch refs/heads/}

    # Simulate the non-porcelain output
    if [[ $branch == detached ]]; then
        # TODO: show a ref that points at $hash here, like vcs_info does?
        branch="(detached HEAD)"
    else
        branch="[$branch]"
    fi

    descriptions+=( "${directories[-1]}"$'\t'"$hash $branch" )
done
_wanted directories expl 'working tree' compadd -ld descriptions -S ' ' -f -M 'r:|/=* r:|=*' -a directories

}
compdef __gwm gwm

zshrc_load_status "hashed directories"

hash -d g=~/g
hash -d sw=~/g/sw
hash -d dc=~/g/perl/Devel--Cover
hash -d am=~/g/perl/AMeasure
hash -d base=~/g/base
hash -d local_base=~/g/local_base

zshrc_load_status "environment"

export BAT_THEME="Solarized (dark)"
export GOPATH=~/g/go
export LESS='--LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS --mouse'
export NOPASTE_SERVICES="Gist Pastie Snitch Shadowcat"
export PAGER="less -N"
export TEMPLATE_DIR=~base/templates
export TERMINFO=~/.terminfo
export TMOUT=0
export TOP="-I all"
export VIMTMP=/tmp/vim
export VISUAL=$EDITOR

: "${LANG:=en_GB.UTF-8}"
LANGUAGE="$LANG"
LC_ALL="$LANG"
export LANGUAGE LANG LC_ALL


export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#056e75"
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
    forward-char
    end-of-line
    vi-end-of-line
    vi-add-eol
)
export ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(vi-forward-blank-word-end)
export ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
    forward-word
    emacs-forward-word
    vi-forward-word
    vi-forward-word-end
    vi-forward-blank-word
    vi-find-next-char
    vi-find-next-char-skip
    vi-forward-char
)

export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[0;37;102m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;32m'
export _NROFF_U=1

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
    s()  { open "$@" }
    fd() { command fd -H --exclude '/Volumes/' "$@" }
    pll() {
        ps -o user,pid,ppid,%cpu,%mem,vsz,rss,tty,state,start,cputime,command \
            "$@"
    }
    pl() { pll -eww "$@" | m }
    pp() { pl -rc "$@" | m }
elif [[ $(uname) == FreeBSD ]]; then
    cp() { command cp -v "$@" }
    f()  { ls -ABGhl "$@" }
    ds() { f -d "$@" }
    mv() { command mv -v "$@" }
    s()  { f "$@" }
    pll() {
        ps -o user,pid,ppid,%cpu,%mem,vsz,rss,tty,state,start,cputime,command \
            "$@"
    }
    pl() { pll -eww "$@" | m }
    pp() { pl -rc "$@" | m }
    export LESS='--LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
else
    if which dmidecode >&/dev/null; then
        (sudo dmidecode -t system | grep -Eq 'VirtualBox|VMware') && ISVM=1
    fi
    cp() { command cp -bv --backup=numbered "$@" }
    f()  { ls -ABhl --color=tty -I \*.bak -I .\*.bak "$@" }
    ds() { f -d "$@" }
    mv() { command mv -bv --backup=numbered "$@" }
    pll() { ps -o user,pid,ppid,pcpu,pmem,vsz,rss,tty,stat,stime,time,args "$@"}
    pl() { pll -eww --forest "$@" | m }
    pp() { pll -e --sort=-pcpu "$@" | m }
    if [[ -n $WSL_DISTRO_NAME ]]; then
        s()  { wslview "$@" }
    elif which xdg-open >&/dev/null; then
        s() { xdg-open "$@" }
    elif which gnome-open >&/dev/null; then
        s() { gnome-open "$@" }
    else
        s() { echo Cannot find open command; echo "$@" }
    fi
fi

[[ $ISVM == 1 ]] && ulimit -n 4096

if which eza >&/dev/null; then
    f() {
        eza -lagH \
            --colour-scale=all --colour-scale-mode=gradient --colour=always \
            --git --time-style=long-iso --icons \
            "$@"
    }
    export EZA_COLORS="xx=00;38;5;244"
    export EZA_ICON_SPACING=2
    export EZA_MIN_LUMINANCE=55
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

export s_rgreen="#25ad2e"   # a nice green for diffs (opposite of s:red)
export s_darkred="#2b0200"  # a dark red

for c in s_base03 s_base02 s_base01 s_base00 s_base0 s_base1 s_base2 s_base3 \
    s_yellow s_orange s_red s_magenta s_violet s_blue s_cyan s_green s_normal \
    s_rgreen s_darkred; do
    export ef$c="$(print -rP "%F{${(P)c}}")"  # foreground terminal esc sequence
    export eb$c="$(print -rP "%K{${(P)c}}")"  # background terminal esc sequence
done

if command -v gdircolors >/dev/null; then
    eval "$(gdircolors -b ~/g/base/dircolours)"
elif command -v dircolors >/dev/null; then
    eval "$(dircolors -b ~/g/base/dircolours)"
else
    echo "Cannot find dircolors"
fi

zshrc_load_status "external files"

load \
    /etc/zsh_command_not_found                               \
    ~/g/sw/etc/zsh/*(N)                                      \
    $HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh          \
    $HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh            \
    /usr/local/share/examples/fzf/shell/key-bindings.zsh     \
    /usr/local/share/examples/fzf/shell/completion.zsh       \
    ~/g/base/zsh/.wezterm.completion.zsh                     \
    /Applications/WezTerm.app/Contents/Resources/wezterm.sh  \
    ~/.iterm2_shell_integration.zsh                          \
    ~/Library/Preferences/org.dystroy.broot/launcher/bash/br \
    ~/.acme.sh/acme.sh.env                                   \
    ~/.zshrc.local                                           \
    ~/.zshrc.${HOST%%.*}

zshrc_load_status "perl"

[[ -z $PERLBREW_ROOT ]] && export PERLBREW_ROOT="$HOME/perl5/perlbrew"
if [[ -e $PERLBREW_ROOT/etc/bashrc ]] then
    __path=$PATH
    __manpath=$MANPATH
    . $PERLBREW_ROOT/etc/bashrc 2>/dev/null
    . $PERLBREW_ROOT/etc/perlbrew-completion.bash
    PATH=$PERLBREW_PATH:$__path
    MANPATH=${MANPATH:-manpath}:$__manpath
    pb() { TEST_JOBS=9 perlbrew -j9 "$@" }
    complete -F _perlbrew_compgen pb
fi

if [[ -e ~/.plenv ]] then
    export PATH=~/.plenv/bin:$PATH
    eval "$(plenv init - zsh)"
fi

zshrc_load_status "nvm"
if [[ -d $(brew --prefix nvm) ]] then
    export NVM_DIR=~/.config/nvm
    mkdir -p $NVM_DIR
    load $(brew --prefix nvm)/nvm.sh
fi

# if [[ $(uname -s) = Darwin ]]; then
#     PATH="/usr/local/opt/node@14/bin:$PATH:~/Library/Python/3.9/bin"
#     LDFLAGS="-L/usr/local/opt/node@14/lib"
#     CPPFLAGS="-I/usr/local/opt/node@14/include"
# fi

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
    tree="lsd -A --tree --color=always --icon=always"

else
    tree="tree -C"
fi
tree() { eval $tree "$@" }

head="2>/dev/null | head -250"

export FZF_TMUX=1
export FZF_TMUX_HEIGHT=90%
export FZF_WIDTH=70
export FZF_DEFAULT_OPTS="
    --height 80% --reverse --inline-info
    --preview-window=right:${FZF_WIDTH}%
    --color fg:-1,bg:-1,hl:$s_blue,fg+:$s_normal,bg+:$s_darkred,hl+:$s_blue,gutter:$s_base02
    --color info:$s_cyan,prompt:$s_violet,pointer:$s_green,marker:$s_base3,spinner:$s_yellow
    --bind 'f1:abort'
    --bind 'f2:toggle-preview'
"
export FZF_DEFAULT_COMMAND="fd --hidden --no-ignore-vcs --exclude .git"
export FZF_CTRL_T_OPTS="--preview '(bat --tabs=2 --color=always {} 2>/dev/null || cat {} || $tree {}) $head'"
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

_fzfgv() {
    local pc=${1:-$FZF_WIDTH}
    local gsh="git -c core.pager=cat show --remerge-diff --color=never %"
    local disp="$gsh | delta --width=$(expr $(tput cols) \* $pc / 100)"
    echo "xargs -I % sh -c '$disp'"
}

fzfgv() {
    echo "$(_fzfgv $1)"
}

fzfgvsha() {
    local get_sha="grep -o '[a-f0-9]\+' | head -1"
    echo "$get_sha | $(_fzfgv $1)"
}

git-commit-sel() {
    setopt localoptions pipefail 2> /dev/null
    local get_sha="grep -o '[a-f0-9]\+' | head -1 | tr -d '\n'"
    local cmd="echo {} | $(fzfgvsha)"
    g ll --color=always "$@" | \
        $(__fzfcmd) --ansi --tiebreak=index \
            --header="f1 exit, f2 toggle, f3 diff, f4 sha" \
            --bind 'f3:preview:echo {} | grep -o "'"[a-f0-9]\\+"'" | head -1 | xargs -I % sh -c "'"git -c delta.side-by-side=false show --remerge-diff --color=always %"'"' \
            --bind "f4:execute:echo {} | $get_sha | osc52" \
            --preview="$cmd" | \
        while read item; do
            echo -n "${item}" | eval "$get_sha"
        done
    return $?
}

fzf_git_commit_widget() {
    LBUFFER="${LBUFFER}$(git-commit-sel --all)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle -N fzf_git_commit_widget

# _fzf_git() { git-commit-sel "$@" | echo -n "" }
_fzf_git() { git-commit-sel "$@" | osc52 }
fzf_git_commit_widget_k() {
    IFS=" " read -A b <<< ${FZF_GIT_K:---all}
    _fzf_git "${b[@]}"
}
zle -N fzf_git_commit_widget_k

fzf_git_commit_widget_lall() { _fzf_git --all }
zle -N fzf_git_commit_widget_lall

fzf_git_commit_widget_l() { _fzf_git }
zle -N fzf_git_commit_widget_l

git-tag-sel() {
    setopt localoptions pipefail 2> /dev/null
    local cmd="echo {} | $(fzfgv)"
    g tag | $(__fzfcmd) --tiebreak=index --preview="$cmd" "$@" | \
        while read item; do
            echo -n "${item}"
        done
    return $?
}

fzf_git_tag_widget() {
    LBUFFER="${LBUFFER}$(git-tag-sel)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle -N fzf_git_tag_widget

git-branch-sel() {
    setopt localoptions pipefail 2> /dev/null
    local get_full_branch="perl -pe 's/..([^ ]+) .*/\$1/'"
    local get_branch="perl -pe 's/.*?([-.\w]+) .*/\$1/'"
    local cmd="echo {} | $get_full_branch | $(fzfgv)"
    local opts="-vv --sort=-committerdate --color=always"
    (eval "gb $opts; gb -r $opts") | \
        $(__fzfcmd) --ansi --tiebreak=index --preview="$cmd" "$@" | \
        while read item; do
            echo -n "${item}" | eval "$get_branch"
        done
    return $?
}

fzf_git_branch_widget() {
    LBUFFER="${LBUFFER}$(git-branch-sel)"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
}
zle -N fzf_git_branch_widget

bindkey '^F' fzf_file_widget
bindkey '^N' fzf-cd-widget
bindkey '^G' fzf_git_commit_widget
bindkey '^B' fzf_git_branch_widget
bindkey '^T' fzf_git_tag_widget

bindkey '^R' fzf_history_search

bindkey '^Y' toggle-fzf-tab

zshrc_load_status "aws"

if which assume >/dev/null; then
    [[ -d ~/.granted ]] && fpath=(~/.granted/zsh_autocomplete/*/ $fpath)
    alias assume="source assume"
    export GRANTED_ENABLE_AUTO_REASSUME=true
fi

zshrc_load_status "paths"

typeset -U path          # unique
typeset -U manpath
typeset -U fpath
path=($^path(N))         # glob to remove non-existent dirs
manpath=($^manpath(N))
fpath=($^fpath(N))

# from command-not-found package

zshrc_load_status "prompt"

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

if [ 1 = 0 ]; then
    if [ $EUID -eq 0 ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi

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
    export ZSH_GIT_PROMPT_FORCE_BLANK=1
    export ZSH_THEME_GIT_PROMPT_PREFIX=""
    export ZSH_THEME_GIT_PROMPT_SUFFIX=" "
    export ZSH_THEME_GIT_PROMPT_SEPARATOR=" "
    export ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_no_bold[cyan]%}:"
    export ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
    export ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[yellow]%}%{↓%G%}"
    export ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[yellow]%}%{↑%G%}"
    export ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}%{⋆%G%}"
    export ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[red]%}%{⦁%G%}"
    export ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[blue]%}%{+%G%}"
    export ZSH_THEME_GIT_PROMPT_UNTRACKED="%{…%G%}"
    export ZSH_THEME_GIT_PROMPT_STASHED="%{$efs_base01%}⚑"
    export ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✔"

    export ZSH_GIT_PROMPT_SHOW_STASH=1
    export ZSH_GIT_PROMPT_SHOW_UPSTREAM=

    . ~/.local/share/zinit/plugins/woefe---git-prompt.zsh/git-prompt.zsh

    if [ $EUID -eq 0 ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi
    local char="─"
    grep -Eq '(18|20)\.04' /etc/os-release 2>|/dev/null && char="-"
    line() { printf "%.s$char" {1..$(tput cols)} }
    PROMPT=$'$(line)$(gitprompt)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '

    perl_here() {
        if [[ -d perl || -d t || -e Makefile.PL ]]; then
            echo 1
        else
            echo 0
        fi
    }
    perlv () {
        if [[ ${PROMPT_SHOW_PERL:-$(perl_here)} == 1 ]]; then
            if which plenv >&/dev/null; then
                local perl=$(plenv version-name)
                if [[ $perl == system ]]; then
                    perl -e 'print "$^V "'
                else
                    echo "$perl "
                fi
                return
            fi
            perl -e '
                $t = -e "Makefile";
                $_ = $t ? `grep "FULLPERL = " Makefile` : `which perl`;
                s|.*/(.*)/bin/perl.*|$1 |;
                s/^usr $//;
                s/perl-// if $t;
                print
            '
        fi
    }
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

# ensure autoenv.zsh is called
{ c ~ && c - } >/dev/null

zshrc_load_status "keychain"

# Clear up after status display
echo "\rzsh loaded                                                        "

# Handle startup
if [[ $(uname) == Darwin ]]; then
    ulimit -n 65536
    ulimit -s 32768
    ssh-add --apple-load-keychain
elif [[ $(uname) == FreeBSD ]]; then
    :
else
    eval $(keychain --eval id_ed25519 id_rsa)
    if [[ -n $WSL_DISTRO_NAME ]]; then
        if ps aux | grep tailscaled | grep -v grep >/dev/null; then
            echo tailscaled running
        else
            sudo tailscaled > /dev/null 2>&1 &
            disown
            sleep 5
            sudo tailscale up --ssh
            echo tailscaled started
        fi
    fi
fi
