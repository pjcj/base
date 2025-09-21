--# selene: allow(mixed_table)

-- Language-specific plugins for Neovim

return {
  -- Comprehensive Go development plugin with LSP, formatting, and debugging
  {
    "ray-x/go.nvim",
    dependencies = {
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
          parameter_hints_prefix = " ",
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

  -- Testing framework with test runner and result display
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
              args = { "-count=1", "-timeout=60s" },
            }),
          },
        },
      })
    end,
  },

  -- Enhanced Perl syntax highlighting and support
  {
    "vim-perl/vim-perl",
    build = "make clean carp dancer heredoc-sql highlight-all-pragmas "
      .. "js-css-in-mason method-signatures moose test-more try-tiny",
    config = function() vim.g.perl_highlight_data = 1 end,
  },

  -- Terraform syntax highlighting and indentation
  { "hashivim/vim-terraform" },

  -- Helm template syntax highlighting
  { "towolf/vim-helm" },

  -- Code refactoring operations using treesitter
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

  -- DB access
  {
    "praem90/db.nvim",
    config = function()
      require("db").setup({
        dependencies = {
          "nvim-lua/plenary.nvim",
          "MunifTanjim/nui.nvim",
          "nvim-telescope/telescope.nvim",
        },
        main = "db",
        connections = {
          {
            name = "devserver",
            host = "127.1",
            port = 3306,
            user = "root",
            password = "password",
          },
        },
      })
    end,
  },
}
