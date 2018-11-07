#ifndef POINTREPLACER_H
#define POINTREPLACER_H

#include <QtCore/QObject>
#include <QtCharts/QAbstractSeries>

QT_CHARTS_USE_NAMESPACE

class PointReplacer
{
public:
    PointReplacer();

Q_SIGNALS:

public slots:
    void update(QAbstractSeries *series);

private:
    QQuickView *m_appViewer;
    QList<QVector<QPointF> > m_data;
    int m_index;
};

#endif // POINTREPLACER_H
