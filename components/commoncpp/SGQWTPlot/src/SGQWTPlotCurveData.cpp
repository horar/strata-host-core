#include "SGQwtPlotCurveData.h"

SGQwtPlotCurveData::SGQwtPlotCurveData(const QVector<QPointF> *container) : container_(container)
{
}

size_t SGQwtPlotCurveData::size() const
{
    return static_cast<size_t>(container_->size());
}

QPointF SGQwtPlotCurveData::sample(size_t i) const
{
    return container_->at(static_cast<int>(i));
}

QRectF SGQwtPlotCurveData::boundingRect() const
{
    return qwtBoundingRect(*this);
}
