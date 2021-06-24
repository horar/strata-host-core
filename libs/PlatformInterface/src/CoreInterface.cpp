//----
// Core Framework
//
// WARNING : DO NOT EDIT THIS FILE UNLESS YOU ARE ON THE CORE FRAMEWORK TEAM
//
//  Platform Implementation is done in PlatformInterface/platforms/<type>/PlatformInterface.h/cpp
//
//

#include "core/CoreInterface.h"

#include "LoggingQtCategories.h"

using std::string;
using strata::hcc::HostControllerClient;

CoreInterface::CoreInterface(QObject* parent, const std::string& hcsInAddress)
    : QObject(parent), hcc{std::make_unique<HostControllerClient>(hcsInAddress)}
{
    // qCDebug(logCategoryCoreInterface) << "CoreInterface::CoreInterfaceQObject *parent) :
    // QObject(parent) CTOR\n";

    qCDebug(logCategoryCoreInterface) << QStringLiteral("HCS incomming address set to: %1").arg(QString::fromStdString(hcsInAddress));

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
                                std::bind(&CoreInterface::platformNotificationHandler,
                                     this, std::placeholders::_1));

    registerNotificationHandler("hcs::notification",
                                std::bind(&CoreInterface::hcsNotificationHandler,
                                     this, std::placeholders::_1));

    registerNotificationHandler("cloud::notification",
                                std::bind(&CoreInterface::cloudNotificationHandler,
                                     this, std::placeholders::_1));

    notification_thread_running_.store(false);
    notification_thread_= std::thread(&CoreInterface::notificationsThread,this);
}

CoreInterface::~CoreInterface()
{
    setNotificationThreadRunning(false);
    bool closed = hcc->close();

    if (closed && notification_thread_.joinable()) {
        notification_thread_.join();
    } else {
        notification_thread_.detach();
    }
}

// @f notificationsThreadHandle
// @b main dispatch thread for notifications from Host Controller Service
//
//
void CoreInterface::notificationsThread()
{
    //qDebug () << "CoreInterface::notificationsThread - notification handling.";
    notification_thread_running_.store(true);

    while(notification_thread_running_.load()) {
        // Notification Message Architecture
        //
        //    {
        //        "notification": {
        //            "device_id": -1088988335,
        //            "message":"{\"notification\":{\"value\":\"sensor_value\",\"payload\":{\"value\":\"touch\"}}}"
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

        if (message.empty()) {
            continue;
        }

        QByteArray n(QByteArray::fromStdString(message));

        // Debug; Some messages are too long to print (ex: cloud images)
        if (n.length() < 500) {
          qCDebug(logCategoryCoreInterface).noquote().nospace() << "[recv] '" << n << "'";
        } else {
          qCDebug(logCategoryCoreInterface).noquote().nospace() << "[recv] '" << n.left(500) << " ...' (message over 500 chars truncated)";
        }

        QJsonDocument doc = QJsonDocument::fromJson(n);
        if(doc.isNull()) {
            // TODO [ian] fix the "ONSEMI" message from fouling up all this
            //qCritical()<<"ERROR: void CoreInterface::notificationsThreadHandle()."
            //             "Failed to create JSON doc. message=" << n.toStdString().c_str();
            continue;
        }

        QJsonObject notification_json = doc.object();
        if(notification_json.isEmpty() ) {
            qCritical()<<"ERROR: void CoreInterface::notificationsThreadHandle():"
                         "JSON is empty.";
            continue;
        }

        //[TODO: ack responses to setting a parameter have both an "ack" and a "payload", which generates an error here. How should that be fixed?]
        QStringList keys = notification_json.keys();
        if( keys.size() != 1 ) {
            //qCritical()<<"ERROR: void CoreInterface::notificationsThreadHandle():"
            //             " More then one key in notification message. Violates message architecture.";
            continue;
        }

        QString notification(keys.at(0)); // top level JSON keys

        auto handler = notification_handlers_.find(notification.toStdString());
        if( handler == notification_handlers_.end()) {
            qCritical("CoreInterface::notificationsThreadHandle()"
                      " ERROR: no handler exits for %s !!", notification.toStdString().c_str ());
            continue;
        }

        // dispatch handler for notification
        handler->second(notification_json[notification].toObject());
    }
}

// ---
// Core Framework Infrastructure Notification Handlers
//

// @f platformNotificationHandler
// @b forward platform notifications to UI
//
//  TODO [ian] change "value" to "name" of notification message
//    {
//        "notification": {
//            "device_id": -1088988335,
//            "message":"{\"notification\":{\"value\":\"sensor_value\",\"payload\":{\"value\":\"touch\"}}}"
//        }
//    }

void CoreInterface::platformNotificationHandler(QJsonObject payload)
{
    //qCDebug(logCategoryCoreInterface) << "CoreInterface::platformNotificationHandler: CALLED";

    QJsonDocument doc(payload);
    emit notification(doc.toJson(QJsonDocument::Compact));
}

// @f initialHandshakeHandler
// @b handle initial list of platform message
//
//    {
//        "handshake":
//          "list":[{
//            "verbose":"simulated-usb-pd",
//            "uuid":"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af",
//             "remote":false
//            }
//        ]
//    }

