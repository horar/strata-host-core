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

    for (int i = m_curves_.length() - 1; i > -1; i--){
        // clean up any dynamically created curves attached to this graph
        if (m_curves_[i]->dynamicallyCreated) {
            delete m_curves_[i];
            m_curves_.remove(i);
        }
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
    update();
}

void SGQWTPlot::update() {
    m_qwtPlot->replot();
    QQuickPaintedItem::update();
}

void SGQWTPlot::shiftXAxis(double offset) {
    double xMin = getXMin_();
    xMin += offset;
    setXMin_(xMin);
    double xMax = getXMax_();
    xMax += offset;
    setXMax_(xMax);
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::shiftYAxis(double offset) {
    double yMin = getYMin_();
    yMin += offset;
    setYMin_(yMin);
    double yMax = getYMax_();
    yMax += offset;
    setYMax_(yMax);
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::autoScaleXAxis() {
   m_qwtPlot->setAxisAutoScale(m_qwtPlot->xBottom);
   if (m_auto_update_) {
       update();
   }
}

void SGQWTPlot::autoScaleYAxis() {
    m_qwtPlot->setAxisAutoScale(m_qwtPlot->yLeft);
    if (m_auto_update_) {
        update();
    }
}

SGQWTPlotCurve* SGQWTPlot::createCurve(QString name) {
    SGQWTPlotCurve* curve = new SGQWTPlotCurve();
    curve->dynamicallyCreated = true;
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
}

void SGQWTPlot::removeCurve(SGQWTPlotCurve* curve) {
    curve->unsetGraph();
    delete curve;
}

int SGQWTPlot::count() {
   return m_curves_.count();
}

void SGQWTPlot::mousePressEvent(QMouseEvent* event)
{
//    routeMouseEvents(event);
}

void SGQWTPlot::mouseReleaseEvent(QMouseEvent* event)
{
//    routeMouseEvents(event);
}

void SGQWTPlot::mouseMoveEvent(QMouseEvent* event)
{
//    routeMouseEvents(event);
}

void SGQWTPlot::mouseDoubleClickEvent(QMouseEvent* event)
{
//    routeMouseEvents(event);
}

void SGQWTPlot::wheelEvent(QWheelEvent* event)
{
//    routeWheelEvents(event);
}

void SGQWTPlot::routeMouseEvents(QMouseEvent* event)
{
//    if (m_qwtPlot) {
//        QMouseEvent* newEvent = new QMouseEvent(event->type(), event->localPos(), event->windowPos(), event->screenPos(),
//                                                event->button(), event->buttons(),
//                                                event->modifiers(), event->source());
//        QCoreApplication::postEvent(m_qwtPlot, newEvent);
//        QCoreApplication::sendEvent(m_qwtPlot->canvas(), newEvent);
//        update();
//    }
}

void SGQWTPlot::routeWheelEvents(QWheelEvent* event)
{
//    if (m_qwtPlot) {
//         QWheelEvent* newEvent = new QWheelEvent(event->pos(), event->delta(),
//                                                 event->buttons(), event->modifiers(),
//                                                 event->orientation());
////         QCoreApplication::postEvent(m_qwtPlot, newEvent);
//         QCoreApplication::sendEvent(m_qwtPlot->canvas(), newEvent);
//         update();
//     }
}

void SGQWTPlot::setXMin_(double value)
{
    m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, value, getXMax_());
    if (m_auto_update_) {
        update();
    }
}

double SGQWTPlot::getXMin_()
{
    return m_qwtPlot->axisScaleDiv(m_qwtPlot->xBottom).lowerBound();
}

void SGQWTPlot::setXMax_(double value)
{
    m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, getXMin_(), value);
    if (m_auto_update_) {
        update();
    }
}

double SGQWTPlot::getXMax_()
{
    return m_qwtPlot->axisScaleDiv(m_qwtPlot->xBottom).upperBound();
}

void SGQWTPlot::setYMin_(double value)
{
    m_qwtPlot->setAxisScale( m_qwtPlot->yLeft, value, getYMax_());
    if (m_auto_update_) {
        update();
    }
}

double SGQWTPlot::getYMin_()
{
    return m_qwtPlot->axisScaleDiv(m_qwtPlot->yLeft).lowerBound();
}

void SGQWTPlot::setYMax_(double value)
{
    m_qwtPlot->setAxisScale( m_qwtPlot->yLeft, getYMin_(), value);
    if (m_auto_update_) {
        update();
    }
}

double SGQWTPlot::getYMax_()
{
    return m_qwtPlot->axisScaleDiv(m_qwtPlot->yLeft).upperBound();
}

