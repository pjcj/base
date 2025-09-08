-- Git-related plugins configuration

return {
  -- Git decorations and hunk management in the gutter
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
      status_formatter = nil,          -- Use default
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

  -- Show git blame information in popup window
  {
    "rhysd/git-messenger.vim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.git_messenger_always_into_popup = 1
      vim.g.git_messenger_include_diff = "current"
      vim.g.git_messenger_extra_blame_args = "-wMC"
      vim.g.git_messenger_floating_win_opts = { border = "single" }
    end,
  },

  -- Highlight and navigate git conflict markers
  {
    "rhysd/conflict-marker.vim",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- Enhanced git diff viewing and file history
  {
    "sindrets/diffview.nvim",
    event = { "BufReadPre", "BufNewFile" }
  },

  -- Open current line/selection in GitHub web interface
  {
    "ruanyl/vim-gh-line",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.gh_use_canonical = 0
      vim.g.gh_trace = 1
    end,
  },

  -- Comprehensive Git integration and commands
  {
    "tpope/vim-fugitive",
    cmd = "Git",
    -- config = function()
    --   vim.api.nvim_command("autocmd User FugitiveChanged set cmdheight=0")
    -- end,
  },

  -- GitLab integration for MR reviews and CI/CD
  {
    "harrisoncramer/gitlab.nvim",
    version = "*",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "stevearc/dressing.nvim",      -- Recommended. Better UI for pickers.
      "nvim-tree/nvim-web-devicons", -- Recommended. Icons in discussion tree.
    },
    event = { "BufReadPre", "BufNewFile" },
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
}
