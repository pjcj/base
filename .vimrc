set encoding=utf-8
scriptencoding utf-8
filetype       off

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction

call plug#begin()

" !sort -t/ -k2

Plug 'w0rp/ale'                                                " syntax checking
Plug 'rhysd/clever-f.vim'                                           " f F t T f;
Plug 'sgur/ctrlp-extensions.vim'              " cmdline, yank and menu for ctrlp
Plug 'ctrlpvim/ctrlp.vim'                                                " <F11>
Plug 'Shougo/deoplete.nvim'
Plug 'vim-scripts/diffchar.vim'                       " show diffs on char basis
Plug 'gregsexton/gitv', {'on': ['Gitv']}
Plug 'davinche/godown-vim'                            " show markdown in browser
Plug 'haya14busa/incsearch-fuzzy.vim'                                       " z/
Plug 'haya14busa/incsearch.vim'                  " show all matches on incsearch
Plug 'Shougo/neco-syntax'                                " for use with deoplete
Plug 'Xuyuanp/nerdtree-git-plugin'                          " show changed files
Plug 'scrooloose/nerdtree'                                              " <S-F1>
Plug 'chr4/nginx.vim'
Plug 'stefandtw/quickfix-reflector.vim'      " edit then save in quickfix window
Plug 'saltstack/salt-vim'                                    " salt highlighting
Plug 'andrewradev/sideways.vim'              " operate on arglists ,sh ,sl aa ia
Plug 'rstacruz/sparkup'                                            " HTML helper
Plug 'ervandew/supertab'
Plug 'majutsushi/tagbar'                                                " <S-F2>
Plug 'wellle/targets.vim'                                " add * | and _ targets
Plug 'wellle/tmux-complete.vim'                       " deoplete from tmux panes
Plug 'SirVer/ultisnips'
Plug 'mbbill/undotree'                                                     " ,gu
Plug 'chrisbra/unicode.vim'        " unicode table, search, complete, ^X^Z, ^X^G
Plug 'tpope/vim-abolish'               " :%Subvert/facilit{y,ies}/building{,s}/g
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'FooSoft/vim-argwrap'                              " wrap multiline args ,a
Plug 'gioele/vim-autoswap'                        " deal with swapfiles sensibly
Plug 'alvan/vim-closetag'                                      " close tags > >>
Plug 'tpope/vim-commentary'                                                 " gc
Plug 'ap/vim-css-color'                             " add colour to descriptions
Plug 'chrisbra/vim-diff-enhanced'                        " change diff algorithm
Plug 'tpope/vim-dispatch'                          " asynchronous build and test
Plug 'junegunn/vim-easy-align'                                     " = ^X<regex>
Plug 'tpope/vim-eunuch'                                          " Unix commands
Plug 'kopischke/vim-fetch'                      " use line numbers in file paths
Plug 'tommcdo/vim-fugitive-blame-ext'                           " extend :Gblame
Plug 'tpope/vim-fugitive'                                  " :Gdiff :Gstatus ,gg
Plug 'airblade/vim-gitgutter'                  " <F3>,hn <F2>,hp ,hv <F1>,hs ,hr
Plug 'ludovicchabant/vim-gutentags'                   " generate tags on the fly
Plug 'nathanaelkane/vim-indent-guides'    " configured for indent of two or four
Plug 'michaeljsmith/vim-indent-object'      " objects based on indentation ii AI
Plug 'lfv89/vim-interestingwords'                                    " ,k ,K n N
Plug 'farmergreg/vim-lastplace'                           " save cursor position
Plug 'tommcdo/vim-lion'                                 " alignment, gl gL glip=
Plug 'Spaceghost/vim-matchit'                                                " %
Plug 'sheerun/vim-polyglot'                                 " extra syntax files
Plug 'tpope/vim-repeat'
Plug 'zirrostig/vim-schlepp'                               " highlight then hjkl
Plug 'google/vim-searchindex'                            " show m/n for searches
Plug 'inside/vim-search-pulse'                                           " * n N
Plug 'kshenoy/vim-signature'                          " mx dmx m, m. m<Space> m/
Plug 'honza/vim-snippets'
Plug 'tpope/vim-surround'                                     " cs'" cs'<q> cst'
Plug 'baskerville/vim-sxhkdrc'                                     "sxhkd syntax
Plug 'tmux-plugins/vim-tmux'                 " tmux syntax highlighting and more
Plug 'mattboehm/vim-unstack'                             " :UnstackFromSelection
Plug 'akracun/vitality.vim'                           " deal with focus for tmux

" Perl
Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do':
    \ 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny' }
Plug 'vim-perl/vim-perl6'
Plug 'c9s/perlomni.vim'                                         " for completion

" FZF
Plug 'sunaku/vim-shortcut'                                                " , ,,
Plug '/home/pjcj/g/ghq/github.com/junegunn/fzf'
Plug '/usr/local/Cellar/fzf/0.16.7'
Plug 'junegunn/fzf.vim'

