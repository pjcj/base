# My Base System

This is the base system that I put onto any machine on which I am developing.
It includes config files for:

- [bspwm](https://github.com/baskerville/bspwm) (tiling window manager)
- [sxhkd](https://github.com/baskerville/sxhkd) (X hotkey daemon)
- Xdefaults
- [tmux](https://tmux.github.io/) (terminal multiplexer)
- [zsh](http://www.zsh.org/) (shell)
- [vim](http://www.vim.org/) or [neovim](https://github.com/neovim/neovim)
  (editors)
- [powerline](https://github.com/powerline/powerline) (status line for tmux)
- [git](http://www.git-scm.com/) (version control)

Colours are Solarized Dark slightly altered to make the dark background colours
a little darker.

Unpackaged software, or software that is newer than packaged versions, is
managed with [ghq](https://github.com/motemen/ghq) and includes the following
repositories:

- [st](http://git.suckless.org/st/)
- [zsh](git://zsh.git.sf.net/gitroot/zsh/zsh)
- [zsh-git-prompt](https://github.com/olivierverdier/zsh-git-prompt) (prompt for
  zsh including git status)
- [neovim](https://github.com/neovim/neovim)
- [tmux](https://github.com/tmux/tmux) and
  [libevent](https://github.com/libevent/libevent)
- [bspwm](https://github.com/baskerville/bspwm)
- [sxhkd](https://github.com/baskerville/sxhkd)
- [git](https://github.com/git/git)
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) (better git diffs)
- [tig](https://github.com/jonas/tig) (git viewer)
- [caps2esc](https://github.com/oblitum/caps2esc) (make capslock useful)
- [xdotool](https://github.com/jordansissel/xdotool) (automate X input)
- [Clipit](https://github.com/shantzu/ClipIt) (clipboard manager)
- [urlview](https://github.com/sigpipe/urlview) (extract URLs from text)
- [shellcheck](https://github.com/koalaman/shellcheck) (shell linter)
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)
- [PathPicker](https://github.com/facebook/PathPicker) (file selector)
- [htop](https://github.com/hishamhm/htop) (better top)
- [hosts](https://github.com/StevenBlack/hosts) (safe hosts file)

The zsh config uses [zplug](https://github.com/b4b4r07/zplug) and the following
plugins:

- [zsh-completions](https://github.com/zsh-users/zsh-completions) (extra
  completions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  (highlighting on the command line)
- [zsh-dwim](https://github.com/oknowton/zsh-dwim) (predict next command with
  ^U)
- [git-extras](https://github.com/tj/git-extras) (additional git commands)

The vim config uses [vim-plug](https://github.com/junegunn/vim-plug) and the
following plugins:

- [ale](https://github.com/w0rp/ale) (syntax checking)
- [clever-f](https://github.com/rhysd/clever-f.vim) (extends f and t)
- [ctrlp-extensions](https://github.com/sgur/ctrlp-extensions) (cmdline, yank
  and menu for ctrlp)
- [ctrlp](https://github.com/ctrlpvim/ctrlp.vim) (fuzzy finder)
- [deoplete](https://github.com/Shougo/deoplete.nvim) (completion)
- [diffchar](https://github.com/vim-scripts/diffchar.vim) (show diffs by
  character)
- [gitv](https://github.com/gregsexton/gitv) (gitk-alike)
- [godown-vim](https://github.com/davinche/godown-vim) (show markdown in
  browser as it is edited)
- [incsearch-fuzzy](https://github.com/haya14busa/incsearch-fuzzy.vim) (fuzzy
  search)
- [incsearch](https://github.com/haya14busa/incsearch.vim) (show all matches on
  incsearch)
- [neco-syntax](https://github.com/Shougo/neco-syntax) (for use with deoplete)
- [neovim-colors-solarized-truecolor-only](https://github.com/pjcj/neovim-colors-solarized-truecolor-only)
  (my version of truecolour solarized colours)
- [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin) (show
  git status against files)
- [nerdtree](https://github.com/scrooloose/nerdtree) (file tree)
- [nginx](https://github.com/chr4/nginx.vim) (nginx syntax)
- [nvim-miniyank](https://github.com/bfredl/nvim-miniyank) (yankring)
- [quickfix-reflector](https://github.com/stefandtw/quickfix-reflector.vim)
  (edit text in quickfix window)
- [salt-vim](https://github.com/saltstack/salt-vim) (salt syntax)
- [sideways](https://andrewradev/sideways.vim) (operate on arglists)
- [sparkup](https://github.com/rstacruz/sparkup) (HTML helper)
- [supertab](https://github.com/ervandew/supertab) (tab completion)
- [tagbar](https://github.com/majutsushi/tagbar) (display tags)
- [targets](https://github.com/wellle/targets.vim) (add * | and _ targets)
- [tmux-complete](https://github.com/wellle/tmux-complete.vim) (completion from
  tmux buffers)
- [ultisnips](https://github.com/SirVer/ultisnips) (snippets)
- [undotree](https://github.com/mbbill/undotree) (undo tree management)
- [unicode](https://github.com/chrisbra/unicode.vim) (unicode table, search,
  complete)
- [vim-abolish](https://github.com/tpope/vim-abolish) (handle word variants)
- [vim-airline](https://github.com/vim-airline/vim-airline) (status line)
- [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
  (status line themes)
- [vim-argwrap](https://github.com/FooSoft/vim-argwrap) (wrap multiline args)
- [vim-autoswap](https://github.com/gioele/vim-autoswap) (deal with swap files
  intelligently)
- [vim-closetag](https://github.com/alvan/vim-closetag) (close tags)
- [vim-commentary](https://github.com/tpope/vim-commentary) (code comments)
- [vim-css-color](https://github.com/ap/vim-css-color) (add colour to
  descriptions)
- [vim-diff-enhanced](https://github.com/chrisbra/vim-diff-enhanced) (change
  diff algorithm)
- [vim-dispatch](https://github.com/tpope/vim-dispatch) (asynchronous jobs)
- [vim-easy-align](https://github.com/junegunn/vim-easy-align) (vertical
  alignment)
- [vim-eunuch](https://github.com/tpope/vim-eunuch) (unix commands)
- [vim-fetch](https://github.com/kopischke/vim-fetch) (use line numbers in file
  paths)
- [vim-fugitive-blame-ext](https://github.com/tommcdo/vim-fugitive-blame-ext)
  (extend :Gblame)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) (work with git)
- [vim-gitgutter](https://github.com/airblade/vim-gitgutter) (show git changes
  in gutter)
- [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags) (generate
  tags dynamically)
- [vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
  (guidelines for indentation)
- [vim-interestingwords](https://github.com/vasconcelloslf/vim-interestingwords)
  (highlighting and navigation)
- [vim-lion](https://github.com/tommcdo/vim-lion) (alignment)
- [vim-matchit](https://github.com/Spaceghost/vim-matchit) (extended % matching)
- [vim-polyglot](https://github.com/sheerun/vim-polyglot) (extra syntax files)
- [vim-repeat](https://github.com/tpope/vim-repeat) (make . work more often)
- [vim-schlepp](https://github.com/zirrostig/vim-schlepp) (move blocks of text)
- [vim-searchindex](https://github.com/google/vim-searchindex) (show m/n for
  searches)
- [vim-search-pulse](https://github.com/inside/vim-search-pulse) (pulse on
  search)
- [vim-signature](https://github.com/kshenoy/vim-signature) (show marks)
- [vim-snippets](https://github.com/honza/vim-snippets) (snippets)
- [vim-surround](https://github.com/tpope/vim-surround) (manage surrounding
  characters)
- [vim-sxhkdrc](https://github.com/baskerville/vim-sxhkdrc) (syntax
  highlighting)
- [vim-tmux](https://github.com/tmux-plugins/vim-tmux) (tmux syntax highlighting
  and more)
- [vitality](https://github.com/akracun/vitality.vim) (focus lost and gained
  inside tmux)
- [vim-perl](https://github.com/vim-perl/vim-perl) (perl functionality)
- [vim-perl6](https://github.com/vim-perl/vim-perl6) (perl6 functionality)
- [perlomni](https://github.com/c9s/perlomni.vim) (perl omni completion)
- [vim-shortcut](https://github.com/sunaku/vim-shortcut) (describe shortcuts)
- [fzf](https://github.com/junegunn/fzf.vim) (fuzzy finder)
- [denite](https://github.com/Shougo/denite.vim) (ctrl-p-like interface)
- [denite-extra](https://github.com/chemzqm/denite-extra.vim) (extra sources)
- [unite](https://github.com/Shougo/unite.vim) (for legacy sources)
- [neomru](https://github.com/Shougo/neomru.vim) (MRU for unite)
- [unite-git](https://github.com/yuku-t/unite-git) (git in unite)
- [unite-outline](https://github.com/Shougo/unite-outline) (outline for unite)
- [unite-perl-module](https://github.com/soh335/unite-perl-module) (integrate
  Perl modules into unite)
