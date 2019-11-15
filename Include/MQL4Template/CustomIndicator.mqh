#property copyright "Copyright 2019, Keisuke Iwabuchi"
#property strict


struct ACParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
};
struct ADParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
};
struct ADXParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_APPLIED_PRICE applied_price;
    int mode;
};
struct AlligatorParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int jaw_period;
    int jaw_shift;
    int teeth_period;
    int teeth_shift;
    int lips_period;
    int lips_shift;
    ENUM_MA_METHOD ma_method;
    ENUM_APPLIED_PRICE applied_price;
    int mode;
};
struct AOParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
};
struct ATRParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
};
struct BearsPowerParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_APPLIED_PRICE applied_price;
};
struct BandsParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    double deviation;
    int bands_shift;
    ENUM_APPLIED_PRICE applied_price;
    int mode;
};
struct BullsPowerParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_APPLIED_PRICE applied_price;
};
struct CCIParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_APPLIED_PRICE applied_price;
};
struct DeMarkerParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
};
struct EnvelopesParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int ma_period;
    ENUM_MA_METHOD ma_method;
    int ma_shift;
    ENUM_APPLIED_PRICE applied_price;
    double deviation;
    int mode;
};
struct ForceParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_MA_METHOD ma_method;
    ENUM_APPLIED_PRICE applied_price;
};
struct FractalsParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int mode;
};
struct GatorParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int jaw_period;
    int jaw_shift;
    int teeth_period;
    int teeth_shift;
    int lips_period;
    int lips_shift;
    ENUM_MA_METHOD ma_method;
    ENUM_APPLIED_PRICE applied_price;
    int mode;
};
struct IchimokuParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int tenkan_sen;
    int kijun_sen;
    int senkou_span_b;
    int mode;
};
struct BWMFIParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
};
struct MomentumParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_APPLIED_PRICE applied_price;
};
struct MFIParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
};
struct MAParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    int ma_shift;
    ENUM_MA_METHOD ma_method;
    ENUM_APPLIED_PRICE applied_price;
};
struct OsMAParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int fast_ema_period;
    int slow_ema_period;
    int signal_period;
    ENUM_APPLIED_PRICE applied_price;
};
struct MACDParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int fast_ema_period;
    int slow_ema_period;
    int signal_period;
    ENUM_APPLIED_PRICE applied_price;
    int mode;
};
struct OBVParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    ENUM_APPLIED_PRICE applied_price;
};
struct SARParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    double step;
    double maximum;
};
struct RSIParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    ENUM_APPLIED_PRICE applied_price;
};
struct RVIParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
    int mode;
};
struct StdDevParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int ma_period;
    int ma_shift;
    ENUM_MA_METHOD ma_method;
    ENUM_APPLIED_PRICE applied_price;
};
struct StochasticParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int k_period;
    int d_period;
    int slowing;
    ENUM_MA_METHOD method;
    ENUM_STO_PRICE price_field;
    int mode;
};
struct WPRParams {
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    int period;
};



ACParams GetACParams()
{
    ACParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    
    return(params);
}


double AC(const ACParams &params, const int shift)
{
    return(iAC(
        params.symbol,
        params.timeframe,
        shift
    ));
}


ADParams GetADParams()
{
    ADParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    
    return(params);
}


double AD(const ADParams &params, const int shift)
{
    return(iAD(
        params.symbol,
        params.timeframe,
        shift
    ));
}


ADXParams GetADXParams()
{
    ADXParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    params.applied_price = PRICE_CLOSE;
    params.mode = MODE_MAIN;
    
    return(params);
}


double ADX(const ADXParams &params, const int shift)
{
    return(iADX(
        params.symbol,
        params.timeframe,
        params.period,
        params.applied_price,
        params.mode,
        shift
    ));
}


AlligatorParams GetAlligatorParams()
{
    AlligatorParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.jaw_period = 13;
    params.jaw_shift = 8;
    params.teeth_period = 18;
    params.teeth_shift = 5;
    params.lips_period = 5;
    params.lips_shift = 3;
    params.ma_method = MODE_SMMA;
    params.applied_price = PRICE_MEDIAN;
    params.mode = MODE_GATORJAW;
    
    return(params);
}


double Alligator(const AlligatorParams &params, const int shift)
{
    return(iAlligator(
        params.symbol,
        params.timeframe,
        params.jaw_period,
        params.jaw_shift,
        params.teeth_period,
        params.teeth_shift,
        params.lips_period,
        params.lips_shift,
        params.ma_method,
        params.applied_price,
        params.mode,
        shift
    ));
}


