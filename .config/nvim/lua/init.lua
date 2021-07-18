Cmd    = vim.cmd                           -- run Vim commands
Fn     = vim.fn                            -- call Vim functions
G      = vim.g                             -- a table to access global variables
Opt    = vim.opt                           -- set options
Lopt   = vim.opt_local                     -- set local options
Api    = vim.api                           -- vim api
Exec   = Api.nvim_exec                     -- execute nvim
Map    = Api.nvim_set_keymap               -- global mappings
Bmap   = Api.nvim_buf_set_keymap           -- local mappings
Defmap = { noremap = true, silent = true } -- default map options

require "colour"
require "plugins"
require "settings"
require "highlight"
require "languages"
require "lsp"
require "mappings"
