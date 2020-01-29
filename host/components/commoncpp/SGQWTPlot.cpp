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
    setBackgroundColor_(m_background_color_.name());
    updatePlotSize_();
    update();
}

void SGQWTPlot::update() {
    m_qwtPlot->replot();
    QQuickPaintedItem::update();
}

void SGQWTPlot::shiftXAxis(double offset) {
    double xMin = getXMin_() + offset;
    double xMax = getXMax_() + offset;
    m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, xMin, xMax);

    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::shiftYAxis(double offset) {
    double yMin = getYMin_() + offset;
    double yMax = getYMax_() + offset;
    m_qwtPlot->setAxisScale( m_qwtPlot->yLeft, yMin, yMax);

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
    SGQWTPlotCurve* curve = new SGQWTPlotCurve(name);
    curve->setGraph(this);
    return curve;
}

SGQWTPlotCurve* SGQWTPlot::curve(int index) {
    if (index >= m_curves_.length() || index < 0) {
        qCWarning(logCategoryUtils) << "Index out of range:" << index;
        return nullptr;
    }
    return m_curves_[index];
}

void SGQWTPlot::removeCurve(SGQWTPlotCurve* curve) {
    curve->unsetGraph();
    delete curve;
    updateCurveList_();
}

void SGQWTPlot::removeCurve(int index) {
    SGQWTPlotCurve *curve = SGQWTPlot::curve(index);
    if (curve != nullptr) {
        removeCurve(curve);
    }
}

int SGQWTPlot::count() {
    return m_curves_.count();
}

void SGQWTPlot::setXMin_(double value)
{
    m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, value, getXMax_());
    if (m_auto_update_) {
        update();
    } else {
        m_qwtPlot->replot();
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
    } else {
        m_qwtPlot->replot();
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
    } else {
        m_qwtPlot->replot();
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
    } else {
        m_qwtPlot->replot();
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
    QPalette palette = m_qwtPlot->palette();
    palette.setColor(QPalette::Window, m_background_color_);
    palette.setColor(QPalette::Light, m_background_color_);
    palette.setColor(QPalette::Dark, m_background_color_);
    m_qwtPlot->setPalette(palette);

    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlot::setForegroundColor_(QColor newColor) {
    m_foreground_color_ = newColor;

    QwtText title = m_qwtPlot->title();
    title.setColor(m_foreground_color_);
    m_qwtPlot->setTitle(title);

    QwtScaleWidget *qwtsw = m_qwtPlot->axisWidget(m_qwtPlot->yLeft);
    QPalette palette = qwtsw->palette();
    palette.setColor( QPalette::WindowText, m_foreground_color_);	// for ticks
    palette.setColor( QPalette::Text, m_foreground_color_);	    // for ticks' labels
    qwtsw->setPalette( palette );

    qwtsw = m_qwtPlot->axisWidget(m_qwtPlot->xBottom);
    palette = qwtsw->palette();
    palette.setColor( QPalette::WindowText, m_foreground_color_);	// for ticks
    palette.setColor( QPalette::Text, m_foreground_color_);	    // for ticks' labels
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
    }
}

void SGQWTPlot::updateCurveList_()
{
    m_curves_ = findChildren<SGQWTPlotCurve*>();
}

QPointF SGQWTPlot::mapToValue(QPointF point)
{
    m_qwtPlot->updateLayout();
    QwtScaleMap xMap = m_qwtPlot->canvasMap(m_qwtPlot->xBottom);
    QwtScaleMap yMap = m_qwtPlot->canvasMap(m_qwtPlot->yLeft);
    QRectF canvasRect = m_qwtPlot->plotLayout()->canvasRect();
    double xValue = xMap.invTransform(point.x() - canvasRect.x());
    double yValue = yMap.invTransform(point.y() - canvasRect.y());
    return QPointF(xValue, yValue);
}

QPointF SGQWTPlot::mapToPosition(QPointF point)
{
    m_qwtPlot->updateLayout();
    QwtScaleMap xMap = m_qwtPlot->canvasMap(m_qwtPlot->xBottom);
    QwtScaleMap yMap = m_qwtPlot->canvasMap(m_qwtPlot->yLeft);
    QRectF canvasRect = m_qwtPlot->plotLayout()->canvasRect();
    double xPos = xMap.transform(point.x()) + canvasRect.x();
    double yPos = yMap.transform(point.y()) + canvasRect.y();
    return QPointF(xPos, yPos);
}






SGQWTPlotCurve::SGQWTPlotCurve(QString name, QObject* parent) : QObject(parent)
{
    m_curve = new QwtPlotCurve(name);

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
    setParent(graph);
    graph->updateCurveList_();
    if (m_graph != nullptr) {
        m_graph->updateCurveList_(); // update previous parent's curve list
        unsetGraph();
    }

    m_graph = graph;
    m_plot = m_graph->m_qwtPlot;
    m_curve->attach(m_plot);

    if (m_auto_update_) {
        update();
    }
}

void SGQWTPlotCurve::unsetGraph()
{
    m_curve->detach();
    if (m_auto_update_) {
        update();
    }
    m_plot = nullptr;
    m_graph = nullptr;
}

SGQWTPlot* SGQWTPlotCurve::getGraph_()
{
    return m_graph;
}

void SGQWTPlotCurve::setName_(QString name)
{
    m_curve->setTitle(name);
    if (m_auto_update_) {
        update();
    }
}

QString SGQWTPlotCurve::getName_()
{
    return m_curve->title().text();
}

void SGQWTPlotCurve::setColor_(QColor color)
{
    m_curve->setPen(QPen(color));
    if (m_auto_update_) {
        update();
    }
}

QColor SGQWTPlotCurve::getColor_()
{
    return m_curve->pen().color();
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
