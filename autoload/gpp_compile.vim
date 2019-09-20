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
let s:gpp_compile_compiler_warning_option = get(g:, "gpp_compile_compiler_warning_option", "-Wall" )
let s:gpp_compile_compiler_option = get(g:, "gpp_compile_compiler_option", "" )
let s:gpp_timeout = get(g:,"gpp_timeout","10")

let s:gpp_dir_type = get(g:,'gpp_dir_type',0)
" auto compile
let s:gpp_compile_auto_type = get(g:,'gpp_compile_auto_type','1')
" auto test
let s:gpp_test_auto_type = get(g:,'gpp_test_auto_type','1')

" work dir
let s:gpp_compile_work_dir = get(g:,'gpp_compile_work_dir',$HOME . "/" ."kyopro")

let s:gpp_compile_is_compiled = 4
let s:test_num = 3
let s:test_out_puts = []
let s:test_set_num = 0
let s:test_ac_num = 0

function! s:check(check_command)
	silent return gpp_compile#check(check_command)
endfunction

call s:check(s:gpp_compile_compiler)
call s:check("diff")

function! s:compile_file()
	return system("timeout ".s:gpp_timeout." ".s:gpp_compile_compiler." ".s:gpp_compile_compiler_option." ".s:gpp_compile_compiler_warning_option." ".expand("%:p")." -o ".expand("%:p:r").".out" )
endfunction

function! s:compile_file_nowarn()
	return system( s:gpp_compile_compiler." ".s:gpp_compile_compiler_option." ".expand("%:p")." -o ".expand("%:p:r").".out" )
endfunction

function! s:do_compile()
	if s:gpp_compile_is_compiled == 4
		let s:cout_string = s:compile_file()
		if s:cout_string == ""
			let s:gpp_compile_is_compiled = 2
		else
			if s:compile_file_nowarn() == ""
				let s:gpp_compile_is_compiled = 3
			else
				let s:gpp_compile_is_compiled = 1
			endif
		endif
		return s:gpp_compile_is_compiled 
	else
		return s:gpp_compile_is_compiled
	endif
endfunction

function! s:print_data_compile(print_type)
	if a:print_type == 1 " just num
		echo s:gpp_compile_is_compiled
		return s:gpp_compile_is_compiled

	elseif a:print_type == 2 " two char
		if s:gpp_compile_is_compiled == 1 " NG
			echo "NG"
			return "NG"
		elseif s:gpp_compile_is_compiled == 2 " OK
			echo "OK"
			return "OK"
		elseif s:gpp_compile_is_compiled == 3 " WA
			echo "WA"  
			return "WA"
		elseif s:gpp_compile_is_compiled == 4 " NY
			echo "NY"
			return "NY"
		endif

	elseif a:print_type == 3 " short messsage
		echo "invalid"	

	elseif a:print_type == 4 " full
		if s:gpp_compile_is_compiled == 1 " NG
			echo s:cout_string
		elseif s:gpp_compile_is_compiled == 2 " OK
			echo "OK!"
		elseif s:gpp_compile_is_compiled == 3 " WA
			echo s:cout_string
		elseif s:gpp_compile_is_compiled == 4 "NY
			echo "Not Yet!"
		endif
	else 
		echo "print_data is " . a:print_data . "@s:print_data_compile and it`s invalid." 
	endif
endfunction

function! gpp_compile#compile(print_type)
	call s:do_compile()
	return s:print_data_compile(a:print_type)
endfunction

function! gpp_compile#gpp_compile_reset()
	let s:gpp_compile_is_compiled = 4
	if s:gpp_compile_auto_type == 1
		silent if s:is_target_dir() == 1
		silent call s:do_compile()
	endif
endif
endfunction

function! gpp_compile#check_compile_num()
	return s:print_data_compile(1)
endfunction

function! gpp_compile#check_compile()
	return s:print_data_compile(2)
endfunction


function! s:check_test_files()
	let l:file_dir = "/".join(split(expand("%:p"),"/")[:-2],"/") . "/"
		if s:gpp_dir_type == 0
			let l:test_file_list = split(system("ls ".l:file_dir."test/sample_input".split(expand("%:p:r"),"/")[-1]."* 2>/dev/null"),"\n")
		elseif s:gpp_dir_type == 1
			let l:test_file_list = split(system("ls ".l:file_dir."test/sample-*.in 2>/dev/null"),"\n")
		endif

	if len(l:test_file_list) == 0
		let s:test_num = 3 " not downloaded
	endif
	return l:test_file_list
