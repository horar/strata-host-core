#include "HostControllerService.h"
#include "ReplicatorCredentials.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

#include <QDir>
#include <QFile>
#include <QStandardPaths>

namespace strataRPC = strata::strataRPC;

HostControllerService::HostControllerService(QObject *parent)
    : QObject(parent), downloadManager_(&networkManager_), storageManager_(&downloadManager_)
{
}

HostControllerService::~HostControllerService()
{
    stop();
}

bool HostControllerService::initialize(const QString &config)
{
    if (parseConfig(config) == false) {
        return false;
    }

    // strataServer_ setup
    QJsonObject serverConfig = config_.value("host_controller_service").toObject();

    if (false == serverConfig.contains("subscriber_address") ||
        false == serverConfig.value("subscriber_address").isString()) {
        qCCritical(logCategoryHcs) << "Invalid subscriber_address.";
        return false;
    }

    strataServer_ = std::make_shared<strataRPC::StrataServer>(
        serverConfig.value("subscriber_address").toString(), true, this);

    // Register handlers in strataServer_
    strataServer_->registerHandler(
        "request_hcs_status",
        std::bind(&HostControllerService::processCmdRequestHcsStatus, this, std::placeholders::_1));
    strataServer_->registerHandler(
        "load_documents",
        std::bind(&HostControllerService::processCmdLoadDocuments, this, std::placeholders::_1));
    strataServer_->registerHandler(
        "download_files",
        std::bind(&HostControllerService::processCmdDownloadFiles, this, std::placeholders::_1));
    strataServer_->registerHandler("dynamic_platform_list",
                                   std::bind(&HostControllerService::processCmdDynamicPlatformList,
                                             this, std::placeholders::_1));
    strataServer_->registerHandler(
        "update_firmware",
        std::bind(&HostControllerService::processCmdUpdateFirmware, this, std::placeholders::_1));
    strataServer_->registerHandler(
        "download_view",
        std::bind(&HostControllerService::processCmdDownlodView, this, std::placeholders::_1));
    strataServer_->registerHandler(
        "platform_message", std::bind(&HostControllerService::processCmdSendPlatformMessage, this,
                                      std::placeholders::_1));

    // connect signals
    connect(&storageManager_, &StorageManager::downloadPlatformFilePathChanged, this,
            &HostControllerService::sendDownloadPlatformFilePathChangedMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformSingleFileProgress, this,
            &HostControllerService::sendDownloadPlatformSingleFileProgressMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformSingleFileFinished, this,
            &HostControllerService::sendDownloadPlatformSingleFileFinishedMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformFilesFinished, this,
            &HostControllerService::sendDownloadPlatformFilesFinishedMessage);
    connect(&storageManager_, &StorageManager::platformListResponseRequested, this,
            &HostControllerService::sendPlatformListMessage);
    connect(&storageManager_, &StorageManager::downloadPlatformDocumentsProgress, this,
            &HostControllerService::sendPlatformDocumentsProgressMessage);
    connect(&storageManager_, &StorageManager::platformDocumentsResponseRequested, this,
            &HostControllerService::sendPlatformDocumentsMessage);
    connect(&storageManager_, &StorageManager::downloadControlViewFinished, this,
            &HostControllerService::sendDownloadControlViewFinishedMessage);
    connect(&storageManager_, &StorageManager::downloadControlViewProgress, this,
            &HostControllerService::sendControlViewDownloadProgressMessage);
    connect(&storageManager_, &StorageManager::platformMetaData, this,
            &HostControllerService::sendPlatformMetaData);

    connect(&platformController_, &PlatformController::platformConnected, this,
            &HostControllerService::platformConnected);
    connect(&platformController_, &PlatformController::platformDisconnected, this,
            &HostControllerService::platformDisconnected);
    connect(&platformController_, &PlatformController::platformMessage, this,
            &HostControllerService::sendPlatformMessageToClients);

    connect(&updateController_, &FirmwareUpdateController::progressOfUpdate, this,
            &HostControllerService::handleUpdateProgress);

    // create base folder
    QString baseFolder{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
    if (true == config_.contains("stage") && true == config_.value("stage").isString()) {
        QString stage = config_.value("stage").toString().toUpper();
        qCInfo(logCategoryHcs) << "Running in" << stage << "setup";
        baseFolder += QString("/%1").arg(stage);
        QDir baseFolderDir{baseFolder};

        if (false == baseFolderDir.exists()) {
            qCDebug(logCategoryHcs) << "Creating base folder" << baseFolder;
            if (false == baseFolderDir.mkpath(baseFolder)) {
                qCCritical(logCategoryHcs) << "Failed to create base folder" << baseFolder;
            }
        }
    }

    storageManager_.setBaseFolder(baseFolder);

    // Data base configuration
    QJsonObject databaseConfig = config_.value("database").toObject();

    if (db_.open(baseFolder, "strata_db") == false) {
        qCCritical(logCategoryHcs) << "Failed to open database.";
        return false;
    }

    // TODO: Will resolved in SCT-517
    // db_.addReplChannel("platform_list");

    QUrl baseUrl = databaseConfig.value("file_server").toString();

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

    db_.initReplicator(databaseConfig.value("gateway_sync").toString().toStdString(),
                       std::string(ReplicatorCredentials::replicator_username).c_str(),
                       std::string(ReplicatorCredentials::replicator_password).c_str());

    platformController_.initialize();

    updateController_.initialize(&platformController_, &downloadManager_);

    return true;
}

void HostControllerService::start()
{
    connect(strataServer_.get(), &strataRPC::StrataServer::initialized, this,
            []() { qCInfo(logCategoryHcs) << "Host controller service started."; });
    strataServer_->initialize();
}

void HostControllerService::stop()
{
    db_.stop();
}

void HostControllerService::onAboutToQuit()
{
    stop();
}

void HostControllerService::sendDownloadPlatformFilePathChangedMessage(
    const QByteArray &clientId, const QString &originalFilePath, const QString &effectiveFilePath)
{
    QJsonObject payload;

    payload.insert("original_filepath", originalFilePath);
    payload.insert("effective_filepath", effectiveFilePath);

    strataServer_->notifyClient(clientId, "download_platform_filepath_changed", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadPlatformSingleFileProgressMessage(
    const QByteArray &clientId, const QString &filePath, qint64 bytesReceived, qint64 bytesTotal)
{
    QJsonObject payload;

    payload.insert("filepath", filePath);
    payload.insert("bytes_received", bytesReceived);
    payload.insert("bytes_total", bytesTotal);

    strataServer_->notifyClient(clientId, "download_platform_single_file_progress", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadPlatformSingleFileFinishedMessage(
    const QByteArray &clientId, const QString &filePath, const QString &errorString)
{
    QJsonObject payload;

    payload.insert("filepath", filePath);
    payload.insert("error_string", errorString);

    strataServer_->notifyClient(clientId, "download_platform_single_file_finished", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadPlatformFilesFinishedMessage(const QByteArray &clientId,
                                                                     const QString &errorString)
{
    QJsonObject payload;

    payload.insert("type", "download_platform_files_finished");
    if (errorString.isEmpty() == false) {
        payload.insert("error_string", errorString);
    }

    strataServer_->notifyClient(clientId, "download_platform_files_finished", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendPlatformListMessage(const QByteArray &clientId,
                                                    const QJsonArray &platformList)
{
    QJsonObject payload;

    payload.insert("list", platformList);

    strataServer_->notifyClient(clientId, "all_platforms", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendPlatformDocumentsProgressMessage(const QByteArray &clientId,
                                                                 const QString &classId,
                                                                 int filesCompleted, int filesTotal)
{
    QJsonObject payload;

    payload.insert("class_id", classId);
    payload.insert("files_completed", filesCompleted);
    payload.insert("files_total", filesTotal);

    strataServer_->notifyClient(clientId, "document_progress", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendControlViewDownloadProgressMessage(const QByteArray &clientId,
                                                                   const QString &partialUri,
                                                                   const QString &filePath,
                                                                   qint64 bytesReceived,
                                                                   qint64 bytesTotal)
{
    QJsonObject payload;

    payload.insert("url", partialUri);
    payload.insert("filepath", filePath);
    payload.insert("bytes_received", bytesReceived);
    payload.insert("bytes_total", bytesTotal);

    strataServer_->notifyClient(clientId, "control_view_download_progress", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendPlatformMetaData(const QByteArray &clientId, const QString &classId,
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

    strataServer_->notifyClient(clientId, "platform_meta_data", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendPlatformDocumentsMessage(const QByteArray &clientId,
                                                         const QString &classId,
                                                         const QJsonArray &datasheetList,
                                                         const QJsonArray &documentList,
                                                         const QString &error)
{
    QJsonObject payload;

    payload.insert("class_id", classId);

    if (error.isEmpty()) {
        payload.insert("datasheets", datasheetList);
        payload.insert("documents", documentList);
    } else {
        payload.insert("error", error);
    }

    strataServer_->notifyClient(clientId, "document", payload,
                                strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadControlViewFinishedMessage(const QByteArray &clientId,
                                                                   const QString &partialUri,
                                                                   const QString &filePath,
                                                                   const QString &errorString)
{
    QJsonObject payload{{"url", partialUri}, {"filepath", filePath}, {"error_string", errorString}};

    strataServer_->notifyClient(clientId, "download_view_finished", payload,
                                strataRPC::ResponseType::Notification);
}

bool HostControllerService::parseConfig(const QString &config)
{
    QString filePath;
    if (config.isEmpty()) {
        filePath = QDir(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation))
                       .filePath("hcs.config");
    } else {
        filePath = config;
    }

    QFile file(filePath);
    if (file.open(QIODevice::ReadOnly) == false) {
        qCCritical(logCategoryHcs) << "Unable to open config file:" << filePath;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(data, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCCritical(logCategoryHcs)
            << "Unable to parse config file." << jsonParseError.errorString();
        qCCritical(logCategoryHcs) << data;
        return false;
    }

    if (false == jsonDocument.object().contains("host_controller_service")) {
        qCCritical(logCategoryHcs) << "ERROR: No Host Controller Configuration parameters.";
        return false;
    }

    config_ = jsonDocument.object();

    return true;
}

void HostControllerService::platformConnected(const QByteArray &deviceId)
{
    Q_UNUSED(deviceId)

    strataServer_->notifyAllClients("connected_platforms",
                                    platformController_.createPlatformsList());
}

void HostControllerService::platformDisconnected(const QByteArray &deviceId)
{
    Q_UNUSED(deviceId)

    strataServer_->notifyAllClients("connected_platforms",
                                    platformController_.createPlatformsList());
}

void HostControllerService::sendPlatformMessageToClients(const QString &platformId,
                                                         const QJsonObject &payload)
{
    Q_UNUSED(platformId)

    // TODO: map each device to a client and update this functionality
    strataServer_->notifyClient(currentClient_, "platform_message", payload,
                                strataRPC::ResponseType::PlatformMessage);
}

void HostControllerService::processCmdRequestHcsStatus(const strataRPC::Message &message)
{
    strataServer_->notifyClient(message, QJsonObject{{"status", "hcs_active"}},
                                strataRPC::ResponseType::Response);
}

void HostControllerService::processCmdDynamicPlatformList(const strataRPC::Message &message)
{
    strataServer_->notifyClient(message,
                                QJsonObject{{"message", "Dynamic platform list requested."}},
                                strataRPC::ResponseType::Response);

    storageManager_.requestPlatformList(message.clientID);

    strataServer_->notifyClient(message.clientID, "connected_platforms",
                                platformController_.createPlatformsList(),
                                strataRPC::ResponseType::Notification);

    currentClient_ = message.clientID;  // Remove this when platforms are mapped to their clients.
}

void HostControllerService::processCmdLoadDocuments(const strataRPC::Message &message)
{
    QString classId = message.payload.value("class_id").toString();
    if (classId.isEmpty()) {
        QString errorMessage(QStringLiteral("class_id attribute is empty or has bad format"));
        qCWarning(logCategoryHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    strataServer_->notifyClient(message, QJsonObject{{"message", "load documents requested."}},
                                strataRPC::ResponseType::Response);

    storageManager_.requestPlatformDocuments(message.clientID, classId);
}

void HostControllerService::processCmdDownloadFiles(const strataRPC::Message &message)
{
    QStringList partialUriList;
    QString destinationDir = message.payload.value("destination_dir").toString();
    if (destinationDir.isEmpty()) {
        QString errorMessage(QStringLiteral("destinationDir attribute is empty or has bad format"));
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        qCWarning(logCategoryHcs) << errorMessage;
        return;
    }

    QJsonValue filesValue = message.payload.value("files");
    if (filesValue.isArray() == false) {
        QString errorMessage(QStringLiteral("files attribute is not an array"));
        qCWarning(logCategoryHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    QJsonArray files = filesValue.toArray();
    for (const QJsonValueRef value : files) {
        if (value.isString()) {
            partialUriList << value.toString();
        }
    }

    storageManager_.requestDownloadPlatformFiles(message.clientID, partialUriList, destinationDir);

    strataServer_->notifyClient(message, QJsonObject{{"message", "File download requested."}},
                                strataRPC::ResponseType::Response);
}

void HostControllerService::processCmdUpdateFirmware(const strataRPC::Message &message)
{
    QByteArray deviceId = message.payload.value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        QString errorMessage(QStringLiteral("device_id attribute is empty or has bad format"));
        qCWarning(logCategoryHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    QString path = message.payload.value("path").toString();
    if (path.isEmpty()) {
        QString errorMessage(QStringLiteral("path attribute is empty or has bad format"));
        qCWarning(logCategoryHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    QUrl firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(path));

    QString firmwareMD5 = message.payload.value("md5").toString();
    if (firmwareMD5.isEmpty()) {
        // If 'md5' attribute is empty firmware will be downloaded, but checksum will not be
        // verified.
        qCWarning(logCategoryHcs) << "md5 attribute is empty or has bad format";
    }

    strataServer_->notifyClient(message, QJsonObject{{"message", "Firmware update requested."}},
                                strataRPC::ResponseType::Response);

    updateController_.updateFirmware(message.clientID, deviceId, firmwareUrl, firmwareMD5);
}

void HostControllerService::processCmdDownlodView(const strataRPC::Message &message)
{
    QString url = message.payload.value("url").toString();
    if (url.isEmpty()) {
        qCWarning(logCategoryHcs) << "url attribute is empty or has bad format";
        return;
    }

    QString md5 = message.payload.value("md5").toString();
    if (md5.isEmpty()) {
        qCWarning(logCategoryHcs) << "md5 attribute is empty or has bad format";
        return;
    }

    QString classId = message.payload.value("class_id").toString();
    if (classId.isEmpty()) {
        qCWarning(logCategoryHcs) << "class_id attribute is empty or has bad format";
        return;
    }

    storageManager_.requestDownloadControlView(message.clientID, url, md5, classId);
}

void HostControllerService::processCmdSendPlatformMessage(const strataRPC::Message &message)
{
    platformController_.sendMessage(message.payload.value("device_id").toString().toUtf8(),
                                    message.payload.value("message").toString().toUtf8());
}

void HostControllerService::handleUpdateProgress(const QByteArray &deviceId,
                                                 const QByteArray &clientId,
                                                 FirmwareUpdateController::UpdateProgress progress)
{
    QString operation;
    switch (progress.operation) {
        case FirmwareUpdateController::UpdateOperation::Download:
            operation = "download";
            break;
        case FirmwareUpdateController::UpdateOperation::Prepare:
            operation = "prepare";
            break;
        case FirmwareUpdateController::UpdateOperation::Backup:
            operation = "backup";
            break;
        case FirmwareUpdateController::UpdateOperation::Flash:
            operation = "flash";
            break;
        case FirmwareUpdateController::UpdateOperation::Restore:
            operation = "restore";
            break;
        case FirmwareUpdateController::UpdateOperation::Finished:
            operation = "finished";
            break;
    }

    QString status;
    switch (progress.status) {
        case FirmwareUpdateController::UpdateStatus::Running:
            status = "running";
            break;
        case FirmwareUpdateController::UpdateStatus::Success:
            status = "success";
            break;
        case FirmwareUpdateController::UpdateStatus::Unsuccess:
            status = "unsuccess";
            break;
        case FirmwareUpdateController::UpdateStatus::Failure:
            status = "failure";
            break;
    }

    QJsonObject payload;
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

    strataServer_->notifyClient(clientId, "firmware_update", payload,
                                strataRPC::ResponseType::Notification);

    if (progress.operation == FirmwareUpdateController::UpdateOperation::Finished &&
        progress.status == FirmwareUpdateController::UpdateStatus::Success) {
        // If firmware was updated broadcast new platforms list
        // to indicate the firmware version has changed.
        strataServer_->notifyAllClients("connected_platforms",
                                        platformController_.createPlatformsList());
    }
}
