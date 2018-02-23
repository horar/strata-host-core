#ifndef PLATFORMINTERFACEMOTORVORTEX_H
#define PLATFORMINTERFACEMOTORVORTEX_H

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

namespace PlatformInterfaceMotorVortex {

class PlatformInterface : public CoreInterface
{
    Q_OBJECT

    //----
    // Platform Implementation properties
    //
    Q_PROPERTY(unsigned int motor_speed_ READ motorSpeed NOTIFY motorSpeedChanged)
    Q_PROPERTY(QString motor_mode_ READ motorSpeed NOTIFY motorModeChanged)

public:
    explicit PlatformInterface(QObject *parent = nullptr);
    virtual ~PlatformInterface();

    // ---
    // Platform Implementation: Commands
    //
    Q_INVOKABLE bool setMotorSpeed(unsigned int speed);
    Q_INVOKABLE bool setMotorMode(QString mode);         // "auto", "manual"

    // ---
    // Platform Implementation: Notification handlers
    // add platform specific notification handlers here
    void motorStatsNotificationHandler(QJsonObject payload);

    // ---
    // Platform Implementation: Q_PROPERTY read methods
    unsigned int motorSpeed() { return current_speed_; }
    QString motorMode() { return motor_mode_; }

signals:

    // ---
    // Platform Implementation Signals
    bool motorSpeedChanged(unsigned int speed);
    bool motorModeChanged(QString mode);

private:

    // ---
    // Platform Implementation variables
    unsigned int current_speed_;
    unsigned int target_speed_;
    QString motor_mode_;

};

} // end namespace Platform

#endif // PLATFORMINTERFACEMOTORVORTEX_H
