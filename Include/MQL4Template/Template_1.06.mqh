//+------------------------------------------------------------------+
//|                                                     Template.mqh |
//|                                 Copyright 2018, Keisuke Iwabuchi |
//|                                        https://order-button.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Keisuke Iwabuchi"
#property link      "https://order-button.com/"
#property strict
#property version   "1.00"


#define COMMENT "EA"
#define OPEN_POS 6
#define ALL_POS  7
#define PEND_POS 8
#define RETRY_INTERVAL 100 // msec
#define RETRY_TIME_LIMIT 5000 // msec


/**
 * 取引方向
 */
enum TRADE_SIGNAL
{
    BUY_SIGNAL = 1,
    SELL_SIGNAL = -1,
    NO_SIGNAL = 0
};


// 外部変数
string __Symbol;
double __Point;
int __Digits;
int TradeBar;
int Mult;
bool IsTrade;
int ObjectCount;
int GMTShift;


/**
 * 外部変数の初期化を実行する
 */
void ProgramInitialize()
{
    // 外部変数の初期化
    __Symbol = _Symbol;
    __Point = MarketInfo(__Symbol, MODE_POINT);
    __Digits = (int)MarketInfo(__Symbol, MODE_DIGITS);
    TradeBar = Bars;
    Mult = (__Digits == 3 || __Digits == 5) ? 10 : 1;
    // EZインベスト証券 USDJPY 4桁対応
    if  (AccountCompany() == "EZ Invest Securities Co., Ltd." &&
        StringSubstr(__Symbol, 0, 6) == "USDJPY") {
        Mult = 100;
    }
    IsTrade = true;
    ObjectCount = 0;
    GMTShift = 3;
}


/**
 * EA用の初期化処理を実行する
 *
 * @dependencies ProgramInitialize
 */
void ExpertInitialize()
{
    ProgramInitialize();
    
    #ifndef DEVELOP_MODE
    if (!IsTesting()) {
        ExpertRemove();
    }
    #endif

    // 口座のチェックアップ
    //--- ターミナルの自動売買の許可を確認
    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        Alert("自動売買が許可されていません。MT4のオプションを開き、"
            + "「自動売買を許可する」がチェックされているか確認して下さい。");
    } else if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
        Alert("自動売買が許可されていません。エキスパートアドバイザーの設定を開き、"
            + "全般タブにて「自動売買を許可する」にチェックを入れて下さい。");
    }
   
    //--- 口座の自動売買の許可を確認
    if (!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
        Alert("このアカウントは自動売買が許可されていません。");
    }
    if (!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
        Alert("このアカウントは自動売買が許可されていません。");
    }
   
    // インジケーターを非表示
    HideTestIndicators(true);
}


/**
 * 終了処理を実行する
 * コメントの消去, オブジェクトの削除を行う
 * ただしビジュアルモードでのバックテスト時には検証のため削除を行わない
 */
void ProgramDeinit()
{
    if (!IsVisualMode()) {
        Comment("");
      
        for (int i = 0; i < ObjectCount; i++) {
            ObjectDelete(0, "Obj" + IntegerToString(i));
        }
    }
}


/**
 * 保有中ポジションの取引数量を取得する
 *
 * @param type  検索タイプ
 * @param magic  マジックナンバー
 *
 * @return  該当ポジションの合計取引数量
 */
double GetOrderLots(int type, int magic)
{
    double lots = 0.0;

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS)) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        switch (type) {
            case OP_BUY:
                if (OrderType() == OP_BUY) {
                    lots += OrderLots();
                }
                break;
            case OP_SELL:
                if (OrderType() == OP_SELL) {
                    lots += OrderLots();
                }
                break;
            case OP_BUYLIMIT:
                if (OrderType() == OP_BUYLIMIT) {
                    lots += OrderLots();
                }
                break;
            case OP_SELLLIMIT:
                if (OrderType() == OP_SELLLIMIT) {
                    lots += OrderLots();
                }
                break;
            case OP_BUYSTOP:
                if (OrderType() == OP_BUYSTOP) {
                    lots += OrderLots();
                }
                break;
            case OP_SELLSTOP:
                if (OrderType() == OP_SELLSTOP) {
                    lots += OrderLots();
                }
                break;
            case OPEN_POS:
                if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                    lots += OrderLots();
                }
                break;
            case ALL_POS:
                lots += OrderLots();
                break;
            case PEND_POS:
                if (OrderType() == OP_BUYLIMIT || 
                    OrderType() == OP_SELLLIMIT || 
                    OrderType() == OP_BUYSTOP || 
                    OrderType() == OP_SELLSTOP) {
                    lots += OrderLots();
                }
                break;
            default:
                break;
        }
    }
    return(lots);
}


/**
 * 保有中ポジションの件数を取得する
 *
 * @param type  検索タイプ
 * @param magic  マジックナンバー
 *
 * @return  該当ポジションのポジション数
 */
int GetOrderCount(int type, int magic)
{
    int count = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS)) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        switch (type) {
            case OP_BUY:
                if (OrderType() == OP_BUY) {
                    count++;
                }
                break;
            case OP_SELL:
                if (OrderType() == OP_SELL) {
                    count++;
                }
                break;
            case OP_BUYLIMIT:
                if (OrderType() == OP_BUYLIMIT) {
                    count++;
                }
                break;
            case OP_SELLLIMIT:
                if (OrderType() == OP_SELLLIMIT) {
                    count++;
                }
                break;
            case OP_BUYSTOP:
                if (OrderType() == OP_BUYSTOP) {
                    count++;
                }
                break;
            case OP_SELLSTOP:
                if (OrderType() == OP_SELLSTOP) {
                    count++;
                }
                break;
            case OPEN_POS:
                if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                    count++;
                }
                break;
            case ALL_POS:
                count++;
                break;
            case PEND_POS:
                if (OrderType() == OP_BUYLIMIT || 
                    OrderType() == OP_SELLLIMIT || 
                    OrderType() == OP_BUYSTOP || 
                    OrderType() == OP_SELLSTOP) {
                    count++;
                }
                break;
            default:
                break;
        }
    }
    return(count);
}


