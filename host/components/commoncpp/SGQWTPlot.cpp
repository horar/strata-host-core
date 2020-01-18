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
    //clean up all dynamic curves
    //for curve in m_dynamic_curves delete curve

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
   m_x_min_ = std::numeric_limits<double>::quiet_NaN(); // setting back to NAN (however user may expect a bound auto-updating value here when querying later --- look into this)
   m_x_max_ = std::numeric_limits<double>::quiet_NaN();
}

void SGQWTPlot::autoScaleYAxis() {
    m_qwtPlot->setAxisAutoScale(m_qwtPlot->yLeft);
    update();
    m_y_min_ = std::numeric_limits<double>::quiet_NaN();
    m_y_max_ = std::numeric_limits<double>::quiet_NaN();
}

SGQWTPlotCurve* SGQWTPlot::addCurve() {
    SGQWTPlotCurve* curve = new SGQWTPlotCurve();
    m_dynamic_curves.push_back(curve);
    return curve;
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

void SGQWTPlot::updatePlotSize_()
{
    if (m_qwtPlot != nullptr) {
        m_qwtPlot->setGeometry(0, 0, static_cast<int>(width()), static_cast<int>(height()));
    }
}













SGQWTPlotCurve::SGQWTPlotCurve(QObject* parent) : QObject(parent)
{
    m_curve = new QwtPlotCurve(m_title_);

    m_curve->setPen(QPen(m_color_));
    m_curve->setStyle(QwtPlotCurve::Lines);
    m_curve->setRenderHint(QwtPlotItem::RenderAntialiased);
    m_curve->setData(new SGQWTPlotCurveData(&m_curve_data));
    m_curve->setPaintAttribute( QwtPlotCurve::FilterPoints , true );
    m_curve->setItemAttribute(QwtPlotItem::AutoScale, true);

//    m_now_ = m_start_time_ = std::chrono::system_clock::now();
}

SGQWTPlotCurve::~SGQWTPlotCurve()
{
}

void SGQWTPlotCurve::addPoint(QPointF point)
{
    m_curve_data.append(point);
    update();
}

void SGQWTPlotCurve::addPoint(double x, double y)
{
    m_curve_data.append(QPointF(x,y));
    update();
}

void SGQWTPlotCurve::setGraph(SGQWTPlot *graph)
{
    m_plot = graph->m_qwtPlot;
    m_graph = graph;
    m_curve->attach(m_plot);
    update();
}

SGQWTPlot* SGQWTPlotCurve::getGraph()
{
    return m_graph;
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

void SGQWTPlotCurve::shiftPoints(double offset)
{
    for (int i = 0; i < m_curve_data.length(); i++ ){
        m_curve_data[i].setX(m_curve_data[i].x()+(offset));
    }
    //update();?
}

int SGQWTPlotCurve::count()
{
    return m_curve_data.count();
}

QPointF* SGQWTPlotCurve::get(int index)
{
    return m_curve_data[index];
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
