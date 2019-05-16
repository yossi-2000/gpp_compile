# gpp_compile

## つかいかた
:GppCompile とvimの下の欄に打つと自動でコンパイルしてくれます.
:GppCompileShort とすると短く結果を表示します。
:GppCompileTest とするとTestがされます.なおデータがないときはリモートからdownloadします。
:GppCompileTestShort とするとTestがされます.上のコマンドとの違いはいくつが通ったかが表示されるだけになってます.
:GppCompileTestVeryShort とするとTestがされます.上のコマンドとの違いはすべて通ったかそうでないかが表示されます。

:GppCompileCopy で開いてるファイルのデータをクリップボードにコピーする

gpp_compile#check_compile_num()でcompileの状態が
1: NG
2: OK
3: WA
4: NY(not yet!)

gpp_compile#check_compile()でcompileの状態が
NG
OK
WA
NY
で表示される。

gpp_compile#check_test_num()でtestの状況が(s:test_num )
1: NG
2: OK
3: ND ( not downloaded )
4: NY(not yet!)
- gpp_compile#check_test()でtestが
{ac}/{wa} or  null
の形で数字が表示される。

printtype
1 just num
2 two char
3 short message(just in test)
4 full

s:gpp_compile_file()
compile target file
return error message

s:gpp_compile_file_no_warn()
compile target file
return error message (without warn)

s:gpp_test()
test binary file
return error message

## 設定
### ツールが動くディレクトリの指定
let g:gpp_compile_work_dir = $HOME ."/kyopro"
などとするとツールが動くディレクトリを決められます。
こうすると~/kyopro/*のファイルで動きます
- 標準はkyopro
:call gpp_compile#is_target_dir()
で動くディレクトリーかわかります.

### コンパイラの種類
let g:gpp_compile_compiler="clang++"
などとするとコンパイラをclang++に変えられます
- 標準は g++
let g:gpp_compile_compiler_warning_option = "-Wall"
などとするとコンパイラのWaringのオプションを選べます.
- 標準は"-Wall"
let g:gpp_compile_compiler_option = "-std=c++1z"
などとするとコンパイラの(Waringでない)オプションを選べます.
- 標準は""

### 自動コンパイル
let g:gpp_compile_auto_type = 0
とすると自動コンパイルしなくなる.
- なおデフォルトは1で自動コンパイルする。

### 自動テスト
let g:gpp_test_auto_type = 0
とすると自動テストしなくなる.
- なおデフォルトは1で自動コンパイルする。