/**
 * 発注処理を実行する
 *
 * @param type  取引種別
 * @param lots  取引数量
 * @param price  注文価格
 * @param slip  スリッページ
 * @param sl  損切り価格
 * @param tp  利食い価格
 * @param comment  コメント
 * @param magic  マジックナンバー
 *
 * @return  エラーコード, 0は正常終了
 *
 * @dependencies NormalizeLots, ErrorDescription, TradeTypeToString
 */
int Entry(
    const int type,
    double lots,
    double price,
    int slip,
    double sl,
    double tp,
    const string comment,
    const int magic)
{
    if (!IsTradeAllowed()) {
        return(7002);
    }

    int err = -1;
    color arrow = (type % 2 == 0) ? clrBlue : clrRed;
   
    lots = NormalizeLots(lots);
    price = NormalizeDouble(price, Digits);
    sl = NormalizeDouble(sl, Digits);
    tp = NormalizeDouble(tp, Digits);
 
    uint starttime = GetTickCount();
    while(true) {
        if (GetTickCount() - starttime > RETRY_TIME_LIMIT) {
            Print("OrderSend timeout.");
            return(7001);
        }
      
        ResetLastError();
        RefreshRates();
      
        int ticket = OrderSend(
            __Symbol,
            type,
            lots,
            price,
            slip,
            sl,
            tp,
            comment,
            magic,
            0,
            arrow);
      
        if (ticket != -1) {
            return(0);
        }
      
        err = _LastError;
        Print("[OrderSendError] : ", err, " ", ErrorDescription(err));

        if (err == 129) {
            break;
        }
        if (err == 130) {
            Print(
                "bid=", Bid, 
                " type=", TradeTypeToString(type), 
                " price=", price,
                " sl=", sl, " tp=", tp,
                " stoplevel=", MarketInfo(__Symbol, MODE_STOPLEVEL));
            break;
        }
      
        Sleep(RETRY_INTERVAL);
    }
   return(err);
}


/**
 * 取引数量を発注可能なロット数に合わせる
 *
 * @param lots  発注予定の取引数量
 * @param symbol  発注する通貨ペア名
 *                省略した場合は現在のチャートの通貨ペア
 *
 * @return  正規化された取引数量
 */
double NormalizeLots(double lots, string symbol = "")
{
    if (symbol == "") {
        symbol = __Symbol;
    }
   
    double max = MarketInfo(symbol, MODE_MAXLOT);
    double min = MarketInfo(symbol, MODE_MINLOT);
   
    if (lots > max) {
        return(max);
    }
    if (lots < min) {
        return(min);
    }
    return(NormalizeDouble(lots, 2));
}


/**
 * 取引種別を文字列として返す
 *
 * @param type  取引種別
 *
 * @return  取引種別の文字列
 */
string TradeTypeToString(const int type)
{
    switch (type) {
        case OP_BUY:
            return("OP_BUY");
        case OP_SELL:
            return("OP_SELL");
        case OP_BUYLIMIT:
            return("OP_BUYLIMIT");
        case OP_SELLLIMIT:
            return("OP_SELLLIMIT");
        case OP_BUYSTOP:
            return("OP_BUYSTOP");
        case OP_SELLSTOP:
            return("OP_SELLSTOP");
        default:
            return("Invalid value");
    }
}


/**
 * 発注処理を実行する
 * slippage, TP/SLはpips単位で指定可能
 *
 * @param type  取引種別
 * @param lots  取引数量
 * @param price  注文価格
 * @param slip  スリッページpips
 * @param sl  損切りpips
 * @param tp  利食いpips
 * @param comment  コメント
 * @param magic  マジックナンバー
 *
 * @return  エラーコード, 0は正常終了
 *
 * @dependencies PipsToPoint, PipsToPrice, Entry
 */
int EntryWithPips(
    const int    type,
    const double lots,
    const double price,
    const double slip,
    const double slpips,
    const double tppips,
    const string comment,
    const int    magic)
{
    int slippage = PipsToPoint(slip);
    double sl = 0;
    double tp = 0;

    if (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) {
        if (slpips > 0) {
            sl = price + PipsToPrice(slpips);
        }
        if (tppips > 0) {
            tp = price - PipsToPrice(tppips);
        }
    } else {
        if (slpips > 0) {
            sl = price - PipsToPrice(slpips);
        }
        if (tppips > 0) {
            tp = price + PipsToPrice(tppips);
        }
    }
   
    return(Entry(type, lots, price, slippage, sl, tp, comment, magic));
}


/**
 * pips単位の値を価格単位へ変換する
 *
 * @param pips_value  pips単位の値
 *
 * @return  価格単位の値
 */
double PipsToPrice(const double pips_value)
{
    return(pips_value * __Point * Mult);
}


/**
 * pips単位の値をpoint単位へ変換する
 *
 * @param pips_value  pips単位の値
 *
 * @return  point単位の値
 */
int PipsToPoint(const double pips_value)
{
    return((int)(pips_value * Mult));
}


/**
 * 損益をpoint単位へ変換する
 *
 * @param profit  変換対象の損益
 * @param lots  取引数量
 * @param symbol  通貨ペア
 *
 * @return  pips単位の値
 */
double ProfitToPips(const double profit, const double lots, string symbol = NULL)
{
    if (symbol == NULL) {
        symbol = __Symbol;
    }
    double tick_value = MarketInfo(symbol, MODE_TICKVALUE);
    double point_value = profit / tick_value / lots;

    return(point_value / Mult);
}


/**
 * magicに一致するオープンポジションを決済する
 * 複数存在する場合は全て決済する
 *
 * @param slippage  スリッページpips
 * @param magic  マジックナンバー
 *
 * @return  true: 決済成功, false: 失敗
 *
 * @dependencies PipsToPoint, ErrorDescription
 */
bool Exit(double slippage, const int magic)
{
    color arrow = clrNONE;
    int type;
    int slip = PipsToPoint(slippage);
   
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) == false) {
            return(false);
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        type = OrderType();
        if (type != OP_BUY && type != OP_SELL) {
            continue;
        }
        if (!IsTradeAllowed()) {
            continue;
        }
      
        arrow = (type % 2 == 0) ? clrBlue : clrRed;
        RefreshRates();
      
        bool result = OrderClose(
            OrderTicket(),
            OrderLots(),
            OrderClosePrice(),
            slip,
            arrow);
      
        if (!result) {
            return(false);
        }
      
        int err = GetLastError();
        Print("[OrderCloseError] : ", err, " ", ErrorDescription(err));
        if (err == 129) {
            break;
        }
        Sleep(RETRY_INTERVAL);
    }

    return(true);
}


