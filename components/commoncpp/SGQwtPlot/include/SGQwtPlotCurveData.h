/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
