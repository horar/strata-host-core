#include "SGQWTPlot.h"
#include "logging/LoggingQtCategories.h"

const double MAX_DIFF = 1.0e10; // large double value

SGQWTPlot::SGQWTPlot(QQuickItem* parent) : QQuickPaintedItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, true);
    setAcceptedMouseButtons(Qt::AllButtons);

    connect(this, &QQuickPaintedItem::widthChanged, this, &SGQWTPlot::updatePlotSize);
    connect(this, &QQuickPaintedItem::heightChanged, this, &SGQWTPlot::updatePlotSize);

    qwtPlot = new QwtPlot();
    qwtGrid_ = new QwtPlotGrid();

    setBackgroundColor("white");
    setForegroundColor("black");

    qwtGrid_->attach(qwtPlot);
    //Setting the default values for x,y axises and color of grid lines.
    qwtGrid_->enableX(xGrid_);
    qwtGrid_->enableY(yGrid_);
    qwtGrid_->enableXMin(xMinorGrid_);
    qwtGrid_->enableYMin(yMinorGrid_);
    setGridColor("lightgrey");
}

SGQWTPlot::~SGQWTPlot()
{
    delete qwtGrid_;
    qwtGrid_ = nullptr;

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
    qwtPlot->setAxisScale(qwtPlot->yLeft, yMin, yMax);
    if (autoUpdate_) {
        update();
    }
}

void SGQWTPlot::shiftYAxisRight(double offset)
{
    double yMinRight = this->yRightMin() + offset;
    double yMaxRight = this->yRightMax() + offset;
    qwtPlot->setAxisScale(qwtPlot->yRight, yMinRight, yMaxRight);
    if (autoUpdate_) {
        update();
    }
}

bool SGQWTPlot :: yRightVisible()
{
    return yRightVisible_;
}

