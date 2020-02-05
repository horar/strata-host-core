#ifndef SGQWTPLOT_H
#define SGQWTPLOT_H

#include <QtQuick>
#include <QPointF>
#include <QVector>

#include "logging/LoggingQtCategories.h"

#include <qwt/qwt_plot.h>
#include <qwt/qwt_plot_curve.h>
#include <qwt/qwt_plot_renderer.h>
#include <qwt/qwt_scale_map.h>
#include <qwt/qwt_series_data.h>
#include <qwt/qwt_scale_engine.h>
#include <qwt/qwt_scale_widget.h>
#include <qwt/qwt_plot_layout.h>

#include <QDebug>

//forward declaration
class SGQWTPlotCurve;

class SGQWTPlot : public QQuickPaintedItem
{
    Q_OBJECT
    Q_DISABLE_COPY(SGQWTPlot)

    Q_PROPERTY(double xMin READ xMin WRITE setXMin NOTIFY xMinChanged)
    Q_PROPERTY(double xMax READ xMax WRITE setXMax NOTIFY xMaxChanged)
    Q_PROPERTY(double yMin READ yMin WRITE setYMin NOTIFY yMinChanged)
    Q_PROPERTY(double yMax READ yMax WRITE setYMax NOTIFY yMaxChanged)
    Q_PROPERTY(QString xTitle READ xTitle WRITE setXTitle NOTIFY xTitleChanged)
    Q_PROPERTY(QString yTitle READ yTitle WRITE setYTitle NOTIFY yTitleChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(bool xLogarithmic MEMBER xLogarithmic_ WRITE setXLogarithmic NOTIFY xLogarithmicChanged)
    Q_PROPERTY(bool yLogarithmic MEMBER yLogarithmic_ WRITE setYLogarithmic NOTIFY yLogarithmicChanged)
    Q_PROPERTY(QColor backgroundColor MEMBER backgroundColor_ WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor MEMBER foregroundColor_ WRITE setForegroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(bool autoUpdate MEMBER autoUpdate_ NOTIFY autoUpdateChanged)
    Q_PROPERTY(int count READ getCount NOTIFY countChanged)

public:
    SGQWTPlot(QQuickItem* parent = nullptr);
    virtual ~SGQWTPlot();

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void update();
    Q_INVOKABLE void shiftXAxis(double offset);
    Q_INVOKABLE void shiftYAxis(double offset);
    Q_INVOKABLE void autoScaleXAxis();
    Q_INVOKABLE void autoScaleYAxis();
    Q_INVOKABLE SGQWTPlotCurve* createCurve(QString name);
    Q_INVOKABLE SGQWTPlotCurve* curve(int index);
    Q_INVOKABLE void removeCurve(SGQWTPlotCurve* curve);
    Q_INVOKABLE void removeCurve(int index);
    Q_INVOKABLE QPointF mapToValue(QPointF point);
    Q_INVOKABLE QPointF mapToPosition(QPointF point);

    void paint(QPainter* painter);
    void setXMin(double value);
    double xMin();
    void setXMax(double value);
    double xMax();
    void setYMin(double value);
    double yMin();
    void setYMax(double value);
    double yMax();
    QString xTitle();
    void setXTitle(QString title);
    QString yTitle();
    void setYTitle(QString title);
    QString title();
    void setTitle(QString title);
    void setXLogarithmic(bool logarithmic);
    void setYLogarithmic(bool logarithmic);
    void setBackgroundColor(QColor newColor);
    void setForegroundColor(QColor newColor);
    int getCount();

protected:
    QwtPlot* qwtPlot = nullptr;

    void updateCurveList();

signals:
    void xMinChanged();
    void xMaxChanged();
    void yMinChanged();
    void yMaxChanged();
    void xTitleChanged();
    void yTitleChanged();
    void titleChanged();
    void xLogarithmicChanged();
    void yLogarithmicChanged();
    void backgroundColorChanged();
    void foregroundColorChanged();
    void autoUpdateChanged();
    void countChanged();

private:
    friend class SGQWTPlotCurve;

    QList<SGQWTPlotCurve*> curves_;
    bool xLogarithmic_ = false;
    bool yLogarithmic_ = false;
    QColor backgroundColor_;
    QColor foregroundColor_ = "black";
    bool autoUpdate_ = true;

private slots:
    void updatePlotSize();
};






class SGQWTPlotCurve : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGQWTPlotCurve)

    Q_PROPERTY(SGQWTPlot* graph READ graph WRITE setGraph NOTIFY graphChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool autoUpdate MEMBER autoUpdate_ NOTIFY autoUpdateChanged)

public:
    SGQWTPlotCurve(QString name = "", QObject* parent = nullptr);
    virtual ~SGQWTPlotCurve();

    Q_INVOKABLE void append(double x, double y);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QPointF at(int index);
    Q_INVOKABLE int count();
    Q_INVOKABLE void shiftPoints(double offsetX, double offsetY);
    Q_INVOKABLE void update();

protected:
    void setGraph(SGQWTPlot* graph);
    void unsetGraph();

signals:
    void graphChanged();
    void colorChanged();
    void nameChanged();
    void autoUpdateChanged();

private:
    friend class SGQWTPlot;

    QwtPlotCurve* curve_;
    QVector<QPointF> curveData_;
    SGQWTPlot* graph_ = nullptr;
    QwtPlot* plot_ = nullptr;
    bool autoUpdate_ = true;

    SGQWTPlot* graph();
    void setColor(QColor color);
    QColor color();
    void setName(QString name);
    QString name();
};






class SGQWTPlotCurveData : public QwtSeriesData<QPointF>
{
public:
    SGQWTPlotCurveData(const QVector<QPointF> *container);

    // QwtSeriesData interface
    size_t size() const;
    QPointF sample(size_t i) const;
    QRectF boundingRect() const;

private:
      const QVector<QPointF>* container_;
};

#endif // SGQWTPLOT_H
