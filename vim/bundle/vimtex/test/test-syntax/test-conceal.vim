source common.vim

let g:vimtex_syntax_conceal = {'sections': 1}
let g:vimtex_syntax_custom_cmds = [
      \ {'name': 'keyw', 'mathmode': 0, 'argstyle': 'boldital' , 'conceal': 1},
      \]
let g:vimtex_syntax_custom_cmds_with_concealed_delims = [
      \ {'name': 'ket',
      \  'mathmode': 1,
      \  'cchar_open': '|',
      \  'cchar_close': '>'},
      \]

EditConcealed test-conceal.tex

if empty($INMAKE) | finish | endif

call vimtex#test#finished()
