#include "ImplementationInterfaceBinding.h"
#include "zhelpers.hpp"

// TODO [ian] split Core Framework and Implementation handlers into separate files
//   PlatformImplementationInterface.h
//   PlatformImplementationInterface.cpp
//
//   FrameworkImplementationInterface.h
//   FrameworkImplementationInterface.cpp
//
//
//

using namespace std;
using namespace Spyglass;


ImplementationInterfaceBinding::ImplementationInterfaceBinding(QObject *parent) : QObject(parent)
{
    hcc = new HostControllerClient;

    // ---
    // Platform Implementation Notification handlers
    //
    registerNotificationHandler("pi_stats",
                                bind(&ImplementationInterfaceBinding::motorStatsNotificationHandler,
                                     this, placeholders::_1));

    // --------------------
    // Core Framework
    // install main notification notification handlers
    //
    // Main sources:
    // "notification"           // platform devices
    // "cloud::notification"    // cloud notifications
    //
    // from platform TODO [ian] make namespaced platform::notification
    registerNotificationHandler("notification",
                                bind(&ImplementationInterfaceBinding::platformNotificationHandler,
                                     this, placeholders::_1));

    registerNotificationHandler("cloud::notification",
                                bind(&ImplementationInterfaceBinding::cloudNotificationHandler,
                                     this, placeholders::_1));

    registerNotificationHandler("platform_id",
                                bind(&ImplementationInterfaceBinding::platformIDNotificationHandler,
                                     this, placeholders::_1));

    registerNotificationHandler("platform_connection_change_notification",
                                bind(&ImplementationInterfaceBinding::connectionChangeNotificationHandler,
                                     this, placeholders::_1));

#ifdef QT_NO_DEBUG
    platform_state_ = false;
#else
    platform_state_ = true;  // Debug builds should not need a platform board
#endif

    notification_thread_running_ = false;
    notification_thread_= std::thread(&ImplementationInterfaceBinding::notificationsThreadHandle,this);

#if BOARD_DATA_SIMULATION
    // Simulation for load board data only
    targetVoltage = 5;
#endif

}

ImplementationInterfaceBinding::~ImplementationInterfaceBinding()
{
    hcc->notificationSocket->close();
    hcc->sendCmdSocket->close();
    zmq_term(hcc->context);
    delete(hcc);
    notification_thread_.detach();
}

// ----- Platform Implementation Commands
//
// Add Platform Specific Command Handlers
// Q_INVOKABLE() functions

// @f setMotorSpeed
// @b set motor speed
//
bool ImplementationInterfaceBinding::setMotorSpeed( unsigned int speed )
{
    qDebug("ImplementationInterfaceBinding::setMotorSpeed(%ld)", speed);

    // { "cmd":"speed_input",
    //   "payload": {
    //   "speed_target":3000
    //  }}

    QJsonObject cmd, payload;

    cmd.insert("cmd", QJsonValue("speed_input"));
    payload.insert("speed_target", QJsonValue((double)speed));
    cmd.insert("payload", payload);
    QJsonDocument doc(cmd);
    QString cmd_json(doc.toJson(QJsonDocument::Compact));

    bool rv = hcc->sendCmd(cmd_json.toStdString());
    if( rv == false) {
        qCritical() << "ERROR:ImplementationInterfaceBinding::setMotorSpeed:"
                       " command send failure";
    }

    return rv;
}

// @f setMotorMode
// @b set motor mode to manual control or automatic demo
//
bool ImplementationInterfaceBinding::setMotorMode( QString mode )
{
    qDebug("ImplementationInterfaceBinding::setMotorMode(%s)",
           mode.toStdString().c_str());

    // Manual:
    //
    // {"cmd":"set_system_mode",
    //  "payload":{"system_mode":1}}
    //
    // Automation:
    //
    // {"cmd":"set_system_mode",
    //  "payload":{"system_mode":0}}
    //
    QJsonObject cmd, payload;

    cmd.insert("cmd", QJsonValue("set_system_mode"));
    payload.insert("system_mode", mode == "manual" ? QJsonValue("manual") :QJsonValue("automation"));
    cmd.insert("payload", payload);
    QJsonDocument doc(cmd);
    QString cmd_json(doc.toJson(QJsonDocument::Compact));

    qDebug() << "cmd: " << cmd_json;

    bool rv = hcc->sendCmd(cmd_json.toStdString());
    if( rv == false) {
        qCritical() << "ERROR:ImplementationInterfaceBinding::setMotorMode:"
                       " command send failure";
    }

    return rv;
}

// END Platform Implementation Notification Handlers
// ----------


// ----- Platform Implementation Notification Handlers
//
// Add Platform Specific Notification Handlers here

