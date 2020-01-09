//#include "plotdata.h"
#include "qwtquick2.h"

#include <qwt/qwt_plot.h>
#include <qwt/qwt_plot_curve.h>
#include <qwt/qwt_plot_renderer.h>

#include <QDebug>

QwtQuick2Plot::QwtQuick2Plot(QQuickItem* parent) : QQuickPaintedItem(parent)
    , m_qwtPlot(nullptr), m_timerId(0)
{
    setFlag(QQuickItem::ItemHasContents, true);
    setAcceptedMouseButtons(Qt::AllButtons);

    connect(this, &QQuickPaintedItem::widthChanged, this, &QwtQuick2Plot::updatePlotSize);
    connect(this, &QQuickPaintedItem::heightChanged, this, &QwtQuick2Plot::updatePlotSize);
}

QwtQuick2Plot::~QwtQuick2Plot()
{
    delete m_qwtPlot;
    m_qwtPlot = nullptr;

    if (m_timerId != 0) {
        killTimer(m_timerId);
    }
}

void QwtQuick2Plot::replotAndUpdate()
{
    m_qwtPlot->replot();
    update();
}

void QwtQuick2Plot::initQwtPlot()
{
    m_qwtPlot = new QwtPlot();
    // after replot() we need to call update() - so disable auto replot
    m_qwtPlot->setAutoReplot(false);
    m_qwtPlot->setStyleSheet("background: white");
//    m_qwtPlot->setStyleSheet("background:" + backgroundColor.name());

    updatePlotSize();

    m_curve1 = new QwtPlotCurve("Curve 1");

    m_curve1->setPen(QPen(Qt::red));
    m_curve1->setStyle(QwtPlotCurve::Lines);
    m_curve1->setRenderHint(QwtPlotItem::RenderAntialiased);

    m_curve1->setData(new PlotData(&m_curve1_data));
    m_curve1->setPaintAttribute( QwtPlotCurve::FilterPoints , true );

    m_qwtPlot->setAxisTitle(m_qwtPlot->xBottom, tr("t"));
    m_qwtPlot->setAxisTitle(m_qwtPlot->yLeft, tr("S"));
    setAxisScaleTest();
    m_curve1->attach(m_qwtPlot);

    replotAndUpdate();
}

void QwtQuick2Plot::startTime(int milliseconds) {
//    qDebug() << Q_FUNC_INFO;

    m_timerId = startTimer(milliseconds);
    m_point_count_ = 10000/milliseconds;
    now_ = start_time_ = std::chrono::system_clock::now();

}

void QwtQuick2Plot::stopTime() {
//    qDebug() << Q_FUNC_INFO;

    killTimer(m_timerId);
}


void QwtQuick2Plot::paint(QPainter* painter)
{
    if (m_qwtPlot) {
        QPixmap picture(boundingRect().size().toSize());

        QwtPlotRenderer renderer;
        renderer.renderTo(m_qwtPlot, picture);

        painter->drawPixmap(QPoint(), picture);
    }
}

void QwtQuick2Plot::mousePressEvent(QMouseEvent* event)
{
//    qDebug() << Q_FUNC_INFO;
    routeMouseEvents(event);
}

void QwtQuick2Plot::mouseReleaseEvent(QMouseEvent* event)
{
//    qDebug() << Q_FUNC_INFO;
    routeMouseEvents(event);
}

void QwtQuick2Plot::mouseMoveEvent(QMouseEvent* event)
{
    routeMouseEvents(event);
}

void QwtQuick2Plot::mouseDoubleClickEvent(QMouseEvent* event)
{
//    qDebug() << Q_FUNC_INFO;
    routeMouseEvents(event);
}

void QwtQuick2Plot::wheelEvent(QWheelEvent* event)
{
    routeWheelEvents(event);
}


void QwtQuick2Plot::routeMouseEvents(QMouseEvent* event)
{
    if (m_qwtPlot) {
        QMouseEvent* newEvent = new QMouseEvent(event->type(), event->localPos(),
                                                event->button(), event->buttons(),
                                                event->modifiers());
        QCoreApplication::postEvent(m_qwtPlot, newEvent);
    }
}

void QwtQuick2Plot::routeWheelEvents(QWheelEvent* event)
{
    if (m_qwtPlot) {
        QWheelEvent* newEvent = new QWheelEvent(event->pos(), event->delta(),
                                                event->buttons(), event->modifiers(),
                                                event->orientation());
        QCoreApplication::postEvent(m_qwtPlot, newEvent);
    }
}

void QwtQuick2Plot::updatePlotSize()
{
    if (m_qwtPlot) {
        m_qwtPlot->setGeometry(0, 0, static_cast<int>(width()), static_cast<int>(height()));
    }
}

void QwtQuick2Plot::addPoint(QPointF point) {
    m_curve1_data.append(point);
}

void QwtQuick2Plot::setAxisScaleTest(){
    m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, 0, 100);
    m_qwtPlot->setAxisScale( m_qwtPlot->yLeft, -2, 2);
}

void QwtQuick2Plot::movePoints(){
    for ( int j = 0; j < m_curve1_data.length(); j++ ){
        m_curve1_data[j].setX(m_curve1_data[j].x()+(10000/m_point_count_));
    }

    while ( m_curve1_data[0].x() > m_point_count_ ){
            m_curve1_data.remove(0);
    }
}

int QwtQuick2Plot::pointCount(){
    return m_curve1_data.length();
}

void QwtQuick2Plot::clearPoints(){
    m_curve1_data.clear();
    replotAndUpdate();
}


void QwtQuick2Plot::timerEvent(QTimerEvent* /*event*/)
{

    std::chrono::duration<double>  time_since_last_plot = std::chrono::system_clock::now() - now_;
    now_ = std::chrono::system_clock::now();

    std::chrono::duration<double> elapsed_seconds = now_-start_time_;


    m_curve1_data.append(QPointF(elapsed_seconds.count(), data_));
//    movePoints();


//    qDebug() << Q_FUNC_INFO << QString("pointcount:%1").arg(pointCount());
//    setAxisScaleTest();

    m_qwtPlot->setAxisScale( m_qwtPlot->xBottom, elapsed_seconds.count()-10, elapsed_seconds.count());
//    m_qwtPlot->setAxisScale( m_qwtPlot->yLeft, -2, 2);
    while ( m_curve1_data.length() > m_point_count_ ){
            m_curve1_data.remove(0);
    }

    replotAndUpdate();
}



PlotData::PlotData(const QVector<QPointF> *container) :
    _container(container)
{
}

size_t PlotData::size() const
{
    return static_cast<size_t>(_container->size());
}

QPointF PlotData::sample(size_t i) const
{
    return _container->at(static_cast<int>(i));
}

QRectF PlotData::boundingRect() const
{
    return qwtBoundingRect(*this);
}
