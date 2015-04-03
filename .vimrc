filetype off

call plug#begin()

Plug 'airblade/vim-gitgutter'
Plug 'akracun/vitality.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'bling/vim-airline'
Plug 'c9s/perlomni.vim'
Plug 'chrisbra/csv.vim'
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'
Plug 'gregsexton/gitv'
Plug 'honza/dockerfile.vim'
Plug 'inside/vim-search-pulse'
Plug 'itchyny/calendar.vim'
Plug 'kien/ctrlp.vim'
Plug 'kshenoy/vim-signature'
Plug 'majutsushi/tagbar'
Plug 'msanders/snipmate.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'pjcj/vim-hl-var'
Plug 'saltstack/salt-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'sjl/gundo.vim'
Plug 'Spaceghost/vim-matchit'
Plug 'stefandtw/quickfix-reflector.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/diffchar.vim'
Plug 'vim-scripts/YankRing.vim'
Plug 'zirrostig/vim-schlepp'

if has ("nvim") || !has ("lua")
    " echo "YCM"
    Plug 'Valloric/YouCompleteMe', { 'do': './install.sh' }
    let g:ycm_min_num_of_chars_for_completion               = 1
    let g:ycm_min_num_identifier_candidate_chars            = 2
    let g:ycm_filetype_whitelist                            = { '*': 1 }
    let g:ycm_filetype_blacklist                            = {}
    let g:ycm_allow_changing_updatetime                     = 0
    let g:ycm_complete_in_strings                           = 1
    let g:ycm_complete_in_comments                          = 1
    let g:ycm_collect_identifiers_from_comments_and_strings = 1
    let g:ycm_collect_identifiers_from_tags_files           = 1
    let g:ycm_seed_identifiers_with_syntax                  = 1
    let g:ycm_add_preview_to_completeopt                    = 1
    let g:ycm_auto_trigger                                  = 1
    let g:ycm_cache_omnifunc                                = 0
else
    " echo "neocomplete"
    Plug 'Shougo/neocomplete.vim'
    let g:acp_enableAtStartup                               = 0
    let g:neocomplete#enable_at_startup                     = 1
    let g:neocomplete#enable_smart_case                     = 1
    let g:neocomplete#sources#syntax#min_keyword_length     = 1
    let g:neocomplete#same_filetypes                        = {}
    let g:neocomplete#same_filetypes._                      = '_'
endif

call plug#end()

if has ("nvim")
    tnoremap <Esc> <C-\><C-n>
endif

filetype plugin indent on

set autoindent
set autowrite
set backspace=indent,eol,start
set backup
set backupcopy=yes,breakhardlink
set backupdir=~/g/tmp/vim/
set backupext=.bak
set nocompatible
" set clipboard=unnamed  # yanks, deletes and changes go into X clipboard
set colorcolumn=80,120
set complete=.,w,b,u,U,k/usr/dict/words,i,t
set cmdheight=3
set dictionary=/usr/dict/words
set diffopt=filler,vertical
set directory=>~/g/tmp/vim/
set encoding=utf-8
set errorformat=%f:%l:%m
set expandtab
set exrc
set formatoptions=tcrqnl
" set grepprg=tcgrep\ -nrq
set grepprg=git\ grep\ -nw
set guifont=inconsolata\ \for\ powerline\ 12
set history=1000
set icon
set incsearch
set joinspaces
set laststatus=2
set list
set listchars=tab:»\ ,trail:·
" set makeprg=nmake
set modelines=0
set mouse=a
set mousefocus
set mousehide
set mousemodel=popup_setpos
set number
" set patchmode=.org
set path=,,.,/usr/include
set report=1
set ruler
set scrolloff=3
set shell=zsh
set shiftwidth=4
set showcmd
set showmatch
set showmode
set nosmartindent
set nosmarttab
set shiftround
set softtabstop=0
set suffixes=.d,.e,.o,.org,.bak,~
set tabstop=8
set tags=./tags,tags,../tags,../../tags,../../../tags,../../../../tags
set tagrelative
set textwidth=80
set title
set ttimeoutlen=50
set ttyfast
set updatetime=250
set undodir=~/g/tmp/vim
set undofile
set undolevels=1000
set viminfo='50
set wildmenu
set wildmode=list:longest,full
set whichwrap=19
set writebackup

" for Vim 7.3
" set relativenumber

let mapleader = ","

" alter regex handling to "normal" syntax
nnoremap / /\v
vnoremap / /\v

set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>

" Java options
set cinoptions+=j1  " anonymous classes
let java_comment_strings=1
let java_highlight_java_lang_ids=1
let java_highlight_all=1
let java_highlight_debug=1
let java_ignore_javadoc=1
let java_highlight_java_lang_ids=1
let java_highlight_functions="style"

