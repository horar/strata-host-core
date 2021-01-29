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
    //handlers for 'cmd'
    clientCmdHandler_.insert( { QByteArray("request_hcs_status"), std::bind(&HostControllerService::onCmdHCSStatus, this, std::placeholders::_1) });
    clientCmdHandler_.insert( { QByteArray("unregister"), std::bind(&HostControllerService::onCmdUnregisterClient, this, std::placeholders::_1) } );
    clientCmdHandler_.insert( { QByteArray("load_documents"), std::bind(&HostControllerService::onCmdLoadDocuments, this, std::placeholders::_1) } );

    hostCmdHandler_.insert( { QByteArray("download_files"), std::bind(&HostControllerService::onCmdHostDownloadFiles, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { QByteArray("dynamic_platform_list"), std::bind(&HostControllerService::onCmdDynamicPlatformList, this, std::placeholders::_1) } );
    hostCmdHandler_.insert( { QByteArray("update_firmware"), std::bind(&HostControllerService::onCmdUpdateFirmware, this, std::placeholders::_1) } );
    hostCmdHandler_.insert( { QByteArray("download_view"), std::bind(&HostControllerService::onCmdDownloadControlView, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { QByteArray("unregister"), std::bind(&HostControllerService::onCmdHostUnregister, this, std::placeholders::_1) });
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

    if (db_.open(baseFolder.toStdString(), "strata_db") == false) {
        qCCritical(logCategoryHcs) << "Failed to open database.";
        return false;
    }

    // TODO: Will resolved in SCT-517
    //db_.addReplChannel("platform_list");

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

    /* We dont want to call these StorageManager methods directly
     * as they should be executed in the main thread. Not in dispatcher's thread. */
    connect(this, &HostControllerService::platformListRequested, &storageManager_, &StorageManager::requestPlatformList, Qt::QueuedConnection);
    connect(this, &HostControllerService::platformDocumentsRequested, &storageManager_, &StorageManager::requestPlatformDocuments, Qt::QueuedConnection);
    connect(this, &HostControllerService::downloadPlatformFilesRequested, &storageManager_, &StorageManager::requestDownloadPlatformFiles, Qt::QueuedConnection);
    connect(this, &HostControllerService::cancelPlatformDocumentRequested, &storageManager_, &StorageManager::requestCancelAllDownloads, Qt::QueuedConnection);
    connect(this, &HostControllerService::downloadControlViewRequested, &storageManager_, &StorageManager::requestDownloadControlView, Qt::QueuedConnection);

    connect(this, &HostControllerService::firmwareUpdateRequested, &updateController_, &FirmwareUpdateController::updateFirmware, Qt::QueuedConnection);

    connect(&boardsController_, &BoardController::boardConnected, this, &HostControllerService::platformConnected);
    connect(&boardsController_, &BoardController::boardDisconnected, this, &HostControllerService::platformDisconnected);
    connect(&boardsController_, &BoardController::boardMessage, this, &HostControllerService::sendMessageToClients);

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

    boardsController_.initialize();

    updateController_.initialize(&boardsController_, &downloadManager_);

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

void HostControllerService::handleMessage(const PlatformMessage& msg)
{
    switch (msg.msg_type)
    {
        case PlatformMessage::eMsgClientMessage:
            handleClientMsg(msg);
            break;
        default:
            assert(false);
            break;
    }
}

void HostControllerService::platformConnected(const int deviceId)
{
    Q_UNUSED(deviceId)

    //send update to all clients
    broadcastMessage(boardsController_.createPlatformsList());
}

void HostControllerService::platformDisconnected(const int deviceId)
{
    Q_UNUSED(deviceId)

    //send update to all clients
    broadcastMessage(boardsController_.createPlatformsList());
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
void HostControllerService::onCmdHCSStatus(const rapidjson::Value* )
{
    Client* client = getSenderClient();
    Q_ASSERT(client);

    rapidjson::Document doc;
    doc.SetObject();
    doc.AddMember("hcs::notification", "hcs_active", doc.GetAllocator() );

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    clients_.sendMessage(client->getClientId(), strbuf.GetString() );
}

void HostControllerService::onCmdDynamicPlatformList(const rapidjson::Value * )
{
    emit platformListRequested(getSenderClient()->getClientId());
}

void HostControllerService::onCmdUnregisterClient(const rapidjson::Value* )
{
    Client* client = getSenderClient();
    Q_ASSERT(client);

    qCWarning(logCategoryHcs) << "Deprecated command: \"cmd\":\"unregister\", use \"hcs::cmd\":\"unregister\" instead.";
    onCmdHostUnregister(nullptr);
}

void HostControllerService::onCmdLoadDocuments(const rapidjson::Value* payload)
{
    Client* client = getSenderClient();
    if (client == nullptr) {
        qCCritical(logCategoryHcs) << "sender client is missing";
        return;
    }

    if (!payload->HasMember("class_id")) {
        qCCritical(logCategoryHcs) << "class_id key is missing";
        return;
    }

    QString classId = QString::fromStdString((*payload)["class_id"].GetString());
    if (classId.isEmpty()) {
        qCCritical(logCategoryHcs) << "class_id is empty";
        return;
    }

    QByteArray clientId = client->getClientId();
    emit platformDocumentsRequested(clientId, classId);
}

void HostControllerService::onCmdHostUnregister(const rapidjson::Value* )
{
    Client* client = getSenderClient();
    Q_ASSERT(client);

    QByteArray clientId = client->getClientId();

    emit cancelPlatformDocumentRequested(clientId);

    // Remove the client from the mapping
    current_client_ = nullptr;
    clientList_.remove(client);
    qCInfo(logCategoryHcs) << "Client unregistered: " << clientId.toHex();
}

void HostControllerService::onCmdHostDownloadFiles(const rapidjson::Value* payload)
{
    QByteArray clientId = getSenderClient()->getClientId();
    QStringList partialUriList;

    QString destinationDir = QString::fromStdString((*payload)["destination_dir"].GetString());
    if (destinationDir.isEmpty()) {
        qCWarning(logCategoryHcs) << "destinationDir attribute is empty";
        return;
    }

    const rapidjson::Value& files = (*payload)["files"];
    if (files.IsArray() == false) {
        qCWarning(logCategoryHcs) << "files attribute is not an array";
        return;
    }

    for (auto it = files.Begin(); it != files.End(); ++it) {
        partialUriList << QString::fromStdString((*it).GetString());
    }

    emit downloadPlatformFilesRequested(clientId, partialUriList, destinationDir);
}

void HostControllerService::onCmdUpdateFirmware(const rapidjson::Value *payload)
{
    QByteArray clientId = getSenderClient()->getClientId();

    const rapidjson::Value& deviceIdValue = (*payload)["device_id"];
    if (deviceIdValue.IsInt() == false) {
        qCWarning(logCategoryHcs) << "device_id attribute has bad format";
        return;
    }
    int deviceId = deviceIdValue.GetInt();

    QString path = QString::fromStdString((*payload)["path"].GetString());
    if (path.isEmpty()) {
        qCWarning(logCategoryHcs) << "path attribute is empty";
        return;
    }
    QUrl firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(path));

    QString firmwareMD5 = QString::fromStdString((*payload)["md5"].GetString());
    if (firmwareMD5.isEmpty()) {
        // If 'md5' attribute is empty firmware will be downloaded, but checksum will not be verified.
        qCWarning(logCategoryHcs) << "md5 attribute is empty";
    }

    emit firmwareUpdateRequested(clientId, deviceId, firmwareUrl, firmwareMD5);
}

void HostControllerService::onCmdDownloadControlView(const rapidjson::Value* payload)
{
    QByteArray clientId = getSenderClient()->getClientId();

    QString partialUri = QString::fromStdString((*payload)["url"].GetString());
    if (partialUri.isEmpty()) {
        qCWarning(logCategoryHcs) << "url attribute is empty";
        return;
    }

    QString md5 = QString::fromStdString((*payload)["md5"].GetString());
    if (md5.isEmpty()) {
        qCWarning(logCategoryHcs) << "md5 attribute is empty";
        return;
    }

    QString class_id = QString::fromStdString((*payload)["class_id"].GetString());
    if (class_id.isEmpty()) {
        qCWarning(logCategoryHcs) << "class_id attribute is empty";
    }

    emit downloadControlViewRequested(clientId, partialUri, md5, class_id);
}

Client* HostControllerService::getClientById(const QByteArray& client_id)
{
    auto findIt = std::find_if(clientList_.begin(), clientList_.end(),
                               [&](Client* val) { return client_id == val->getClientId(); }  );

    return (findIt != clientList_.end()) ? *findIt : nullptr;
}

void HostControllerService::handleClientMsg(const PlatformMessage& msg)
{
    QByteArray clientId = msg.from_client;

    //check the client's ID (dealer_id) is in list
    Client* client = getClientById(clientId);
    if (client == nullptr) {
        qCInfo(logCategoryHcs) << "new Client:" << clientId.toHex();

        client = new Client(clientId);
        clientList_.push_back(client);
    }

    current_client_ = client;

    rapidjson::Document service_command;
    if (service_command.Parse(msg.message.constData(), msg.message.size()).HasParseError()) {
        qCWarning(logCategoryHcs) << "Client:" << clientId.toHex() << "parse error!";
        return;
    }

    auto firstIt = service_command.MemberBegin();
    QByteArray msg_type(firstIt->name.GetString(), firstIt->name.GetStringLength());

    rapidjson::Value* payload = nullptr;
    if (service_command.HasMember("payload")) {
        payload = &(service_command["payload"]);
    }

    if (service_command.HasMember("device_id")) {
        if (service_command["device_id"].IsInt() == false) {
            qCCritical(logCategoryHcs) << "device_id is not integer";
            return;
        }

        boardsController_.sendMessage(service_command["device_id"].GetInt(), msg.message);
        return;
    }

    QByteArray cmd_name(firstIt->value.GetString(), firstIt->value.GetStringLength());
    qCInfo(logCategoryHcs) << "Client:" << clientId.toHex() << "Type:" << msg_type << "cmd:" << cmd_name;

    if (msg_type == "hcs::cmd") {

        auto findIt = hostCmdHandler_.find(cmd_name);
        if (findIt == hostCmdHandler_.end()) {
            //TODO: error handling...
            qCWarning(logCategoryHcs) << "Unhandled command" <<  "Client:" << clientId.toHex() << "Type:" << msg_type << "cmd:" << cmd_name;
            return;
        }

        findIt->second(payload);
    }
    else if (msg_type == "cmd") {

        auto findIt = clientCmdHandler_.find(cmd_name);
        if (findIt == clientCmdHandler_.end()) {
            qCWarning(logCategoryHcs) << "Unhandled command" <<  "Client:" << clientId.toHex() << "Type:" << msg_type << "cmd:" << cmd_name;
            return;
        }

        findIt->second(payload);
    }
    else {
        qCWarning(logCategoryHcs) << "Unhandled command type" <<  "Client:" << clientId.toHex() << "Type:" << msg_type << "cmd:" << cmd_name;
        return;
    }
}

bool HostControllerService::broadcastMessage(const QString& message)
{
    qCInfo(logCategoryHcs).noquote().nospace() << "broadcast msg: '" << message << "'";
    for(auto item : clientList_) {
        QByteArray clientId = item->getClientId();
        clients_.sendMessage(clientId, message);
    }

    return false;
}

void HostControllerService::handleUpdateProgress(int deviceId, QByteArray clientId, FirmwareUpdateController::UpdateProgress progress)
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
    payload.insert("device_id", deviceId);
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
        broadcastMessage(boardsController_.createPlatformsList());
    }
}
