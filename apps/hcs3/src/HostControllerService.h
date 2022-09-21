/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <set>
#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QJsonArray>
#include <QNetworkAccessManager>

#include "Database.h"
#include "PlatformController.h"
#include "FirmwareUpdateController.h"
#include "StorageManager.h"
#include "ComponentUpdateInfo.h"
#include "ErrorTracker.h"

#include <DownloadManager.h>
#include <StrataRPC/StrataServer.h>

struct DispatcherMessage;

class Client;
class StorageManager;

namespace strata {
class DownloadManager;
}

class HostControllerService : public QObject
{
    Q_OBJECT

public:

    enum InitializeErrorCode {
        Success = EXIT_SUCCESS,
        FailureAppGuard = EXIT_FAILURE + 1,
        FailureParseConfig,
        FailureSubscriberAddress,
        FailureBaseFolder,
        FailureOpenDatabase,
        FailureFileServerUrlNotValid,
        FailureFileServerUrlNoScheme,
    };

    HostControllerService(QObject* parent = nullptr);
    ~HostControllerService() override;

    /**
     * Initializes the HCS
     * @return returns error code
     */
    InitializeErrorCode initialize(const QString& config);

    /**
     * Starts the HCS - dispatching thread
     */
    void start();

    /**
     * Stops the HCS
     */
    void stop();

signals:
    void newMessageFromClient(QByteArray message, QByteArray clientId);

public slots:
    void onAboutToQuit();

    void sendDownloadPlatformFilePathChangedMessage(
            const QByteArray &clientId,
            const QString &fileUrl,
            const QString &originalFilePath,
            const QString &effectiveFilePath);

    void sendDownloadPlatformSingleFileProgressMessage(
            const QByteArray &clientId,
            const QString &fileUrl,
            const QString &filePath,
            qint64 bytesReceived,
            qint64 bytesTotal);

    void sendDownloadPlatformSingleFileFinishedMessage(
            const QByteArray &clientId,
            const QString &fileUrl,
            const QString &filePath,
            const QString &errorString);

    void sendDownloadPlatformFilesFinishedMessage(
            const QByteArray &clientId,
            const QString &errorString);

    void sendPlatformListMessage(
            const QByteArray &clientId,
            const QJsonArray &platformList);

    void sendPlatformDocumentsProgressMessage(
            const QByteArray &clientId,
            const QString &classId,
            int filesCompleted,
            int filesTotal);

    void sendPlatformDocumentsMessage(
            const QByteArray &clientId,
            const QString &classId,
            const QJsonArray &datasheetList,
            const QJsonArray &documentList,
            const QString &error);

    void sendDownloadControlViewFinishedMessage(
            const QByteArray &clientId,
            const QString &partialUri,
            const QString &filePath,
            const QString &errorString);

    void sendControlViewDownloadProgressMessage(
            const QByteArray &clientId,
            const QString &partialUri,
            const QString &filePath,
            qint64 bytesReceived,
            qint64 bytesTotal);

    void sendPlatformMetaData(
            const QByteArray &clientId,
            const QString &classId,
            const QJsonArray &controlViewList,
            const QJsonArray &firmwareList,
            const QString &error);

    void sendUpdateInfoMessage(
            const QByteArray &clientId,
            const QJsonArray &componentList,
            const QString &errorString);

private slots:
    void sendPlatformMessageToClients(
            const QString &platformId,
            const QJsonObject& payload);

    void handleUpdateProgress(
            const QByteArray& deviceId,
            const QByteArray& clientId,
            FirmwareUpdateController::UpdateProgress progress);

    void platformStateChanged(const QByteArray& deviceId);

#ifdef APPS_FEATURE_BLE
    void bluetoothScanFinished(const QJsonObject payload);
#endif // APPS_FEATURE_BLE

    void connectDeviceFinished(
            const QByteArray &deviceId,
            const QByteArray &clientId,
            const QString &errorMessage);

    void disconnectDeviceFinished(
            const QByteArray &deviceId,
            const QByteArray &clientId,
            const QString &errorMessage);

private:
    enum class RpcMethodName {
        DownloadPlatformFilepathChanged,
        DownloadPlatformSingleFileProgress,
        DownloadPlatformSingleFileFinished,
        DownloadPlatformFilesFinished,
        AllPlatforms,
        PlatformMetaData,
        ControlViewDownloadProgress,
        DownloadViewFinished,
        UpdatesAvailable,
        UpdateFirmware,
        UpdateFirmwareJob,
        ProgramController,
        ProgramControllerJob,
        BluetoothScan,
        ConnectDevice,
        DisconnectDevice,
        PlatformDocumentsProgress,
        PlatformDocument,
        PlatformMessage,
        PlatformNotification,
        ConnectedPlatforms
    };
    constexpr const char *rpcMethodToString(RpcMethodName method);

    void sendDeviceError(
            RpcMethodName method,
            const QByteArray& deviceId,
            const QByteArray& clientId,
            const QString &errorString);

    void sendDeviceSuccess(
            RpcMethodName method,
            const QByteArray& deviceId,
            const QByteArray& clientId);

    void processCmdHcsStatus(const strata::strataRPC::RpcRequest &request);
    void processCmdLoadDocuments(const strata::strataRPC::RpcRequest &request);
    void processCmdDownloadDatasheetFile(const strata::strataRPC::RpcRequest &request);
    void processCmdDownloadPlatformFiles(const strata::strataRPC::RpcRequest &request);
    void processCmdDynamicPlatformList(const strata::strataRPC::RpcRequest &request);
    void processCmdUpdateFirmware(const strata::strataRPC::RpcRequest &request);
    void processCmdDownlodView(const strata::strataRPC::RpcRequest &request);
    void processCmdSendPlatformMessage(const strata::strataRPC::RpcRequest &request);
    void processCmdProgramController(const strata::strataRPC::RpcRequest &request);
    void processCmdCheckForUpdates(const strata::strataRPC::RpcRequest &request);
#ifdef APPS_FEATURE_BLE
    void processCmdBluetoothScan(const strata::strataRPC::RpcRequest &request);
#endif // APPS_FEATURE_BLE
    void processCmdConnectDevice(const strata::strataRPC::RpcRequest &request);
    void processCmdDisconnectDevice(const strata::strataRPC::RpcRequest &request);
    void processCmdPlatformStartApplication(const strata::strataRPC::RpcRequest &request);

    bool parseConfig(const QString& config);

    PlatformController platformController_;
    Database db_;
    QNetworkAccessManager networkManager_;
    strata::DownloadManager downloadManager_;
    StorageManager storageManager_;
    FirmwareUpdateController updateController_;
    ComponentUpdateInfo componentUpdateInfo_;
    ErrorTracker errorTracker_;

    QJsonObject config_;
    std::shared_ptr<strata::strataRPC::StrataServer> strataServer_;
};
