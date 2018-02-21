#ifndef PLATFORM_INTERFACE_H
#define PLATFORM_INTERFACE_H

#include <QObject>
#include <iterator>
#include <QString>
#include <QKeyEvent>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>
#include <QStringList>
#include <QString>
#include <QJsonArray>
#include <string>
#include <thread>
#include <map>
#include <functional>
#include <stdlib.h>
#include <PlatformInterface/CoreInterface.h>
#include "HostControllerClient.hpp"

class PlatformInterface : public CoreInterface
{
    Q_OBJECT

public:
    using CoreInterface::CoreInterface;

    explicit PlatformInterface(QObject *parent = nullptr) : CoreInterface(parent)
    {
        qDebug() << "PlatformInterface::PlatformInterface CTOR called";
    }
    virtual ~PlatformInterface()
    {
        qDebug() << "PlatformInterface::~PlatformInterface DTOR called";
    }

signals:

private:

};


#endif // PLATFORM_INTERFACE_H