endfunction

function! s:test_file()
	let l:file_dir = "/".join(split(expand("%:p"),"/")[:-2],"/") . "/"
	let l:test_file_list = s:check_test_files()
	if len(l:test_file_list) == 0
		call s:get_test_data()	
		let l:test_file_list = s:check_test_files()
		if len(l:test_file_list) == 0
			echo "failed to make sample testfiles."
			let s:test_num = 3 " not downloaded
			let s:gpp_test_auto_type = 0
			return
		endif
	else
		" echo l:test_file_list
	endif 

	let l:ac_num = 0
	let s:test_out_puts = []
	for l:input_file in l:test_file_list
		if ! filereadable(substitute(l:input_file,"in","out","g"))
			call s:get_test_data()
		endif
		let l:diff_str = system(expand("%:p:r").".out < ".l:input_file." | diff -u --strip-trailing-cr - ".substitute(l:input_file,"in","out","g"))
		if l:diff_str != ""
			call add(s:test_out_puts,l:diff_str)
		else
			" echo l:ac_num
			let l:ac_num += 1
		endif
	endfor
	let s:test_ac_num = l:ac_num
	let s:test_set_num = len(l:test_file_list)
	if s:test_ac_num == s:test_set_num 
		let s:test_num = 2 " OK!
	else 
		let s:test_num = 1 " NG!
	endif
endfunction

function! s:do_test()
	if s:gpp_compile_is_compiled == 1 " NG
		if s:test_num != 3 " Not Downloaded
			let s:test_num = 1
			let s:test_ac_num = 0
		endif
	else

		if s:test_num == 4 || s:test_num == 3
			call s:test_file()
		endif
	endif
	return s:test_num
endfunction

function! s:print_data_test(print_type)
	if a:print_type == 1 " just num
		echo s:test_num
		return s:test_num

	elseif a:print_type == 2 " two char
		if s:test_num == 1 " NG
			echo "NG"
			return "NG"
		elseif s:test_num == 2 " OK
			echo "OK"
			return "OK"
		elseif s:test_num == 3 " ND
			echo "ND"  
			return "ND"
		elseif s:test_num == 4 " NY
			echo "NY"
			return "NY"
		endif

	elseif a:print_type == 3 " short messsage
		if s:test_num == 1 " NG
			echo s:test_ac_num."/".s:test_set_num
			return s:test_ac_num."/".s:test_set_num
		elseif s:test_num == 2 " OK
			echo s:test_ac_num."/".s:test_set_num
			return s:test_ac_num."/".s:test_set_num
		elseif s:test_num == 3 " ND
			echo "not downloaded"
			return "not downloaded"
		elseif s:test_num == 4 " NY
			echo "not yet"
			return "not yet"
		endif

	elseif a:print_type == 4 " full
		if s:test_num == 1 " NG
			for l:test_output in s:test_out_puts
				echo l:test_output
			endfor 
		elseif s:test_num == 2 " OK
			echo s:test_ac_num."/".s:test_set_num." OK!"
		elseif s:test_num == 3 " ND
			echo "not downloaded"
		elseif s:test_num == 4 " NY
			echo "not yet"
		endif
	else 
		echo "print_data is " . a:print_type . "@s:print_data_test and it`s invalid." 
	endif
endfunction

function! gpp_compile#check_test_num()
	return s:print_data_test(1)
endfunction

function! gpp_compile#check_test()
	return s:print_data_test(3)
endfunction

function! gpp_compile#test(print_type)
	call s:do_test()
	return s:print_data_test(a:print_type)
endfunction

function! gpp_compile#gpp_test_reset()
	if s:test_num != 3
		" echo "change to 4"
		let s:test_num = 4
	else
		" echo "not change to 4"
	endif

	if s:gpp_test_auto_type == 1
		silent if s:is_target_dir() == 1
		call s:do_test()
	endif
endif
endfunction

function! gpp_compile#auto()
	call gpp_compile#gpp_compile_reset()
	call gpp_compile#gpp_test_reset()
endfunction

" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
