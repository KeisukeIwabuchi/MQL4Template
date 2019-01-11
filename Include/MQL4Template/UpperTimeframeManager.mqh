//+------------------------------------------------------------------+
//|                                         UpperTimeframeManger.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Keisuke Iwabuchi"
#property strict


class UpperTimeframeManger
{
    private:
        bool status;
        ENUM_TIMEFRAMES tf;
        int day;
        int last_shift;

    public:
        UpperTimeframeManger(const ENUM_TIMEFRAMES timeframe);
        bool GetStatus(void);
        bool SetTimeframe(const ENUM_TIMEFRAMES timeframe);
        int ShiftToUpperTFShift(const int shift);
        
    private:
        int GetUpperTFShift(const int shift);
};


UpperTimeframeManger::UpperTimeframeManger(const ENUM_TIMEFRAMES timeframe)
{
    this.status = (timeframe > Period());
    this.tf = timeframe;
    this.day = 0;
    this.last_shift = 0;
}


bool UpperTimeframeManger::GetStatus(void)
{
    return(this.status);
}


bool UpperTimeframeManger::SetTimeframe(const ENUM_TIMEFRAMES timeframe)
{
    if (timeframe > Period()) {
        this.status = true;
        this.tf = timeframe;
        this.day = 0;
        this.last_shift = 0;
        
        return(true);
    }
    return(false);
}


int UpperTimeframeManger::ShiftToUpperTFShift(const int shift)
{
    MqlDateTime server;
    TimeToStruct(Time[shift], server);
    
    if (server.day != this.day) {
        this.day = server.day;
        this.last_shift = this.GetUpperTFShift(shift);
    }
    
    return(this.last_shift);
}


int UpperTimeframeManger::GetUpperTFShift(const int shift)
{
    for (int time = shift; time >= 0; time--) {
        if(Time[shift] < iTime(Symbol(), this.tf, time)){
            return(time + 1);
        }
    }
    return(0);
}