" Denite and unite, plugins for denite
let g:neomru#file_mru_limit = 8
Plug 'Shougo/denite.nvim'
Plug 'chemzqm/denite-extra'
Plug 'Shougo/unite.vim'
Plug 'Shougo/neomru.vim'
Plug 'yuku-t/unite-git'
Plug 'Shougo/unite-outline'
Plug 'soh335/unite-perl-module'

Plug 'pjcj/neovim-colors-solarized-truecolor-only'

if has('nvim')
    Plug 'bfredl/nvim-miniyank'                              " yankring <C-Y> g-
endif

call plug#end()

let g:mapleader = ','

runtime plugin/shortcut.vim
Shortcut show shortcut menu and run chosen shortcut
    \ noremap <silent> <Leader><Leader> :Shortcuts<Return>
Shortcut fallback to shortcut menu on partial entry
    \ noremap <silent> <Leader> :Shortcuts<Return>

filetype plugin indent on

set autoindent
set autowriteall
set backspace=indent,eol,start
set backup
set backupcopy=yes,breakhardlink
set backupdir=~/g/tmp/vim/
set backupext=.bak
set clipboard=unnamedplus  " yanks, deletes and changes go into + clipboard
set cmdheight=3
set colorcolumn=80,120
set complete=.,w,b,u,U,k/usr/share/dict/words,i,t
set dictionary=/usr/share/dict/words
set diffopt=filler,vertical
set directory=>~/g/tmp/vim/
set errorformat=%f:%l:%m
set expandtab
set exrc
set formatoptions=tcrqnlj
set guifont=inconsolata\ \for\ powerline\ 12
set hidden  " needed for completor
set history=1000
set hlsearch
set icon
set ignorecase
set incsearch
set joinspaces
set laststatus=2
set lazyredraw
set list
set listchars=tab:»\ ,trail:·
set modelines=1
set mouse=a
set mousefocus
set mousehide
set mousemodel=popup_setpos
set nosmartindent
set nosmarttab
set number
set path=,,.,/usr/include
set report=1
set ruler
set scrolloff=3
set shell=zsh
set shiftround
set shiftwidth=4
set showcmd
set showmatch
set showmode
set smartcase
set softtabstop=0
set suffixes=.d,.e,.o,.org,.bak,~
set tabstop=8
set tagrelative
set tags=./tags,tags,../tags,../../tags,../../../tags,../../../../tags
set textwidth=0
set title
set ttimeoutlen=50
set ttyfast
set undodir=~/g/tmp/vim
set undofile
set undolevels=10000
set updatetime=250
set viminfo='50
set whichwrap=19
set wildmenu
set wildmode=list:longest,full
set writebackup

if executable('rg')
    set grepprg=rg\ --no-heading\ --hidden\ --glob\ '!.git'\ --vimgrep
    set grepformat=%f:%l:%c:%m
else
    set grepprg=git\ grep\ -n
endif

if has('nvim')
    set inccommand=split
endif

" Java options
set cinoptions+=j1  " anonymous classes
let g:java_comment_strings         = 1
let g:java_highlight_java_lang_ids = 1
let g:java_highlight_all           = 1
let g:java_highlight_debug         = 1
let g:java_ignore_javadoc          = 1
let g:java_highlight_java_lang_ids = 1
let g:java_highlight_functions     = 'style'

syntax enable
set background=dark
set termguicolors
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

let s:rgreen  = '#25ad2e'  " a nice green for diffs (opposite of s:red)

function! Set_colour(group, part, colour)
    execute 'highlight ' . a:group . ' ' . a:part . '=' . a:colour
endfunc

" highlight Comment cterm = italic
call Set_colour('Normal',       'guifg', s:normal)
call Set_colour('SpecialKey',   'guibg', s:base03)
call Set_colour('SpellBad',     'guibg', s:violet)
call Set_colour('SpellBad',     'guifg', s:base03)
call Set_colour('SpellBad',     'gui',   'NONE'  )
call Set_colour('SpellCap',     'guibg', s:blue  )
call Set_colour('SpellCap',     'guifg', s:base03)
call Set_colour('SpellCap',     'gui',   'NONE'  )
call Set_colour('SpellRare',    'guibg', s:yellow)
call Set_colour('SpellRare',    'guifg', s:base03)
call Set_colour('SpellRare',    'gui',   'NONE'  )
call Set_colour('SpellLocal',   'guibg', s:green )
call Set_colour('SpellLocal',   'guifg', s:base03)
call Set_colour('SpellLocal',   'gui',   'NONE'  )
call Set_colour('LineNr',       'guibg', s:base03)
call Set_colour('CursorLine',   'guibg', s:base02)
call Set_colour('CursorColumn', 'guibg', s:base02)
call Set_colour('CursorLineNr', 'guibg', s:base03)
call Set_colour('DiffAdd',      'guibg', s:base03)
call Set_colour('DiffAdd',      'guifg', s:rgreen)
call Set_colour('DiffChange',   'guibg', s:base03)
call Set_colour('DiffDelete',   'guibg', s:base03)
call Set_colour('diffAdded',    'guifg', s:rgreen)
call Set_colour('Search',       'guibg', s:violet)
call Set_colour('Search',       'guifg', s:base03)
call Set_colour('Search',       'gui',   'NONE'  )
call Set_colour('TabLineSel',   'guibg', s:base03)
call Set_colour('TabLineSel',   'guifg', s:violet)

