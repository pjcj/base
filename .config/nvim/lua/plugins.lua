local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

local path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", path})
  cmd "packadd packer.nvim"
end

require("packer").startup(function()
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  use "pjcj/neovim-colors-solarized-truecolor-only"

  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }

  use "neovim/nvim-lspconfig"
  use "kabouzeid/nvim-lspinstall"

  use { "fatih/vim-go", run = ":GoUpdateBinaries" }

  use {
    "nvim-telescope/telescope.nvim",
    requires = {{ "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" }}
  }

  use "hrsh7th/nvim-compe"
  use "andersevenrud/compe-tmux"

  use "psliwka/vim-smoothie"

  use {
    "lewis6991/gitsigns.nvim",
    requires = {
      "nvim-lua/plenary.nvim"
    }
  }
end)

require "nvim-treesitter.configs".setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
}

require "compe".setup {
  enabled          = true;
  autocomplete     = true;
  debug            = false;
  min_length       = 1;
  preselect        = "enable";
  throttle_time    = 80;
  source_timeout   = 200;
  resolve_timeout  = 800;
  incomplete_delay = 400;
  max_abbr_width   = 100;
  max_kind_width   = 100;
  max_menu_width   = 100;
  documentation    = true;

  source = {
    path      = true;
    buffer    = true;
    calc      = true;
    spell     = true;
    emoji     = true;
    nvim_lsp  = true;
    nvim_lua  = true;
    vsnip     = true;
    ultisnips = true;
    nvim_treesitter = true;
    tmux      = {
      all_panes = true
    }
  }
}

require "gitsigns".setup {
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '+', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  numhl = false,
  linehl = false,
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,

    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},
    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},

    ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
  },
  watch_index = {
    interval = 1000
  },
  current_line_blame = false,
  current_line_blame_delay = 1000,
  current_line_blame_position = 'eol',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  use_decoration_api = true,
  use_internal_diff = true,  -- If luajit is present
}
