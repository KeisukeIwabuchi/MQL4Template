// #property copyright ""
// #property link      ""
#property strict
#property version   "1.00"


#define IS_SAR 0      // ドテン取引するか? 0:ドテンしない, 1:ドテンする
#define TRADE_RETRY 0 // エントリーに失敗したときに同じローソク足で再発注を可能とするか? 0:しない, 1:する


#include <Template_1.06.mqh>


// パラメーター
sinput double Lots        = 0.1; // 取引数量
sinput int    MagicNumber = 123; // マジックナンバー
input  double TP          = 100; // 利食い(pips)
input  double SL          = 100; // 損切り(pips)
sinput double Slippage    = 1.0; // スリッページ(pips)


int OnInit()
{
   ExpertInitialize();

   return(INIT_SUCCEEDED);
}


void OnTick()
{
   // ポジション情報の取得
   double buy_pos = getOrderLots(OP_BUY, MagicNumber);
   double sell_pos = getOrderLots(OP_SELL, MagicNumber);


   // エントリー
   EntryProcess(buy_pos, sell_pos);
   
   
   // 決済
   ExitProcess(buy_pos, sell_pos);
}


void OnDeinit(const int reason)
{
   ProgramDeinit();
}


// エントリー処理の実行
void EntryProcess(const double buy_pos, const double sell_pos)
{
   if (!IsTrade) {
      return; // 取引停止状態
   }
   
   if (TradeBar == Bars) {
      return; // このローソク足でエントリー済み
   }
   
   if (IS_SAR == 0) {
      if (buy_pos != 0 || sell_pos != 0) {
         return; // 非ドテン時、ポジション保有済み
      }
   }
   
   bool   is_entry     = true;
   trade  entry_signal = getEntrySignal();
   int    trade_type   = -1;
   double trade_price  = 0;
      
   if (entry_signal == BUY && buy_pos == 0) {
      trade_type = OP_BUY;
      trade_price = Ask;
   } else if (entry_signal == SELL && sell_pos == 0) {
      trade_type = OP_SELL;
      trade_price = Bid;
   }
   
   if (trade_type == -1) {
      return; // 取引種別不正
   }
   
   if (IS_SAR > 0) {
      if (buy_pos > 0 || sell_pos > 0) {
         if(!Exit(Slippage, MagicNumber)) {
            return; // ドテン時、既存ポジションの決済失敗
         }
      }
   }

   int trade_result = EntryWithPips(
      trade_type,
      Lots,
      trade_price,
      Slippage,
      SL,
      TP,
      COMMENT,
      MagicNumber);
   
   if (trade_result == 0) {
      TradeBar = Bars;
   } else {
      if (TRADE_RETRY == 0) {
         TradeBar = Bars;
      }
      if (trade_result == 134 && IsTesting()) {
         IsTrade = false;
      }
   }
}


// 決済処理の実行
void ExitProcess(const double buy_pos, const double sell_pos)
{
   if (buy_pos + sell_pos > 0) {
      if (getExitSignal()) {
         Exit(Slippage, MagicNumber);
      }
   }
}


// エントリー条件の判定
trade getEntrySignal()
{
   return(NO_TRADE);
}


// 決済条件の判定
bool getExitSignal()
{
   return(false);
}
