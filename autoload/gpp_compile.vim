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

" auto compile
let s:gpp_compile_auto_type = get(g:,'gpp_compile_auto_type','1')
" work dir
let s:gpp_compile_work_dir = get(g:,'gpp_compile_work_dir',$HOME . "/" ."kyopro")

let s:gpp_compile_is_compiled = 4
let s:gpp_compile_is_tested = 4

function! s:check(check_command)
	if !executable(a:check_command)
		echohl WaringMsg | echo a:check_command . " is not defined!" | echohl None | finish
	endif
endfunction

call s:check(s:gpp_compile_compiler)
call s:check("diff")

function! s:is_target_dir(print_type)
	if a:print_type == 1
		echo ( expand("%:p") =~ s:gpp_compile_work_dir )
	endif
	return expand("%:p") =~ s:gpp_compile_work_dir 
endfunction

function! gpp_compile#is_target_dir()
	return s:is_target_dir(1)
endfunction

function! s:compile_file()
	return system(s:gpp_compile_compiler." ".s:gpp_compile_compiler_option." ".s:gpp_compile_compiler_warning_option." ".expand("%:p")." -o ".expand("%:p:r").".out" )
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

	elseif a:print_type == 2 " two char
		if s:gpp_compile_is_compiled == 1 " NG
			echo "NG"
		elseif s:gpp_compile_is_compiled == 2 " OK
			echo "OK"
		elseif s:gpp_compile_is_compiled == 3 " WA
			echo "WA"  
		elseif s:gpp_compile_is_compiled == 4 " NY
			echo "NY"
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

function! s:gpp_compile_auto()
	if s:gpp_compile_auto_type == 1
		if s:is_target_dir(0) == 1
			silent call s:do_compile()
		endif
	endif
endfunction

function! gpp_compile#compile(print_type)
	call s:do_compile()
	return s:print_data_compile(a:print_type)
endfunction

function! gpp_compile#gpp_compile_reset()
	let s:gpp_compile_is_compiled = 4
	call s:gpp_compile_auto()
endfunction

function! gpp_compile#check_compile_num()
	call s:print_data_compile(1)
endfunction

function! gpp_compile#check_compile()
	call s:print_data_compile(2)
endfunction

function! s:get_test_data()
	let l:atcoder_url = "https://atcoder.jp/contests/" . split(expand("%:p"),"/")[-2] . "/tasks/".split(expand("%:p"),"/")[-2] . "_" .tolower(split(expand("%:p:r"),"/")[-1])
	echo "downloading sample data from " . l:atcoder_url . "..."
	let l:atcoder_site_data = system("curl -s " . l:atcoder_url )
	echo "hoge"
	let l:test_data_list = split(l:atcoder_site_data,"Sample Input")[1:]

	let l:test_data_num = 1
	let l:test_dir = "/" . join(split(expand("%:p"),"/","g")[:-2],"/") ."/test"
	if !isdirectory(l:test_dir) 
			call mkdir(l:test_dir,"p")
	endif
	for l:test_data in l:test_data_list
		let l:tmp_data = split(l:test_data,"Sample Output ")
		let l:tmp_input = split(split(split(l:tmp_data[0],"<pre>")[1],"</pre>")[0],"\n")
		let l:tmp_output = split(split(split(l:tmp_data[1],"<pre>")[1],"</pre>")[0],"\n")

		call writefile(l:tmp_input, "/".join(split(expand("%:p"),"/")[:-2],"/") . "/test/sample_input".split(expand("%:p:r"),"/")[-1] ."_".l:test_data_num.".txt")
		call writefile(l:tmp_output, "/".join(split(expand("%:p"),"/")[:-2],"/") . "/test/sample_output".split(expand("%:p:r"),"/")[-1] ."_".l:test_data_num.".txt")
		let l:test_data_num += 1
	endfor
endfunction

function! gpp_compile#test(print_type)
	if s:gpp_compile_is_compiled
		call s:print_data(0)
	endif

	let l:test_file_list = split(system("ls " . "/".join(split(expand("%:p"),"/")[:-2],"/") ."/test/sample_input".split(expand("%:p:r"),"/")[-1] . "_* 2>/dev/null") ,"\n")
	if len(l:test_file_list) == 0
		echo "make file"
		call s:get_test_data()	
		let l:test_file_list = split(system("ls " . "/".join(split(expand("%:p"),"/")[:-2],"/") ."/test/sample_input".split(expand("%:p:r"),"/")[-1] . "_* 2>/dev/null") ,"\n")
		if len(l:test_file_list) == 0
			echo "failed to make sample testfiles."
		endif
	else
		" echo l:test_file_list
	endif 

	let l:ac_num = 0
	for l:input_file in l:test_file_list
		let l:diff_str = system(expand("%:p:r") . ".out < " ."/".join(split(expand("%:r"),"/")[:-2],"/") . l:input_file . " | diff -u --strip-trailing-cr - " .substitute(l:input_file,"in","out","g"))
		if l:diff_str != ""
			echo l:diff_str | echo system("cat ". l:input_file)
		else
			let l:ac_num += 1
		endif
	endfor
	if a:print_type == 0
		echo l:ac_num . "/" .len(l:test_file_list) . " is accepted!"
	elseif a:print_type == 1
		echo l:ac_num . "/" .len(l:test_file_list)
	else
		if l:ac_num == len(l:test_file_list)
			echo 1
			" echo 'OK!'
		else
			echo 0
			" echo 'NG!'
		endif
	endif
endfunction

" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
