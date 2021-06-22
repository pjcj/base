local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

g.mapleader = ","

local map = vim.api.nvim_set_keymap

local def = { noremap = true, silent = true}

map("i", "<F5>",       "[",   def)
map("n", "r<F5>",      "r[",  def)
map("i", "<F6>",       "]",   def)
map("n", "r<F6>",      "r]",  def)
map("i", "<F7>",       "{",   def)
map("n", "r<F7>",      "r{",  def)
map("i", "<F8>",       "}",   def)
map("n", "r<F8>",      "r}",  def)
map("i", "<F9>",       "|",   def)
map("n", "r<F9>",      "r|",  def)
map("i", "<F10>",      "~",   def)
map("n", "r<F10>",     "r~",  def)
map("n", "<F12>",      "",  def)
map("n", "<PageUp>",   "0", def)
map("n", "<PageDown>", "0", def)

map("n", "<leader>.",  [[<cmd>lua require"telescope.builtin".find_files({ hidden = true })<cr>]], def)
map("n", "<leader> ",  [[<cmd>lua require"telescope.builtin".oldfiles()<cr>]],                    def)
map("n", "<leader>m",  [[<cmd>lua require"telescope.builtin".buffers()<cr>]],                     def)
map("n", "<leader>ff", [[<cmd>lua require"telescope.builtin".builtin()<cr>]],                     def)
map("n", "<leader>fg", [[<cmd>lua require"telescope.builtin".live_grep()<cr>]],                   def)
map("n", "<leader>fh", [[<cmd>lua require"telescope.builtin".help_tags()<cr>]],                   def)

map("n", "<leader>gg", [[<cmd>tab Git commit<cr>]], def)

map("n", "ga",      "<Plug>(EasyAlign)", {})
map("x", "ga",      "<Plug>(EasyAlign)", {})
map("v", "<Enter>", "<Plug>(EasyAlign)", {})

-- map("n", "<leader>l" [[<cmd>let @/ = ""<bar> :call UncolorAllWords()<cr>]], def)

cmd([[
  nnoremap <silent> <leader>l :let @/ = ""<bar> :call UncolorAllWords()<cr>
]])
