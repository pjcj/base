--# selene: allow(mixed_table)

-- UI-related plugins for enhanced visual experience and interface
return {
  -- Customizable statusline with Git, LSP, and mode indicators
  {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("statusline") end,
  },

  -- Popup showing available keybindings for partial commands
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

  -- Enhanced markdown rendering with checkboxes, headings, and tables
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    priority = 100,
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
          icon_provider = "devicons",
          enable = false,
        },
        markdown = {
          checkboxes = presets.checkboxes.nerd,
          headings = presets.headings.slanted,
          horizontal_rules = presets.horizontal_rules.double,
          tables = presets.tables.rounded,
          list_items = {
            indent_size = 2,
            shift_width = 2,
          },
        },
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "MarkviewSplitviewOpen",
        callback = function(event)
          local source_buffer = event.data.source
          local preview_window = event.data.preview_window

          -- Enable scrollbind and cursorbind in both windows
          for _, win in ipairs(vim.fn.win_findbuf(source_buffer)) do
            vim.api.nvim_set_option_value("scrollbind", true, { win = win })
            vim.api.nvim_set_option_value("cursorbind", true, { win = win })
          end

          -- Enable scrollbind and cursorbind in the preview window
          vim.api.nvim_set_option_value(
            "scrollbind",
            true,
            { win = preview_window }
          )
          vim.api.nvim_set_option_value(
            "cursorbind",
            true,
            { win = preview_window }
          )

          -- Sync the scroll and cursor positions
          vim.cmd("syncbind")
        end,
      })

      -- Optional: Clean up when splitview closes
      vim.api.nvim_create_autocmd("User", {
        pattern = "MarkviewSplitviewClose",
        callback = function(event)
          local source_buffer = event.data.source

          -- Disable scrollbind and cursorbind in source windows
          for _, win in ipairs(vim.fn.win_findbuf(source_buffer)) do
            vim.api.nvim_set_option_value("scrollbind", false, { win = win })
            vim.api.nvim_set_option_value("cursorbind", false, { win = win })
          end
        end,
      })
    end,
  },

  -- Task runner and job management
  {
    "stevearc/overseer.nvim",
    opts = {},
  },

  -- Scrollbar with git and diagnostic indicators
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local l = require("local_defs")
      local c = l.colour
      require("scrollbar").setup({
        handle = {
          color = c.dblue,
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

      -- Conditionally hide scrollbar for large Perl files
      local scrollbar_utils = require("scrollbar.utils")
      local is_large_perl_file = require("local_defs").fn.large_perl_file
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        callback = function()
          if is_large_perl_file(0) then
            scrollbar_utils.hide()
          else
            scrollbar_utils.show()
          end
        end,
      })
    end,
  },

  -- Sidebar with git status, diagnostics, todos, and symbols
  {
    "sidebar-nvim/sidebar.nvim",
    opts = {
      open = false,
      sections = { "git", "diagnostics", "todos", "symbols" },
      disable_closing_prompt = true,
    },
  },

  -- Smooth cursor movement animation with mode indicators
  {
    "gen740/SmoothCursor.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("smoothcursor").setup({
        priority = 1,
        fancy = { enable = true },
        show_last_positions = "enter",
      })
      vim.fn.sign_define("smoothcursor_v", { text = " " })
      vim.fn.sign_define("smoothcursor_V", { text = "" })
      vim.fn.sign_define("smoothcursor_i", { text = "" })
      vim.fn.sign_define("smoothcursor_�", { text = "" })
      vim.fn.sign_define("smoothcursor_R", { text = "󰊄" })
    end,
  },

  -- Live markdown preview in browser
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

  -- Render markdown in specific filetypes (Avante, codecompanion)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "Avante", "codecompanion" },
    },
    ft = { "Avante", "codecompanion" },
  },

  -- Enhanced help file viewer with better formatting
  {
    "OXY2DEV/helpview.nvim",
    event = "BufEnter",
    -- lazy = false, -- as specified in docs
  },

  -- Smart window splitting and resizing with tmux integration
  {
    "mrjones2014/smart-splits.nvim",
    version = "*",
    opts = {
      ignored_filetypes = {
        "nofile",
        "quickfix",
        "prompt",
      },
      ignored_buftypes = { "nofile" },
      default_amount = 3,
      at_edge = "wrap",
      cursor_follows_swapped_bufs = true,
    },
  },

  -- Colorful window separators with animations
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "UIEnter", -- just WinLeave causes session loading to hang
    config = function()
      require("colorful-winsep").setup({
        border = "rounded",
        highlight = require("local_defs").colour.pyellow,
        animate = { enabled = "shift" },
      })
    end,
  },
}
