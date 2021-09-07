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
    HostControllerService(QObject* parent = nullptr);
    ~HostControllerService() override;

    /**
     * Initializes the HCS
     * @return returns true when succeeded otherwise false
     */
    bool initialize(const QString& config);

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
            const QString &originalFilePath,
            const QString &effectiveFilePath);

    void sendDownloadPlatformSingleFileProgressMessage(
            const QByteArray &clientId,
            const QString &filePath,
            qint64 bytesReceived,
            qint64 bytesTotal);

    void sendDownloadPlatformSingleFileFinishedMessage(
            const QByteArray &clientId,
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
    void sendPlatformMessageToClients(const QString &platformId, const QJsonObject& payload);

    void handleUpdateProgress(const QByteArray& deviceId, const QByteArray& clientId, FirmwareUpdateController::UpdateProgress progress);

    void platformConnected(const QByteArray& deviceId);
    void platformDisconnected(const QByteArray& deviceId);

    void bluetoothScanFinished(const QJsonObject payload);
    void connectDeviceFinished(const QByteArray &deviceId, const QByteArray &clientId);
    void connectDeviceFailed(const QByteArray &deviceId, const QByteArray &clientId, const QString &errorMessage);
    void disconnectDeviceFinished(const QByteArray &deviceId, const QByteArray &clientId);
    void disconnectDeviceFailed(const QByteArray &deviceId, const QByteArray &clientId, const QString &errorMessage);
private:
    enum class hcsNotificationType {
        downloadPlatformFilepathChanged,
        downloadPlatformSingleFileProgress,
        downloadPlatformSingleFileFinished,
        downloadPlatformFilesFinished,
        allPlatforms,
        platformMetaData,
        controlViewDownloadProgress,
        downloadViewFinished,
        updatesAvailable,
        updateFirmware,
        updateFirmwareJob,
        programController,
        programControllerJob,
        bluetoothScan,
        connectDevice,
        disconnectDevice,
        platformDocumentsProgress,
        platformDocument,
        platformMessage,
        connectedPlatforms
    };
    constexpr const char* hcsNotificationTypeToString(hcsNotificationType notificationType);

    void sendDeviceError(hcsNotificationType notificationType, const QByteArray& deviceId, const QByteArray& clientId, const QString &errorString);
    void sendDeviceSuccess(hcsNotificationType notificationType, const QByteArray& deviceId, const QByteArray& clientId);

    void processCmdRequestHcsStatus(const strata::strataRPC::Message &message);
    void processCmdLoadDocuments(const strata::strataRPC::Message &message);
    void processCmdDownloadFiles(const strata::strataRPC::Message &message);
    void processCmdDynamicPlatformList(const strata::strataRPC::Message &message);
    void processCmdUpdateFirmware(const strata::strataRPC::Message &message);
    void processCmdDownlodView(const strata::strataRPC::Message &message);
    void processCmdSendPlatformMessage(const strata::strataRPC::Message &message);
    void processCmdProgramController(const strata::strataRPC::Message &message);
    void processCmdCheckForUpdates(const strata::strataRPC::Message &message);
    void processCmdBluetoothScan(const strata::strataRPC::Message &message);
    void processCmdConnectDevice(const strata::strataRPC::Message &message);
    void processCmdDisconnectDevice(const strata::strataRPC::Message &message);

    bool parseConfig(const QString& config);

    PlatformController platformController_;
    Database db_;
    QNetworkAccessManager networkManager_;
    strata::DownloadManager downloadManager_;
    StorageManager storageManager_;
    FirmwareUpdateController updateController_;
    ComponentUpdateInfo componentUpdateInfo_;

    QByteArray currentClient_ = "";   // remove this when platforms are mapped to connected clients.

    QJsonObject config_;
    std::shared_ptr<strata::strataRPC::StrataServer> strataServer_;
};