" Save position of cursor in file
au BufReadPost * if line("'\"") != 0
au BufReadPost *   normal `"
au BufReadPost * endif

syntax enable
set background=dark
colorscheme solarized
highlight clear SignColumn
" let g:solarized_contrast="normal"
" let g:solarized_termcolors=256
" set t_Co=256
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_indent_levels         = 40
function! Setup_indent_guides()
    if &shiftwidth < 3
        let g:indent_guides_guide_size  = 0
        let g:indent_guides_auto_colors = 0
        hi IndentGuidesEven  ctermbg=black
        " echo "small: " &shiftwidth
    else
        let g:indent_guides_guide_size  = 1
        let g:indent_guides_start_level = 2
        let g:indent_guides_auto_colors = 0
        hi IndentGuidesOdd  ctermbg=black
        hi IndentGuidesEven ctermbg=black
        " echo "big: " &shiftwidth
    endif
endfunction
autocmd VimEnter,Colorscheme * call Setup_indent_guides()

" set rtp+=~/g/base/powerline/powerline/bindings/vim
let g:airline_powerline_fonts = 1

au BufNewFile,BufReadPost template/* set ft=tt2html
au BufNewFile,BufReadPost *.tt2      set ft=tt2html
au BufNewFile,BufReadPost *.tt       set ft=tt2html
au BufNewFile,BufReadPost *.t        set ft=perl
au BufNewFile,BufReadPost *.pd       set ft=perl

au BufRead *tmp/ml/mutt-*            setlocal tw=72 spell spelllang=en_gb

au Filetype perl source ~/.vim/local/perl_local.vim
au Filetype gitcommit setlocal colorcolumn=50,80

autocmd InsertLeave * if expand('%') != '' | update | endif

" closetag plugin
" au Filetype html,xml,xsl source ~/.vim/plugin/closetag.vim
au FileType xhtml,xml,html,tt2html so ~/.vim/plugin/html_autoclosetag.vim
au FileType xhtml,xml,html,tt2html setlocal sw=2

au FileType * exe('setl dict^='.$VIMRUNTIME.'/syntax/'.&filetype.'.vim')

" taglist plugin
let Tlist_Use_SingleClick      = 1
let Tlist_Use_Right_Window     = 1
let Tlist_Auto_Open            = 0
let Tlist_Show_One_File        = 0
let Tlist_WinWidth             = 32
let Tlist_Compact_Format       = 1
let Tlist_Exit_OnlyWindow      = 1
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Process_File_Always  = 1
let Tlist_Enable_Fold_Column   = 0
let Tlist_Show_Menu            = 1

let g:tagbar_width            = 32
let g:tagbar_autoclose        = 1
let g:tagbar_autofocus        = 1
let g:tagbar_sort             = 1
let g:tagbar_compact          = 1
let g:tagbar_indent           = 1
let g:tagbar_show_visibility  = 1
let g:tagbar_show_linenumbers = 0
let g:tagbar_singleclick      = 1
let g:tagbar_autoshowtag      = 1

autocmd BufReadPost fugitive://* set bufhidden=delete
autocmd QuickFixCmdPost *grep* cwindow

augroup gitgutter
    autocmd BufEnter * call GitGutter()
augroup END
highlight GitGutterAdd              ctermbg=black
highlight GitGutterChange           ctermbg=black
highlight GitGutterDelete           ctermbg=black
highlight GitGutterChangeDelete     ctermbg=black
highlight GitGutterAddLine          ctermbg=black
highlight GitGutterChangeLine       ctermbg=black
highlight GitGutterDeleteLine       ctermbg=black
highlight GitGutterChangeDeleteLine ctermbg=black
let g:gitgutter_signs           = 1
let g:gitgutter_highlight_lines = 0
let g:gitgutter_realtime        = 1
" ]h and [h
nnoremap <leader>gn :GitGutterNextHunk<CR>
nnoremap <leader>gp :GitGutterPrevHunk<CR>

let g:vitality_tumx_can_focus = 1

let g:csv_autocmd_arrange = 1

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags
" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl =
 \ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'

" diffchar sets defaults if these aren't set
nmap <silent> abc1 <Plug>ToggleDiffCharAllLines
nmap <silent> abc2 <Plug>ToggleDiffCharCurrentLine
nmap <silent> abc3 <Plug>JumpDiffCharPrevStart
nmap <silent> abc4 <Plug>JumpDiffCharNextStart
nmap <silent> abc5 <Plug>JumpDiffCharPrevEnd
nmap <silent> abc6 <Plug>JumpDiffCharNextEnd

let g:calendar_google_calendar = 1
let g:calendar_google_task     = 1

let g:vim_search_pulse_disable_auto_mappings = 1
nmap n n<Plug>Pulse
nmap N N<Plug>Pulse
nmap * *<Plug>Pulse``
cmap <enter> <Plug>PulseFirst

vmap <unique> k <Plug>SchleppUp
vmap <unique> j <Plug>SchleppDown
vmap <unique> h <Plug>SchleppLeft
vmap <unique> l <Plug>SchleppRight
nnoremap k gk
nnoremap j gj

au FocusLost * silent! wa

set guioptions=ag

nnoremap <silent> <F1> :NERDTreeToggle<CR>
" nnoremap <silent> <F2> :TlistToggle<CR>
nnoremap <silent> <F2> :TagbarToggle<CR>
nmap <F3> 
nnoremap <F4> :execute "tjump " . expand("<cword>")<CR>
nnoremap <S-F4> :tnext<CR>
map [26~ <S-F4>
nnoremap <M-F4> :tprev<CR>
" map OS <M-F4>
nnoremap <F5> :execute "silent make" <Bar> botright copen<CR><C-L>
nnoremap <S-F5> :w<CR>:SyntasticCheck<CR>:ll<CR>
map [28~ <S-F5>
nnoremap <F6> :cprevious<CR>
nnoremap <S-F6> :lprevious<CR>
map [29~ <S-F6>
nnoremap <F7> :cnext<CR>
nnoremap <S-F7> :lnext<CR>
map [31~ <S-F7>
nnoremap <F8> :execute "silent grep! " . expand("<cword>") <Bar> botright copen<CR><C-L>
nnoremap <F9> :cclose<Bar>:lclose<CR>
nnoremap <silent> <F10> w
nnoremap <Home> 1G
nnoremap <End> Gz-
nnoremap <PageUp> 0
nnoremap <PageDown> 0
nnoremap <Insert> [[(z<CR>]]
nnoremap <Del> j]](z<CR>]]
nnoremap <F12> 

imap <F2> sub {<CR>my $self = shift;<CR>my () = @_;<CR>}<ESC>%hi<Space>
imap <F3> $self->{}<ESC>i
imap <F4> $self->

nnoremap <leader>gu :GundoToggle<CR>

" This toggles the hlsearch flag, then reports the current state of the flag.
nnoremap <C-M-h> :set hls!<cr><bar>:echo "HLSearch: " . strpart("OffOn",3*&hlsearch,3)<cr>

function! Tab_or_complete()
    if col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^\w'
        return "\<C-P>"
    else
        return "\<C-V>\<Tab>"
endfunction
" inoremap <Tab> <C-R>=Tab_or_complete()<CR>

" let g:SuperTabMappingForward  = '<s-tab>'
" let g:SuperTabMappingBackward = '<tab>'

inoremap # X<BS>#
cnoremap <C-w> <C-I>

map! <S-Insert> <C-R>*

" Allow p to paste current copy buffer onto currently selected text.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" delete trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

nnoremap <leader>q gqip
nnoremap <leader>v V`]

