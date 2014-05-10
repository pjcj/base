if [ "$(whoami)" = "root" ]; then NCOLOUR="red"; else NCOLOUR="cyan"; fi

perlv () { perl -e '$t = -e "Makefile"; $_ = $t ? `grep "FULLPERL = " Makefile` : `which perl`; s|.*/(.*)/bin/perl.*|$1 |; s/^usr $//; s/perl-// if $t; print' }

PROMPT='$(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[$NCOLOUR]%}%h:%{$reset_color%} '
RPROMPT='%{$fg[blue]%}$(perlv)%{$fg[green]%}%m:%~ %T%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