/**
 * magicに一致するオープンポジションを半分決済する
 * 複数存在する場合は全て半分決済する
 *
 * @param slippage  スリッページpips
 * @param magic  マジックナンバー
 * @param lots  初期ロット数
 *
 * @return  true: 決済成功, false: 失敗
 *
 * @dependencies PipsToPoint
 */
bool ExitHalf(const double slippage, const int magic, const double lots)
{
   double exit_lots = NormalizeDouble(lots / 2, 2);
   int slip = PipsToPoint(slippage);
   
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
         break;
      }
      if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
         continue;
      }
      
      if (OrderLots() == lots) {
         if (OrderClose(OrderTicket(), exit_lots, OrderClosePrice(), slip)) {
            return(true);
         }
      } 
   }
   
   return(false);
}


/**
 * 固定幅のTP/SLにより成り行きで決済する
 * sl_pips, tp_pipsはどちらも0は無効
 *
 * @param magic マジックナンバー
 * @param sl_pips 損切り値幅(pips)
 * @param tp_pips 利食い値幅(pips)
 *
 * @return true: 決済, false: 決済しない
 *
 * @dependecies GetOrderType, GetOrderOpenPrice
 */
bool ExitTpSl(const int magic, const double sl_pips, const double tp_pips)
{
    int type = GetOrderType(magic);
    double open_price = GetOrderOpenPrice(magic);
   
    if (open_price <= 0 || type == -1) {
        return(false);
    }
   
    if (type == OP_BUY) {
        if (tp_pips > 0) {
            if (Bid >= open_price + PipsToPrice(tp_pips)) {
                return(true);
            }
        }
        if (sl_pips > 0) {
            if (Bid <= open_price - PipsToPrice(sl_pips)) {
                return(true);
            }
        }
    } else if (type == OP_SELL) {
        if (tp_pips > 0) {
            if (Ask <= open_price - PipsToPrice(tp_pips)) {
                return(true);
            }
        }
        if (sl_pips > 0) {
            if (Ask >= open_price + PipsToPrice(sl_pips)) {
                return(true);
            }
        }
    }
   
    return(false);
}


/**
 * オープンポジションを変更する
 *
 * @param sl  損切り価格, 0を指定すると現在の価格のまま変更しない
 * @param tp  利食い価格, 0を指定すると現在の価格のまま変更しない
 * @param magic  注文変更ポジションのマジックナンバー
 *
 * @return  true: 成功, false: 失敗
 *
 * @dependencies ErrorDescription
 */
bool Modify(double sl, double tp, const int magic)
{
    int ticket = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) == false) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        int type = OrderType();
        if (type == OP_BUY || type == OP_SELL) {
            ticket = OrderTicket();
            break;
        }
    }
    if (ticket == 0) {
        return(false);
    }
   
    sl = NormalizeDouble(sl, Digits);
    tp = NormalizeDouble(tp, Digits);

    if (sl == 0) {
        sl = OrderStopLoss();
    }
    if (tp == 0) {
        tp = OrderTakeProfit();
    }
    if (OrderStopLoss() == sl && OrderTakeProfit() == tp) {
        return(false);
    }
   
    ulong start_time = GetTickCount();
    while (true) {
        if (GetTickCount() - start_time > RETRY_TIME_LIMIT) {
            Print("OrderModify timeout.");
            return(false);
        }
        if (IsTradeAllowed()) {
            ResetLastError();
            RefreshRates();
        
            if (OrderModify(ticket, 0, sl, tp, 0)) {
                return(true);
            }
         
            int err = GetLastError();
            Print("[OrderModifyError] : ", err, " ", ErrorDescription(err));
            if (err == 1) {
                break;
            }
            if (err == 130) {
                break;
            }
        }
        Sleep(RETRY_INTERVAL);
    }
    return(false);
}


/**
 * magicに一致する待機注文を削除する
 * 複数存在する場合は全て削除する
 *
 * @param magic  マジックナンバー
 *
 * @return  true: 成功, false: 失敗
 */
bool Delete(const int magic)
{
    int type;
    color arrow;
   
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS)) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        type = OrderType();
        if (type == OP_BUYLIMIT || type == OP_SELLLIMIT
            || type == OP_BUYSTOP || type == OP_SELLSTOP) {
            arrow = (type % 2 == 0) ? clrBlue : clrRed;
            if (!OrderDelete(OrderTicket(), arrow)) {
                int err = GetLastError();
                Print("[OrderDeleteError] : ", err, " ", ErrorDescription(err));
                return(false);
            }
        }
    }
   
    return(true);
}


/**
 * lower～upperの値幅内で、baseから上下width pips間隔で指値注文を出す。
 *
 * @param base  基準価格
 * @param lower  発注レンジ下限
 * @param upper  発注レンジ上限
 * @param width  発注間隔pips
 * @param lots  取引数量
 * @param sl  損切りpips
 * @param tp  利食いpips
 * @param magic  マジックナンバー
 *
 * @return  true: 成功, false: 失敗
 *
 * @dependencies PipsToPrice, HasOrderByPrice, EntryWithPips
 */
bool RepeatOrder(
    const double base,
    const double lower,
    const double upper,
    const double width,
    const double lots,
    const double sl,
    const double tp,
    const int    magic)
{
    if (upper < lower || width <= 0) {
        return(false);
    }
   
    double price = base;
    int type;
    string comment = "";
    int code = 0;
   
    while (price > lower) {
        price -= PipsToPrice(width);
    }
    price += PipsToPrice(width);
   
    while (price <= upper) {
        if (price < Ask) {
            type = OP_BUYLIMIT;
            comment = DoubleToString(price, __Digits);
        } else if (price > Bid) {
            type = OP_SELLLIMIT;
            comment = DoubleToString(price * -1, __Digits);
        } else {
            price += PipsToPrice(width);
            continue;
        }
      
        if (!HasOrderByPrice(type, price, magic)) {
            code = EntryWithPips(type, lots, price, 0, sl, tp, comment, magic);
            if (code != 0) {
                return(false);
            }
        }
      
        price += PipsToPrice(width);
        Sleep(RETRY_INTERVAL);
    }
   
    return(true);
}


