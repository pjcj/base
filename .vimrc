set encoding=utf-8
scriptencoding utf-8
filetype off

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction

call plug#begin()

" !sort -t/ -k2
Plug 'sgur/ctrlp-extensions.vim'              " cmdline, yank and menu for ctrlp
Plug 'ctrlpvim/ctrlp.vim'                                                " <F11>
Plug 'vim-scripts/diffchar.vim'                       " show diffs on char basis
Plug 'docker/docker', { 'rtp': '/contrib/syntax/vim/' }          " docker syntax
Plug 'gregsexton/gitv'                                                   " <F10>
Plug 'sjl/gundo.vim'                                                       " ,gu
Plug 'scrooloose/nerdtree'                                                " <F1>
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'amperser/proselint', { 'rtp': '/plugins/vim/syntastic_proselint' }
Plug 'stefandtw/quickfix-reflector.vim'      " edit then save in quickfix window
Plug 'saltstack/salt-vim'                                    " salt highlighting
Plug 'ervandew/supertab'
Plug 'scrooloose/syntastic'
Plug 'majutsushi/tagbar'                                                  " <F2>
Plug 'wellle/tmux-complete.vim'
Plug 'tpope/vim-abolish'               " :%Subvert/facilit{y,ies}/building{,s}/g
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'gioele/vim-autoswap'                        " deal with swapfiles sensibly
Plug 'tpope/vim-commentary'                                                 " gc
Plug 'tpope/vim-dispatch'                          " asynchronous build and test
Plug 'junegunn/vim-easy-align'                                     " = ^X<regex>
Plug 'tpope/vim-eunuch'                                          " Unix commands
Plug 'tpope/vim-fugitive'                                  " :Gdiff :Gstatus ,gg
Plug 'airblade/vim-gitgutter'                              " ,hn ,hp ,hv ,hs ,hr
Plug 'ludovicchabant/vim-gutentags'                   " generate tags on the fly
Plug 'pjcj/vim-hl-var'
Plug 'nathanaelkane/vim-indent-guides'    " configured for indent of two or four
Plug 'suan/vim-instant-markdown'
Plug 'vasconcelloslf/vim-interestingwords'                           " ,k ,K n N
Plug 'Spaceghost/vim-matchit'                                                " %
Plug 'terryma/vim-multiple-cursors'                                         " ^n
Plug 'tpope/vim-repeat'
Plug 'zirrostig/vim-schlepp'                               " highlight then hjkl
Plug 'inside/vim-search-pulse'                                           " * n N
Plug 'kshenoy/vim-signature'                          " mx dmx m, m. m<Space> m/
Plug 'tpope/vim-surround'                                     " cs'" cs'<q> cst'
Plug 'baskerville/vim-sxhkdrc'                                     "sxhkd syntax
Plug 'tmux-plugins/vim-tmux'                 " tmux syntax highlighting and more
Plug 'jszakmeister/vim-togglecursor'             " change cursor shape on insert
Plug 'todesking/vint-syntastic'                                     " vim linter
Plug 'akracun/vitality.vim'                           " deal with focus for tmux

Plug 'Shougo/unite.vim'                                " <space><space> <space>s
Plug 'Shougo/vimproc.vim', { 'do': 'make' }                      " async library

" Unite plugins
Plug 'Shougo/neomru.vim'                                         " MRU for unite
Plug 'yuku-t/unite-git'
Plug 'lambdalisue/unite-grep-vcs'
Plug 'Shougo/unite-help'
Plug 'Shougo/unite-outline'
Plug 'soh335/unite-perl-module'
Plug 'mpendse/unite-search-history'
Plug 'tsukkee/unite-tag'
Plug 'sanford1/unite-unicode'
Plug 'LeafCage/yankround.vim'

" Plug 'itchyny/calendar.vim'
" Plug 'junegunn/gv.vim'                                         " :GV :GV! gb q
" Plug 'msanders/snipmate.vim'
" Plug 'Raimondi/delimitMate'         " insert mode quote/bracket autocompletion
" Plug 'tpope/vim-obsession'
" Plug 'vim-scripts/YankRing.vim'
" YankRing messes up xp unless min_element_length is 1, in which case it's slow

