#ifndef COREINTERFACE_H
#define COREINTERFACE_H

//----
// Core Framework
//
// WARNING : DO NOT EDIT THIS FILE UNLESS YOU ARE ON THE CORE FRAMEWORK TEAM
//
//  Platform Implementation is done in PlatformInterface/platforms/<type>/PlatformInterface.h/cpp
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
#include <string>
#include <HostControllerClient.hpp>

typedef std::function<void(QJsonObject)> NotificationHandler; // notification handler
typedef std::function<void(QJsonObject)> DataSourceHandler; // data source handler accepting QJsonObject

class CoreInterface : public QObject
{
    Q_OBJECT

    //----
    // Core Framework Properties
    //
    Q_PROPERTY(QString platform_id_ READ platformID NOTIFY platformIDChanged)                   // update platformID to switch control interface
    Q_PROPERTY(bool platform_state_ READ platformState NOTIFY platformStateChanged)  // TODO [ian] define core framework platform states

public:
    explicit CoreInterface(QObject *parent = nullptr);
    virtual ~CoreInterface();

    // ---
    // Core Framework: Q_PROPERTY read methods
    QString platformID() { return platform_id_; }
    bool platformState() { return platform_state_; }

    bool registerNotificationHandler(std::string notification, NotificationHandler handler);
    bool registerDataSourceHandler(std::string source, DataSourceHandler handler);

    Spyglass::HostControllerClient *hcc;
    std::thread notification_thread_;
    void notificationsThread();

signals:

    // ---
    // Core Framework Signals
    bool platformIDChanged(QString id);
    bool platformStateChanged(bool platform_connected_state);

private:

    // ---
    // Core Framework
    QString platform_id_;
    bool platform_state_;         // TODO [ian] change variable name to platform_connected_state

    bool notification_thread_running_;

    // ---
    // notification handling
    std::map<std::string, NotificationHandler > notification_handlers_;

    // Main Catagory Notification handlers
    void platformNotificationHandler(QJsonObject notification);
    void cloudNotificationHandler(QJsonObject notification);

    // Core Framework Notificaion Handlers
    void platformIDNotificationHandler(QJsonObject payload);
    void connectionChangeNotificationHandler(QJsonObject payload);

    // attached Data Source subscribers
    std::map<std::string, DataSourceHandler > data_source_handlers_;

};

#endif // COREINTERFACE_H
