let s:fg_cover = "#859900"
let s:fg_error = "#dc322f"
let s:bg_valid = "#073642"
let s:bg_old   = "#342a2a"

let s:types = [ "pod", "subroutine", "statement", "branch", "condition", ]

for s:type in s:types
    exe "highlight cov_" . s:type .       " ctermbg=0 cterm=bold gui=NONE guifg=" . s:fg_cover
    exe "highlight cov_" . s:type . "_error ctermbg=0 cterm=bold gui=NONE guifg=" . s:fg_error
endfor
exe "highlight SignColumn ctermbg=0 guibg=" . s:bg_valid

" highlight cov ctermbg=8 guibg=#002b36
" highlight err ctermbg=0 guibg=#073642

function! s:set_bg(bg)
    for s:type in s:types
        exe "highlight cov_" . s:type .       " guibg=" . a:bg
        exe "highlight cov_" . s:type . "_error guibg=" . a:bg
    endfor
    exe "highlight SignColumn ctermbg=0 guibg=" . a:bg
endfunction

function! g:coverage_valid(filename)
    call s:set_bg(s:bg_valid)
endfunction

function! g:coverage_old(filename)
    call s:set_bg(s:bg_old)
endfunction