if has ('nvim')
    Plug 'pjcj/neovim-colors-solarized-truecolor-only'

    Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
    let g:deoplete#enable_at_startup            = 1
    let g:neocomplete#enable_smart_case         = 1
    let g:deoplete#disable_auto_complete        = 0
    let g:deoplete#auto_completion_start_length = 2
    let g:deoplete#sources                      = {}
    let g:deoplete#sources._                    =
        \ ['member', 'buffer', 'tag', 'file', 'tmux-complete', 'dictionary']

    let g:tmuxcomplete#trigger = ''

    " Plug 'benekastah/neomake'
    " autocmd! BufWritePost,BufEnter * Neomake
    " let g:neomake_list_height              = 10
    " let g:neomake_open_list                = 2
    " let g:neomake_serialize                = 1
    " let g:neomake_serialize_abort_on_error = 1
    " let g:neomake_verbose                  = 2
    " let g:neomake_sh_enabled_checkers      = ['shellcheck']
    " let g:neomake_vim_enabled_checkers     = ['vint']
else
    Plug 'altercation/vim-colors-solarized'

    " echo 'neocomplete'
    Plug 'Shougo/neocomplete.vim'
    let g:acp_enableAtStartup                           = 0
    let g:neocomplete#enable_at_startup                 = 1
    let g:neocomplete#enable_smart_case                 = 1
    let g:neocomplete#sources#syntax#min_keyword_length = 1
    let g:neocomplete#same_filetypes                    = {}
    let g:neocomplete#same_filetypes._                  = '_'
    let g:neocomplete#skip_auto_completion_time         = ''
    let g:neocomplete#sources                           = {}
    let g:neocomplete#sources._                         = ['buffer']
    let g:neocomplete#sources.cpp                       = ['buffer', 'dictionary']
    let g:neocomplete#keyword_patterns                  = {}
    let g:neocomplete#keyword_patterns.xml              = '\h\w*'
    let g:neocomplete#text_mode_filetypes               = {}
    let g:neocomplete#text_mode_filetypes.xml           = 1

    let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'default'  : '',
        \ 'vimshell' : $HOME.'/.vimshell_hist',
        \ 'scheme'   : $HOME.'/.gosh_completions'
        \ }

    " Enable heavy omni completion.
    Plug 'c9s/perlomni.vim'
    let g:neocomplete#sources#omni#input_patterns = {}
    let g:neocomplete#force_omni_input_patterns   = {}
    augroup omni_filetypes
        autocmd!
        autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
        autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags
    augroup END
    " For perlomni.vim setting.
    " https://github.com/c9s/perlomni.vim
    let g:neocomplete#sources#omni#input_patterns.perl =
        \ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
    let g:neocomplete#enable_onmi_fallback = 1
    let g:neocomplete#fallback_mappings =
        \ ["\<C-x>\<C-o>", "\<C-x>\<C-n>"]
    function! sqlcomplete#Complete(findstart, base)
        if a:findstart
            return -1
        endif
        return []
    endfunc
endif

call plug#end()

if has ('nvim')
    " Use head matcher instead of fuzzy matcher
    call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
    " Order completions.
    call deoplete#custom#set('member',     'rank', 450)
    call deoplete#custom#set('buffer',     'rank', 400)
    call deoplete#custom#set('file',       'rank', 300)
    call deoplete#custom#set('tag',        'rank', 200)
    call deoplete#custom#set('dictionary', 'rank', 100)
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
set clipboard=unnamedplus  " yanks, deletes and changes go into + clipboard
set colorcolumn=80,120
set complete=.,w,b,u,U,k/usr/share/dict/words,i,t
set cmdheight=3
set dictionary=/usr/share/dict/words
set diffopt=filler,vertical
set directory=>~/g/tmp/vim/
set errorformat=%f:%l:%m
set expandtab
set exrc
set formatoptions=tcrqnl
set grepprg=git\ grep\ -nw
set guifont=inconsolata\ \for\ powerline\ 12
set history=1000
set icon
set incsearch
set joinspaces
set laststatus=2
set lazyredraw
set list
set listchars=tab:»\ ,trail:·
set modelines=0
set mouse=a
set mousefocus
set mousehide
set mousemodel=popup_setpos
set number
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
set textwidth=0
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

