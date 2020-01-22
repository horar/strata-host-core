#include "SGQWTPlot.h"


SGQWTPlot::SGQWTPlot(QQuickItem* parent) : QQuickPaintedItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, true);
    setAcceptedMouseButtons(Qt::AllButtons);

    connect(this, &QQuickPaintedItem::widthChanged, this, &SGQWTPlot::updatePlotSize_);
    connect(this, &QQuickPaintedItem::heightChanged, this, &SGQWTPlot::updatePlotSize_);

    m_qwtPlot = new QwtPlot();
}

SGQWTPlot::~SGQWTPlot()
{
    delete m_qwtPlot;
    m_qwtPlot = nullptr;

    for (int i = m_dynamic_curves_.length() - 1; i > -1; i--){
        //TODO: clean up dynamically created curves - before delete m_qwtplot maybe?
//        m_dynamic_curves_[i]->deleteLater();
//        m_dynamic_curves_.remove(i);
    }
}

void SGQWTPlot::paint(QPainter* painter)
{
    if (m_qwtPlot != nullptr) {
        QPixmap picture(boundingRect().size().toSize());

        QwtPlotRenderer renderer;
        renderer.renderTo(m_qwtPlot, picture);

        painter->drawPixmap(QPoint(), picture);
    }
}

void SGQWTPlot::initialize()
{
    // after replot() we need to call update() - so disable auto replot
    m_qwtPlot->setAutoReplot(false);
    m_qwtPlot->setStyleSheet("background:" + m_background_color_.name());
    updatePlotSize_();

    setXAxis_();
    setYAxis_();
    update();
}

void SGQWTPlot::update() {
    m_qwtPlot->replot();
    QQuickPaintedItem::update();
}

void SGQWTPlot::shiftXAxis(double offset) {
    m_x_max_ += offset;
    m_x_min_ += offset;
    setXAxis_();
    update();
}

void SGQWTPlot::shiftYAxis(double offset) {
    m_y_max_ += offset;
    m_y_min_ += offset;
    setYAxis_();
    update();
}

void SGQWTPlot::autoScaleXAxis() {
   m_qwtPlot->setAxisAutoScale(m_qwtPlot->xBottom);
   update();
   m_x_min_ = std::numeric_limits<double>::quiet_NaN(); // setting back to NaN (however user may expect a bound auto-updating value here when querying later --- look into this)
   m_x_max_ = std::numeric_limits<double>::quiet_NaN();
}

void SGQWTPlot::autoScaleYAxis() {
    m_qwtPlot->setAxisAutoScale(m_qwtPlot->yLeft);
    update();
    m_y_min_ = std::numeric_limits<double>::quiet_NaN();
    m_y_max_ = std::numeric_limits<double>::quiet_NaN();
}

SGQWTPlotCurve* SGQWTPlot::createCurve(QString name) {
    SGQWTPlotCurve* curve = new SGQWTPlotCurve();
    m_dynamic_curves_.append(curve);
    curve->setGraph(this);
    curve->setName(name);
    return curve;
}

SGQWTPlotCurve* SGQWTPlot::curve(int index) {
    return m_curves_[index];
}

void SGQWTPlot::registerCurve(SGQWTPlotCurve* curve) {
    m_curves_.append(curve);
}

void SGQWTPlot::deregisterCurve(SGQWTPlotCurve* curve) {
    for (int i = 0; i < m_curves_.length(); i++ ){
        if (m_curves_[i] == curve) {
            m_curves_.remove(i);
            break;
        }
    }
    for (int i = 0; i < m_dynamic_curves_.length(); i++ ){
        if (m_dynamic_curves_[i] == curve) {
            m_dynamic_curves_.remove(i);
            break;
        }
    }
}

void SGQWTPlot::removeCurve(SGQWTPlotCurve* curve) {
    curve->unsetGraph();
    delete curve;
    update();
}

int SGQWTPlot::count() {
   return m_curves_.count();
}

void SGQWTPlot::mousePressEvent(QMouseEvent* event)
{
}

void SGQWTPlot::mouseReleaseEvent(QMouseEvent* event)
{
}

void SGQWTPlot::mouseMoveEvent(QMouseEvent* event)
{
}

void SGQWTPlot::mouseDoubleClickEvent(QMouseEvent* event)
{
}

void SGQWTPlot::wheelEvent(QWheelEvent* event)
{
}

void SGQWTPlot::routeMouseEvents(QMouseEvent* event)
{
}

void SGQWTPlot::routeWheelEvents(QWheelEvent* event)
{
}

void SGQWTPlot::setXMin_(double value) {
    m_x_min_ = value;
    setXAxis_();
    update();
}

void SGQWTPlot::setXMax_(double value) {
    m_x_max_ = value;
    setXAxis_();
    update();
}

void SGQWTPlot::setYMin_(double value) {
    m_y_min_ = value;
    setYAxis_();
    update();
}

void SGQWTPlot::setYMax_(double value) {
    m_y_max_ = value;
    setYAxis_();
    update();
}

void SGQWTPlot::setXTitle_(QString title) {
    m_x_title_ = title;
    m_qwtPlot->setAxisTitle(m_qwtPlot->xBottom, m_x_title_);
    update();
}

