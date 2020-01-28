#ifndef SGQWTPLOT_H
#define SGQWTPLOT_H

#include <QtQuick>
#include <QPointF>
#include <QVector>

#include "logging/LoggingQtCategories.h"

#include <qwt/qwt_plot.h>
#include <qwt/qwt_plot_curve.h>
#include <qwt/qwt_plot_renderer.h>
#include <qwt/qwt_scale_map.h>
#include <qwt/qwt_series_data.h>
#include <qwt/qwt_scale_engine.h>
#include <qwt/qwt_scale_widget.h>
#include <qwt/qwt_plot_layout.h>

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
    Q_INVOKABLE void removeCurve(int index);
    Q_INVOKABLE int count();
    Q_INVOKABLE QPointF mapToValue(QPointF point);
    Q_INVOKABLE QPointF mapToPosition(QPointF point);

    Q_PROPERTY(double xMin READ getXMin_ WRITE setXMin_ NOTIFY xMinChanged)
    Q_PROPERTY(double xMax READ getXMax_ WRITE setXMax_ NOTIFY xMaxChanged)
    Q_PROPERTY(double yMin READ getYMin_ WRITE setYMin_ NOTIFY yMinChanged)
    Q_PROPERTY(double yMax READ getYMax_ WRITE setYMax_ NOTIFY yMaxChanged)
    Q_PROPERTY(QString xTitle READ getXTitle_ WRITE setXTitle_ NOTIFY xTitleChanged)
    Q_PROPERTY(QString yTitle READ getYTitle_ WRITE setYTitle_ NOTIFY yTitleChanged)
    Q_PROPERTY(QString title READ getTitle_ WRITE setTitle_ NOTIFY titleChanged)
    Q_PROPERTY(bool xLogarithmic MEMBER m_x_logarithmic_ WRITE setXLogarithmic_ NOTIFY xLogarithmicChanged)
    Q_PROPERTY(bool yLogarithmic MEMBER m_y_logarithmic_ WRITE setYLogarithmic_ NOTIFY yLogarithmicChanged)
    Q_PROPERTY(QColor backgroundColor MEMBER m_background_color_ WRITE setBackgroundColor_ NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor MEMBER m_foreground_color_ WRITE setForegroundColor_ NOTIFY foregroundColorChanged)
    Q_PROPERTY(bool autoUpdate MEMBER m_auto_update_ NOTIFY autoUpdateChanged)

protected:
    QwtPlot*  m_qwtPlot = nullptr;

    void    updateCurveList_();

signals:
    void xMinChanged();
    void xMaxChanged();
    void yMinChanged();
    void yMaxChanged();
    void xTitleChanged();
    void yTitleChanged();
    void titleChanged();
    void xLogarithmicChanged();
    void yLogarithmicChanged();
    void backgroundColorChanged();
    void foregroundColorChanged();
    void curvesChanged();
    void autoUpdateChanged();

private:
    friend class SGQWTPlotCurve;

    QList<SGQWTPlotCurve*> m_curves_;

    bool    m_x_logarithmic_;
    bool    m_y_logarithmic_;
    QColor  m_background_color_ = "white";
    QColor  m_foreground_color_ = "black";
    bool    m_auto_update_ = true;

    void    setXMin_(double value);
    double  getXMin_();
    void    setXMax_(double value);
    double  getXMax_();
    void    setYMin_(double value);
    double  getYMin_();
    void    setYMax_(double value);
    double  getYMax_();
    QString getXTitle_();
    void    setXTitle_(QString title);
    QString getYTitle_();
    void    setYTitle_(QString title);
    QString getTitle_();
    void    setTitle_(QString title);
    void    setXLogarithmic_(bool logarithmic);
    void    setYLogarithmic_(bool logarithmic);
    void    setBackgroundColor_(QColor newColor);
    void    setForegroundColor_(QColor newColor);

private slots:
    void    updatePlotSize_();
};






class SGQWTPlotCurve : public QObject
{
    Q_OBJECT

public:
    SGQWTPlotCurve(QString name = "", QObject* parent = nullptr);
    virtual ~SGQWTPlotCurve();

    Q_INVOKABLE void append(QPointF point);
    Q_INVOKABLE void append(double x, double y);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QPointF at(int index);
    Q_INVOKABLE int count();
    Q_INVOKABLE void shiftPoints(double offset);
    Q_INVOKABLE void update();

    Q_PROPERTY(SGQWTPlot* graph READ getGraph_ WRITE setGraph NOTIFY graphChanged)
    Q_PROPERTY(QColor color READ getColor_ WRITE setColor_ NOTIFY colorChanged)
    Q_PROPERTY(QString name READ getName_ WRITE setName_ NOTIFY nameChanged)
    Q_PROPERTY(bool autoUpdate MEMBER m_auto_update_ NOTIFY autoUpdateChanged)

protected:
    void setGraph (SGQWTPlot* graph);
    void unsetGraph ();

signals:
    void graphChanged();
    void colorChanged();
    void nameChanged();
    void autoUpdateChanged();

private:
    friend class SGQWTPlot;

    QwtPlotCurve*       m_curve;  ///update naming conventions to _ if private in the end
    QVector<QPointF>    m_curve_data;

    SGQWTPlot*      m_graph = nullptr;
    QwtPlot*        m_plot = nullptr;
    bool            m_auto_update_ = true;

    SGQWTPlot*  getGraph_ ();
    void        setColor_ (QColor color);
    QColor      getColor_ ();
    void        setName_ (QString name);
    QString     getName_ ();
};






class SGQWTPlotCurveData : public QwtSeriesData<QPointF>
{
public:
    SGQWTPlotCurveData(const QVector<QPointF> *container);

private:
      const QVector<QPointF>* _container;

public:
      // QwtSeriesData interface
      size_t    size() const;
      QPointF   sample(size_t i) const;
      QRectF    boundingRect() const;
};

#endif // SGQWTPLOT_H
