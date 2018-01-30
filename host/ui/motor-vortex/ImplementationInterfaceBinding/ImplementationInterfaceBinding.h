#ifndef USER_INTERFACE_BINDING_H
#define USER_INTERFACE_BINDING_H

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
#include "HostControllerClient.hpp"

// To simulate the data
#define BOARD_DATA_SIMULATION 0

typedef std::function<void(QJsonObject)> NotificationHandler; // notification handler
typedef std::function<void(QJsonObject)> DataSourceHandler; // data source handler accepting QJsonObject

class ImplementationInterfaceBinding : public QObject
{
    Q_OBJECT

    //----
    // Platform Implementation properties
    //
    Q_PROPERTY(unsigned int motor_speed_ READ motorSpeed NOTIFY motorSpeedChanged)
    Q_PROPERTY(QString motor_mode_ READ motorSpeed NOTIFY motorModeChanged)

    //----
    // Core Framework Properties
    //
    Q_PROPERTY(QString platform_id_ READ platformID NOTIFY platformIDChanged)                   // update platformID to switch control interface
    Q_PROPERTY(bool platform_state_ READ platformState NOTIFY platformStateChanged)  // TODO [ian] define core framework platform states

public:

    explicit ImplementationInterfaceBinding(QObject *parent = nullptr);
    virtual ~ImplementationInterfaceBinding();

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
    // Platform Implementation: Error handlers

    // ---
    // Platform Implementation: Q_PROPERTY read methods
    unsigned int motorSpeed() { return current_speed_; }
    QString motorMode() { return motor_mode_; }

    // End Platform Implementation Specific
    // ---

    // ---
    // Core Framework
    //
    // note: generally no need to add/modify items in this area
    //

    // Core Framework: Q_PROPERTY read methods
    QString platformID() { return platform_id_; }
    bool platformState() { return platform_state_; }

    bool registerDataSourceHandler(std::string source, DataSourceHandler handler);
    bool getPlatformState();
    QString getPlatformId();

    std::thread notification_thread_;
    void notificationsThreadHandle();

signals:
    // ---
    // Platform Implementation Signals
    bool motorSpeedChanged(unsigned int speed);
    bool motorModeChanged(QString mode);

    // ---
    // Core Framework Signals
    bool platformIDChanged(QString id);
    bool platformStateChanged(bool platform_connected_state);

private:

    // ---
    // Platform Implementation variables
    unsigned int current_speed_;
    unsigned int target_speed_;
    QString motor_mode_;

    // --- end Platform Implementation variables
    // ---
    // Core Framework
    QString platform_id_;
    bool platform_state_;         // TODO [ian] change variable name to platform_connected_state

    bool notification_thread_running_;

    // ---
    // notification handling
    std::map<std::string, NotificationHandler > notification_handlers_;
    bool registerNotificationHandler(std::string notification, NotificationHandler handler);

    // Main Catagory Notification handlers
    void platformNotificationHandler(QJsonObject notification);
    void cloudNotificationHandler(QJsonObject notification);

    // Core Framework Notificaion Handlers
    void platformIDNotificationHandler(QJsonObject payload);
    void connectionChangeNotificationHandler(QJsonObject payload);

    // attached Data Source subscribers
    std::map<std::string, DataSourceHandler > data_source_handlers_;


    Spyglass::HostControllerClient *hcc;

};


#endif // UserInterfaceBinding_H

