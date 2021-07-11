local install_path = Fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if Fn.empty(Fn.glob(install_path)) > 0 then
  Fn.system({
    "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path
  })
  Cmd "packadd packer.nvim"
end

require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  use { "famiu/feline.nvim", config = function() require "statusline" end }

  use "kyazdani42/nvim-web-devicons"

  use "pjcj/neovim-colors-solarized-truecolor-only"

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require "nvim-treesitter.configs".setup {
        ensure_installed = "maintained",
        highlight        = { enable = true  },
        indent           = { enable = false },
      }
    end,
  }

  use "neovim/nvim-lspconfig"
  use "kabouzeid/nvim-lspinstall"
  use {
    "kosayoda/nvim-lightbulb",
    config = function()
      Cmd [[autocmd CursorHold,CursorHoldI * lua require "nvim-lightbulb".update_lightbulb()]]
    end,
  }

  use "ray-x/lsp_signature.nvim"

  use {
    "w0rp/ale",
    config = function()
      G.ale_linters_explicit = 1
      G.ale_disable_lsp      = 1
      G.ale_sign_error       = ""
      G.ale_sign_warning     = "⚠"
      G.ale_linters = {
        yaml = { "circleci", "spectral", "swaglint", "yamllint" },
        sh   = { "bashate", "language_server", "shell", "shellcheck" },
        perl = { "perl" },
      }
      G.ale_perl_perl_executable = Fn.expand("~/g/base/utils/ale_perl")
      G.ale_perl_perl_options    = ""
    end,
  }

  use {
    "ludovicchabant/vim-gutentags",
    config = function()
      G.gutentags_ctags_exclude            = { "blib", "tmp" }
      -- can be extended with '*/sub/path' if required
      G.gutentags_generate_on_new          = 1
      G.gutentags_generate_on_missing      = 1
      G.gutentags_generate_on_write        = 1
      G.gutentags_generate_on_empty_buffer = 0
    end,
  }

  use {
    "fatih/vim-go",
    run = ":GoUpdateBinaries",
    config = function()
      G.go_auto_type_info              = 1
      G.go_test_show_name              = 1
      G.go_doc_max_height              = 40
      G.go_doc_popup_window            = 1
      G.go_diagnostics_enabled         = 1
      G.go_diagnostics_level           = 2
      G.go_template_autocreate         = 0
      G.go_metalinter_command          = "golangci-lint"
      G.go_metalinter_autosave         = 0
      G.go_metalinter_autosave_enabled = { }
      G.go_metalinter_enabled          = { }
      G.go_fmt_options                 = { gofmt = "-s" }
    end,
  }

  use {
    "nvim-telescope/telescope.nvim",
    requires = {{ "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" }},
    config = function()
      require "telescope".setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob",
            "!.git",
          },
          file_ignore_patterns = {
            ".git/.*"
          },
        },
      }
    end,
  }

  use {
    "hrsh7th/nvim-compe",
    config = function()
      require "compe".setup {
        enabled          = true,
        autocomplete     = true,
        debug            = false,
        min_length       = 1,
        preselect        = "disable",
        throttle_time    = 80,
        source_timeout   = 200,
        resolve_timeout  = 800,
        incomplete_delay = 400,
        max_abbr_width   = 100,
        max_kind_width   = 100,
        max_menu_width   = 100,
        documentation    = true,

        source = {
          path            = true,
          buffer          = true,
          calc            = true,
          spell           = { priority = 3 },
          emoji           = true,
          nvim_lsp        = true,
          nvim_lua        = true,
          vsnip           = false,
          ultisnips       = false,
          nvim_treesitter = false,
          tmux            = {
            priority  = 5,
            all_panes = true,
          },
        },
      }

      local t = function(str)
        return Api.nvim_replace_termcodes(str, true, true, true)
      end

      local check_back_space = function()
        local col = Fn.col(".") - 1
        if col == 0 or Fn.getline("."):sub(col, col):match("%s") then
          return true
        else
          return false
        end
      end

      -- Use (s-)tab to:
      --- move to prev/next item in completion menuone
      --- jump to prev/next snippet's placeholder
      _G.tab_complete = function()
        if Fn.pumvisible() == 1 then
          return t "<C-n>"
        elseif Fn.call("vsnip#available", {1}) == 1 then
          return t "<Plug>(vsnip-expand-or-jump)"
        elseif check_back_space() then
          return t "<Tab>"
        else
          return Fn["compe#complete"]()
        end
      end

      _G.s_tab_complete = function()
        if Fn.pumvisible() == 1 then
          return t "<C-p>"
        elseif Fn.call("vsnip#jumpable", {-1}) == 1 then
          return t "<Plug>(vsnip-jump-prev)"
        else
          -- If <S-Tab> is not working in your terminal, change it to <C-h>
          return t "<S-Tab>"
        end
      end

      Map("i", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
      Map("s", "<Tab>",   "v:lua.tab_complete()",   {expr = true})
      Map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
      Map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
    end,
  }
  use "andersevenrud/compe-tmux"
  use {
    "windwp/nvim-autopairs",
    config = function()
      require "nvim-autopairs".setup({
        map_cr       = true, --  map <CR> on insert mode
        map_complete = true, -- auto insert `(` after selecting function
      })
    end,
  }

  use {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require "gitsigns".setup {
        signs = {
          add          = { show_count = true, text = "+" },
          change       = { show_count = true, text = "~" },
          delete       = { show_count = true, text = "_" },
          topdelete    = { show_count = true, text = "‾" },
          changedelete = { show_count = true, text = "~" },
        },
        numhl   = false,
        linehl  = false,
        keymaps = {
          -- Default keymap options
          noremap = true,
          buffer  = true,

          ["n <F2>"] = { expr = true, [[&diff ? '[c' : '<cmd>lua require "gitsigns.actions".prev_hunk()<CR>']]},
          ["n <F3>"] = { expr = true, [[&diff ? ']c' : '<cmd>lua require "gitsigns.actions".next_hunk()<CR>']]},

          ["n <leader>hs"] = '<cmd>lua require "gitsigns".stage_hunk()<CR>',
          ["v <leader>hs"] = '<cmd>lua require "gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
          ["n <leader>hu"] = '<cmd>lua require "gitsigns".undo_stage_hunk()<CR>',
          ["n <leader>hr"] = '<cmd>lua require "gitsigns".reset_hunk()<CR>',
          ["v <leader>hr"] = '<cmd>lua require "gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
          ["n <leader>hR"] = '<cmd>lua require "gitsigns".reset_buffer()<CR>',
          ["n <leader>hp"] = '<cmd>lua require "gitsigns".preview_hunk()<CR>',
          ["n <leader>hb"] = '<cmd>lua require "gitsigns".blame_line(true)<CR>',

          ["n <F1>"] = '<cmd>lua require "gitsigns".stage_hunk()<CR>',
          ["v <F1>"] = '<cmd>lua require "gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',

          -- Text objects
          ["o ih"] = ':<C-U>lua require "gitsigns.actions".select_hunk()<CR>',
          ["x ih"] = ':<C-U>lua require "gitsigns.actions".select_hunk()<CR>'
        },
        watch_index                 = { interval = 1000 },
        current_line_blame          = true,
        current_line_blame_delay    = 1000,
        current_line_blame_position = "eol",
        sign_priority               = 6,
        update_debounce             = 100,
        status_formatter            = nil, -- Use default
        use_decoration_api          = true,
        use_internal_diff           = true, -- If luajit is present
        count_chars = {
          [1]   = "₁",
          [2]   = "₂",
          [3]   = "₃",
          [4]   = "₄",
          [5]   = "₅",
          [6]   = "₆",
          [7]   = "₇",
          [8]   = "₈",
          [9]   = "₉",
          ["+"] = "₊",
        },
      }
    end,
  }

  use {
    "rhysd/git-messenger.vim",
    config = function()
      G.git_messenger_always_into_popup = 1
      G.git_messenger_include_diff      = "current"
    end,
  }

  use {
    "ruanyl/vim-gh-line",
    config = function()
      G.gh_use_canonical = 0
    end,
  }

  use "tpope/vim-fugitive"

  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      Opt.termguicolors = true
      require "colorizer".setup(
        { "*" },
        { names = true, RGB = true, RRGGBB = true, RRGGBBAA = true, css = true }
      )
    end,
  }

  use {
    "terrortylor/nvim-comment",
    config = function()
      require "nvim_comment".setup({ line_mapping = "-" })
    end,
  }

  use "zsugabubus/crazy8.nvim"
  use "lukas-reineke/indent-blankline.nvim"

  use "gioele/vim-autoswap"
  use "farmergreg/vim-lastplace"
  use "mhinz/vim-startify"
  use "lfv89/vim-interestingwords"
  use "junegunn/vim-easy-align"
  use "tpope/vim-surround"
  use "tpope/vim-repeat"
  use "dstein64/nvim-scrollview"
  use "edluffy/specs.nvim"
