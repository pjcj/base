vim.cmd [[
  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent!
      \ lua vim.highlight.on_yank{ higroup="Cursor", timeout=1000 }
  augroup end

  function! BufWinEnterFunc()
    call v:lua.require("local_defs").fn.set_buffer_settings()
  endfunction

  augroup buf_enter
    autocmd!
    autocmd BufWinEnter * call BufWinEnterFunc()
  augroup end

  augroup autowrite
    autocmd!
    autocmd FocusLost,BufLeave * silent! wa
  augroup end

  augroup file_types
    autocmd!
    autocmd BufNewFile,BufReadPost *.t         set ft=perl
    autocmd BufNewFile,BufReadPost *.mc        set ft=mason
    autocmd BufNewFile,BufReadPost template/** set ft=tt2html
    autocmd BufNewFile,BufReadPost *.tt2       set ft=tt2html
    autocmd BufNewFile,BufReadPost *.tt        set ft=tt2html
  augroup end

  augroup osc
    autocmd!
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankRegister +' | endif
  augroup end

  augroup quickfix
    autocmd FileType qf setlocal winheight=20
  augroup end
]]