QString SGQWTPlot::getXTitle_() {
    return m_qwtPlot->axisTitle(m_qwtPlot->xBottom).text();
}

void SGQWTPlot::setXTitle_(QString title) {
    m_qwtPlot->setAxisTitle(m_qwtPlot->xBottom, title);
    if (m_auto_update_) {
        update();
    }
}

QString SGQWTPlot::getYTitle_() {
    return m_qwtPlot->axisTitle(m_qwtPlot->yLeft).text();
}

void SGQWTPlot::setYTitle_(QString title) {
    m_qwtPlot->setAxisTitle(m_qwtPlot->yLeft, title);
    if (m_auto_update_) {
        update();
    }
}

QString SGQWTPlot::getTitle_() {
    return m_qwtPlot->title().text();
}

void SGQWTPlot::setTitle_(QString title) {
    m_qwtPlot->setTitle(title);
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::setBackgroundColor_(QColor newColor) {
    m_background_color_ = newColor;
    m_qwtPlot->setStyleSheet("background:" + m_background_color_.name());
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::setAxisColor_(QColor newColor) {
    m_axis_color_ = newColor;

    QwtScaleWidget *qwtsw = m_qwtPlot->axisWidget(m_qwtPlot->yLeft);
    QPalette palette = qwtsw->palette();
    palette.setColor( QPalette::WindowText, m_axis_color_);	// for ticks
    palette.setColor( QPalette::Text, m_axis_color_);	    // for ticks' labels
    qwtsw->setPalette( palette );

    qwtsw = m_qwtPlot->axisWidget(m_qwtPlot->xBottom);
    palette = qwtsw->palette();
    palette.setColor( QPalette::WindowText, m_axis_color_);	// for ticks
    palette.setColor( QPalette::Text, m_axis_color_);	    // for ticks' labels
    qwtsw->setPalette( palette );

    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::setXLogarithmic_(bool logarithmic){
    m_x_logarithmic_ = logarithmic;
    if (m_x_logarithmic_){
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->xBottom, new QwtLogScaleEngine(10));
    } else {
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->xBottom, new QwtLinearScaleEngine(10));
    }
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::setYLogarithmic_(bool logarithmic){
    m_y_logarithmic_ = logarithmic;
    if (m_y_logarithmic_){
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->yLeft, new QwtLogScaleEngine(10));
    } else {
        m_qwtPlot->setAxisScaleEngine(m_qwtPlot->yLeft, new QwtLinearScaleEngine(10));
    }
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::updatePlotSize_()
{
    if (m_qwtPlot != nullptr) {
        m_qwtPlot->setGeometry(0, 0, static_cast<int>(width()), static_cast<int>(height()));
        m_qwtPlot->updateLayout();
    }
}

QPointF SGQWTPlot::mapToValue(QPointF point)
{
    QwtScaleMap xMap = m_qwtPlot->canvasMap(m_qwtPlot->xBottom);
    QwtScaleMap yMap = m_qwtPlot->canvasMap(m_qwtPlot->yLeft);
//        xMap.setPaintInterval(34,992);
//        qDebug()<<xMap.p1() << xMap.p2() << xMap.s1() << xMap.s2();
    double xValue = xMap.invTransform(point.x());
    double yValue = yMap.invTransform(point.y());
//    qDebug()<<xValue <<yValue;
////// this is still generating slightly off values after updateLayout compared to manually setting paint interval above
    QPointF valuePoint = QPointF(xValue, yValue);
    return valuePoint;
}

QPointF SGQWTPlot::mapToPosition(QPointF point)
{
    QwtScaleMap xMap = m_qwtPlot->canvasMap(m_qwtPlot->xBottom);
    QwtScaleMap yMap = m_qwtPlot->canvasMap(m_qwtPlot->yLeft);
    double xValue = xMap.transform(point.x());
    double yValue = yMap.transform(point.y());
    QPointF valuePoint = QPointF(xValue, yValue);
    return valuePoint;
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
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlotCurve::unsetGraph()
{
    m_curve->detach();
    m_graph->deregisterCurve(this);
    if (m_auto_update_) {
        update();
    }
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
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlotCurve::setColor(QColor color)
{
    m_color_ = color;
    m_curve->setPen(QPen(m_color_));
    if (m_auto_update_) {
        update();
    }
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
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlotCurve::append(double x, double y)
{
    m_curve_data.append(QPointF(x,y));
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlotCurve::remove(int index)
{
    m_curve_data.remove(index);
    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlotCurve::clear()
{
    m_curve_data.clear();
    if (m_auto_update_) {
        update();
    }
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
    if (m_auto_update_) {
        update();
    }
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
