#ifndef QMLPLOT_H
#define QMLPLOT_H

#include <QtQuick>

#include <qwt/qwt_plot.h>
#include <qwt/qwt_plot_curve.h>
#include <qwt/qwt_series_data.h>

#include <chrono>
#include <QPointF>
#include <QVector>


class QwtQuick2Plot : public QQuickPaintedItem
{
    Q_OBJECT

public:
    QwtQuick2Plot(QQuickItem* parent = nullptr);
    virtual ~QwtQuick2Plot();

    void paint(QPainter* painter);

    Q_INVOKABLE void initQwtPlot();
    Q_INVOKABLE void addPoint(QPointF point);
//    Q_INVOKABLE void clearPoints();
    Q_INVOKABLE void setAxisScaleTest();
    Q_INVOKABLE void movePoints();
    Q_INVOKABLE void replotAndUpdate();
    Q_INVOKABLE int pointCount();
    Q_INVOKABLE void setData(double dataPoint){
        data_ = dataPoint;
    }
    Q_INVOKABLE void startTime(int milliseconds);
    Q_INVOKABLE void stopTime();
    Q_INVOKABLE void clearPoints();

    QColor backgroundColor = "transparent";

protected:
    void routeMouseEvents(QMouseEvent* event);
    void routeWheelEvents(QWheelEvent* event);

    virtual void mousePressEvent(QMouseEvent* event);
    virtual void mouseReleaseEvent(QMouseEvent* event);
    virtual void mouseMoveEvent(QMouseEvent* event);
    virtual void mouseDoubleClickEvent(QMouseEvent* event);
    virtual void wheelEvent(QWheelEvent *event);

    virtual void timerEvent(QTimerEvent *event);

private:
    QwtPlot*         m_qwtPlot;
    QwtPlotCurve*    m_curve1;
    QVector<QPointF> m_curve1_data;
    int              m_timerId;
    double           data_;
    int              m_point_count_;
    std::chrono::system_clock::time_point start_time_;
    std::chrono::system_clock::time_point now_;

//    void replotAndUpdate();

private slots:
    void updatePlotSize();

};



class PlotData : public QwtSeriesData<QPointF>
{
public:
    PlotData(const QVector<QPointF> *container);

private:
      const QVector<QPointF>* _container;

      // QwtSeriesData interface
public:
      size_t size() const;
      QPointF sample(size_t i) const;
      QRectF boundingRect() const;
};




#endif // QMLPLOT_H
