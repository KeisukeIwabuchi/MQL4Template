#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1


double UpArrow[];
double DownArrow[];


bool IsAlert = false;
bool IsMail = false;
int InfoBar = 0;


int OnInit()
{
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexBuffer(0, UpArrow);
    SetIndexArrow(0, 233);
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexBuffer(1, DownArrow);
    SetIndexArrow(1, 234);
   
    return(INIT_SUCCEEDED);
}


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    double sma[2], lma[2];

    int limit = Bars - IndicatorCounted() - 1;
    int min_bars = 20;

    for (int i = limit; i >= 0; i--) {
        if (i > Bars - min_bars) {
            continue;
        }
      
        // 計算に必要なテクニカル指標の値を取得
        sma[0] = iMA(_Symbol, _Period, 10, 0, MODE_SMA, PRICE_CLOSE, i);
        sma[1] = iMA(_Symbol, _Period, 10, 0, MODE_SMA, PRICE_CLOSE, i + 1);
        lma[0] = iMA(_Symbol, _Period, 20, 0, MODE_SMA, PRICE_CLOSE, i);
        lma[1] = iMA(_Symbol, _Period, 20, 0, MODE_SMA, PRICE_CLOSE, i + 1);
      
        // 上矢印
        if (sma[0] > lma[0] && sma[1] <= lma[1]) {
            UpArrow[i] = low[i] - 5 * _Point;
         
            if (i == 0 && InfoBar != Bars) {
                if (IsAlert) {
                    Alert(MQLInfoString(MQL_PROGRAM_NAME) + 
                        " Up " + _Symbol + " " + PeriodToString(_Period));
                }
                if (IsMail) {
                    SendMail(
                        MQLInfoString(MQL_PROGRAM_NAME),
                        "Up " + _Symbol + " " + PeriodToString(_Period)
                    );
                }
            }
            InfoBar = Bars;
        }
      
        // 下矢印
        if (sma[0] < lma[0] && sma[1] >= lma[1]) {
            DownArrow[i] = high[i] + 5 * _Point;
         
            if (i == 0 && InfoBar != Bars) {
                if (IsAlert) {
                    Alert(MQLInfoString(MQL_PROGRAM_NAME) + 
                        " Down " + _Symbol + " " + PeriodToString(_Period));
                }
                if (IsMail) {
                    SendMail(
                        MQLInfoString(MQL_PROGRAM_NAME),
                        "Down " + _Symbol + " " + PeriodToString(_Period)
                    );
                }
            }
            InfoBar = Bars;
        }
    }

    return(rates_total);
}


void OnDeinit(const int reason)
{
    Comment("");
}


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
