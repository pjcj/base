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
    config = function()
      require("nvim-navic").setup({
        separator = " >",
        depth_limit = 0,
        depth_limit_indicator = "..",
        safe_output = true,
        click = true,
      })
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
      require("statusline")
    end,
  },

  {
    "linrongbin16/lsp-progress.nvim",
    event = { "VimEnter" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lsp-progress").setup({})
    end,
  },

  {
    "folke/which-key.nvim",
    version = "*",
    config = function()
      require("which-key").setup({
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
        ignore_install = {
          -- "swift", -- requires glibc 2.28
          -- "phpdoc", -- fails on MacOS
        },
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
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              -- You can optionally set descriptions to the mappings (used in
              -- the desc parameter of nvim_buf_set_keymap) which plugins like
              -- which-key display
              ["ic"] = {
                query = "@class.inner",
                desc = "Select inner part of a class region",
              },
              -- You can also use captures from other query groups like
              -- `locals.scm`
              ["as"] = {
                query = "@scope",
                query_group = "locals",
                desc = "Select language scope",
              },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ["@parameter.outer"] = "v", -- charwise
              ["@function.outer"] = "V", -- linewise
              ["@class.outer"] = "<c-v>", -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any
            -- textobject is extended to include preceding or succeeding
            -- whitespace. Succeeding whitespace has priority in order to act
            -- similarly to eg the built-in `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
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
      vim.cmd([[
        augroup lightbulb
          autocmd!
          autocmd CursorHold,CursorHoldI * lua require "nvim-lightbulb".update_lightbulb()
        augroup end
      ]])
      require("nvim-lightbulb").setup({
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
      local lint = require("lint")
      lint.linters_by_ft = {
        docker = { "hadolint" },
        html = { "tidy" },
        javascript = { "eslint" },
        json = { "jsonlint" },
        markdown = { "markdownlint" },
        rst = { "rstlint" },
        yaml = { "yamllint" },
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
          lint.try_lint("codespell")
          lint.try_lint("typos")
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
          zsh = { "shellharden", "shellcheck" }, -- run sequentially
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
        adapters = {
          require("neotest-go")({
            -- experimental = {
            --   test_table = true,
            -- },
            args = { "-count=1", "-timeout=60s" },
          }),
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
    config = function()
      local refactoring = require("refactoring")
      refactoring.setup({
        installation_path = vim.fn.stdpath("data") .. "/dapinstall/",
      })
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
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("refactoring")
      telescope.load_extension("undo")
      telescope.load_extension("frecency")
      telescope.load_extension("git_file_history") -- ^G - open in browser
      telescope.load_extension("emoji")
      telescope.load_extension("smart_open")

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
    config = function()
      require("neoclip").setup({
        enable_persistent_history = true,
        db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
        default_register = '"',
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    version = "*",
  },
  { "gabrielpoca/replacer.nvim" },
  {
    "kevinhwang91/nvim-bqf",
    config = function()
      require("bqf").setup({
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
      })
    end,
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
        vim.env.OPENAI_API_KEY and { name = "copilot" } or {},
        vim.env.OPENAI_API_KEY and { name = "supermaven" } or {},
        vim.env.OPENAI_API_KEY and { name = "codeium" } or {},
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
          fetching_timeout = 1000,
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
          ["<C-Right>"] = cmp.mapping(function(fallback)
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
    config = function()
      require("supermaven-nvim").setup({
        disable_inline_completion = true,
        disable_keymaps = true,
      })
    end,
  },

  {
    "pasky/claude.vim",
    config = function()
      vim.g.claude_api_key = os.getenv("CLAUDE_API_KEY")
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    version = "*",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = { debug = false },
  },

  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("chatgpt").setup({
        -- openai_params = {
        --   model = "gpt-4-32k",
        --   frequency_penalty = 0,
        --   presence_penalty = 0,
        --   max_tokens = 2000,
        --   temperature = 0,
        --   top_p = 1,
        --   n = 1,
        -- },
        -- openai_edit_params = {
        --   model = "gpt-4-32k",
        --   frequency_penalty = 0,
        --   presence_penalty = 0,
        --   temperature = 0,
        --   top_p = 1,
        --   n = 1,
        -- },
      })
    end,
  },

  {
    "dense-analysis/neural",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "ElPiloto/significant.nvim",
    },
    config = function()
      require("neural").setup({
        source = {
          openai = {
            -- model = "gpt-3.5-turbo-instruct",
            max_tokens = 2048,
            api_key = vim.env.OPENAI_API_KEY,
          },
        },
      })
    end,
  },

  {
    "frankroeder/parrot.nvim",
    version = "*",
    dependencies = {
      "ibhagwan/fzf-lua",
      "nvim-lua/plenary.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("parrot").setup({
        -- Providers must be explicitly added to make them available.
        providers = {
          openai = {
            api_key = os.getenv("OPENAI_API_KEY"),
          },
          anthropic = {
            api_key = os.getenv("CLAUDE_API_KEY"),
          },
        },
        chat_conceal_model_params = false,
        hooks = {
          Complete = function(prt, params)
            local template = [[
              I have the following code from {{filename}}:

              ```{{filetype}}
              {{selection}}
              ```

              Please finish the code above carefully and logically.
              Respond just with the snippet of code that should be inserted."
            ]]
            local model_obj = prt.get_model("command")
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end,
          CompleteFullContext = function(prt, params)
            local template = [[
              I have the following code from {{filename}}:

              ```{{filetype}}
              {filecontent}}
              ```
              Please look at the following section specifically:

              ```{{filetype}}
              {{selection}}
              ```

              Please finish the code above carefully and logically.
              Respond just with the snippet of code that should be inserted."
            ]]
            local model_obj = prt.get_model("command")
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end,
          CompleteMultiContext = function(prt, params)
            local template = [[
              I have the following code from {{filename}} and other related files:

              ```{{filetype}}
              {{multifilecontent}}
              ```
              Please look at the following section specifically:

              ```{{filetype}}
              {{selection}}
              ```

              Please finish the code above carefully and logically.
              Respond just with the snippet of code that should be inserted."
            ]]
            local model_obj = prt.get_model("command")
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end,
          Explain = function(prt, params)
            local template = [[
              Your task is to take the code snippet from {{filename}} and
              explain it with gradually increasing complexity. Break down the
              code's functionality, purpose, and key components. The goal is to
              help the reader understand what the code does and how it works.

              ```{{filetype}}
              {{selection}}
              ```

              Use the markdown format with codeblocks and inline code.
              Explanation of the code above:
            ]]
            local model = prt.get_model("chat")
            prt.logger.info("Explaining selection with model: " .. model.name)
            prt.Prompt(params, prt.ui.Target.new, model, nil, template)
          end,
          FixBugs = function(prt, params)
            local template = [[
              You are an expert in {{filetype}}.
              Fix bugs in the below code from {{filename}} carefully and
              logically. Your task is to analyse the provided {{filetype}} code
              snippet, identify any bugs or errors present, and provide a
              corrected version of the code that resolves these issues. Explain
              the problems you found in the original code and how your fixes
              address them. The corrected code should be functional, efficient,
              and adhere to best practices in {{filetype}} programming.

              ```{{filetype}}
              {{selection}}
              ```

              Fixed code:
            ]]
            local model_obj = prt.get_model("command")
            prt.logger.info(
              "Fixing bugs in selection with model: " .. model_obj.name
            )
            prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
          end,
          Optimise = function(prt, params)
            local template = [[
              You are an expert in {{filetype}}.
              Your task is to analyse the provided {{filetype}} code snippet and
              suggest improvements to optimise its performance. Identify areas
              where the code can be made more efficient, faster, or less
              resource-intensive. Provide specific suggestions for optimisation,
              along with explanations of how these changes can enhance the
              code's performance. The optimised code should maintain the same
              functionality as the original code while demonstrating improved

              efficiency.

              ```{{filetype}}
              {{selection}}
              ```

              Optimised code:
            ]]
            local model_obj = prt.get_model("command")
            prt.logger.info(
              "Optimising selection with model: " .. model_obj.name
            )
            prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
          end,
          UnitTests = function(prt, params)
            local template = [[
              I have the following code from {{filename}}:

              ```{{filetype}}
              {{selection}}
              ```

              Please respond by writing table driven unit tests for the code
              above.
            ]]
            local model_obj = prt.get_model("command")
            prt.logger.info(
              "Creating unit tests for selection with model: " .. model_obj.name
            )
            prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
          end,
          Debug = function(prt, params)
            local template = [[
              I want you to act as {{filetype}} expert.
              Review the following code, carefully examine it, and report
              potential bugs and edge cases alongside solutions to resolve
              them. Keep your explanation short and to the point:

              ```{{filetype}}
              {{selection}}
              ```
            ]]
            local model_obj = prt.get_model("command")
            prt.logger.info(
              "Debugging selection with model: " .. model_obj.name
            )
            prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
          end,
          CommitMsg = function(prt, params)
            local futils = require("parrot.file_utils")
            if futils.find_git_root() == "" then
              prt.logger.warning("Not in a git repository")
              return
            else
              local template = [[
                I want you to act as a commit message generator. I will provide
                you with information about the task and the prefix for the task
                code, and I would like you to generate an appropriate commit
                message using the conventional commit format. Do not write any
                explanations or other words, just reply with the commit
                message. Start with a short headline as summary but then list
                the individual changes in more detail.

                Here are the changes that should be considered by this message:
              ]] .. vim.fn.system(
                "git diff --no-color --no-ext-diff --staged"
              )
              local model_obj = prt.get_model("command")
              prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
            end
          end,
          SpellCheck = function(prt, params)
            local chat_prompt = [[
              Your task is to take the text provided and rewrite it into a
              clear, grammatically correct version while preserving the original
              meaning as closely as possible. Correct any spelling mistakes,
              punctuation errors, verb tense issues, word choice problems, and
              other grammatical mistakes.
            ]]
            prt.ChatNew(params, chat_prompt)
          end,
          CodeConsultant = function(prt, params)
            local chat_prompt = [[
              Your task is to analyse the provided {{filetype}} code and suggest
              improvements to optimise its performance. Identify areas where the
              code can be made more efficient, faster, or less
              resource-intensive. Provide specific suggestions for optimisation,
              along with explanations of how these changes can enhance the
              code's performance. The optimised code should maintain the same
              functionality as the original code while demonstrating improved
              efficiency.

              Here is the code
              ```{{filetype}}
              {{filecontent}}
              ```
            ]]
            prt.ChatNew(params, chat_prompt)
          end,
          ProofReader = function(prt, params)
            local chat_prompt = [[
              I want you to act as a proofreader. I will provide you with texts
              and I would like you to review them for any spelling, grammar, or
              punctuation errors. Once you have finished reviewing the text,
              provide me with any necessary corrections or suggestions to
              improve the text. Highlight the corrected fragments (if any) using
              markdown backticks. Use British English spelling and grammar.

              When you have done that subsequently provide me with a slightly
              better version of the text, but keep close to the original text.

              Finally provide me with an ideal version of the text.

              Whenever I provide you with text, you reply in this format
              directly:

              ## Corrected text:

              {corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there
              are no corrections made}

              ## Slightly better text

              {slightly better text}

              ## Ideal text

              {ideal text}
            ]]
            prt.ChatNew(params, chat_prompt)
          end,
        },
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup({
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
        on_attach = function(bufnr)
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
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

  {
    "tpope/vim-fugitive",
    config = function()
      vim.api.nvim_command("autocmd User FugitiveChanged set cmdheight=0")
    end,
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
    config = function()
      require("nvim-surround").setup({})
    end,
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
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
        max_join_length = 80,
      })
    end,
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

      vim.cmd([[
        hi default link HlSearchNear SpellCap
        hi default link HlSearchLens SpellLocal
        hi default link HlSearchLensNear SpellRare
        hi default link HlSearchFloat Search
      ]])
    end,
  },

  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      local sidebar = require("sidebar-nvim")
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
    "OXY2DEV/markview.nvim",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local presets = require("markview.presets")
      require("markview").setup({
        markdown = {
          presets = {
            checkboxes = presets.checkboxes.nerd,
            headings = presets.headings.slanted,
            horizontal_rules = presets.horizontal_rules.double,
            tables = presets.tables.rounded,
          },
          preview = {
            modes = { "n", "i", "no", "c" },
            hybrid_modes = { "i" },
          },
          checkboxes = presets.checkboxes.nerd,
          headings = presets.headings.slanted,
          horizontal_rules = presets.horizontal_rules.double,
          tables = presets.tables.rounded,
          modes = { "n", "i", "no", "c" },
          hybrid_modes = { "i" },
        },
      })
    end,
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
