#pragma once

#include "SGQWTPlotCurve.h"

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