Shortcut! <C-S-P> show syntax class of item under cursor
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
endfunc

set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
" let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

let g:deoplete#enable_at_startup          = 1
let g:deoplete#auto_complete_delay        = 10
call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])

let g:completor_min_chars                 = 1
" let g:completor_perl_omni_trigger       = '->'

let g:UltiSnipsJumpForwardTrigger         = '<tab>'
let g:UltiSnipsJumpBackwardTrigger        = '<s-tab>'

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_indent_levels         = 40
function! Setup_indent_guides()
    " hi IndentGuidesEven ctermbg=black
    call Set_colour('IndentGuidesEven', 'guibg', s:base02)
    if &shiftwidth < 3
        let g:indent_guides_guide_size  = 0
        let g:indent_guides_auto_colors = 0
        call Set_colour('IndentGuidesOdd', 'guibg', 'NONE')
        " echo 'small: ' &shiftwidth
    else
        let g:indent_guides_guide_size  = 1
        let g:indent_guides_start_level = 2
        let g:indent_guides_auto_colors = 0
        " hi IndentGuidesOdd ctermbg=black
        call Set_colour('IndentGuidesOdd', 'guibg', s:base02)
        " echo 'big: ' &shiftwidth
    endif
endfunction
autocmd BufEnter,Colorscheme * call Setup_indent_guides()

let g:airline_theme                  = 'solarized'
let g:airline_powerline_fonts        = 1
let g:airline_solarized_normal_green = 1

let g:autoswap_detect_tmux = 1  " switch to open tmux pane

augroup file_types
    autocmd!
    autocmd BufNewFile,BufReadPost template/* set ft=tt2html
    autocmd BufNewFile,BufReadPost *.tt2      set ft=tt2html
    autocmd BufNewFile,BufReadPost *.tt       set ft=tt2html
    autocmd BufNewFile,BufReadPost *.t        set ft=perl
    autocmd BufNewFile,BufReadPost *.pd       set ft=perl
    autocmd BufNewFile,BufReadPost *.mc       set ft=mason

    autocmd BufRead *tmp/ml/mutt-*
        \ setlocal colorcolumn=72 tw=72 spell spelllang=en_gb
    autocmd Filetype gitcommit
        \ setlocal colorcolumn=50,72 tw=72 spell spelllang=en_gb

    autocmd InsertLeave * if expand("%") != "" | update | endif

    autocmd FileType xhtml,xml,html,tt2html,mason setlocal sw=2

    " close quickfix, location and preview list windows
    autocmd FileType qf if mapcheck('<Esc>', 'n') ==# ''
        \ | nnoremap <buffer><silent> <Esc> :cclose<Bar>lclose<Bar>:pclose<CR>
        \ | endif
augroup END

" let g:html_indent_script1 = 'inc'
" let g:html_indent_style1  = 'inc'
" let g:html_indent_inctags = 'html,body,head,tbody,p,li,dd,dt,h1,h2,h3,h4,h5,h6,blockquote,section'

let g:gutentags_ctags_exclude    = ['blib', 'tmp']
" can be extended with '*/sub/path' if required

let g:NERDTreeShowHidden         = 1

function! NERDTreeRefresh()
    if &filetype ==# 'nerdtree'
        silent exe substitute(mapcheck('R'), '<CR>', '', '')
    endif
endfunction

augroup nerdtree
    autocmd!
    autocmd BufEnter * call NERDTreeRefresh()
augroup END

" taglist plugin
let g:Tlist_Use_SingleClick      = 1
let g:Tlist_Use_Right_Window     = 1
let g:Tlist_Auto_Open            = 0
let g:Tlist_Show_One_File        = 0
let g:Tlist_WinWidth             = 32
let g:Tlist_Compact_Format       = 1
let g:Tlist_Exit_OnlyWindow      = 1
let g:Tlist_File_Fold_Auto_Close = 1
let g:Tlist_Process_File_Always  = 1
let g:Tlist_Enable_Fold_Column   = 0
let g:Tlist_Show_Menu            = 1

let g:tagbar_width               = 32
let g:tagbar_autoclose           = 1
let g:tagbar_autofocus           = 1
let g:tagbar_sort                = 1
let g:tagbar_compact             = 1
let g:tagbar_indent              = 1
let g:tagbar_show_visibility     = 1
let g:tagbar_show_linenumbers    = 0
let g:tagbar_singleclick         = 1
let g:tagbar_autoshowtag         = 1

augroup git
    autocmd!
    autocmd BufReadPost fugitive://* set bufhidden=delete
    autocmd QuickFixCmdPost *grep* cwindow
augroup END
Shortcut show git diff
    \ nnoremap <leader>gd :Gdiff<CR>
Shortcut make git commit
    \ nnoremap <leader>gg :Gcommit -v<CR>O
Shortcut show git status
    \ nnoremap <leader>gs :Gstatus<CR>

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
Shortcut jump to next hunk
    \ nnoremap <leader>hn :GitGutterNextHunk<CR>
