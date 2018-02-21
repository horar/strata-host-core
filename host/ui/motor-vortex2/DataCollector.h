#ifndef DATACOLLECTOR_H
#define DATACOLLECTOR_H

#include <QObject>
#include <QQmlListProperty>
#include <QObject>
#include <QByteArray>
#include <QList>
#include <QString>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTime>
#include <QTimer>
#include <map>

#include <PlatformInterface/PlatformInterface.h>

class View {
public:
    explicit View(QString name) : name(name), hits(0), timer_running(false) {}

    QString name;
    unsigned long hits;
    bool timer_running;
    QTime time;
};

class DataCollector : public QObject
{
    Q_OBJECT

public:
    DataCollector();
    DataCollector(PlatformInterface * implInterface);
    explicit DataCollector(QObject *parent);
    virtual ~DataCollector();

    // @f start
    // @b start timer and increment view hit count
    Q_INVOKABLE void start(QString view);

private:
    void init();

    PlatformInterface * implInterface_;
    std::map<QString, View> views;

};

#endif // DATACOLLECTOR_H