end)

G.indent_blankline_char                           = " "
G.indent_blankline_space_char                     = " "
G.indent_blankline_show_trailing_blankline_indent = false
G.indent_blankline_show_first_indent_level        = false

G.startify_change_to_vcs_root  = 1
G.startify_fortune_use_unicode = 1
G.startify_lists = {
  { type = "dir",       header = {"   MRU " .. Fn.getcwd()} },
  { type = "sessions",  header = {"   Sessions"           } },
  { type = "files",     header = {"   Files"              } },
  { type = "bookmarks", header = {"   Bookmarks"          } },
  { type = "commands",  header = {"   Commands"           } },
}

G.interestingWordsGUIColors = {
  '#72b5e4', '#f0c53f', '#ff8784', '#c5c7f1',
  '#c2d735', '#78d3cc', '#ea8336', '#e43542',
  '#ebab35', '#ebe735', '#aadd32', '#dcca6b',
  '#219286', '#2f569c', '#ffb577', '#5282a4',
  '#edfccf', '#67064c', '#f5bca7', '#95c474',
  '#dece83', '#de9783', '#f2e700', '#e9e9e9',
  '#69636d', '#626b98', '#f5f5a7', '#dcca6b',
  '#b72a83', '#6f2b9d', '#69636d', '#5f569c',
}

G.scrollview_winblend = 75
G.scrollview_column   = 1

require("specs").setup{
  show_jumps  = true,
  min_jump = 10,
  popup = {
    delay_ms = 0, -- delay before popup displays
    inc_ms = 5, -- time increments used for fade/resize effects
    blend = 10, -- starting blend, between 0-100 (fully transparent), see :h winblend
    width = 40,
    winhl = "ScrollView",
    fader = require("specs").linear_fader,
    resizer = require("specs").shrink_resizer,
  },
  ignore_filetypes = {},
  ignore_buftypes = {
    nofile = true,
  },
}
