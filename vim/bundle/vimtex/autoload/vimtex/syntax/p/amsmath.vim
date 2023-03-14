" VimTeX - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

scriptencoding utf-8

function! vimtex#syntax#p#amsmath#load(cfg) abort " {{{1
  call vimtex#syntax#core#new_region_math('align')
  call vimtex#syntax#core#new_region_math('alignat')
  call vimtex#syntax#core#new_region_math('flalign')
  call vimtex#syntax#core#new_region_math('gather')
  call vimtex#syntax#core#new_region_math('mathpar')
  call vimtex#syntax#core#new_region_math('multline')
  call vimtex#syntax#core#new_region_math('xalignat')
  call vimtex#syntax#core#new_region_math('xxalignat', {'starred': 0})

  syntax match texMathCmdEnv contained contains=texCmdMathEnv nextgroup=texMathArrayArg skipwhite skipnl "\\begin{subarray}"
  syntax match texMathCmdEnv contained contains=texCmdMathEnv nextgroup=texMathArrayArg skipwhite skipnl "\\begin{x\?alignat\*\?}"
  syntax match texMathCmdEnv contained contains=texCmdMathEnv nextgroup=texMathArrayArg skipwhite skipnl "\\begin{xxalignat}"
  syntax match texMathCmdEnv contained contains=texCmdMathEnv                                            "\\end{subarray}"
  syntax match texMathCmdEnv contained contains=texCmdMathEnv                                            "\\end{x\?alignat\*\?}"
  syntax match texMathCmdEnv contained contains=texCmdMathEnv                                            "\\end{xxalignat}"

  " \numberwithin
  syntax match texCmdNumberWithin "\\numberwithin\>"
        \ nextgroup=texNumberWithinArg1 skipwhite skipnl
  call vimtex#syntax#core#new_arg('texNumberWithinArg1', {
        \ 'next': 'texNumberWithinArg2',
        \ 'contains': 'TOP,@Spell'
        \})
  call vimtex#syntax#core#new_arg('texNumberWithinArg2', {
        \ 'contains': 'TOP,@Spell'
        \})

  " \subjclass
  syntax match texCmdSubjClass "\\subjclass\>"
        \ nextgroup=texSubjClassOpt,texSubjClassArg skipwhite skipnl
  call vimtex#syntax#core#new_opt('texSubjClassOpt', {
        \ 'next': 'texSubjClassArg',
        \ 'contains': 'TOP,@Spell'
        \})
  call vimtex#syntax#core#new_arg('texSubjClassArg', {
        \ 'contains': 'TOP,@Spell'
        \})

  " \operatorname
  syntax match texCmdOpname nextgroup=texOpnameArg skipwhite skipnl "\\operatorname\>"
  call vimtex#syntax#core#new_arg('texOpnameArg', {
        \ 'contains': 'TOP,@Spell'
        \})

  " DeclareMathOperator
  syntax match texCmdDeclmathoper nextgroup=texDeclmathoperArgName skipwhite skipnl "\\DeclareMathOperator\>\*\?"
  call vimtex#syntax#core#new_arg('texDeclmathoperArgName', {
        \ 'next': 'texDeclmathoperArgBody',
        \ 'contains': ''
        \})
  call vimtex#syntax#core#new_arg('texDeclmathoperArgBody', {'contains': 'TOP,@Spell'})

  " \tag{label} or \tag*{label}
  syntax match texMathCmd "\\tag\>\*\?" contained nextgroup=texMathTagArg
  call vimtex#syntax#core#new_arg('texMathTagArg', {'contains': 'TOP,@Spell'})

  " Add conceal rules
  if a:cfg.conceal
    call s:add_conceals()
  endif

  highlight def link texCmdDeclmathoper     texCmdNew
  highlight def link texCmdNumberWithin     texCmd
  highlight def link texCmdOpName           texCmd
  highlight def link texCmdSubjClass        texCmd
  highlight def link texCmdRefEq            texCmdRef
  highlight def link texRefEqConcealedArg   texRefArg
  highlight def link texRefEqConcealedDelim texDelim
  highlight def link texDeclmathoperArgName texArgNew
  highlight def link texDeclmathoperArgBody texMathZone
  highlight def link texMathConcealedArg    texMathTextArg
  highlight def link texNumberWithinArg1    texArg
  highlight def link texNumberWithinArg2    texArg
  highlight def link texOpnameArg           texMathZone
  highlight def link texSubjClassArg        texArg
  highlight def link texSubjClassOpt        texOpt
endfunction

" }}}1

function! s:add_conceals() abort " {{{1
  " Conceal "\eqref{ … }" as "(…)"
  syntax match texCmdRefEq nextgroup=texRefEqConcealedArg
        \ conceal skipwhite skipnl "\\eqref\>"
  call vimtex#syntax#core#new_arg('texRefEqConcealedArg', {
        \ 'contains': 'texComment,@NoSpell,texRefEqConcealedDelim',
        \ 'opts': 'keepend contained',
        \ 'matchgroup': '',
        \})
  syntax match texRefEqConcealedDelim contained "{" conceal cchar=(
  syntax match texRefEqConcealedDelim contained "}" conceal cchar=)

  " \operatorname
  "   conceal the command and delims
  "   \operatorname{ … }  ⇒  …
  syntax region texMathConcealedArg contained matchgroup=texMathCmd
        \ start="\\operatorname\*\?\s*{\s*" end="\s*}"
        \ concealends
  syntax cluster texClusterMath add=texMathConcealedArg

  " The last part are amsmath specific math delimiters and should respect the
  " global config value
  if !g:vimtex_syntax_conceal.math_delimiters | return | endif

  " Amsmath [lr][vV]ert
  if &encoding ==# 'utf-8'
    syntax match texMathDelim contained conceal cchar=| "\\\%([bB]igg\?l\?\|left\)\\lvert\>\s*"
    syntax match texMathDelim contained conceal cchar=| "\s*\\\%([bB]igg\?r\?\|right\)\\rvert\>"
    syntax match texMathDelim contained conceal cchar=‖ "\\\%([bB]igg\?l\?\|left\)\\lVert\>\s*"
    syntax match texMathDelim contained conceal cchar=‖ "\s*\\\%([bB]igg\?r\?\|right\)\\rVert\>"
  endif

  syntax match texCmdEnvM "\\\%(begin\|end\){Vmatrix}" contained conceal cchar=║
  syntax match texCmdEnvM "\\\%(begin\|end\){vmatrix}" contained conceal cchar=|
  syntax match texCmdEnvM "\\begin{Bmatrix}"           contained conceal cchar={
  syntax match texCmdEnvM "\\end{Bmatrix}"             contained conceal cchar=}
  syntax match texCmdEnvM "\\begin{bmatrix}"           contained conceal cchar=[
  syntax match texCmdEnvM "\\end{bmatrix}"             contained conceal cchar=]
  syntax match texCmdEnvM "\\begin{pmatrix}"           contained conceal cchar=(
  syntax match texCmdEnvM "\\end{pmatrix}"             contained conceal cchar=)
  syntax match texCmdEnvM "\\begin{smallmatrix}"       contained conceal cchar=(
  syntax match texCmdEnvM "\\end{smallmatrix}"         contained conceal cchar=)
endfunction

" }}}1
