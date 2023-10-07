vim.g.mapleader = ","
vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { "nvim-tree/nvim-web-devicons" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      local c = require("local_defs").colour
      require("catppuccin").setup {
        color_overrides = {
          all = {
            -- stylua: ignore start
            rosewater = c.c_rosewater,
            flamingo  = c.c_flamingo,
            pink      = c.c_pink,
            mauve     = c.c_mauve,
            red       = c.c_red,
            maroon    = c.c_maroon,
            peach     = c.c_peach,
            yellow    = c.c_yellow,
            green     = c.c_green,
            teal      = c.c_teal,
            sky       = c.c_sky,
            sapphire  = c.c_sapphire,
            blue      = c.c_blue,
            lavender  = c.c_lavender,
            text      = c.c_text,
            subtext1  = c.c_subtext1,
            subtext0  = c.c_subtext0,
            overlay2  = c.c_overlay2,
            overlay1  = c.c_overlay1,
            overlay0  = c.c_overlay0,
            surface2  = c.c_surface2,
            surface1  = c.c_surface1,
            surface0  = c.c_surface0,
            base      = c.c_base,
            mantle    = c.c_mantle,
            crust     = c.c_crust,
            -- stylua: ignore end
          },
        },
        integrations = {
          cmp = true,
          gitgutter = true,
          gitsigns = true,
          indent_blankline = true,
          mason = true,
          notify = true,
          nvimtree = true,
          overseer = true,
          symbols_outline = true,
          treesitter = true,
          which_key = true,
        },
        custom_highlights = function(col)
          return {
            Cursor = { bg = c.llyellow },
            CursorColumn = { bg = col.surface1 },
            CursorLine = { bg = col.surface1 },
            DiffAdded = { fg = c.rgreen },
            DiffRemoved = { fg = c.red },
            ExtraWhitespace = { bg = c.mred },
            GitSignsCurrentLineBlame = { bg = col.base, fg = c.dblue },
            GitSignsDeleteVirtLn = { bg = col.mantle, fg = c.mred },
            IblIndent = { fg = c.dred },
            IblScope = { fg = c.dorange },
            LineNr = { fg = c.dblue },
            MatchParen = { bg = col.blue, fg = col.base },
            -- MatchParenCur = { bg = col.base, fg = col.blue },
            Pmenu = { bg = c.dddred },
            PmenuSel = { bg = c.dred },
            SpellBad = { bg = col.base, fg = c.dorange },
            SpellCap = { bg = c.blue, fg = col.base },
            SpellLocal = { bg = c.green, fg = col.base },
            SpellRare = { bg = c.yellow, fg = col.base },
            TabLine = { bg = col.base, fg = col.overlay1 },
            Visual = { bg = c.dred, fg = c.base1 },
            ["@text.danger"] = { bg = col.base, fg = c.red, bold = true },
            ["@text.note"] = { bg = col.base, fg = col.blue, bold = true },
            ["@text.todo"] = { bg = col.base, fg = col.yellow, bold = true },
            ["@text.warning"] = { bg = col.base, fg = c.yellow, bold = true },
          }
        end,
      }

      vim.cmd.colorscheme "catppuccin"
    end,
  },

  { "nvim-lua/plenary.nvim" },

  {
    "SmiteshP/nvim-navic",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("nvim-navic").setup {
        separator = " >",
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true,
        click = true,
      }
    end,
  },

  {
    "freddiehaddad/feline.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      "SmiteshP/nvim-navic",
      "linrongbin16/lsp-progress.nvim",
    },
    config = function()
      require "statusline"
    end,
  },

  {
    "linrongbin16/lsp-progress.nvim",
    event = { "VimEnter" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lsp-progress").setup {}
    end,
  },

  {
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
          height = {
            max = 40,
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
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "windwp/nvim-ts-autotag",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        -- ensure_installed = "all",
        ignore_install = {
          "swift", -- requires glibc 2.28
          -- "perl", -- sometimes crashes
          "phpdoc", -- fails on MacOS
        },
        highlight = {
          enable = true,
          disable = {
            -- "perl",
            -- "sh",
            "gitcommit",
          },
        },
        indent = { enable = false },
        refactor = {
          highlight_definitions = { enable = true },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-F5>",
            scope_incremental = "<C-F7>",
            node_incremental = "<C-F5>",
            node_decremental = "<C-F6>",
          },
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        autotag = {
          enable = true,
        },
      }
      local parser_config =
        require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.perl = {
        install_info = {
          url = "https://github.com/tree-sitter-perl/tree-sitter-perl",
          revision = "release",
          files = { "src/parser.c", "src/scanner.c" },
        },
      }
    end,
  },

  {
    "terrortylor/nvim-comment",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
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
  },

  {
    "rcarriga/nvim-notify", -- ,fn
    config = function()
      local notify = require "notify"
      vim.notify = notify
      notify.setup { background_colour = require("local_defs").colour.base03 }
    end,
  },

  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim", version = "*" },
  { "ray-x/lsp_signature.nvim" },
  { "folke/lsp-colors.nvim" },
  {
    "kosayoda/nvim-lightbulb",
    dependencies = {
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      vim.cmd [[
        augroup lightbulb
          autocmd!
          autocmd CursorHold,CursorHoldI * lua require "nvim-lightbulb".update_lightbulb()
        augroup end
      ]]
      require("nvim-lightbulb").setup {
        sign = {
          enabled = false,
          priority = 1,
        },
        virtual_text = {
          enabled = true,
        },
      }
    end,
  },

  -- {
  --   "jose-elias-alvarez/null-ls.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   config = function()
  --     local null_ls = require "null-ls"
  --     local helpers = require "null-ls.helpers"

  --     local perl_diagnostics = {
  --       method = null_ls.methods.DIAGNOSTICS,
  --       filetypes = { "perl" },
  --       generator = null_ls.generator {
  --         command = vim.fn.expand "~/g/base/utils/lint_perlx",
  --         args = { "$FILENAME", "$ROOT", "$FILEEXT" },
  --         to_stdin = true,
  --         from_stderr = true,
  --         format = "json", --raw, json, or line
  --         check_exit_code = function(code, stderr)
  --           local success = code <= 1
  --           if not success then
  --             print(stderr)
  --           end
  --           return success
  --         end,
  --         on_output = helpers.diagnostics.from_json({
  --           attributes = {
  --             row = "row",
  --             -- col = "start_column",
  --             -- end_col = "end_column",
  --             -- severity = "annotation_level",
  --             message = "message",
  --           },
  --           -- severities = {
  --           --   helpers.diagnostics.severities["information"],
  --           --   helpers.diagnostics.severities["warning"],
  --           --   helpers.diagnostics.severities["error"],
  --           --   helpers.diagnostics.severities["hint"],
  --           -- },
  --         }),
  --       },
  --     }

  --     null_ls.register(perl_diagnostics)

  --     local b = null_ls.builtins
  --     local a = b.code_actions
  --     local c = b.completion
  --     local d = b.diagnostics
  --     local f = b.formatting
  --     local h = b.hover

  --     local codespell = { "--builtin", "clear,rare,informal,usage,names" }
  --     if vim.fn.filereadable(".codespell") == 1 then
  --       table.insert(codespell, "-I")
  --       table.insert(codespell, vim.fn.getcwd() .. "/.codespell")
  --     end

  --     local yamllint = { }
  --     if vim.fn.filereadable(".yamllint") == 1 then
  --       table.insert(yamllint, "-c")
  --       table.insert(yamllint, vim.fn.getcwd() .. "/.yamllint")
  --     end

  --     local sources = {
  --       a.eslint,
  --       -- a.gitsigns,
  --       a.proselint,
  --       -- a.refactoring,
  --       a.shellcheck,
  --       -- -- c.spell,  -- puts funny stuff in completion
  --       c.vsnip,
  --       d.codespell.with { extra_args = codespell },
  --       d.eslint,
  --       d.hadolint,
  --       d.jsonlint,
  --       d.markdownlint,
  --       d.misspell.with { extra_args = { "-i", "importas" } },
  --       d.proselint,
  --       d.selene,
  --       -- d.shellcheck,
  --       -- d.spectral,
  --       -- d.sqlfluff.with { extra_args = { "--dialect", "mysql" } },
  --       d.tidy,
  --       d.yamllint.with { extra_args = yamllint },
  --       d.zsh,
  --       -- f.beautysh,  -- not all that useful
  --       f.codespell.with { extra_args = codespell },
  --       f.eslint,
  --       f.fixjson,
  --       f.mdformat.with { extra_args = { "--number" } },
  --       -- f.golines,
  --       -- f.prettier,
  --       f.shellharden,
  --       f.shfmt.with { extra_args = { "-i", "2", "-s" } },
  --       -- f.sqlfluff.with { extra_args = { "--dialect", "mysql" } },
  --       f.sql_formatter,
  --       -- f.stylua,
  --       f.tidy,
  --       h.dictionary,
  --     }

  --     require "notify"("setup_null_ls")
  --     null_ls.setup {
  --       sources = sources,
  --       debounce = 2000,
  --       debug = true,
  --     }
  --   end,
  -- },
  { "jose-elias-alvarez/nvim-lsp-ts-utils" },
  -- {
  --   -- :lua vim.lsp.buf.incoming_calls()
  --   -- :lua vim.lsp.buf.outgoing_calls()
  --   "ldelossa/calltree.nvim",
  --   config = function()
  --     require "calltree".setup {}
  --   end,
  -- },

  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        docker = { "codespell", "typos", "hadolint" },
        html = { "codespell", "typos", "tidy" },
        javascript = { "codespell", "typos", "eslint" },
        json = { "codespell", "typos", "jsonlint" },
        lua = { "codespell", "typos", "selene" },
        markdown = { "codespell", "typos", "proselint", "markdownlint" },
        perl = { "codespell", "typos" },
        rst = { "codespell", "typos", "rstlint" },
        sh = { "codespell", "typos" },
        yaml = { "codespell", "typos", "yamllint" },
      }

      local codespell_args = { "--builtin", "clear,rare,informal,usage,names" }
      local found =
        vim.fs.find(".codespell", { upward = true, path = vim.fn.getcwd() })[1]
      if found then
        vim.list_extend(codespell_args, { "-I", found })
      end
      lint.linters.codespell.args = codespell_args

      local last_lint_time = 0
      vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufReadPost",
        "BufWritePost",
        "CursorHold",
      }, {
        callback = function(ev)
          local current_time = os.time()
          if current_time - last_lint_time >= 1 then
            last_lint_time = current_time
            require "notify"(string.format("lint: %s", ev.event))
            lint.try_lint()
          end
        end,
      })
    end,
  },
  {
    "dense-analysis/ale",
    config = function()
      vim.g.ale_linters_explicit = 0
      vim.g.ale_disable_lsp = "auto"
      vim.g.ale_use_neovim_diagnostics_api = 1
      vim.g.ale_virtualtext_cursor = 1
      vim.g.ale_linters = {
        -- go = { "gofmt", "golint", "gopls", "govet", "golangci-lint" },
        go = {},
        -- lua = {},
        perl = {},
        sh = {},
        yaml = { "spectral" },
      }
      -- vim.g.ale_fixers = {
      -- }
    end,
  },
  {
    "stevearc/conform.nvim",
    version = "*",
    opts = {},
    config = function()
      require("conform").setup {
        formatters_by_ft = {
          javascript = { { "prettierd", "prettier" } }, -- run first
          lua = { "stylua" },
          markdown = { "markdownlint", "mdformat" },
          python = { "isort", "black" },
          sh = { "shellharden", "shellcheck", "shfmt" }, -- run sequentially
          sql = { "sql_formatter" },
          toml = { "taplo" },
          terraform = { "terraform_fmt" },
          yaml = { "yamlfmt" }, -- yamlfix is too buggy
          ["*"] = { "codespell" },
        },
      }

      require("conform.formatters.mdformat").args = {
        "--number",
        "-",
      }

      require("conform.formatters.shfmt").args = {
        "-i",
        "2",
        "-s",
        "-filename",
        "$FILENAME",
      }

      local codespell_args = {
        "$FILENAME",
        "--write-changes",
        "--check-hidden", -- conform's temp file is hidden
        "--builtin",
        "clear,rare,informal,usage,names",
      }
      local found =
        vim.fs.find(".codespell", { upward = true, path = vim.fn.getcwd() })[1]
      if found then
        vim.list_extend(codespell_args, { "-I", found })
      end
      require("conform.formatters.codespell").args = codespell_args
    end,
  },

  {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_ctags_exclude = vim.g.gutentags_ctags_exclude or {}
      local ex = vim.g.gutentags_ctags_exclude
      local exclude = {
        "tmp",
        "blib",
        "node_modules",
        "dist",
      }
      for _, v in pairs(exclude) do
        table.insert(ex, v)
      end
      vim.g.gutentags_ctags_exclude = ex
      -- print(vim.inspect(vim.g.gutentags_ctags_exclude))

      -- can be extended with '*/sub/path' if required
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0

      local is_freebsd = (io.popen("uname"):read() == "FreeBSD")
      if is_freebsd then
        vim.g.gutentags_ctags_executable = "/usr/local/bin/uctags"
      end
    end,
  },

  {
    "ray-x/go.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "ray-x/guihua.lua", -- float term, codeaction and codelens gui support
      "leoluz/nvim-dap-go",
    },
    config = function()
      require("go").setup {
        goimport = "goimports",
        gofmt_args = {
          "--max-len=80",
          "--tab-len=2",
          "--base-formatter=gofumpt",
        },
        -- log_path = vim.fn.expand("$HOME") .. "/g/tmp/gonvimx.log",
        log_path = "/tmp/gonvim.log",
        lsp_cfg = false,
        lsp_diag_hdlr = false,
        lsp_fmt_async = true,
        lsp_gofumpt = true,
        -- max_line_len = 80, -- max line length in goline format
        null_ls_document_formatting_disable = true,
        verbose = true,
        -- luasnip = true,
        lsp_inlay_hints = {
          enable = true,

          -- Only show inlay hints for the current line
          only_current_line = false,

          -- Event which triggers a refersh of the inlay hints.
          -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
          -- not that this may cause higher CPU usage.
          -- This option is only respected when only_current_line and
          -- autoSetHints both are true.
          only_current_line_autocmd = "CursorHold",

          -- whether to show variable name before type hints with the inlay
          -- hints or not
          -- default: false
          show_variable_name = true,

          -- prefix for parameter hints
          parameter_hints_prefix = " ",
          show_parameter_hints = true,

          -- prefix for all the other hints (type, chaining)
          other_hints_prefix = "=> ",

          -- whether to align to the length of the longest line in the file
          max_len_align = true,

          -- padding from the left if max_len_align is true
          max_len_align_padding = 1,

          -- whether to align to the extreme right or not
          right_align = false,

          -- padding from the right if right_align is true
          right_align_padding = 6,

          -- The color of the hints
          highlight = "Comment",
        },
      }
    end,
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-go",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-go" {
            -- experimental = {
            --   test_table = true,
            -- },
            args = { "-count=1", "-timeout=60s" },
          },
        },
      }
    end,
  },

  {
    "vim-perl/vim-perl",
    build = "make clean carp dancer heredoc-sql highlight-all-pragmas "
      .. "js-css-in-mason method-signatures moose test-more try-tiny",
    config = function()
      vim.g.perl_highlight_data = 1
    end,
  },

  { "hashivim/vim-terraform" },
  { "towolf/vim-helm" },

  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local refactoring = require "refactoring"
      refactoring.setup {
        installation_path = vim.fn.stdpath "data" .. "/dapinstall/",
      }
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "make || gmake",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "protex/better-digraphs.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "debugloop/telescope-undo.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-frecency.nvim",
    },
    config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<c-s>"] = actions.select_vertical,
              ["<c-k>"] = actions.which_key,
            },
            n = {
              ["<c-s>"] = actions.select_vertical,
              ["<c-k>"] = actions.which_key,
            },
          },
          -- telescope prefers rg
          find_command = { "fd", "--type", "f", "--color", "never" },
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
        extensions = {
          fzf = {
            -- default options
            fuzzy = true,
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
          frecency = {
            show_scores = true,
            show_unindexed = true,
            -- ignore_patterns = { "*.git/*", "*/tmp/*" },
            -- disable_devicons = false,
            default_workspace = "CWD",
            use_sqlite = false,
            auto_validate = false,
          },
        },
      }

      telescope.load_extension "fzf"
      telescope.load_extension "refactoring"
      telescope.load_extension "undo"
      telescope.load_extension "frecency"

      vim.cmd [[
        augroup telescope
          autocmd!
          autocmd User TelescopePreviewerLoaded setlocal number
          autocmd User TelescopePreviewerLoaded setlocal tabstop=2
        augroup end
      ]]
    end,
  },
  { "stevearc/dressing.nvim" },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      "hrsh7th/cmp-buffer",
      "petertriho/cmp-git",
      -- "hrsh7th/cmp-path",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "chrisgrieser/cmp-nerdfont",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "quangnguyen30192/cmp-nvim-tags",
      "andersevenrud/cmp-tmux",
      "onsails/lspkind-nvim",
      "rafamadriz/friendly-snippets",
      "uga-rosa/cmp-dictionary",
      "hrsh7th/cmp-cmdline",
      -- "tzachar/cmp-ai",
    },
    config = function()
      require("cmp_nvim_lsp").setup {}
      local cmp = require "cmp"
      local lspkind = require "lspkind"
      local compare = cmp.config.compare

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
          TypeParameter = "",
          Codeium       = "",
        }
      })
      -- stylua: ignore end

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api
              .nvim_buf_get_lines(0, line - 1, line, true)[1]
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
        min_length = 1,
        preselect = cmp.PreselectMode.None,
        performance = {
          fetching_timeout = 500,
          debounce = 60,
          throttle = 30,
        },
        formatting = {
          format = lspkind.cmp_format {
            mode = "symbol_text",
            maxwidth = 80,
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
              dictionary = "dict",
            },
            before = function(entry, vim_item)
              vim_item.dup = ({
                nvim_lsp = 0,
                buffer = 0,
                tags = 0,
                path = 0,
                tmux = 0,
                dictionary = 0,
              })[entry.source.name] or 0
              return vim_item
            end,
          },
        },
        experimental = {
          native_menu = false,
          ghost_text = true,
          horizontal_search = true,
        },
        mapping = {
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          ["<C-x>"] = cmp.mapping.confirm { select = true },
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
          { name = "nvim_lua" },
          { name = "nvim_lsp_signature_help" },
          os.getenv "OPENAI_API_KEY" and { name = "codeium" } or {},
          -- { name = "cmp_ai" },
          { name = "nvim_lsp" },
          {
            name = "buffer",
            max_item_count = 10,
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
              -- keywords or just words
              keyword_pattern = [[\%(\k\+\|\w\+\)]],
            },
          },
          { name = "tags", max_item_count = 10 },
          { name = "path" },
          { name = "git" },
          {
            name = "tmux",
            max_item_count = 10,
            option = {
              all_panes = true,
              label = "[tmux]",
            },
          },
          { name = "calc" },
          { name = "emoji" },
          {
            name = "dictionary",
            keyword_length = 2,
            max_item_count = 10,
          },
        },
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        sorting = {
          priority_weight = 2.0,
          comparators = {
            compare.score,
            -- score = score +
            --  ((#sources - (source_index - 1)) * sorting.priority_weight)
            compare.locality,
            compare.recently_used,
            compare.scopes,
            compare.offset,
            compare.order,
            -- compare.score_offset,
            -- compare.sort_text,
            -- compare.exact,
            -- compare.kind,
            -- compare.length,
          },
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      }

      -- local cmp_ai = require('cmp_ai.config')

      -- cmp_ai:setup{
      --   max_lines = 1000,
      --   provider = "OpenAI",
      --   model = 'gpt-4',
      --   notify = true,
      --   notify_callback = function(msg)
      --     vim.notify(msg)
      --   end,
      --   run_on_every_keystroke = true,
      --   ignored_file_types = {
      --     -- default is not to ignore
      --     -- uncomment to ignore in lua:
      --     -- lua = true
      --   },
      -- }

      -- cmp_ai:setup({
      --   max_lines = 1000,
      --   provider = 'Bard',
      --   notify = true,
      --   notify_callback = function(msg)
      --     vim.notify(msg)
      --   end,
      --   run_on_every_keystroke = true,
      --   ignored_file_types = {
      --     -- default is not to ignore
      --     -- uncomment to ignore in lua:
      --     -- lua = true
      --   },
      -- })

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
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':'.
      -- cmp.setup.cmdline(":", {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources({
      --     { name = "path" },
      --   }, {
      --     { name = "cmdline" },  -- currently broken
      --   }),
      -- })
    end,
  },

  {
    -- "jcdickinson/codeium.nvim",
    "0xRichardH/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup {}
    end,
  },

  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup {
        edit_with_instructions = {
          diff = false,
          keymaps = {
            close = "<C-c>",
            accept = "<C-y>",
            toggle_diff = "<C-d>",
            toggle_settings = "<C-o>",
            cycle_windows = "<Tab>",
            use_output_as_input = "<C-u>",
          },
        },
        chat = {
          keymaps = {
            close = { "<C-c>" },
            yank_last = "<C-y>",
            yank_last_code = "<C-k>",
            scroll_up = "<C-u>",
            scroll_down = "<C-d>",
            new_session = "<C-n>",
            cycle_windows = "<Tab>",
            cycle_modes = "<C-f>",
            select_session = "<Space>",
            rename_session = "r",
            delete_session = "d",
            draft_message = "<C-d>",
            toggle_settings = "<C-o>",
            toggle_message_role = "<C-r>",
            toggle_system_role_open = "<C-s>",
            stop_generating = "<C-x>",
          },
        },
        popup_input = {
          submit = "<C-y>",
          submit_n = "<Enter>",
        },
        openai_params = {
          model = "gpt-4",
          frequency_penalty = 0,
          presence_penalty = 0,
          max_tokens = 3000,
          temperature = 0,
          top_p = 1,
          n = 1,
        },
      }
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup {
        signs = {
          add = { show_count = true, text = "+" },
          change = { show_count = true, text = "~" },
          delete = { show_count = true, text = "_" },
          topdelete = { show_count = true, text = "‾" },
          changedelete = { show_count = true, text = "~" },
        },
        numhl = true,
        linehl = false,
        watch_gitdir = { interval = 1000 },
        sign_priority = 6,
        update_debounce = 1000,
        status_formatter = nil, -- Use default
        diff_opts = { internal = true }, -- If luajit is present
        word_diff = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          ignore_whitespace = true,
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

          -- Text object
          map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
          map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      }
    end,
  },

  {
    "rhysd/git-messenger.vim",
    config = function()
      vim.g.git_messenger_always_into_popup = 1
      vim.g.git_messenger_include_diff = "current"
      vim.g.git_messenger_extra_blame_args = "-wMC"
      vim.g.git_messenger_floating_win_opts = { border = "single" }
    end,
  },

  { "rhysd/conflict-marker.vim" },
  { "sindrets/diffview.nvim" },

  {
    "ruanyl/vim-gh-line",
    config = function()
      vim.g.gh_use_canonical = 0
      vim.g.gh_trace = 1
    end,
  },

  { "tpope/vim-fugitive" },

  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- Recommended but not required. Better UI for pickers.
      enabled = true,
    },
    build = function()
      require("gitlab.server").build(true)
    end, -- Builds the Go binary
    config = function()
      require("gitlab").setup {} -- Uses delta reviewer by default
    end,
  },

  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      vim.opt.termguicolors = true
      require("colorizer").setup()
    end,
  },

  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "tami5/sqlite.lua", module = "sqlite" },
    config = function()
      require("neoclip").setup {
        enable_persistent_history = true,
        db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
        default_register = '"',
      }
    end,
  },

  { "zsugabubus/crazy8.nvim" },
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        highlight = { "IblIndent" },
      },
      exclude = {
        filetypes = { "startify" },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        callback = function(ev)
          vim.cmd ":IBLEnable"
          require "notify"(string.format("ibl: %s", ev.event))
        end,
      })
    end,
  },

  {
    "matze/vim-move",
    config = function()
      vim.g.move_map_keys = 0
    end,
  },

  { "gioele/vim-autoswap" },
  { "farmergreg/vim-lastplace" },

  {
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
  },

  {
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
  },

  {
    "rareitems/hl_match_area.nvim",
    config = function()
      require("hl_match_area").setup {
        n_lines_to_search = 500,
        highlight_in_insert_mode = true,
        delay = 500,
      }
    end,
  },

  {
    "cohama/lexima.vim",
    config = function()
      vim.cmd [[
        call lexima#add_rule({"char": '"', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": "'", "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '`', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '(', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '[', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '{', "at": '\%#\(\w\|\$\)'})
      ]]
    end,
  },

  {
    "kylechui/nvim-surround",
    -- tag = "*",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  { "junegunn/vim-easy-align" }, -- ctrl-x for regexp
  { "tpope/vim-repeat" },
  { "windwp/nvim-ts-autotag" },
  { "AndrewRadev/splitjoin.vim" }, -- gS, gJ
  { "Konfekt/vim-unicode-homoglyphs" }, -- gy
  { "superhawk610/ascii-blocks.nvim" }, -- :AsciiBlockify
  { "ntpeters/vim-better-whitespace" },
  { "ojroques/vim-oscyank" },
  { "uga-rosa/translate.nvim" },
  { "chrisgrieser/nvim-spider" },
  { "kana/vim-textobj-user" },
  {
    "Julian/vim-textobj-variable-segment",
    dependencies = {
      "vim-textobj-user",
    },
  },

  {
    "axieax/urlview.nvim", -- ,fu ,fU
    config = function()
      require("urlview").setup {
        default_picker = "telescope",
        default_action = "clipboard",
      }
    end,
  },

  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup {}
    end,
  },

  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup {}
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    config = function()
      local l = require "local_defs"
      local c = l.colour
      require("scrollbar").setup {
        handle = {
          color = c.ddblue,
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = true,
          handle = true,
          search = true,
          ale = true,
        },
        render = {
          "BufWinEnter",
          "TabEnter",
          "TermEnter",
          "WinEnter",
          "CmdwinLeave",
          -- "TextChanged",
          "VimResized",
          "WinScrolled",
          "CursorHold",
        },
        clear = {
          "BufWinLeave",
          "TabLeave",
          "TermLeave",
          "WinLeave",
        },
      }
      require("scrollbar.handlers.search").setup {}

      vim.cmd [[
        hi default link HlSearchNear SpellCap
        hi default link HlSearchLens SpellLocal
        hi default link HlSearchLensNear SpellRare
        hi default link HlSearchFloat Search
      ]]
    end,
  },

  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      local sidebar = require "sidebar-nvim"
      local opts = {
        open = false,
        sections = { "git", "diagnostics", "buffers", "symbols" },
        disable_closing_prompt = true,
      }
      sidebar.setup(opts)
    end,
  },

  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "simrat39/symbols-outline.nvim",
    dependencies = {
      "folke/which-key.nvim",
    },
    config = function()
      require("symbols-outline").setup {
        width = 40,
        auto_close = true,
        -- keymaps = { -- These keymaps can be a string or a table for multiple keys
        --   close = { "<Esc>", "q" },
        --   goto_location = "<Cr>",
        --   focus_location = "o",
        --   hover_symbol = "<C-space>",
        --   toggle_preview = "K",
        --   rename_symbol = "r",
        --   code_actions = "a",
        --   fold = "h",
        --   unfold = "l",
        --   fold_all = "W",
        --   unfold_all = "E",
        --   fold_reset = "R",
        -- },
      }
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("nvim-tree").setup {
        hijack_directories = { enable = false },
      }
    end,
  },

  {
    "edluffy/specs.nvim",
    config = function()
      local specs = require "specs"
      specs.setup {
        show_jumps = true,
        min_jump = 5,
        popup = {
          delay_ms = 0, -- delay before popup displays
          inc_ms = 5, -- time increments used for fade/resize effects
          blend = 30, -- starting blend, between 0-100, see :h winblend
          width = 60,
          winhl = "SpellRare",
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
  },

  {
    "tzachar/highlight-undo.nvim",
    config = function()
      require("highlight-undo").setup {
        hlgroup = "Cursor",
        duration = 1500,
      }
    end,
  },

  {
    "gen740/SmoothCursor.nvim",
    config = function()
      require("smoothcursor").setup {
        priority = 1,
      }
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    ft = "markdown",
  },

  {
    "RaafatTurki/hex.nvim",
    config = function()
      require("hex").setup {}
    end,
  },
}

local opts = {
  defaults = {
    lazy = false,
    -- version = "*",
  },
}

require("lazy").setup(plugins, opts)
require("lsp").setup_servers()

-- packer.startup(function(use)
--   use "mfussenegger/nvim-dap"
--   -- use {
--   --   "Pocco81/DAPInstall.nvim",
--   --   config = function()
--   --     local dap_install = require "dap-install"
--
--   --     dap_install.setup {
--   --       installation_path = vim.fn.stdpath "data" .. "/dapinstall/",
--   --     }
--
--   --     local dbg_list =
--   --       require "dap-install.api.debuggers".get_installed_debuggers()
--
--   --     for _, debugger in ipairs(dbg_list) do
--   --       dap_install.config(debugger)
--   --     end
--   --   end,
--   -- }
