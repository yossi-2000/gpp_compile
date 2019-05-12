# gpp_compile

## つかいかた
:GppCompile とvimの下の欄に打つと自動でコンパイルしてくれます.

## 設定
### コンパイラの種類
let g:gpp_compile_compiler="clang++"
などとするとコンパイラをclang++に変えられます
- 標準は g++

### 自動コンパイル
let g:gpp_compile_auto_type = 0
とすると自動コンパイルしなくなる.
なおデフォルトは1で自動コンパイルする。