let mapleader = ','

" alter regex handling to 'normal' syntax
nnoremap / /\v
vnoremap / /\v

set ignorecase
set smartcase
set incsearch
set showmatch
set hlsearch

" Java options
set cinoptions+=j1  " anonymous classes
let java_comment_strings=1
let java_highlight_java_lang_ids=1
let java_highlight_all=1
let java_highlight_debug=1
let java_ignore_javadoc=1
let java_highlight_java_lang_ids=1
let java_highlight_functions='style'

" Save position of cursor in file
augroup save_position
    autocmd!
    autocmd BufReadPost * if line("'\"") != 0
    autocmd BufReadPost *   normal `"
    autocmd BufReadPost * endif
augroup END

syntax enable
set termguicolors
set background=dark
" let g:solarized_contrast='high'
" let g:solarized_visibility='normal'
colorscheme solarized
let s:base03  = '#001920'
let s:base02  = '#022731'
let s:base01  = '#586e75'
let s:base00  = '#657b83'
let s:base0   = '#839496'
let s:base1   = '#93a1a1'
let s:base2   = '#eee8d5'
let s:base3   = '#fdf6e3'
let s:yellow  = '#b58900'
let s:orange  = '#cb4b16'
let s:red     = '#dc322f'
let s:magenta = '#d33682'
let s:violet  = '#6c71c4'
let s:blue    = '#268bd2'
let s:cyan    = '#2aa198'
let s:green   = '#859900'
let s:normal  = '#9599dc'

function! Set_colour(group, part, colour)
    execute 'highlight ' . a:group . ' ' . a:part . '=' . a:colour
endfunc

highlight Comment cterm=italic
call Set_colour('Normal',       'guifg', s:normal )
call Set_colour('SpecialKey',   'guibg', s:base03 )
call Set_colour('SpellBad',     'guibg', s:violet )
call Set_colour('SpellBad',     'guifg', s:base03 )
call Set_colour('SpellBad',     'gui',   'NONE'   )
call Set_colour('SpellCap',     'guibg', s:blue   )
call Set_colour('SpellCap',     'guifg', s:base03 )
call Set_colour('SpellCap',     'gui',   'NONE'   )
call Set_colour('SpellRare',    'guibg', s:yellow )
call Set_colour('SpellRare',    'guifg', s:base03 )
call Set_colour('SpellRare',    'gui',   'NONE'   )
call Set_colour('SpellLocal',   'guibg', s:green  )
call Set_colour('SpellLocal',   'guifg', s:base03 )
call Set_colour('SpellLocal',   'gui',   'NONE'   )
call Set_colour('LineNr',       'guibg', s:base03 )
call Set_colour('CursorLineNr', 'guibg', s:base03 )
call Set_colour('DiffAdd',      'guibg', s:base03 )
call Set_colour('DiffChange',   'guibg', s:base03 )
call Set_colour('DiffDelete',   'guibg', s:base03 )
call Set_colour('Search',       'guibg', s:violet )
call Set_colour('Search',       'guifg', s:base03 )
call Set_colour('Search',       'gui',   'NONE'   )
call Set_colour('TabLineSel',   'guibg', s:base03 )
call Set_colour('TabLineSel',   'guifg', s:violet )

nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists('*synstack')
    return
  endif
  echo map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
endfunc

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_indent_levels         = 40
function! Setup_indent_guides()
    hi IndentGuidesEven ctermbg=black
    call Set_colour('IndentGuidesEven', 'guibg', s:base02)
    if &shiftwidth < 3
        let g:indent_guides_guide_size  = 0
        let g:indent_guides_auto_colors = 0
        " echo 'small: ' &shiftwidth
    else
        let g:indent_guides_guide_size  = 1
        let g:indent_guides_start_level = 2
        let g:indent_guides_auto_colors = 0
        hi IndentGuidesOdd ctermbg=black
        call Set_colour('IndentGuidesOdd', 'guibg', s:base02)
        " echo 'big: ' &shiftwidth
    endif
endfunction
autocmd VimEnter,Colorscheme * call Setup_indent_guides()

let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1

augroup file_types
    autocmd!
    autocmd BufNewFile,BufReadPost template/* set ft=tt2html
    autocmd BufNewFile,BufReadPost *.tt2      set ft=tt2html
    autocmd BufNewFile,BufReadPost *.tt       set ft=tt2html
    autocmd BufNewFile,BufReadPost *.t        set ft=perl
    autocmd BufNewFile,BufReadPost *.pd       set ft=perl
    autocmd BufNewFile             *.pm       0r ~/.vim/templates/module.pm
    autocmd BufNewFile             *.pl       0r ~/.vim/templates/program.pl
    autocmd BufNewFile             *.t        0r ~/.vim/templates/test.t

    autocmd Filetype perl setlocal path+=lib tw=80

    autocmd BufRead *tmp/ml/mutt-*
        \ setlocal colorcolumn=72 tw=72 spell spelllang=en_gb
    autocmd Filetype gitcommit
        \ setlocal colorcolumn=50,72 tw=72 spell spelllang=en_gb

    autocmd InsertLeave * if expand("%") != "" | update | endif

    autocmd FileType xhtml,xml,html,tt2html so ~/.vim/plugin/html_autoclosetag.vim
    autocmd FileType xhtml,xml,html,tt2html setlocal sw=2

    " This prevents deoplete autocompletion from working.
    " autocmd FileType * exe("setl dict^=".$VIMRUNTIME."/syntax/".&filetype.".vim")
augroup END

let g:gutentags_exclude = ['blib']
" can be extended with '*/sub/path' if required

let NERDTreeShowHidden=1

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

augroup git
    autocmd!
    autocmd BufReadPost fugitive://* set bufhidden=delete
    autocmd QuickFixCmdPost *grep* cwindow
augroup END
nnoremap <leader>gg :Gcommit -v<CR>

augroup gitgutter
    autocmd!
    autocmd BufEnter * call GitGutter()
augroup END
highlight link GitGutterAdd              DiffAdd
highlight link GitGutterChange           DiffChange
highlight link GitGutterDelete           DiffDelete
highlight link GitGutterChangeDelete     DiffDelete
highlight link GitGutterAddLine          DiffAdd
highlight link GitGutterChangeLine       DiffChange
highlight link GitGutterDeleteLine       DiffDelete
highlight link GitGutterChangeDeleteLine DiffDelete
let g:gitgutter_signs           = 1
let g:gitgutter_highlight_lines = 0
let g:gitgutter_realtime        = 1
let g:gitgutter_eager           = 1
let g:gitgutter_map_keys        = 0
nnoremap <leader>hn :GitGutterNextHunk<CR>
nnoremap <leader>hp :GitGutterPrevHunk<CR>
nnoremap <leader>hv :GitGutterPreviewHunk<CR>
nnoremap <leader>hs :GitGutterStageHunk<CR>
nnoremap <leader>hr :GitGutterRevertHunk<CR>

let g:SignatureMarkTextHLDynamic = 1

let g:vitality_tumx_can_focus = 1

let g:csv_autocmd_arrange = 1

" diffchar sets defaults if these aren't set
nmap <silent> abc1 <Plug>ToggleDiffCharAllLines
nmap <silent> abc2 <Plug>ToggleDiffCharCurrentLine
nmap <silent> abc3 <Plug>JumpDiffCharPrevStart
nmap <silent> abc4 <Plug>JumpDiffCharNextStart
nmap <silent> abc5 <Plug>JumpDiffCharPrevEnd
nmap <silent> abc6 <Plug>JumpDiffCharNextEnd

let g:calendar_google_calendar = 1
let g:calendar_google_task     = 1

" get vim-search-pulse and vim-interestingwords working together
let g:vim_search_pulse_disable_auto_mappings = 1
let g:vim_search_pulse_mode = 'pattern'  " or cursor_line
let g:interestingWordsGUIColors =
    \ ['#72b5e4', '#f0c53f', '#ff8784', '#c5c7f1',
    \  '#c2d735', '#78d3cc', '#ea8336']
" nmap * *``:call search_pulse#Pulse()<CR>
nmap * *``:call InterestingWords('n')<CR>:set nohls<CR>
nnoremap <silent> <leader>k :call InterestingWords('n')<CR>
vnoremap <silent> <leader>k :call InterestingWords('v')<CR>
nnoremap <silent> <leader>K :call UncolorAllWords()<CR>
nnoremap <silent> n :call WordNavigation(1)<CR>:call search_pulse#Pulse()<CR>
nnoremap <silent> N :call WordNavigation(0)<CR>:call search_pulse#Pulse()<CR>
augroup Pulse
    autocmd!
    autocmd User PrePulse  set cursorline! cursorcolumn!
    autocmd User PostPulse set cursorline! cursorcolumn!
augroup END

vnoremap <unique> k <Plug>SchleppUp
vnoremap <unique> j <Plug>SchleppDown
vnoremap <unique> h <Plug>SchleppLeft
vnoremap <unique> l <Plug>SchleppRight
nnoremap k gk
nnoremap j gj

augroup autowrite
    autocmd!
    autocmd FocusLost * silent! wa
augroup END

set guioptions=ag

nnoremap <F1>       :GitGutterStageHunk<CR>
nnoremap <F2>       :GitGutterPrevHunk<CR>
nnoremap <F3>       :GitGutterNextHunk<CR>
nnoremap <S-F1>     :NERDTreeToggle<CR>
nnoremap <S-F2>     :TagbarToggle<CR>
nnoremap <F4>       :execute "tjump " . expand("<cword>")<CR>
nnoremap <S-F4>     :tnext<CR>
nnoremap <M-F4>     :tprev<CR>
nnoremap <F5>       :execute "silent make" <Bar> botright copen<CR><C-L>
nnoremap <S-F5>     :w<CR>:SyntasticCheck<CR>:Errors<CR>
nnoremap <F6>       :cprevious<CR>
nnoremap <S-F6>     :lprevious<CR>
nnoremap <F7>       :cnext<CR>
nnoremap <S-F7>     :lnext<CR>
nnoremap <F8>       :execute "silent grep! " . expand("<cword>")
                        \ <Bar> botright copen<CR><C-L>
nnoremap <F9>       :cclose<Bar>:lclose<Bar>:pclose<CR>
nnoremap <silent>   <S-F10> w
nnoremap §          :Gitv --all<CR>
nnoremap °          :Gitv! --all<CR>
vnoremap °          :Gitv! --all<CR>
nnoremap <Home>     1G
nnoremap <End>      Gz-
nnoremap <PageUp>   0
nnoremap <PageDown> 0
nnoremap <Insert>   [[(z<CR>]]
nnoremap <Del>      j]](z<CR>]]
nnoremap <F12>      

imap <F2> sub {<CR>my $self = shift;<CR>my () = @_;<CR>}<ESC>%hi<Space>
imap <F3> $self->{}<ESC>i
imap <F4> $self->

map [26~   <S-F4>
map [28~   <S-F5>
map [29~   <S-F6>
map [31~   <S-F7>
map [21;2~ <S-F10>
map <F13>    <S-F1>
map <F14>    <S-F2>
map <F15>    <S-F3>
map <F16>    <S-F4>
map <F17>    <S-F5>
map <F18>    <S-F6>
map <F19>    <S-F7>
map <F22>    <S-F10>

nnoremap <leader>gu :GundoToggle<CR>

" This toggles the hlsearch flag, then reports the current state of the flag.
nnoremap <leader><space> :set hls!<CR><BAR>
                       \ :echo "HLSearch: " . strpart("OffOn",3*&hlsearch,3)<CR>

let g:SuperTabDefaultCompletionType = '<c-n>'

let g:Gitv_WipeAllOnClose      = 1
let g:Gitv_WrapLines           = 0
let g:Gitv_OpenPreviewOnLaunch = 1
let g:Gitv_CommitStep          = 100

inoremap # X<BS>#
cnoremap <C-w> <C-I>

map! <S-Insert> <C-R>*

" Allow p to paste current copy buffer onto currently selected text.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" delete trailing whitespace
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=""<CR>

nnoremap <leader>q gqip
nnoremap <leader>v V`]