// @f motorStats
// @b Motor statistics
//
void ImplementationInterfaceBinding::motorStatsNotificationHandler(QJsonObject payload)
{
    //{
    //   "notification": {
    //         "value":"pi_stats",
    //         "payload": {
    //               "speed_target":4000,
    //               "current_speed":3880,
    //               "error":120,
    //               "sum":0.00,
    //               "duty_now":0.58,
    //               "mode":"automation"}}}
    //
    // current_speed is the actual measured speed of the motor.

    unsigned int current_speed = payload["current_speed"].toInt();
    unsigned int target_speed = payload["speed_target"].toInt();
    QString motor_mode = payload["mode"].toString();

    qDebug() << "current_speed = " << current_speed;
    qDebug() << "target_speed = " << target_speed;
    qDebug() << "mode = " << motor_mode;

    if( current_speed != current_speed_ ) {
        qDebug() << "EMIT: current_speed = " << current_speed;
        current_speed_ = current_speed;
        emit motorSpeedChanged(current_speed_);
    }

    // TODO [ian] target speed is not used at this time.
    //    if( target_speed != target_speed_ ) {
    //        target_speed_ = target_speed;
    //        emit targetSpeedChanged(target_speed_);
    //    }

    if( motor_mode != motor_mode_ ) {
        motor_mode_ = motor_mode;
        emit motorModeChanged(motor_mode_);
    }
}

// END Platform Implementation Notification Handlers
// ----------


// @f notificationsThreadHandle
// @b main dispatch thread for notifications from Host Controller Service
//

void ImplementationInterfaceBinding::notificationsThreadHandle()
{
    qDebug () << "Thread Created for notification ";
    notification_thread_running_ = true;

    while(notification_thread_running_) {
        // Notification Message Architecture
        //
        //    {
        //        "notification": {
        //            "value": "platform_connection_change_notification",
        //            "payload": {
        //                "status": "disconnected"
        //            }
        //        }
        //    }
        //
        //    {
        //        "cloud::notification": {
        //        "type": "document",
        //        "name": "schematic",
        //        "documents": [
        //              {"data": "*******","filename": "schematic1.png"},
        //              {"data": "*******","filename": "schematic1.png"}
        //        ]
        //        }
        //   }
        //

        // TODO [ian] need to avoid uneeded std::string to QString conversion
        // TODO [ian] need to error check/validate json messages
        string message = hcc->receiveNotification();  // Host Controller Service

        QString n(message.c_str());

        QJsonDocument doc = QJsonDocument::fromJson(n.toUtf8());
        if(doc.isNull()) {
            // TODO [ian] fix the "ONSEMI" message from fouling up all this
            //qCritical()<<"ERROR: void ImplementationInterfaceBinding::notificationsThreadHandle()."
            //             "Failed to create JSON doc. message=" << n.toStdString().c_str();
            continue;
        }

        QJsonObject notification_json = doc.object();
        if(notification_json.isEmpty() ) {
            qCritical()<<"ERROR: void ImplementationInterfaceBinding::notificationsThreadHandle():"
                         "JSON is empty.";
            continue;
        }

        QStringList keys = notification_json.keys();
        if( keys.size() != 1 ) {
            qCritical()<<"ERROR: void ImplementationInterfaceBinding::notificationsThreadHandle():"
                         " More then one key in notification message. Violates message architecture.";
            continue;
        }

        QString notification(keys.at(0)); // top level JSON keys

        auto handler = notification_handlers_.find(notification.toStdString());
        if( handler == notification_handlers_.end()) {
            qCritical("ImplementationInterfaceBinding::notificationsThreadHandle()"
                      " ERROR: no handler exits for %s !!", notification.toStdString().c_str ());
            continue;
        }

        // dispatch handler for notification
        handler->second(notification_json["notification"].toObject());
    }
}

// ---
// Core Framework Infrastructure Notification Handlers
//
void ImplementationInterfaceBinding::platformIDNotificationHandler(QJsonObject payload)
{
    if (payload.contains("platform_id")) {
        QString platform_id = payload["platform_id"].toString();
        //qDebug() << "Received platform_id = " << platform_id;

        if(platform_id_ != platform_id ) {
            platform_id_ = platform_id;
            emit platformIDChanged(platform_id_);

            // also update platform connected state
            platform_state_ = true;
            emit platformStateChanged(platform_state_);
        }
    }
}

void ImplementationInterfaceBinding::connectionChangeNotificationHandler(QJsonObject payload)
{
    QString state = payload["status"].toString();
    //qDebug() << "platform_state = " << state;

    if( state == "connected" ) {
        platform_state_ = true;
        emit platformStateChanged(platform_state_);
    }
    else {
        platform_state_ = false;
        emit platformStateChanged(platform_state_);
    }
}

// @f platformNotificationHandler
// @b handle platform notifications
//
//  TODO [ian] change "value" to "name" of notification message
//    {
//        "notification": {
//            "value": "platform_connection_change_notification",
//            "payload": {
//                "status": "disconnected"
//            }
//        }
//    }

void ImplementationInterfaceBinding::platformNotificationHandler(QJsonObject payload)
{
    //qDebug("ImplementationInterfaceBinding::platformmNotificationHandler: CALLED");

    if( payload.contains("value") == false ) {
        qCritical("ImplementationInterfaceBinding::platformNotificationHandler()"
                  " ERROR: no name for notification!!");
        return;
    }

    if( payload.contains("payload") == false ) {
        qCritical("ImplementationInterfaceBinding::platformNotificationHandler()"
                  " ERROR: no payload for notification!!");
        return;
    }

    QString value = payload["value"].toString();
    auto handler = notification_handlers_.find(value.toStdString());
    if( handler == notification_handlers_.end()) {
        qCritical("ImplementationInterfaceBinding::notificationsThreadHandle()"
                  " ERROR: no handler exits for %s !!", value.toStdString().c_str ());
        return;
    }

    handler->second(payload["payload"].toObject());

}