void CoreInterface::hcsNotificationHandler(QJsonObject payload)
{
    QJsonDocument testdoc(payload);
    QString strJson_payload(testdoc.toJson(QJsonDocument::Compact));
    QString type = payload["type"].toString();

    //for messages with inner payload
    QJsonObject innerPayload = payload.value("payload").toObject();

    if (type == "connected_platforms") {
        if( connected_platform_list_ != strJson_payload ) {
            connected_platform_list_ = strJson_payload;
            emit connectedPlatformListChanged(connected_platform_list_);
        }
        emit connectedPlatformListMessage(payload);
    } else if (type == "all_platforms") {
        if( platform_list_ != strJson_payload ) {
            platform_list_ = strJson_payload;
        }
        emit platformListChanged(platform_list_);
    } else if (type == "download_platform_filepath_changed") {
        emit downloadPlatformFilepathChanged(payload);
    } else if (type == "download_platform_single_file_progress") {
        emit downloadPlatformSingleFileProgress(payload);
    } else if (type == "download_platform_single_file_finished") {
        emit downloadPlatformSingleFileFinished(payload);
    } else if (type == "download_platform_files_finished") {
        emit downloadPlatformFilesFinished(payload);
    } else if (type == "update_firmware") {
        emit updateFirmwareReply(innerPayload);
    } else if (type == "update_firmware_job") {
        emit updateFirmwareJobUpdate(innerPayload);
    } else if (type == "download_view_finished") {
        emit downloadViewFinished(payload);
    } else if (type == "control_view_download_progress") {
        emit downloadControlViewProgress(payload);
    } else if (type == "platform_meta_data") {
        emit platformMetaData(payload);
    } else if (type == "updates_available") {
        emit updateInfoReceived(payload);
    } else if (type == "program_controller") {
        emit programControllerReply(innerPayload);
    } else if (type == "program_controller_job") {
        emit programControllerJobUpdate(innerPayload);
    } else if (type == "bluetooth_scan") {
        emit bluetoothScan(innerPayload);
    } else if (type == "connect_device") {
        emit connectDevice(innerPayload);
    }else if (type == "disconnect_device") {
        emit disconnectDevice(innerPayload);
    } else {
        qCCritical(logCategoryCoreInterface) << "unknown message type" << type;
    }
}

// @f loadDocuments
// @b send the user selected platform to HCS to create the mapping
//
void CoreInterface::loadDocuments(QString class_id)
{
    QJsonObject cmdPayloadObject;
    cmdPayloadObject.insert("class_id",class_id);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("cmd", "load_documents");
    cmdMessageObject.insert("payload", cmdPayloadObject);

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    //qDebug()<<"parse to send"<<strJson;
    hcc->sendCmd(strJson.toStdString());
}

// @f sendCommand
// @b send json command to platform
//
void CoreInterface::sendCommand(QString cmd)
{
    hcc->sendCmd(cmd.toStdString());
}

void CoreInterface::setNotificationThreadRunning(bool running)
{
    notification_thread_running_.store(running);
}

// @f unregisterClient
// @b Unregister to remove any notifications from HCS
//
void CoreInterface::unregisterClient()
{
    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("hcs::cmd", "unregister");
    cmdMessageObject.insert("payload", QJsonObject());

    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    //qDebug()<<"parse to send"<<strJson;
    hcc->sendCmd(strJson.toStdString());
}

// @f cloudNotificationHandler
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
void CoreInterface::cloudNotificationHandler(QJsonObject payload)
{
    // data source type: document_set, chat, marketing et al
    string type = payload.value("type").toString().toStdString();

    auto handler = data_source_handlers_.find(type);
    if( handler == data_source_handlers_.end()) {
        qCritical("CoreInterface::cloudNotification"
                  " ERROR: no handler exits for %s !!", type.c_str ());
        return;
    }

    handler->second(payload);  // dispatch handler for notification

}

bool CoreInterface::registerNotificationHandler(std::string notification, NotificationHandler handler)
{
    //qDebug("CoreInterface::registerNotificationHandler:"
    //          "source=%s", notification.c_str());

    auto search = notification_handlers_.find(notification);
    if( search != notification_handlers_.end()) {
        qCritical("CoreInterface::registerNotificationHandler:"
                  " ERROR: handler already exits for %s !!", notification.c_str ());
        return false;
    }

    notification_handlers_.emplace(std::make_pair(notification, handler));

    return true;
}

bool CoreInterface::registerDataSourceHandler(std::string source, DataSourceHandler handler)
{
    qCDebug(logCategoryCoreInterface) << "CoreInterface::registerDataSourceHanlder:"
                                      << QString("source=%1").arg(source.c_str());

    auto search = data_source_handlers_.find(source);
    if( search != data_source_handlers_.end()) {
        qCCritical(logCategoryCoreInterface) << "CoreInterface::registerDataSourceHanlder:"
                                             << QString(" ERROR: handler already exits for %1 !!").arg(source.c_str ());
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