" toggle cursorline and cursorcolumn
nnoremap <Leader>ccl :set cursorline! cursorcolumn!<CR>

" Devel::Cover coverage information
nnoremap <Leader>c :source cover_db/coverage.vim<CR>

" spelling
nnoremap <leader>se :setlocal spell spelllang=en_gb<CR>
nnoremap <leader>sd :setlocal spell spelllang=de_ch<CR>
nnoremap <leader>so :set nospell<CR>

" paste
nnoremap <leader>p :set paste!<CR>

" yankring
map <leader>m :YRShow<CR>
let g:yankring_max_history         = 1000
let g:yankring_min_element_length  = 2
let g:yankring_max_element_length  = 40000  " 40K
let g:yankring_max_display         = 500
let g:yankring_window_height       = 25
let g:yankring_manage_numbered_reg = 1
let g:yankring_history_dir         = '$HOME/.vim'

" syntastic
let g:syntastic_check_on_open            = 1
let g:syntastic_check_on_wq              = 0
let g:syntastic_aggregate_errors         = 1  " doesn't seem to work
let g:syntastic_sort_aggregated_errors   = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list            = 1
let g:syntastic_auto_jump                = 1
let g:syntastic_enable_signs             = 1
let g:syntastic_error_symbol             = '✗'
let g:syntastic_warning_symbol           = '⚠'
let g:syntastic_style_error_symbol       = '✗'
let g:syntastic_style_warning_symbol     = '⚠'
highlight SyntasticErrorSign   ctermbg=0 ctermfg=1 cterm=bold
highlight SyntasticWarningSign ctermbg=0 ctermfg=5 cterm=bold
call Set_colour('SyntasticErrorSign',   'guibg', s:base03)
call Set_colour('SyntasticErrorSign',   'guifg', s:red   )
call Set_colour('SyntasticWarningSign', 'guibg', s:base03)
call Set_colour('SyntasticWarningSign', 'guifg', s:yellow)

