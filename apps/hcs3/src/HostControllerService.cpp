#include "HostControllerService.h"
#include "Client.h"
#include "ReplicatorCredentials.h"
#include "logging/LoggingQtCategories.h"

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

    // TODO: update config_ to use use QJson instead.
    rapidjson::Value& hcs_cfg = config_["host_controller_service"];

    if (hcs_cfg.HasMember("subscriber_address") == false) {
        return false;
    }

    strataServer_ = std::make_shared<strata::strataRPC::StrataServer>(hcs_cfg["subscriber_address"].GetString(), true, this);

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
    // connect(this, &HostControllerService::newMessageFromClient, this, &HostControllerService::parseMessageFromClient, Qt::QueuedConnection);

    // connect(&storageManager_, &StorageManager::downloadPlatformFilePathChanged, this, &HostControllerService::sendDownloadPlatformFilePathChangedMessage);
    // connect(&storageManager_, &StorageManager::downloadPlatformSingleFileProgress, this, &HostControllerService::sendDownloadPlatformSingleFileProgressMessage);
    // connect(&storageManager_, &StorageManager::downloadPlatformSingleFileFinished, this, &HostControllerService::sendDownloadPlatformSingleFileFinishedMessage);
    // connect(&storageManager_, &StorageManager::downloadPlatformFilesFinished, this, &HostControllerService::sendDownloadPlatformFilesFinishedMessage);
    // connect(&storageManager_, &StorageManager::platformListResponseRequested, this, &HostControllerService::sendPlatformListMessage);
    // connect(&storageManager_, &StorageManager::downloadPlatformDocumentsProgress, this, &HostControllerService::sendPlatformDocumentsProgressMessage);
    // connect(&storageManager_, &StorageManager::platformDocumentsResponseRequested, this, &HostControllerService::sendPlatformDocumentsMessage);
    // connect(&storageManager_, &StorageManager::downloadControlViewFinished, this, &HostControllerService::sendDownloadControlViewFinishedMessage);
    // connect(&storageManager_, &StorageManager::downloadControlViewProgress, this, &HostControllerService::sendControlViewDownloadProgressMessage);
    // connect(&storageManager_, &StorageManager::platformMetaData, this, &HostControllerService::sendPlatformMetaData);

    // connect(&platformController_, &PlatformController::platformConnected, this, &HostControllerService::platformConnected);
    // connect(&platformController_, &PlatformController::platformDisconnected, this, &HostControllerService::platformDisconnected);
    // connect(&platformController_, &PlatformController::platformMessage, this, &HostControllerService::sendMessageToClients);

    // connect(&updateController_, &FirmwareUpdateController::progressOfUpdate, this, &HostControllerService::handleUpdateProgress);

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

    // rapidjson::Value& hcs_cfg = config_["host_controller_service"];

    // clients_.initialize(dispatcher_, hcs_cfg);
    strataServer_->initialize(); // on failure, this will emit an error signal
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
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "download_platform_filepath_changed");
    payload.insert("original_filepath", originalFilePath);
    payload.insert("effective_filepath", effectiveFilePath);

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendDownloadPlatformSingleFileProgressMessage(
        const QByteArray &clientId,
        const QString &filePath,
        qint64 bytesReceived,
        qint64 bytesTotal)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "download_platform_single_file_progress");
    payload.insert("filepath", filePath);
    payload.insert("bytes_received", bytesReceived);
    payload.insert("bytes_total", bytesTotal);

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendDownloadPlatformSingleFileFinishedMessage(
        const QByteArray &clientId,
        const QString &filePath,
        const QString &errorString)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "download_platform_single_file_finished");
    payload.insert("filepath", filePath);
    payload.insert("error_string", errorString);

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendDownloadPlatformFilesFinishedMessage(const QByteArray &clientId, const QString &errorString)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "download_platform_files_finished");
    if (errorString.isEmpty() == false) {
        payload.insert("error_string", errorString);
    }

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendPlatformListMessage(
        const QByteArray &clientId,
        const QJsonArray &platformList)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "all_platforms");
    payload.insert("list", platformList);

    message.insert("hcs::notification", payload);
    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
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
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "control_view_download_progress");
    payload.insert("url", partialUri);
    payload.insert("filepath", filePath);
    payload.insert("bytes_received", bytesReceived);
    payload.insert("bytes_total", bytesTotal);

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
}