Shortcut jump to previous hunk
    \ nnoremap <leader>hp :GitGutterPrevHunk<CR>
Shortcut preview current hunk
    \ nnoremap <leader>hv :GitGutterPreviewHunk<CR>
Shortcut stage current hunk
    \ nnoremap <leader>hs :GitGutterStageHunk<CR>
Shortcut undo current hunk
    \ nnoremap <leader>hr :GitGutterUndoHunk<CR>

let g:SignatureMarkTextHLDynamic = 1

let g:vitality_tumx_can_focus    = 1

let g:csv_autocmd_arrange        = 1

let g:godown_autorun             = 1

" diffchar sets defaults if these aren't set
nmap <silent> abc1 <Plug>ToggleDiffCharAllLines
nmap <silent> abc2 <Plug>ToggleDiffCharCurrentLine
nmap <silent> abc3 <Plug>JumpDiffCharPrevStart
nmap <silent> abc4 <Plug>JumpDiffCharNextStart
nmap <silent> abc5 <Plug>JumpDiffCharPrevEnd
nmap <silent> abc6 <Plug>JumpDiffCharNextEnd

" get vim-search-pulse and vim-interestingwords working together
" stop plugin overwriting mappings
function! Pulse_col(colour)
    call Set_colour('CursorLine',   'guibg', a:colour)
    call Set_colour('CursorColumn', 'guibg', a:colour)
endfunc
function! Pulse_on()
    let s:ccl = &cursorline
    set cursorline
    set cursorcolumn
    call Pulse_col(s:yellow)
endfunc
function! Pulse_off()
    let &cursorline   = s:ccl
    let &cursorcolumn = s:ccl
    call Pulse_col(s:base02)
endfunc
function! Pulse()
    exe 'normal zz'
    call search_pulse#Pulse()
endfunc
augroup Pulse
    autocmd!
    autocmd User PrePulse  call Pulse_on()
    autocmd User PostPulse call Pulse_off()
    " Pulses the first match after hitting the enter key
    autocmd! User IncSearchExecute
    autocmd User IncSearchExecute :call search_pulse#Pulse()
augroup END

map <leader>interestingwords <Plug>InterestingWords
let g:vim_search_pulse_disable_auto_mappings = 1
let g:vim_search_pulse_mode                  = 'pattern'  " or cursor_line
let g:vim_search_pulse_duration              = 100
let g:interestingWordsGUIColors              =
    \ ['#72b5e4', '#f0c53f', '#ff8784', '#c5c7f1',
    \  '#c2d735', '#78d3cc', '#ea8336', '#e43542',
    \  '#ebab35', '#ebe735', '#aadd32', '#dcca6b',
    \  '#219286', '#2f569c', '#ffb577', '#5282a4',
    \  '#edfccf', '#67064c', '#f5bca7', '#95c474',
    \  '#dece83', '#de9783', '#f2e700', '#e9e9e9',
    \  '#69636d', '#626b98', '#f5f5a7', '#dcca6b',
    \  '#b72a83', '#6f2b9d', '#69636d', '#5f569c']
augroup SearchIndex
    autocmd!
    autocmd VimEnter * call <SID>OverridePluginSettings()
    function! s:OverridePluginSettings()
        nmap <silent> * *``:call InterestingWords('n')<CR>
            \ :set nohls<CR>
            \ :call Pulse()<CR>
            \ <Plug>SearchIndex
        nmap <silent> n :call WordNavigation(1)<CR>
            \ :call Pulse()<CR><Plug>SearchIndex
        nmap <silent> N :call WordNavigation(0)<CR>
            \ :call Pulse()<CR><Plug>SearchIndex
    endfunction
augroup END
Shortcut (nv) toggle highlighting of interesting words
    \ nnoremap <silent> <leader>k :call InterestingWords('n')<CR>
    \|vnoremap <silent> <leader>k :call InterestingWords('v')<CR>
Shortcut turn off highlighting of interesting words
    \ nnoremap <silent> <leader>K :call UncolorAllWords()<CR>

function! s:config_fuzzyall(...) abort
    set hlsearch
    return extend(copy({
        \     'converters': [
        \         incsearch#config#fuzzy#converter(),
        \         incsearch#config#fuzzyspell#converter()
        \     ],
        \ }), get(a:, 1, {}))
endfunction

Shortcut! z/ incremental fuzzy search forward
noremap <silent><expr> z/ incsearch#go(<SID>config_fuzzyall())
Shortcut! z? incremental fuzzy search backward
noremap <silent><expr> z? incsearch#go(<SID>config_fuzzyall({'command': '?'}))
Shortcut! zg/ incremental fuzzy search backward without moving
noremap <silent><expr> zg/ incsearch#go(<SID>config_fuzzyall({'is_stay': 1}))

map / :set hls<CR><Plug>(incsearch-forward)

Shortcut toggle search highlighting
    \ nnoremap <leader><space> :set hls!<BAR>
        \ :call UncolorAllWords()<BAR>
        \ :echo "HLSearch: " . strpart("OffOn",3*&hlsearch,3)<CR>

