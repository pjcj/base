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

  use "norcalli/nvim-colorizer.lua"
  use "terrortylor/nvim-comment"

  use "zsugabubus/crazy8.nvim"
  use { "lukas-reineke/indent-blankline.nvim", branch = "lua" }

  use {
    "hoob3rt/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true }
  }

  use "gioele/vim-autoswap"
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

require "telescope".setup {
  defaults = {
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
      ".git/.*"
    },
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
    },
  },
}

require "gitsigns".setup {
  signs = {
    add          = { show_count = true, text = "+" },
    change       = { show_count = true, text = "~" },
    delete       = { show_count = true, text = "_" },
    topdelete    = { show_count = true, text = "‾" },
    changedelete = { show_count = true, text = "~" },
  },
  numhl   = false,
  linehl  = false,
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer  = true,

    ['n <F2>'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},
    ['n <F3>'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},

    ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

    ['n <F1>'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <F1>'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
  },
  watch_index                 = { interval = 1000 },
  current_line_blame          = true,
  current_line_blame_delay    = 1000,
  current_line_blame_position = "eol",
  sign_priority               = 6,
  update_debounce             = 100,
  status_formatter            = nil, -- Use default
  use_decoration_api          = true,
  use_internal_diff           = true, -- If luajit is present
  count_chars = {
    [1]   = "₁",
    [2]   = "₂",
    [3]   = "₃",
    [4]   = "₄",
    [5]   = "₅",
    [6]   = "₆",
    [7]   = "₇",
    [8]   = "₈",
    [9]   = "₉",
    ["+"] = "₊",
  },
}

opt.termguicolors = true
require "colorizer".setup(
  { "*" },
  { names = true, RGB = true, RRGGBB = true, RRGGBBAA = true, css = true }
)

require "nvim_comment".setup({ line_mapping = "-" })

g.indent_blankline_char                           = " "
g.indent_blankline_space_char                     = " "
g.indent_blankline_show_trailing_blankline_indent = false
g.indent_blankline_show_first_indent_level        = false

require "lualine".setup{
  options = { theme  = "solarized_dark" },
  extensions = { "quickfix", "fugitive" },
}
