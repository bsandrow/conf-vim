" vim:ft=vim:fdm=marker:
"
"    Copyright: Copyright (C) 2010 Brandon Sandrowicz
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               todo-list.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. In no event will the
"               copyright holder be liable for any damages resulting from the
"               use of this software.
" Name Of File: todo.vim
"  Description: Filetype Plugin for todo files
"       Author: Brandon Sandrowicz <brandon@sandrowicz.org>
"   Maintainer: Brandon Sandrowicz <brandon@sandrowicz.org>
"      Version: 0.1
"
" Install Details:
"
"   1. Copy todo.vim to ~/.vim/ftplugin
"   2. Add the following to ~/.vim/filetype.vim:
"       augroup todo
"           au!
"           au BufRead,BufNewFile todo.txt  setf todo
"           au BufRead,BufNewFile TODO      setf todo
"       augroup END
"
" Controls:
"   g:todo_enable_folding       Turns on folding support.
"   g:did_todo_ftplugin         Turns off this ftplugin.
"   g:no_todo_maps              Turns off keybindings.
"

if exists("b:did_ftplugin") || exists("g:did_todo_ftplugin")
    finish
endif
let b:did_ftplugin = 1
let g:did_todo_ftplugin = 1

" Save original cpoptions value, and enable use of compound statements
let s:save_cpo = &cpo
set cpo-=C
let b:undo_ftplugin = "unlet! g:did_todo_ftplugin"

""""""""""
"" Helper Functions
"" {{{

" s:is_cursor_on_item() {{{
"
" Return 1 or 0 depending on whether or not the cursor is on a line that is
" part of an item. This matters because sometimes an item may have multiple
" lines that don't start with the '[ ]' string. e.g.
"
"   [ ] go to the store and blah blah blah
"       blah blah blah
"
" The second line is still part of the item (just wrapped), so we need to
" treat it as such.
"
function! s:is_cursor_on_item()
    let l:cur_line  = line('.')
    let l:line_no   = s:find_nearest_item()

    if l:line_no == l:cur_line  | return 1 | endif
    if l:line_no == -1          | return 0 | endif

    let l:item_indent_level     = indent(l:line_no)
    let l:subline_indent_level  = l:item_indent_level + 4

    let l:iter = l:line_no + 1
    while (l:iter <= l:cur_line)
        if indent(l:iter) != l:subline_indent_level
            return 0
        endif
        let l:iter += 1
    endwhile
    return 1
endfunction " }}}

" Find the nearest item line (only searches up)
function! s:find_nearest_item() " {{{
    let l:origpos = [ line('.'), col('.') ]

    " Search up for an item, stop when we hit the top
    if search('^\s\+\[.\] ','bcW')
        let l:line_result = line('.')
        call cursor(origpos[0],origpos[1])
        return l:line_result
    endif

    return -1
endfunction " }}}

" Return the indent level of the nearest line
function! s:find_nearest_item_indent() " {{{
    let l:line = s:find_nearest_item()
    return l:line == -1 ? 0 : indent(l:line)
endfunction " }}}

function! s:goto_next_item_line() " {{{
    let l:origcol = col('.')
    if search('^\s\+\[.\] \|\(^\s*$\)','W')
        call cursor(line('.')-1,origpos[1])
    endif
endfunction " }}}

"" }}}

""""""""""
"" Functions
"" {{{
" Mark a checkbox with a 'x' on the current line (if one exists)
function! s:mark_checkbox() " {{{
    if getline('.') =~ '^\s*\[ \]'
        :substitute/^\(\s*\)\[ \]/\1[x]/
    endif
endfunction " }}}

" Create a new grouping. Searches downward looking for the next grouping. If
" it finds another grouping, it will create a new grouping above it.
" Otherwise, it will create a new grouping at the end of the buffer.
function! s:create_new_group() " {{{
    if search('^@','cW')
        execute 'normal O'
        execute 'normal O@:'
        call cursor(line('.'),2)
        startinsert
    else
        call cursor('$',col('.'))
        execute 'normal o'
        execute 'normal o@:'
        call cursor(line('.'),2)
        startinsert
    endif
endfunction " }}}

" Create a new checkbox below the curret line
function! s:new_checkbox() " {{{
    call s:goto_next_item_line()
    let l:indent_level = s:find_nearest_item_indent()
    let l:start_string = repeat(' ',l:indent_level) . "[ ] "
    execute "normal o" . l:start_string
    startinsert!
endfunction " }}}

" Generate the text displayed for the fold
function! s:fold_text() " {{{
    let items = 0
    let subitems = 0
    for i in range(v:foldend - v:foldstart + 1)
        if getline(v:foldstart+i) =~ '^\s*\[.\] '
            let l:indent_level = indent(v:foldstart + i)
            if l:indent_level == 0 | let items += 1 | endif
            if l:indent_level > 0 && (l:indent_level % (&tabstop)) == 0 | let subitems += 1 | endif
        endif
    endfor

    let text = getline(v:foldstart)
    return text . ' { ' . items . ' items, ' . subitems . ' subitems } '
endfunction " }}}

" Determine where folds are
function! s:fold_expr(lnum) " {{{

    " lines that start with '@' are groups
    if getline(a:lnum) =~ '^@'
        return 1
    endif

    " All lines with no indent are outside of a fold
    if indent(a:lnum) == 0 && getline(a:lnum) =~ '^\s*$'
        return 0
    endif

    return '='
endfunction " }}}

" }}}

""""""""""
"" Folding
"" {{{
if exists('g:todo_enable_folding')
    function! TodoFoldExpr(line)
        return s:fold_expr(a:line)
    endfunction

    function! TodoFoldText()
        return s:fold_text()
    endfunction

    setlocal foldmethod=expr
    setlocal foldexpr=TodoFoldExpr(v:lnum)
    setlocal foldtext=TodoFoldText()

    let b:undo_ftplugin = b:undo_ftplugin . " | setlocal fdm< fde< fdt<"
endif
" }}}

""""""""""
"" Keybindings
"" {{{
if !exists("no_plugin_maps") && !exists("g:no_todo_maps")
    if !hasmapto('<Plug>TickCheckbox')
        nmap <buffer> <LocalLeader>x <Plug>TickCheckbox
    endif

    if !hasmapto('<Plug>NewCheckbox')
        nmap <buffer> <LocalLeader>n <Plug>NewCheckbox
    endif

    if !hasmapto('<Plug>NewGrouping')
        nmap <buffer> <LocalLeader>g <Plug>NewGrouping
    endif

    nnoremap <buffer> <Plug>TickCheckbox :call <SID>mark_checkbox()<CR>
    nnoremap <buffer> <Plug>NewCheckbox  :call <SID>new_checkbox()<CR>
    nnoremap <buffer> <Plug>NewGrouping  :call <SID>create_new_group()<CR>
endif
" }}}

" Restore the value of cpoptions
let &cpo = s:save_cpo
