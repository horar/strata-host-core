#pragma once

#include "SGQwtPlot.h"
#include "SGQwtPlotCurveData.h"

class SGQwtPlot;

class SGQwtPlotCurve : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGQwtPlotCurve)

    Q_PROPERTY(SGQwtPlot* graph READ graph WRITE setGraph NOTIFY graphChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool autoUpdate MEMBER autoUpdate_ NOTIFY autoUpdateChanged)
    Q_PROPERTY(bool yAxisLeft READ yAxisLeft WRITE setYAxisLeft NOTIFY yAxisLeftChanged)

public:
    SGQwtPlotCurve(QString name = "", QObject* parent = nullptr);
    virtual ~SGQwtPlotCurve();

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
    void setGraph(SGQwtPlot* graph);
    void unsetGraph();

signals:
    void graphChanged();
    void colorChanged();
    void nameChanged();
    void autoUpdateChanged();
    void yAxisLeftChanged();

private:
    friend class SGQwtPlot;

    QwtPlotCurve* curve_;
    QVector<QPointF> curveData_;
    SGQwtPlot* graph_ = nullptr;
    QwtPlot* plot_ = nullptr;
    bool autoUpdate_ = true;
    bool yAxisLeft_ = true;

    SGQwtPlot* graph();
    void setColor(QColor color);
    QColor color();
    void setName(QString name);
    QString name();
    bool yAxisLeft();
    void setYAxisLeft(bool yleftAxis);
};
