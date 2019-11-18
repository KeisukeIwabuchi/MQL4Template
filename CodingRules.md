# コーディング規則


## 基本
+ インデントはスペース4つとする。
+ プログラムはproperty, define, include, resource, enum, struct, class, パラメーター, 外部変数, 関数の順に記述する。
+ 関数はOnInit, OnTick(OnCalculate, OnStart), OnDeinit, OnTimer, OnChartEvent, 自作関数の順に記述する。
+ 定義済み変数はMQL5の変数を優先して使用する。
```
OK: _Digits
NG: Digits
```
+ true, falseは全て小文字で記述する。



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


### 関数
関数については下記のようになる。

```
int Sum(int a, int b)
{
    return(a + b);
}
```

関数と関数の間は2行あける。

```
void Hoge()
{

}


void Uga()
{

}
```


### 三項演算子
必要に応じて三項演算子を使用して良い。  
ただし三項演算子内に三項演算子を記述してはいけない。

```
a = (条件) ? 1 : -1; // OK
b = (条件1) ? (条件2) ? 1 : -1 : 0; // NG
```























