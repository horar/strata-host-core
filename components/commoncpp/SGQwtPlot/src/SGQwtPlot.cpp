/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGQwtPlot.h"
#include "logging/LoggingQtCategories.h"

SGQwtPlot::SGQwtPlot(QQuickItem* parent) : QQuickPaintedItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, true);
    setAcceptedMouseButtons(Qt::AllButtons);

    connect(this, &QQuickPaintedItem::widthChanged, this, &SGQwtPlot::updatePlotSize);
    connect(this, &QQuickPaintedItem::heightChanged, this, &SGQwtPlot::updatePlotSize);

    qwtPlot = new QwtPlot();
    qwtGrid_ = new QwtPlotGrid();

    setBackgroundColor("white");
    setForegroundColor("black");

    qwtGrid_->attach(qwtPlot);
    //Setting the default values for x,y axes and color of grid lines.
    qwtGrid_->enableX(xGrid_);
    qwtGrid_->enableY(yGrid_);
    qwtGrid_->enableXMin(xMinorGrid_);
    qwtGrid_->enableYMin(yMinorGrid_);
    setGridColor("lightgrey");
}

SGQwtPlot::~SGQwtPlot()
{
    delete qwtGrid_;
    qwtGrid_ = nullptr;

    delete qwtPlot;
    qwtPlot = nullptr;
}

void SGQwtPlot::paint(QPainter* painter)
{
    if (qwtPlot != nullptr) {
        QPixmap picture(boundingRect().size().toSize());

        QwtPlotRenderer renderer;
        renderer.renderTo(qwtPlot, picture);

        painter->drawPixmap(QPoint(), picture);
    }
}

void SGQwtPlot::initialize()
{
    // after replot() we need to call update() - so disable auto replot
    qwtPlot->setAutoReplot(false);
    updatePlotSize();
    update();
}

void SGQwtPlot::update()
{
    qwtPlot->replot();
    QQuickPaintedItem::update();
}

void SGQwtPlot::shiftXAxis(double offset)
{
    double xMin = this->xMin() + offset;
    double xMax = this->xMax() + offset;
    qwtPlot->setAxisScale( qwtPlot->xBottom, xMin, xMax);

    if (autoUpdate_) {
        update();
    }
}

void SGQwtPlot::shiftYAxis(double offset)
{
    double yMin = this->yMin() + offset;
    double yMax = this->yMax() + offset;
    qwtPlot->setAxisScale(qwtPlot->yLeft, yMin, yMax);

    if (autoUpdate_) {
        update();
    }
}

void SGQwtPlot::shiftYAxisRight(double offset)
{
    double yMinRight = this->yRightMin() + offset;
    double yMaxRight = this->yRightMax() + offset;
    qwtPlot->setAxisScale(qwtPlot->yRight, yMinRight, yMaxRight);

    if (autoUpdate_) {
        update();
    }
}

bool SGQwtPlot::yRightVisible()
{
    return yRightVisible_;
}

