Cmd    = vim.cmd                           -- run Vim commands
Fn     = vim.fn                            -- call Vim functions
G      = vim.g                             -- a table to access global variables
Opt    = vim.opt                           -- set options
Lopt   = vim.opt_local                     -- set local options
Api    = vim.api                           -- vim api
Exec   = Api.nvim_exec                     -- execute nvim
Map    = vim.api.nvim_set_keymap           -- global mappings
Bmap   = vim.api.nvim_buf_set_keymap       -- local mappings
Defmap = { noremap = true, silent = true } -- default map options

require "plugins"
require "settings"
require "colour"
require "languages"
require "lsp"
require "mappings"