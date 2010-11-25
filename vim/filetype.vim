augroup todo
    au!
    au BufRead,BufNewFile todo.txt  setf todo
    au BufRead,BufNewFile TODO      setf todo
augroup END

augroup moin
    au!
    au BufRead,BufNewFile *.moin    setf moin
augroup END