void HostControllerService::sendPlatformMetaData(const QByteArray &clientId, const QString &classId, const QJsonArray &controlViewList, const QJsonArray &firmwareList, const QString &error)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "platform_meta_data");
    payload.insert("class_id", classId);

    if (error.isEmpty()) {
        payload.insert("control_views", controlViewList);
        payload.insert("firmwares", firmwareList);
    } else {
        payload.insert("error", error);
    }

    message.insert("hcs::notification", payload);

    doc.setObject(message);
    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
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
        {"type", "download_view_finished"},
        {"url", partialUri},
        {"filepath", filePath},
        {"error_string", errorString}
    };

    QJsonObject message {
        {"hcs::notification", payload}
    };

    QJsonDocument doc(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));
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
    QByteArray deviceId = payload.value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        qCWarning(logCategoryHcs) << "device_id attribute is empty or has bad format";
        return;
    }

    QString path = payload.value("path").toString();
    if (path.isEmpty()) {
        qCWarning(logCategoryHcs) << "path attribute is empty or has bad format";
        return;
    }

    QUrl firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(path));

    QString firmwareMD5 = payload.value("md5").toString();
    if (firmwareMD5.isEmpty()) {
        // If 'md5' attribute is empty firmware will be downloaded, but checksum will not be verified.
        qCWarning(logCategoryHcs) << "md5 attribute is empty or has bad format";
    }

    updateController_.updateFirmware(clientId, deviceId, firmwareUrl, firmwareMD5);
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
    QString operation;
    switch (progress.operation) {
    case FirmwareUpdateController::UpdateOperation::Download :
        operation = "download";
        break;
    case FirmwareUpdateController::UpdateOperation::Prepare :
        operation = "prepare";
        break;
    case FirmwareUpdateController::UpdateOperation::Backup :
        operation = "backup";
        break;
    case FirmwareUpdateController::UpdateOperation::Flash :
        operation = "flash";
        break;
    case FirmwareUpdateController::UpdateOperation::Restore :
        operation = "restore";
        break;
    case FirmwareUpdateController::UpdateOperation::Finished :
        operation = "finished";
        break;
    }

    QString status;
    switch (progress.status) {
    case FirmwareUpdateController::UpdateStatus::Running :
        status = "running";
        break;
    case FirmwareUpdateController::UpdateStatus::Success :
        status = "success";
        break;
    case FirmwareUpdateController::UpdateStatus::Unsuccess :
        status = "unsuccess";
        break;
    case FirmwareUpdateController::UpdateStatus::Failure :
        status = "failure";
        break;
    }

    QJsonObject payload;
    payload.insert("type", "firmware_update");
    payload.insert("device_id", QLatin1String(deviceId));
    payload.insert("operation", operation);
    payload.insert("status", status);
    payload.insert("complete", progress.complete);
    payload.insert("total", progress.total);
    payload.insert("download_error", progress.downloadError);
    payload.insert("prepare_error", progress.prepareError);
    payload.insert("backup_error", progress.backupError);
    payload.insert("flash_error", progress.flashError);
    payload.insert("restore_error", progress.restoreError);

    QJsonDocument doc;
    QJsonObject message;
    message.insert("hcs::notification", payload);
    doc.setObject(message);

    clients_.sendMessage(clientId, doc.toJson(QJsonDocument::Compact));

    if (progress.operation == FirmwareUpdateController::UpdateOperation::Finished &&
            progress.status == FirmwareUpdateController::UpdateStatus::Success) {
        // If firmware was updated broadcast new platforms list
        // to indicate the firmware version has changed.
        broadcastMessage(platformController_.createPlatformsList());
    }
}

void HostControllerService::processCmdRequestHcsStatus(const strata::strataRPC::Message &message)
{
    strataServer_->notifyClient(message, QJsonObject{{"status", "hcs_active"}},
                                strata::strataRPC::ResponseType::Response);
}

void HostControllerService::processCmdLoadDocuments(const strata::strataRPC::Message &message)
{
    qCCritical(logCategoryHcs) << "Handler not implemented yet";
    strataServer_->notifyClient(message, QJsonObject{{"message", "not implemented yet"}},
                                strata::strataRPC::ResponseType::Error);
}

void HostControllerService::processCmdDownloadFiles(const strata::strataRPC::Message &message) 
{
    qCCritical(logCategoryHcs) << "Handler not implemented yet";
    strataServer_->notifyClient(message, QJsonObject{{"message", "not implemented yet"}},
                                strata::strataRPC::ResponseType::Error);
}

void HostControllerService::processCmdDynamicPlatformList(const strata::strataRPC::Message &message) 
{
    qCCritical(logCategoryHcs) << "Handler not implemented yet";
    strataServer_->notifyClient(message, QJsonObject{{"message", "not implemented yet"}},
                                strata::strataRPC::ResponseType::Error);
}

void HostControllerService::processCmdUpdateFirmware(const strata::strataRPC::Message &message) 
{
    qCCritical(logCategoryHcs) << "Handler not implemented yet";
    strataServer_->notifyClient(message, QJsonObject{{"message", "not implemented yet"}},
                                strata::strataRPC::ResponseType::Error);
}

void HostControllerService::processCmdDownlodView(const strata::strataRPC::Message &message) 
{
    qCCritical(logCategoryHcs) << "Handler not implemented yet";
    strataServer_->notifyClient(message, QJsonObject{{"message", "not implemented yet"}},
                                strata::strataRPC::ResponseType::Error);
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
    } else {
        qCWarning(logCategoryHcs).nospace().noquote()
                << "unhandled command from client: 0x" << clientId.toHex()
                << " " << cmdName;
    }
}
