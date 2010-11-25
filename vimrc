" vimrc
"

""""""""""
"" Load all bundles
""
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

""""""""""
"" options
""
set nocompatible                " disable vanliia vi compatibility mode
set backspace=indent,eol,start  " let backspace plow over everything
set virtualedit=all             " i like being able to move the cursor all around
set vb t_vb=                    " i hate visual/audible bells // turn on visualbell, and set the vb character to nothing
set hidden                      " allow unsaved buffers to be backgrounded

""""""""""
"" searching
""
set incsearch   " we want to see the first match before actually searching
set ignorecase  " make searches case-insensitive by default
set smartcase   " make searches case-sensitive if contains upper-case chars

""""""""""
"" display
""
set ruler           " turn on the ruler to show cursor/buffer pos
set nonumber        " no line numbers
set nowrap          " never wrap lines unless explicitly told to
set noshowmatch     " don't match paren/braces as they are created
set list            " turn on listmode

"set listchars=eol:$         " default listchars
set listchars=tab:»·,trail:· " jhe's listchars

""""""""""
"" \t control
""
set expandtab       " <Tab> inserts spaces instead of \t .
set tabstop=4       " display tabs as n spaces
set shiftwidth=4    " used when indenting and shifting selections
set softtabstop=4   " \t counts for n spaces when mixing the two

""""""""""
"" Make the Y key work more like the D and yank to end of line
""
noremap Y y$

""""""""""
"" Define a mapleader to use for subsequent mappings
""
let mapleader = ","
let maplocalleader = ","

" Defined ',,' to take the place of the old functionality of ','
nnoremap <leader>, :normal ,<CR>:<CR>

""""""""""
"" syntax highlighting
""
syntax on
if has("autocmd")
    filetype on
    filetype plugin on
    filetype indent on
endif

""""""""""
"" groovy syntax settings
""
let groovy_allow_cpp_keywords = 1 " don't warn when using c++ keywords

""""""""""
"" java syntax settings
""
let java_space_errors = 1
let java_ignore_javadoc = 1
let java_highlight_functions = 1
let java_allow_cpp_keywords = 1   " don't warn when using c++ keywords

""""""""""
"" perl syntax settings
""
let perl_extended_vars = 1
let perl_include_pod = 1
let perl_string_as_statement = 1
let perl_fold = 1
let perl_nofold_packages = 1

""""""""""
"" perl-support settings
""
"" TODO disable the .pm file template
"" TODO disable the stupid { bracket delay
let g:Perl_NoKeyMappings=0  " turn off the perl-support key mappings
let g:Perl_Support_Root_Dir = $HOME . "/.vim/bundle/perl-support"

""""""""""
"" Disable the parenthesis/bracket highlighting plugin that was enabled by default
"" in Vim 7.2
""
"" source: http://vimrc-dissection.blogspot.com/2006/09/vim-7-re-turn-off-parenparenthesiswhat.html
""
let loaded_matchparen = 1

""""""""""
"" remove trailing whitespace
""
"" ref: http://vim.wikia.com/wiki/Remove_unwanted_spaces
""
function! RemoveTrailingWhitespace() range
    if !&binary && &filetype != "diff"
        execute a:firstline . "," . a:lastline . "s/\\s\\+$//ge"
    endif
    echomsg "trailing whitespace removed"
endfunction
command -bar -nargs=0 -range=% RemoveTrailingWhitespace <line1>,<line2>call RemoveTrailingWhitespace()
nnoremap <leader>rw :RemoveTrailingWhitespace<CR>
vnoremap <leader>rw :RemoveTrailingWhitespace<CR>

""""""""""
"" convert tabs to spaces
""
"" TODO Make it so that the number of spaces a replacing a tab depends on the
"" position of the tab in relation to columns defined by &tabstop SmartTab2Space?
function! Tab2Space() range
    let l:spaces = repeat(" ",&tabstop)
    if !&binary && &filetype != "diff"
        execute a:firstline . "," . a:lastline . "s,\t," . l:spaces . ",ge"
    endif
    echomsg "conveted tabs to spaces"
endfunction
command -bar -nargs=0 -range=% Tab2Space <line1>,<line2>call Tab2Space()
nnoremap <leader>ts :Tab2Space<CR>
vnoremap <leader>ts :Tab2Space<CR>

""""""""""
"" LustyExplorer settings
""

nnoremap <leader>b  :BufferExplorer<CR>
nnoremap <leader>f  :FilesystemExplorer<CR>
nnoremap <leader>r  :FilesystemExplorerFromHere<CR>

""""""""""
"" Todo File Support
""
let g:todo_enable_folding = 1

""""""""""
"" Control sh/bash syntax file
""
let g:sh_fold_enabled = 1

""""""""""
"" local changes
""
if filereadable(expand("$HOME/.vim/local.vim"))
    source $HOME/.vim/local.vim
endif

" vim:syn=vim:
