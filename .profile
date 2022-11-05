# shellcheck shell=sh
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        # shellcheck disable=1091
        . "$HOME/.bashrc"
    fi
fi

PATH="$HOME/g/base/utils:$HOME/g/sw/bin:$PATH"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ "$(uname)" = "Linux" ]; then
    xrdb -merge ~/.Xdefaults
fi

export FONTSIZE=12

# shellcheck disable=1091
[ -r "$HOME/.profile.local" ] && . "$HOME/.profile.local"

: "${LANG:=en_GB.UTF-8}"
LANGUAGE="$LANG"
LC_ALL="$LANG"
export LANGUAGE LANG LC_ALL

[ -e /home/linuxbrew/.linuxbrew/bin/brew ] && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -e /usr/local/bin/brew ] && \
    eval "$(/usr/local/bin/brew shellenv)"
