scriptencoding utf-8


" Load this module only once.
if exists('g:loaded_gpp_compile')
    finish
endif
let g:loaded_gpp_compile = '0.0.0 2019-05-12'

" ユーザー設定を一時退避
let s:save_cpo = &cpo
set cpo&vim

if !exists(":GppCompile")
    command GppCompile :call gpp_compile#compile()
endif

" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
