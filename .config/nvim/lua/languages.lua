Cmd([[
  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

Cmd([[
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

  augroup autowrite
    autocmd!
    autocmd FocusLost * silent! wa
  augroup end
]])