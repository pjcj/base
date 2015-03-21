" Vim global plugin for tracking Perl vars in source
" Last change:  Sun May 18 11:40:10 EST 2014
" Maintainer:	Damian Conway
" License:	This file is placed in the public domain.

finish

" If already loaded, we're done...
if exists("loaded_trackperlvars")
    finish
endif
let loaded_trackperlvars = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:save_cpo = &cpo
set cpo&vim

" Select an unlikely match number (e.g. the Neighbours of the Beast)...
let s:match_id = 664668

" Set up initial highlight group (unless already set)...
highlight default TRACK_PERL_VAR ctermfg=white

" This gets called every time the cursor moves (so keep it tight!)...
function! s:track_perl_var ()
    " Remove previous highlighting...
    try | call matchdelete(s:match_id) | catch /./ | endtry

    " Locate a var under cursor...
    let cursline = getline('.')
    let curscol  = col('.')

    let varparts
    \    = matchlist(cursline, '\%<'.(curscol+1).'c\([@%]\|[$][#]\?\)\s*[{]\?\(\h\w*\)[}]\?\%>'.curscol.'c\s*\([[{]\)\?')

    " Short-circuit if nothing to track...
    if empty(varparts)
        return
    endif

    " Otherwise, extract components of variable...
    let sigil   = get(varparts,1)
    let varname = get(varparts,2)
    let bracket = get(varparts,3,'')

    " Handle arrays: @array, $array[...], $#array...
    if sigil == '@' && bracket != '{' || sigil == '$#' || sigil =~ '[$%]' && bracket == '['
        let curs_var = '\%('
                \ . '[$%]\_s*\%('.varname.'\|[{]'.varname.'[}]\)\%(\_s*[[]\)\@=\|'
                \ . '[$]#\_s*\%('.varname.'\|[{]'.varname.'[}]\)\|'
                \ .  '[@]\_s*\%('.varname.'\|[{]'.varname.'[}]\)\%(\_s*[{]\)\@!'
                \ . '\)'

    " Handle hashes: %hash, $hash{...}, @hash{...}...
    elseif sigil == '%' && bracket != '[' || sigil =~ '[$@]' && bracket == '{'
        let curs_var = '\%('
                \ . '[$@]\_s*\%('.varname.'\|[{]'.varname.'[}]\)\%(\_s*[{]\)\@=\|'
                \ .  '[%]\_s*\%('.varname.'\|[{]'.varname.'[}]\)\%(\_s*[[]\)\@!'
                \ . '\)'

    " Handle scalars: $scalar
    else
        let curs_var = '[$]\_s*\%('.varname.'\|[{]'.varname.'[}]\)\%(\_s*[[{]\)\@!'
    endif

    " Set up the match
    let g:track_perl_var = matchadd('TRACK_PERL_VAR', curs_var.'\%(\_$\|\W\@=\)', 10, s:match_id)
endfunction

" Track vars after each cursor movement...
augroup TrackVar
    autocmd!
    au CursorMoved  *.pl,*.pm,*.t  call <sid>track_perl_var()
    au CursorMovedI *.pl,*.pm,*.t  call <sid>track_perl_var()
augroup END


" Restore previous external compatibility options
let &cpo = s:save_cpo
