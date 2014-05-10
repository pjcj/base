"=============================================================================
" File: cal.vim
" Author: Yasuhiro Matsumoto <mattn_jp@hotmail.com>
" Last Change:  Tue, 17 Jun 2003
" Version: for 1.3s
" ThisIs: ftplugin for calendar diary

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

if &filetype != "calendar"
  finish
endif
set fo=troqwan1
set ai
set tw=80
imap <localleader>z <C-R>=strftime("%Y-%m-%d %X")<CR>
nmap <localleader>z i<C-R>=strftime("%Y-%m-%d %X")<CR><ESC>
