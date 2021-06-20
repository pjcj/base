local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

g.mapleader = ","

cmd([[
  imap     <F5>       [
  imap     <F6>       ]
  imap     <F7>       {
  imap     <F8>       }
  imap     <F9>       \|
  imap     <F10>      ~
  nnoremap <F12>      
  nmap     <PageUp>   0
  nmap     <PageDown> 0

  nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files({ hidden = true })<cr>
  nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
  nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
  nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

  inoremap <silent><expr> <CR>      compe#confirm("<CR>")
]])
