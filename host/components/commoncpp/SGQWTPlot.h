#ifndef SGQWTPLOT_H
#define SGQWTPLOT_H

#include <QtQuick>

#include <qwt/qwt_plot.h>
#include <qwt/qwt_plot_curve.h>
#include <qwt/qwt_plot_renderer.h>
#include <qwt/qwt_series_data.h>
#include <qwt/qwt_scale_engine.h>

#include <chrono>
#include <QPointF>
#include <QVector>

#include <QDebug>

//forward declaration
class SGQWTPlotCurve;

class SGQWTPlot : public QQuickPaintedItem
{
    Q_OBJECT

public:
    SGQWTPlot(QQuickItem* parent = nullptr);
    virtual ~SGQWTPlot();

    void paint(QPainter* painter);

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void update();
    Q_INVOKABLE void shiftXAxis(double offset);
    Q_INVOKABLE void shiftYAxis(double offset);
    Q_INVOKABLE void autoScaleXAxis();
    Q_INVOKABLE void autoScaleYAxis();
    Q_INVOKABLE SGQWTPlotCurve* createCurve(QString name);
    Q_INVOKABLE SGQWTPlotCurve* curve(int index);
    Q_INVOKABLE void removeCurve(SGQWTPlotCurve* curve);
    Q_INVOKABLE int count();

    Q_PROPERTY(double xMin MEMBER m_x_min_ WRITE setXMin_ NOTIFY xMinChanged)
    Q_PROPERTY(double xMax MEMBER m_x_max_ WRITE setXMax_ NOTIFY xMaxChanged)
    Q_PROPERTY(double yMin MEMBER m_y_min_ WRITE setYMin_ NOTIFY yMinChanged)
    Q_PROPERTY(double yMax MEMBER m_y_max_ WRITE setYMax_ NOTIFY yMaxChanged)
    Q_PROPERTY(QString xTitle MEMBER m_x_title_ WRITE setXTitle_ NOTIFY xTitleChanged)
    Q_PROPERTY(QString yTitle MEMBER m_y_title_ WRITE setYTitle_ NOTIFY yTitleChanged)
    Q_PROPERTY(bool xLogarithmic MEMBER m_x_logarithmic_ WRITE setXLogarithmic_ NOTIFY xLogarithmicChanged)
    Q_PROPERTY(bool yLogarithmic MEMBER m_y_logarithmic_ WRITE setYLogarithmic_ NOTIFY yLogarithmicChanged)
    Q_PROPERTY(QColor backgroundColor MEMBER m_background_color_ WRITE setBackgroundColor_ NOTIFY backgroundColorChanged)

protected:
    // are protected members accessible from instances wrapping this in qml? like from login.qml https://stackoverflow.com/questions/224966/private-and-protected-members-c
    void routeMouseEvents(QMouseEvent* event);
    void routeWheelEvents(QWheelEvent* event);

    virtual void mousePressEvent(QMouseEvent* event);
    virtual void mouseReleaseEvent(QMouseEvent* event);
    virtual void mouseMoveEvent(QMouseEvent* event);
    virtual void mouseDoubleClickEvent(QMouseEvent* event);
    virtual void wheelEvent(QWheelEvent* event);

    void registerCurve(SGQWTPlotCurve* curve );
    void deregisterCurve(SGQWTPlotCurve* curve );

    QwtPlot*  m_qwtPlot = nullptr;

signals:
    void xMinChanged();
    void xMaxChanged();
    void yMinChanged();
    void yMaxChanged();
    void xTitleChanged();
    void yTitleChanged();
    void xLogarithmicChanged();
    void yLogarithmicChanged();
    void backgroundColorChanged();
    void curvesChanged();

private:
    friend class SGQWTPlotCurve;

    QVector<SGQWTPlotCurve*> m_curves_; // tracks all attached curves for user access
    QVector<SGQWTPlotCurve*> m_dynamic_curves_; // tracks dynamically created curves for later destruction

    double  m_x_min_ = std::numeric_limits<double>::quiet_NaN();
    double  m_x_max_ = std::numeric_limits<double>::quiet_NaN();
    double  m_y_min_ = std::numeric_limits<double>::quiet_NaN();
    double  m_y_max_ = std::numeric_limits<double>::quiet_NaN();
    QString m_x_title_;
    QString m_y_title_;
    bool m_x_logarithmic_;
    bool m_y_logarithmic_;
    QColor  m_background_color_ = "white";

    void setXMin_(double value);
    void setXMax_(double value);
    void setYMin_(double value);
    void setYMax_(double value);
    void setXTitle_(QString title);
    void setYTitle_(QString title);
    void setXLogarithmic_(bool logarithmic);
    void setYLogarithmic_(bool logarithmic);
    void setBackgroundColor_(QColor newColor);

    void setXAxis_();
    void setYAxis_();

private slots:
    void updatePlotSize_();
};











class SGQWTPlotCurve : public QObject
{
    Q_OBJECT

public:
    SGQWTPlotCurve(QObject* parent = nullptr);
    virtual ~SGQWTPlotCurve();

    Q_INVOKABLE void append(QPointF point);
    Q_INVOKABLE void append(double x, double y);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QPointF at(int index);
    Q_INVOKABLE int count();
    Q_INVOKABLE void shiftPoints(double offset);
    Q_INVOKABLE void update();

    Q_PROPERTY(SGQWTPlot* graph READ getGraph WRITE setGraph NOTIFY graphChanged)
    Q_PROPERTY(QColor color READ getColor WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString name MEMBER m_name_ WRITE setName NOTIFY nameChanged)

protected:
    void setGraph (SGQWTPlot* graph);
    void unsetGraph ();
    void setName (QString name);

signals:
    void graphChanged();
    void colorChanged();
    void nameChanged();

private:
    friend class SGQWTPlot;

    QwtPlotCurve*   m_curve;  ///update naming conventions to _ if private in the end
    QVector<QPointF>    m_curve_data;

    SGQWTPlot*      m_graph = nullptr;
    QwtPlot*        m_plot = nullptr;
    QColor          m_color_ = Qt::black;
    QString         m_name_ = "";

    SGQWTPlot* getGraph ();
    void setColor (QColor color);
    QColor getColor ();
};









class SGQWTPlotCurveData : public QwtSeriesData<QPointF>
{
public:
    SGQWTPlotCurveData(const QVector<QPointF> *container);

private:
      const QVector<QPointF>* _container;

public:
      // QwtSeriesData interface
      size_t size() const;
      QPointF sample(size_t i) const;
      QRectF boundingRect() const;
};

#endif // SGQWTPLOT_H
