-- AI-related plugins for Neovim
-- This file contains all AI completion and assistance plugins

return {
  -- Free AI code completion from Windsurf (formerly Codeium)
  {
    "Exafunction/windsurf.nvim",
    enabled = _G.using_ai(),
    main = "codeium", -- repo was renamed but the Lua module was not
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {},
  },

  -- Fast AI code completion with local context awareness
  {
    "supermaven-inc/supermaven-nvim",
    enabled = _G.using_ai(),
    opts = {
      disable_inline_completion = true,
      disable_keymaps = true,
    },
  },

  -- GitHub Copilot integration
  {
    "zbirenbaum/copilot.lua",
    enabled = _G.using_ai(),
    event = { "BufReadPre", "BufNewFile" },
    cmd = "Copilot",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        ["*"] = true, -- enable copilot for all filetypes
      },
    },
  },

  -- Display Copilot status in lualine statusline
  {
    "AndreM222/copilot-lualine",
    enabled = _G.using_ai(),
  },

  -- Copilot Next Edit Suggestions rendered as navigable diffs
  {
    "folke/sidekick.nvim",
    enabled = _G.using_ai(),
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<C-i>" -- no suggestion pending: keep jumplist-forward
          end
        end,
        mode = "n",
        expr = true,
        desc = "NES jump/apply",
      },
    },
  },

  -- Claude Code integration for AI-powered development
  {
    "coder/claudecode.nvim",
    enabled = true, -- needed for claude code /ide command
    event = { "BufReadPre", "BufNewFile" },
    config = true,
    opts = {
      auto_start = true,
      port_range = { min = 63720, max = 63739 },
    },
    keys = {
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
}