/**
 * lower～upperの値幅内で、baseから上下width pips間隔で待機注文を出す。
 * 待機注文は指値と逆指値の両方を発注する。
 *
 * @param base  基準価格
 * @param lower  発注レンジ下限
 * @param upper  発注レンジ上限
 * @param width  発注間隔pips
 * @param lots  取引数量
 * @param sl  損切りpips
 * @param tp  利食いpips
 * @param magic  マジックナンバー
 *
 * @return  true: 成功, false: 失敗
 *
 * @dependencies PipsToPrice, HasOrderByPrice, EntryWithPips
 */
bool RepeatOrderHedge(
    const double base,
    const double lower,
    const double upper,
    const double width,
    const double lots,
    const double sl,
    const double tp,
    const int    magic)
{
    if (upper < lower || width <= 0) {
        return(false);
    }
   
    double price = base;
    int type_buy, type_sell;
    string comment_buy, comment_sell;
   
    while (price > lower) {
        price -= PipsToPrice(width);
    }
    price += PipsToPrice(width);
   
    while (price <= upper) {
        if (price < Ask) {
            type_buy = OP_BUYLIMIT;
            type_sell = OP_SELLSTOP;
        } else if (price > Bid) {
            type_buy = OP_BUYSTOP;
            type_sell = OP_SELLLIMIT;
        } else {
            price += PipsToPrice(width);
            continue;
        }
      
        if (!HasOrderByPrice(type_buy, price, magic)) {
            comment_buy = DoubleToString(price, __Digits);
            if (EntryWithPips(type_buy, lots, price, 0, sl, tp, comment_buy, magic) != 0) {
                return(false);
            }
        }
        if (!HasOrderByPrice(type_sell, price, magic)) {
            comment_sell = DoubleToString(price, __Digits);
            if (EntryWithPips(type_sell, lots, price, 0, sl, tp, comment_sell, magic) != 0) {
                return(false);
            }
        }
      
        price += PipsToPrice(width);
        Sleep(RETRY_INTERVAL);
    }
   
    return(true);
}


/**
 * 取引種別type, エントリー価格price, マジックナンバーmagic
 * と一致するポジションが存在するか確認する
 *
 * @param type  取引種別
 * @param price  価格
 * @param magic  マジックナンバー
 *
 * @return  true: ポジション有り, false: ポジション無し
 */
bool HasOrderByPrice(const int type, double price, const int magic)
{
    int order_type;
    string price_str;
    double comment_price;
   
    price = NormalizeDouble(price, __Digits);
    if (type > 0) {
        price_str = DoubleToString(price, __Digits);
    }
    if (type < 0) {
        price_str = DoubleToString(price * -1, __Digits);
    }
   
   
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            return(true);
        }
        if (OrderSymbol() != __Symbol) {
            continue;
        }
        if (OrderMagicNumber() != magic) {
            continue;
        }
      
        order_type = OrderType();
        comment_price = StringToDouble(
            StringSubstr(OrderComment(), 0, StringLen(price_str)));
      
        if (type > 0) {
            if (order_type == OP_BUY ||
                order_type == OP_BUYLIMIT ||
                order_type == OP_BUYSTOP) {
                if (comment_price == price) {
                    return(true);
                }
            }
        }
        if (type < 0) {
            if (order_type == OP_SELL ||
                order_type == OP_SELLLIMIT ||
                order_type == OP_SELLSTOP) {
                if (comment_price == price * -1) {
                    return(true);
                }
            }
        }
    }
   
    return(false);
}


/**
 * 取引数量の複利計算
 * 計算が不可能な場合は0を返す
 *
 * @param risk  損切りの損失, 口座残高に対する割合(%)
 * @param sl_pips  損切り(pips)
 *
 * @return  取引数量
 *
 * @dependencies PipsToPoint
 */
double MoneyManagement(const double risk, const double sl_pips)
{
    if (risk <= 0 || sl_pips <= 0) {
        return(0);
    }
   
    double lots = AccountBalance() * (risk / 100);
    double tickvalue = MarketInfo(__Symbol, MODE_TICKVALUE);

    if (tickvalue == 0) {
        return(0);
    }
   
    lots = lots / (tickvalue * PipsToPoint(sl_pips));
   
    return(lots);
}


/**
 * トレーリングストップを実行する
 *
 * @param value  トレーリング幅(pips)
 * @param magic  マジックナンバー
 *
 * @dependencies PipsToPrice, Modify
 */
void TrailingStop(const double value, const int magic)
{
    double new_sl;
   
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
            return;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        if (OrderType() == OP_BUY) {
            new_sl = Bid - PipsToPrice(value);
            if (new_sl >= OrderOpenPrice() && new_sl > OrderStopLoss()) {
                Modify(new_sl, 0, magic);
                break;
            }
        }
        if (OrderType() == OP_SELL) {
            new_sl = Ask + PipsToPrice(value);
            if (new_sl <= OrderOpenPrice() && 
                (new_sl < OrderStopLoss() || OrderStopLoss() == 0)) {
                Modify(new_sl, 0, magic);
                break;
            }
        }
    }
}


/**
 * 建値決済機能
 * value pipsだけ利益が出たポジションの決済SLをエントリー価格に設定する
 *
 * @param value  利益(pips)
 * @param magic  マジックナンバー
 * @param pips  新しいSLの建値からの距離(pips)
 *
 * @dependencies PipsToPrice, Modify
 */
void BreakEven(const double value, const int magic, const double pips = 0)
{
    double new_sl;
    
    if (value <= pips) {
        return;
    }
   
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
            return;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        if (OrderType() == OP_BUY) {
            new_sl = OrderOpenPrice() + PipsToPrice(pips);
            if (Bid - PipsToPrice(value) >= OrderOpenPrice() && new_sl > OrderStopLoss()) {
                Modify(new_sl, 0, magic);
                break;
            }
        }
        if (OrderType() == OP_SELL) {
            new_sl = OrderOpenPrice() - PipsToPrice(pips);
            if (Ask + PipsToPrice(value) <= OrderOpenPrice() &&
                (new_sl < OrderStopLoss() || OrderStopLoss() == 0)) {
                Modify(new_sl, 0, magic);
                break;
            }
        }
    }
}


