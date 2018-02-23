#ifndef PLATFORMINTERFACEBUBU_H
#define PLATFORMINTERFACEBUBU_H

//----
// Platform Interface
//
// BuBu platform
//
//  Platform Implementation for BuBu
//
//
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
#include <PlatformInterface/core/CoreInterface.h>

namespace PlatformInterfaceBuBu {

class PlatformInterface : public CoreInterface
{
    Q_OBJECT

public:
    explicit PlatformInterface(QObject *parent = nullptr);
    virtual ~PlatformInterface();

signals:

private:

};

} // end namespace PlatformBuBu

#endif // PLATFORMINTERFACEBUBU_H
