scriptencoding utf-8


" Load this module only once.
if exists('g:loaded_gpp_compile_autoload')
	finish
endif
let g:loaded_gpp_compile_autoload = '0.0.0 2019-05-12'


" ユーザー設定を一時退避
let s:save_cpo = &cpo
set cpo&vim

let s:gpp_compile_num = 4

function! s:check(check_command)
	silent return gpp_compile#check(check_command)
endfunction

call s:check(s:gpp_compile_compiler)
call s:check("diff")

function! s:compile_file()
	return system("timeout ".s:gpp_timeout." ".s:gpp_compile_compiler." ".s:gpp_compile_compiler_option." ".s:gpp_compile_compiler_warning_option." ".expand("%:p")." -o ".expand("%:p:r").".out" )
endfunction

function! s:compile_file_nowarn()
	return system("timeout ".s:gpp_timeout." ".s:gpp_compile_compiler." ".s:gpp_compile_compiler_option." ".expand("%:p")." -o ".expand("%:p:r").".out" )
endfunction

function! s:do_compile()
	if s:gpp_compile_is_compiled == 4 " Not yet
		let s:warn_string = s:compile_file()
		let s:no_warn_string = s:compile_file_nowarn()
		if s:warn_string == "" 
			let s:gpp_compile_num = 2
		elseif s:no_warn_string = ""
			let s:gpp_compile_num = 3
		else
			let s:gpp_compile_num = 1
		return {"warn":s:warn_string,"error":s:no_warn_string}
	endif
endfunction

"return dict {"done":true/false,"warn":"" , "error":""}
function! s:check_compile()
	if s:gpp_compile_num == 4 "Not yet
		let l:compile_isdone = false
	else 
		let l:compile_isdone = true
	endif
	return { "done": l:compile_isdone, "warn":s:warn_string,"error":s:no_warn_string}
endfunction


function! s:reset_compile()
	let s:gpp_compile_num = 4
endfunction

function! gpp_compile#get_copile_num()
	echo s:gpp_compile_num
	return s:gpp_compile_num
endfunction

function! gpp_compile#check_compile()
	return s:check_compile()
endfunction

function! gpp_compile#do_compile()
	return s:do_compile()
endfunction

" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
