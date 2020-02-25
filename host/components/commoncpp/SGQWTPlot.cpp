#include "SGQWTPlot.h"

SGQWTPlot::SGQWTPlot(QQuickItem* parent) : QQuickPaintedItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, true);
    setAcceptedMouseButtons(Qt::AllButtons);

    connect(this, &QQuickPaintedItem::widthChanged, this, &SGQWTPlot::updatePlotSize);
    connect(this, &QQuickPaintedItem::heightChanged, this, &SGQWTPlot::updatePlotSize);

    qwtPlot = new QwtPlot();

    setBackgroundColor("white");
}

SGQWTPlot::~SGQWTPlot()
{
    delete qwtPlot;
    qwtPlot = nullptr;
}

void SGQWTPlot::paint(QPainter* painter)
{
    if (qwtPlot != nullptr) {
        QPixmap picture(boundingRect().size().toSize());

        QwtPlotRenderer renderer;
        renderer.renderTo(qwtPlot, picture);

        painter->drawPixmap(QPoint(), picture);
    }
}

void SGQWTPlot::initialize()
{
    // after replot() we need to call update() - so disable auto replot
    qwtPlot->setAutoReplot(false);
    updatePlotSize();
    update();
}

void SGQWTPlot::update()
{
    qwtPlot->replot();
    QQuickPaintedItem::update();
}

void SGQWTPlot::shiftXAxis(double offset)
{
    double xMin = this->xMin() + offset;
    double xMax = this->xMax() + offset;
    qwtPlot->setAxisScale( qwtPlot->xBottom, xMin, xMax);

    if (autoUpdate_) {
        update();
    }
}

void SGQWTPlot::shiftYAxis(double offset)
{
    double yMin = this->yMin() + offset;
    double yMax = this->yMax() + offset;
    qwtPlot->setAxisScale( qwtPlot->yLeft, yMin, yMax);

    if (autoUpdate_) {
        update();
    }
}

void SGQWTPlot::autoScaleXAxis()
{
   qwtPlot->setAxisAutoScale(qwtPlot->xBottom);
   emit xMinChanged();
   emit xMaxChanged();
   if (autoUpdate_) {
       update();
   }
}

void SGQWTPlot::autoScaleYAxis()
{
    qwtPlot->setAxisAutoScale(qwtPlot->yLeft);
    emit yMinChanged();
    emit yMaxChanged();
    if (autoUpdate_) {
        update();
    }
}

SGQWTPlotCurve* SGQWTPlot::createCurve(QString name)
{
    SGQWTPlotCurve* curve = new SGQWTPlotCurve(name);
    curve->setGraph(this);
    return curve;
}

SGQWTPlotCurve* SGQWTPlot::curve(int index)
{
    if (index >= curves_.length() || index < 0) {
        qCWarning(logCategoryQWTPlot) << "Index out of range:" << index;
        return nullptr;
    }
    return curves_[index];
}

void SGQWTPlot::removeCurve(SGQWTPlotCurve* curve)
{
    curve->unsetGraph();
    delete curve;
    updateCurveList();
}

void SGQWTPlot::removeCurve(int index)
{
    SGQWTPlotCurve *curve = SGQWTPlot::curve(index);
    if (curve != nullptr) {
        removeCurve(curve);
    }
}

int SGQWTPlot::getCount()
{
    return curves_.count();
}

void SGQWTPlot::setXMin(double value)
{
    qwtPlot->setAxisScale( qwtPlot->xBottom, value, xMax());
    emit xMinChanged();
    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQWTPlot::xMin()
{
    return qwtPlot->axisScaleDiv(qwtPlot->xBottom).lowerBound();
}

void SGQWTPlot::setXMax(double value)
{
    qwtPlot->setAxisScale( qwtPlot->xBottom, xMin(), value);
    emit xMaxChanged();
    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQWTPlot::xMax()
{
    return qwtPlot->axisScaleDiv(qwtPlot->xBottom).upperBound();
}

void SGQWTPlot::setYMin(double value)
{
    qwtPlot->setAxisScale( qwtPlot->yLeft, value, yMax());
    emit yMinChanged();
    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQWTPlot::yMin()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yLeft).lowerBound();
}

void SGQWTPlot::setYMax(double value)
{
    qwtPlot->setAxisScale( qwtPlot->yLeft, yMin(), value);
    emit yMaxChanged();
    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQWTPlot::yMax()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yLeft).upperBound();
}

