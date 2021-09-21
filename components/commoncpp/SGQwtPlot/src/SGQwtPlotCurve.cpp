#include "SGQwtPlotCurve.h"
#include "logging/LoggingQtCategories.h"

SGQwtPlotCurve::SGQwtPlotCurve(QString name, QObject* parent) : QObject(parent)
{
    curve_ = new QwtPlotCurve(name);
    curve_->setStyle(QwtPlotCurve::Lines);
    curve_->setRenderHint(QwtPlotItem::RenderAntialiased);
    curve_->setData(new SGQwtPlotCurveData(&curveData_));
    curve_->setPaintAttribute(QwtPlotCurve::FilterPoints, true);
    curve_->setItemAttribute(QwtPlotItem::AutoScale, true);
}

SGQwtPlotCurve::~SGQwtPlotCurve()
{
    // QwtPlot class deletes attached QwtPlotItems (i.e. curve_)
}

void SGQwtPlotCurve::setGraph(SGQwtPlot *graph)
{
    if (graph_ != graph) {
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

void SGQwtPlotCurve::unsetGraph()
{
    curve_->detach();
    if (autoUpdate_) {
        update();
    }
    plot_ = nullptr;
    graph_ = nullptr;
}

SGQwtPlot* SGQwtPlotCurve::graph()
{
    return graph_;
}

void SGQwtPlotCurve::setName(QString name)
{
    if (name != this->name()) {
        curve_->setTitle(name);
        if (autoUpdate_) {
            update();
        }
        emit nameChanged();
    }
}

QString SGQwtPlotCurve::name()
{
    return curve_->title().text();
}

void SGQwtPlotCurve::setColor(QColor color)
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

QColor SGQwtPlotCurve::color()
{
    return curve_->pen().color();
}

void SGQwtPlotCurve::setYAxisLeft(bool yleftAxis)
{
    if (yAxisLeft_ != yleftAxis) {
        yAxisLeft_ = yleftAxis;
        if (!yleftAxis) {
            curve_->setYAxis(QwtPlot::yRight);
        }
        if (autoUpdate_) {
            update();
        }
        emit yAxisLeftChanged();
    }
}

bool SGQwtPlotCurve::yAxisLeft()
{
    return yAxisLeft_;
}

void SGQwtPlotCurve::update()
{
    if (graph_ != nullptr) {
        graph_->update();
    }
}

void SGQwtPlotCurve::append(double x, double y)
{
    curveData_.append(QPointF(x, y));
    if (autoUpdate_) {
        update();
    }
}

void SGQwtPlotCurve::appendList(const QVariantList &list)
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

void SGQwtPlotCurve::remove(int index)
{
    if(index < curveData_.count() && index > -1) {
        curveData_.remove(index);
        if (autoUpdate_) {
            update();
        }
    }
}

void SGQwtPlotCurve::clear()
{
    curveData_.clear();
    if (autoUpdate_) {
        update();
    }
}

QPointF SGQwtPlotCurve::at(int index)
{
    if (index < curveData_.count()) {
        return curveData_[index];
    } else {
        qCWarning(logCategoryQWTPlot) << "Index Invalid" << index << "return 0,0";
        return QPointF(0, 0);
    }
}

int SGQwtPlotCurve::count()
{
    return curveData_.count();
}

void SGQwtPlotCurve::shiftPoints(double offsetX, double offsetY)
{
    for (int i = 0; i < curveData_.length(); i++) {
        curveData_[i].setX(curveData_[i].x() + (offsetX));
        curveData_[i].setY(curveData_[i].y() + (offsetY));
    }
    if (autoUpdate_) {
        update();
    }
}

void SGQwtPlotCurve::setSymbol(int newStyle, QColor color, int penStyle, int size)
{
    curve_->setSymbol(new QwtSymbol(QwtSymbol::Style(newStyle), QBrush(color), QPen(penStyle), QSize(size, size)));

    if (autoUpdate_) {
        update();
    }
}

// Given any value from the X axis of the graph, find the point in the curve with the nearest X value and return its index
int SGQwtPlotCurve::closestXAxisPointIndex(double xVal) {
    double diff;
    QPointF currentPoint = QPointF(0,0);

    // error check to ensure there is a curve with points
    if (curveData_.count() == 0) {
        return -1; // return -1 if there is no curve
    }

    int right = curveData_.count() - 1;
    int left = 0;
    int mid = 0;

    // loop until there are only two points remaining
    // binary search
    while (right - left > 1) {
        mid = (left + right) / 2;
        currentPoint = curveData_.at(mid);
        diff = (currentPoint.x() - xVal);
        if (diff == 0) {
            return mid;
        } else if (diff < 0) {
            left = mid;
        } else {
            right = mid;
        }
    }

    // once only two points remain, determines which is the mouse closer to
    QPointF leftVal = curveData_.at(left);
    QPointF rightVal = curveData_.at(right);
    double lDiff = abs(leftVal.x() - xVal);
    double rDiff = abs(rightVal.x() - xVal);

    if (lDiff < rDiff) {
        return left;
    } else {
        return right;
    }
}