Shortcut (v) schlepp up
    \ vmap <unique> k <Plug>SchleppUp
Shortcut (v) schlepp down
    \ vmap <unique> j <Plug>SchleppDown
Shortcut (v) schlepp left
    \ vmap <unique> h <Plug>SchleppLeft
Shortcut (v) schlepp right
    \ vmap <unique> l <Plug>SchleppRight
Shortcut move up one logical line
    \ nnoremap k gk
Shortcut move down one logical line
    \ nnoremap j gj

Shortcut toggle argument and parameter wrapping
    \ nnoremap <silent> <leader>a :ArgWrap<CR>
let g:argwrap_padded_braces = '[{'
let g:argwrap_tail_comma    = 1

Shortcut (nv) generate digraph from characters
    \ nmap <leader>dg <Plug>(MakeDigraph)
    \|vmap <leader>dg <Plug>(MakeDigraph)
Shortcut describe character under cursor
    \ nmap ga <Plug>(UnicodeGA)
Shortcut! :UnicodeTable<CR> show table of all unicode characters
Shortcut! :Digraphs<CR> show digraph table
Shortcut! :Digraphs!<CR> show extended digraph table
Shortcut! :Digraphs! show digraph table matching argument
Shortcut! <C-X><C-G> complete as digraph
Shortcut! <C-X><C-Z> complete as unicode

augroup autowrite
    autocmd!
    autocmd FocusLost * silent! wa
augroup END

set guioptions=ag

function! s:get_visual_selection()
    let [l:lnum1, l:col1] = getpos("'<")[1:2]
    let [l:lnum2, l:col2] = getpos("'>")[1:2]
    let l:lines           = getline(l:lnum1, l:lnum2)
    let l:lines[-1]       = l:lines[-1]
                            \[: l:col2 - (&selection ==# 'inclusive' ? 1 : 2)]
    let l:lines[0]        = l:lines[0][l:col1 - 1:]
    return join(l:lines, ' ')
endfunction
function! Grep_visual(text)
    execute "silent grep! '" . a:text . "'"
endfunction
command! GrepVisual call Grep_visual(s:get_visual_selection())

Shortcut stage current hunk
    \ nnoremap <F1>       :GitGutterStageHunk<CR>
Shortcut jump to previous hunk
    \ nnoremap <F2>       :GitGutterPrevHunk<CR>
Shortcut jump to next hunk
    \ nnoremap <F3>       :GitGutterNextHunk<CR>
Shortcut preview hunk
    \ nnoremap <C-F1>     :GitGutterPreviewHunk<CR>
Shortcut toggle NERDTree filesystem viewer
    \ nnoremap <S-F1>     :NERDTreeToggle<CR>
Shortcut toggle tagbar subroutine funtion method viewer
    \ nnoremap <S-F2>     :TagbarToggle<CR>
Shortcut jump to tag
    \ nnoremap <F4>       :execute "tjump /^\\(_build_\\)\\?" .
        \ expand("<cword>") . "$"
        \ <Bar> :call Pulse()<CR>
Shortcut jump to next tag
    \ nnoremap <S-F4>     :tnext<Bar>:call Pulse()<CR>
Shortcut jump to previous tag
    \ nnoremap <M-F4>     :tprev<Bar>:call Pulse()<CR>
Shortcut run make
    \ nnoremap <F5>       :execute "silent make" <Bar> botright copen<CR><C-L>
Shortcut display current error from quickfix list
    \ nnoremap <S-F5>     :cc<CR>
Shortcut display current error from location list
    \ nnoremap <C-F5>     :ll<CR>
Shortcut jump to previous error from quickfix list
    \ nnoremap <F6>       :cprevious<Bar>:call Pulse()<CR>
Shortcut jump to previous error from location list
    \ nnoremap <C-F6>     :lprevious<Bar>:call Pulse()<CR>
Shortcut jump to next error from quickfix list
    \ nnoremap <F7>       :cnext<Bar>:call Pulse()<CR>
Shortcut jump to next error from location list
    \ nnoremap <C-F7>     :lnext<Bar>:call Pulse()<CR>
Shortcut grep for exact word under cursor
    \ nnoremap <F8>       *``:execute "silent grep! -w " . expand("<cword>")
        \ <Bar> botright copen<CR><C-L>
Shortcut grep for word under cursor
    \ nnoremap <S-F8>     *``:execute "silent grep! " . expand("<cword>")
        \ <Bar> botright copen<CR><C-L>
Shortcut (v) grep for visual selection
    \ vnoremap <C-F8> :<C-U>GrepVisual<CR>
Shortcut only show current window
    \ nnoremap <F9>       :only<CR>
Shortcut open quickfix list window
    \ nnoremap <S-F9>     :copen<CR>
Shortcut open location list window
    \ nnoremap <C-F9>     :lopen<CR>
Shortcut switch windows
    \ nnoremap <silent>   <S-F10> w
Shortcut open gitv in browser mode
    \ nnoremap §          :Gitv --all<CR>
Shortcut open gitv in browser mode
    \ vnoremap §          :Gitv --all<CR>
Shortcut open gitv in file mode
    \ nnoremap °          :Gitv! --all<CR>
Shortcut open gitv in file mode
    \ vnoremap °          :Gitv! --all<CR>
nnoremap <Home>     1G
nnoremap <End>      Gz-
nnoremap <PageUp>   0
nnoremap <PageDown> 0
nnoremap <Insert>   [[(z<CR>]]
nnoremap <Del>      j]](z<CR>]]
Shortcut! <F12> switch to previous buffer
nnoremap <F12>      

