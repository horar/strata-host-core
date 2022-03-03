/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

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
