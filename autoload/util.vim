scriptencoding utf-8

" Load this module only once.
if exists('g:loaded_gpp_compile_autoload_util')
	finish
endif
let g:loaded_gpp_compile_autoload_util = '0.0.0 2019-05-12'


function! s:is_target_dir()
	return expand("%:p") =~ s:gpp_compile_work_dir 
endfunction

function! gpp_compile#is_target_dir()
	silent return s:is_target_dir()
endfunction

function! gpp_compile#check(check_command)
	if !executable(a:check_command)
		echohl WaringMsg | echo a:check_command . " is not defined!" | echohl None | finish
	endif
endfunction