" Local configuration information for Perl filetypes
" From http://houston.pm.org/talks/2009talks/0901Talk/perl_local.vim

" fine grained perl control
  let perl_want_scope_in_variables = 1
  let perl_extended_vars = 1
  let perl_include_pod = 1
" let perl_highlight_matches = 1
" let perl_no_sync_on_sub = 1
" let perl_sync_dist = 20

" Set this once, globally.
if !exists("perlpath")
  let perlpath = 1
  let $perlpath = system('perl -e "print join(q(,),@INC)"')
  set path+=$perlpath
  set path+=popopo
endif

" Perl help
noremap K :!perldoc <cword> <bar><bar> perldoc -f <cword><cr>
" setlocal iskeyword+=:

" Allow gf to work with modules
set isfname+=:
set include=\\<\\(use\\\|require\\)\\>
set includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','.pm','')
set path+=lib

" check perl code with :make
" setlocal makeprg=perl\ -c\ -Iblib\ -Ilib\ %\ $*
" setlocal errorformat=%f:%l:%m
" setlocal errorformat+=%m\ at\ %f\ line\ %l.
setlocal autowrite

" Adds prove as the make option for .t files
" ':make %' to run prove on the current file. Can pass more options to make.
" autocmd BufNewFile,BufRead *.t compiler perlprove

" Tidy selected lines (or entire file) with ,pt
nnoremap <silent> ,pt :%!perltidy -q<cr>
vnoremap <silent> ,pt :!perltidy -q<cr>

" Critic check the current file with ,pc
nnoremap <silent> ,pc :!perlcritic %<cr>

" Deparse obfuscated code with ,pd
nnoremap <silent> ,pD :.!perl -MO=Deparse 2>/dev/null<cr>
vnoremap <silent> ,pD :!perl -MO=Deparse 2>/dev/null<cr>

" From Ovid
noremap ,pd  :!perldoc %<cr>

" Prove test code
nmap  ,pp :!prove -blv %<cr>

" Extend the snippets
" exec "source ".$HOME."/vim/after/ftplugin/perl_mysnippets.vim"

" autocmd BufNewFile  *.pm        0r ~/.vim/templates/Module.pm
" autocmd BufNewFile  *.pl        0r ~/.vim/templates/Program.pl
" autocmd BufNewFile  *.t         0r ~/.vim/templates/Test.t

" From Codon on PerlMonks
" restore defaults (incase I :e or :sp)
setlocal cinkeys&
" don't go to column zero when # is the first thing on the line
setlocal cinkeys-=0#
" restore defaults
setlocal cinwords&
" add Perl-ish keywords
setlocal cinwords+=elsif,foreach,sub,unless,until
setlocal cinoptions&
" I don't rememer these OTTOMH; :help cinoptions to learn more
setlocal cinoptions+=+2s,(1s,u0,m1
setlocal cindent
