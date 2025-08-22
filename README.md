# My Base System

This is the base system that I put onto any machine on which I am developing.
It includes config files for:

- [bspwm](https://github.com/baskerville/bspwm) (tiling window manager)
- [sxhkd](https://github.com/baskerville/sxhkd) (X hotkey daemon)
- Xdefaults
- [tmux](https://tmux.github.io/) (terminal multiplexer)
- [zsh](http://www.zsh.org/) (shell)
- [neovim](https://github.com/neovim/neovim) (editor)
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

The neovim config uses [lazy.nvim](https://github.com/folke/lazy.nvim) and the
following plugins:

**Core & UI:**

- [catppuccin/nvim](https://github.com/catppuccin/nvim) (colorscheme)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (file icons)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) (status line)
- [which-key.nvim](https://github.com/folke/which-key.nvim) (key binding help)
- [nvim-navic](https://github.com/SmiteshP/nvim-navic) (breadcrumbs)

**LSP & Completion:**

- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (LSP configuration)
- [mason.nvim](https://github.com/williamboman/mason.nvim) (LSP installer)
- [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) (mason integration)
- [magazine.nvim](https://github.com/iguanacucumber/magazine.nvim) (completion engine)
- [lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim) (signature help)
- [nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb) (code actions indicator)
- [lsp-colors.nvim](https://github.com/folke/lsp-colors.nvim) (LSP colors)

**Treesitter:**

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (syntax highlighting)
- [nvim-treesitter-refactor](https://github.com/nvim-treesitter/nvim-treesitter-refactor) (refactoring)
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) (text objects)
- [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) (context)
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) (auto close tags)
- [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) (context comments)

**Fuzzy Finding & Navigation:**

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (fuzzy finder)
- [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) (fzf integration)
- [telescope-frecency.nvim](https://github.com/nvim-telescope/telescope-frecency.nvim) (frecency algorithm)
- [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) (UI select)
- [telescope-undo.nvim](https://github.com/debugloop/telescope-undo.nvim) (undo tree)
- [smart-open.nvim](https://github.com/danielfalk/smart-open.nvim) (smart file opening)

**Git:**

- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) (git signs)
- [git-messenger.vim](https://github.com/rhysd/git-messenger.vim) (git blame popup)
- [conflict-marker.vim](https://github.com/rhysd/conflict-marker.vim) (conflict markers)
- [diffview.nvim](https://github.com/sindrets/diffview.nvim) (diff viewer)
- [vim-gh-line](https://github.com/ruanyl/vim-gh-line) (GitHub line links)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) (git integration)
- [gitlab.nvim](https://github.com/harrisoncramer/gitlab.nvim) (GitLab integration)

**AI & Completion Sources:**

- [copilot.lua](https://github.com/zbirenbaum/copilot.lua) (GitHub Copilot)
- [copilot-cmp](https://github.com/zbirenbaum/copilot-cmp) (Copilot completion)
- [codeium.nvim](https://github.com/Exafunction/codeium.nvim) (Codeium AI)
- [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) (Supermaven AI)
- [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) (Gemini AI)
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) (AI chat)
- [avante.nvim](https://github.com/yetone/avante.nvim) (AI assistant)
- [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim) (MCP integration)
- [VectorCode](https://github.com/Davidyz/VectorCode) (code search)

**Language Support:**

- [go.nvim](https://github.com/ray-x/go.nvim) (Go development)
- [vim-perl](https://github.com/vim-perl/vim-perl) (Perl support)
- [vim-terraform](https://github.com/hashivim/vim-terraform) (Terraform)
- [vim-helm](https://github.com/towolf/vim-helm) (Helm charts)

**Testing & Debugging:**

- [neotest](https://github.com/nvim-neotest/neotest) (testing framework)
- [neotest-go](https://github.com/nvim-neotest/neotest-go) (Go testing)

**Linting & Formatting:**

- [nvim-lint](https://github.com/mfussenegger/nvim-lint) (linting)
- [ale](https://github.com/dense-analysis/ale) (async linting)
- [conform.nvim](https://github.com/stevearc/conform.nvim) (formatting)
- [nvim-rulebook](https://github.com/chrisgrieser/nvim-rulebook) (rule checking)

**File Management:**

- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) (file tree)
- [oil.nvim](https://github.com/stevearc/oil.nvim) (file editing)
- [yazi.nvim](https://github.com/mikavilpas/yazi.nvim) (file manager)
- [outline.nvim](https://github.com/hedyhli/outline.nvim) (code outline)

**Text Manipulation:**

- [nvim-surround](https://github.com/kylechui/nvim-surround) (surround text)
- [vim-easy-align](https://github.com/junegunn/vim-easy-align) (alignment)
- [vim-move](https://github.com/matze/vim-move) (move lines/blocks)
- [nvim-comment](https://github.com/terrortylor/nvim-comment) (commenting)
- [treesj](https://github.com/Wansmer/treesj) (split/join code)
- [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) (refactoring)
- [nvim-spider](https://github.com/chrisgrieser/nvim-spider) (camelCase motion)
- [nvim-various-textobjs](https://github.com/chrisgrieser/nvim-various-textobjs) (text objects)

**UI Enhancements:**

- [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) (color highlighting)
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) (indent guides)
- [nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens) (search lens)
- [nvim-scrollbar](https://github.com/petertriho/nvim-scrollbar) (scrollbar)
- [hl_match_area.nvim](https://github.com/rareitems/hl_match_area.nvim) (match highlighting)
- [lfv89/vim-interestingwords](https://github.com/lfv89/vim-interestingwords) (word highlighting)
- [SmoothCursor.nvim](https://github.com/gen740/SmoothCursor.nvim) (smooth cursor)
- [emission.nvim](https://github.com/aileot/emission.nvim) (change highlighting)

**Utilities:**

- [vim-autoswap](https://github.com/gioele/vim-autoswap) (swap file handling)
- [vim-lastplace](https://github.com/farmergreg/vim-lastplace) (restore cursor position)
- [vim-startify](https://github.com/mhinz/vim-startify) (start screen)
- [crazy8.nvim](https://github.com/zsugabubus/crazy8.nvim) (utilities)
- [lexima.vim](https://github.com/cohama/lexima.vim) (auto pairs)
- [vim-repeat](https://github.com/tpope/vim-repeat) (repeat plugin actions)
- [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags) (tag generation)

**Quickfix & Search:**

- [nvim-bqf](https://github.com/kevinhwang91/nvim-bqf) (better quickfix)
- [nvim-pqf](https://github.com/yorickpeterse/nvim-pqf) (pretty quickfix)
- [replacer.nvim](https://github.com/gabrielpoca/replacer.nvim) (search replace)

**Markdown & Documentation:**

- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) (markdown preview)
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) (markdown rendering)
- [markview.nvim](https://github.com/OXY2DEV/markview.nvim) (markdown viewer)
- [helpview.nvim](https://github.com/OXY2DEV/helpview.nvim) (help viewer)

**Miscellaneous:**

- [nvim-notify](https://github.com/rcarriga/nvim-notify) (notifications)
- [nvim-lsp-notify](https://github.com/mrded/nvim-lsp-notify) (LSP notifications)
- [dressing.nvim](https://github.com/stevearc/dressing.nvim) (UI improvements)
- [overseer.nvim](https://github.com/stevearc/overseer.nvim) (task runner)
- [sidebar.nvim](https://github.com/sidebar-nvim/sidebar.nvim) (sidebar)
- [hex.nvim](https://github.com/RaafatTurki/hex.nvim) (hex editor)
- [shell.nvim](https://github.com/siadat/shell.nvim) (shell integration)
- [urlview.nvim](https://github.com/axieax/urlview.nvim) (URL viewer)
- [translate.nvim](https://github.com/uga-rosa/translate.nvim) (translation)
- [vim-oscyank](https://github.com/ojroques/vim-oscyank) (OSC52 clipboard)
- [ascii-blocks.nvim](https://github.com/superhawk610/ascii-blocks.nvim) (ASCII art)
- [vim-unicode-homoglyphs](https://github.com/Konfekt/vim-unicode-homoglyphs) (unicode handling)
