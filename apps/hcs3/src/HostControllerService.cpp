/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "HostControllerService.h"
#include "JsonStrings.h"
#include "PlatformDocument.h"
#include "ReplicatorCredentials.h"
#include "logging/LoggingQtCategories.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLatin1String>
#include <QStandardPaths>
#include <QUuid>

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
        qCCritical(lcHcs) << "Invalid subscriber_address.";
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
    strataServer_->registerHandler(
        "check_for_updates",
        std::bind(&HostControllerService::processCmdCheckForUpdates, this, std::placeholders::_1));
    strataServer_->registerHandler(
        "program_controller", std::bind(&HostControllerService::processCmdProgramController, this,
                                        std::placeholders::_1));
    strataServer_->registerHandler(
        "platform_start_application", std::bind(&HostControllerService::processCmdPlatformStartApplication, this,
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
            &HostControllerService::platformStateChanged);
    connect(&platformController_, &PlatformController::platformDisconnected, this,
            &HostControllerService::platformStateChanged);
    connect(&platformController_, &PlatformController::platformMessage, this,
            &HostControllerService::sendPlatformMessageToClients);
    connect(&platformController_, &PlatformController::platformApplicationStarted, this,
            &HostControllerService::platformStateChanged);

    connect(&updateController_, &FirmwareUpdateController::progressOfUpdate, this,
            &HostControllerService::handleUpdateProgress);
    connect(&updateController_, &FirmwareUpdateController::bootloaderActive,
            &platformController_, &PlatformController::bootloaderActive);
    connect(&updateController_, &FirmwareUpdateController::applicationActive,
            &platformController_, &PlatformController::applicationActive);

    connect(&componentUpdateInfo_, &ComponentUpdateInfo::requestUpdateInfoFinished, this,
            &HostControllerService::sendUpdateInfoMessage);

    // create base folder
    QString baseFolder{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
    if (true == config_.contains("stage") && true == config_.value("stage").isString()) {
        QString stage = config_.value("stage").toString().toUpper();
        qCInfo(lcHcs) << "Running in" << stage << "setup";
        baseFolder += QString("/%1").arg(stage);
        QDir baseFolderDir{baseFolder};

        if (false == baseFolderDir.exists()) {
            qCDebug(lcHcs) << "Creating base folder" << baseFolder;
            if (false == baseFolderDir.mkpath(baseFolder)) {
                qCCritical(lcHcs) << "Failed to create base folder" << baseFolder;
            }
        }
    }

    storageManager_.setBaseFolder(baseFolder);

    // Data base configuration
    QJsonObject databaseConfig = config_.value("database").toObject();

    if (db_.open(baseFolder, "strata_db") == false) {
        qCCritical(lcHcs) << "Failed to open database.";
        return false;
    }

    // TODO: Will resolved in SCT-517
    // db_.addReplChannel("platform_list");

    QUrl baseUrl = databaseConfig.value("file_server").toString();

    qCInfo(lcHcs) << "file_server url:" << baseUrl.toString();

    if (baseUrl.isValid() == false) {
        qCCritical(lcHcs) << "Provided file_server url is not valid";
        return false;
    }

    if (baseUrl.scheme().isEmpty()) {
        qCCritical(lcHcs) << "file_server url does not have scheme";
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
            []() { qCInfo(lcHcs) << "Host controller service started."; });
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
    QJsonObject payload {
        { "original_filepath", originalFilePath },
        { "effective_filepath", effectiveFilePath }
    };

    strataServer_->notifyClient(
        clientId, hcsNotificationTypeToString(hcsNotificationType::downloadPlatformFilepathChanged),
        payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadPlatformSingleFileProgressMessage(
    const QByteArray &clientId, const QString &filePath, qint64 bytesReceived, qint64 bytesTotal)
{
    QJsonObject payload {
        { "filepath", filePath },
        { "bytes_received", bytesReceived },
        { "bytes_total", bytesTotal }
    };

    strataServer_->notifyClient(
        clientId,
        hcsNotificationTypeToString(hcsNotificationType::downloadPlatformSingleFileProgress),
        payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadPlatformSingleFileFinishedMessage(
    const QByteArray &clientId, const QString &filePath, const QString &errorString)
{
    QJsonObject payload {
        { "filepath", filePath },
        { "error_string", errorString }
    };

    strataServer_->notifyClient(
        clientId,
        hcsNotificationTypeToString(hcsNotificationType::downloadPlatformSingleFileFinished),
        payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadPlatformFilesFinishedMessage(const QByteArray &clientId,
                                                                     const QString &errorString)
{
    QJsonObject payload;

    if (errorString.isEmpty() == false) {
        payload.insert("error_string", errorString);
    }

    strataServer_->notifyClient(
        clientId, hcsNotificationTypeToString(hcsNotificationType::downloadPlatformFilesFinished),
        payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendPlatformListMessage(const QByteArray &clientId,
                                                    const QJsonArray &platformList)
{
    QJsonObject payload {
        { "list", platformList }
    };

    strataServer_->notifyClient(clientId,
                                hcsNotificationTypeToString(hcsNotificationType::allPlatforms),
                                payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendPlatformDocumentsProgressMessage(const QByteArray &clientId,
                                                                 const QString &classId,
                                                                 int filesCompleted, int filesTotal)
{
    QJsonObject payload;

    payload.insert("class_id", classId);
    payload.insert("files_completed", filesCompleted);
    payload.insert("files_total", filesTotal);

    strataServer_->notifyClient(
        clientId, hcsNotificationTypeToString(hcsNotificationType::platformDocumentsProgress),
        payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendControlViewDownloadProgressMessage(const QByteArray &clientId,
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

    strataServer_->notifyClient(
        clientId, hcsNotificationTypeToString(hcsNotificationType::controlViewDownloadProgress),
        payload, strataRPC::ResponseType::Notification);
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

    strataServer_->notifyClient(clientId,
                                hcsNotificationTypeToString(hcsNotificationType::platformMetaData),
                                payload, strataRPC::ResponseType::Notification);
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

    strataServer_->notifyClient(clientId,
                                hcsNotificationTypeToString(hcsNotificationType::platformDocument),
                                payload, strataRPC::ResponseType::Notification);
}

void HostControllerService::sendDownloadControlViewFinishedMessage(const QByteArray &clientId,
                                                                   const QString &partialUri,
                                                                   const QString &filePath,
                                                                   const QString &errorString)
{
    QJsonObject payload {
        { "url", partialUri },
        { "filepath", filePath },
        { "error_string", errorString }
    };

    strataServer_->notifyClient(
        clientId, hcsNotificationTypeToString(hcsNotificationType::downloadViewFinished), payload,
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
        qCCritical(lcHcs) << "Unable to open config file:" << filePath;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError jsonParseError;
    QJsonDocument jsonDocument = QJsonDocument::fromJson(data, &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qCCritical(lcHcs)
            << "Unable to parse config file." << jsonParseError.errorString();
        qCCritical(lcHcs) << data;
        return false;
    }

    if (false == jsonDocument.object().contains("host_controller_service")) {
        qCCritical(lcHcs) << "ERROR: No Host Controller Configuration parameters.";
        return false;
    }

    config_ = jsonDocument.object();

    return true;
}

void HostControllerService::platformStateChanged(const QByteArray &deviceId)
{
    Q_UNUSED(deviceId)

    strataServer_->notifyAllClients(
        hcsNotificationTypeToString(hcsNotificationType::connectedPlatforms),
        platformController_.createPlatformsList());
}

void HostControllerService::sendPlatformMessageToClients(const QString &platformId,
                                                         const QJsonObject &payload)
{
    Q_UNUSED(platformId)

    // TODO: map each device to a client and update this functionality
    strataServer_->notifyClient(currentClient_,
                                hcsNotificationTypeToString(hcsNotificationType::platformMessage),
                                payload, strataRPC::ResponseType::PlatformMessage);
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

    strataServer_->notifyClient(
        message.clientID, hcsNotificationTypeToString(hcsNotificationType::connectedPlatforms),
        platformController_.createPlatformsList(), strataRPC::ResponseType::Notification);

    currentClient_ = message.clientID;  // Remove this when platforms are mapped to their clients.
}

void HostControllerService::processCmdLoadDocuments(const strataRPC::Message &message)
{
    QString classId = message.payload.value("class_id").toString();
    if (classId.isEmpty()) {
        QString errorMessage(QStringLiteral("class_id attribute is empty or has bad format"));
        qCWarning(lcHcs) << errorMessage;
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
        qCWarning(lcHcs) << errorMessage;
        return;
    }

    QJsonValue filesValue = message.payload.value("files");
    if (filesValue.isArray() == false) {
        QString errorMessage(QStringLiteral("files attribute is not an array"));
        qCWarning(lcHcs) << errorMessage;
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
    FirmwareUpdateController::ChangeFirmwareData firmwareData;
    firmwareData.clientId = message.clientID;

    QString errorString;
    do {
        firmwareData.deviceId = message.payload.value("device_id").toVariant().toByteArray();
        if (firmwareData.deviceId.isEmpty()) {
            errorString = "device_id attribute is empty or has bad format";
            break;
        }

        strata::platform::PlatformPtr platform = platformController_.getPlatform(firmwareData.deviceId);
        if (platform == nullptr) {
            errorString = "Platform " + firmwareData.deviceId + " doesn't exist";
            break;
        }

        const QJsonValue noBackup = message.payload.value("no_backup");
        if ((noBackup.isUndefined() == false) && (noBackup.toBool() == true)) {
            firmwareData.action = FirmwareUpdateController::ChangeFirmwareAction::ProgramFirmware;
        } else {
            firmwareData.action = FirmwareUpdateController::ChangeFirmwareAction::UpdateFirmware;
        }

        // if firmwareClassId is available, flasher needs it (due to correct flashing of assisted boards)
        if (platform->controllerType() == strata::platform::Platform::ControllerType::Assisted) {
            firmwareData.firmwareClassId = platform->firmwareClassId();
        }

        QString firmwarePath;
        const QJsonValue path = message.payload.value("path");
        const QJsonValue md5 = message.payload.value("md5");
        if ((path.isUndefined() == false) || (md5.isUndefined() == false)) {
            //use provided firmware
            firmwarePath = path.toString();
            if (firmwarePath.isEmpty()) {
                errorString = "path attribute is empty or has bad format";
                break;
            }

            firmwareData.firmwareMD5 = md5.toString();
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

            firmwarePath = firmware->partialUri;
            firmwareData.firmwareMD5 = firmware->md5;
        }

        firmwareData.firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(firmwarePath));
        firmwareData.jobUuid = QUuid::createUuid().toString(QUuid::WithoutBraces);

        QJsonObject payloadBody {
            { "job_id", firmwareData.jobUuid },
            { "device_id", QLatin1String(firmwareData.deviceId) },
            { "path", firmwarePath },
            { "md5", firmwareData.firmwareMD5 }
        };

        strataServer_->notifyClient(message, payloadBody, strataRPC::ResponseType::Response);

        updateController_.changeFirmware(firmwareData);

        return;

    } while (false);

    //send back error
    qCWarning(lcHcs) <<  errorString;

    QJsonObject payloadBody {
        { "error_string", errorString },
        { "device_id", QLatin1String(firmwareData.deviceId) }
    };

    strataServer_->notifyClient(message, payloadBody, strataRPC::ResponseType::Error);
}

void HostControllerService::processCmdProgramController(const strataRPC::Message &message)
{
    FirmwareUpdateController::ChangeFirmwareData firmwareData;
    firmwareData.clientId = message.clientID;

    QString errorString;
    do {
        firmwareData.deviceId = message.payload.value("device_id").toVariant().toByteArray();
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
        const QString controllerClassId = platform->controllerClassId();
        if (firmwareData.firmwareClassId.isEmpty() || controllerClassId.isEmpty()) {
            errorString = "Platform has no classId or controllerClassId";
            break;
        }

        const FirmwareFileItem *firmware = storageManager_.findHighestFirmware(firmwareData.firmwareClassId, controllerClassId);
        if (firmware == nullptr) {
            errorString = "No compatible firmware for your combination of controller and platform";
            break;
        }
        firmwareData.firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(firmware->partialUri));
        firmwareData.firmwareMD5 = firmware->md5;
        const QString path = firmware->partialUri;

        QString currentMD5; // get md5 accorging to old fw_class_id and fw version
        if (platform->applicationVer().isEmpty() == false
            && platform->firmwareClassId().isNull() == false
            && platform->firmwareClassId().isEmpty() == false)
        {
            firmware = storageManager_.findFirmware(platform->firmwareClassId(), controllerClassId, platform->applicationVer());
            if (firmware != nullptr) {
                currentMD5 = firmware->md5;
            } else {
                qCWarning(lcHcs) << platform << "Cannot find current firmware in database.";
            }
        } else {
            qCInfo(lcHcs) << platform << "Platform has probably no firmware.";
        }

        if (currentMD5.isEmpty()) {
            qCWarning(lcHcs) << platform << "Cannot get MD5 of curent firmware from database.";
        }

        firmwareData.jobUuid = QUuid::createUuid().toString(QUuid::WithoutBraces);

        QJsonObject payloadBody {
            { "job_id", firmwareData.jobUuid },
            { "device_id", QLatin1String(firmwareData.deviceId) },
            { "path", path },
            { "md5", firmwareData.firmwareMD5 }
        };
        strataServer_->notifyClient(message, payloadBody, strataRPC::ResponseType::Response);

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

    qCWarning(lcHcs).noquote() << errorString;

    QJsonObject payloadBody {
        { "error_string", errorString },
        { "device_id", QLatin1String(firmwareData.deviceId) }
    };
    strataServer_->notifyClient(message, payloadBody, strataRPC::ResponseType::Error);
}

void HostControllerService::processCmdDownlodView(const strataRPC::Message &message)
{
    QString url = message.payload.value("url").toString();
    if (url.isEmpty()) {
        QString errorMessage(QStringLiteral("url attribute is empty or has bad format"));
        qCWarning(lcHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    QString md5 = message.payload.value("md5").toString();
    if (md5.isEmpty()) {
        QString errorMessage(QStringLiteral("md5 attribute is empty or has bad format"));
        qCWarning(lcHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    QString classId = message.payload.value("class_id").toString();
    if (classId.isEmpty()) {
        QString errorMessage(QStringLiteral("class_id attribute is empty or has bad format"));
        qCWarning(lcHcs) << errorMessage;
        strataServer_->notifyClient(message, QJsonObject{{"message", errorMessage}},
                                    strataRPC::ResponseType::Error);
        return;
    }

    strataServer_->notifyClient(message, QJsonObject{{"message", "view download requested"}},
                                strataRPC::ResponseType::Response);
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
        payload.insert("error_string", progress.lastError);
    }
    hcsNotificationType type = (progress.programController)
            ? hcsNotificationType::programControllerJob
            : hcsNotificationType::updateFirmwareJob;

    strataServer_->notifyClient(clientId, hcsNotificationTypeToString(type), payload,
                                strataRPC::ResponseType::Notification);

    if (progress.operation == FirmwareUpdateController::UpdateOperation::Finished) {
        // If update process finished broadcast new platforms list to indicate
        // the firmware version has changed (or platform is in bootloader mode)
        strataServer_->notifyAllClients(
            hcsNotificationTypeToString(hcsNotificationType::connectedPlatforms),
            platformController_.createPlatformsList());
    }
}

constexpr const char* HostControllerService::hcsNotificationTypeToString(hcsNotificationType notificationType)
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
    case hcsNotificationType::platformDocumentsProgress:
        type = "document_progress";
        break;
    case hcsNotificationType::platformDocument:
        type = "document";
        break;
    case hcsNotificationType::platformMessage:
        type = "platform_message";
        break;
    case hcsNotificationType::connectedPlatforms:
        type = "connected_platforms";
        break;
    }

    return type;
}

void HostControllerService::processCmdCheckForUpdates(const strataRPC::Message &message)
{
    componentUpdateInfo_.requestUpdateInfo(message.clientID);
    strataServer_->notifyClient(message, QJsonObject{{"message", "Update check requested."}}, strataRPC::ResponseType::Response);
}

void HostControllerService::processCmdPlatformStartApplication(const strataRPC::Message &message)
{
    QString errorString;
    bool ok = true;

    const QByteArray deviceId = message.payload.value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        errorString = QStringLiteral("device_id attribute is empty or has bad format");
        ok = false;
    }

    if (ok && (platformController_.platformStartApplication(deviceId) == false)) {
        errorString = QStringLiteral("Attempt to start platform application was rejected.");
        ok = false;
    }

    QJsonObject payloadBody {
        { "device_id", QLatin1String(deviceId) }
    };
    if (ok == false) {
        payloadBody.insert("error_string", errorString);
        qCWarning(lcHcs).noquote() << errorString;
    }

    strataServer_->notifyClient(message, payloadBody, ok ? strataRPC::ResponseType::Response : strataRPC::ResponseType::Error);
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

    strataServer_->notifyClient(clientId, "updates_available", payload, strataRPC::ResponseType::Notification);
}
