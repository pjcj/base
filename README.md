# My Base System

This is the base system that I put onto any machine on which I am developing.
It includes config files for:

* [bspwm](https://github.com/baskerville/bspwm) (tiling window manager)
* [sxhkd](https://github.com/baskerville/sxhkd) (X hotkey daemon)
* Xdefaults, including [st](http://st.suckless.org/) and
  [urxvt](http://software.schmorp.de/pkg/rxvt-unicode.html) (terminal emulators)
* [tmux](https://tmux.github.io/) (terminal multiplexer)
* [zsh](http://www.zsh.org/) (shell)
* [vim](http://www.vim.org/) or [neovim](https://github.com/neovim/neovim)
  (editors)
* [powerline](https://github.com/powerline/powerline) (status line for tmux)
* [git](http://www.git-scm.com/) (version control)

Colours are Solarized Dark slightly altered to make the dark background colours
a little darker.

Cutting edge software (newer than that packaged) is managed with
[ghq](https://github.com/motemen/ghq) and includes the following repositories:

* [st](http://git.suckless.org/st/)
* [urxvt (with true colour support)](https://github.com/spudowiar/rxvt-unicode)
* [zsh](git://zsh.git.sf.net/gitroot/zsh/zsh)
* [zsh-git-prompt](https://github.com/olivierverdier/zsh-git-prompt) (prompt for
  zsh including git status)
* [neovim](https://github.com/neovim/neovim)
* [tmux](https://github.com/tmux/tmux)
* [bspwm](https://github.com/baskerville/bspwm)
* [sxhkd](https://github.com/baskerville/sxhkd)
* [xdotool](https://github.com/jordansissel/xdotool) (automate X input)
* [urlview](https://github.com/sigpipe/urlview) (extract URLs from text)

The zsh config uses [zplug](https://github.com/b4b4r07/zplug) and the following
plugins:

* [zsh-completions](https://github.com/zsh-users/zsh-completions) (extra
  completions)
* [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  (hightlighting on the command line)
* [zsh-dwim](https://github.com/oknowton/zsh-dwim) (predict next command with ^U)
* [git-extras](https://github.com/tj/git-extras) (additional git commands)
* [k](https://github.com/supercrabtree/k) (ls extended)

The vim config uses [vim-plug](https://github.com/junegunn/vim-plug) and the
following plugins:

* [vim-gitgutter](https://github.com/airblade/vim-gitgutter) (show git changes
  in gutter)
* [vitality.vim](https://github.com/akracun/vitality.vim) (focus lost and gained
  inside tmux)
* [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
  (solarized colours)
* [vim-sxhkdrc](https://github.com/baskerville/vim-sxhkdrc) (syntax
  highlighting)
* [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim) (fuzzy finder)
* [supertab](https://github.com/ervandew/supertab) (tab completion)
* [vim-autoswap](https://github.com/gioele/vim-autoswap) (deal with swap files
  intelligently)
* [gitv](https://github.com/gregsexton/gitv) (gitk-alike)
* [dockerfile](https://github.com/honza/dockerfile) (docker syntax)
* [vim-search-pulse](https://github.com/inside/vim-search-pulse)
* [calendar](https://github.com/itchyny/calendar)
* [vim-easy-align](https://github.com/junegunn/vim-easy-align)
* [vim-signature](https://github.com/kshenoy/vim-signature)
* [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)
* [tagbar](https://github.com/majutsushi/tagbar)
* [vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
* [vim-hl-var](https://github.com/pjcj/vim-hl-var)
* [salt-vim](https://github.com/saltstack/salt-vim)
* [nerdtree](https://github.com/scrooloose/nerdtree)
* [syntastic](https://github.com/scrooloose/syntastic)
* [ctrlp-extensions](https://github.com/sgur/ctrlp-extensions)
* [gundo.vim](https://github.com/sjl/gundo.vim)
* [vim-matchit](https://github.com/Spaceghost/vim-matchit)
* [quickfix-reflector](https://github.com/stefandtw/quickfix-reflector)
* [vim-instant-markdown](https://github.com/suan/vim-instant-markdown)
* [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)
* [vim-abolish](https://github.com/tpope/vim-abolish)
* [vim-commentary](https://github.com/tpope/vim-commentary)
* [vim-dispatch](https://github.com/tpope/vim-dispatch)
* [vim-eunuch](https://github.com/tpope/vim-eunuch)
* [vim-fugitive](https://github.com/tpope/vim-fugitive)
* [vim-repeat](https://github.com/tpope/vim-repeat)
* [vim-surround](https://github.com/tpope/vim-surround)
* [vim-interestingwords](https://github.com/vasconcelloslf/vim-interestingwords)
* [vim-airline](https://github.com/vim-airline/vim-airline)
* [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
* [diffchar.vim](https://github.com/vim-scripts/diffchar.vim)
* [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)
* [vim-schlepp](https://github.com/zirrostig/vim-schlepp)
* [unite.vim](https://github.com/Shougo/unite.vim)
* [unite-grep-vcs](https://github.com/lambdalisue/unite-grep-vcs)
* [yankround.vim](https://github.com/LeafCage/yankround.vim)
* [unite-search-history](https://github.com/mpendse/unite-search-history)
* [neomru.vim](https://github.com/Shougo/neomru.vim)
* [vimproc.vim](https://github.com/Shougo/vimproc.vim)
* [unite-perl-module](https://github.com/soh335/unite-perl-module)
* [unite-git](https://github.com/yuku-t/unite-git)