void SGQWTPlot::setYTitle_(QString title) {
    m_y_title_ = title;
    m_qwtPlot->setAxisTitle(m_qwtPlot->yLeft, m_y_title_);
    update();
}

void SGQWTPlot::setBackgroundColor_(QColor newColor) {
    m_background_color_ = newColor;
    m_qwtPlot->setStyleSheet("background:" + m_background_color_.name());
    update();
}

void SGQWTPlot::setXAxis_(){
    if (!isnan(m_x_min_) && !isnan(m_x_max_)){
        m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, m_x_min_, m_x_max_);
    }
}

void SGQWTPlot::setYAxis_(){
    if (!isnan(m_y_min_) && !isnan(m_y_max_)){
        m_qwtPlot->setAxisScale( m_qwtPlot->yLeft, m_y_min_, m_y_max_);
    }
}

void SGQWTPlot::setXLogarithmic_(bool logarithmic){
    m_x_logarithmic_ = logarithmic;
    if (m_x_logarithmic_){
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->xBottom, new QwtLogScaleEngine(10));
    } else {
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->xBottom, new QwtLinearScaleEngine(10));
    }
    update();
}

void SGQWTPlot::setYLogarithmic_(bool logarithmic){
    m_y_logarithmic_ = logarithmic;
    if (m_y_logarithmic_){
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->yLeft, new QwtLogScaleEngine(10));
    } else {
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->yLeft, new QwtLinearScaleEngine(10));
    }
    update();
}

void SGQWTPlot::updatePlotSize_()
{
    if (m_qwtPlot != nullptr) {
        m_qwtPlot->setGeometry(0, 0, static_cast<int>(width()), static_cast<int>(height()));
    }
}













SGQWTPlotCurve::SGQWTPlotCurve(QObject* parent) : QObject(parent)
{
    m_curve = new QwtPlotCurve(m_name_);

    m_curve->setPen(QPen(m_color_));
    m_curve->setStyle(QwtPlotCurve::Lines);
    m_curve->setRenderHint(QwtPlotItem::RenderAntialiased);
    m_curve->setData(new SGQWTPlotCurveData(&m_curve_data));
    m_curve->setPaintAttribute( QwtPlotCurve::FilterPoints , true );
    m_curve->setItemAttribute(QwtPlotItem::AutoScale, true);
}

SGQWTPlotCurve::~SGQWTPlotCurve()
{
    // QwtPlot class deletes attached QwtPlotItems (i.e. m_curve)
}

void SGQWTPlotCurve::setGraph(SGQWTPlot *graph)
{
    if (m_graph != nullptr) {
        unsetGraph();
    }
    m_graph = graph;
    m_plot = m_graph->m_qwtPlot;
    m_curve->attach(m_plot);
    m_graph->registerCurve(this);
    update();
}

void SGQWTPlotCurve::unsetGraph()
{
    m_graph->deregisterCurve(this);
    m_curve->detach();
    m_plot = nullptr;
    m_graph = nullptr;
}

SGQWTPlot* SGQWTPlotCurve::getGraph()
{
    return m_graph;
}

void SGQWTPlotCurve::setName(QString name)
{
    m_name_ = name;
    m_curve->setTitle(m_name_);
    update();
}

void SGQWTPlotCurve::setColor(QColor color)
{
    m_color_ = color;
    m_curve->setPen(QPen(m_color_));
    update();
}

QColor SGQWTPlotCurve::getColor()
{
    return m_color_;
}

void SGQWTPlotCurve::update()
{
    if (m_graph != nullptr) {
        m_graph->update();
    }
}

void SGQWTPlotCurve::append(QPointF point)
{
    m_curve_data.append(point);
    update(); ///////////// Todo: don't call update here for performance reasons? or filter by a 'autoupdate' bool?
}

void SGQWTPlotCurve::append(double x, double y)
{
    m_curve_data.append(QPointF(x,y));
    update();
}

void SGQWTPlotCurve::remove(int index)
{
    m_curve_data.remove(index);
}

void SGQWTPlotCurve::clear()
{
    m_curve_data.clear();
}

QPointF SGQWTPlotCurve::at(int index)
{
    if (index < m_curve_data.count()) {
        return m_curve_data[index];
    } else {
        return QPointF(0,0);
    }
}

int SGQWTPlotCurve::count()
{
    return m_curve_data.count();
}

void SGQWTPlotCurve::shiftPoints(double offset)
{
    for (int i = 0; i < m_curve_data.length(); i++ ){
        m_curve_data[i].setX(m_curve_data[i].x()+(offset));
    }
    update();
}








SGQWTPlotCurveData::SGQWTPlotCurveData(const QVector<QPointF> *container) :
    _container(container)
{
}

size_t SGQWTPlotCurveData::size() const
{
    return static_cast<size_t>(_container->size());
}

QPointF SGQWTPlotCurveData::sample(size_t i) const
{
    return _container->at(static_cast<int>(i));
}

QRectF SGQWTPlotCurveData::boundingRect() const
{
    return qwtBoundingRect(*this);
}