/**
 * トレードプールから最新のポジション情報を1件選択する
 *
 * @param magic  マジックナンバー
 *
 * @return  true: 選択成功, false: 失敗
 */
bool GetOrder(const int magic)
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
        return(true);
    }
    return(false);
}


/**
 * ヒストリープールから最新のポジション情報を1件選択する
 *
 * @param magic  マジックナンバー
 *
 * @return  true: 選択成功, false: 失敗
 */
bool GetOrderByHistory(const int magic)
{
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
        return(true);
    }
    return(false);
}


/**
 * magicで指定したポジションのエントリー価格を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  エントリー価格
 *
 * @dependencies GetOrder
 */
double GetOrderOpenPrice(const int magic)
{
    double value = (GetOrder(magic)) ? OrderOpenPrice() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのエントリー価格をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  エントリー価格
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderOpenPriceByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderOpenPrice() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのエントリー時刻を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  エントリー時刻
 *
 * @dependencies GetOrder
 */
datetime GetOrderOpenTime(const int magic)
{
    datetime value = (GetOrder(magic)) ? OrderOpenTime() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのエントリー時刻をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  エントリー時刻
 *
 * @dependencies GetOrderByHistory
 */
datetime GetOrderOpenTimeByHistory(const int magic)
{
    datetime value = (GetOrderByHistory(magic)) ? OrderOpenTime() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの取引種別を返す
 * 取得できなかった場合は-1を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  取引種別
 *
 * @dependencies GetOrder
 */
int GetOrderType(const int magic)
{
    int value = (GetOrder(magic)) ? OrderType() : -1;
      
    return(value);
}


/**
 * magicで指定したポジションの取引種別をヒストリープールから取得して返す
 * 取得できなかった場合は-1を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  取引種別
 *
 * @dependencies GetOrderByHistory
 */
int GetOrderTypeByHistory(const int magic)
{
    int value = (GetOrderByHistory(magic)) ? OrderType() : -1;
      
    return(value);
}


/**
 * magicで指定したポジションの取引数量を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  取引数量
 *
 * @dependencies GetOrder
 */
double GetOrderLots(const int magic)
{
    double value = (GetOrder(magic)) ? OrderLots() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの取引数量をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  取引数量
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderLotsByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderLots() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのTPを返す
 *
 * @param magic  マジックナンバー
 *
 * @return  TP
 *
 * @dependencies GetOrder
 */
double GetOrderTakeProfit(const int magic)
{
    double value = (GetOrder(magic)) ? OrderTakeProfit() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのTPをヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  TP
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderTakeProfitByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderTakeProfit() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのSLを返す
 *
 * @param magic  マジックナンバー
 *
 * @return  SL
 *
 * @dependencies GetOrder
 */
double GetOrderStopLoss(const int magic)
{
    double value = (GetOrder(magic)) ? OrderStopLoss() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのSLをヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  SL
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderStopLossByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderStopLoss() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの有効期限を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  有効期限
 *
 * @dependencies GetOrder
 */
datetime GetOrderExpiration(const int magic)
{
    datetime value = (GetOrder(magic)) ? OrderExpiration() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの有効期限をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  有効期限
 *
 * @dependencies GetOrderByHistory
 */
datetime GetOrderExpirationByHistory(const int magic)
{
    datetime value = (GetOrderByHistory(magic)) ? OrderExpiration() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのコメントを返す
 *
 * @param magic  マジックナンバー
 *
 * @return  コメント
 *
 * @dependencies GetOrder
 */
string GetOrderComment(const int magic)
{
    string value = (GetOrder(magic)) ? OrderComment() : "";
      
    return(value);
}


/**
 * magicで指定したポジションのコメントをヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  コメント
 *
 * @dependencies GetOrderByHistory
 */
string GetOrderCommentByHisotry(const int magic)
{
    string value = (GetOrderByHistory(magic)) ? OrderComment() : "";
      
    return(value);
}


/**
 * magicで指定したポジションの損益を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  損益
 *
 * @dependencies GetOrder
 */
double GetOrderProfit(const int magic)
{
    double value = (GetOrder(magic)) ? OrderProfit() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの損益をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  損益
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderProfitByHisotry(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderProfit() : 0;
      
    return(value);
}


/**
 * magicに一致する全ポジションの合計損益を取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  合計損益
 */
double GetOrderProfitTotal(const int magic)
{
    double profit = 0;
   
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
            break;
        }
        if (OrderSymbol() != __Symbol || OrderMagicNumber() != magic) {
            continue;
        }
      
        profit += OrderProfit();
    }
   
    return(profit);
}


/**
 * magicで指定したポジションのスワップを返す
 *
 * @param magic  マジックナンバー
 *
 * @return  スワップ
 *
 * @dependencies GetOrder
 */
double GetOrderSwap(const int magic)
{
    double value = (GetOrder(magic)) ? OrderSwap() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションのスワップをヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  スワップ
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderSwapByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderSwap() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの手数料を返す
 *
 * @param magic  マジックナンバー
 *
 * @return  手数料
 *
 * @dependencies GetOrder
 */
double GetOrderCommission(const int magic)
{
    double value = (GetOrder(magic)) ? OrderCommission() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの手数料をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  手数料
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderCommissionByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderCommission() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの決済価格をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  決済価格
 *
 * @dependencies GetOrderByHistory
 */
double GetOrderClosePriceByHistory(const int magic)
{
    double value = (GetOrderByHistory(magic)) ? OrderClosePrice() : 0;
      
    return(value);
}


/**
 * magicで指定したポジションの決済時刻をヒストリープールから取得して返す
 *
 * @param magic  マジックナンバー
 *
 * @return  決済時刻
 *
 * @dependencies GetOrderByHistory
 */
datetime GetOrderCloseTimeByHistory(const int magic)
{
    datetime value = (GetOrderByHistory(magic)) ? OrderCloseTime() : 0;
      
    return(value);
}


/**
 *  取引可能曜日フィルター
 * 
 * @param arr  曜日ごとのフィルターON/OFFの配列 true:取引する, false:しない
 *
 * @return  true: 取引可能, false: 取引不可能
 */
bool DayOfWeekFilter(bool &arr[])
{
    if (ArraySize(arr) != 7) {
        return(false);
    }

    return(arr[DayOfWeek()]); 
}


/**
 * スプレッドフィルター
 * 現在のスプレッドがspreadよりも大きければ取引しない
 * 
 * @param spread  スプレッドの最大許容値
 *
 * @return  true: 取引可能, false: 取引不可能
 */
bool SpreadFilter(const int spread)
{
    return(MarketInfo(__Symbol, MODE_SPREAD) <= spread);
}


/**
 * 指定時刻での決済判定
 * exit_timeからinterval(秒)の間は決済と判定する
 *
 * @param exit_time  決済時刻
 * @param interval  決済時刻からの猶予時間
 *
 * @return  true: 決済
 */
bool ExitByTime(const datetime exit_time, const uint interval = 300)
{
    return(TimeCurrent() >= exit_time &&
        TimeCurrent() <= exit_time + interval);
}


/**
 * string型の時間をdatetime型に直す
 *
 * @param value  時刻の文字列, 例: 1:23
 *
 * @return 今日の日付（サーバー時刻）でdatetime型に変換したvalueの時刻
 */
datetime StringToTimeWithServerDate(const string value)
{
    return(StringToTime((string)Year() + "."
        + (string)Month() + "."
        + (string)Day() + " " + value));
}


/**
 * int型の時間をdatetime型に直す
 *
 * @param value  時刻
 *
 * @return 今日の日付（サーバー時刻）でdatetime型に変換したvalueの時刻
 */
datetime HourToTimeWithServerDate(const int value)
{
    return(StringToTime((string)Year() + "."
        + (string)Month() + "."
        + (string)Day()+ " "
        + IntegerToString(value) + ":00"));
}


/**
 * string型の日本時間をサーバー時間のdatetime型に直す
 *
 * @param value  時刻の文字列, 例: 1:23
 *
 * @return サーバー時刻に変換した時刻
 *
 * @dependencies StringToTimeWithServerDate
 */
datetime StringWithJpnTimeToTime(const string value)
{
    datetime jpn = StringToTimeWithServerDate(value);
    datetime server = jpn - (9 - GMTShift) * 3600;
   
    return(server);
}


/**
 * 現在のサーバー時刻から日本時間を求めて返す
 *
 * @return 日本時間
 */
datetime TimeJpn()
{
    return(TimeCurrent() + (9 - GMTShift) * 3600);
}


/**
 * 現在のサーバー時刻から日本時間を求め、
 * 参照渡しされたMqlDateTime型のパラメーターに代入する
 *
 * @param gmt_shift サーバー時刻とGMTの時差（日本の時差は+9）
 * @param time 結果を受け取る構造体
 */
void TimeJpn(MqlDateTime &time)
{
    TimeToStruct(TimeJpn(), time);
}


/**
 * 取引時間帯を制限する
 *
 * @param start_time  取引時間の開始時刻
 * @param end_time  取引時間の終了時刻
 *
 * @return  true: 取引可能時刻, false: 取引不能時刻
 */
bool TradeTimeZoneFilter(const datetime start_time, const datetime end_time)
{
    if (start_time < end_time) {
        return(TimeCurrent() >= start_time && TimeCurrent() < end_time);
    }
   
    return(TimeCurrent() < end_time || TimeCurrent() >= start_time);
}


/**
 * 取引時間帯を制限する
 *
 * @param start_time  取引時間の開始時刻
 * @param end_time  取引時間の終了時刻
 *
 * @return  true: 取引可能時刻, false: 取引不能時刻
 *
 * @dependencies StringToTimeWithServerDate, TradeTimeZoneFilter
 */
bool TradeTimeZoneFilterByString(
    const string start_time,
    const string end_time)
{
    return(TradeTimeZoneFilter(
        StringToTimeWithServerDate(start_time),
        StringToTimeWithServerDate(end_time)));
}


/**
 * 週末の取引を制限する
 *
 * @param exit_day_of_week 決済曜日
 * @param exit_hour 決済時
 * @param exit_min 決済分
 *
 * @return  true: 取引可能, false: 取引不能
 */
bool WeekendFilter(
    const int exit_day_of_week = 5,
    const int exit_hour = 23,
    const int exit_min = 50)
{
    MqlDateTime now;
    TimeCurrent(now);
    
    if (now.day_of_week == exit_day_of_week) {
        if (now.hour > exit_hour) {
            return(false);
        } else if (now.hour == exit_hour && now.min == exit_min) {
            return(false);
        }
    } else if (now.day_of_week > exit_day_of_week) {
        return(false);
    }
    
    return(true);
}


/**
 * 週末の取引を制限する
 * パラメーターは日本時間で指定
 *
 * @param exit_day_of_week 決済曜日
 * @param exit_hour 決済時
 * @param exit_min 決済分
 *
 * @return  true: 取引可能, false: 取引不能
 */
bool WeekendFilterJpn(
    const int exit_day_of_week = 5,
    const int exit_hour = 23,
    const int exit_min = 50)
{
    MqlDateTime now;
    TimeJpn(now);
    
    if (now.day_of_week == exit_day_of_week) {
        if (now.hour > exit_hour) {
            return(false);
        } else if (now.hour == exit_hour && now.min >= exit_min) {
            return(false);
        }
    } else if (now.day_of_week > exit_day_of_week) {
        return(false);
    }
    
    return(true);
}


/**
 * 週初めの取引を制限する
 *
 * @param start_day_of_week 開始曜日
 * @param start_hour 開始時
 * @param start_min 開始分
 *
 * @return  true: 取引可能, false: 取引不能
 */
bool WeekStartFilter(
    const int start_day_of_week = 1,
    const int start_hour = 9,
    const int start_min = 00)
{
    MqlDateTime now;
    TimeCurrent(now);
    
    if (now.day_of_week == start_day_of_week) {
        if (now.hour < start_hour) {
            return(false);
        } else if (now.hour == start_hour && now.min < start_min) {
            return(false);
        }
    } else if (now.day_of_week < start_day_of_week) {
        return(false);
    }
    
    return(true);
}


/**
 * パーフェクトオーダーに一致しているか判定しいる
 * MAは全てSMA, 終値で計算している
 * periodsは最低でも2以上の大きさの配列であること
 *
 * @param type  OP_BUY: 昇順 , OP_SELL: 降順
 * @param periods[]  パーフェクトオーダーに使用するMAの期間をまとめた配列
 * @param shift  計算位置, 初期値は1
 *
 * @return  true:パーフェクトオーダーに一致 , false: 不一致
 */
bool PerfectOrderFilter(const int type, int &periods[], const int shift = 1)
{
    double ma[];
    int size = ArraySize(periods);
   
    if (size < 2) {
        return(false);
    }
   
    ArrayResize(ma, size);
    ArraySort(periods, WHOLE_ARRAY, 0, MODE_ASCEND);
   
    for (int i = 0; i < size; i++) {
        ma[i] = iMA(__Symbol, 0, periods[i], 0, MODE_SMA, PRICE_CLOSE, shift);
      
        if (i == 0) {
            continue;
        }
      
        if (type == OP_BUY) {
            if (ma[i] <= ma[i - 1]) {
                return(false);
            }
        } else if (type == OP_SELL) {
            if (ma[i] >= ma[i - 1]) {
                return(false);
            }
        } else {
            return(false);
        }
    }
   
    return(true);
}


/**
 * 2種類の値のクロスにより取引する
 * value1がvalue2を超えると買い
 * value1がvalue2を下回ると売り
 *
 * @param value1[2]  値の配列1
 * @param value2[2]  値の配列2
 *
 * @return  0:取引なし, 1:買い, -1:売り
 */
int GetCrossSignal(double &value1[2], double &value2[2])
{
    if (value1[0] > value2[0] && value1[1] <= value2[1]) {
        return(1);
    }
    if (value1[0] < value2[0] && value1[1] >= value2[1]) {
        return(-1);
    }
    return(0);
}


/**
 * 短期MAと長期MAのクロスで取引する
 *
 * @param small_period  短期MAの期間
 * @param long_period  長期MAの期間
 * @param shift  計算位置
 *
 * @return  0:取引なし, 1:買い, -1:売り
 *
 * @dependencies getCrossSignal
 */
int GetMACrossSignal(
    const int small_period,
    const int long_period,
    const int shift = 1)
{
    double small_ma[2], long_ma[2];
   
    small_ma[0] = iMA(__Symbol, 0, small_period, 0, MODE_SMA, PRICE_CLOSE, shift);
    small_ma[1] = iMA(__Symbol, 0, small_period, 0, MODE_SMA, PRICE_CLOSE, shift + 1);
    long_ma[0]  = iMA(__Symbol, 0, long_period,  0, MODE_SMA, PRICE_CLOSE, shift);
    long_ma[1]  = iMA(__Symbol, 0, long_period,  0, MODE_SMA, PRICE_CLOSE, shift + 1);

    return(GetCrossSignal(small_ma, long_ma));
}


/**
 * MACDとMACDのシグナルのクロスで取引する
 *
 * @param fast_ema_period  短期EMAの期間
 * @param slow_ema_period  長期EMAの期間
 * @param signal_period  シグナルの期間
 * @param shift  計算位置
 *
 * @return  0:取引なし, 1:買い, -1:売り
 *
 * @dependencies getCrossSignal
 */
int GetMACDSignal(
    const int fast,
    const int slow,
    const int signal_period,
    const int shift = 1)
{
    double macd[2], signal[2];
   
    macd[0]   = iMACD(__Symbol, 0, fast, slow, signal_period, PRICE_CLOSE, MODE_MAIN,   shift);
    macd[1]   = iMACD(__Symbol, 0, fast, slow, signal_period, PRICE_CLOSE, MODE_MAIN,   shift + 1);
    signal[0] = iMACD(__Symbol, 0, fast, slow, signal_period, PRICE_CLOSE, MODE_SIGNAL, shift);
    signal[1] = iMACD(__Symbol, 0, fast, slow, signal_period, PRICE_CLOSE, MODE_SIGNAL, shift + 1);

    return(GetCrossSignal(macd, signal));
}


/**
 * 1日のローソク足の本数
 *
 * @return 現在のチャートの時間足が、24時間に何本出現するか
 */
int GetBarsInDay()
{
    int period = _Period;
   
    if (period <= 0 || period > 1440) {
        return(0);
    }
   
    return(1440 / period);
}


/**
 * timeで指定された時刻が何本前のローソクかを算出する
 *
 * @param time 時間
 *
 * @return 指定された時間が何本前のローソク足か
 */
int TimeToShift(const datetime time)
{
    for (int i = 0; i < Bars; i++) {
        if (Time[i] <= time) {
            return(i);
        }
    }
    return(0);
}


/**
 * 時間足を文字列として返す
 *
 * @param period  時間足, 0は現在の時間足
 *
 * @return  時間足の日本語表示
 */
string PeriodToString(int period)
{
    if (period == 0) {
        period = _Period;
    }
   
    switch (period) {
        case PERIOD_M1:
            return("1分足 (M1)");
        case PERIOD_M5:
            return("5分足 (M5)");
        case PERIOD_M15:
            return("15分足 (M15)");
        case PERIOD_M30:
            return("30分足 (M30)");
        case PERIOD_H1: 
            return("1時間足 (H1)");
        case PERIOD_H4:
            return("4時間足 (H4)");
        case PERIOD_D1:
            return("日足 (D1)");
        case PERIOD_W1:
            return("週足 (W1)");
        case PERIOD_MN1:
            return("月足 (MN1)");
        default:
            return("");
    }
}


/**
 * 通貨ペア名の後ろに付いている文字を取得する
 *
 * @return 通貨ペア名の後ろに付いている文字
 */
string GetSymbolEndingOfWord()
{
    return(StringSubstr(__Symbol, 6, StringLen(__Symbol) - 6));
}


/**
 * マーチンゲールによるロット数を計算する
 *
 * @param base_lots 基本ロット数
 * @param lots_mult 連敗毎のロット倍率
 * @param magic マジックナンバー
 * @param max_lots 最大ロット数, 0は上限なし
 *
 * @return 取引数量
 */
double Martingale(
    const double base_lots,
    const double lots_mult,
    const int magic,
    const int max_lots = 0)
{
    int lose = 0;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == __Symbol && OrderMagicNumber() == magic) {
                if (OrderProfit() < 0) {
                    lose++;
                } else {
                    break;
                }
            }
        }
    }
    
    double lots = base_lots * MathPow(lots_mult, lose);
    
    if (max_lots > 0) {
        if (lots > max_lots) {
            return(max_lots);
        }
    }

    return(lots);
}


/**
 * エラー内容を取得する
 *
 * @param error_code  エラーコード
 *
 * @return  エラー内容を表す文字列
 */
string ErrorDescription(int error_code)
{
    string error_string;

    switch (error_code) {
        case 0:
        case 1:   error_string = "no error";                                                  break;
        case 2:   error_string = "common error";                                              break;
        case 3:   error_string = "invalid trade parameters";                                  break;
        case 4:   error_string = "trade server is busy";                                      break;
        case 5:   error_string = "old version of the client terminal";                        break;
        case 6:   error_string = "no connection with trade server";                           break;
        case 7:   error_string = "not enough rights";                                         break;
        case 8:   error_string = "too frequent requests";                                     break;
        case 9:   error_string = "malfunctional trade operation (never returned error)";      break;
        case 64:  error_string = "account disabled";                                          break;
        case 65:  error_string = "invalid account";                                           break;
        case 128: error_string = "trade timeout";                                             break;
        case 129: error_string = "invalid price";                                             break;
        case 130: error_string = "invalid stops";                                             break;
        case 131: error_string = "invalid trade volume";                                      break;
        case 132: error_string = "market is closed";                                          break;
        case 133: error_string = "trade is disabled";                                         break;
        case 134: error_string = "not enough money";                                          break;
        case 135: error_string = "price changed";                                             break;
        case 136: error_string = "off quotes";                                                break;
        case 137: error_string = "broker is busy (never returned error)";                     break;
        case 138: error_string = "requote";                                                   break;
        case 139: error_string = "order is locked";                                           break;
        case 140: error_string = "long positions only allowed";                               break;
        case 141: error_string = "too many requests";                                         break;
        case 145: error_string = "modification denied because order too close to market";     break;
        case 146: error_string = "trade context is busy";                                     break;
        case 147: error_string = "expirations are denied by broker";                          break;
        case 148: error_string = "amount of open and pending orders has reached the limit";   break;
        case 149: error_string = "hedging is prohibited";                                     break;
        case 150: error_string = "prohibited by FIFO rules";                                  break;
      
        //---- mql4 errors
        case 4000: error_string = "no error (never generated code)";                          break;
        case 4001: error_string = "wrong function pointer";                                   break;
        case 4002: error_string = "array index is out of range";                              break;
        case 4003: error_string = "no memory for function call stack";                        break;
        case 4004: error_string = "recursive stack overflow";                                 break;
        case 4005: error_string = "not enough stack for parameter";                           break;
        case 4006: error_string = "no memory for parameter string";                           break;
        case 4007: error_string = "no memory for temp string";                                break;
        case 4008: error_string = "not initialized string";                                   break;
        case 4009: error_string = "not initialized string in array";                          break;
        case 4010: error_string = "no memory for array\' string";                             break;
        case 4011: error_string = "too long string";                                          break;
        case 4012: error_string = "remainder from zero divide";                               break;
        case 4013: error_string = "zero divide";                                              break;
        case 4014: error_string = "unknown command";                                          break;
        case 4015: error_string = "wrong jump (never generated error)";                       break;
        case 4016: error_string = "not initialized array";                                    break;
        case 4017: error_string = "dll calls are not allowed";                                break;
        case 4018: error_string = "cannot load library";                                      break;
        case 4019: error_string = "cannot call function";                                     break;
        case 4020: error_string = "expert function calls are not allowed";                    break;
        case 4021: error_string = "not enough memory for temp string returned from function"; break;
        case 4022: error_string = "system is busy (never generated error)";                   break;
        case 4050: error_string = "invalid function parameters count";                        break;
        case 4051: error_string = "invalid function parameter value";                         break;
        case 4052: error_string = "string function internal error";                           break;
        case 4053: error_string = "some array error";                                         break;
        case 4054: error_string = "incorrect series array using";                             break;
        case 4055: error_string = "custom indicator error";                                   break;
        case 4056: error_string = "arrays are incompatible";                                  break;
        case 4057: error_string = "global variables processing error";                        break;
        case 4058: error_string = "global variable not found";                                break;
        case 4059: error_string = "function is not allowed in testing mode";                  break;
        case 4060: error_string = "function is not confirmed";                                break;
        case 4061: error_string = "send mail error";                                          break;
        case 4062: error_string = "string parameter expected";                                break;
        case 4063: error_string = "integer parameter expected";                               break;
        case 4064: error_string = "double parameter expected";                                break;
        case 4065: error_string = "array as parameter expected";                              break;
        case 4066: error_string = "requested history data in update state";                   break;
        case 4099: error_string = "end of file";                                              break;
        case 4100: error_string = "some file error";                                          break;
        case 4101: error_string = "wrong file name";                                          break;
        case 4102: error_string = "too many opened files";                                    break;
        case 4103: error_string = "cannot open file";                                         break;
        case 4104: error_string = "incompatible access to a file";                            break;
        case 4105: error_string = "no order selected";                                        break;
        case 4106: error_string = "unknown symbol";                                           break;
        case 4107: error_string = "invalid price parameter for trade function";               break;
        case 4108: error_string = "invalid ticket";                                           break;
        case 4109: error_string = "trade is not allowed in the expert properties";            break;
        case 4110: error_string = "longs are not allowed in the expert properties";           break;
        case 4111: error_string = "shorts are not allowed in the expert properties";          break;
        case 4200: error_string = "object is already exist";                                  break;
        case 4201: error_string = "unknown object property";                                  break;
        case 4202: error_string = "object is not exist";                                      break;
        case 4203: error_string = "unknown object type";                                      break;
        case 4204: error_string = "no object name";                                           break;
        case 4205: error_string = "object coordinates error";                                 break;
        case 4206: error_string = "no specified subwindow";                                   break;
      
        //--- original
        case 7001: error_string = "trade timeout";                                            break;
        case 7002: error_string = "trade is not allow";                                       break;
        default:   error_string = "unknown error";
    }

    return(error_string);
}
