" Termux .vimrc - portable version of Neovim config
" Works with both vim and neovim
" Copy to ~/.vimrc on Termux

" -----------------------------------------------------------------------------
" Basic settings (from settings.lua)
" -----------------------------------------------------------------------------

set nocompatible
filetype plugin indent on
syntax enable

set autoread
set autowriteall
set backspace=indent,eol,start
set background=dark
set backup
set backupcopy=yes
set backupext=.bak
set cmdheight=1
set colorcolumn=80,120
set complete=.,w,b,u,U,i,t
set completeopt=menuone,noselect
set diffopt=internal,filler,vertical
set expandtab
set fillchars=fold:\
set formatoptions=tcrqnljp
set hidden
set history=10000
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:»\ ,trail:·,nbsp:␣
set matchpairs+=<:>
set mouse=a
set number
set report=0
set scrolloff=12
set shiftround
set shiftwidth=2
set shortmess+=c
set showmatch
set showmode
set signcolumn=yes
set smartcase
set smarttab
set splitbelow
set splitright
set tabstop=2
set title
set titlestring=%t
set undofile
set undolevels=10000
set updatecount=40
set updatetime=250
set wildmenu
set wildmode=longest:full,full
set encoding=utf-8
set fileencoding=utf-8

" Undo and backup directories
if !isdirectory($HOME . '/.vim/undo')
  call mkdir($HOME . '/.vim/undo', 'p')
endif
if !isdirectory($HOME . '/.vim/backup')
  call mkdir($HOME . '/.vim/backup', 'p')
endif
set undodir=~/.vim/undo//
set backupdir=~/.vim/backup//

" Enable true colours if available
if has('termguicolors')
  set termguicolors
endif

" -----------------------------------------------------------------------------
" Leader key
" -----------------------------------------------------------------------------

let mapleader = ','
let maplocalleader = ','

" -----------------------------------------------------------------------------
" Key mappings (from mappings.lua)
" -----------------------------------------------------------------------------

" Escape with jk
inoremap jk <Esc>

" Save with ö
nnoremap ö :w<cr>:wa<cr>

" Clear search highlight
nnoremap <leader>l :let @/ = ""<cr>

" Window navigation (Ctrl + hjkl)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Terminal mode window navigation
if has('nvim')
  tnoremap <C-h> <C-\><C-n><C-w>h
  tnoremap <C-j> <C-\><C-n><C-w>j
  tnoremap <C-k> <C-\><C-n><C-w>k
  tnoremap <C-l> <C-\><C-n><C-w>l
endif

" Window resizing with Alt + hjkl
nnoremap <A-h> :vertical resize -2<cr>
nnoremap <A-j> :resize +2<cr>
nnoremap <A-k> :resize -2<cr>
nnoremap <A-l> :vertical resize +2<cr>

" Quickfix navigation
nnoremap <F6> :cprevious<cr>
nnoremap <F7> :cnext<cr>
nnoremap <S-F6> :lprevious<cr>
nnoremap <S-F7> :lnext<cr>
nnoremap <F9> :cclose<bar>lclose<bar>only<cr>

" Quit
nnoremap <S-F1> :q<cr>
inoremap <S-F1> <Esc>:q<cr>

" Go to definition (works with tags)
nnoremap gd <C-]>
nnoremap gD <C-]>

" Page up/down override
nnoremap <PageUp> <C-u>
nnoremap <PageDown> <C-d>

