scriptencoding utf-8


" Load this module only once.
if exists('g:loaded_gpp_compile_autoload')
    finish
endif
let g:loaded_gpp_compile_autoload = '0.0.0 2019-05-12'


" ユーザー設定を一時退避
let s:save_cpo = &cpo
set cpo&vim

" settings
" compiler
let s:gpp_compile_compiler = get(g:, "gpp_compile_compiler", "g++" )
" auto compile
let s:gpp_compile_auto_type = get(g:,'gpp_compile_auto_type','1')

if !executable(s:gpp_compile_compiler)
	echo s:gpp_compile_compiler . " is not defined!"
	finish
endif

function! s:compile_file()
	return system( s:gpp_compile_compiler . " -Wall " . expand("%") . " -o " . expand("%:r").".out" )
endfunction

function! s:print_data(print_type)
	let s:cout_string = s:compile_file()
	if s:cout_string != ""
		if a:print_type
			highlight MyMessage ctermfg=red
			echohl MyMessage  
			echo "NG!"
			echohl NONE
		else
			echo s:cout_string
			highlight StatusLine   term=NONE cterm=NONE ctermbg=red
		endif
	else
		highlight StatusLine   term=NONE cterm=NONE ctermbg=blue

		highlight MyMessage ctermfg=green 
		echohl MyMessage 
		echo 'OK!' 
		echohl NONE
	endif
	return 
endfunction

function! gpp_compile#compile(print_type)
	return s:print_data(a:print_type)
endfunction

function! s:is_target_dir()
	return expand("%:p") =~ $HOME . "/program/project/atcoder"
endfunction

function! gpp_compile#gpp_compile_auto()
	if s:gpp_compile_auto_type
		if s:is_target_dir()
			call s:print_data(0)
		endif
	endif
endfunction

" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
