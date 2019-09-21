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


function! gpp_compile#auto()
	call gpp_compile#gpp_compile_reset()
	call gpp_compile#gpp_test_reset()
endfunction

" 退避していたユーザ設定を戻す
let &cpo = s:save_cpo
unlet s:save_cpo
