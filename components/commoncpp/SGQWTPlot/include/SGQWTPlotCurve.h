#pragma once

#include "SGQWTPlot.h"
#include "SGQWTPlotCurveData.h"

class SGQWTPlot;

class SGQWTPlotCurve : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGQWTPlotCurve)

    Q_PROPERTY(SGQWTPlot* graph READ graph WRITE setGraph NOTIFY graphChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool autoUpdate MEMBER autoUpdate_ NOTIFY autoUpdateChanged)
    Q_PROPERTY(bool yAxisLeft READ yAxisLeft WRITE setYAxisLeft NOTIFY yAxisLeftChanged)

public:
    SGQWTPlotCurve(QString name = "", QObject* parent = nullptr);
    virtual ~SGQWTPlotCurve();

    Q_INVOKABLE void append(double x, double y);
    Q_INVOKABLE void appendList(const QVariantList &list);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QPointF at(int index);
    Q_INVOKABLE int count();
    Q_INVOKABLE void shiftPoints(double offsetX, double offsetY);
    Q_INVOKABLE void update();
    Q_INVOKABLE void setSymbol(int newStyle, QColor color, int penStyle, int size);
    Q_INVOKABLE int closestXAxisPointIndex(double xVal);

protected:
    void setGraph(SGQWTPlot* graph);
    void unsetGraph();

signals:
    void graphChanged();
    void colorChanged();
    void nameChanged();
    void autoUpdateChanged();
    void yAxisLeftChanged();

private:
    friend class SGQWTPlot;

    QwtPlotCurve* curve_;
    QVector<QPointF> curveData_;
    SGQWTPlot* graph_ = nullptr;
    QwtPlot* plot_ = nullptr;
    bool autoUpdate_ = true;
    bool yAxisLeft_ = true;

    SGQWTPlot* graph();
    void setColor(QColor color);
    QColor color();
    void setName(QString name);
    QString name();
    bool yAxisLeft();
    void setYAxisLeft(bool yleftAxis);
};
