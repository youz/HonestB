# Honest B

難読関数型プログラミング言語[Lazy K](https://tromp.github.io/cl/lazy-k.html)の方言です。
"スロー" と "クイック" と "❤" のみでプログラムを記述します。

## 文法

```bnf
Program ::= Expr
   Expr ::= "スロー" | "クイック" | Expr Expr "❤"
```

`スロー`はSコンビネータ、`クイック`はKコンビネータ、`❤` (U+2764 heavy black heart)は関数適用演算子です。
関数適用は逆ポーランド記法で記述します。

| Lazy K  | Honest B   | ラムダ式     |
|---------|------------|--------------|
| s       | スロー     | \xyz. xz(yz) |
| k       | クイック   | \xy. x       |
| `e1 e2  | e2 e1 ❤   | e1 e2        |

関数適用では左側の式が引数、右側の式が関数となる事に注意してください。
Iコンビネータ ``` i = ``skk ``` をHonest Bに変換した時に`クイッククイックスロー❤❤`となるように
したかった為この順番になっています。

`スロー`、`クイック`、`❤`以外の文字列は無視して読み飛ばします。
❤は❤️のように異字体セレクタ(U+FE0E or U+FE0F)が付いていても問題ありません。

## 入出力

Honest BプログラムはLazy Kと同様に "入力文字列を引数に取って出力文字列を返す関数" となるように記述します。

文字列はUTF-8エンコードのバイト列を[チャーチ数](https://ja.wikipedia.org/wiki/%E3%83%A9%E3%83%A0%E3%83%80%E8%A8%88%E7%AE%97#%E8%87%AA%E7%84%B6%E6%95%B0%E3%81%A8%E7%AE%97%E8%A1%93)のリスト([チャーチ対](https://ja.wikipedia.org/wiki/%E3%83%A9%E3%83%A0%E3%83%80%E8%A8%88%E7%AE%97#%E5%AF%BE))として表します。

入力文字列は無限リストとなっており、実際の入力の終端以降はチャーチ数の256が無限に並びます。

出力の終端は256以上のチャーチ数で表します。
出力リストの終端文字以降の部分は無視するので、例えば出力リストが

```
(cons 65 (cons 256 <チャーチ対ではない何かの関数>))
```

というような構造になっていてもエラーにはなりません。


## Honest Bプログラムの最も簡単な書き方

1. [Lazy Kリファレンス実装パッケージ (lazy-k.zip)](https://sange.fi/esoteric/essie2/download/)に含まれているScheme -> Lazy Kコンパイラ **lazier.scm** を入手する
    - [Gauche](https://practical-scheme.net/gauche/index-j.html) v0.9.12 で動作する事を確認済み
2. Lazy Kパッケージ内のegフォルダにあるサンプルやこのリポジトリのSchemeコードを参考にしながらSchemeプログラムを書く
    - 最終出力は `print-as-unlambda` 関数を使ってUnlambdaスタイルで出力する
3. 2.のSchemeプログラムを実行し、出力結果をこのリポジトリの [lazyk2hb.rb](./lazyk2hb.rb) でコンパイルする

```
$ gosh myprog.scm > myprog.lazyk
$ ruby lazyk2hb.rb myprog.lazyk > myprog.hb
```

もしくは

```
$ gosh myprog.scm | ruby lazyk2hb.rb > myprog.hb
```

4. 完成

lazyk2hb.rbを介さずにschemeプログラムからダイレクトにHonest Bプログラムを生成したい場合は
[sample-hb.scm](./sample-hb.scm)を参考にしてみてください。


## 実行方法

要 ruby ver3.0以上
```
$ ruby honestb.rb myprog.hb
```


## サンプルコード

### echo

```
クイッククイックスロー❤❤
```

実行
```
$ echo ご友人！ | ruby honestb.rb echo.hb
ご友人！
```

### Hello, world!

```
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
クイックスロー❤❤クイッククイックスロー❤❤スロー❤❤❤クイッククイックスロー
❤❤クイッククイックスロー❤❤スロー❤❤❤クイック❤クイック❤クイッククイック
スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤
❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤スロー❤❤❤
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤クイック
クイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイッククイックスロー❤❤
クイックスロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤クイック
クイックスロー❤❤スロー❤❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
❤スロー❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー
❤❤❤クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
スロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤クイッククイック
スロー❤❤スロー❤❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー
❤❤スロー❤❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤❤
クイック❤スロー❤❤クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤
クイック❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤
❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤
クイッククイックスロー❤❤スロー❤❤❤クイックスロークイック❤スロー❤❤スロー
❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイック❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
クイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤スロー
❤❤クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイック
クイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイックスロー
クイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤クイッククイックスロー
❤❤スロー❤❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤
スロー❤❤クイック❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤クイック
クイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイッククイックスロー❤❤
クイックスロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤クイック
クイックスロー❤❤クイッククイックスロー❤❤スロー❤❤スロー❤❤❤クイック
スロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤クイックスロー
クイック❤スロー❤❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤スロー❤❤
クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイック
クイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイック
スロー❤❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤スロー
❤❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイック❤スロー❤❤クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤
クイック❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤
❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤
クイッククイックスロー❤❤スロー❤❤❤クイックスロークイック❤スロー❤❤スロー
❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイッククイックスロー❤❤クイッククイックスロー❤❤クイッククイックスロー❤❤
スロー❤❤スロー❤❤❤クイックスロークイック❤スロー❤❤スロー❤❤❤❤クイック
❤クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイッククイック
スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイックスロークイック❤
スロー❤❤スロー❤❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー
❤❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤
クイック❤スロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
クイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤スロー
❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤クイッククイック
スロー❤❤スロー❤❤スロー❤❤クイック❤クイッククイックスロー❤❤クイック
スロークイック❤スロー❤❤スロー❤❤クイックスロークイック❤スロー❤❤スロー
❤❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤❤クイック
クイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイック
スロー❤❤クイッククイックスロー❤❤スロー❤❤❤クイック❤スロー❤❤クイック❤
クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイッククイックスロー
❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイックスロークイック❤スロー
❤❤スロー❤❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤❤
クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック
クイックスロー❤❤クイッククイックスロー❤❤スロー❤❤❤クイック❤スロー❤❤
クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイック
クイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイック
スロー❤❤クイッククイックスロー❤❤スロー❤❤❤クイックスロークイック❤スロー
❤❤スロー❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤
スロー❤❤クイック❤スロー❤❤クイッククイックスロー❤❤クイックスロークイック
❤スロー❤❤スロー❤❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイック❤
クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤クイッククイックスロー
❤❤クイックスロークイック❤スロー❤❤スロー❤❤クイッククイックスロー❤❤
クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤スロー❤❤❤
クイックスロークイック❤スロー❤❤スロー❤❤クイックスロークイック❤スロー❤❤
スロー❤❤クイッククイックスロー❤❤クイックスロークイック❤スロー❤❤スロー❤
❤クイッククイックスロー❤❤クイッククイックスロー❤❤スロー❤❤❤クイック❤
スロー❤❤クイック❤クイッククイックスロー❤❤スロー❤❤スロー❤❤クイック❤
```

実行
```
$ ruby honestb.rb hello.hb
Hello, world!
```

### FizzBuzz

[fizzbuzz.hb](./fizzbuzz.hb)

実行
```
$ ruby honestb.rb fizzbuzz.hb
1
2
ご友人…
4
素敵だ…
ご友人…
7
8
ご友人…
素敵だ…
11
ご友人…
13
14
ご友人…素敵だ…
16
<中略>
97
98
ご友人…
素敵だ…
```


## LICENSE

MIT License
