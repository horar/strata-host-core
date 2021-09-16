#include "SGQWTPlotCurveData.h"

SGQWTPlotCurveData::SGQWTPlotCurveData(const QVector<QPointF> *container) : container_(container)
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
