-- Core dependencies and essential plugins

return {
  -- File type icons for various plugins
  { "nvim-tree/nvim-web-devicons" },

  -- Lua utility functions used by many plugins
  { "nvim-lua/plenary.nvim" },

  -- SQLite bindings for Neovim (used by telescope-frecency and other plugins)
  { "kkharji/sqlite.lua" },

  -- Enhanced notification system with animations and history
  {
    "rcarriga/nvim-notify",
    version = "*",
    lazy = false,
    config = function()
      local notify = require("notify")
      vim.notify = notify
      notify.setup({
        background_colour = require("local_defs").colour.base03,
        top_down = false,
      })
    end,
  },

  -- LSP progress notifications using nvim-notify
  {
    "mrded/nvim-lsp-notify",
    dependencies = { "rcarriga/nvim-notify" },
    opts = {},
  },

  -- Start screen with recent files and sessions
  {
    "mhinz/vim-startify",
    lazy = false,
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

  -- Remember cursor position when reopening files
  { "farmergreg/vim-lastplace", lazy = false },

  -- Handle Vim swap files intelligently
  { "gioele/vim-autoswap", lazy = false },

  -- Repeat plugin commands with dot operator
  { "tpope/vim-repeat" },

  -- Improved UI for vim.ui interfaces (select, input)
  {
    "stevearc/dressing.nvim",
    version = "*",
  },

  -- Command-line fuzzy finder (required by telescope-fzf-native)
  { "junegunn/fzf" },

  -- Turn off expensive plugins and features for large files
  {
    "pteroctopus/faster.nvim",
    opts = {
      behaviours = {
        bigfile = {
          on = true,
          filesize = 2, -- MB
          pattern = "*",
          features_disabled = {
            "illuminate",
            "matchparen",
            "lsp",
            "treesitter",
            "indent_blankline",
            "vimopts",
            "syntax",
            "filetype",
            "codespell",
          },
        },
      },
    },
  },
}
