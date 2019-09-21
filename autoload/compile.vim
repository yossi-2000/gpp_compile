
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

