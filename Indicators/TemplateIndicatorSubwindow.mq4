#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1


double Value[];


int OnInit()
{
    SetIndexStyle(0, DRAW_LINE);
    SetIndexBuffer(0, Value);

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
    int limit = Bars - IndicatorCounted() - 1;
    int min_bars = 20;

    for (int i = limit; i >= 0; i--) {
        if (i > Bars - min_bars) {
            continue;
        }
      
        Value[i] = iMA(_Symbol, _Period, 20, 0, MODE_SMA, PRICE_CLOSE, i);
    }

    return(rates_total);
}


void OnDeinit(const int reason)
{
    Comment("");
}
