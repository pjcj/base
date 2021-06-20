local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

g.mapleader = ","

cmd([[
  imap     <F6>       ]
  imap     <F7>       {
  imap     <F8>       }
  imap     <F9>       \|
  imap     <F10>      ~
  nnoremap <F12>      
  nmap     <PageUp>   0
  nmap     <PageDown> 0

]])

local map = vim.api.nvim_set_keymap

-- map("i", "<F5>", "[", def)

local def = { noremap = true, silent = true}
map("n", "<leader>.",  [[<cmd>lua require"telescope.builtin".find_files({ hidden = true })<cr>]], def)
map("n", "<leader> ",  [[<cmd>lua require"telescope.builtin".oldfiles()<cr>]], def)
map("n", "<leader>m",  [[<cmd>lua require"telescope.builtin".buffers()<cr>]], def)
map("n", "<leader>ff", [[<cmd>lua require"telescope.builtin".builtin()<cr>]], def)
map("n", "<leader>fg", [[<cmd>lua require"telescope.builtin".live_grep()<cr>]], def)
map("n", "<leader>fh", [[<cmd>lua require"telescope.builtin".help_tags()<cr>]], def)