" Better search (case sensitive star)
nnoremap * /\C\V\<<C-r>=escape(expand('<cword>'), '/\')<cr>\><cr>

" Remove trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/ = ""<cr>

" Copy filename to clipboard
nnoremap <leader>G :let @+ = expand("%:p")<cr>:echo "Copied: " . expand("%:p")<cr>
nnoremap <leader><C-g> :let @+ = expand("%")<cr>:echo "Copied: " . expand("%")<cr>

" Session save and exit
nnoremap <leader>rr :mksess! /tmp/tmp_session.vim<cr>:xa<cr>

" Spell
nnoremap <leader>sd :setlocal spell spelllang=de_ch<cr>
nnoremap <leader>se :setlocal spell spelllang=en_gb<cr>
nnoremap <leader>so :set nospell<cr>

" Toggle settings
nnoremap <leader>tw :set list!<cr>

" Buffer navigation
nnoremap <leader>fb :buffers<cr>:buffer<space>
nnoremap <leader>bn :bnext<cr>
nnoremap <leader>bp :bprevious<cr>

" File explorer (netrw)
nnoremap <leader>tt :Explore<cr>
nnoremap <leader>tv :Vexplore<cr>
nnoremap <leader>ts :Sexplore<cr>

" -----------------------------------------------------------------------------
" Abbreviations
" -----------------------------------------------------------------------------

iabbrev ,, =>

" -----------------------------------------------------------------------------
" Surround-like mappings (basic, no plugin)
" -----------------------------------------------------------------------------

" Quote word under cursor
nnoremap <leader>qid ciw""<Esc>P
nnoremap <leader>qis ciw''<Esc>P
nnoremap <leader>qib ciw``<Esc>P

" Visual mode surround
vnoremap <leader>" c""<Esc>P
vnoremap <leader>' c''<Esc>P
vnoremap <leader>` c``<Esc>P
vnoremap <leader>( c()<Esc>P
vnoremap <leader>{ c{}<Esc>P
vnoremap <leader>[ c[]<Esc>P

" -----------------------------------------------------------------------------
" Git mappings (basic, works with fugitive if available)
" -----------------------------------------------------------------------------

nnoremap <leader>gg :Git commit<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gs :Git status<cr>
nnoremap <leader>gd :Git diff<cr>
nnoremap <leader>gl :Git log --oneline --graph<cr>
nnoremap <leader>gb :Git blame<cr>

" -----------------------------------------------------------------------------
" Searching with grep
" -----------------------------------------------------------------------------

" Grep for word under cursor
nnoremap <leader>fs :grep! -r <cword> .<cr>:copen<cr>
nnoremap <leader>fg :grep! -r "" .<left><left><left>

" Use ripgrep if available
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

" -----------------------------------------------------------------------------
" FZF integration (if available)
" -----------------------------------------------------------------------------

if executable('fzf')
  " Use fzf for file finding
  nnoremap <leader>. :FZF<cr>
  nnoremap <leader>- :FZF<cr>

  " fzf in Termux
  if isdirectory('/data/data/com.termux/files/usr/share/fzf')
    set runtimepath+=/data/data/com.termux/files/usr/share/fzf
  endif
endif

" -----------------------------------------------------------------------------
" Netrw settings (built-in file explorer)
" -----------------------------------------------------------------------------

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" -----------------------------------------------------------------------------
" Status line
" -----------------------------------------------------------------------------

function! GitBranch()
  let l:branch = system('git branch --show-current 2>/dev/null | tr -d "\n"')
  return strlen(l:branch) > 0 ? ' ' . l:branch . ' ' : ''
endfunction

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{GitBranch()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\

" -----------------------------------------------------------------------------
" Colours (Solarized-inspired)
" -----------------------------------------------------------------------------

" Basic colour overrides for dark background
highlight Normal ctermbg=NONE guibg=NONE
highlight LineNr ctermfg=10 guifg=#586e75
highlight CursorLineNr ctermfg=3 guifg=#b58900
highlight ColorColumn ctermbg=0 guibg=#073642
highlight SignColumn ctermbg=NONE guibg=NONE
highlight VertSplit ctermfg=0 ctermbg=NONE guifg=#073642 guibg=NONE
highlight StatusLine ctermfg=7 ctermbg=0 guifg=#93a1a1 guibg=#073642
highlight StatusLineNC ctermfg=10 ctermbg=0 guifg=#586e75 guibg=#073642
highlight Pmenu ctermfg=7 ctermbg=0 guifg=#839496 guibg=#073642
highlight PmenuSel ctermfg=3 ctermbg=0 guifg=#b58900 guibg=#002b36
highlight Search ctermfg=0 ctermbg=3 guifg=#002b36 guibg=#b58900
highlight IncSearch ctermfg=0 ctermbg=9 guifg=#002b36 guibg=#cb4b16
highlight Visual ctermbg=0 guibg=#073642
highlight MatchParen ctermfg=1 ctermbg=NONE guifg=#dc322f guibg=NONE gui=bold

" Diff colours
highlight DiffAdd ctermfg=2 ctermbg=NONE guifg=#859900 guibg=NONE
highlight DiffChange ctermfg=3 ctermbg=NONE guifg=#b58900 guibg=NONE
highlight DiffDelete ctermfg=1 ctermbg=NONE guifg=#dc322f guibg=NONE

" -----------------------------------------------------------------------------
" Autocommands
" -----------------------------------------------------------------------------

augroup termux_vimrc
  autocmd!

  " Return to last edit position
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g'\"" |
    \ endif

  " Auto-reload files changed outside vim
  autocmd FocusGained,BufEnter * checktime

  " Trim trailing whitespace on save (optional - uncomment if wanted)
  " autocmd BufWritePre * :%s/\s\+$//e

  " Filetype specific settings
  autocmd FileType python setlocal shiftwidth=4 tabstop=4
  autocmd FileType go setlocal noexpandtab shiftwidth=4 tabstop=4
  autocmd FileType make setlocal noexpandtab
  autocmd FileType markdown setlocal wrap linebreak

  " Help in vertical split
  autocmd FileType help wincmd L

augroup END

" -----------------------------------------------------------------------------
" Commands
" -----------------------------------------------------------------------------

" Sudo write
command! W execute 'silent! write !sudo tee % >/dev/null' | edit!

" Quick edit vimrc
command! Vimrc edit ~/.vimrc
command! Source source ~/.vimrc

" -----------------------------------------------------------------------------
" Local customisations
" -----------------------------------------------------------------------------

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
