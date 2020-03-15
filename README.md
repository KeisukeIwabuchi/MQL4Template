# MQL4Template
EA・インジケーター開発のテンプレートです。  
最新版はversion1.10  
  
基本的な使い方としてはTemplateEA.mq4をコピペしてEAを開発してください。  
必要な機能はTemplate_1.10.mqhから適宜コピペしてください。  
  
もしくはEAからTemplate_1.10.mqhを読み込んで使用します。  
```
#include <MQL4Template\Template_1.10.mqh>
```
  
  
  
  
## 定義値
+ OPEN_POS -> ポジション情報の取得に使用。エントリー中のポジション(OP_BUY + OP_SELL)を指す。
+ ALL_POS -> ポジション情報の取得に使用。全種類のポジションを指す。
+ PEND_POS -> ポジション情報の取得に使用。待機注文を指す。
+ RETRY_INTERVAL -> リトライ処理の間隔(ミリ秒)
+ RETRY_TIME_LIMIT -> リトライ処理の制限時間(ミリ秒)
  
  
  
  
## 列挙型
+ TRADE_SIGNAL -> 取引方向を表すための列挙型。主にエントリー判定に使用。
+ EROR -> 処理結果を3パターン受け取りたいときに使用。
+ SUMMER_TIME_MODE -> サマータイムの方式。
  
  
  
  
## 外部変数(TemplateEA.mq4)
+ TradeBar -> 最後にエントリーした時点でのBarsの値。連続エントリーの制御に使用。
+ BuyTrade -> 買い取引の許可
+ SellTrade -> 売り取引の許可