void SGQWTPlot :: setYRightVisible(bool showYRightAxis)
{
    if(yRightVisible_ != showYRightAxis) {
        yRightVisible_ = showYRightAxis;
        qwtPlot->enableAxis(qwtPlot->yRight,showYRightAxis);
        emit yRightVisibleChanged();
        if (autoUpdate_) {
            update();
        }
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
    qwtPlot->setAxisAutoScale(qwtPlot->yRight);
    emit yMinChanged();
    emit yMaxChanged();
    emit yRightMinChanged();
    emit yRightMaxChanged();
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


void SGQWTPlot :: setXGrid(bool showGrid)
{
    if(xGrid_ != showGrid) {
        xGrid_ = showGrid;
        qwtGrid_->enableX(xGrid_);

        emit xGridChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQWTPlot :: xGrid()
{
    return xGrid_;
}

void SGQWTPlot :: setYGrid(bool showGrid)
{
    if(yGrid_ != showGrid) {
        yGrid_ = showGrid;
        qwtGrid_->enableY(yGrid_);

        emit yGridChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQWTPlot :: yGrid()
{
    return yGrid_;
}

void SGQWTPlot :: setXMinorGrid(bool showGrid)
{
    if(xMinorGrid_ != showGrid) {
        xMinorGrid_ = showGrid;
        setXGrid(xMinorGrid_);
        qwtGrid_->enableXMin(xMinorGrid_);

        emit xMinorGridChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQWTPlot :: xMinorGrid()
{
    return xMinorGrid_;
}

void SGQWTPlot :: setYMinorGrid(bool showGrid)
{
    if(yMinorGrid_ != showGrid) {
        yMinorGrid_ = showGrid;
        setYGrid(yMinorGrid_);
        qwtGrid_->enableYMin(yMinorGrid_);
        emit yMinorGridChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQWTPlot :: yMinorGrid()
{
    return yMinorGrid_;
}


void SGQWTPlot :: setGridColor(QColor newColor)
{
    if (gridColor_ != newColor) {
        gridColor_ = newColor;
        qwtGrid_->setPen(QPen(gridColor_,0,Qt::DotLine));

        emit gridColorChanged();
        if (autoUpdate_) {
            update();
        }
    }
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
    qwtPlot->setAxisScale(qwtPlot->yLeft, value, yMax());
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

    qwtPlot->setAxisScale(qwtPlot->yLeft, yMin(), value);
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

void SGQWTPlot::setYRightMin(double value)
{
    qwtPlot->setAxisScale(qwtPlot->yRight, value, yRightMax());
    emit yRightMinChanged();
    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQWTPlot::yRightMin()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yRight).lowerBound();
}

void SGQWTPlot::setYRightMax(double value)
{
    qwtPlot->setAxisScale(qwtPlot->yRight, yRightMin(), value);
    emit yRightMaxChanged();
    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQWTPlot::yRightMax()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yRight).upperBound();
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

void SGQWTPlot::setXTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->xTitlePixelSize()){
        QwtText title = qwtPlot->axisTitle(qwtPlot->xBottom);
        QFont titleFont = title.font();
        titleFont.setPixelSize(pixelSize);
        title.setFont(titleFont);
        qwtPlot->setAxisTitle(qwtPlot->xBottom, title);
        emit xTitlePixelSizeChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

int SGQWTPlot::xTitlePixelSize()
{
    return qwtPlot->axisTitle(qwtPlot->xBottom).font().pixelSize();
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

void SGQWTPlot::setYTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->yTitlePixelSize()){
        QwtText title = qwtPlot->axisTitle(qwtPlot->yLeft);
        QFont titleFont = title.font();
        titleFont.setPixelSize(pixelSize);
        title.setFont(titleFont);
        qwtPlot->setAxisTitle(qwtPlot->yLeft, title);
        emit yTitlePixelSizeChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

int SGQWTPlot::yTitlePixelSize()
{
    return qwtPlot->axisTitle(qwtPlot->yLeft).font().pixelSize();
}

QString SGQWTPlot::yRightTitle()
{
    return qwtPlot->axisTitle(qwtPlot->yRight).text();
}

void SGQWTPlot::setYRightTitle(QString title)
{
    if (title != yRightTitle()){
        qwtPlot->setAxisTitle(qwtPlot->yRight, title);
        emit yRightTitleChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot::setYRightTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->yRightTitlePixelSize()){
        QwtText title = qwtPlot->axisTitle(qwtPlot->yRight);
        QFont titleFont = title.font();
        titleFont.setPixelSize(pixelSize);
        title.setFont(titleFont);
        qwtPlot->setAxisTitle(qwtPlot->yRight, title);
        emit yRightTitlePixelSizeChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

int SGQWTPlot::yRightTitlePixelSize()
{
    return qwtPlot->axisTitle(qwtPlot->yRight).font().pixelSize();
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

void SGQWTPlot::setTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->titlePixelSize()){
        QwtTextLabel* titleLabel = qwtPlot->titleLabel();
        QFont titleFont = titleLabel->font();
        titleFont.setPixelSize(pixelSize);
        titleLabel->setFont(titleFont);
        emit titlePixelSizeChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

int SGQWTPlot::titlePixelSize()
{
    return qwtPlot->titleLabel()->font().pixelSize();
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

        setYLeftAxisColor(foregroundColor_);
        setXAxisColor(foregroundColor_);
        setYRightAxisColor(foregroundColor_);

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
            qwtPlot->setAxisMaxMinor(qwtPlot->xBottom,10);
            qwtPlot->setAxisMaxMajor(qwtPlot->xBottom,10);
        } else {
            qwtPlot->setAxisScaleEngine(qwtPlot->xBottom, new QwtLinearScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->xBottom,5);
            qwtPlot->setAxisMaxMajor(qwtPlot->xBottom,5);
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
            qwtPlot->setAxisScaleEngine(qwtPlot->yRight, new QwtLogScaleEngine(10));
            qwtPlot->setAxisScaleEngine(qwtPlot->yLeft, new QwtLogScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->yLeft,10);
            qwtPlot->setAxisMaxMajor(qwtPlot->yLeft,10);
        } else {
            qwtPlot->setAxisScaleEngine(qwtPlot->yRight, new QwtLinearScaleEngine(10));
            qwtPlot->setAxisScaleEngine(qwtPlot->yLeft, new QwtLinearScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->yLeft,5);
            qwtPlot->setAxisMaxMajor(qwtPlot->yLeft,5);
        }
        emit yLogarithmicChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot :: setYRightAxisColor(QColor newColor)
{
    if (yRightAxisColor_ != newColor) {
        yRightAxisColor_ = newColor;
        QwtScaleWidget * qwtsw_ = qwtPlot->axisWidget(QwtPlot::yRight);
        QPalette palette = qwtsw_->palette();
        palette.setColor(QPalette::WindowText, yRightAxisColor_);	// for ticks
        palette.setColor(QPalette::Text, yRightAxisColor_);           //for  ticks' labels
        qwtsw_->setPalette(palette);

        emit yRightAxisColorChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot :: setYLeftAxisColor(QColor newColor)
{

    if (yLeftAxisColor_ != newColor) {
        yLeftAxisColor_ = newColor;
        QwtScaleWidget * qwtsw_ = qwtPlot->axisWidget(QwtPlot::yLeft);
        QPalette palette = qwtsw_->palette();
        palette.setColor(QPalette::WindowText, yLeftAxisColor_);	// for ticks
        palette.setColor(QPalette::Text, yLeftAxisColor_);           //for  ticks' labels
        qwtsw_->setPalette(palette);

        emit yLeftAxisColorChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot :: setXAxisColor(QColor newColor)
{
    if (xAxisColor_ != newColor) {
        xAxisColor_ = newColor;
        QwtScaleWidget * qwtsw_ = qwtPlot->axisWidget(QwtPlot::xBottom);
        QPalette palette = qwtsw_->palette();
        palette.setColor(QPalette::WindowText, xAxisColor_);	// for ticks
        palette.setColor(QPalette::Text, xAxisColor_);           //for  ticks' labels
        qwtsw_->setPalette(palette);

        emit xAxisColorChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQWTPlot :: insertLegend(bool legend)
{
    if(legend_ != legend) {
        legend_ = legend;
        if(legend) {
            qwtPlot->insertLegend(new QwtLegend(),QwtPlot::BottomLegend);
        }
        else {
            qwtPlot->insertLegend(0);
        }

        emit legendChanged();
        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQWTPlot :: legend()
{
    return legend_;
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

QPointF SGQWTPlot::mapToValueYRight(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yRight);
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

QPointF SGQWTPlot::mapToPositionYRight(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yRight);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xPos = xMap.transform(point.x()) + canvasRect.x();
    double yPos = yMap.transform(point.y()) + canvasRect.y();
    return QPointF(xPos, yPos);
}


/*-----------------------
    SGQWTPlotCurve Class
------------------------*/

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
        QwtText title = curve_->title().text();
        title.setColor(color);
        curve_->setTitle(title);
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

void SGQWTPlotCurve::setYAxisLeft(bool yleftAxis)
{
    if (yAxisLeft_ != yleftAxis){
        yAxisLeft_ = yleftAxis;
        if(!yleftAxis){
            curve_->setYAxis(QwtPlot::yRight);
        }
        if (autoUpdate_) {
            update();
        }
        emit yAxisLeftChanged();
    }
}

bool SGQWTPlotCurve::yAxisLeft()
{
    return yAxisLeft_;
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
    if(index < curveData_.count() && index > -1) {
        curveData_.remove(index);
        if (autoUpdate_) {
            update();
        }
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
        qCWarning(logCategoryQWTPlot) << "Index Invalid " << index << " return 0,0" ;
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

void SGQWTPlotCurve::setSymbol(int newStyle , QColor color , int penStyle , int size)
{
    curve_->setSymbol(new QwtSymbol(QwtSymbol::Style(newStyle),QBrush(color),QPen(penStyle),QSize(size,size)));

    if (autoUpdate_) {
        update();
    }
    return;
}

QPointF SGQWTPlotCurve::nearestPoint(QPointF point) 
{
     double smallDiff = MAX_DIFF;
     double diff;
     QPointF temp = QPointF(0,0);
     QPointF closest = temp;

     for (int i = 0; i < curveData_.count(); i++) {
         temp = curveData_.at(i);
         diff = abs(temp.x() - point.x());
         if (diff < smallDiff) {
             smallDiff = diff;
             closest = temp;
         }
     }
     return closest;
}

/*-----------------------
    SGQWTPlotCurveData Class
------------------------*/

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
