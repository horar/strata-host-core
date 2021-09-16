#pragma once

#include "SGQwtPlotCurve.h"

class SGQwtPlotCurveData : public QwtSeriesData<QPointF>
{
public:
    SGQwtPlotCurveData(const QVector<QPointF> *container);

    // QwtSeriesData interface
    size_t size() const;
    QPointF sample(size_t i) const;
    QRectF boundingRect() const;

private:
    const QVector<QPointF>* container_;
};