// @f handleCloudNotification
// @b handle cloud service notifications
//
//
//  CLOUD JSON STRUCTURE
// {
//   "cloud::notification": {
//     "type": "document",
//     "name": "schematic",
//     "documents": [
//       {"data": "*******","filename": "schematic1.png"},
//       {"data": "*******","filename": "schematic1.png"}
//     ]
//   }
// }
//
// {
//   "cloud::notification": {
//     "type": "marketing",
//     "name": "adas_sensor_fusion",
//     "data": "raw html"
//  }
// }
//
void ImplementationInterfaceBinding::cloudNotificationHandler(QJsonObject value)
{
    //qDebug("ImplementationInterfaceBinding::cloudNotificationHandler: CALLED");

    // data source type: document_set, chat, marketing et al
    QJsonObject payload = value["cloud::notification"].toObject();
    string type = payload.value("type").toString().toStdString();

    auto handler = data_source_handlers_.find(type);
    if( handler == data_source_handlers_.end()) {
        qCritical("ImplementationInterfaceBinding::handleNotification"
                  " ERROR: no handler exits for %s !!", type.c_str ());
        return;
    }

    handler->second(payload);  // dispatch handler for notification

}

bool ImplementationInterfaceBinding::registerNotificationHandler(std::string notification, NotificationHandler handler)
{
    qDebug("ImplementationInterfaceBinding::registerNotificationHandler:"
              "source=%s", notification.c_str());

    auto search = notification_handlers_.find(notification);
    if( search != notification_handlers_.end()) {
        qCritical("ImplementationInterfaceBinding::registerNotificationHandler:"
                  " ERROR: handler already exits for %s !!", notification.c_str ());
        return false;
    }

    notification_handlers_.emplace(std::make_pair(notification, handler));

    return true;
}

bool ImplementationInterfaceBinding::registerDataSourceHandler(std::string source, DataSourceHandler handler)
{
    qDebug("ImplementationInterfaceBinding::registerDataSourceHanlder:"
              "source=%s", source.c_str());

    auto search = data_source_handlers_.find(source);
    if( search != data_source_handlers_.end()) {
        qCritical("ImplementationInterfaceBinding::registerDataSourceHanlder:"
                  " ERROR: handler already exits for %s !!", source.c_str ());
        return false;
    }

    data_source_handlers_.emplace(std::make_pair(source, handler));

    // notify Host Controller Service of the data source connection
    //    {
    //        "db::cmd":"connect_data_source",
    //        "db::payload":{
    //            "type":"documents"
    //        }
    //    }
    //
    QJsonObject cmd;
    QJsonObject payload;

    cmd.insert("db::cmd", "connect_data_source");
    payload.insert("type", source.c_str());
    cmd.insert("db::payload", payload);

    hcc->sendCmd(QString(QJsonDocument(cmd).toJson(QJsonDocument::Compact)).toStdString());
    return true;
}

#if CODE_SNIPPETS
//    auto message = R"(
//                {
//                    "notification": {
//                        "value": "platform_connection_change_notification",
//                        "payload": {
//                            "status": "disconnected"
//                        }
//                    }
//                }
//                )";

//    auto message = R"(
//                {
//                    "cloud::notification": {
//                        "value": "platform_connection_change_notification",
//                        "payload": {
//                            "status": "disconnected"
//                        }
//                    }
//                }
//                )";

//    QString n(message);
//    QJsonDocument doc = QJsonDocument::fromJson(n.toUtf8());
//    if(doc.isNull()){
//        qCritical()<<"ERROR: void ImplementationInterfaceBinding::notificationsThreadHandle(). Failed to create JSON doc.";
//        //continue;
//    }

//    QJsonObject notification_json = doc.object();
//    if(notification_json.isEmpty() ) {
//        qCritical()<<"ERROR: void ImplementationInterfaceBinding::notificationsThreadHandle(): JSON is empty.";
//        //continue;
//    }

//    // get keys from json object. Must only
//    QStringList keys = notification_json.keys();
//    if( keys.size() > 1 ) {
//        qCritical()<<"ERROR: void ImplementationInterfaceBinding::notificationsThreadHandle():"
//                     " More then one key in notification message. Violates message architecture.";
//        //continue;
//    }

//    QString notification(keys.at(0));

//    auto handler = notification_handlers_.find(notification.toStdString());
//    if( handler == notification_handlers_.end()) {
//        qCritical("ImplementationInterfaceBinding::notificationsThreadHandle()"
//                  " ERROR: no handler exits for %s !!", notification.toStdString().c_str ());
//        //return;
//    }
//    handler->second(notification_json);  // dispatch handler for notification
#endif


