local install_path = Fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if Fn.empty(Fn.glob(install_path)) > 0 then
  Fn.system({
    "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path
  })
  Cmd "packadd packer.nvim"
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

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

  use {
    "lewis6991/spellsitter.nvim",
    config = function()
      require("spellsitter").setup {
        hl = "SpellBad",
        captures = { "comment" },  -- set to {} to spellcheck everything
      }
    end
  }

  use "neovim/nvim-lspconfig"
  use "kabouzeid/nvim-lspinstall"
  use "ray-x/lsp_signature.nvim"
  use {
    "kosayoda/nvim-lightbulb",
    config = function()
      Cmd [[autocmd CursorHold,CursorHoldI * lua require "nvim-lightbulb".update_lightbulb()]]
    end,
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  }

  use {
    "dense-analysis/ale",
    config = function()
      G.ale_linters_explicit   = 1
      G.ale_disable_lsp        = 1
      G.ale_virtualtext_cursor = 1
      G.ale_sign_error         = "E"
      G.ale_sign_warning       = "W"
      G.ale_sign_info          = "I"
      G.ale_linters = {
        yaml = { "circleci", "spectral", "swaglint", "yamllint" },
        sh   = { "shellcheck" },
        perl = { "perl" },
      }
      G.ale_perl_perl_executable = Fn.expand("~/g/base/utils/ale_perl")
      G.ale_perl_perl_options    = ""
    end,
  }

  use {
    "ludovicchabant/vim-gutentags",
    config = function()
      G.gutentags_ctags_exclude            = {
        "tmp", "blib", "node_modules", "dist",
      }
      -- can be extended with '*/sub/path' if required
      G.gutentags_generate_on_new          = 1
      G.gutentags_generate_on_missing      = 1
      G.gutentags_generate_on_write        = 1
      G.gutentags_generate_on_empty_buffer = 0
    end,
  }

  use {
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-gps").setup({
        icons = {
          ["class-name"]    = " ",
          ["function-name"] = " ",
          ["method-name"]   = " ",
        },
        -- Any language not disabled here is enabled by default
        languages = {
          -- ["bash"] = false,
          -- ["go"]   = false,
        },
        separator = ' > ',
      })
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
      G.go_gopls_gofumpt               = 1
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
      Map("n", "<leader>.",  [[<cmd>lua require "telescope.builtin".find_files({ hidden = true })<cr>]],      Defmap)
      Map("n", "<leader> ",  [[<cmd>lua require "telescope.builtin".oldfiles()<cr>]],                         Defmap)
      Map("n", "<leader>m",  [[<cmd>lua require "telescope.builtin".git_status()<cr>]],                       Defmap)
      Map("n", "<leader>fb", [[<cmd>lua require "telescope.builtin".buffers()<cr>]],                          Defmap)
      Map("n", "<leader>ff", [[<cmd>lua require "telescope.builtin".builtin()<cr>]],                          Defmap)
      Map("n", "<leader>fg", [[<cmd>lua require "telescope.builtin".live_grep()<cr>]],                        Defmap)
      Map("n", "<leader>fh", [[<cmd>lua require "telescope.builtin".help_tags()<cr>]],                        Defmap)
      Map("n", "<leader>fs", [[<cmd>lua require "telescope.builtin".grep_string()<cr>]],                      Defmap)
      Map("n", "<leader>fS", [[<cmd>lua require "telescope.builtin".grep_string({ word_match = "-w" })<cr>]], Defmap)
      Map("n", "<leader>fl", [[<cmd>lua require "telescope.builtin".current_buffer_fuzzy_find()<cr>]],        Defmap)
      Map("n", "<leader>fa", [[<cmd>lua require "telescope.builtin".lsp_code_actions()<cr>]],                 Defmap)
      Map("n", "<leader>fd", [[<cmd>lua require "telescope.builtin".lsp_definitions()<cr>]],                  Defmap)
      Map("n", "<leader>fr", [[<cmd>lua require "telescope.builtin".lsp_references()<cr>]],                   Defmap)
      Map("n", "<leader>ft", [[<cmd>lua require "telescope.builtin".tags()<cr>]],                             Defmap)
      Map("n", "<leader>fT", [[<cmd>lua require "telescope.builtin".tags{ only_current_buffer = true }<cr>]], Defmap)

      Cmd [[
        autocmd User TelescopePreviewerLoaded setlocal number
        autocmd User TelescopePreviewerLoaded setlocal tabstop=2
      ]]
    end,
  }

  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "quangnguyen30192/cmp-nvim-tags",
      { "andersevenrud/compe-tmux", branch = "cmp" },
      "onsails/lspkind-nvim",
    },
    config = function()
      require "cmp_nvim_lsp".setup()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require "cmp_nvim_lsp".update_capabilities(capabilities)
      local cmp = require "cmp"
      local lspkind = require "lspkind"

      lspkind.init({
        -- symbol_map = {
        --     Text = "",
        --     Method = "",
        --     Function = "",
        --     Constructor = "",
        --     Field = "ﰠ",
        --     Variable = "",
        --     Class = "ﴯ",
        --     Interface = "",
        --     Module = "",
        --     Property = "ﰠ",
        --     Unit = "塞",
        --     Value = "",
        --     Enum = "",
        --     Keyword = "",
        --     Snippet = "",
        --     Color = "",
        --     File = "",
        --     Reference = "",
        --     Folder = "",
        --     EnumMember = "",
        --     Constant = "",
        --     Struct = "פּ",
        --     Event = "",
        --     Operator = "",
        --     TypeParameter = ""
        -- }
      })

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and
          vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- local feedkey = function(key, mode)
        -- vim.api.nvim_feedkeys(
          -- vim.api.nvim_replace_termcodes(key, true, true, true), mode, true
        -- )
      -- end

      cmp.setup {
        formatting = {
          format = lspkind.cmp_format {
            -- with_text = false,
            -- maxwidth = 50,
            menu = {
              buffer   = "buf",
              nvim_lsp = "lsp",
              nvim_lua = "lua",
              path     = "path",
              tmux     = "tmux",
              tags     = "tags",
              vsnip    = "snip",
              calc     = "calc",
              spell    = "spell",
              emoji    = "emoji",
            }
          },
        },
        experimental = {native_menu = false, ghost_text = true},
        min_length = 1,
        mapping = {
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.close(),
          ["<CR>"]      = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            -- elseif vim.fn["vsnip#available"](1) == 1 then
              -- feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, {"i", "s"}),
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            -- elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              -- feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, {"i", "s"})
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          {
            name = "buffer",
            opts = {
              get_bufnrs = function() return vim.api.nvim_list_bufs() end,
            },
            -- keywords or just words
            keyword_pattern = "\\%(\\k\\+\\|\\w\\+\\)",
          },
          {
            name = "tmux",
            opts = { all_panes = true, label = "[tmux]" }
          },
          { name = "tags"  },
          { name = "path"  },
          { name = "calc"  },
          { name = "emoji" },
        },
        snippet = {
          expand = function(args)
            require "luasnip".lsp_expand(args.body)
          end,
        },
        -- snippet = {
          -- expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          -- end
        -- },
      }

      -- Use buffer source for `/`.
      cmp.setup.cmdline("/", {sources = {{name = "buffer"}}})

      -- Use cmdline & path source for ':'.
      -- TODO - revisit this, but currently it prevents normal completion
      -- cmp.setup.cmdline(":", {
        -- sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}})
      -- })
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
        watch_gitdir            = { interval = 1000 },
        sign_priority           = 6,
        update_debounce         = 100,
        status_formatter        = nil, -- Use default
        diff_opts               = {
          internal = true, -- If luajit is present
        },
        word_diff               = true,
        current_line_blame      = true,
        current_line_blame_opts = {
          virt_text     = true,
          virt_text_pos = 'eol',
          delay         = 1000,
        },
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
      require "nvim_comment".setup{
        line_mapping     = "-",
        comment_empty    = false,
      }
      Map("v", "-", ":<c-u>call CommentOperator(visualmode())<cr>", Defmap)
    end,
  }

  use "zsugabubus/crazy8.nvim"

  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      G.indent_blankline_char                           = " "
      G.indent_blankline_space_char                     = " "
      G.indent_blankline_show_trailing_blankline_indent = false
      G.indent_blankline_show_first_indent_level        = false
      G.indent_blankline_max_indent_increase            = 1
    end,
  }

  use "gioele/vim-autoswap"
  use "farmergreg/vim-lastplace"

  use {
    "mhinz/vim-startify",
    config = function()
      G.startify_change_to_vcs_root  = 1
      G.startify_fortune_use_unicode = 1
      G.startify_lists = {
        { type = "dir",       header = {"   MRU " .. Fn.getcwd()} },
        { type = "sessions",  header = {"   Sessions"           } },
        { type = "files",     header = {"   Files"              } },
        { type = "bookmarks", header = {"   Bookmarks"          } },
        { type = "commands",  header = {"   Commands"           } },
      }
    end,
  }

  use {
    "lfv89/vim-interestingwords",
    config = function()
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
    end,
  }

  use "junegunn/vim-easy-align"
  use "tpope/vim-surround"
  use "tpope/vim-repeat"

  use {
    "dstein64/nvim-scrollview",
    config = function()
      G.scrollview_winblend = 75
      G.scrollview_column   = 1
    end,
  }

  use {
    "edluffy/specs.nvim",
    config = function()
      require "specs".setup{
        show_jumps = true,
        min_jump   = 5,
        popup      = {
          delay_ms = 0,  -- delay before popup displays
          inc_ms   = 5,  -- time increments used for fade/resize effects
          blend    = 10, -- starting blend, between 0-100, see :h winblend
          width    = 40,
          winhl    = "ScrollView",
          fader    = require("specs").linear_fader,
          resizer  = require("specs").shrink_resizer,
        },
        ignore_filetypes = {},
        ignore_buftypes  = { nofile = true },
      }
      Map("n", "ä", [[<cmd>lua require "specs".show_specs()<cr>]], Defmap)
    end,
  }

  use {
    "iamcco/markdown-preview.nvim",
    config = function()
      vim.call("mkdp#util#install")
      Map("n", "<leader>d", [[<cmd>MarkdownPreviewToggle<cr>]], Defmap)
    end,
    cmd = "MarkdownPreviewToggle",
    ft = { "markdown" },
  }
end)
