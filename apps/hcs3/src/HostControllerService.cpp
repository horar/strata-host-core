#include "HostControllerService.h"
#include "Client.h"
#include "ReplicatorCredentials.h"
#include "logging/LoggingQtCategories.h"
#include "JsonStrings.h"
#include "PlatformDocument.h"

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QUuid>
#include <QLatin1String>


HostControllerService::HostControllerService(QObject* parent)
    : QObject(parent),
      downloadManager_(&networkManager_),
      storageManager_(&downloadManager_),
      dispatcher_{std::make_shared<HCS_Dispatcher>()}
{
}

HostControllerService::~HostControllerService()
{
    stop();
}

bool HostControllerService::initialize(const QString& config)
{
    if (parseConfig(config) == false) {
        return false;
    }

    dispatcher_->setMsgHandler(std::bind(&HostControllerService::handleMessage, this, std::placeholders::_1) );

    QString baseFolder{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
    if (config_.HasMember("stage")) {
        rapidjson::Value &devStage = config_["stage"];
        if (devStage.IsString()) {
            std::string stage(devStage.GetString(), devStage.GetStringLength());
            std::transform(stage.begin(), stage.end(), stage.begin(), ::toupper);
            qCInfo(logCategoryHcs, "Running in %s setup", qUtf8Printable(stage.data()));
            baseFolder += QString("/%1").arg(qUtf8Printable(stage.data()));
            QDir baseFolderDir{baseFolder};
            if (baseFolderDir.exists() == false) {
                qCDebug(logCategoryHcs) << "Creating base folder" << baseFolder << "-" << baseFolderDir.mkpath(baseFolder);
            }
        }
    }

    storageManager_.setBaseFolder(baseFolder);

    rapidjson::Value& db_cfg = config_["database"];

    if (db_.open(baseFolder, "strata_db") == false) {
        qCCritical(logCategoryHcs) << "Failed to open database.";
        return false;
    }

    // TODO: Will resolved in SCT-517
    //db_.addReplChannel("platform_list");

    //To process requests in the main thread. Not in dispatcher's thread.
    connect(this, &HostControllerService::newMessageFromClient, this, &HostControllerService::parseMessageFromClient, Qt::QueuedConnection);

    connect(&storageManager_, &StorageManager::downloadPlatformFilePathChanged, this, &HostControllerService::sendDownloadPlatformFilePathChangedMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformSingleFileProgress, this, &HostControllerService::sendDownloadPlatformSingleFileProgressMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformSingleFileFinished, this, &HostControllerService::sendDownloadPlatformSingleFileFinishedMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformFilesFinished, this, &HostControllerService::sendDownloadPlatformFilesFinishedMessage);
    connect(&storageManager_, &StorageManager::platformListResponseRequested, this, &HostControllerService::sendPlatformListMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformDocumentsProgress, this, &HostControllerService::sendPlatformDocumentsProgressMessage);
    connect(&storageManager_, &StorageManager::platformDocumentsResponseRequested, this, &HostControllerService::sendPlatformDocumentsMessage);
    connect(&storageManager_, &StorageManager::downloadControlViewFinished, this, &HostControllerService::sendDownloadControlViewFinishedMessage);
    connect(&storageManager_, &StorageManager::downloadControlViewProgress, this, &HostControllerService::sendControlViewDownloadProgressMessage);
    connect(&storageManager_, &StorageManager::platformMetaData, this, &HostControllerService::sendPlatformMetaData);

    connect(&componentUpdateInfo_, &ComponentUpdateInfo::requestUpdateInfoFinished, this, &HostControllerService::sendUpdateInfoMessage);

    connect(&platformController_, &PlatformController::platformConnected, this, &HostControllerService::platformConnected);
    connect(&platformController_, &PlatformController::platformDisconnected, this, &HostControllerService::platformDisconnected);
    connect(&platformController_, &PlatformController::platformMessage, this, &HostControllerService::sendMessageToClients);
    connect(&platformController_, &PlatformController::bluetoothScanFinished, this, &HostControllerService::bluetoothScanFinished);
    connect(&platformController_, &PlatformController::connectDeviceFinished, this, &HostControllerService::connectDeviceFinished);
    connect(&platformController_, &PlatformController::connectDeviceFailed, this, &HostControllerService::connectDeviceFailed);
    connect(&platformController_, &PlatformController::disconnectDeviceFinished, this, &HostControllerService::disconnectDeviceFinished);
    connect(&platformController_, &PlatformController::disconnectDeviceFailed, this, &HostControllerService::disconnectDeviceFailed);

    connect(&updateController_, &FirmwareUpdateController::progressOfUpdate, this, &HostControllerService::handleUpdateProgress);

    QUrl baseUrl = QString::fromStdString(db_cfg["file_server"].GetString());

    qCInfo(logCategoryHcs) << "file_server url:" << baseUrl.toString();

    if (baseUrl.isValid() == false) {
        qCCritical(logCategoryHcs) << "Provided file_server url is not valid";
        return false;
    }

    if (baseUrl.scheme().isEmpty()) {
        qCCritical(logCategoryHcs) << "file_server url does not have scheme";
        return false;
    }

    storageManager_.setBaseUrl(baseUrl);
    storageManager_.setDatabase(&db_);

    db_.initReplicator(db_cfg["gateway_sync"].GetString(),
        std::string(ReplicatorCredentials::replicator_username).c_str(),
        std::string(ReplicatorCredentials::replicator_password).c_str());

    platformController_.initialize();

    updateController_.initialize(&platformController_, &downloadManager_);

    rapidjson::Value& hcs_cfg = config_["host_controller_service"];

    clients_.initialize(dispatcher_, hcs_cfg);
    return true;
}

void HostControllerService::start()
{
    if (dispatcherThread_.get_id() != std::thread::id()) {
        return;
    }

    dispatcherThread_ = std::thread(&HCS_Dispatcher::dispatch, dispatcher_.get());

    qCInfo(logCategoryHcs) << "Host controller service started.";
}

void HostControllerService::stop()
{
    clients_.stop();        // first stop "clients controller" and then stop "dispatcher" (dispatcher receives data from clients controller)

    bool stop_dispatcher = (dispatcherThread_.get_id() != std::thread::id());
    if (stop_dispatcher) {
        dispatcher_->stop();
        dispatcherThread_.join();
    }

    db_.stop();             // db should be stopped last for it receives requests from dispatcher

    if (stop_dispatcher)    // log only once and at the very end
        qCInfo(logCategoryHcs) << "Host controller service stoped.";
}

void HostControllerService::onAboutToQuit()
{
    stop();
}

void HostControllerService::sendDownloadPlatformFilePathChangedMessage(
        const QByteArray &clientId,
        const QString &originalFilePath,
        const QString &effectiveFilePath)
{
    QJsonObject payload {
        { "original_filepath", originalFilePath },
        { "effective_filepath", effectiveFilePath }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::downloadPlatformFilepathChanged, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendDownloadPlatformSingleFileProgressMessage(
        const QByteArray &clientId,
        const QString &filePath,
        qint64 bytesReceived,
        qint64 bytesTotal)
{
    QJsonObject payload {
        { "filepath", filePath },
        { "bytes_received", bytesReceived },
        { "bytes_total", bytesTotal }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::downloadPlatformSingleFileProgress, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendDownloadPlatformSingleFileFinishedMessage(
        const QByteArray &clientId,
        const QString &filePath,
        const QString &errorString)
{
    QJsonObject payload {
        { "filepath", filePath },
        { "error_string", errorString }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::downloadPlatformSingleFileFinished, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendDownloadPlatformFilesFinishedMessage(const QByteArray &clientId, const QString &errorString)
{
    QJsonObject payload;

    if (errorString.isEmpty() == false) {
        payload.insert("error_string", errorString);
    }

    QByteArray notification = createHcsNotification(hcsNotificationType::downloadPlatformSingleFileFinished, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendPlatformListMessage(
        const QByteArray &clientId,
        const QJsonArray &platformList)
{
    QJsonObject payload {
        { "list", platformList }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::allPlatforms, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendPlatformDocumentsProgressMessage(
        const QByteArray &clientId,
        const QString &classId,
        int filesCompleted,
        int filesTotal)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "document_progress");
    payload.insert("class_id", classId);
    payload.insert("files_completed", filesCompleted);
    payload.insert("files_total", filesTotal);

    message.insert("cloud::notification", payload);
    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendControlViewDownloadProgressMessage(
        const QByteArray &clientId,
        const QString &partialUri,
        const QString &filePath,
        qint64 bytesReceived,
        qint64 bytesTotal)
{
    QJsonObject payload {
        { "url", partialUri },
        { "filepath", filePath },
        { "bytes_received", bytesReceived },
        { "bytes_total", bytesTotal }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::controlViewDownloadProgress, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendPlatformMetaData(
        const QByteArray &clientId,
        const QString &classId,
        const QJsonArray &controlViewList,
        const QJsonArray &firmwareList,
        const QString &error)
{
    QJsonObject payload;

    payload.insert("class_id", classId);

    if (error.isEmpty()) {
        payload.insert("control_views", controlViewList);
        payload.insert("firmwares", firmwareList);
    } else {
        payload.insert("error", error);
    }

    QByteArray notification = createHcsNotification(hcsNotificationType::platformMetaData, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendPlatformDocumentsMessage(
        const QByteArray &clientId,
        const QString &classId,
        const QJsonArray &datasheetList,
        const QJsonArray &documentList,
        const QString &error)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "document");
    payload.insert("class_id", classId);

    if (error.isEmpty()) {
        payload.insert("datasheets", datasheetList);
        payload.insert("documents", documentList);
    } else {
        payload.insert("error", error);
    }

    message.insert("cloud::notification", payload);
    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendDownloadControlViewFinishedMessage(
        const QByteArray &clientId,
        const QString &partialUri,
        const QString &filePath,
        const QString &errorString)
{
    QJsonObject payload {
        { "url", partialUri },
        { "filepath", filePath },
        { "error_string", errorString }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::downloadViewFinished, payload, false);

    clients_.sendMessage(clientId, notification);
}

bool HostControllerService::parseConfig(const QString& config)
{
    QString filePath;
    if (config.isEmpty()) {
        filePath  = QDir(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)).filePath("hcs.config");
    }
    else {
        filePath = config;
    }

    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly) == false) {
        qCCritical(logCategoryHcs) << "Unable to open config file:" << filePath;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    rapidjson::Document configuration;
    if (configuration.Parse<rapidjson::kParseCommentsFlag>(data.data()).HasParseError()) {
        qCCritical(logCategoryHcs) << "Parse error on config file!";
        return false;
    }

    if ( ! configuration.HasMember("host_controller_service") ) {
        qCCritical(logCategoryHcs) << "ERROR: No Host Controller Configuration parameters.";
        return false;
    }

    config_ = std::move(configuration);
    return true;
}

void HostControllerService::handleMessage(const DispatcherMessage& msg)
{
    emit newMessageFromClient(msg.message, msg.from_client);
}

void HostControllerService::platformConnected(const QByteArray& deviceId)
{
    Q_UNUSED(deviceId)

    //send update to all clients
    broadcastMessage(platformController_.createPlatformsList());
}

void HostControllerService::platformDisconnected(const QByteArray& deviceId)
{
    Q_UNUSED(deviceId)

    //send update to all clients
    broadcastMessage(platformController_.createPlatformsList());
}

void HostControllerService::sendMessageToClients(const QString &platformId, const QString &message)
{
    Q_UNUSED(platformId)
    Client* client = getSenderClient();
    if (client != nullptr) {
        clients_.sendMessage(client->getClientId(), message);
    }
}

void HostControllerService::bluetoothScanFinished(const QJsonObject payload)
{
    QByteArray message = createHcsNotification(hcsNotificationType::bluetoothScan, payload, true);
    broadcastMessage(message);
}

void HostControllerService::connectDeviceFinished(const QByteArray &deviceId, const QByteArray &clientId)
{
    sendDeviceSuccess(hcsNotificationType::connectDevice, deviceId, clientId);
}

void HostControllerService::connectDeviceFailed(const QByteArray &deviceId, const QByteArray &clientId, const QString &errorMessage)
{
    sendDeviceError(hcsNotificationType::connectDevice, deviceId, clientId, errorMessage);
}

void HostControllerService::disconnectDeviceFinished(const QByteArray &deviceId, const QByteArray &clientId)
{
    sendDeviceSuccess(hcsNotificationType::disconnectDevice, deviceId, clientId);
}

void HostControllerService::disconnectDeviceFailed(const QByteArray &deviceId, const QByteArray &clientId, const QString &errorMessage)
{
    sendDeviceError(hcsNotificationType::disconnectDevice, deviceId, clientId, errorMessage);
}

// clients handler...

void HostControllerService::processCmdRequestHcsStatus(const QByteArray &clientId)
{
    QJsonDocument doc;
    QJsonObject object;

    object.insert("hcs::notification", "hcs_active");
    doc.setObject(object);

    QString message = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));

    clients_.sendMessage(clientId, message);
}

void HostControllerService::processCmdDynamicPlatformList(const QByteArray &clientId)
{
    storageManager_.requestPlatformList(clientId);

    clients_.sendMessage(clientId, platformController_.createPlatformsList());
}

void HostControllerService::processCmdClientUnregister(const QByteArray &clientId)
{
    qCWarning(logCategoryHcs) << "Deprecated command: \"cmd\":\"unregister\", use \"hcs::cmd\":\"unregister\" instead.";
    processCmdHostUnregister(clientId);
}

void HostControllerService::processCmdLoadDocuments(const QJsonObject &payload, const QByteArray &clientId)
{
    QString classId = payload.value("class_id").toString();
    if (classId.isEmpty()) {
        qCWarning(logCategoryHcs) << "class_id attribute is empty or has bad format";
        return;
    }

    storageManager_.requestPlatformDocuments(clientId, classId);
}

void HostControllerService::processCmdHostUnregister(const QByteArray &clientId)
{
    Client* client = getSenderClient();

    storageManager_.requestCancelAllDownloads(clientId);

    // Remove the client from the mapping
    current_client_ = nullptr;
    clientList_.remove(client);
    qCInfo(logCategoryHcs).nospace().noquote() << "Client unregistered: 0x" << clientId.toHex();
}

void HostControllerService::processCmdDownloadFiles(const QJsonObject &payload, const QByteArray &clientId)
{
    QStringList partialUriList;
    QString destinationDir = payload.value("destination_dir").toString();
    if (destinationDir.isEmpty()) {
        qCWarning(logCategoryHcs) << "destinationDir attribute is empty or has bad format";
        return;
    }

    QJsonValue filesValue = payload.value("files");
    if (filesValue.isArray() == false) {
        qCWarning(logCategoryHcs) << "files attribute is not an array";
        return;
    }

    QJsonArray files = filesValue.toArray();
    for (const QJsonValueRef value : files) {
        if (value.isString()) {
            partialUriList << value.toString();
        }
    }

    storageManager_.requestDownloadPlatformFiles(clientId, partialUriList, destinationDir);
}

void HostControllerService::processCmdUpdateFirmware(const QJsonObject &payload, const QByteArray &clientId)
{
    FirmwareUpdateController::ChangeFirmwareData firmwareData;
    firmwareData.clientId = clientId;
    firmwareData.action = FirmwareUpdateController::ChangeFirmwareAction::UpdateFirmware;

    QString errorString;
    do {
        firmwareData.deviceId = payload.value("device_id").toVariant().toByteArray();
        if (firmwareData.deviceId.isEmpty()) {
            errorString = "device_id attribute is empty or has bad format";
            break;
        }

        strata::platform::PlatformPtr platform = platformController_.getPlatform(firmwareData.deviceId);
        if (platform == nullptr) {
            errorString = "Platform " + firmwareData.deviceId + " doesn't exist";
            break;
        }

        // if firmwareClassId is available, flasher needs it (due to correct flashing of assisted boards)
        if (platform->controllerType() == strata::platform::Platform::ControllerType::Assisted) {
            firmwareData.firmwareClassId = platform->firmwareClassId();
        }

        if (payload.contains("path") || payload.contains("md5")) {
            //use provided firmware
            QString path = payload.value("path").toString();
            if (path.isEmpty()) {
                errorString = "path attribute is empty or has bad format";
                break;
            }

            firmwareData.firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(path));

            firmwareData.firmwareMD5 = payload.value("md5").toString();
            if (firmwareData.firmwareMD5.isEmpty()) {
                errorString = "md5 attribute is empty or has bad format";
                break;
            }
        } else {
            //find highest firmware
            if (platform->hasClassId() == false) {
                errorString = "platform has empty classId";
                break;
            }

            const FirmwareFileItem *firmware = storageManager_.findHighestFirmware(platform->classId());
            if (firmware == nullptr) {
                errorString = "No firmware for provided classId";
                break;
            }

            firmwareData.firmwareUrl = storageManager_.getBaseUrl().resolved(firmware->partialUri);
            firmwareData.firmwareMD5 = firmware->md5;
        }

        firmwareData.jobUuid = QUuid::createUuid().toString(QUuid::WithoutBraces);

        QJsonObject payloadBody {
            { "job_id", firmwareData.jobUuid },
            { "device_id", QLatin1String(firmwareData.deviceId) }
        };
        QByteArray notification = createHcsNotification(hcsNotificationType::updateFirmware, payloadBody, true);
        clients_.sendMessage(firmwareData.clientId, notification);

        updateController_.changeFirmware(firmwareData);

        return;

    } while (false);

    //send back error
    qCWarning(logCategoryHcs) <<  errorString;

    QJsonObject payloadBody {
        { "error_string", errorString },
        { "device_id", QLatin1String(firmwareData.deviceId) }
    };

    QByteArray notification = createHcsNotification(hcsNotificationType::updateFirmware, payloadBody, true);
    clients_.sendMessage(firmwareData.clientId, notification);
}

void HostControllerService::processCmdProgramController(const QJsonObject &payload, const QByteArray &clientId)
{
    FirmwareUpdateController::ChangeFirmwareData firmwareData;
    firmwareData.clientId = clientId;

    QString errorString;
    do {
        firmwareData.deviceId = payload.value("device_id").toVariant().toByteArray();
        if (firmwareData.deviceId.isEmpty()) {
            errorString = "device_id attribute is empty or has bad format";
            break;
        }

        strata::platform::PlatformPtr platform = platformController_.getPlatform(firmwareData.deviceId);
        if (platform == nullptr) {
            errorString = "Platform " + firmwareData.deviceId + " doesn't exist";
            break;
        }

        if (platform->isControllerConnectedToPlatform() == false) {
            errorString = "Controller (dongle) is not connected to platform";
            break;
        }

        firmwareData.firmwareClassId = platform->classId(); // class_id becomes the new fw_class_id
        QString controllerClassId = platform->controllerClassId();
        if (firmwareData.firmwareClassId.isEmpty() || controllerClassId.isEmpty()) {
            errorString = "Platform has no classId or controllerClassId";
            break;
        }

        const FirmwareFileItem *firmware = storageManager_.findHighestFirmware(firmwareData.firmwareClassId, controllerClassId);
        if (firmware == nullptr) {
            errorString = "No compatible firmware for your combination of controller and platform";
            break;
        }
        firmwareData.firmwareUrl = storageManager_.getBaseUrl().resolved(firmware->partialUri);
        firmwareData.firmwareMD5 = firmware->md5;

        QString currentMD5; // get md5 accorging to old fw_class_id and fw version
        if (platform->applicationVer().isEmpty() == false
                && platform->firmwareClassId().isNull() == false
                && platform->firmwareClassId().isEmpty() == false) {
            firmware = storageManager_.findFirmware(platform->firmwareClassId(), controllerClassId, platform->applicationVer());
            if (firmware == nullptr) {
                errorString = "No compatible firmware";
                break;
            }

            currentMD5 = firmware->md5;
        } else {
            qCInfo(logCategoryHcs) << platform << "Platform has probably no firmware.";
        }

        if (currentMD5.isEmpty()) {
            qCWarning(logCategoryHcs) << platform << "Cannot get MD5 of curent firmware from database.";
        }

        firmwareData.jobUuid = QUuid::createUuid().toString(QUuid::WithoutBraces);

        QJsonObject payloadBody {
            { "job_id", firmwareData.jobUuid },
            { "device_id", QLatin1String(firmwareData.deviceId) }
        };
        QByteArray notification = createHcsNotification(hcsNotificationType::programController, payloadBody, true);
        clients_.sendMessage(firmwareData.clientId, notification);

        if (currentMD5 != firmwareData.firmwareMD5
                || firmwareData.firmwareMD5.isEmpty()
                || currentMD5.isEmpty()) {
            firmwareData.action = FirmwareUpdateController::ChangeFirmwareAction::ProgramController;
        } else {
            firmwareData.action = FirmwareUpdateController::ChangeFirmwareAction::SetControllerFwClassId;
        }
        updateController_.changeFirmware(firmwareData);

        return;

    } while (false);

    qCWarning(logCategoryHcs).noquote() << errorString;

    QJsonObject payloadBody {
        { "error_string", errorString },
        { "device_id", QLatin1String(firmwareData.deviceId) }
    };
    QByteArray notification = createHcsNotification(hcsNotificationType::programController, payloadBody, true);
    clients_.sendMessage(firmwareData.clientId, notification);
}

void HostControllerService::processCmdDownlodView(const QJsonObject &payload, const QByteArray &clientId)
{
    QString url = payload.value("url").toString();
    if (url.isEmpty()) {
        qCWarning(logCategoryHcs) << "url attribute is empty or has bad format";
        return;
    }

    QString md5 = payload.value("md5").toString();
    if (md5.isEmpty()) {
        qCWarning(logCategoryHcs) << "md5 attribute is empty or has bad format";
        return;
    }

    QString classId = payload.value("class_id").toString();
    if (classId.isEmpty()) {
        qCWarning(logCategoryHcs) << "class_id attribute is empty or has bad format";
        return;
    }

    storageManager_.requestDownloadControlView(clientId, url, md5, classId);
}

void HostControllerService::processCmdBluetoothScan()
{
    platformController_.startBluetoothScan();
}

void HostControllerService::processCmdConnectDevice(const QJsonObject &payload, const QByteArray &clientId)
{
    QByteArray deviceId = payload.value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        sendDeviceError(hcsNotificationType::connectDevice, QByteArray(), clientId, "device_id attribute is empty or has bad format");
        return;
    }

    platformController_.connectDevice(deviceId, clientId);
}

void HostControllerService::processCmdDisconnectDevice(const QJsonObject &payload, const QByteArray &clientId)
{
    QByteArray deviceId = payload.value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        sendDeviceError(hcsNotificationType::disconnectDevice, QByteArray(), clientId, "device_id attribute is empty or has bad format");
        return;
    }

    platformController_.disconnectDevice(deviceId, clientId);
}

Client* HostControllerService::getClientById(const QByteArray& clientId)
{
    auto findIt = std::find_if(clientList_.begin(), clientList_.end(),
                               [&](Client* val) { return clientId == val->getClientId(); }  );

    return (findIt != clientList_.end()) ? *findIt : nullptr;
}


void HostControllerService::parseMessageFromClient(const QByteArray &message, const QByteArray &clientId)
{
    //check the client's ID (dealer_id) is in list
    Client* client = getClientById(clientId);
    if (client == nullptr) {
        qCInfo(logCategoryHcs).nospace().noquote() << "new Client: 0x" << clientId.toHex();

        client = new Client(clientId);
        clientList_.push_back(client);
    }

    current_client_ = client;

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        qCWarning(logCategoryHcs).nospace().noquote()
                << "invalid json from client 0x" << clientId.toHex()
                << ", error:" << parseError.errorString();
        return;
    }

    if (doc.isObject() == false) {
        qCWarning(logCategoryHcs).nospace().noquote()
                << "invalid json from client 0x" << clientId.toHex()
                << ", error: document is not an object";
        return;
    }

    QJsonObject rootObject = doc.object();

    //forward message to device
    if (rootObject.contains("device_id")) {
        QByteArray deviceId = rootObject.value("device_id").toVariant().toByteArray();
        if (deviceId.isEmpty()) {
            qCCritical(logCategoryHcs) << "bad format of device_id";
            return;
        }

        platformController_.sendMessage(deviceId, message);
        return;
    }

    //process message in HCS
    QJsonObject payload = rootObject.value("payload").toObject();

    if (rootObject.contains("hcs::cmd")) {
        QString cmdName = rootObject.value("hcs::cmd").toString();
        callHandlerForTypeHcsCmd(cmdName, payload, clientId);
    } else if (rootObject.contains("cmd")) {
        QString cmdName = rootObject.value("cmd").toString();
        callHandlerForTypeCmd(cmdName, payload, clientId);
    } else {
        qCWarning(logCategoryHcs).nospace().noquote()
                << "unhandled command from client: 0x" << clientId.toHex();
        return;
    }
}

bool HostControllerService::broadcastMessage(const QString& message)
{
    qCInfo(logCategoryHcs).noquote().nospace() << "broadcast msg: '" << message << "'";
    for(auto item : clientList_) {
        const QByteArray clientId = item->getClientId();
        clients_.sendMessage(clientId, message);
    }

    return false;
}

void HostControllerService::handleUpdateProgress(const QByteArray& deviceId, const QByteArray& clientId, FirmwareUpdateController::UpdateProgress progress)
{
    Q_UNUSED(deviceId)

    QString jobType;
    switch (progress.operation) {
    case FirmwareUpdateController::UpdateOperation::Download :
        jobType = "download_progress";
        break;
    case FirmwareUpdateController::UpdateOperation::ClearFwClassId :
        jobType = "clear_fw_class_id";
        break;
    case FirmwareUpdateController::UpdateOperation::SetFwClassId :
        jobType = "set_fw_class_id";
        break;
    case FirmwareUpdateController::UpdateOperation::Prepare :
        jobType = "prepare";
        break;
    case FirmwareUpdateController::UpdateOperation::Backup :
        jobType = "backup_progress";
        break;
    case FirmwareUpdateController::UpdateOperation::Flash :
        jobType = "flash_progress";
        break;
    case FirmwareUpdateController::UpdateOperation::Restore :
        jobType = "restore_progress";
        break;
    case FirmwareUpdateController::UpdateOperation::Finished :
        jobType = "finished";
        // Do not send progress information in this job type.
        progress.complete = -1;
        progress.total = -1;
        break;
    }

    QString jobStatus;
    if (progress.operation == FirmwareUpdateController::UpdateOperation::Finished) {
        switch (progress.status) {
        case FirmwareUpdateController::UpdateStatus::Running :
        case FirmwareUpdateController::UpdateStatus::Success :
            jobStatus = "success";
            break;
        case FirmwareUpdateController::UpdateStatus::Unsuccess :
            jobStatus = "unsuccess";
            break;
        case FirmwareUpdateController::UpdateStatus::Failure :
            jobStatus = "failure";
            break;
        }
    } else {
        if (progress.status == FirmwareUpdateController::UpdateStatus::Running) {
            jobStatus = "running";
        } else {
            jobStatus = "failure";
        }
    }

    QJsonObject payload {
        { "job_id", progress.jobUuid },
        { "job_type", jobType },
        { "job_status", jobStatus }
    };
    if ((progress.complete >= 0) && (progress.total >= 0)) {
        payload.insert("complete", progress.complete);
        payload.insert("total", progress.total);
    }
    if (progress.status == FirmwareUpdateController::UpdateStatus::Failure ||
            progress.status == FirmwareUpdateController::UpdateStatus::Unsuccess) {
        payload.insert("error_string", progress.error);
    }
    hcsNotificationType type = (progress.programController)
            ? hcsNotificationType::programControllerJob
            : hcsNotificationType::updateFirmwareJob;
    QByteArray notification = createHcsNotification(type, payload, true);

    // This notification must be sent before broadcasting new platforms list.
    // Message order is very important for Developer Studio.
    clients_.sendMessage(clientId, notification);

    if (progress.operation == FirmwareUpdateController::UpdateOperation::Finished &&
            progress.status == FirmwareUpdateController::UpdateStatus::Success) {
        // If firmware was updated broadcast new platforms list
        // to indicate the firmware version has changed.
        broadcastMessage(platformController_.createPlatformsList());
    }
}

const char* HostControllerService::hcsNotificationTypeToString(hcsNotificationType notificationType)
{
    const char* type = "";

    switch (notificationType) {
    case hcsNotificationType::downloadPlatformFilepathChanged:
        type = "download_platform_filepath_changed";
        break;
    case hcsNotificationType::downloadPlatformSingleFileProgress:
        type = "download_platform_single_file_progress";
        break;
    case hcsNotificationType::downloadPlatformSingleFileFinished:
        type = "download_platform_single_file_finished";
        break;
    case hcsNotificationType::downloadPlatformFilesFinished:
        type = "download_platform_files_finished";
        break;
    case hcsNotificationType::allPlatforms:
        type = "all_platforms";
        break;
    case hcsNotificationType::platformMetaData:
        type = "platform_meta_data";
        break;
    case hcsNotificationType::controlViewDownloadProgress:
        type = "control_view_download_progress";
        break;
    case hcsNotificationType::downloadViewFinished:
        type = "download_view_finished";
        break;
    case hcsNotificationType::updatesAvailable:
        type = "updates_available";
        break;
    case hcsNotificationType::updateFirmware:
        type = "update_firmware";
        break;
   case hcsNotificationType::updateFirmwareJob:
        type = "update_firmware_job";
        break;
    case hcsNotificationType::programController:
        type = "program_controller";
        break;
    case hcsNotificationType::programControllerJob:
        type = "program_controller_job";
        break;
    case hcsNotificationType::bluetoothScan:
        type = "bluetooth_scan";
        break;
    case hcsNotificationType::connectDevice:
        type = "connect_device";
        break;
    case hcsNotificationType::disconnectDevice:
        type = "disconnect_device";
        break;
    }

    return type;
}

QByteArray HostControllerService::createHcsNotification(hcsNotificationType notificationType, const QJsonObject &payload, bool standalonePayload)
{
    const char* type = hcsNotificationTypeToString(notificationType);
    QJsonObject notificationBody {
        { "type", type }
        //, { "payload", payload }  // TODO uncomment this when all notifications will have standalone payload
    };

    // workaround for support of old notification style (without standalone paylod object)
    if (standalonePayload) {
        notificationBody.insert("payload", payload);
    } else {
        for (auto it = payload.constBegin(); it != payload.constEnd(); ++it) {
            notificationBody.insert(it.key(), it.value());
        }
    }

    QJsonObject message {
        { "hcs::notification", notificationBody }
    };

    QJsonDocument doc(message);

    return doc.toJson(QJsonDocument::Compact);
}

void HostControllerService::sendDeviceError(hcsNotificationType notificationType, const QByteArray& deviceId, const QByteArray& clientId, const QString &errorString)
{
    QJsonObject payloadBody {
        { "error_string", errorString },
        { "device_id", QLatin1String(deviceId) }
    };
    QByteArray notification = createHcsNotification(notificationType, payloadBody, true);
    clients_.sendMessage(clientId, notification);
}

void HostControllerService::sendDeviceSuccess(hcsNotificationType notificationType, const QByteArray& deviceId, const QByteArray& clientId)
{
    QJsonObject payloadBody {
        { "device_id", QLatin1String(deviceId) }
    };
    QByteArray notification = createHcsNotification(notificationType, payloadBody, true);
    clients_.sendMessage(clientId, notification);
}

void HostControllerService::processCmdCheckForUpdates(const QByteArray &clientId )
{
    componentUpdateInfo_.requestUpdateInfo(clientId);
}

void HostControllerService::sendUpdateInfoMessage(const QByteArray &clientId, const QJsonArray &componentList, const QString &errorString)
{
    QJsonObject payload;
    if ((componentList.isEmpty() == false) || errorString.isEmpty()) {  // if list is empty, but no error is set, it means we have no updates available
        payload.insert("component_list", componentList);
    }
    if (errorString.isEmpty() == false) {
        payload.insert("error_string", errorString);
    }

    QByteArray notification = createHcsNotification(hcsNotificationType::updatesAvailable, payload, false);

    clients_.sendMessage(clientId, notification);
}

void HostControllerService::callHandlerForTypeCmd(
        const QString &cmdName,
        const QJsonObject &payload,
        const QByteArray &clientId)
{
    if (cmdName == "request_hcs_status") {
        processCmdRequestHcsStatus(clientId);
    } else if (cmdName == "unregister") {
        processCmdClientUnregister(clientId);
    } else if (cmdName == "load_documents") {
        processCmdLoadDocuments(payload, clientId);
    } else {
        qCWarning(logCategoryHcs).nospace().noquote()
                << "unhandled command from client: 0x" << clientId.toHex()
                << " " << cmdName;
    }
}

void HostControllerService::callHandlerForTypeHcsCmd(
        const QString &cmdName,
        const QJsonObject &payload,
        const QByteArray &clientId)
{
    if (cmdName == "download_files") {
        processCmdDownloadFiles(payload, clientId);
    } else if (cmdName == "dynamic_platform_list") {
        processCmdDynamicPlatformList(clientId);
    } else if (cmdName == "update_firmware") {
        processCmdUpdateFirmware(payload, clientId);
    } else if (cmdName == "download_view") {
        processCmdDownlodView(payload, clientId);
    } else if (cmdName == "unregister") {
        processCmdHostUnregister(clientId);
    } else if (cmdName == "check_for_updates") {
        processCmdCheckForUpdates(clientId);
    } else if (cmdName == "program_controller") {
        processCmdProgramController(payload, clientId);
    } else if (cmdName == "bluetooth_scan") {
        processCmdBluetoothScan();
    } else if (cmdName == "connect_device") {
        processCmdConnectDevice(payload, clientId);
    } else if (cmdName == "disconnect_device") {
        processCmdDisconnectDevice(payload, clientId);
    } else {
        qCWarning(logCategoryHcs).nospace().noquote()
                << "unhandled command from client: 0x" << clientId.toHex()
                << " " << cmdName;
    }
}
