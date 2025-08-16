--# selene: allow(mixed_table)

-- Navigation and search plugins

return {
  -- Native FZF sorting for Telescope (requires compilation)
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "make || gmake",
  },
  -- Fuzzy finder for files, buffers, LSP symbols, and more
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
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

      local telescope_group =
        vim.api.nvim_create_augroup("telescope", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        group = telescope_group,
        callback = function()
          vim.opt_local.number = true
          vim.opt_local.tabstop = 2
        end,
      })
    end,
  },
  -- Clipboard history manager with persistent storage
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua", module = "sqlite" },
    opts = {
      enable_persistent_history = true,
      db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      default_register = '"',
    },
  },
  -- Find and replace with preview in quickfix window
  { "gabrielpoca/replacer.nvim" },
  -- Better quickfix window with preview and fuzzy search
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
  -- Pretty quickfix and location lists
  {
    "yorickpeterse/nvim-pqf",
    opts = {},
  },
  -- File manager that works like a normal buffer
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- Terminal file manager integration (yazi)
  {
    "mikavilpas/yazi.nvim",
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

  -- Code outline and symbol navigation
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

  -- File explorer tree with git integration
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    cmd = { "NvimTreeToggle", "NvimTreeOpen" },
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icon
    },
    config = function()
      require("nvim-tree").setup({
        hijack_directories = { enable = false },
      })
    end,
  },
}