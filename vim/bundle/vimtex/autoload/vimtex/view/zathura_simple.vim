" VimTeX - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! vimtex#view#zathura_simple#new() abort " {{{1
  return s:viewer.init()
endfunction

" }}}1


let s:viewer = vimtex#view#_template#new({
      \ 'name': 'Zathura',
      \ 'has_synctex': 1,
      \})

function! s:viewer._check() dict abort " {{{1
  return vimtex#view#zathura#check(self)
endfunction

" }}}1
function! s:viewer._start(outfile) dict abort " {{{1
  let self.cmd_start
        \ = vimtex#view#zathura#cmdline(a:outfile, self.has_synctex, 2)

  call vimtex#jobs#run(self.cmd_start)
endfunction

" }}}1
