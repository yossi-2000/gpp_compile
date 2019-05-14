# gpp_compile

## つかいかた
:GppCompile とvimの下の欄に打つと自動でコンパイルしてくれます.
:GppCompileShort とすると短く結果を表示します。
:GppCompileTest とするとTestがされます.なおデータがないときはリモートからdownloadします。
:GppCompileTestShort とするとTestがされます.上のコマンドとの違いはいくつが通ったかが表示されるだけになってます.
:GppCompileTestVeryShort とするとTestがされます.上のコマンドとの違いはすべて通ったかそうでないかが表示されます。


## 設定
### ツールが動くディレクトリの指定
let g:gpp_compile_work_dir = "kyopro"
などとするとツールが動くディレクトリを決められます。
こうすると~/kyopro/****のファイルで動きます
- 標準はkyopro

### コンパイラの種類
let g:gpp_compile_compiler="clang++"
などとするとコンパイラをclang++に変えられます
- 標準は g++
let g:gpp_compile_compiler_option = "-Wall"
などとするとコンパイラのオプションを選べます.
- 標準は"-Wall"

### 自動コンパイル
let g:gpp_compile_auto_type = 0
とすると自動コンパイルしなくなる.
なおデフォルトは1で自動コンパイルする。