imap <F2> sub {<CR>my $self = shift;<CR>my () = @_;<CR>}<ESC>%hi<Space>
imap <F3> $self->{}<ESC>i
imap <F4> $self->

map <F13>    <S-F1>
map <F14>    <S-F2>
map <F15>    <S-F3>
map <F16>    <S-F4>
map <F17>    <S-F5>
map <F18>    <S-F6>
map <F19>    <S-F7>
map <F20>    <S-F8>
map <F21>    <S-F9>
map <F22>    <S-F10>
map <F23>    <S-F11>
map <F24>    <S-F12>

map <F25>    <C-F1>
map <F26>    <C-F2>
map <F27>    <C-F3>
map <F28>    <C-F4>
map <F29>    <C-F5>
map <F30>    <C-F6>
map <F31>    <C-F7>
map <F32>    <C-F8>
map <F33>    <C-F9>
map <F34>    <C-F10>
map <F35>    <C-F11>
map <F36>    <C-F12>

map <F37>    <M-F1>
" not working with neovim
map <F38>    <M-F2>
map <F39>    <M-F3>
map <F40>    <M-F4>
map <F41>    <M-F5>
map <F42>    <M-F6>
map <F43>    <M-F7>
map <F44>    <M-F8>
map <F45>    <M-F9>
map <F46>    <M-F10>
map <F47>    <M-F11>
map <F48>    <M-F12>

map <Leader>f8 <C-F8>

Shortcut swap with the word on the left
    \ nnoremap <Leader><Left>
    \ "_yiw?\v\w+\_W+%#<CR>:s/\v(%#\w+)(\_W+)(\w+)/\3\2\1/<CR><C-o><C-l>
Shortcut swap with the word on the right
    \ nnoremap <Leader><Right>
    \ "_yiw:s/\v(%#\w+)(\_W+)(\w+)/\3\2\1/<CR><C-o>/\v\w+\_W+<CR><C-l>

let g:undotree_WindowLayout          = 1
let g:undotree_ShortIndicators       = 1
let g:undotree_SetFocusWhenToggle    = 1
let g:undotree_HighlightSyntaxAdd    = 'CursorLine'
let g:undotree_HighlightSyntaxAdd    = 'CursorLine'
let g:undotree_HighlightSyntaxChange = 'CursorLine'

Shortcut toggle undo tree
    \ nnoremap <leader>gu :UndotreeToggle<CR>

Shortcut jump to previous edit location
    \ nnoremap g, g;
Shortcut jump to next edit location
    \ nnoremap g. g,

if has('nvim')
    tnoremap <Esc> <C-\><C-n>
endif

let g:SuperTabDefaultCompletionType = '<c-n>'

let g:Gitv_CommitStep               = 100
let g:Gitv_OpenHorizontal           = 1
let g:Gitv_OpenPreviewOnLaunch      = 1
let g:Gitv_TruncateCommitSubjects   = 1
let g:Gitv_WipeAllOnClose           = 1
let g:Gitv_WrapLines                = 0

inoremap # X<BS>#
cnoremap <C-w> <C-I>

map! <S-Insert> <C-R>*

Shortcut unindent
    \ vnoremap < <gv
Shortcut indent
    \ vnoremap > >gv

Shortcut (v) paste current copy buffer onto currently selected text
    \ vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

Shortcut delete trailing whitespace
    \ nnoremap <leader>W :%s/\s\+$//<cr>:let @/=""<CR>

