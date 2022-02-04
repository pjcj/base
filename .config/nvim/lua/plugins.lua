local install_path = vim.fn.stdpath "data"
  .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system {
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  vim.cmd "packadd packer.nvim"
end

vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]]

require("packer").startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  use {
    "famiu/feline.nvim",
    config = function()
      require "statusline"
    end,
  }
  use "kyazdani42/nvim-web-devicons"
  use "pjcj/neovim-colors-solarized-truecolor-only"

  use {
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "nvim-treesitter/playground",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = "maintained",
        highlight = { enable = true },
        indent = { enable = false },
        refactor = {
          highlight_definitions = { enable = true },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<tab>",
            scope_incremental = "<cr>",
            node_incremental = "<tab>",
            node_decremental = "<s-tab>",
          },
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
      }
    end,
  }

  use {
    "terrortylor/nvim-comment",
    config = function()
      require("nvim_comment").setup {
        line_mapping = "-",
        comment_empty = false,
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      }
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "v",
        "-",
        ":<c-u>call CommentOperator(visualmode())<cr>",
        l.map.defmap
      )
    end,
  }

  use {
    "lewis6991/spellsitter.nvim",
    config = function()
      require("spellsitter").setup {
        hl = "SpellBad",
        captures = { "comment" }, -- set to {} to spellcheck everything
      }
    end,
  }

  use "neovim/nvim-lspconfig"
  use "williamboman/nvim-lsp-installer"
  use "ray-x/lsp_signature.nvim"
  -- use "folke/lsp-colors.nvim"
  use {
    "kosayoda/nvim-lightbulb",
    config = function()
      vim.cmd [[autocmd CursorHold,CursorHoldI * lua require "nvim-lightbulb".update_lightbulb()]]
    end,
  }
  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  }
  -- use {
  --   -- :lua vim.lsp.buf.incoming_calls()
  --   -- :lua vim.lsp.buf.outgoing_calls()
  --   "ldelossa/calltree.nvim",
  --   config = function()
  --     require "calltree".setup({})
  --   end,
  -- }

  use {
    "dense-analysis/ale",
    config = function()
      vim.g.ale_linters_explicit = 1
      vim.g.ale_disable_lsp = 1
      vim.g.ale_virtualtext_cursor = 1
      vim.g.ale_sign_error = "E"
      vim.g.ale_sign_warning = "W"
      vim.g.ale_sign_info = "I"
      vim.g.ale_linters = {
        yaml = { "circleci", "spectral", "swaglint", "yamllint" },
        perl = { "perl" },
      }
      vim.g.ale_perl_perl_executable = vim.fn.expand "~/g/base/utils/ale_perl"
      vim.g.ale_perl_perl_options = ""
    end,
  }

  use {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_ctags_exclude = {
        "tmp",
        "blib",
        "node_modules",
        "dist",
      }
      -- can be extended with '*/sub/path' if required
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0
    end,
  }

  use {
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-gps").setup {
        icons = {
          ["class-name"] = " ",
          ["function-name"] = " ",
          ["method-name"] = " ",
        },
        -- Any language not disabled here is enabled by default
        languages = {
          -- ["bash"] = false,
          -- ["go"]   = false,
        },
        separator = " > ",
      }
    end,
  }

  use {
    "fatih/vim-go",
    run = ":GoUpdateBinaries",
    config = function()
      vim.g.go_auto_type_info = 1
      vim.g.go_test_show_name = 1
      vim.g.go_doc_max_height = 40
      vim.g.go_doc_popup_window = 1
      vim.g.go_diagnostics_enabled = 1
      vim.g.go_diagnostics_level = 2
      vim.g.go_template_autocreate = 0
      vim.g.go_metalinter_command = "golangci-lint"
      vim.g.go_metalinter_autosave = 0
      vim.g.go_metalinter_autosave_enabled = {}
      vim.g.go_metalinter_enabled = {}
      vim.g.go_gopls_gofumpt = 1
      -- vim.g.go_fmt_command                 = "golines"
      vim.g.go_fmt_options = {
        gofmt = "-s",
        golines = "-m 80 -t 2",
      }
    end,
  }

  use {
    "vim-perl/vim-perl",
    run = "make clean carp dancer heredoc-sql highlight-all-pragmas js-css-in-mason method-signatures moose test-more try-tiny",
  }

  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      local refactoring = require "refactoring"

      refactoring.setup {
        installation_path = vim.fn.stdpath "data" .. "/dapinstall/",
      }
    end,
  }

  use "mfussenegger/nvim-dap"
  use {
    "Pocco81/DAPInstall.nvim",
    config = function()
      local dap_install = require "dap-install"

      dap_install.setup {
        installation_path = vim.fn.stdpath "data" .. "/dapinstall/",
      }

      local dbg_list =
        require("dap-install.api.debuggers").get_installed_debuggers()

      for _, debugger in ipairs(dbg_list) do
        dap_install.config(debugger)
      end
    end,
  }

  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
  use {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
    config = function()
      local telescope = require "telescope"
      telescope.setup {
        defaults = {
          extensions = {
            fzf = {
              -- default options
              fuzzy = true,
              case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            },
          },
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
            ".git/.*",
          },
          dynamic_preview_title = true,
        },
      }

      telescope.load_extension "fzf"
      telescope.load_extension "refactoring"

      local l = require "local_defs"
      -- stylua: ignore start
      vim.api.nvim_set_keymap("n", "<leader>.",  [[<cmd>lua require "telescope.builtin".find_files({ hidden = true })<cr>]],      l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader> ",  [[<cmd>lua require "telescope.builtin".oldfiles()<cr>]],                         l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>m",  [[<cmd>lua require "telescope.builtin".git_status()<cr>]],                       l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fb", [[<cmd>lua require "telescope.builtin".buffers()<cr>]],                          l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>ff", [[<cmd>lua require "telescope.builtin".builtin()<cr>]],                          l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fg", [[<cmd>lua require "telescope.builtin".live_grep()<cr>]],                        l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fG", [[<cmd>lua require "telescope.builtin".live_grep({ additional_args = function() return { "-w" } end })<cr>]], l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fh", [[<cmd>lua require "telescope.builtin".help_tags()<cr>]],                        l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fs", [[<cmd>lua require "telescope.builtin".grep_string()<cr>]],                      l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fS", [[<cmd>lua require "telescope.builtin".grep_string({ word_match = "-w" })<cr>]], l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fl", [[<cmd>lua require "telescope.builtin".current_buffer_fuzzy_find()<cr>]],        l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fa", [[<cmd>lua require "telescope.builtin".lsp_code_actions()<cr>]],                 l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fd", [[<cmd>lua require "telescope.builtin".lsp_definitions()<cr>]],                  l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fr", [[<cmd>lua require "telescope.builtin".lsp_references()<cr>]],                   l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>ft", [[<cmd>lua require "telescope.builtin".tags()<cr>]],                             l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fT", [[<cmd>lua require "telescope.builtin".tags{ only_current_buffer = true }<cr>]], l.map.defmap)
      vim.api.nvim_set_keymap("n", "<leader>fp", [[<cmd>lua require "telescope".extensions.neoclip.default()<cr>]],               l.map.defmap)
      vim.api.nvim_set_keymap("v", "<leader>fR", [[<esc><cmd>lua require('telescope').extensions.refactoring.refactors()<cr>]],   l.map.defmap)
      -- stylua: ignore end

      vim.cmd [[
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
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "quangnguyen30192/cmp-nvim-tags",
      "andersevenrud/cmp-tmux",
      "onsails/lspkind-nvim",
      "rafamadriz/friendly-snippets",
      "uga-rosa/cmp-dictionary",
    },
    config = function()
      require("cmp_nvim_lsp").setup()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
      local cmp = require "cmp"
      local lspkind = require "lspkind"

      -- stylua: ignore start
      lspkind.init({
        symbol_map = {
          Text          = "",
          Method        = "",
          Function      = "",
          Constructor   = "",
          Field         = "",
          Variable      = "",
          Class         = "ﴯ",
          Interface     = "",
          Module        = "",
          Property      = "ﰠ",
          Unit          = "",
          Value         = "",
          Enum          = "",
          Keyword       = "",
          Snippet       = "",
          Color         = "",
          File          = "",
          Reference     = "",
          Folder        = "",
          EnumMember    = "",
          Constant      = "",
          Struct        = "פּ",
          Event         = "",
          Operator      = "",
          TypeParameter = ""
        }
      })
      -- stylua: ignore end

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
              :sub(col, col)
              :match "%s"
            == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(key, true, true, true),
          mode,
          true
        )
      end

      cmp.setup {
        formatting = {
          format = lspkind.cmp_format {
            mode = "symbol_text",
            -- maxwidth = 50,
            menu = {
              buffer = "buf",
              nvim_lsp = "lsp",
              nvim_lua = "lua",
              path = "path",
              tmux = "tmux",
              tags = "tags",
              vsnip = "snip",
              calc = "calc",
              spell = "spell",
              emoji = "emoji",
            },
          },
        },
        experimental = {
          native_menu = false,
          ghost_text = true,
          horizontal_search = true,
        },
        min_length = 1,
        mapping = {
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          {
            name = "buffer",
            options = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
            -- keywords or just words
            keyword_pattern = "\\%(\\k\\+\\|\\w\\+\\)",
          },
          {
            name = "tmux",
            option = { all_panes = true, label = "[tmux]" },
          },
          { name = "tags" },
          { name = "path" },
          { name = "calc" },
          { name = "emoji" },
          {
            name = "dictionary",
            keyword_length = 2,
          },
        },
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
      }

      require("cmp_dictionary").setup {
        dic = {
          ["*"] = { "/usr/share/dict/words" },
          -- ["lua"] = "path/to/lua.dic",
          -- ["javascript,typescript"] = { "path/to/js.dic", "path/to/js2.dic" },
          -- filename = {
          --   ["xmake.lua"] = { "path/to/xmake.dic", "path/to/lua.dic" },
          -- },
          -- filepath = {
          --   ["%.tmux.*%.conf"] = "path/to/tmux.dic"
          -- },
        },
        -- The following are default values, so you don't need to write them if
        -- you don't want to change them
        -- exact = 2,
        -- first_case_insensitive = false,
        -- async = false,
        -- capacity = 5,
        -- debug = false,
      }

      -- Use buffer source for `/`.
      cmp.setup.cmdline("/", { sources = { { name = "buffer" } } })

      -- Use cmdline & path source for ':'.
      -- TODO - revisit this, but currently it prevents normal completion
      -- cmp.setup.cmdline(":", {
      --   sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}})
      -- })
    end,
  }

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        window = {
          border = "single",
        },
        layout = {
          width = {
            max = 80,
          },
        },
        plugins = {
          spelling = {
            enabled = true,
            suggestions = 20,
          },
        },
      }
    end,
  }

  use {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup {
        signs = {
          add = { show_count = true, text = "+" },
          change = { show_count = true, text = "~" },
          delete = { show_count = true, text = "_" },
          topdelete = { show_count = true, text = "‾" },
          changedelete = { show_count = true, text = "~" },
        },
        numhl = false,
        linehl = false,
        watch_gitdir = { interval = 1000 },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        diff_opts = { internal = true }, -- If luajit is present
        word_diff = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
        },
        count_chars = {
          [1] = "₁",
          [2] = "₂",
          [3] = "₃",
          [4] = "₄",
          [5] = "₅",
          [6] = "₆",
          [7] = "₇",
          [8] = "₈",
          [9] = "₉",
          ["+"] = "₊",
        },
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, opts)
            opts = vim.tbl_extend(
              "force",
              { noremap = true, silent = true },
              opts or {}
            )
            vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
          end

        -- stylua: ignore start
          -- Navigation
          map(
            "n",
            "<F3>",
            "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'",
            { expr = true }
          )
          map(
            "n",
            "<F2>",
            "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'",
            { expr = true }
          )

          -- Actions
          map("n", "<F1>", ":Gitsigns stage_hunk<CR>")
          map("v", "<F1>", ":Gitsigns stage_hunk<CR>")
          map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>")
          map("v", "<leader>hs", ":Gitsigns stage_hunk<CR>")
          map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
          map("v", "<leader>hr", ":Gitsigns reset_hunk<CR>")
          map("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>")
          map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
          map("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>")
          map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
          map(
            "n",
            "<leader>hb",
            '<cmd>lua require"gitsigns".blame_line{full=true}<CR>'
          )
          map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>")
          map("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>")
          map("n", "<leader>hD", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
          map("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>")

          -- Text object
          map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
          map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      }
    end,
  }

  use {
    "rhysd/git-messenger.vim",
    config = function()
      vim.g.git_messenger_always_into_popup = 1
      vim.g.git_messenger_include_diff = "current"
    end,
  }

  use {
    "ruanyl/vim-gh-line",
    config = function()
      vim.g.gh_use_canonical = 0
    end,
  }

  use "tpope/vim-fugitive"

  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      vim.opt.termguicolors = true
      require("colorizer").setup(
        { "*" },
        { names = true, RGB = true, RRGGBB = true, RRGGBBAA = true, css = true }
      )
    end,
  }

  use {
    "ggandor/lightspeed.nvim",
    config = function()
      require("lightspeed").setup {
        jump_to_unique_chars = 2000,
      }
    end,
  }

  use {
    "AckslD/nvim-neoclip.lua",
    requires = { "tami5/sqlite.lua", module = "sqlite" },
    config = function()
      require("neoclip").setup {
        enable_persistant_history = true,
        db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
        default_register = '"',
      }
    end,
  }

  use "zsugabubus/crazy8.nvim"
  use "gpanders/editorconfig.nvim"
  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      -- stylua: ignore
      require "indent_blankline".setup{
        char                                       = " ",
        space_char                                 = " ",
        context_char                               = "┃",
        show_trailing_blankline_indent             = false,
        show_first_indent_level                    = true,
        max_indent_increase                        = 1,
        viewport_buffer                            = 100,
        show_current_context                       = true,
        show_current_context_start                 = true,
        show_current_context_start_on_current_line = false,
        buftype_exclude  = { "terminal" },
        filetype_exclude = {
          "diff", "help", "markdown", "packer", "qf", "lspinfo", "checkhealth",
          "",
        },
        context_patterns = {
          -- defaults
          "class", "^func", "method", "^if", "while", "for", "with",
          "try", "except", "arguments", "argument_list", "object",
          "dictionary", "element", "table", "tuple",
          -- general
          "^arguments",
          -- go
          "^func_literal", "^import_declaration", "^const_declaration",
          "^var_declaration", "^short_var_declaration", "^type_declaration",
          "^expression_switch_statement", "^expression_case",
          -- bash
          "^case_statement", "^case_item",
          -- perl  # the TS implementation here isn't all that good
          "^block", "^package_statement", "^use_constant_statement",
          -- lua
          "^local_function",
        },
      }
    end,
  }

  use "gioele/vim-autoswap"
  use "farmergreg/vim-lastplace"

  use {
    "mhinz/vim-startify",
    config = function()
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_lists = {
        { type = "dir", header = { "   MRU " .. vim.fn.getcwd() } },
        { type = "sessions", header = { "   Sessions" } },
        { type = "files", header = { "   Files" } },
        { type = "bookmarks", header = { "   Bookmarks" } },
        { type = "commands", header = { "   Commands" } },
      }
    end,
  }

  use {
    "lfv89/vim-interestingwords",
    config = function()
      -- stylua: ignore
      vim.g.interestingWordsGUIColors = {
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
  use "AndrewRadev/splitjoin.vim" -- gS, gJ
  use "Konfekt/vim-unicode-homoglyphs" -- gy
  use "ntpeters/vim-better-whitespace"
  use "ojroques/vim-oscyank"

  use {
    "dstein64/nvim-scrollview",
    config = function()
      vim.g.scrollview_winblend = 75
      vim.g.scrollview_column = 1
    end,
  }

  use {
    "sidebar-nvim/sidebar.nvim",
    -- branch = "dev",
    config = function()
      local sidebar = require "sidebar-nvim"
      local opts = {
        open = false,
        sections = { "git", "diagnostics", "todos", "buffers", "symbols" },
        disable_closing_prompt = true,
      }
      sidebar.setup(opts)
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ss",
        [[<cmd>lua require "sidebar-nvim".toggle()<cr>]],
        l.map.defmap
      )
    end,
  }

  use {
    "simrat39/symbols-outline.nvim",
    requires = {
      "folke/which-key.nvim",
    },
    config = function()
      local wk = require "which-key"
      wk.register {
        ["<leader>"] = {
          t = {
            name = "+toggle",
            o = { "<cmd>SymbolsOutline<cr>", "Show Symbols" },
          },
        },
      }
      vim.g.symbols_outline = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 80,
        auto_close = true,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = "Pmenu",
        keymaps = { -- These keymaps can be a string or a table for multiple keys
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
      }
    end,
  }

  use "elihunter173/dirbuf.nvim"
  use {
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("nvim-tree").setup {
        update_to_buf_dir = { enable = false },
      }
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "n",
        "<leader>st",
        [[<cmd>lua require "nvim-tree".toggle()<cr>]],
        l.map.defmap
      )
    end,
  }

  use {
    "edluffy/specs.nvim",
    config = function()
      local specs = require "specs"
      specs.setup {
        show_jumps = true,
        min_jump = 5,
        popup = {
          delay_ms = 0, -- delay before popup displays
          inc_ms = 5, -- time increments used for fade/resize effects
          blend = 10, -- starting blend, between 0-100, see :h winblend
          width = 40,
          winhl = "ScrollView",
          fader = specs.linear_fader,
          resizer = specs.shrink_resizer,
        },
        ignore_filetypes = {},
        ignore_buftypes = { nofile = true },
      }
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "n",
        "ä",
        [[<cmd>lua require "specs".show_specs()<cr>]],
        l.map.defmap
      )
    end,
  }

  use {
    "iamcco/markdown-preview.nvim",
    config = function()
      vim.call "mkdp#util#install"
      local l = require "local_defs"
      vim.api.nvim_set_keymap(
        "n",
        "<leader>d",
        [[<cmd>MarkdownPreviewToggle<cr>]],
        l.map.defmap
      )
    end,
    cmd = "MarkdownPreviewToggle",
    ft = { "markdown" },
  }
end)