QString SGQWTPlot::xTitle()
{
    return qwtPlot->axisTitle(qwtPlot->xBottom).text();
}

void SGQWTPlot::setXTitle(QString title)
{
    if (title != xTitle()){
        qwtPlot->setAxisTitle(qwtPlot->xBottom, title);
        emit xTitleChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

QString SGQWTPlot::yTitle()
{
    return qwtPlot->axisTitle(qwtPlot->yLeft).text();
}

void SGQWTPlot::setYTitle(QString title)
{
    if (title != yTitle()){
        qwtPlot->setAxisTitle(qwtPlot->yLeft, title);
        emit yTitleChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

QString SGQWTPlot::title()
{
    return qwtPlot->title().text();
}

void SGQWTPlot::setTitle(QString title)
{
    if (title != this->title()){
        qwtPlot->setTitle(title);
        emit titleChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot::setBackgroundColor(QColor newColor)
{
    if (backgroundColor_ != newColor){
        backgroundColor_ = newColor;
        QPalette palette = qwtPlot->palette();
        palette.setColor(QPalette::Window, backgroundColor_);
        palette.setColor(QPalette::Light, backgroundColor_);
        palette.setColor(QPalette::Dark, backgroundColor_);
        qwtPlot->setPalette(palette);
        emit backgroundColorChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot::setForegroundColor(QColor newColor)
{
    if (foregroundColor_ != newColor){
        foregroundColor_ = newColor;

        QwtText title = qwtPlot->title();
        title.setColor(foregroundColor_);
        qwtPlot->setTitle(title);

        QwtScaleWidget *qwtsw = qwtPlot->axisWidget(qwtPlot->yLeft);
        QPalette palette = qwtsw->palette();
        palette.setColor( QPalette::WindowText, foregroundColor_);	// for ticks
        palette.setColor( QPalette::Text, foregroundColor_);	    // for ticks' labels
        qwtsw->setPalette( palette );

        qwtsw = qwtPlot->axisWidget(qwtPlot->xBottom);
        palette = qwtsw->palette();
        palette.setColor( QPalette::WindowText, foregroundColor_);	// for ticks
        palette.setColor( QPalette::Text, foregroundColor_);	    // for ticks' labels
        qwtsw->setPalette( palette );

        emit foregroundColorChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot::setXLogarithmic(bool logarithmic)
{
    if (logarithmic != xLogarithmic_){
        xLogarithmic_ = logarithmic;
        if (xLogarithmic_){
            qwtPlot->setAxisScaleEngine(qwtPlot->xBottom, new QwtLogScaleEngine(10));
        } else {
            qwtPlot->setAxisScaleEngine(qwtPlot->xBottom, new QwtLinearScaleEngine(10));
        }

        emit xLogarithmicChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot::setYLogarithmic(bool logarithmic)
{
    if (logarithmic != yLogarithmic_){
        yLogarithmic_ = logarithmic;
        if (yLogarithmic_){
            qwtPlot->setAxisScaleEngine(qwtPlot->yLeft, new QwtLogScaleEngine(10));
        } else {
            qwtPlot->setAxisScaleEngine(qwtPlot->yLeft, new QwtLinearScaleEngine(10));
        }

        emit yLogarithmicChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot::updatePlotSize()
{
    if (qwtPlot != nullptr) {
        qwtPlot->setGeometry(0, 0, static_cast<int>(width()), static_cast<int>(height()));
    }
}

void SGQWTPlot::updateCurveList()
{
    curves_ = findChildren<SGQWTPlotCurve*>();
    emit countChanged();
}

QPointF SGQWTPlot::mapToValue(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yLeft);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xValue = xMap.invTransform(point.x() - canvasRect.x());
    double yValue = yMap.invTransform(point.y() - canvasRect.y());
    return QPointF(xValue, yValue);
}

QPointF SGQWTPlot::mapToPosition(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yLeft);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xPos = xMap.transform(point.x()) + canvasRect.x();
    double yPos = yMap.transform(point.y()) + canvasRect.y();
    return QPointF(xPos, yPos);
}






SGQWTPlotCurve::SGQWTPlotCurve(QString name, QObject* parent) : QObject(parent)
{
    curve_ = new QwtPlotCurve(name);

    curve_->setStyle(QwtPlotCurve::Lines);
    curve_->setRenderHint(QwtPlotItem::RenderAntialiased);
    curve_->setData(new SGQWTPlotCurveData(&curveData_));
    curve_->setPaintAttribute( QwtPlotCurve::FilterPoints , true );
    curve_->setItemAttribute(QwtPlotItem::AutoScale, true);
}

SGQWTPlotCurve::~SGQWTPlotCurve()
{
    // QwtPlot class deletes attached QwtPlotItems (i.e. curve_)
}

void SGQWTPlotCurve::setGraph(SGQWTPlot *graph)
{
    if (graph_ != graph){
        setParent(graph);
        graph->updateCurveList();
        if (graph_ != nullptr) {
            graph_->updateCurveList(); // update previous parent's curve list
            unsetGraph();
        }

        graph_ = graph;
        plot_ = graph_->qwtPlot;
        curve_->attach(plot_);

        if (autoUpdate_) {
            update();
        }

        emit graphChanged();
    }
}

void SGQWTPlotCurve::unsetGraph()
{
    curve_->detach();
    if (autoUpdate_) {
        update();
    }
    plot_ = nullptr;
    graph_ = nullptr;
}

SGQWTPlot* SGQWTPlotCurve::graph()
{
    return graph_;
}

void SGQWTPlotCurve::setName(QString name)
{
    if (name != this->name()){
        curve_->setTitle(name);
        if (autoUpdate_) {
            update();
        }
        emit nameChanged();
    }
}

QString SGQWTPlotCurve::name()
{
    return curve_->title().text();
}

void SGQWTPlotCurve::setColor(QColor color)
{
    if (color != this->color()){
        curve_->setPen(QPen(color));
        if (autoUpdate_) {
            update();
        }
        emit colorChanged();
    }
}

QColor SGQWTPlotCurve::color()
{
    return curve_->pen().color();
}

void SGQWTPlotCurve::update()
{
    if (graph_ != nullptr) {
        graph_->update();
    }
}

void SGQWTPlotCurve::append(double x, double y)
{
    curveData_.append(QPointF(x,y));
    if (autoUpdate_) {
        update();
    }
}

void SGQWTPlotCurve::appendList(const QVariantList &list)
{
    bool autoUpdateCache = autoUpdate_;
    autoUpdate_ = false;
    for (int var = 0; var < list.length(); ++var) {
        append(list[var].toMap()["x"].toDouble(), list[var].toMap()["y"].toDouble());
    }
    autoUpdate_ = autoUpdateCache;
    if (autoUpdate_) {
        update();
    }
}

void SGQWTPlotCurve::remove(int index)
{
    curveData_.remove(index);
    if (autoUpdate_) {
        update();
    }
}

void SGQWTPlotCurve::clear()
{
    curveData_.clear();
    if (autoUpdate_) {
        update();
    }
}

QPointF SGQWTPlotCurve::at(int index)
{
    if (index < curveData_.count()) {
        return curveData_[index];
    } else {
        return QPointF(0,0);
    }
}

int SGQWTPlotCurve::count()
{
    return curveData_.count();
}

void SGQWTPlotCurve::shiftPoints(double offsetX, double offsetY)
{
    for (int i = 0; i < curveData_.length(); i++ ){
        curveData_[i].setX(curveData_[i].x()+(offsetX));
        curveData_[i].setY(curveData_[i].y()+(offsetY));
    }
    if (autoUpdate_) {
        update();
    }
}






SGQWTPlotCurveData::SGQWTPlotCurveData(const QVector<QPointF> *container) :
    container_(container)
{
}

size_t SGQWTPlotCurveData::size() const
{
    return static_cast<size_t>(container_->size());
}

QPointF SGQWTPlotCurveData::sample(size_t i) const
{
    return container_->at(static_cast<int>(i));
}

QRectF SGQWTPlotCurveData::boundingRect() const
{
    return qwtBoundingRect(*this);
}