" toggle cursorline and cursorcolumn
nnoremap <Leader>cl :set cursorline! cursorcolumn!<CR>

" Devel::Cover coverage information
nnoremap <Leader>c :source cover_db/coverage.vim<CR>

" spelling
nnoremap <leader>se :setlocal spell spelllang=en_gb<CR>
nnoremap <leader>sd :setlocal spell spelllang=de_ch<CR>
nnoremap <leader>so :set nospell<CR>

" paste
map <leader>p :set paste!<CR>

" yankring
map <leader>m :YRShow<CR>
let g:yankring_max_history = 1000
let g:yankring_min_element_length = 1
let g:yankring_max_element_length = 40000 " 40K
let g:yankring_max_display = 500
let g:yankring_window_height = 25
let g:yankring_manage_numbered_reg = 1
let g:yankring_history_dir = '$HOME/.vim'

" syntastic
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { "mode": "passive",
    \ "active_filetypes": [],
    \ "passive_filetypes": [] }
let g:syntastic_auto_loc_list = 1
let g:syntastic_perl_checkers = ["perl"]
let g:syntastic_enable_perl_checker = 1
let g:syntastic_shell_checkers = ["shellcheck"]
highlight SyntasticErrorSign   ctermbg=0 ctermfg=1 cterm=bold
highlight SyntasticWarningSign ctermbg=0 ctermfg=5 cterm=bold

cmap w!! w !sudo tee % >/dev/null

let NERDSpaceDelims = 1
map - <Plug>NERDCommenterToggle

