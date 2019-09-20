scriptencoding utf-8

" Load this module only once.
if exists('g:loaded_gpp_compile_autoload_copy')
	finish
endif
let g:loaded_gpp_compile_autoload_copy = '0.0.0 2019-05-12'

function! s:copy()
	call s:check("uname")
	let l:os = system("uname")
	" echo l:os
	if l:os == ""
		echo "unknown os!"
	endif
	if l:os =~ "Darwin" 
		" echo "mac"
		call s:check("pbcopy")
		call system("cat ".expand("%:p")." | pbcopy ")
	elseif l:os =~ "Linux"
		" echo "Linux"
		call s:check("xsel")
		call system("cat ".expand("%:p")." | xsel --clipboard --input")
	endif
endfunction

function! gpp_compile#copy()
	call s:copy()
endfunction