let g:syntastic_mode_map = { 'mode': 'active',
    \ 'active_filetypes':  [],
    \ 'passive_filetypes': ['xml', 'c'] }
let g:syntastic_enable_perl_checker = 1
let g:syntastic_perl_perl_exec      = 'perl -Mblib'
let g:syntastic_markdown_checkers   = ['proselint']
let g:syntastic_perl_checkers       = ['perl']
let g:syntastic_shell_checkers      = ['sh', 'shellcheck', 'checkbashisms']
let g:syntastic_vim_checkers        = ['vint']

" delimitMate
" imap § <C-G>g
" let delimitMate_expand_space         = 1
" let delimitMate_expand_cr            = 2
" let delimitMate_expand_inside_quotes = 1

vmap <Enter> <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" Format HTML tables (good for selenium IDE)
vmap ,at :EasyAlign*/<tr>/<CR><Bar>gv<Bar>:EasyAlign*/<\/tr>/<CR><Bar>gv<Bar>:EasyAlign*/<td>/r0l0<CR><Bar>gv<Bar>:EasyAlign*/<\/td>/r0l0<CR>

cmap w!! w !sudo tee % >/dev/null

" ctrlp
nnoremap <F11> :silent! write <Bar> CtrlPMixed<CR>
let g:ctrlp_map                = '<F99>'  " Not used
let g:ctrlp_cmd                = 'CtrlP'
let g:ctrlp_reuse_window       = 'quickfix'
let g:ctrlp_working_path_mode  = 'ra'
let g:ctrlp_user_command       = ['.git', 'cd %s && git ls-files']
let g:ctrlp_custom_ignore      = {
    \ 'dir':  '\v[\/](tmp|blib|cover_db|nytprof|pdldb|site)$',
    \ 'file': "\v\nytprof$",
    \ }
