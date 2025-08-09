--# selene: allow(mixed_table)

vim.g.mapleader = ","
vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local exists = vim.fn.isdirectory(lazypath) == 1
if not exists then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
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
      require("catppuccin").setup({
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
          gitsigns = true,
          indent_blankline = true,
          mason = true,
          notify = true,
          nvimtree = true,
          overseer = true,
          symbols_outline = true,
          treesitter = true,
          which_key = true,
          telescope = {
            enabled = true,
          },
        },
        custom_highlights = function(col)
          return {
            CmpItemKindCodeium = { fg = col.lavender },
            CmpItemKindCopilot = { fg = col.peach },
            CmpItemKindSupermaven = { fg = col.teal },
            CurSearch = { bg = col.surface2, fg = col.yellow },
            Cursor = { bg = c.llyellow },
            CursorColumn = { bg = col.surface1 },
            CursorLine = { bg = col.surface1 },
            DiagnosticFloatingHint = { fg = c.blue },
            DiagnosticHint = { fg = c.blue },
            DiagnosticSignHint = { fg = c.blue },
            DiagnosticVirtualTextHint = { fg = c.blue },
            DiffAdded = { fg = c.rgreen },
            DiffRemoved = { fg = c.red },
            ExtraWhitespace = { bg = c.mred },
            GitSignsCurrentLineBlame = { bg = col.base, fg = c.dblue },
            GitSignsDeleteVirtLn = { bg = col.mantle, fg = c.mred },
            IblIndent1 = { fg = c.dblue },
            IblIndent2 = { fg = c.dviolet },
            IblScope = { fg = c.yellow },
            IncSearch = { bg = col.yellow, fg = col.surface1 },
            LineNr = { fg = c.dblue },
            LspDiagnosticsDefaultHint = { fg = c.blue },
            LspDiagnosticsHint = { fg = c.blue },
            LspDiagnosticsVirtualTextHint = { fg = c.blue },
            MarkviewPalette1 = { fg = c.lred, bg = col.base },
            MarkviewPalette1Bg = { fg = col.base },
            MarkviewPalette1Fg = { fg = c.lred },
            MarkviewPalette1Sign = { fg = c.lred },
            MarkviewPalette2 = { fg = c.lyellow, bg = col.base },
            MarkviewPalette2Bg = { fg = col.base },
            MarkviewPalette2Fg = { fg = c.lyellow },
            MarkviewPalette2Sign = { fg = c.lyellow },
            MarkviewPalette3 = { fg = c.peach, bg = col.base },
            MarkviewPalette3Bg = { fg = col.base },
            MarkviewPalette3Fg = { fg = c.peach },
            MarkviewPalette3Sign = { fg = c.peach },
            MarkviewPalette4 = { fg = c.lgreen, bg = col.base },
            MarkviewPalette4Bg = { fg = col.base },
            MarkviewPalette4Fg = { fg = c.lgreen },
            MarkviewPalette4Sign = { fg = c.lgreen },
            MarkviewPalette5 = { fg = c.llblue, bg = col.base },
            MarkviewPalette5Bg = { fg = col.base },
            MarkviewPalette5Fg = { fg = c.llblue },
            MarkviewPalette5Sign = { fg = c.llblue },
            MarkviewPalette6 = { fg = c.lviolet, bg = col.base },
            MarkviewPalette6Bg = { fg = col.base },
            MarkviewPalette6Fg = { fg = c.lviolet },
            MarkviewPalette6Sign = { fg = c.lviolet },
            MarkviewPalette7 = { fg = c.mviolet, bg = col.base },
            MarkviewPalette7Bg = { fg = col.base },
            MarkviewPalette7Fg = { fg = c.mviolet },
            MarkviewPalette7Sign = { fg = c.mviolet },
            MatchParen = { bg = col.blue, fg = col.base },
            Pmenu = { bg = c.dddred },
            PmenuSel = { bg = c.dred },
            Search = { bg = c.lyellow, fg = col.surface1 },
            -- SpellBad = { bg = col.base, fg = c.dorange },
            SpellCap = { bg = c.blue, fg = col.base },
            SpellLocal = { bg = c.green, fg = col.base },
            SpellRare = { bg = c.yellow, fg = col.base },
            TabLine = { bg = col.base, fg = col.overlay1 },
            VertSplit = { bg = col.base, fg = c.yellow },
            Visual = { bg = c.dred, fg = c.base1 },
            Whitespace = { fg = c.red },
            ["@text.danger"] = { bg = col.base, fg = c.red, bold = true },
            ["@text.note"] = { bg = col.base, fg = col.blue, bold = true },
            ["@text.todo"] = { bg = col.base, fg = col.yellow, bold = true },
            ["@text.warning"] = { bg = col.base, fg = c.yellow, bold = true },
            TreesitterContext = { bg = col.surface1 },
          }
        end,
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },

  { "nvim-lua/plenary.nvim" },
  { "kkharji/sqlite.lua" },

  {
    "SmiteshP/nvim-navic",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      separator = " >",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
      click = true,
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("statusline")
    end,
  },

  {
    "folke/which-key.nvim",
    version = "*",
    opts = {
      win = {
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
    },
  },

  {
    "OXY2DEV/markview.nvim", -- needs to be before treesitter
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local presets = require("markview.presets")
      require("markview").setup({
        preview = {
          -- filetypes = { "markdown", "codecompanion" },
          ignore_buftypes = {},
          modes = { "n" },
        },
        markdown = {
          checkboxes = presets.checkboxes.nerd,
          headings = presets.headings.slanted,
          horizontal_rules = presets.horizontal_rules.double,
          tables = presets.tables.rounded,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
      "windwp/nvim-ts-autotag",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        highlight = {
          enable = true,
          disable = {},
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<F53>", -- option-f5
            scope_incremental = "<F55>", -- option-f7
            node_incremental = "<F53>", -- option-f5
            node_decremental = "<F54>", -- option-f6
          },
        },
        refactor = {
          highlight_definitions = { enable = true },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to the text object
            keymaps = {
              -- Custom text object for comments
              ["ia"] = "@comment.inner", -- Select inner part of a comment
              ["aa"] = "@comment.outer", -- Select outer part of a comment
            },
            include_surrounding_whitespace = false,
          },
        },
        autotag = {
          enable = true, -- closes tags automatically (eq html)
        },
      })
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      })
    end,
  },

  {
    "chrisgrieser/nvim-various-textobjs",
    event = "UIEnter",
    keymaps = { useDefaults = true },
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = true,
        ts_context_commentstring_module = true,
      })
    end,
  },

  {
    "terrortylor/nvim-comment",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("nvim_comment").setup({
        line_mapping = "-",
        comment_empty = false,
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      })
      local l = require("local_defs")
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
    version = "*",
    config = function()
      local notify = require("notify")
      vim.notify = notify
      notify.setup({
        background_colour = require("local_defs").colour.base03,
        top_down = false,
      })
    end,
  },
  {
    "mrded/nvim-lsp-notify",
    dependencies = { "rcarriga/nvim-notify" },
    config = function()
      require("lsp-notify").setup({})
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
      require("nvim-lightbulb").setup({
        autocmd = { enabled = true },
        sign = {
          enabled = false,
          priority = 1,
        },
        virtual_text = {
          enabled = true,
        },
      })
    end,
  },

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
      local lint = require("lint")
      lint.linters_by_ft = {
        -- docker = { "hadolint" },
        html = { "tidy" },
        javascript = { "eslint" },
        json = { "jsonlint" },
        markdown = { "markdownlint" },
        rst = { "rstlint" },
        yaml = { "yamllint" },
        zsh = { "zsh" },
      }

      local codespell_args = { "--builtin", "clear,rare,informal,usage,names" }
      local found =
        vim.fs.find(".codespell", { upward = true, path = vim.fn.getcwd() })[1]
      if found then
        vim.list_extend(codespell_args, { "-I", found })
      end
      vim.list_extend(codespell_args, { "--stdin-single-line", "-" })
      lint.linters.codespell.args = codespell_args

      vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufReadPost",
        "BufWritePost",
        "CursorHold",
      }, {
        callback = function()
          -- callback = function(ev)
          -- if ev.event == "CursorHold" then
          --   require("notify")(string.format("lint: %s", ev.event))
          -- end
          lint.try_lint()
          if vim.bo.filetype ~= "SidebarNvim" then
            lint.try_lint("codespell")
            lint.try_lint("typos")
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
        html = {},
        markdown = {},
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
      require("conform").setup({
        formatters_by_ft = {
          dockerfile = { "dprint" },
          javascript = { { "prettierd", "prettier" } }, -- run first
          json = { "fixjson" },
          lua = { "stylua" },
          markdown = { "markdownlint", "mdformat" },
          python = { "isort", "black" },
          sh = { "shellharden", "shellcheck", "shfmt" }, -- run sequentially
          bash = { "shellharden", "shellcheck", "shfmt" }, -- run sequentially
          zsh = { "shellharden", "shellcheck", "shfmt" }, -- run sequentially
          sql = { "sql_formatter" },
          terraform = { "terraform_fmt" },
          toml = { "taplo" },
          yaml = { "yamlfmt" }, -- yamlfix is too buggy
          ["*"] = { "codespell" },
        },
        log_level = vim.log.levels.DEBUG,
      })

      require("conform.formatters.mdformat").args = {
        "--number",
        "-",
      }

      require("conform.formatters.shellcheck").args = {
        "--shell=bash",
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
  { "chrisgrieser/nvim-rulebook" },

  {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_ctags_exclude =
        require("local_defs").fn.gutentags_ctags_exclude()
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
      require("go").setup({
        goimports = "goimports",
        gofmt_args = {
          "--max-len=80",
          "--tab-len=2",
          "--base-formatter=gofumpt",
        },
        -- log_path = vim.fn.expand("$HOME") .. "/g/tmp/gonvimx.log",
        log_path = "/tmp/gonvim.log",
        lsp_cfg = false,
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
      })
    end,
  },

  {
    "nvim-neotest/neotest",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-go",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require("neotest").setup({
        opts = {
          adapters = {
            require("neotest-go")({
              -- experimental = {
              --   test_table = true,
              -- },
              args = { "-count=1", "-timeout=60s" },
            }),
          },
        },
      })
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
    opts = {
      installation_path = vim.fn.stdpath("data") .. "/dapinstall/",
    },
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
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "debugloop/telescope-undo.nvim",
      "isak102/telescope-git-file-history.nvim",
      "allaman/emoji.nvim",
      "danielfalk/smart-open.nvim",
      "AckslD/nvim-neoclip.lua",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
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
            ignore_patterns = require("local_defs").fn.frecency_ignore_patterns(),
            default_workspace = "CWD",
            use_sqlite = false,
            auto_validate = false,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("refactoring")
      telescope.load_extension("undo")
      telescope.load_extension("frecency")
      telescope.load_extension("git_file_history") -- ^G - open in browser
      telescope.load_extension("emoji")
      telescope.load_extension("smart_open")
      telescope.load_extension("ui-select")

      vim.cmd([[
        augroup telescope
          autocmd!
          autocmd User TelescopePreviewerLoaded setlocal number tabstop=2
        augroup end
      ]])
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua", module = "sqlite" },
    opts = {
      enable_persistent_history = true,
      db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      default_register = '"',
    },
  },
  {
    "stevearc/dressing.nvim",
    version = "*",
  },
  { "gabrielpoca/replacer.nvim" },
  {
    "kevinhwang91/nvim-bqf",
    opts = {
      preview = {
        win_height = 30,
        winblend = 0,
      },
      func_map = {
        vsplit = "<C-s>",
      },
      filter = {
        fzf = {
          action_for = { ["ctrl-s"] = "vsplit" },
          extra_opts = {
            "--bind",
            "ctrl-o:toggle-all",
            "--inline-info",
          },
        },
      },
    },
  },
  {
    "yorickpeterse/nvim-pqf",
    config = function()
      require("pqf").setup({})
    end,
  },
  { "junegunn/fzf" },

  -- magazine sources
  { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
  { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
  { "iguanacucumber/mag-buffer", name = "cmp-buffer" },
  { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },

  {
    -- "hrsh7th/nvim-cmp",
    "iguanacucumber/magazine.nvim", -- includes performance and other PRs
    -- name = "nvim-cmp", -- Otherwise highlighting gets messed up
    dependencies = {
      -- "hrsh7th/cmp-nvim-lsp",  # magazine
      -- "hrsh7th/cmp-nvim-lua",  # magazine
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      -- "hrsh7th/cmp-buffer",  # magazine
      "petertriho/cmp-git",
      -- "hrsh7th/cmp-path",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-calc",
      -- "hrsh7th/cmp-emoji",
      "allaman/emoji.nvim",
      "chrisgrieser/cmp-nerdfont",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "quangnguyen30192/cmp-nvim-tags",
      "andersevenrud/cmp-tmux",
      "onsails/lspkind-nvim",
      "rafamadriz/friendly-snippets",
      "uga-rosa/cmp-dictionary",
      -- "hrsh7th/cmp-cmdline",  # magazine
      -- "tzachar/cmp-ai",
    },
    config = function()
      require("cmp_nvim_lsp").setup({})
      local cmp = require("cmp")
      local lspkind = require("lspkind")
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
          Copilot       = "",
          Supermaven    = "",
          gemini        = "",
        }
      })
      -- stylua: ignore end

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api
              .nvim_buf_get_lines(0, line - 1, line, true)[1]
              :sub(col, col)
              :match("%s")
            == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(key, true, true, true),
          mode,
          true
        )
      end

      require("cmp_dictionary").setup({
        first_case_insensitive = true,
        paths = {
          vim.fn.expand("~/g/base/dict/en.dict"),
          -- vim.fn.expand("~/g/base/dict/de.dict"),
        },
      })

      -- local buf_is_big = function(bufnr)
      --   local max_filesize = 120 * 1024 -- 120 KB
      --   local ok, stats =
      --     pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      --   if ok and stats and stats.size > max_filesize then
      --     return true
      --   else
      --     return false
      --   end
      -- end

      local default_sources = {
        { name = "nvim_lua" },
        { name = "nvim_lsp_signature_help" },
        vim.env.ENABLE_AI_PLUGINS and vim.env.OPENAI_API_KEY and {
          name = "copilot",
        } or {},
        vim.env.ENABLE_AI_PLUGINS and vim.env.OPENAI_API_KEY and {
          name = "supermaven",
        } or {},
        vim.env.ENABLE_AI_PLUGINS and vim.env.OPENAI_API_KEY and {
          name = "codeium",
        } or {},
        vim.env.ENABLE_AI_PLUGINS and vim.env.GEMINI_API_KEY and {
          name = "minuet",
        } or {},
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
        { name = "async_path" },
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
        { name = "nerdfont" },
        { name = "emoji" },
        {
          name = "dictionary",
          keyword_length = 2,
          max_item_count = 10,
        },
        { name = "cmdline" },
      }

      vim.api.nvim_create_autocmd("BufReadPre", {
        callback = function()
          cmp.setup.buffer({
            sources = default_sources,
          })
        end,
        -- callback = function(t)
        --   local sources = default_sources
        --   if buf_is_big(t.buf) then
        --     local next_index = nil
        --     for i, source in ipairs(sources) do
        --       if source.name == "copilot" then
        --         next_index = i + 1
        --         break
        --       end
        --     end
        --     if next_index then
        --       table.remove(sources, next_index)
        --     end
        --   end
        --   -- for i, source in ipairs(default_sources) do
        --   --   print(i, source.name)
        --   -- end
        --   cmp.setup.buffer({
        --     sources = sources,
        --   })
        -- end,
      })

      local hl = "Normal:Normal,FloatBorder:Float,CursorLine:Visual,Search:None"

      cmp.setup({
        min_length = 1,
        preselect = cmp.PreselectMode.None,
        performance = {
          fetching_timeout = 3000,
          debounce = 100,
          throttle = 300,
          max_view_entries = 15,
        },
        formatting = {
          format = lspkind.cmp_format({
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
          }),
        },
        experimental = {
          native_menu = false,
          ghost_text = true,
        },
        mapping = {
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<C-S-Right>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local gt = cmp.core.view.ghost_text_view
              local c = require("cmp.config").get().experimental.ghost_text
              if c and gt.entry then
                local _, col = unpack(vim.api.nvim_win_get_cursor(0))
                local line = vim.api.nvim_get_current_line()
                local text = gt.text_gen(gt, line, col)
                if #text > 0 then
                  local next_char = text:sub(1, 1)
                  feedkey(next_char, "n")
                  return
                end
              end
            end
            fallback()
          end, { "i", "s" }),
          ["<C-x>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              return cmp.complete_common_string()
            end
            fallback()
          end, { "i", "s" }),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
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
          completion = cmp.config.window.bordered({
            winhighlight = hl,
            col_offset = 10,
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = hl,
          }),
        },
      })

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
    "allaman/emoji.nvim",
    version = "*",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      enable_cmp_integration = true,
    },
  },

  { -- TODO - consider https://github.com/monkoose/neocodeium
    "Exafunction/codeium.nvim",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({})
    end,
  },

  {
    "supermaven-inc/supermaven-nvim",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    config = function()
      require("supermaven-nvim").setup({
        disable_inline_completion = true,
        disable_keymaps = true,
      })
    end,
  },

  -- {
  --   "pasky/claude.vim",
  --   config = function()
  --     vim.g.claude_api_key = os.getenv("ANTHROPIC_API_KEY")
  --   end,
  -- },

  {
    "zbirenbaum/copilot.lua",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      copilot_model = "claude-sonnet-4",
      filetypes = {
        ["*"] = true, -- enable copilot for all filetypes
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  { "AndreM222/copilot-lualine" },
  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
  --   -- branch = "canary",
  --   version = "*",
  --   dependencies = {
  --     { "zbirenbaum/copilot.lua" },
  --     { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  --   },
  --   build = "make tiktoken", -- Only on MacOS or Linux
  --   opts = { debug = false },
  -- },
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
  --   event = "VeryLazy",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "folke/trouble.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  --   config = function()
  --     require("chatgpt").setup({
  --       -- openai_params = {
  --       --   model = "gpt-4-32k",
  --       --   frequency_penalty = 0,
  --       --   presence_penalty = 0,
  --       --   max_tokens = 2000,
  --       --   temperature = 0,
  --       --   top_p = 1,
  --       --   n = 1,
  --       -- },
  --       -- openai_edit_params = {
  --       --   model = "gpt-4-32k",
  --       --   frequency_penalty = 0,
  --       --   presence_penalty = 0,
  --       --   temperature = 0,
  --       --   top_p = 1,
  --       --   n = 1,
  --       -- },
  --     })
  --   end,
  -- },

  -- {
  --   "dense-analysis/neural",
  --   enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "ElPiloto/significant.nvim",
  --   },
  --   config = function()
  --     require("neural").setup({
  --       source = {
  --         openai = {
  --           -- model = "gpt-3.5-turbo-instruct",
  --           max_tokens = 2048,
  --           api_key = vim.env.OPENAI_API_KEY,
  --         },
  --       },
  --     })
  --   end,
  -- },

  -- {
  --   "frankroeder/parrot.nvim",
  --   enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
  --   version = "*",
  --   dependencies = {
  --     "ibhagwan/fzf-lua",
  --     "nvim-lua/plenary.nvim",
  --     "rcarriga/nvim-notify",
  --   },
  --   config = function()
  --     require("parrot").setup({
  --       -- Providers must be explicitly added to make them available.
  --       providers = {
  --         openai = {
  --           api_key = os.getenv("OPENAI_API_KEY"),
  --           endpoint = "https://api.openai.com/v1",
  --         },
  --         anthropic = {
  --           api_key = os.getenv("ANTHROPIC_API_KEY"),
  --           endpoint = "https://api.anthropic.com/v1",
  --         },
  --         gemini = {
  --           api_key = os.getenv("GEMINI_API_KEY"),
  --           endpoint = "https://generativelanguage.googleapis.com/v1",
  --         },
  --       },
  --       chat_conceal_model_params = false,
  --       hooks = {
  --         Complete = function(prt, params)
  --           local template = [[
  --             I have the following code from {{filename}}:

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Please finish the code above carefully and logically.
  --             Respond just with the snippet of code that should be inserted."
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  --         end,
  --         CompleteFullContext = function(prt, params)
  --           local template = [[
  --             I have the following code from {{filename}}:

  --             ```{{filetype}}
  --             {filecontent}}
  --             ```
  --             Please look at the following section specifically:

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Please finish the code above carefully and logically.
  --             Respond just with the snippet of code that should be inserted."
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  --         end,
  --         CompleteMultiContext = function(prt, params)
  --           local template = [[
  --             I have the following code from {{filename}} and other related files:

  --             ```{{filetype}}
  --             {{multifilecontent}}
  --             ```
  --             Please look at the following section specifically:

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Please finish the code above carefully and logically.
  --             Respond just with the snippet of code that should be inserted."
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  --         end,
  --         Explain = function(prt, params)
  --           local template = [[
  --             Your task is to take the code snippet from {{filename}} and
  --             explain it with gradually increasing complexity. Break down the
  --             code's functionality, purpose, and key components. The goal is to
  --             help the reader understand what the code does and how it works.

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Use the markdown format with codeblocks and inline code.
  --             Explanation of the code above:
  --           ]]
  --           local model = prt.get_model("chat")
  --           prt.logger.info("Explaining selection with model: " .. model.name)
  --           prt.Prompt(params, prt.ui.Target.new, model, nil, template)
  --         end,
  --         FixBugs = function(prt, params)
  --           local template = [[
  --             You are an expert in {{filetype}}.
  --             Fix bugs in the below code from {{filename}} carefully and
  --             logically. Your task is to analyse the provided {{filetype}} code
  --             snippet, identify any bugs or errors present, and provide a
  --             corrected version of the code that resolves these issues. Explain
  --             the problems you found in the original code and how your fixes
  --             address them. The corrected code should be functional, efficient,
  --             and adhere to best practices in {{filetype}} programming.

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Fixed code:
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.logger.info(
  --             "Fixing bugs in selection with model: " .. model_obj.name
  --           )
  --           prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
  --         end,
  --         Optimise = function(prt, params)
  --           local template = [[
  --             You are an expert in {{filetype}}.
  --             Your task is to analyse the provided {{filetype}} code snippet and
  --             suggest improvements to optimise its performance. Identify areas
  --             where the code can be made more efficient, faster, or less
  --             resource-intensive. Provide specific suggestions for optimisation,
  --             along with explanations of how these changes can enhance the
  --             code's performance. The optimised code should maintain the same
  --             functionality as the original code while demonstrating improved

  --             efficiency.

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Optimised code:
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.logger.info(
  --             "Optimising selection with model: " .. model_obj.name
  --           )
  --           prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
  --         end,
  --         UnitTests = function(prt, params)
  --           local template = [[
  --             I have the following code from {{filename}}:

  --             ```{{filetype}}
  --             {{selection}}
  --             ```

  --             Please respond by writing table driven unit tests for the code
  --             above.
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.logger.info(
  --             "Creating unit tests for selection with model: " .. model_obj.name
  --           )
  --           prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
  --         end,
  --         Debug = function(prt, params)
  --           local template = [[
  --             I want you to act as {{filetype}} expert.
  --             Review the following code, carefully examine it, and report
  --             potential bugs and edge cases alongside solutions to resolve
  --             them. Keep your explanation short and to the point:

  --             ```{{filetype}}
  --             {{selection}}
  --             ```
  --           ]]
  --           local model_obj = prt.get_model("command")
  --           prt.logger.info(
  --             "Debugging selection with model: " .. model_obj.name
  --           )
  --           prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
  --         end,
  --         CommitMsg = function(prt, params)
  --           local futils = require("parrot.file_utils")
  --           if futils.find_git_root() == "" then
  --             prt.logger.warning("Not in a git repository")
  --             return
  --           else
  --             local template = [[
  --               I want you to act as a commit message generator. I will provide
  --               you with information about the task and the prefix for the task
  --               code, and I would like you to generate an appropriate commit
  --               message using the conventional commit format. Do not write any
  --               explanations or other words, just reply with the commit
  --               message. Start with a short headline as summary but then list
  --               the individual changes in more detail.

  --               Here are the changes that should be considered by this message:
  --             ]] .. vim.fn.system(
  --               "git diff --no-color --no-ext-diff --staged"
  --             )
  --             local model_obj = prt.get_model("command")
  --             prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  --           end
  --         end,
  --         SpellCheck = function(prt, params)
  --           local chat_prompt = [[
  --             Your task is to take the text provided and rewrite it into a
  --             clear, grammatically correct version while preserving the original
  --             meaning as closely as possible. Correct any spelling mistakes,
  --             punctuation errors, verb tense issues, word choice problems, and
  --             other grammatical mistakes.
  --           ]]
  --           prt.ChatNew(params, chat_prompt)
  --         end,
  --         CodeConsultant = function(prt, params)
  --           local chat_prompt = [[
  --             Your task is to analyse the provided {{filetype}} code and suggest
  --             improvements to optimise its performance. Identify areas where the
  --             code can be made more efficient, faster, or less
  --             resource-intensive. Provide specific suggestions for optimisation,
  --             along with explanations of how these changes can enhance the
  --             code's performance. The optimised code should maintain the same
  --             functionality as the original code while demonstrating improved
  --             efficiency.

  --             Here is the code
  --             ```{{filetype}}
  --             {{filecontent}}
  --             ```
  --           ]]
  --           prt.ChatNew(params, chat_prompt)
  --         end,
  --         ProofReader = function(prt, params)
  --           local chat_prompt = [[
  --             I want you to act as a proofreader. I will provide you with texts
  --             and I would like you to review them for any spelling, grammar, or
  --             punctuation errors. Once you have finished reviewing the text,
  --             provide me with any necessary corrections or suggestions to
  --             improve the text. Highlight the corrected fragments (if any) using
  --             markdown backticks. Use British English spelling and grammar.

  --             When you have done that subsequently provide me with a slightly
  --             better version of the text, but keep close to the original text.

  --             Finally provide me with an ideal version of the text.

  --             Whenever I provide you with text, you reply in this format
  --             directly:

  --             ## Corrected text:

  --             {corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there
  --             are no corrections made}

  --             ## Slightly better text

  --             {slightly better text}

  --             ## Ideal text

  --             {ideal text}
  --           ]]
  --           prt.ChatNew(params, chat_prompt)
  --         end,
  --       },
  --     })
  --   end,
  -- },

  {
    "olimorris/codecompanion.nvim",
    version = "*",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "claude37sonnet",
            tools = {
              opts = {
                wait_timeout = 600000, -- 10 minutes
                auto_submit_errors = true, -- Automatically submit errors to the LLM
                auto_submit_success = true, -- Automatically submit successful results to the LLM
                default_tools = {
                  "full_stack_dev",
                  "next_edit_suggestion",
                  -- "vectorcode",
                  "mcp",
                },
              },
            },
            keymaps = {
              completion = {
                modes = {
                  i = "<C-n>",
                },
              },
            },
          },
          inline = { adapter = "claude37sonnet" },
          cmd = { adapter = "claude37sonnet" },
        },
        display = {
          chat = {
            -- intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
            show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
            separator = "─", -- The separator between the different messages in the chat buffer
            show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
            show_settings = false, -- Show LLM settings at the top of the chat buffer?
            show_token_count = true, -- Show the token count for each response?
            start_in_insert_mode = true, -- Open the chat buffer in insert mode?
            border = "rounded", -- Add border styling
            window = {
              width = 120,
            },
          },
        },
        adapters = {
          claude4sonnet = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-sonnet-4",
                },
                -- max_tokens = {
                --   default = 81920,
                -- },
              },
            })
          end,
          claude37sonnet = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.7-sonnet",
                },
                -- max_tokens = {
                --   default = 81920,
                -- },
              },
            })
          end,
          gemini25 = function()
            return require("codecompanion.adapters").extend("gemini", {
              -- give this adapter a different name to differentiate it from the
              -- default gemini adapter
              name = "gemini25",
              schema = {
                model = {
                  default = "gemini-2.5-pro",
                  -- default = "gemini-2.5-pro-preview-06-05",
                },
                -- num_ctx = {
                --   default = 16384,
                -- },
                -- num_predict = {
                --   default = -1,
                -- },
              },
            })
          end,
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              show_result_in_chat = true, -- Show mcp tool results in chat
              make_vars = true, -- Convert resources to #variables
              make_slash_commands = true, -- Add prompts as /slash commands
            },
          },

          -- vectorcode = {
          --   opts = {
          --     add_tool = true,
          --     add_slash_command = true,
          --     ---@type VectorCode.CodeCompanion.ToolOpts
          --     tool_opts = {
          --       max_num = { chunk = -1, document = -1 },
          --       default_num = { chunk = 50, document = 10 },
          --       include_stderr = true,
          --       use_lsp = true,
          --       auto_submit = { ls = true, query = false },
          --       ls_on_start = true,
          --       no_duplicate = true,
          --       chunk_mode = false,
          --     },
          --   },
          -- },
        },
      })
      local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "CodeCompanionChatModel",
        group = group,
        callback = function(event)
          vim.api.nvim_buf_set_name(
            event.data.bufnr,
            string.format(
              "[CodeCompanion] %d (%s)",
              event.data.bufnr,
              event.data.model
            )
          )
        end,
      })
    end,
  },
  -- {
  --   "Davidyz/VectorCode",
  --   version = "*", -- optional, depending on whether you're on nightly or release
  --   build = "uv tool upgrade vectorcode", -- This helps keeping the CLI up-to-date
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   cmd = "VectorCode", -- if you're lazy-loading VectorCode
  --   config = function()
  --     require("vectorcode").setup({
  --       -- number of retrieved documents
  --       n_query = 3,
  --       -- number of retrieved chunks per document
  --       n_chunk = 50,
  --       -- whether to use the LSP server for code completion
  --       use_lsp = true,
  --       -- whether to include stderr in the results
  --       includeuse_lsp = true,
  --       -- whether to automatically submit the query when the LSP server is ready
  --       auto_submit = { ls = true, query = false },
  --       -- whether to run the LSP server on startup
  --       ls_on_start = true,
  --       -- whether to avoid duplicate results
  --       no_duplicate = true,
  --     })
  --   end,
  -- },
  {
    "milanglacier/minuet-ai.nvim",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
    config = function()
      local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
      local vectorcode_cacher = nil
      if has_vc then
        vectorcode_cacher = vectorcode_config.get_cacher_backend()
      end

      -- roughly equate to 2000 tokens for LLM
      local RAG_Context_Window_Size = 8000

      local gemini = {
        -- model = "gemini-1.5-flash",
        model = "gemini-2.0-flash",
        stream = true, -- streaming responses are generally faster
        system = {
          template = "{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}",
          repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
        },
        chat_input = {
          template = "{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}",
          repo_context = function(_, _, _)
            local prompt_message = ""
            print("Gemini repo context requested")
            if
              has_vc
              and vectorcode_cacher
              and vectorcode_cacher.query_from_cache
            then
              local cache_result = vectorcode_cacher.query_from_cache(0)
              if cache_result then
                for _, file in ipairs(cache_result) do
                  prompt_message = prompt_message
                    .. "<file_separator>"
                    .. file.path
                    .. "\n"
                    .. file.document
                end
              end
            end

            prompt_message =
              vim.fn.strcharpart(prompt_message, 0, RAG_Context_Window_Size)

            if prompt_message ~= "" then
              prompt_message = "<repo_context>\n"
                .. prompt_message
                .. "\n</repo_context>"
            end
            print("Gemini prompt message: " .. prompt_message)
            return prompt_message
          end,
        },
      }

      require("minuet").setup({
        provider = "gemini",
        provider_options = {
          -- gemini = gemini,
          provider_options = {
            gemini = {
              model = "gemini-2.0-flash",
              -- optional = {
              --   generationConfig = {
              --     maxOutputTokens = 256,
              --     -- When using `gemini-2.5-flash`, it is recommended to entirely
              --     -- disable thinking for faster completion retrieval.
              --     thinkingConfig = {
              --       thinkingBudget = 0,
              --     },
              --   },
              --   -- safetySettings = {
              --   --   {
              --   --     -- HARM_CATEGORY_HATE_SPEECH,
              --   --     -- HARM_CATEGORY_HARASSMENT
              --   --     -- HARM_CATEGORY_SEXUALLY_EXPLICIT
              --   --     category = "HARM_CATEGORY_DANGEROUS_CONTENT",
              --   --     -- BLOCK_NONE
              --   --     threshold = "BLOCK_ONLY_HIGH",
              --   --   },
              --   -- },
              -- },
            },
          },
        },
      })

      -- require("minuet").setup({
      --   provider = "gemini",
      --   provider_options = {
      --     gemini = {
      --       model = "gemini-1.5-flash", -- fastest Gemini model
      --       stream = true, -- streaming responses are generally faster
      --     },
      --   },
      -- })
    end,
    -- notify = debug,
  },
  {
    "ravitemer/mcphub.nvim",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "MCPHub", -- lazy load by default
    build = "npm install -g mcp-hub@latest",
    config = function()
      require("mcphub").setup({
        log = {
          level = vim.log.levels.DEBUG, -- DEBUG, INFO, WARN, ERROR
        },
        extensions = {
          avante = {
            auto_approve_mcp_tool_calls = false, -- auto approve mcp tool calls
          },
        },
      })
    end,
  },
  {
    "yetone/avante.nvim",
    enabled = vim.env.ENABLE_AI_PLUGINS ~= nil,
    event = "VeryLazy",
    version = false, -- never set this to "*"
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- the below dependencies are optional
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      "ravitemer/mcphub.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
      -- {
      --   -- support for image pasting
      --   "HakonHarnes/img-clip.nvim",
      --   event = "VeryLazy",
      --   opts = {
      --     -- recommended settings
      --     default = {
      --       embed_image_as_base64 = false,
      --       prompt_for_file_name = false,
      --       -- drag_and_drop = {
      --       --   insert_mode = true,
      --       -- },
      --       use_absolute_path = true, -- required for Windows
      --     },
      --   },
      -- },
    },
    opts = {
      provider = "copilot_claude_sonnet_4",
      providers = {
        copilot_claude_sonnet_3_7 = {
          __inherited_from = "copilot",
          model = "claude-3.7-sonnet",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 200000,
          },
        },
        copilot_claude_sonnet_4 = {
          __inherited_from = "copilot",
          model = "claude-sonnet-4",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 2000000,
          },
        },
        copilot_gemini = {
          __inherited_from = "copilot",
          model = "gemini-2.5-pro",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 2097152,
          },
        },
        perplexity_llama_3_1_sonar_large_128k_online = {
          __inherited_from = "openai",
          api_key_name = "PPLX_API_KEY",
          endpoint = "https://api.perplexity.ai",
          model = "llama-3.1-sonar-large-128k-online",
          timeout = 60000,
          extra_request_body = {
            max_tokens = 128000,
          },
        },
        -- copilot = {
        --   -- -- https://codecompanion.olimorris.dev/usage/chat-buffer/agents#compatibility
        --   -- model = "claude-3.7-sonnet",  -- gives 400 error
        --   -- model = "claude-3.7-sonnet-thought",  -- gives 400 error
        --   model = "claude-sonnet-4",
        --   -- model = "gpt-4.1",
        --   -- model = "o1",
        --   -- model = "o4-mini",  -- not available
        --   -- model = "gemini-2.5-pro",  -- not available
        --   timeout = 60000,
        --   extra_request_body = {
        --     max_tokens = 200000, -- Maximum possible for Claude Sonnet 4
        --   },
        -- },
        -- gemini = {
        --   model = "gemini-2.5-pro",
        --   timeout = 60000,
        --   extra_request_body = {
        --     max_tokens = 2097152, -- 2M tokens (Gemini 2.5 Pro max context)
        --   },
        -- },
        -- openai = {
        --   -- endpoint = "https://api.openai.com/v1",
        --   model = "gpt-4o",
        --   timeout = 60000, -- timeout in milliseconds
        --   extra_request_body = {
        --     -- temperature = 0,
        --     max_tokens = 128000, -- Maximum context window for GPT-4o
        --     -- reasoning_effort = "medium", -- low|medium|high, for reasoning models
        --   },
        -- },
        -- perplexity = {
        --   __inherited_from = "openai",
        --   api_key_name = "PPLX_API_KEY",
        --   endpoint = "https://api.perplexity.ai",
        --   model = "llama-3.1-sonar-large-128k-online",
        --   extra_request_body = {
        --     max_tokens = 128000, -- Maximum context window for llama-3.1-sonar-large-128k-online
        --   },
        -- },
      },
      thinking = {
        type = "enabled",
        budget_tokens = 50000, -- Increased thinking budget for maximum reasoning
      },
      dual_boost = {
        enabled = false,
        first_provider = "copilot_claude_sonnet_3_7",
        second_provider = "copilot_gemini",
        timeout = 60000, -- timeout in milliseconds
      },
      rag_service = {
        enabled = false,
        host_mount = os.getenv("HOME") .. "/g",
        runner = "docker",
        llm = {
          provider = "ollama",
          endpoint = "http://host.docker.internal:11434",
          model = "qwen2.5-coder",
          -- model = "llama3",
          api_key = "",
        },
        embed = {
          provider = "ollama",
          endpoint = "http://host.docker.internal:11434",
          model = "mxbai-embed-large",
          -- model = "nomic-embed-text",
          api_key = "",
        },
      },

      {
        selector = { provider = "telescope" },
      },

      -- system_prompt as function ensures LLM always has latest MCP server
      -- state - evaluated for every message, even in existing chats.
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- using a function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
  },
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    dependencies = {
      {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
          -- bigfile = { enabled = true },
          -- dashboard = { enabled = true },
          -- explorer = { enabled = true },
          -- indent = { enabled = true },
          -- input = { enabled = true },
          picker = { enabled = true },
          -- notifier = { enabled = true },
          -- quickfile = { enabled = true },
          -- scope = { enabled = true },
          -- scroll = { enabled = true },
          -- statuscolumn = { enabled = true },
          -- words = { enabled = true },
        },
      },
      "catppuccin/nvim",
      "nvim-tree/nvim-tree.lua",
      {
        "nvim-neo-tree/neo-tree.nvim",
        optional = true,
        opts = function(_, opts)
          require("nvim_aider.neo_tree").setup(opts)
        end,
      },
    },
    config = function()
      require("nvim_aider").setup({
        args = {
          "--openai-api-base",
          "https://api.githubcopilot.com",
          "--openai-api-key",
          "$(op read op://Private/GitHub/copilot-api-key)",
          "--model",
          "openai/claude-sonnet-4",
          "--weak-model",
          "openai/claude-3.7-sonnet",
          -- "--model", "openai/gpt-4o",
          -- "--model", "openai/gpt-4.1",
          -- "--weak-model", "openai/gpt-4o-mini",
          -- "--model", "openai/gemini-2.5-pro",
          "--no-show-model-warnings",
          "--edit-format",
          "udiff",
          -- "--multiline",
          "--show-diffs",
        },
        -- args = {
        --   "--no-auto-commits",
        --   "--pretty",
        --   "--stream",
        -- },
        -- Automatically reload buffers changed by Aider (requires vim.o.autoread = true)
        auto_reload = true,
        -- Theme colors (automatically uses Catppuccin flavor if available)
        -- theme = {
        --   user_input_color = "#a6da95",
        --   tool_output_color = "#8aadf4",
        --   tool_error_color = "#ed8796",
        --   tool_warning_color = "#eed49f",
        --   assistant_output_color = "#c6a0f6",
        --   completion_menu_color = "#cad3f5",
        --   completion_menu_bg_color = "#24273a",
        --   completion_menu_current_color = "#181926",
        --   completion_menu_current_bg_color = "#f4dbd6",
        -- },
        -- -- snacks.picker.layout.Config configuration
        -- picker_cfg = {
        --   preset = "vscode",
        -- },
        -- -- Other snacks.terminal.Opts options
        -- config = {
        --   os = { editPreset = "nvim-remote" },
        --   gui = { nerdFontsVersion = "3" },
        -- },
        -- win = {
        --   wo = { winbar = "Aider" },
        --   style = "nvim_aider",
        --   position = "right",
        -- },
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    lazy = false,
    config = true,
    opts = {
      auto_start = true,
      terminal = {
        terminal_cmd = "~/.claude/local/claude",
        -- provider = "native",
        provider = {
          -- setup = function(config) end,
          -- open = function(cmd_string, env_table, effective_config, focus) end,
          -- close = function() end,
          -- simple_toggle = function(cmd_string, env_table, effective_config) end,
          -- focus_toggle = function(cmd_string, env_table, effective_config) end,
          setup = function() end,
          open = function() end,
          close = function() end,
          simple_toggle = function() end,
          focus_toggle = function() end,
          get_active_bufnr = function() end,
          is_available = function()
            return true
          end,
        },
        split_width_percentage = 0.4,
      },
    },
    keys = {
      {
        "<leader> ..",
        "<cmd>ClaudeCode<cr><cmd>horizontal wincmd =<cr>",
        desc = "Toggle Claude",
      },
      { "<leader> .f", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader> .r", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      {
        "<leader> .c",
        "<cmd>ClaudeCode --continue<cr>",
        desc = "Continue Claude",
      },
      {
        "<leader> .b",
        "<cmd>ClaudeCodeAdd %<cr>",
        desc = "Add current buffer",
      },
      {
        "<leader> .s",
        "<cmd>ClaudeCodeSend<cr>",
        mode = "v",
        desc = "Send to Claude",
      },
      {
        "<leader> .s",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader> .a", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader> .d", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
  {
    "pittcat/claude-fzf.nvim",
    dependencies = {
      "ibhagwan/fzf-lua",
      "coder/claudecode.nvim",
    },
    opts = {
      auto_context = true,
      batch_size = 10,
    },
    cmd = {
      "ClaudeFzf",
      "ClaudeFzfFiles",
      "ClaudeFzfGrep",
      "ClaudeFzfBuffers",
      "ClaudeFzfGitFiles",
      "ClaudeFzfDirectory",
    },
    keys = {
      { "<leader>cf", "<cmd>ClaudeFzfFiles<cr>", desc = "Claude: Add files" },
      {
        "<leader>cg",
        "<cmd>ClaudeFzfGrep<cr>",
        desc = "Claude: Search and add",
      },
      {
        "<leader>cb",
        "<cmd>ClaudeFzfBuffers<cr>",
        desc = "Claude: Add buffers",
      },
      {
        "<leader>cgf",
        "<cmd>ClaudeFzfGitFiles<cr>",
        desc = "Claude: Add Git files",
      },
      {
        "<leader>cd",
        "<cmd>ClaudeFzfDirectory<cr>",
        desc = "Claude: Add directory files",
      },
    },
  },
  {
    "pittcat/claude-fzf-history.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    config = function()
      require("claude-fzf-history").setup()
    end,
    cmd = { "ClaudeHistory", "ClaudeHistoryDebug" },
    keys = {
      { "<leader>ch", "<cmd>ClaudeHistory<cr>", desc = "Claude History" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
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
      word_diff = false,
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
      attach_to_untracked = false,
    },
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

  {
    "tpope/vim-fugitive",
    -- config = function()
    --   vim.api.nvim_command("autocmd User FugitiveChanged set cmdheight=0")
    -- end,
  },

  {
    "harrisoncramer/gitlab.nvim",
    version = "*",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "stevearc/dressing.nvim", -- Recommended. Better UI for pickers.
      "nvim-tree/nvim-web-devicons", -- Recommended. Icons in discussion tree.
    },
    enabled = true,
    build = function()
      require("gitlab.server").build(true)
    end, -- Builds the Go binary
    config = function()
      require("gitlab").setup({
        debug = { go_request = true, go_response = true },
        popup = { exit = "<leader>q" },
      })
    end,
  },

  {
    "brenoprata10/nvim-highlight-colors",
    config = function()
      vim.opt.termguicolors = true
      require("nvim-highlight-colors").setup({
        render = "background", -- background, foreground, virtual
        virtual_symbol = "■",
        enable_short_hex = false,
        enable_named_colors = true,
        enable_tailwind = true,
      })
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
        tab_char = "╏",
        highlight = { "IblIndent1", "IblIndent2" },
      },
      exclude = {
        filetypes = { "startify" },
      },
      scope = {
        show_exact_scope = true,
        include = {
          node_type = {
            go = { "import_declaration" },
            lua = { "return_statement", "table_constructor" },
          },
        },
      },
      whitespace = {
        remove_blankline_trail = true,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        callback = function()
          vim.cmd(":IBLEnable")
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
      require("hl_match_area").setup({
        n_lines_to_search = 500,
        highlight_in_insert_mode = true,
        delay = 500,
      })
    end,
  },

  {
    "cohama/lexima.vim",
    config = function()
      vim.cmd([[
        call lexima#add_rule({"char": '"', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": "'", "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '`', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '(', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '[', "at": '\%#\(\w\|\$\)'})
        call lexima#add_rule({"char": '{', "at": '\%#\(\w\|\$\)'})
      ]])
    end,
  },

  {
    "kylechui/nvim-surround",
    -- tag = "*",
    opts = {},
  },

  { "junegunn/vim-easy-align" }, -- ctrl-x for regexp
  { "machakann/vim-swap" }, -- g< g> gs
  { "tpope/vim-repeat" },
  { "Konfekt/vim-unicode-homoglyphs" }, -- gy
  { "superhawk610/ascii-blocks.nvim" }, -- :AsciiBlockify
  { "ojroques/vim-oscyank" },
  { "uga-rosa/translate.nvim" },
  { "chrisgrieser/nvim-spider" }, -- w moves in camelcase words
  -- { "kana/vim-textobj-user" },
  -- {
  --   "Julian/vim-textobj-variable-segment",
  --   dependencies = {
  --     "kana/vim-textobj-user",
  --   },
  -- },

  {
    "axieax/urlview.nvim", -- ,fU
    config = function()
      require("urlview").setup({
        default_picker = "telescope",
        default_action = "clipboard",
      })
    end,
  },

  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 80,
    },
  },

  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup({})
    end,
  },

  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup({})
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    config = function()
      local l = require("local_defs")
      local c = l.colour
      require("scrollbar").setup({
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
      })
      require("scrollbar.handlers.search").setup({})

      local set_default_link = function(group, target)
        vim.api.nvim_set_hl(0, group, { link = target, default = true })
      end

      set_default_link("HlSearchNear", "SpellCap")
      set_default_link("HlSearchLens", "SpellLocal")
      set_default_link("HlSearchLensNear", "SpellRare")
      set_default_link("HlSearchFloat", "Search")
    end,
  },

  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      local sidebar = require("sidebar-nvim")
      local opts = {
        open = false,
        sections = { "git", "diagnostics", "todos", "symbols" },
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
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    -- dependencies = { "folke/snacks.nvim", lazy = true },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<c-s>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-g>",
        replace_in_directory = "<c-r>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<c-d>",
      },
    },
  },

  {
    "hedyhli/outline.nvim",
    dependencies = {
      "folke/which-key.nvim",
    },
    config = function()
      require("outline").setup({
        outline_window = {
          position = "right",
          width = 60,
          relative_width = false,
          auto_close = true,
        },
      })
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("nvim-tree").setup({
        hijack_directories = { enable = false },
      })
    end,
  },

  {
    "aileot/emission.nvim", -- highlight additions and deletions
    event = "VeryLazy",
    opts = {
      highlight = {
        duration = 500,
      },
      added = {
        hl_map = {
          link = "Cursor",
        },
      },
    },
  },

  {
    "gen740/SmoothCursor.nvim",
    config = function()
      require("smoothcursor").setup({
        priority = 1,
        fancy = { enable = true },
        show_last_positions = "enter",
      })
      vim.fn.sign_define("smoothcursor_v", { text = " " })
      vim.fn.sign_define("smoothcursor_V", { text = "" })
      vim.fn.sign_define("smoothcursor_i", { text = "" })
      vim.fn.sign_define("smoothcursor_�", { text = "" })
      vim.fn.sign_define("smoothcursor_R", { text = "󰊄" })
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_echo_preview_url = 1
    end,
    ft = { "markdown" },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "Avante", "codecompanion" },
    },
    ft = { "Avante", "codecompanion" },
  },
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
  },

  {
    "RaafatTurki/hex.nvim",
    config = function()
      require("hex").setup({})
    end,
  },

  {
    "siadat/shell.nvim",
    opts = {},
  },

  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("smart-splits").setup({
        ignored_filetypes = {
          "nofile",
          "quickfix",
          "prompt",
        },
        ignored_buftypes = { "nofile" },
        default_amount = 3,
        at_edge = "wrap",
        cursor_follows_swapped_bufs = true,
      })
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
