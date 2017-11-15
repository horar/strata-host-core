
#include "DataCollector.h"

using namespace std;

DataCollector::DataCollector()
{
    //qDebug("DataCollector::DataCollector(): default ctor");
    init();
}

DataCollector::DataCollector(QObject *parent) : QObject(parent)
{
    qDebug("DataCollector::DataCollector(parent=%p)", parent);
    init();
}

DataCollector::~DataCollector()
{
    qDebug("DataCollector::~DataCollector(): dtor");
}

void DataCollector::init()
{
    //qDebug("DataCollector::init()");
}

void DataCollector::start(QString view)
{
    qDebug("DataCollector::start(%s)", view.toStdString ().c_str ());

    auto v = views.find(view);
    if (v == views.end()) {
        qDebug("DataCollector::DataCollector: %s not found. Adding view.", view.toStdString ().c_str ());

        views.emplace(make_pair(view, View(view)));
    }

    qDebug("DataCollector::start(): current views");

    for( auto &v : views) {
        qDebug(" name(%s,%s):", v.first.toStdString ().c_str (), v.second.name.toStdString ().c_str ());
        qDebug(" hits = %ld:", v.second.hits);
        qDebug(" timer = %ld:", v.second.hits);
        qDebug(" timer_running = %s:", v.second.timer_running ? "TRUE" : "FALSE");
    }

    return;
}


