/*
 * Copyright (c) 2018-2022 onsemi.
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
    : QObject(parent),
      downloadManager_(&networkManager_),
      storageManager_(&downloadManager_)
{
}

HostControllerService::~HostControllerService()
{
    stop();
}

HostControllerService::InitializeErrorCode HostControllerService::initialize(const QString &config)
{
    if (parseConfig(config) == false) {
        return FailureParseConfig;
    }

    // strataServer_ setup
    QJsonObject serverConfig = config_.value("host_controller_service").toObject();

    if (false == serverConfig.contains("subscriber_address") ||
        false == serverConfig.value("subscriber_address").isString()) {
        qCCritical(lcHcs) << "Invalid subscriber_address.";
        return FailureSubscriberAddress;
    }

    strataServer_ = std::make_shared<strataRPC::StrataServer>(
                serverConfig.value("subscriber_address").toString(),
                this);

    // Register handlers in strataServer_
    strataServer_->registerHandler(
                "hcs_status",
                std::bind(&HostControllerService::processCmdHcsStatus, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "load_documents",
                std::bind(&HostControllerService::processCmdLoadDocuments, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "download_datasheet_file",
                std::bind(&HostControllerService::processCmdDownloadDatasheetFile, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "download_platform_files",
                std::bind(&HostControllerService::processCmdDownloadPlatformFiles, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "dynamic_platform_list",
                std::bind(&HostControllerService::processCmdDynamicPlatformList, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "update_firmware",
                std::bind(&HostControllerService::processCmdUpdateFirmware, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "download_view",
                std::bind(&HostControllerService::processCmdDownlodView, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "platform_message",
                std::bind(&HostControllerService::processCmdSendPlatformMessage, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "check_for_updates",
                std::bind(&HostControllerService::processCmdCheckForUpdates, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "program_controller",
                std::bind(&HostControllerService::processCmdProgramController, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "platform_start_application",
                std::bind(&HostControllerService::processCmdPlatformStartApplication, this, std::placeholders::_1));

#ifdef APPS_FEATURE_BLE
    strataServer_->registerHandler(
                "bluetooth_scan",
                std::bind(&HostControllerService::processCmdBluetoothScan, this, std::placeholders::_1));
#endif // APPS_FEATURE_BLE

    strataServer_->registerHandler(
                "connect_device",
                std::bind(&HostControllerService::processCmdConnectDevice, this, std::placeholders::_1));

    strataServer_->registerHandler(
                "disconnect_device",
                std::bind(&HostControllerService::processCmdDisconnectDevice, this, std::placeholders::_1));

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

#ifdef APPS_FEATURE_BLE
    connect(&platformController_, &PlatformController::bluetoothScanFinished, this,
            &HostControllerService::bluetoothScanFinished);
#endif // APPS_FEATURE_BLE
    connect(&platformController_, &PlatformController::connectDeviceFinished, this,
            &HostControllerService::connectDeviceFinished);
    connect(&platformController_, &PlatformController::disconnectDeviceFinished, this,
            &HostControllerService::disconnectDeviceFinished);

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
    if (config_.contains("stage") && config_.value("stage").isString()) {
        QString stage = config_.value("stage").toString().toUpper();
        qCInfo(lcHcs) << "Running in" << stage << "setup";
        baseFolder += QString("/%1").arg(stage);
        QDir baseFolderDir{baseFolder};

        if (false == baseFolderDir.exists()) {
            qCDebug(lcHcs) << "Creating base folder" << baseFolder;
            if (false == baseFolderDir.mkpath(baseFolder)) {
                qCCritical(lcHcs) << "Failed to create base folder" << baseFolder;
                return FailureBaseFolder;
            }
        }
    }

    storageManager_.setBaseFolder(baseFolder);

    // Data base configuration
    QJsonObject databaseConfig = config_.value("database").toObject();

    if (db_.open(baseFolder, "strata_db") == false) {
        qCCritical(lcHcs) << "Failed to open database.";
        return FailureOpenDatabase;
    }

    // TODO: Will resolved in SCT-517
    // db_.addReplChannel("platform_list");

    QUrl baseUrl = databaseConfig.value("file_server").toString();

    qCInfo(lcHcs) << "file_server url:" << baseUrl.toString();

    if (baseUrl.isValid() == false) {
        qCCritical(lcHcs) << "Provided file_server url is not valid";
        return FailureFileServerUrlNotValid;
    }

    if (baseUrl.scheme().isEmpty()) {
        qCCritical(lcHcs) << "file_server url does not have scheme";
        return FailureFileServerUrlNoScheme;
    }

    storageManager_.setBaseUrl(baseUrl);
    storageManager_.setDatabase(&db_);


    bool replicatorInitResult = db_.initReplicator(
                databaseConfig.value("gateway_sync").toString().toStdString(),
                std::string(ReplicatorCredentials::replicator_username),
                std::string(ReplicatorCredentials::replicator_password));

    if (replicatorInitResult == false) {
        qCCritical(lcHcs) << "Database replicator not initialized";
        errorTracker_.reportError(strataRPC::ReplicatorRunError);
    }

    platformController_.initialize();

    updateController_.initialize(&platformController_, &downloadManager_);

    return Success;
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
        const QByteArray &clientId,
        const QString &fileUrl,
        const QString &originalFilePath,
        const QString &effectiveFilePath)
{
    QJsonObject payload {
        { "file_url", fileUrl },
        { "original_filepath", originalFilePath },
        { "effective_filepath", effectiveFilePath }
    };

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::DownloadPlatformFilepathChanged),
                payload);
}

void HostControllerService::sendDownloadPlatformSingleFileProgressMessage(
        const QByteArray &clientId,
        const QString &fileUrl,
        const QString &filePath,
        qint64 bytesReceived,
        qint64 bytesTotal)
{
    QJsonObject payload {
        { "file_url", fileUrl },
        { "filepath", filePath },
        { "bytes_received", bytesReceived },
        { "bytes_total", bytesTotal }
    };

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::DownloadPlatformSingleFileProgress),
                payload);
}

void HostControllerService::sendDownloadPlatformSingleFileFinishedMessage(
        const QByteArray &clientId,
        const QString &fileUrl,
        const QString &filePath,
        const QString &errorString)
{
    QJsonObject payload {
        { "file_url", fileUrl },
        { "filepath", filePath },
        { "error_string", errorString }
    };

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::DownloadPlatformSingleFileFinished),
                payload);
}

void HostControllerService::sendDownloadPlatformFilesFinishedMessage(
        const QByteArray &clientId,
        const QString &errorString)
{
    QJsonObject payload;

    if (errorString.isEmpty() == false) {
        payload.insert("error_string", errorString);
    }

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::DownloadPlatformFilesFinished),
                payload);
}

void HostControllerService::sendPlatformListMessage(
        const QByteArray &clientId,
        const QJsonArray &platformList)
{
    QJsonObject payload {
        { "list", platformList }
    };

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::AllPlatforms),
                payload);
}

void HostControllerService::sendPlatformDocumentsProgressMessage(
        const QByteArray &clientId,
        const QString &classId,
        int filesCompleted, int filesTotal)
{
    QJsonObject payload;

    payload.insert("class_id", classId);
    payload.insert("files_completed", filesCompleted);
    payload.insert("files_total", filesTotal);

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::PlatformDocumentsProgress),
                payload);
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

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::ControlViewDownloadProgress),
                payload);
}

void HostControllerService::sendPlatformMetaData(
        const QByteArray &clientId, const QString &classId,
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

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::PlatformMetaData),
                payload);
}

void HostControllerService::sendPlatformDocumentsMessage(
        const QByteArray &clientId,
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

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::PlatformDocument),
                payload);
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

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(RpcMethodName::DownloadViewFinished),
                payload);
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
    strataServer_->broadcastNotification(
                rpcMethodToString(RpcMethodName::ConnectedPlatforms),
                platformController_.createPlatformsList());
}

void HostControllerService::sendPlatformMessageToClients(
        const QString &platformId,
        const QJsonObject &payload)
{
    Q_UNUSED(platformId)

    QByteArray firstClientId = strataServer_->firstClientId();
    if (firstClientId.isEmpty()) {
        return;
    }

    strataServer_->sendNotification(
                firstClientId,
                rpcMethodToString(RpcMethodName::PlatformNotification),
                payload);
}

#ifdef APPS_FEATURE_BLE
void HostControllerService::bluetoothScanFinished(const QJsonObject payload)
{
    strataServer_->broadcastNotification(
                rpcMethodToString(RpcMethodName::BluetoothScan),
                payload);
}
#endif // APPS_FEATURE_BLE

void HostControllerService::connectDeviceFinished(
        const QByteArray &deviceId,
        const QByteArray &clientId,
        const QString &errorMessage)
{
    if (errorMessage.isEmpty()) {
        sendDeviceSuccess(RpcMethodName::ConnectDevice, deviceId, clientId);
    } else {
        sendDeviceError(RpcMethodName::ConnectDevice, deviceId, clientId, errorMessage);
    }
}

void HostControllerService::disconnectDeviceFinished(
        const QByteArray &deviceId,
        const QByteArray &clientId,
        const QString &errorMessage)
{
    if (errorMessage.isEmpty()) {
        sendDeviceSuccess(RpcMethodName::DisconnectDevice, deviceId, clientId);
    } else {
        sendDeviceError(RpcMethodName::DisconnectDevice, deviceId, clientId, errorMessage);
    }
}

void HostControllerService::processCmdHcsStatus(const strataRPC::RpcRequest &request)
{
    auto errors = errorTracker_.errors();

    QJsonArray jsonErrorList;
    for (const auto errorCode : errors) {
        strataRPC::RpcError error(errorCode);
        jsonErrorList.append(error.toJsonObject());
    }

    strataServer_->sendReply(request.clientId(), request.id(), {{"error_list", jsonErrorList}});
}

void HostControllerService::processCmdDynamicPlatformList(const strataRPC::RpcRequest &request)
{
    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "dynamic platform list requested"}});

    storageManager_.requestPlatformList(request.clientId());

    QJsonObject platformList = platformController_.createPlatformsList();

    strataServer_->sendNotification(
                request.clientId(),
                rpcMethodToString(RpcMethodName::ConnectedPlatforms),
                platformList);
}

void HostControllerService::processCmdLoadDocuments(const strataRPC::RpcRequest &request)
{
    QString classId = request.params().value("class_id").toString();
    if (classId.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "class_id attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "load documents requested"}});

    storageManager_.requestPlatformDocuments(request.clientId(), classId);
}

void HostControllerService::processCmdDownloadDatasheetFile(const strataRPC::RpcRequest &request)
{
    QString url = request.params().value("url").toString();
    if (url.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "url attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    if (QUrl(url).fileName().isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "url attribute is missing filename");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    QString classId = request.params().value("class_id").toString();
    storageManager_.requestDownloadDatasheetFile(request.clientId(), url, classId);

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "Datasheet file download requested."}});
}

void HostControllerService::processCmdDownloadPlatformFiles(const strataRPC::RpcRequest &request)
{
    QStringList partialUriList;
    QString destinationDir = request.params().value("destination_dir").toString();
    if (destinationDir.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "destinationDir attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    QJsonValue filesValue = request.params().value("files");
    if (filesValue.isArray() == false) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "files attribute is not an array");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    QJsonArray files = filesValue.toArray();
    for (const QJsonValueRef value : files) {
        if (value.isString()) {
            partialUriList << value.toString();
        }
    }

    storageManager_.requestDownloadPlatformFiles(request.clientId(), partialUriList, destinationDir);

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "platform files download requested"}});
}

void HostControllerService::processCmdUpdateFirmware(const strataRPC::RpcRequest &request)
{
    FirmwareUpdateController::ChangeFirmwareData firmwareData;
    firmwareData.clientId = request.clientId();

    strataRPC::RpcError error;
    do {
        firmwareData.deviceId = request.params().value("device_id").toVariant().toByteArray();
        if (firmwareData.deviceId.isEmpty()) {
            error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
            error.setMessage("device_id attribute is empty or has bad format");
            break;
        }

        strata::platform::PlatformPtr platform = platformController_.getPlatform(firmwareData.deviceId);
        if (platform == nullptr) {
            error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
            error.setMessage("unknown platform");
            break;
        }

        const QJsonValue noBackup = request.params().value("no_backup");
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
        const QJsonValue path = request.params().value("path");
        const QJsonValue md5 = request.params().value("md5");
        if ((path.isUndefined() == false) || (md5.isUndefined() == false)) {
            //use provided firmware
            firmwarePath = path.toString();
            if (firmwarePath.isEmpty()) {
                error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
                error.setMessage("path attribute is empty or has bad format");
                break;
            }

            firmwareData.firmwareMD5 = md5.toString();
            if (firmwareData.firmwareMD5.isEmpty()) {
                error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
                error.setMessage("md5 attribute is empty or has bad format");
                break;
            }
        } else {
            //find highest firmware
            if (platform->hasClassId() == false) {
                error.setCode(strataRPC::RpcErrorCode::ProcedureExecutionError);
                error.setMessage("platform has empty classId");
                break;
            }

            const FirmwareFileItem *firmware = storageManager_.findHighestFirmware(platform->classId());
            if (firmware == nullptr) {
                error.setCode(strataRPC::RpcErrorCode::ProcedureExecutionError);
                error.setMessage("no firmware for provided classId");
                break;
            }

            firmwarePath = firmware->partialUri;
            firmwareData.firmwareMD5 = firmware->md5;
        }

        firmwareData.firmwareUrl = storageManager_.getBaseUrl().resolved(QUrl(firmwarePath));
        firmwareData.jobUuid = QUuid::createUuid().toString(QUuid::WithoutBraces);

        QJsonObject resultObject {
            { "job_id", firmwareData.jobUuid },
            { "device_id", QLatin1String(firmwareData.deviceId) },
            { "path", firmwarePath },
            { "md5", firmwareData.firmwareMD5 }
        };

        strataServer_->sendReply(
                    request.clientId(),
                    request.id(),
                    resultObject);

        updateController_.changeFirmware(firmwareData);
        return;

    } while (false);

    //send back error

    error.setData({{"device_id", QLatin1String(firmwareData.deviceId)}});
    qCWarning(lcHcs) << error;
    strataServer_->sendError(request.clientId(), request.id(), error);
}

void HostControllerService::processCmdProgramController(const strataRPC::RpcRequest &request)
{
    FirmwareUpdateController::ChangeFirmwareData firmwareData;
    firmwareData.clientId = request.clientId();

    strataRPC::RpcError error;
    do {
        firmwareData.deviceId = request.params().value("device_id").toVariant().toByteArray();
        if (firmwareData.deviceId.isEmpty()) {
            error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
            error.setMessage("device_id attribute is empty or has bad format");
            break;
        }

        strata::platform::PlatformPtr platform = platformController_.getPlatform(firmwareData.deviceId);
        if (platform == nullptr) {
            error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
            error.setMessage("unknown device_id");
            break;
        }

        if (platform->isControllerConnectedToPlatform() == false) {
            error.setCode(strataRPC::RpcErrorCode::ProcedureExecutionError);
            error.setMessage("controller is not connected to platform");
            break;
        }

        firmwareData.firmwareClassId = platform->classId(); // class_id becomes the new fw_class_id
        const QString controllerClassId = platform->controllerClassId();
        if (firmwareData.firmwareClassId.isEmpty() || controllerClassId.isEmpty()) {
            error.setCode(strataRPC::RpcErrorCode::ProcedureExecutionError);
            error.setMessage("platform has no classId or controllerClassId");
            break;
        }

        const FirmwareFileItem *firmware = storageManager_.findHighestFirmware(firmwareData.firmwareClassId, controllerClassId);
        if (firmware == nullptr) {
            error.setCode(strataRPC::RpcErrorCode::ProcedureExecutionError);
            error.setMessage("no compatible firmware for your combination of controller and platform");
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

        QJsonObject resultObject {
            { "job_id", firmwareData.jobUuid },
            { "device_id", QLatin1String(firmwareData.deviceId) },
            { "path", path },
            { "md5", firmwareData.firmwareMD5 }
        };

        strataServer_->sendReply(
                    request.clientId(),
                    request.id(),
                    resultObject);

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

    error.setData({{"device_id", QLatin1String(firmwareData.deviceId)}});

    qCWarning(lcHcs) << error;
    strataServer_->sendError(request.clientId(), request.id(), error);
}

void HostControllerService::processCmdDownlodView(const strataRPC::RpcRequest &request)
{
    QString url = request.params().value("url").toString();
    if (url.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "url attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    QString md5 = request.params().value("md5").toString();
    if (md5.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "md5 attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    QString classId = request.params().value("class_id").toString();
    if (classId.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "class_id attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "view download requested"}});

    storageManager_.requestDownloadControlView(request.clientId(), url, md5, classId);
}

#ifdef APPS_FEATURE_BLE
void HostControllerService::processCmdBluetoothScan(const strata::strataRPC::RpcRequest &request)
{
    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "bluetooth scan initiated"}});

    platformController_.startBluetoothScan();
}
#endif // APPS_FEATURE_BLE

void HostControllerService::processCmdConnectDevice(const strata::strataRPC::RpcRequest &request)
{
    QByteArray deviceId = request.params().value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "device_id attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "device connection initiated"}});

    platformController_.connectDevice(deviceId, request.clientId());
}

void HostControllerService::processCmdDisconnectDevice(const strata::strataRPC::RpcRequest &request)
{
    QByteArray deviceId = request.params().value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        strataRPC::RpcError error(
                    strataRPC::RpcErrorCode::InvalidParamsError,
                    "device_id attribute is empty or has bad format");

        qCWarning(lcHcs) << error;
        strataServer_->sendError(request.clientId(), request.id(), error);
        return;
    }

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "device disconnection initiated"}});

    platformController_.disconnectDevice(deviceId, request.clientId());
}

void HostControllerService::processCmdSendPlatformMessage(const strataRPC::RpcRequest &request)
{
    platformController_.sendMessage(
                request.params().value("device_id").toString().toUtf8(),
                request.params().value("message").toString().toUtf8());
}

void HostControllerService::handleUpdateProgress(
        const QByteArray &deviceId,
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
    RpcMethodName method = (progress.programController)
            ? RpcMethodName::ProgramControllerJob
            : RpcMethodName::UpdateFirmwareJob;

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(method),
                payload);

    if (progress.operation == FirmwareUpdateController::UpdateOperation::Finished) {
        // If update process finished broadcast new platforms list to indicate
        // the firmware version has changed (or platform is in bootloader mode)
        strataServer_->broadcastNotification(
                    rpcMethodToString(RpcMethodName::ConnectedPlatforms),
                    platformController_.createPlatformsList());
    }
}

constexpr const char* HostControllerService::rpcMethodToString(RpcMethodName method)
{
    const char* string = "";

    switch (method) {
    case RpcMethodName::DownloadPlatformFilepathChanged:
        string = "download_platform_filepath_changed";
        break;
    case RpcMethodName::DownloadPlatformSingleFileProgress:
        string = "download_platform_single_file_progress";
        break;
    case RpcMethodName::DownloadPlatformSingleFileFinished:
        string = "download_platform_single_file_finished";
        break;
    case RpcMethodName::DownloadPlatformFilesFinished:
        string = "download_platform_files_finished";
        break;
    case RpcMethodName::AllPlatforms:
        string = "all_platforms";
        break;
    case RpcMethodName::PlatformMetaData:
        string = "platform_meta_data";
        break;
    case RpcMethodName::ControlViewDownloadProgress:
        string = "control_view_download_progress";
        break;
    case RpcMethodName::DownloadViewFinished:
        string = "download_view_finished";
        break;
    case RpcMethodName::UpdatesAvailable:
        string = "updates_available";
        break;
    case RpcMethodName::UpdateFirmware:
        string = "update_firmware";
        break;
    case RpcMethodName::UpdateFirmwareJob:
        string = "update_firmware_job";
        break;
    case RpcMethodName::ProgramController:
        string = "program_controller";
        break;
    case RpcMethodName::ProgramControllerJob:
        string = "program_controller_job";
        break;
    case RpcMethodName::BluetoothScan:
        string = "bluetooth_scan";
        break;
    case RpcMethodName::ConnectDevice:
        string = "connect_device";
        break;
    case RpcMethodName::DisconnectDevice:
        string = "disconnect_device";
        break;
    case RpcMethodName::PlatformDocumentsProgress:
        string = "document_progress";
        break;
    case RpcMethodName::PlatformDocument:
        string = "document";
        break;
    case RpcMethodName::PlatformMessage:
        string = "platform_message";
        break;
    case RpcMethodName::PlatformNotification:
        string = "platform_notification";
        break;
    case RpcMethodName::ConnectedPlatforms:
        string = "connected_platforms";
        break;
    }

    return string;
}

void HostControllerService::processCmdCheckForUpdates(const strataRPC::RpcRequest &request)
{
    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"message", "update check requested"}});

    componentUpdateInfo_.requestUpdateInfo(request.clientId());
}

void HostControllerService::sendDeviceError(
        RpcMethodName method,
        const QByteArray& deviceId,
        const QByteArray& clientId,
        const QString &errorString)
{
    QJsonObject resultObject {
        { "error_string", errorString },
        { "device_id", QLatin1String(deviceId) }
    };

    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(method),
                resultObject);
}

void HostControllerService::sendDeviceSuccess(
        RpcMethodName method,
        const QByteArray& deviceId,
        const QByteArray& clientId)
{
    strataServer_->sendNotification(
                clientId,
                rpcMethodToString(method),
                {{ "device_id", QLatin1String(deviceId) }});
}

void HostControllerService::processCmdPlatformStartApplication(const strataRPC::RpcRequest &request)
{
    strataRPC::RpcError error;

    const QByteArray deviceId = request.params().value("device_id").toVariant().toByteArray();
    if (deviceId.isEmpty()) {
        error.setCode(strataRPC::RpcErrorCode::InvalidParamsError);
        error.setMessage("device_id attribute is empty or has bad format");
    } else if (platformController_.platformStartApplication(deviceId) == false) {
        error.setCode(strataRPC::RpcErrorCode::ProcedureExecutionError);
        error.setMessage("attempt to start platform application was rejected.");
    }

    if (error.code() != strataRPC::RpcErrorCode::NoError) {
        error.setData({{"device_id", QLatin1String(deviceId)}});
        qCWarning(lcHcs) << error;

        strataServer_->sendError(
                    request.clientId(),
                    request.id(),
                    error);
        return;
    }

    strataServer_->sendReply(
                request.clientId(),
                request.id(),
                {{"device_id", QLatin1String(deviceId)}});
}

void HostControllerService::sendUpdateInfoMessage(
        const QByteArray &clientId,
        const QJsonArray &componentList,
        const QString &errorString)
{
    QJsonObject paramsObject;
    if ((componentList.isEmpty() == false) || errorString.isEmpty()) {  // if list is empty, but no error is set, it means we have no updates available
        paramsObject.insert("component_list", componentList);
    }
    if (errorString.isEmpty() == false) {
        paramsObject.insert("error_string", errorString);
    }

    strataServer_->sendNotification(
                clientId,
                "updates_available",
                paramsObject);
}
