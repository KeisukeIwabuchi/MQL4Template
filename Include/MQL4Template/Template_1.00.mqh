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


/**
 * 保有中ポジションの取引数量を取得する
 */
double getOrderLots(int type, int magic)
{
   double lots = 0.0;

   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS) == false) {
         break;
      }
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) {
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
 */
int getOrderCount(int type, int magic)
{
   int count = 0;

   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS) == false) {
         break;
      }
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) {
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
 */
bool Entry(int type, double lots, double price, int slip, double sl, double tp, string comment, int magic)
{
   color arrow = (type % 2 == 0) ? clrBlue : clrRed;
   price = NormalizeDouble(price, Digits);
   sl = NormalizeDouble(sl, Digits);
   tp = NormalizeDouble(tp, Digits);
 
   uint starttime = GetTickCount();
   while(true) {
      if (GetTickCount() - starttime > 5 * 1000) {
         Print("OrderSend timeout.");
         return(false);
      }
      if (IsTradeAllowed() == true) {
         RefreshRates();
         if (OrderSend(Symbol(), type, lots, price, slip, sl, tp, comment, magic, 0, arrow) != -1) {
            return(true);
         }
         int err = GetLastError();
         Print("[OrderSendError] : ", err, " ", ErrorDescription(err));

         if (err == 129) {
            break;
         }
         if (err == 130) {
            break;
         }
      }
      Sleep(100);
   }
   return(false);
}


/**
 * 発注処理を実行する
 * TP/SLはpips単位で指定可能
 */
bool EntrySL(int type, double lots, double price, double slip, double slpips, double tppips, string comment, int magic)
{
   int m = (Digits == 3 || Digits == 5) ? 10 : 1;
   slip *= m;

   if (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) {
      m *= -1;
   }
   
   double sl = 0;
   double tp = 0;
   if (slpips > 0) {
      sl = price - slpips * Point * m;
   }
   if(tppips > 0) {
      tp = price + tppips * Point * m;
   }
   return(Entry(type, lots, price, (int)slip, sl, tp, comment, magic));
}


/**
 * オープンポジションを決済する
 */
bool Exit(double slippage, int magic)
{
   color arrow = clrNONE;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS) == false) {
         return(false);
      }
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) {
         continue;
      }
      
      int type = OrderType();
      if (type == OP_BUY || type == OP_SELL) {
         
         
         if (IsTradeAllowed() == true) {
            arrow = (type % 2 == 0) ? clrBlue : clrRed;
            RefreshRates();
            if (OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), (int)slippage, arrow) == false) {
               return(false);
            }
            int err = GetLastError();
            Print("[OrderCloseError] : ", err, " ", ErrorDescription(err));
            if (err == 129) {
               break;
            }
         }
         Sleep(100);
      }
   }

   return(true);
}


/**
 * オープンポジションを変更する
 */
bool Modify(double sl, double tp, int magic)
{
   int ticket = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS) == false) {
         break;
      }
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) {
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
   
   ulong starttime = GetTickCount();
   while (true) {
      if (GetTickCount() - starttime > 5 * 1000) {
         Alert("OrderModify timeout. Check the experts log.");
         return(false);
      }
      if (IsTradeAllowed() == true) {
         if (OrderModify(ticket, 0, sl, tp, 0) == true) {
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
      Sleep(100);
   }
   return(false);
}


/**
 * 待機注文を削除する
 */
bool Delete(int magic)
{
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS) == false) {
         break;
      }
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) {
         continue;
      }
      int type = OrderType();
      if (type == OP_BUYLIMIT || type == OP_SELLLIMIT || type == OP_BUYSTOP || type == OP_SELLSTOP) {
         if (OrderDelete(OrderTicket()) == false) {
            return(false);
         }
      }
   }
   
   return(true);
}


/**
 *  取引可能曜日フィルター
 * 
 * @param arr  曜日ごとのフィルターON/OFFの配列 true:取引する, false:しない
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
 * 指定時刻での決済判定
 */
bool ExitByTime(datetime exit_time, uint interval = 300)
{
   return(TimeCurrent() >= exit_time && TimeCurrent() <= exit_time + interval);
}


/**
 * string型の時間をdatetime型に直す
 */
datetime StringToTimeWithServerDate(string value)
{
   return(StringToTime((string)Year() + "." + (string)Month() + "." + (string)Day() + " " + value));
}


/**
 * 取引時間帯を制限する
 */
bool TradeTimeZoneFilter(datetime start_time, datetime end_time)
{
   if (start_time < end_time) {
      return(TimeCurrent() >= start_time && TimeCurrent() < end_time);
   }
   
   return(TimeCurrent() < end_time || TimeCurrent() >= start_time);
}


/**
 * 1日のローソク足の本数
 */
int getBarsInDay()
{
   int period = Period();
   
   if (period <= 0 || period > 1440) {
      return(0);
   }
   
   return(1440 / period);
}



/**
 * エラー内容を取得する
 */
string ErrorDescription(int error_code)
{
   string error_string;

   switch (error_code) {
      case 0:
      case 1:   error_string="no error";                                                  break;
      case 2:   error_string="common error";                                              break;
      case 3:   error_string="invalid trade parameters";                                  break;
      case 4:   error_string="trade server is busy";                                      break;
      case 5:   error_string="old version of the client terminal";                        break;
      case 6:   error_string="no connection with trade server";                           break;
      case 7:   error_string="not enough rights";                                         break;
      case 8:   error_string="too frequent requests";                                     break;
      case 9:   error_string="malfunctional trade operation (never returned error)";      break;
      case 64:  error_string="account disabled";                                          break;
      case 65:  error_string="invalid account";                                           break;
      case 128: error_string="trade timeout";                                             break;
      case 129: error_string="invalid price";                                             break;
      case 130: error_string="invalid stops";                                             break;
      case 131: error_string="invalid trade volume";                                      break;
      case 132: error_string="market is closed";                                          break;
      case 133: error_string="trade is disabled";                                         break;
      case 134: error_string="not enough money";                                          break;
      case 135: error_string="price changed";                                             break;
      case 136: error_string="off quotes";                                                break;
      case 137: error_string="broker is busy (never returned error)";                     break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      case 147: error_string="expirations are denied by broker";                          break;
      case 148: error_string="amount of open and pending orders has reached the limit";   break;
      case 149: error_string="hedging is prohibited";                                     break;
      case 150: error_string="prohibited by FIFO rules";                                  break;
      //---- mql4 errors
      case 4000: error_string="no error (never generated code)";                          break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid ticket";                                           break;
      case 4109: error_string="trade is not allowed in the expert properties";            break;
      case 4110: error_string="longs are not allowed in the expert properties";           break;
      case 4111: error_string="shorts are not allowed in the expert properties";          break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
   }

   return(error_string);
}
