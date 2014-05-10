let g:gitgrepprg="git\\ grep\\ -n"
let g:gitroot="`git rev-parse --show-cdup`"

function! GitGrep(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:gitgrepprg
    execute "silent! grep " . a:args . " " . g:gitroot
    botright copen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

func GitGrepWord()
  normal! "zyiw
  call GitGrep(getreg('z'))
endf

nmap <C-x><C-x> :call GitGrepWord()<CR>
