scriptencoding utf-8


" Load this module only once.
if exists('g:loaded_gpp_compile_autoload_downlload')
	finish
endif
let g:loaded_gpp_compile_autoload_download = '0.0.0 2019-05-12'

let s:gpp_dir_type = get(g:,'gpp_dir_type',0)


function! s:get_sample_data_page()
	if s:gpp_dir_type == 0
		let l:atcoder_task_url = "https://atcoder.jp/contests/" . split(expand("%:p"),"/")[-2] . "/tasks?lang=en"
	elseif s:gpp_dir_type == 1
		let l:atcoder_task_url = "https://atcoder.jp/contests/" . split(expand("%:p"),"/")[-3] . "/tasks?lang=en"
	else 
		echo "invalid g:gpp_dir_type \n".s:gpp_dir_type." is not invalid!"
	endif

	let l:atcoder_task_site_data = system("curl -s " . l:atcoder_task_url )
	
	if len(split(l:atcoder_task_site_data,"Task Name")) == 1
		let s:test_num = 3
		let s:gpp_test_auto_type = 0
		echo "failed to find url"
		return
	endif

	let l:atcoder_task_site_data = split(l:atcoder_task_site_data,"Task Name")[1]
	let l:atcoder_task_site_data_list = split(l:atcoder_task_site_data,"text-center no-break")[1:]
	for l:hoge in l:atcoder_task_site_data_list
		let l:hoge = split(l:hoge,"><a href='")[1]
		let l:question_name = ""
		if s:gpp_dir_type == 0
			let l:question_name = toupper(split(expand("%:p:r"),"/")[-1])
		elseif s:gpp_dir_type == 1
			let l:question_name = toupper( split(expand("%:p"),"/")[-2] )
		endif

		if stridx(l:hoge, l:question_name) == -1
			echo "not match"
			let s:gpp_test_auto_type = 0
			continue
		endif
		echo "match"
		let l:hoge = split(l:hoge,'</a>')[0]
		let l:hoge = split(l:hoge,"'>")[0]
		let l:ans = "https://atcoder.jp".l:hoge 
		let l:hoge = l:ans."?lang=en"
		echo l:hoge
		return l:hoge
	endfor
	finish
endfunction

function! s:get_test_data()
	echo "making files"
	let l:atcoder_url = s:get_sample_data_page()
	if l:atcoder_url == ""
		return
	endif
	echo "downloading sample data from " . l:atcoder_url . "..."
	let l:atcoder_site_data = system("curl -s " . l:atcoder_url )
	" echo "hoge"
	let l:test_data_list = split(l:atcoder_site_data,"Sample Input")[1:]

	let l:test_data_num = 1

		let l:test_dir = "/" . join(split(expand("%:p"),"/","g")[:-2],"/") ."/test"

	if !isdirectory(l:test_dir) 
		call mkdir(l:test_dir,"p")
	endif
	for l:test_data in l:test_data_list
		let l:tmp_data = split(l:test_data,"Sample Output ")
		echo "hoge"
		let l:tmp_input = split(split(split(l:tmp_data[0],'<pre\(\w\|\s\|"\)*>')[1],"</pre>")[0],"\n")
		let l:tmp_output = split(split(split(l:tmp_data[1],'<pre\(\w\|\s\|"\)*>')[1],"</pre>")[0],"\n")

		if s:gpp_dir_type == 0
			let l:input_file_name = l:test_dir."/sample_input".split(expand("%:p:r"),"/")[-1] ."_".l:test_data_num.".txt"
			let l:output_file_name = l:test_dir."/sample_output".split(expand("%:p:r"),"/")[-1] ."_".l:test_data_num.".txt"
		elseif s:gpp_dir_type == 1
			let l:input_file_name = l:test_dir."/sample-".l:test_data_num.".in"
			let l:output_file_name = l:test_dir."/sample-".l:test_data_num.".out"
		endif

		call writefile(l:tmp_input, l:input_file_name)
		call writefile(l:tmp_output,l:output_file_name)
		let l:test_data_num += 1
	endfor
endfunction