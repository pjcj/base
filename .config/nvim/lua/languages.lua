local cmd  = vim.cmd        -- run Vim commands
local fn   = vim.fn         -- call Vim functions
local g    = vim.g          -- a table to access global variables
local opt  = vim.opt        -- set options
local api  = vim.api        -- vim api
local exec = api.nvim_exec  -- execute nvim

cmd([[
  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

cmd([[
  function! BufEnterFunc()
    call v:lua.set_buffer_colours()
  endfunction

  function! BufWinEnterFunc()
    call v:lua.set_buffer_settings()
  endfunction

  augroup buf_enter
    autocmd!
    autocmd BufEnter,ColorScheme * call BufEnterFunc()
    autocmd BufWinEnter          * call BufWinEnterFunc()
  augroup end
]])