Shortcut select lines to end of previous yanked or changed text
    \ nnoremap <leader>v V`]

Shortcut! cs change quotes from to
Shortcut change quotes from ' to "
    \ nmap <leader>qq cs'"
Shortcut change quotes from " to '
    \ nmap <leader>qQ cs"'

Shortcut toggle cursorline and cursorcolumn
    \ nnoremap <Leader>ccl :set cursorline! cursorcolumn!<CR>

Shortcut show coverage information in gutter
    \ nnoremap <Leader>c :source cover_db/coverage.vim<CR>

Shortcut spellcheck with British English
    \ nnoremap <leader>se :setlocal spell spelllang=en_gb<CR>
Shortcut spellcheck with Swiss German
    \ nnoremap <leader>sd :setlocal spell spelllang=de_ch<CR>
Shortcut turn off spellchecking
    \ nnoremap <leader>so :set nospell<CR>

Shortcut toggle paste option
    \ nnoremap <leader>p :set paste!<CR>

" miniyank
let g:miniyank_maxitems        = 1000
let g:miniyank_filename        = $HOME.'/.vim/.miniyank.mpack'
let g:miniyank_delete_maxlines = 10000

Shortcut paste with miniyank
    \ map p <Plug>(miniyank-autoput)
Shortcut paste with miniyank
    \ map P <Plug>(miniyank-autoPut)
Shortcut cycle forwards though miniyank buffer
    \ map <C-Y> <Plug>(miniyank-cycle)
Shortcut! g- cycle backwards though miniyank buffer

" ALE
let g:ale_open_list            = 0
let g:ale_echo_cursor          = 1
let g:ale_lint_on_text_changed = 1
let g:ale_lint_on_enter        = 1
let g:ale_lint_on_save         = 1
let g:ale_lint_delay           = 200
let g:ale_set_quickfix         = 0
let g:ale_sign_error           = '✗'
let g:ale_sign_warning         = '⚠'

let g:ale_linters              = {'perl' : ['perl']}
let g:ale_perl_perl_executable = glob('~/g/base/utils/ale_perl')
let g:ale_perl_perl_options    = ''

Shortcut jump to next error
    \ nmap <silent> <C-J> <Plug>(ale_next_wrap)
Shortcut jump to previous error
    \ nmap <silent> <C-K> <Plug>(ale_previous_wrap)

" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.tt'

" unstack
let g:unstack_populate_quickfix = 1
let g:unstack_open_tab          = 0

vmap <Enter> <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
" Format HTML tables (good for selenium IDE)
vmap <leader>at :EasyAlign*/<tr>/r0l0<CR><Bar>gv<Bar>
               \:EasyAlign*/<td>/r0l0<CR><Bar>gv<Bar>
               \:EasyAlign*/<\/tr>/r0l0<CR>

cmap w!! w !sudo tee % >/dev/null
Shortcut! :w!! write file as superuser

" ctrlp
Shortcut! <F11> CtrlP
nnoremap <F11> :silent! write <Bar> CtrlPMixed<CR>
let g:ctrlp_map                = '<F99>'  " Not used
let g:ctrlp_cmd                = 'CtrlP'
let g:ctrlp_reuse_window       = 'quickfix'
let g:ctrlp_working_path_mode  = 'ra'
let g:ctrlp_user_command       = ['.git', 'cd %s && git ls-files']
let g:ctrlp_custom_ignore      = {
    \ 'dir':  '\v[\/](tmp|blib|cover_db|nytprof)$',
    \ 'file': "\v\nytprof$",
    \ }
let g:ctrlp_extensions         = [
    \ 'mixed', 'menu', 'tag', 'changes', 'cmdline'
    \ ]
let g:ctrlp_mruf_relative      = 1
let g:ctrlp_use_caching        = 0
let g:ctrlp_match_window       = 'bottom,order:btt,min:25,max:25,results:25'
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

" Denite
call denite#custom#option('default', 'smartcase', v:true)

nnoremap [denite] <Nop>
Shortcut denite
    \ nmap <space> [denite]

Shortcut denite general fuzzy search
    \ nnoremap <silent> [denite]<space>
    \ :<C-u>Denite -buffer-name=files
    \ unite:git_modified unite:git_untracked buffer file_mru file_rec<CR>

Shortcut denite resume
    \ nnoremap <silent> [denite]r
    \ :<C-u>Denite -resume -refresh<CR>

Shortcut denite files recursively
    \ nnoremap <silent> [denite]f
    \ :<C-u>Denite file_rec<CR>

Shortcut denite old files
    \ nnoremap <silent> [denite]b
    \ :<C-u>Denite buffer file_old -default-action=switch<CR>

call denite#custom#alias('source', 'file_rec/git', 'file_rec')
call denite#custom#var('file_rec/git', 'command',
    \ ['git', 'ls-files', '-co', '--exclude-standard'])
Shortcut denite git files
    \ nnoremap <silent> [denite]i
    \ :<C-u>Denite
    \ `finddir('.git', ';') != '' ? 'file_rec/git' : 'file_rec'`<CR>

Shortcut denite change directory
    \ nnoremap <silent> [denite]d
    \ :<C-u>Denite directory_rec -default-action=cd<CR>

Shortcut denite insert from register
    \ nnoremap <silent> [denite]v
    \ :<C-u>Denite register -buffer-name=register<CR>

Shortcut denite show location list
    \ nnoremap <silent> [denite]l
    \ :<C-u>Denite location_list -buffer-name=list<CR>

Shortcut denite show quickfix list
    \ nnoremap <silent> [denite]q
    \ :<C-u>Denite quickfix -buffer-name=list<CR>

Shortcut denite grep
    \ nnoremap <silent> [denite]g
    \ :<C-u>Denite grep<CR>

Shortcut denite jump and change
    \ nnoremap <silent> [denite]j
    \ :<C-u>Denite jump change file_point<CR>

Shortcut denite outline
    \ nnoremap <silent> [denite]o
    \ :<C-u>Denite unite:outline<CR>

Shortcut denite tags
    \ nnoremap <silent> [denite]t
    \ :<C-u>Denite tag<CR>

Shortcut denite command
    \ nnoremap <silent> [denite]c
    \ :<C-u>Denite command<CR>

Shortcut denite help
    \ nnoremap <silent> [denite]h
    \ :<C-u>Denite help<CR>

let g:unite_data_directory = expand($HOME . '/.unite')
Shortcut denite perl modules
    \ nnoremap <silent> [denite]p
    \ :<C-u>Denite unite:perl-module/cpan -buffer-name=perl_modules<CR>

Shortcut denite command history
    \ nnoremap <silent> [denite]s
    \ :<C-u>Denite command_history<CR>

call denite#custom#source('_', 'sorters', ['sorter_sublime'])
call denite#custom#source('file_mru', 'converters', ['converter_relative_abbr'])

call denite#custom#var('file_rec', 'command',
    \ [ 'fd', '--hidden',
    \     '--exclude', '*.git/',
    \     '--exclude', '/tmp/',
    \     '--exclude', '/blib/',
    \     '--exclude', '/cover_db/',
    \     '--exclude', '/nytprof*',
    \     '--exclude', '/tags',
    \     '.'
    \ ])

call denite#custom#option('_', {
    \ 'prompt': '❯',
    \ 'highlight_matched_char': 'Todo',
    \ 'highlight_mode_insert': 'CursorLine',
    \ 'reversed': v:true,
    \ 'winheight': 30
    \ })

call denite#custom#map(
    \ 'insert',
    \ '<Down>',
    \ '<denite:move_to_next_line>',
    \ 'noremap'
    \)
call denite#custom#map(
    \ 'insert',
    \ '<Up>',
    \ '<denite:move_to_previous_line>',
    \ 'noremap'
    \)

call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
    \ ['--vimgrep', '--no-heading', '--hidden', '--glob', '!.git'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

Shortcut - (nv) comment
    \ nmap - gcc
    \|vmap - gc
augroup Commentary
    autocmd!
    autocmd FileType apache  setlocal commentstring=#\ %s
    autocmd FileType crontab setlocal commentstring=#\ %s
augroup END

" clever-f
let g:clever_f_fix_key_direction     = 1    " f is always forwards, F backwards
let g:clever_f_chars_match_any_signs = ';'  " ; matches all signs
Shortcut! f  find character forwards
Shortcut! F  find character backwards
Shortcut! t  to character forwards
Shortcut! T  to character backwards
Shortcut! f; find all signs

let g:lion_squeeze_spaces = 1
Shortcut! gl align with spaces to right
Shortcut! gL align with spaces to left
Shortcut align single line subs
    \ map <leader>gls gl/}$<CR>

function! NewFile(type)
    " exe 'normal ggdG'
    exe 'r! file_template -path ' . &path . ' ' . expand('%') . ' ' . a:type
    exe 'normal ggdd'
    /^[ \t]*[#] *implementation/
    w
endfunction
command! -nargs=? NewFile :call NewFile(<q-args>)
Shortcut add new file template
    \ nnoremap <leader>n :NewFile<CR>

Shortcut move argument left
    \ nnoremap <leader>sh :SidewaysLeft<cr>
Shortcut move argument right
    \ nnoremap <leader>sl :SidewaysRight<cr>
" define argument objects
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

" abbr
iabbr ,, =>
iabbr op, open my $fh, "<", $filename or die "Can't open $filename: $!";<CR>
          \close $fh or die "Can't close $filename: $!";

" shortcuts

Shortcut! gJ join without adding spaces
Shortcut! gu change to lower-case
Shortcut! gU change to upper-case
Shortcut! g~ toggle case

" functions
function! MyToHtml(line1, line2)
    " make sure to generate in the correct format
    let l:old_css = 1
    if exists('g:html_use_css')
        let l:old_css = g:html_use_css
    endif
    let g:html_use_css = 0

    " generate and delete unneeded lines
    exec a:line1.','.a:line2.'TOhtml'
    %g/<body/normal k$dgg

    " vint: -ProhibitCommandWithUnintendedSideEffect
    " vint: -ProhibitCommandRelyOnUser

    " convert body to a table
    %s/<body\s*\(bgcolor="[^"]*"\)\s*text=\("[^"]*"\)\s*onload="JumpToLine();">/
        \<table \1 cellPadding=0><tr><td><font color=\2>/
    %s#</body>\(.\|\n\)*</html>#\="</font></td></tr></table>"#i

    " solarized colours
    " %s/808080/001920/g  " base03 - background
    " %s/000000/022731/g  " base02 - background
    " %s/ffffff/9599dc/g  " base0  - body text
    " %s/ffff00/93a1a1/g  " base1  - line numbers
    " %s/00ffff/93a1a1/g  " base1  - comments
    " %s/008000/b58900/g  " yellow - sub
    " %s/0000c0/268bd2/g  " blue   - sub name
    " %s/804000/cb4b16/g  " orange - vars
    " %s/ffd7d7/dc322f/g  " red    - punctuation

    " font
    %s/monospace/inconsolata,monospace/g

    " vint: +ProhibitCommandRelyOnUser
    " vint: +ProhibitCommandWithUnintendedSideEffect

    redraw  " no hit enter ...

    " restore old setting
    let g:html_use_css = l:old_css
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
