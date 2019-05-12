scriptencoding utf-8


" Load this module only once.
if exists('g:loaded_gpp_compile_autoload')
    finish
endif
let g:loaded_gpp_compile_autoload = '0.0.0 2019-05-12'


" ユーザー設定を一時退避
let s:save_cpo = &cpo
set cpo&vim

function! s:compile_file()
	return system( "g++ -Wall " . expand("%") . " -o " . expand("%:r") )
endfunction

function! s:print_data()
	let s:cout_string = s:compile_file()
	if s:cout_string != ""
		echo s:cout_string
	else
		highlight MyMessage ctermfg=green 
		echohl MyMessage 
		echo 'OK!' 
		echohl NONE
	endif
	return 
endfunction

function! gpp_compile#compile()
	return s:print_data()
endfunction



" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