" if &term == "rxvt-unicode-256color"
    " let &t_SI = "\<Esc>[3 q"
    " let &t_EI = "\<Esc>[0 q"
" endif

nnoremap <F11> :silent! write <Bar> CtrlPBuffer<CR>
let g:ctrlp_map = '<F99>'  " Not used
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_reuse_window = 'quickfix'
let g:ctrlp_working_path_mode = 'ra'
" let g:ctrlp_root_markers = ['.git']
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/](tmp|blib|cover_db|pdldb)$',
    \ 'file': '\v\nytprof$',
    \ }
let g:ctrlp_extensions = ['tag', 'changes']
let g:ctrlp_mruf_relative = 1
let g:ctrlp_use_caching = 0
let g:ctrlp_match_window = 'bottom,order:ttb,min:25,max:25,results:25'
let g:ctrlp_prompt_mappings = {
    \ 'PrtBS()': ['<bs>', '<c-]>'],
    \ 'PrtDelete()': ['<del>'],
    \ 'PrtDeleteWord()': ['<c-w>'],
    \ 'PrtClear()': ['<c-u>'],
    \ 'PrtSelectMove("j")': ['<c-j>', '<down>'],
    \ 'PrtSelectMove("k")': ['<c-k>', '<up>', 'OA'],
    \ 'PrtSelectMove("t")': ['<Home>', '<kHome>'],
    \ 'PrtSelectMove("b")': ['<End>', '<kEnd>'],
    \ 'PrtSelectMove("u")': ['<PageUp>', '<kPageUp>'],
    \ 'PrtSelectMove("d")': ['<PageDown>', '<kPageDown>'],
    \ 'PrtHistory(-1)': ['<c-n>'],
    \ 'PrtHistory(1)': ['<c-p>'],
    \ 'AcceptSelection("e")': ['<cr>', '<2-LeftMouse>'],
    \ 'AcceptSelection("h")': ['<c-x>', '<c-cr>', '<c-s>'],
    \ 'AcceptSelection("t")': ['<c-t>'],
    \ 'AcceptSelection("v")': ['<c-v>', '<RightMouse>'],
    \ 'ToggleFocus()': ['<s-tab>'],
    \ 'ToggleRegex()': ['<c-r>'],
    \ 'ToggleByFname()': ['<c-d>'],
    \ 'ToggleType(1)': ['<c-f>', '<c-up>', '<F11>'],
    \ 'ToggleType(-1)': ['<c-b>', '<c-down>'],
    \ 'PrtExpandDir()': ['<tab>'],
    \ 'PrtInsert("c")': ['<MiddleMouse>', '<insert>'],
    \ 'PrtInsert()': ['<c-\>'],
    \ 'PrtCurStart()': ['<c-a>'],
    \ 'PrtCurEnd()': ['<c-e>'],
    \ 'PrtCurLeft()': ['<c-h>', '<left>', '<c-^>'],
    \ 'PrtCurRight()': ['<c-l>', '<right>'],
    \ 'PrtClearCache()': ['<F5>'],
    \ 'PrtDeleteEnt()': ['<F7>'],
    \ 'CreateNewFile()': ['<c-y>'],
    \ 'MarkToOpen()': ['<c-z>'],
    \ 'OpenMulti()': ['<c-o>'],
    \ 'PrtExit()': ['<esc>', '<c-c>', '<c-g>'],
    \ }

abbr ,, =>

function! MyToHtml(line1, line2)
    " make sure to generate in the correct format
    let old_css = 1
    if exists('g:html_use_css')
        let old_css = g:html_use_css
    endif
    let g:html_use_css = 0

    " generate and delete unneeded lines
    exec a:line1.','.a:line2.'TOhtml'
    %g/<body/normal k$dgg

    " convert body to a table
    %s/<body\s*\(bgcolor="[^"]*"\)\s*text=\("[^"]*"\)\s*onload='JumpToLine();'>/<table \1 cellPadding=0><tr><td><font color=\2>/
    %s#</body>\(.\|\n\)*</html>#\='</font></td></tr></table>'#i

    " solarised colours
    %s/808080/002b36/g  " base03 - background
    %s/000000/073642/g  " base02 - gutter
    %s/8080ff/839496/g  " base0  - body text
    %s/00ff00/93a1a1/g  " base1  - line numbers
    %s/008000/b58900/g  " yellow - sub
    %s/0000c0/268bd2/g  " blue   - sub name
    %s/804000/cb4b16/g  " orange - vars
    %s/c00000/dc322f/g  " red    - punctuation

    " font
    %s/monospace/inconsolata,monospace/g

    redraw  " no hit enter ...

    " restore old setting
    let g:html_use_css = old_css
endfunction
command! -range=% MyToHtml :call MyToHtml(<line1>,<line2>)

let s:localrc = expand($HOME . '/.vimrc.local')
if filereadable(s:localrc)
    exec 'source ' . s:localrc
endif
