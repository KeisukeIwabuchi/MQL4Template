#include <Controls\WndObj.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>


class KLabel : public CWndObj
{
    private:
        CChartObjectLabel m_label; // chart object
   
    public:
        KLabel(void);
        ~KLabel(void);
        //--- create
        virtual bool Create(const long chart,
                            const string name,
                            const int subwin,
                            const int x1,
                            const int y1,
                            const int x2,
                            const int y2);
   
        //--- original method
        virtual bool Anchor(const ENUM_ANCHOR_POINT anchor);
        virtual bool Corner(const ENUM_BASE_CORNER corner);
   
    protected:
        //--- handlers of object settings
        virtual bool OnSetText(void) { return(m_label.Description(m_text)); }
        virtual bool OnSetColor(void) { return(m_label.Color(m_color)); }
        virtual bool OnSetFont(void) { return(m_label.Font(m_font)); }
        virtual bool OnSetFontSize(void) { return(m_label.FontSize(m_font_size)); }
        //--- internal event handlers
        virtual bool OnCreate(void);
        virtual bool OnShow(void);
        virtual bool OnHide(void);
        virtual bool OnMove(void);
};


KLabel::KLabel(void)
{
    m_color = CONTROLS_LABEL_COLOR;
}


KLabel::~KLabel(void)
{
}


bool KLabel::Create(const long chart,
                    const string name,
                    const int subwin,
                    const int x1,
                    const int y1,
                    const int x2,
                    const int y2)
{
    //--- call method of the parent class
    if (!CWndObj::Create(chart, name, subwin, x1, y1, x2, y2)) {
        return(false);
    }
   
    //--- create the chart object
    if (!m_label.Create(chart, name, subwin, x1, y1)) {
        return(false);
    }
   
    //--- call the settings handler
    return(OnChange());
}


bool KLabel::OnCreate(void)
{
    //--- create the chart object by previously set parameters
    return(m_label.Create(m_chart_id, m_name, m_subwin, m_rect.left, m_rect.top));
}


bool KLabel::OnShow(void)
{
    return(m_label.Timeframes(OBJ_ALL_PERIODS));
}


bool KLabel::OnHide(void)
{
    return(m_label.Timeframes(OBJ_NO_PERIODS));
}


bool KLabel::OnMove(void)
{
    //--- position the chart object
    return(m_label.X_Distance(m_rect.left) && m_label.Y_Distance(m_rect.top));
}


bool KLabel::Anchor(const ENUM_ANCHOR_POINT anchor)
{
    if (m_chart_id == -1) {
        return(false);
    }
    return(ObjectSetInteger(m_chart_id, m_name, OBJPROP_ANCHOR, anchor));
}


bool KLabel::Corner(const ENUM_BASE_CORNER corner)
{
    if (m_chart_id == -1) {
        return(false);
    }
    return(ObjectSetInteger(m_chart_id, m_name, OBJPROP_CORNER, corner));
}