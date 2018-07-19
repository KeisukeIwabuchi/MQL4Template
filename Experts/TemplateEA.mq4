// #property copyright ""
// #property link      ""
#property strict
#property version   "1.00"


#define DEVELOP_MODE


#include <Template_1.07.mqh>


// パラメーター
sinput double Lots        = 0.1; // 取引数量
sinput int    MagicNumber = 123; // マジックナンバー
input  double TP          = 100; // 利食い(pips)
input  double SL          = 100; // 損切り(pips)
sinput double Slippage    = 1.0; // スリッページ(pips)
#ifndef DEVELOP_MODE
    sinput int    Spread      = 10; // 最大スプレッド(point)
#endif 
#ifdef DEVELOP_MODE
    extern double DoubleValue = 10;
    extern int    IntValue    = 10;
#endif


double Pos;


int OnInit()
{
    ExpertInitialize();

    return(INIT_SUCCEEDED);
}


void OnTick()
{
    // ポジション情報の取得
    Pos = GetOrderCount(OPEN_POS, MagicNumber);


    // エントリー
    EntryProcess();
   
   
    // 決済
    ExitProcess();
}


void OnDeinit(const int reason)
{
    ProgramDeinit();
}


// エントリー処理の実行
void EntryProcess()
{
    if (!IsTrade) {
        return; // 取引停止状態
    }
   
    if (TradeBar == Bars) {
        return; // このローソク足でエントリー済み
    }
   
    if (Pos != 0) {
        return; // 非ドテン時、ポジション保有済み
    }
    
    #ifndef DEVELOP_MODE
    if (!SpreadFilter(Spread)) {
        return;
    }
    #endif


    TRADE_SIGNAL entry_signal = GetEntrySignal();
    int trade_type   = -1;
    double trade_price  = 0;
    
    if (Pos == 0) {
        if (entry_signal == BUY_SIGNAL && BuyTrade == true) {
            trade_type = OP_BUY;
            trade_price = Ask;
        } else if (entry_signal == SELL_SIGNAL && SellTrade == true) {
            trade_type = OP_SELL;
            trade_price = Bid;
        }
    }
   
    if (trade_type == -1) {
        return; // 取引種別不正
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
   
    if (trade_result != 0) {
        if (trade_result == 134 && IsTesting()) {
            IsTrade = false;
        }
    }
    
    TradeBar = Bars;
}


// 決済処理の実行
void ExitProcess()
{
    if (Pos > 0) {
        if (GetExitSignal()) {
            Exit(Slippage, MagicNumber);
        }
    }
}


// エントリー条件の判定
TRADE_SIGNAL GetEntrySignal()
{
    return(EntrySignal());
}


TRADE_SIGNAL EntrySignal()
{
    if (Close[1] > Open[1]) {
        return(BUY_SIGNAL);
    } else if (Close[1] < Open[1]) {
        return(SELL_SIGNAL);
    }
    return(NO_SIGNAL);
}


// 決済条件の判定
bool GetExitSignal()
{
    return(false);
}