void SGQwtPlot::setYRightVisible(bool showYRightAxis)
{
    if (yRightVisible_ != showYRightAxis) {
        yRightVisible_ = showYRightAxis;
        qwtPlot->enableAxis(qwtPlot->yRight,showYRightAxis);
        emit yRightVisibleChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::autoScaleXAxis()
{
    qwtPlot->setAxisAutoScale(qwtPlot->xBottom);
    emit xMinChanged();
    emit xMaxChanged();

    if (autoUpdate_) {
        update();
    }
}


void SGQwtPlot::autoScaleYAxis()
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

SGQwtPlotCurve* SGQwtPlot::createCurve(QString name)
{
    SGQwtPlotCurve* curve = new SGQwtPlotCurve(name);
    curve->setGraph(this);
    return curve;
}

SGQwtPlotCurve* SGQwtPlot::curve(int index)
{
    if (index >= curves_.length() || index < 0) {
        qCWarning(lcQWTPlot) << "Index out of range:" << index;
        return nullptr;
    }
    return curves_[index];
}

void SGQwtPlot::removeCurve(SGQwtPlotCurve* curve)
{
    curve->unsetGraph();
    delete curve;
    updateCurveList();
}

void SGQwtPlot::removeCurve(int index)
{
    SGQwtPlotCurve *curve = SGQwtPlot::curve(index);
    if (curve != nullptr) {
        removeCurve(curve);
    }
}

int SGQwtPlot::getCount()
{
    return curves_.count();
}

void SGQwtPlot::setXGrid(bool showGrid)
{
    if (xGrid_ != showGrid) {
        xGrid_ = showGrid;
        qwtGrid_->enableX(xGrid_);
        emit xGridChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQwtPlot::xGrid()
{
    return xGrid_;
}

void SGQwtPlot::setYGrid(bool showGrid)
{
    if (yGrid_ != showGrid) {
        yGrid_ = showGrid;
        qwtGrid_->enableY(yGrid_);
        emit yGridChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQwtPlot::yGrid()
{
    return yGrid_;
}

void SGQwtPlot::setXMinorGrid(bool showGrid)
{
    if (xMinorGrid_ != showGrid) {
        xMinorGrid_ = showGrid;
        setXGrid(xMinorGrid_);
        qwtGrid_->enableXMin(xMinorGrid_);
        emit xMinorGridChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQwtPlot::xMinorGrid()
{
    return xMinorGrid_;
}

void SGQwtPlot::setYMinorGrid(bool showGrid)
{
    if (yMinorGrid_ != showGrid) {
        yMinorGrid_ = showGrid;
        setYGrid(yMinorGrid_);
        qwtGrid_->enableYMin(yMinorGrid_);
        emit yMinorGridChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQwtPlot::yMinorGrid()
{
    return yMinorGrid_;
}

void SGQwtPlot::setGridColor(QColor newColor)
{
    if (gridColor_ != newColor) {
        gridColor_ = newColor;
        qwtGrid_->setPen(QPen(gridColor_, 0, Qt::DotLine));
        emit gridColorChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setXMin(double value)
{
    qwtPlot->setAxisScale( qwtPlot->xBottom, value, xMax());
    emit xMinChanged();

    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQwtPlot::xMin()
{
    return qwtPlot->axisScaleDiv(qwtPlot->xBottom).lowerBound();
}

void SGQwtPlot::setXMax(double value)
{
    qwtPlot->setAxisScale( qwtPlot->xBottom, xMin(), value);
    emit xMaxChanged();

    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQwtPlot::xMax()
{
    return qwtPlot->axisScaleDiv(qwtPlot->xBottom).upperBound();
}

void SGQwtPlot::setYMin(double value)
{
    qwtPlot->setAxisScale(qwtPlot->yLeft, value, yMax());
    emit yMinChanged();

    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQwtPlot::yMin()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yLeft).lowerBound();
}

void SGQwtPlot::setYMax(double value)
{
    qwtPlot->setAxisScale(qwtPlot->yLeft, yMin(), value);
    emit yMaxChanged();

    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQwtPlot::yMax()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yLeft).upperBound();
}

void SGQwtPlot::setYRightMin(double value)
{
    qwtPlot->setAxisScale(qwtPlot->yRight, value, yRightMax());
    emit yRightMinChanged();

    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQwtPlot::yRightMin()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yRight).lowerBound();
}

void SGQwtPlot::setYRightMax(double value)
{
    qwtPlot->setAxisScale(qwtPlot->yRight, yRightMin(), value);
    emit yRightMaxChanged();

    if (autoUpdate_) {
        update();
    } else {
        qwtPlot->replot();
    }
}

double SGQwtPlot::yRightMax()
{
    return qwtPlot->axisScaleDiv(qwtPlot->yRight).upperBound();
}

QString SGQwtPlot::xTitle()
{
    return qwtPlot->axisTitle(qwtPlot->xBottom).text();
}

void SGQwtPlot::setXTitle(QString title)
{
    if (title != xTitle()){
        qwtPlot->setAxisTitle(qwtPlot->xBottom, title);
        emit xTitleChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setXTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->xTitlePixelSize()) {
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

int SGQwtPlot::xTitlePixelSize()
{
    return qwtPlot->axisTitle(qwtPlot->xBottom).font().pixelSize();
}

QString SGQwtPlot::yTitle()
{
    return qwtPlot->axisTitle(qwtPlot->yLeft).text();
}

void SGQwtPlot::setYTitle(QString title)
{
    if (title != yTitle()) {
        qwtPlot->setAxisTitle(qwtPlot->yLeft, title);
        emit yTitleChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setYTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->yTitlePixelSize()) {
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

int SGQwtPlot::yTitlePixelSize()
{
    return qwtPlot->axisTitle(qwtPlot->yLeft).font().pixelSize();
}

QString SGQwtPlot::yRightTitle()
{
    return qwtPlot->axisTitle(qwtPlot->yRight).text();
}

void SGQwtPlot::setYRightTitle(QString title)
{
    if (title != yRightTitle()) {
        qwtPlot->setAxisTitle(qwtPlot->yRight, title);
        emit yRightTitleChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setYRightTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->yRightTitlePixelSize()) {
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

int SGQwtPlot::yRightTitlePixelSize()
{
    return qwtPlot->axisTitle(qwtPlot->yRight).font().pixelSize();
}

QString SGQwtPlot::title()
{
    return qwtPlot->title().text();
}

void SGQwtPlot::setTitle(QString title)
{
    if (title != this->title()){
        qwtPlot->setTitle(title);
        emit titleChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setTitlePixelSize(int pixelSize)
{
    if (pixelSize != this->titlePixelSize()) {
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

int SGQwtPlot::titlePixelSize()
{
    return qwtPlot->titleLabel()->font().pixelSize();
}

void SGQwtPlot::setBackgroundColor(QColor newColor)
{
    if (backgroundColor_ != newColor) {
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

void SGQwtPlot::setForegroundColor(QColor newColor)
{
    if (foregroundColor_ != newColor) {
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

void SGQwtPlot::setXLogarithmic(bool logarithmic)
{
    if (logarithmic != xLogarithmic_) {
        xLogarithmic_ = logarithmic;
        if (xLogarithmic_) {
            qwtPlot->setAxisScaleEngine(qwtPlot->xBottom, new QwtLogScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->xBottom, 10);
            qwtPlot->setAxisMaxMajor(qwtPlot->xBottom, 10);
        } else {
            qwtPlot->setAxisScaleEngine(qwtPlot->xBottom, new QwtLinearScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->xBottom, 5);
            qwtPlot->setAxisMaxMajor(qwtPlot->xBottom, 5);
        }
        emit xLogarithmicChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setYLogarithmic(bool logarithmic)
{
    if (logarithmic != yLogarithmic_) {
        yLogarithmic_ = logarithmic;
        if (yLogarithmic_) {
            qwtPlot->setAxisScaleEngine(qwtPlot->yRight, new QwtLogScaleEngine(10));
            qwtPlot->setAxisScaleEngine(qwtPlot->yLeft, new QwtLogScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->yLeft, 10);
            qwtPlot->setAxisMaxMajor(qwtPlot->yLeft, 10);
        } else {
            qwtPlot->setAxisScaleEngine(qwtPlot->yRight, new QwtLinearScaleEngine(10));
            qwtPlot->setAxisScaleEngine(qwtPlot->yLeft, new QwtLinearScaleEngine(10));
            qwtPlot->setAxisMaxMinor(qwtPlot->yLeft, 5);
            qwtPlot->setAxisMaxMajor(qwtPlot->yLeft, 5);
        }
        emit yLogarithmicChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setYRightAxisColor(QColor newColor)
{
    if (yRightAxisColor_ != newColor) {
        yRightAxisColor_ = newColor;
        QwtScaleWidget *qwtsw_ = qwtPlot->axisWidget(QwtPlot::yRight);
        QPalette palette = qwtsw_->palette();
        palette.setColor(QPalette::WindowText, yRightAxisColor_); // for ticks
        palette.setColor(QPalette::Text, yRightAxisColor_);       // for ticks' labels
        qwtsw_->setPalette(palette);
        emit yRightAxisColorChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setYLeftAxisColor(QColor newColor)
{
    if (yLeftAxisColor_ != newColor) {
        yLeftAxisColor_ = newColor;
        QwtScaleWidget *qwtsw_ = qwtPlot->axisWidget(QwtPlot::yLeft);
        QPalette palette = qwtsw_->palette();
        palette.setColor(QPalette::WindowText, yLeftAxisColor_); // for ticks
        palette.setColor(QPalette::Text, yLeftAxisColor_);       // for ticks' labels
        qwtsw_->setPalette(palette);
        emit yLeftAxisColorChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::setXAxisColor(QColor newColor)
{
    if (xAxisColor_ != newColor) {
        xAxisColor_ = newColor;
        QwtScaleWidget *qwtsw_ = qwtPlot->axisWidget(QwtPlot::xBottom);
        QPalette palette = qwtsw_->palette();
        palette.setColor(QPalette::WindowText, xAxisColor_); // for ticks
        palette.setColor(QPalette::Text, xAxisColor_);       // for ticks' labels
        qwtsw_->setPalette(palette);
        emit xAxisColorChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlot::insertLegend(bool legend)
{
    if (legend_ != legend) {
        legend_ = legend;
        if (legend) {
            qwtPlot->insertLegend(new QwtLegend(), QwtPlot::BottomLegend);
        } else {
            qwtPlot->insertLegend(0);
        }
        emit legendChanged();

        if (autoUpdate_) {
            update();
        }
    }
}

bool SGQwtPlot::legend()
{
    return legend_;
}

void SGQwtPlot::updatePlotSize()
{
    if (qwtPlot != nullptr) {
        qwtPlot->setGeometry(0, 0, static_cast<int>(width()), static_cast<int>(height()));
    }
}

void SGQwtPlot::updateCurveList()
{
    curves_ = findChildren<SGQwtPlotCurve*>();
    emit countChanged();
}

QPointF SGQwtPlot::mapToValue(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yLeft);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xValue = xMap.invTransform(point.x() - canvasRect.x());
    double yValue = yMap.invTransform(point.y() - canvasRect.y());
    return QPointF(xValue, yValue);
}

QPointF SGQwtPlot::mapToValueYRight(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yRight);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xValue = xMap.invTransform(point.x() - canvasRect.x());
    double yValue = yMap.invTransform(point.y() - canvasRect.y());
    return QPointF(xValue, yValue);
}

QPointF SGQwtPlot::mapToPosition(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yLeft);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xPos = xMap.transform(point.x()) + canvasRect.x();
    double yPos = yMap.transform(point.y()) + canvasRect.y();
    return QPointF(xPos, yPos);
}

QPointF SGQwtPlot::mapToPositionYRight(QPointF point)
{
    qwtPlot->updateLayout();
    QwtScaleMap xMap = qwtPlot->canvasMap(qwtPlot->xBottom);
    QwtScaleMap yMap = qwtPlot->canvasMap(qwtPlot->yRight);
    QRectF canvasRect = qwtPlot->plotLayout()->canvasRect();
    double xPos = xMap.transform(point.x()) + canvasRect.x();
    double yPos = yMap.transform(point.y()) + canvasRect.y();
    return QPointF(xPos, yPos);
}