let g:ctrlp_extensions         = [
    \ 'mixed', 'menu', 'tag', 'yankring', 'changes', 'cmdline'
    \ ]
let g:ctrlp_mruf_relative      = 1
let g:ctrlp_use_caching        = 0
let g:ctrlp_match_window       = 'bottom,order:ttb,min:25,max:25,results:25'
let g:ctrlp_match_current_file = 1
let g:ctrlp_prompt_mappings    = {
    \ 'PrtBS()':              ['<bs>', '<c-]>'],
    \ 'PrtDelete()':          ['<del>'],
    \ 'PrtDeleteWord()':      ['<c-w>'],
    \ 'PrtClear()':           ['<c-u>'],
    \ "PrtSelectMove('j')":   ['<c-j>', '<down>'],
    \ "PrtSelectMove('k')":   ['<c-k>', '<up>', 'OA'],
    \ "PrtSelectMove('t')":   ['<Home>', '<kHome>'],
    \ "PrtSelectMove('b')":   ['<End>', '<kEnd>'],
    \ "PrtSelectMove('u')":   ['<PageUp>', '<kPageUp>'],
    \ "PrtSelectMove('d')":   ['<PageDown>', '<kPageDown>'],
    \ 'PrtHistory(-1)':       ['<c-n>'],
    \ 'PrtHistory(1)':        ['<c-p>'],
    \ "AcceptSelection('e')": ['<cr>', '<2-LeftMouse>'],
    \ "AcceptSelection('h')": ['<c-x>', '<c-cr>', '<c-s>'],
    \ "AcceptSelection('t')": ['<c-t>'],
    \ "AcceptSelection('v')": ['<c-v>', '<RightMouse>'],
    \ 'ToggleFocus()':        ['<s-tab>'],
    \ 'ToggleRegex()':        ['<c-r>'],
    \ 'ToggleByFname()':      ['<c-d>'],
    \ 'ToggleType(1)':        ['<c-f>', '<c-up>', '<F11>'],
    \ 'ToggleType(-1)':       ['<c-b>', '<c-down>'],
    \ 'PrtExpandDir()':       ['<tab>'],
    \ "PrtInsert('c')":       ['<MiddleMouse>', '<insert>'],
    \ 'PrtInsert()':          ['<c-\>'],
    \ 'PrtCurStart()':        ['<c-a>'],
    \ 'PrtCurEnd()':          ['<c-e>'],
    \ 'PrtCurLeft()':         ['<c-h>', '<left>', '<c-^>'],
    \ 'PrtCurRight()':        ['<c-l>', '<right>'],
    \ 'PrtClearCache()':      ['<F5>'],
    \ 'PrtDeleteEnt()':       ['<F7>'],
    \ 'CreateNewFile()':      ['<c-y>'],
    \ 'MarkToOpen()':         ['<c-z>'],
    \ 'OpenMulti()':          ['<c-o>'],
    \ 'PrtExit()':            ['<esc>', '<c-c>', '<c-g>'],
    \ }