AOParams GetAOParams()
{
    AOParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    
    return(params);
}


double AO(const AOParams &params, const int shift)
{
    return(iAO(
        params.symbol,
        params.timeframe,
        shift
    ));
}


ATRParams GetATRParams()
{
    ATRParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    
    return(params);
}


double ATR(const ATRParams &params, const int shift)
{
    return(iATR(
        params.symbol,
        params.timeframe,
        params.period,
        shift
    ));
}


BearsPowerParams GetBearsPowerParams()
{
    BearsPowerParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 13;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double BearsPower(const BearsPowerParams &params, const int shift)
{
    return(iBearsPower(
        params.symbol,
        params.timeframe,
        params.period,
        params.applied_price,
        shift
    ));
}


BandsParams GetBandsParams()
{
    BandsParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 20;
    params.deviation = 2.0;
    params.bands_shift = 0;
    params.applied_price = PRICE_CLOSE;
    params.mode = MODE_UPPER;
    
    return(params);
}


double Bands(const BandsParams &params, const int shift)
{
    return(iBands(
        params.symbol,
        params.timeframe,
        params.period,
        params.deviation,
        params.bands_shift,
        params.applied_price,
        params.mode,
        shift
    ));
}


BullsPowerParams GetBullsPowerParams()
{
    BullsPowerParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 13;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double BullsPower(const BullsPowerParams &params, const int shift)
{
    return(iBullsPower(
        params.symbol,
        params.timeframe,
        params.period,
        params.applied_price,
        shift
    ));
}


CCIParams GetCCIParams()
{
    CCIParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    params.applied_price = PRICE_TYPICAL;
    
    return(params);
}


double CCI(const CCIParams &params, const int shift)
{
    return(iCCI(
        params.symbol,
        params.timeframe,
        params.period,
        params.applied_price,
        shift
    ));
}


DeMarkerParams GetDeMarkerParams()
{
    DeMarkerParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    
    return(params);
}


double DeMarker(const DeMarkerParams &params, const int shift)
{
    return(iDeMarker(
        params.symbol,
        params.timeframe,
        params.period,
        shift
    ));
}


EnvelopesParams GetEnvelopesParams()
{
    EnvelopesParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.ma_period = 14;
    params.ma_method = MODE_SMA;
    params.ma_shift = 0;
    params.applied_price = PRICE_CLOSE;
    params.deviation = 0.1;
    params.mode = MODE_UPPER;
    
    return(params);
}


double Envelopes(const EnvelopesParams &params, const int shift)
{
    return(iEnvelopes(
        params.symbol,
        params.timeframe,
        params.ma_period,
        params.ma_method,
        params.ma_shift,
        params.applied_price,
        params.deviation,
        params.mode,
        shift
    ));
}


ForceParams GetForceParams()
{
    ForceParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 13;
    params.ma_method = MODE_SMA;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double Force(const ForceParams &params, const int shift)
{
    return(iForce(
        params.symbol,
        params.timeframe,
        params.period,
        params.ma_method,
        params.applied_price,
        shift));
}


FractalsParams GetFractalsParams()
{
    FractalsParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.mode = MODE_UPPER;
    
    return(params);
}


double Fractals(const FractalsParams &params, const int shift)
{
    return(iFractals(
        params.symbol,
        params.timeframe,
        params.mode,
        shift));
}


GatorParams GetGatorParams()
{
    GatorParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.jaw_period = 13;
    params.jaw_shift = 8;
    params.teeth_period = 18;
    params.teeth_shift = 5;
    params.lips_period = 5;
    params.lips_shift = 3;
    params.ma_method = MODE_SMMA;
    params.applied_price = PRICE_MEDIAN;
    params.mode = MODE_UPPER;
    
    return(params);
}


double Gator(const GatorParams &params, const int shift)
{
    return(iGator(
        params.symbol,
        params.timeframe,
        params.jaw_period,
        params.jaw_shift,
        params.teeth_period,
        params.teeth_shift,
        params.lips_period,
        params.lips_shift,
        params.ma_method,
        params.applied_price,
        params.mode,
        shift
    ));
}


IchimokuParams GetIchimokuParams()
{
    IchimokuParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.tenkan_sen = 9;
    params.kijun_sen = 26;
    params.senkou_span_b = 52;
    params.mode = MODE_TENKANSEN;
    
    return(params);
}


double Ichimoku(const IchimokuParams &params, const int shift)
{
    return(iIchimoku(
        params.symbol,
        params.timeframe,
        params.tenkan_sen,
        params.kijun_sen,
        params.senkou_span_b,
        params.mode,
        shift
    ));
}


BWMFIParams GetBWMFIParams()
{
    BWMFIParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    
    return(params);
}


double BWMFI(const BWMFIParams &params, const int shift)
{
    return(iBWMFI(
        params.symbol,
        params.timeframe,
        shift
    ));
}


MomentumParams GetMomentumParams()
{
    MomentumParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double Momentum(const MomentumParams &params, const int shift)
{
    return(iMomentum(
        params.symbol,
        params.timeframe,
        params.period,
        params.applied_price,
        shift
    ));
}


MFIParams GetMFIParams()
{
    MFIParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    
    return(params);
}


double MFI(const MFIParams &params, const int shift)
{
    return(iMFI(
        params.symbol,
        params.timeframe,
        params.period,
        shift
    ));
}


MAParams GetMAParams()
{
    MAParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    params.ma_shift = 0;
    params.ma_method = MODE_SMA;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double MA(const MAParams &params, const int shift)
{
    return(iMA(
        params.symbol,
        params.timeframe,
        params.period,
        params.ma_shift,
        params.ma_method,
        params.applied_price,
        shift));
}


OsMAParams GetOsMAParams()
{
    OsMAParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.fast_ema_period = 12;
    params.slow_ema_period = 26;
    params.signal_period = 9;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double OsMA(const OsMAParams &params, const int shift)
{
    return(iOsMA(
        params.symbol,
        params.timeframe,
        params.fast_ema_period,
        params.slow_ema_period,
        params.signal_period,
        params.applied_price,
        shift
    ));
}


MACDParams GetMACDParams()
{
    MACDParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.fast_ema_period = 12;
    params.slow_ema_period = 26;
    params.signal_period = 9;
    params.applied_price = PRICE_CLOSE;
    params.mode = MODE_MAIN;
    
    return(params);
}


double MACD(const MACDParams &params, const int shift)
{
    return(iMACD(
        params.symbol,
        params.timeframe,
        params.fast_ema_period,
        params.slow_ema_period,
        params.signal_period,
        params.applied_price,
        params.mode,
        shift
    ));
}


OBVParams GetOBVParams()
{
    OBVParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double OBV(const OBVParams &params, const int shift)
{
    return(iOBV(
        params.symbol,
        params.timeframe,
        params.applied_price,
        shift
    ));
}


SARParams GetSARParams()
{
    SARParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.step = 0.02;
    params.maximum = 0.2;
    
    return(params);
}


double SAR(const SARParams &params, const int shift)
{
    return(iSAR(
        params.symbol,
        params.timeframe,
        params.step,
        params.maximum,
        shift
    ));
}


RSIParams GetRSIParams()
{
    RSIParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double RSI(const RSIParams &params, const int shift)
{
    return(iRSI(
        params.symbol,
        params.timeframe,
        params.period,
        params.applied_price,
        shift
    ));
}


RVIParams GetRVIParams()
{
    RVIParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 10;
    params.mode = MODE_MAIN;
    
    return(params);
}


double RVI(const RVIParams &params, const int shift)
{
    return(iRVI(
        params.symbol,
        params.timeframe,
        params.period,
        params.mode,
        shift
    ));
}


StdDevParams GetStdDevParams()
{
    StdDevParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.ma_period = 20;
    params.ma_shift = 0;
    params.ma_method = MODE_SMA;
    params.applied_price = PRICE_CLOSE;
    
    return(params);
}


double StdDev(const StdDevParams &params, const int shift)
{
    return(iStdDev(
        params.symbol,
        params.timeframe,
        params.ma_period,
        params.ma_shift,
        params.ma_method,
        params.applied_price,
        shift
    ));
}


StochasticParams GetStochasticParams()
{
    StochasticParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.k_period = 5;
    params.d_period = 3;
    params.slowing = 3;
    params.method = MODE_SMA;
    params.price_field = STO_LOWHIGH;
    params.mode = MODE_MAIN;
    
    return(params);
}


double Stochastic(const StochasticParams &params, const int shift)
{
    return(iStochastic(
        params.symbol,
        params.timeframe,
        params.k_period,
        params.d_period,
        params.slowing,
        params.method,
        params.price_field,
        params.mode,
        shift
    ));
}


WPRParams GetWPRParams()
{
    WPRParams params;
    
    params.symbol = _Symbol;
    params.timeframe = 0;
    params.period = 14;
    
    return(params);
}


double WPR(const WPRParams &params, const int shift)
{
    return(iWPR(
        params.symbol,
        params.timeframe,
        params.period,
        shift
    ));
}
