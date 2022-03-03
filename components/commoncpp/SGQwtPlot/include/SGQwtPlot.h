/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QtQuick>
#include <QPointF>
#include <QVector>

#include <qwt/qwt_plot.h>
#include <qwt/qwt_plot_curve.h>
#include <qwt/qwt_plot_renderer.h>
#include <qwt/qwt_scale_map.h>
#include <qwt/qwt_series_data.h>
#include <qwt/qwt_scale_engine.h>
#include <qwt/qwt_scale_widget.h>
#include <qwt/qwt_plot_layout.h>
#include <qwt/qwt_text_label.h>
#include <qwt/qwt_plot_grid.h>
#include <qwt/qwt_symbol.h>
#include <qwt/qwt_legend.h>

#include "SGQwtPlotCurve.h"

class SGQwtPlotCurve;

class SGQwtPlot : public QQuickPaintedItem
{
    Q_OBJECT
    Q_DISABLE_COPY(SGQwtPlot)

    Q_PROPERTY(double xMin READ xMin WRITE setXMin NOTIFY xMinChanged)
    Q_PROPERTY(double xMax READ xMax WRITE setXMax NOTIFY xMaxChanged)
    Q_PROPERTY(double yMin READ yMin WRITE setYMin NOTIFY yMinChanged)
    Q_PROPERTY(double yMax READ yMax WRITE setYMax NOTIFY yMaxChanged)
    Q_PROPERTY(double yRightMin READ yRightMin WRITE setYRightMin NOTIFY yRightMinChanged)
    Q_PROPERTY(double yRightMax READ yRightMax WRITE setYRightMax NOTIFY yRightMaxChanged)
    Q_PROPERTY(QString xTitle READ xTitle WRITE setXTitle NOTIFY xTitleChanged)
    Q_PROPERTY(int xTitlePixelSize READ xTitlePixelSize WRITE setXTitlePixelSize NOTIFY xTitlePixelSizeChanged)
    Q_PROPERTY(QString yTitle READ yTitle WRITE setYTitle NOTIFY yTitleChanged)
    Q_PROPERTY(int yTitlePixelSize READ yTitlePixelSize WRITE setYTitlePixelSize NOTIFY yTitlePixelSizeChanged)
    Q_PROPERTY(QString yRightTitle READ  yRightTitle WRITE setYRightTitle NOTIFY yRightTitleChanged)
    Q_PROPERTY(int yRightTitlePixelSize READ yRightTitlePixelSize WRITE setYRightTitlePixelSize NOTIFY yRightTitlePixelSizeChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(int titlePixelSize READ titlePixelSize WRITE setTitlePixelSize NOTIFY titlePixelSizeChanged)
    Q_PROPERTY(bool xLogarithmic MEMBER xLogarithmic_ WRITE setXLogarithmic NOTIFY xLogarithmicChanged)
    Q_PROPERTY(bool yLogarithmic MEMBER yLogarithmic_ WRITE setYLogarithmic NOTIFY yLogarithmicChanged)
    Q_PROPERTY(QColor backgroundColor MEMBER backgroundColor_ WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor MEMBER foregroundColor_ WRITE setForegroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(bool autoUpdate MEMBER autoUpdate_ NOTIFY autoUpdateChanged)
    Q_PROPERTY(int count READ getCount NOTIFY countChanged)
    Q_PROPERTY(bool xGrid READ xGrid WRITE setXGrid NOTIFY xGridChanged)
    Q_PROPERTY(bool yGrid READ yGrid WRITE setYGrid NOTIFY yGridChanged)
    Q_PROPERTY(bool xMinorGrid READ xMinorGrid WRITE setXMinorGrid NOTIFY xMinorGridChanged)
    Q_PROPERTY(bool yMinorGrid READ yMinorGrid WRITE setYMinorGrid NOTIFY yMinorGridChanged)
    Q_PROPERTY(QColor gridColor MEMBER gridColor_ WRITE setGridColor NOTIFY gridColorChanged)
    Q_PROPERTY(bool yRightVisible READ yRightVisible WRITE setYRightVisible NOTIFY yRightVisibleChanged)
    Q_PROPERTY(QColor yRightAxisColor MEMBER yRightAxisColor_ WRITE setYRightAxisColor NOTIFY yRightAxisColorChanged)
    Q_PROPERTY(QColor yLeftAxisColor MEMBER yLeftAxisColor_ WRITE setYLeftAxisColor NOTIFY yLeftAxisColorChanged)
    Q_PROPERTY(QColor xAxisColor MEMBER xAxisColor_ WRITE setXAxisColor NOTIFY xAxisColorChanged)
    Q_PROPERTY(bool legend READ legend WRITE insertLegend NOTIFY legendChanged)

public:
    SGQwtPlot(QQuickItem* parent = nullptr);
    virtual ~SGQwtPlot();

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void update();
    Q_INVOKABLE void shiftXAxis(double offset);
    Q_INVOKABLE void shiftYAxis(double offset);
    Q_INVOKABLE void shiftYAxisRight(double offset);
    Q_INVOKABLE void autoScaleXAxis();
    Q_INVOKABLE void autoScaleYAxis();
    Q_INVOKABLE SGQwtPlotCurve* createCurve(QString name);
    Q_INVOKABLE SGQwtPlotCurve* curve(int index);
    Q_INVOKABLE void removeCurve(SGQwtPlotCurve* curve);
    Q_INVOKABLE void removeCurve(int index);
    Q_INVOKABLE QPointF mapToValue(QPointF point);
    Q_INVOKABLE QPointF mapToValueYRight(QPointF point);
    Q_INVOKABLE QPointF mapToPosition(QPointF point);
    Q_INVOKABLE QPointF mapToPositionYRight(QPointF point);

    void paint(QPainter* painter);
    void setXMin(double value);
    double xMin();
    void setXMax(double value);
    double xMax();
    void setYMin(double value);
    double yMin();
    void setYMax(double value);
    double yMax();
    void setYRightMin(double value);
    double yRightMin();
    void setYRightMax(double value);
    double yRightMax();
    QString xTitle();
    void setXTitle(QString title);
    void setXTitlePixelSize(int pixelSize);
    int xTitlePixelSize();
    QString yTitle();
    void setYTitle(QString title);
    void setYTitlePixelSize(int pixelSize);
    int yTitlePixelSize();
    QString yRightTitle();
    void setYRightTitle(QString title);
    void setYRightTitlePixelSize(int pixelSize);
    int yRightTitlePixelSize();
    QString title();
    void setTitle(QString title);
    void setTitlePixelSize(int pixelSize);
    int titlePixelSize();
    void setXLogarithmic(bool logarithmic);
    void setYLogarithmic(bool logarithmic);
    void setBackgroundColor(QColor newColor);
    void setForegroundColor(QColor newColor);
    int getCount();
    void setXGrid(bool showGrid);
    bool xGrid();
    void setYGrid(bool showGrid);
    bool yGrid();
    void setXMinorGrid(bool showGrid);
    bool xMinorGrid();
    void setYMinorGrid(bool showGrid);
    bool yMinorGrid();
    void setGridColor(QColor newColor);
    void setYRightVisible(bool showYRightAxis);
    bool yRightVisible();
    void setYRightAxisColor(QColor newColor);
    void setYLeftAxisColor(QColor newColor);
    void setXAxisColor(QColor newColor);
    void insertLegend(bool showLegend);
    bool legend();

protected:
    QwtPlot* qwtPlot = nullptr;
    void updateCurveList();

signals:
    void xMinChanged();
    void xMaxChanged();
    void yMinChanged();
    void yMaxChanged();
    void xTitleChanged();
    void xTitlePixelSizeChanged();
    void yTitleChanged();
    void yTitlePixelSizeChanged();
    void yRightTitleChanged();
    void yRightTitlePixelSizeChanged();
    void titleChanged();
    void titlePixelSizeChanged();
    void xLogarithmicChanged();
    void yLogarithmicChanged();
    void backgroundColorChanged();
    void foregroundColorChanged();
    void autoUpdateChanged();
    void countChanged();
    void xGridChanged();
    void yGridChanged();
    void xMinorGridChanged();
    void yMinorGridChanged();
    void gridColorChanged();
    void yRightVisibleChanged();
    void yRightMinChanged();
    void yRightMaxChanged();
    void yRightAxisColorChanged();
    void yLeftAxisColorChanged();
    void xAxisColorChanged();
    void legendChanged();

private:
    friend class SGQwtPlotCurve;

    QList<SGQwtPlotCurve*> curves_;
    QwtPlotGrid * qwtGrid_  = nullptr;

    bool xLogarithmic_ = false;
    bool yLogarithmic_ = false;
    bool autoUpdate_ = true;
    bool xGrid_ = false;
    bool yGrid_ = false;
    bool xMinorGrid_ = false;
    bool yMinorGrid_ = false;
    bool yRightVisible_ = false;
    bool legend_ = false;

    QColor backgroundColor_;
    QColor foregroundColor_;
    QColor gridColor_;
    QColor yRightAxisColor_;
    QColor yLeftAxisColor_;
    QColor xAxisColor_;

private slots:
    void updatePlotSize();
};