" unite
" Use the fuzzy matcher
call unite#filters#matcher_default#use(['matcher_fuzzy'])

" Only use project files
call unite#custom#source('file_mru', 'matchers',
    \ ['matcher_project_files', 'matcher_fuzzy'])

" Increase max candidates
call unite#custom#source('file,file_rec,file_rec/async,grep', 'max_candidates',
    \ 10000)

let g:unite_enable_start_insert             = 1
let g:unite_split_rule                      = 'botright'
let g:unite_data_directory                  = expand($HOME . '/.unite')
let g:unite_prompt                          = '❯ '
let g:unite_marked_icon                     = '•'

" Shorten the default update time of 500ms
let g:unite_update_time                     = 200

let g:unite_source_file_mru_limit           = 1000
let g:unite_cursor_line_highlight           = 'TabLineSel'

let g:unite_source_file_mru_filename_format = ':~:.'
let g:unite_source_file_mru_time_format     = ''

" Map space to the prefix for Unite
nnoremap [unite] <Nop>
nmap <space> [unite]

" General fuzzy search
nnoremap <silent> [unite]<space>
    \ :<C-u>Unite -buffer-name=files buffer
    \ bookmark git_modified git_untracked file_mru git_cached<CR>

" Quick registers
nnoremap <silent> [unite]r
    \ :<C-u>Unite -buffer-name=register register<CR>

