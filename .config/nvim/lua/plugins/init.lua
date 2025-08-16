--# selene: allow(mixed_table)

vim.g.mapleader = ","
vim.opt.termguicolors = true

-- Helper function for AI plugin enablement
local function using_ai()
  return vim.env.ENABLE_AI_PLUGINS and vim.env.ENABLE_AI_PLUGINS ~= "0"
end

-- Make using_ai available globally for plugin configs
_G.using_ai = using_ai

-- Setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local exists = vim.fn.isdirectory(lazypath) == 1
if not exists then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load plugin groups
local plugin_groups = {
  require("plugins.core"),
  require("plugins.theme"),
  require("plugins.completion"),
  require("plugins.lsp"),
  require("plugins.languages"),
  require("plugins.git"),
  require("plugins.ui"),
  require("plugins.navigation"),
  require("plugins.editing"),
  require("plugins.ai"),
}

-- Flatten the plugin groups
local plugins = {}
for _, group in ipairs(plugin_groups) do
  vim.list_extend(plugins, group)
end

-- Lazy.nvim options
local opts = {
  defaults = {
    lazy = true,
    -- version = "*",
  },
}

-- Setup lazy.nvim with all plugins
require("lazy").setup(plugins, opts)

-- Setup LSP servers after plugins are loaded
require("lsp").setup_servers()