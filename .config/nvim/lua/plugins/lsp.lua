--# selene: allow(mixed_table)

local plugins = {
  -- LSP-based breadcrumb navigation in statusline
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

  -- Package manager for LSP servers, DAP servers, linters, and formatters
  { "williamboman/mason.nvim" },
  -- Automatic color highlighting for LSP diagnostics
  { "folke/lsp-colors.nvim" },
  -- Shows lightbulb icon when LSP code actions are available
  {
    "kosayoda/nvim-lightbulb",
    dependencies = {
      "antoinemadec/FixCursorHold.nvim",
    },
    opts = {
      autocmd = { enabled = true },
      sign = {
        enabled = false,
        priority = 1,
      },
      virtual_text = {
        enabled = true,
      },
    },
  },

  -- {
  --   -- :lua vim.lsp.buf.incoming_calls()
  --   -- :lua vim.lsp.buf.outgoing_calls()
  --   "ldelossa/calltree.nvim",
  --   config = function()
  --     require "calltree".setup {}
  --   end,
  -- },

  -- Asynchronous linting for various file types
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
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
      local found = vim.fs.find(
        ".codespell",
        { upward = true, path = vim.fn.getcwd() }
      )[1]
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
  -- Asynchronous linting engine (legacy support)
  {
    "dense-analysis/ale",
    event = { "BufReadPost", "BufNewFile" },
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
  -- Code formatting with support for multiple formatters per filetype
  {
    "stevearc/conform.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local codespell_args = {
        "$FILENAME",
        "--write-changes",
        "--check-hidden", -- conform's temp file is hidden
        "--builtin",
        "clear,rare,informal,usage,names",
      }
      local found = vim.fs.find(
        ".codespell",
        { upward = true, path = vim.fn.getcwd() }
      )[1]
      if found then
        vim.list_extend(codespell_args, { "-I", found })
      end

      require("conform").setup({
        formatters_by_ft = {
          dockerfile = { "dprint", "dockerfmt" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          json = { "fixjson" },
          make = { "bake" },
          markdown = { "markdownlint", "mdformat", "injected", "mdsf" },
          python = { "isort", "black" },
          sh = { "shellharden", "shellcheck", "shfmt" },
          bash = { "shellharden", "shellcheck", "shfmt" },
          zsh = { "shellcheck" },
          sql = { "sql_formatter" },
          terraform = { "terraform_fmt" },
          yaml = { "yamlfmt" }, -- yamlfix is too buggy
          ["*"] = { "codespell", "typos" },
        },
        formatters = {
          bake = {
            command = "mbake",
          },
          codespell = {
            args = codespell_args,
          },
          mdformat = {
            args = { "--number", "-" },
          },
          shellcheck = {
            args = { "--shell=bash", "-" },
          },
          shfmt = {
            append_args = { "-i", "2" },
          },
        },
        default_format_opts = {
          lsp_format = "first",
        },
        log_level = vim.log.levels.DEBUG,
      })
    end,
  },
  -- Rule-based linting and code analysis
  { "chrisgrieser/nvim-rulebook" },

  -- Automatic ctags generation and management
  {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_ctags_exclude =
        require("local_defs").fn.gutentags_ctags_exclude()
      -- print(vim.inspect(vim.g.gutentags_ctags_exclude))

      -- can be extended with '*/sub/path' if required
      vim.g.gutentags_generate_on_new          = 1
      vim.g.gutentags_generate_on_missing      = 1
      vim.g.gutentags_generate_on_write        = 1
      vim.g.gutentags_generate_on_empty_buffer = 0

      local is_freebsd = (io.popen("uname"):read() == "FreeBSD")
      if is_freebsd then
        vim.g.gutentags_ctags_executable = "/usr/local/bin/uctags"
      end
    end,
  },

  -- LSP server for ctags-based navigation
  {
    "netmute/ctags-lsp.nvim",
  },
}

return plugins
