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
