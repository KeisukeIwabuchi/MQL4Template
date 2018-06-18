# コーディング規則


## 基本
+ インデントはスペース4つとする。


## 命名規則
### クラス名

StudlyCaps記法で記述する。


### 定義値

アンダースコア文字を区切り文字として大文字で記述。


### 外部変数

StudlyCaps記法で記述する。


### 内部変数

スネークケースで記述する。


### グローバル変数

特別な理由がない限り使用するべきではない。


### 関数

キャメルケースで記述する。
例外としてMQL4標準のイベントハンドラに関してはアッパーキャメルケースを許容する。


## 制御構造
### if, else if, else
if制御については下記のようになる。

```
if (条件1) {
    // if body;
} else if (条件2) {
    // else if body;
} else {
    // else body;
}
```

1行で記述できる場合でも{}を省力せず、3行かけて記述する。


### switch, case
switch制御については下記のようになる。
意図的に処理スルーさせる場合は「// no break」等、コメントを記述する。

```
switch (値) {
    case: 0
        Print("hoge");
        break;
    case: 1
        Print("uga");
        return;
    default:
        Print("foo");
        break;
}
```


### while, do while
while制御については下記のようになる。

```
while (条件) {
    // structure body
}
```

do while制御については下記のようになる。

```
do {
    // structure body
} while (条件);
```


### for
for制御については下記のようになる。

```
for (int i = 0; i < 10; i++) {
    // for body
}
```


##　その他
### 関数
関数については下記のようになる。

```
int Sum(int a, int b)
{
    return(a + b);
}
```




























