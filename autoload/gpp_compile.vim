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
let s:gpp_compile_compiler_option = get(g:, "gpp_compile_compiler", "-Wall" )
" auto compile
let s:gpp_compile_auto_type = get(g:,'gpp_compile_auto_type','1')
" work dir
let s:gpp_compile_work_dir = get(g:,'gpp_compile_work_dir',$HOME . "/" ."kyopro")

let s:gpp_compile_is_compiled = 1
let s:gpp_compile_is_tested = 1

function! s:check(check_command)
	if !executable(a:check_command)
		echohl WaringMsg | echo a:check_command . " is not defined!" | echohl None | finish
	endif
endfunction

call s:check(s:gpp_compile_compiler)
call s:check("diff")

function! s:compile_file()
	let s:gpp_compile_is_compiled = 0
	return system( s:gpp_compile_compiler . " " .s:gpp_compile_compiler_option . " " . expand("%:p") . " -o " . expand("%:p:r").".out" )
endfunction

function! s:print_data(print_type)
	if s:gpp_compile_is_compiled 
		let s:cout_string = s:compile_file()
	endif

	if s:cout_string != ""
		if a:print_type
			highlight MyMessage ctermfg=red | echohl MyMessage | echo "NG!" | echohl NONE
		else
			echo s:cout_string | highlight StatusLine   term=NONE cterm=NONE ctermbg=red
		endif
	else
		highlight StatusLine   term=NONE cterm=NONE ctermbg=blue
		highlight MyMessage ctermfg=green  | echohl MyMessage | echo 'OK!' | echohl NONE
	endif
	return 
endfunction

function! gpp_compile#compile(print_type)
	return s:print_data(a:print_type)
endfunction

function! s:is_target_dir()
	echo ( expand("%:p") =~ s:gpp_compile_work_dir )
	return expand("%:p") =~ s:gpp_compile_work_dir 
endfunction

function! gpp_compile#is_target_dir()
	return s:is_target_dir()
endfunction

function! s:gpp_compile_auto()
	if s:gpp_compile_auto_type
		if s:is_target_dir()
			call s:print_data(0)
		endif
	endif
endfunction

function! gpp_compile#gpp_compile_reset()
	let s:gpp_compile_is_compiled = 1
	call s:gpp_compile_auto()
endfunction

function! s:get_test_data()
	let l:atcoder_url = "https://atcoder.jp/contests/" . split(expand("%:p"),"/")[-2] . "/tasks/".split(expand("%:p"),"/")[-2] . "_" .tolower(split(expand("%:p:r"),"/")[-1])
	echo "downloading sample data from " . l:atcoder_url . "..."
	let l:atcoder_site_data = system("curl -s " . l:atcoder_url )
	let l:test_data_list = split(l:atcoder_site_data,"Sample Input")[1:]

	let l:test_data_num = 1
	let l:test_dir = "/" . join(split(expand("%:p"),"/","g")[:-2],"/") ."/test"
	if !isdirectory(l:test_dir) 
			call mkdir(l:test_dir,"p")
	endif
	for l:test_data in l:test_data_list
		let l:tmp_data = split(l:test_data,"Sample Output ")
		let l:tmp_input = split(split(split(l:tmp_data[0],"<pre>")[1],"<pre>")[0],"\n")
		let l:tmp_output = split(split(split(l:tmp_data[1],"<pre>")[1],"<pre>")[0],"\n")

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