" Quick yank history
nnoremap <silent> [unite]y
    \ :<C-u>Unite -buffer-name=yanks history/yank<CR>

" Quick perl modules
nnoremap <silent> [unite]p
    \ :<C-u>Unite -buffer-name=perl_modules perl-module/cpan<CR>

" Quick sources
nnoremap <silent> [unite]s
    \ :<C-u>Unite -buffer-name=sources source<CR>

" Quickly switch lcd
nnoremap <silent> [unite]d
    \ :<C-u>Unite -buffer-name=change-cwd -default-action=cd
    \ directory_mru directory_rec/async<CR>

" Quick file search
nnoremap <silent> [unite]f
    \ :<C-u>Unite -buffer-name=files file_rec/async file/new<CR>

" Quick grep from cwd
nnoremap <silent> [unite]g
    \ :<C-u>Unite -buffer-name=grep grep/git<CR>

" Quick help
nnoremap <silent> [unite]h
    \ :<C-u>Unite -buffer-name=help help<CR>

" Quick commands
nnoremap <silent> [unite]c
    \ :<C-u>Unite -buffer-name=commands command<CR>

" Quick tags
nnoremap <silent> [unite]t
    \ :<C-u>Unite -buffer-name=tags tag<CR>

" Quick outline
nnoremap <silent> [unite]o
    \ :<C-u>Unite -buffer-name=outline outline<CR>

function! s:unite_settings()
    imap <buffer> <Esc> <Plug>(unite_exit)
    nmap <buffer> <Esc> <Plug>(unite_exit)
endfunction

augroup EscapeUnite
    autocmd!
    autocmd FileType unite call s:unite_settings()
augroup END

nmap - gcc
vmap - gc
augroup Commentary
    autocmd!
    autocmd FileType apache  setlocal commentstring=#\ %s
    autocmd FileType crontab setlocal commentstring=#\ %s
augroup END

" abbr
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

    " vint: -ProhibitCommandWithUnintendedSideEffect
    " vint: -ProhibitCommandRelyOnUser

    " convert body to a table
    %s/<body\s*\(bgcolor="[^"]*"\)\s*text=\("[^"]*"\)\s*onload="JumpToLine();">/<table \1 cellPadding=0><tr><td><font color=\2>/
    %s#</body>\(.\|\n\)*</html>#\="</font></td></tr></table>"#i

    " solarized colours
    %s/808080/001920/g  " base03 - background
    %s/000000/022731/g  " base02 - gutter
    %s/8080ff/839496/g  " base0  - body text
    %s/00ff00/93a1a1/g  " base1  - line numbers
    %s/008000/b58900/g  " yellow - sub
    %s/0000c0/268bd2/g  " blue   - sub name
    %s/804000/cb4b16/g  " orange - vars
    %s/c00000/dc322f/g  " red    - punctuation

    " font
    %s/monospace/inconsolata,monospace/g

    " vint: +ProhibitCommandRelyOnUser
    " vint: +ProhibitCommandWithUnintendedSideEffect
    "
    redraw  " no hit enter ...

    " restore old setting
    let g:html_use_css = old_css
endfunction
command! -range=% MyToHtml :call MyToHtml(<line1>,<line2>)

let s:homerc = expand($HOME . '/.vimrc.local')
if filereadable(s:homerc)
    exec 'source ' . s:homerc
endif

let s:localrc = expand('./.vimrc.local')
if filereadable(s:localrc)
    exec 'source ' . s:localrc
endif
