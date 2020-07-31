#pragma once

#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

#include <set>
#include <memory>

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QJsonArray>
#include <QNetworkAccessManager>

#include "Dispatcher.h"
#include "ClientsController.h"
#include "Database.h"
#include "LoggingAdapter.h"
#include "BoardController.h"
#include "FirmwareUpdateController.h"
#include "StorageManager.h"
#include "DownloadManager.h"
#include "CoreUpdate.h"

struct PlatformMessage;

class HCS_Client;
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
    void platformListRequested(QByteArray clientId);
    void platformDocumentsRequested(QByteArray clientId, QString classId);
    void downloadPlatformFilesRequested(QByteArray clientId, QStringList partialUriList, QString savePath);
    void cancelPlatformDocumentRequested(QByteArray clientId);
    void firmwareUpdateRequested(QByteArray clientId, int deviceId, QUrl firmwareUrl, QString firmwareMD5);
    void downloadControlViewRequested(QByteArray clientId, QString partialUri, QString md5);
    void versionInfoRequested (QByteArray clientId);

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
            const QJsonArray &documentList,
            const QJsonArray &firmwareList,
            const QJsonArray &controlViewList,
            const QString &error);

    void sendDownloadControlViewFinishedMessage(
            const QByteArray &clientId,
            const QString &partialUri,
            const QString &filePath,
            const QString &errorString);

    void sendVersionInfoMessage(
            const QByteArray &clientId,
            const QString &currentVersion,
            const QString &latestVersion,
            const QString &errorString);

private:
    void handleMessage(const PlatformMessage& msg);

    void handleClientMsg(const PlatformMessage& msg);
    void sendMessageToClients(const QString &platformId, const QString& message);

    bool broadcastMessage(const QString& message);

    void handleUpdateProgress(int deviceId, QByteArray clientId, FirmwareUpdateController::UpdateProgress progress);

    ///////
    //handlers for client (UI)
    void onCmdHCSStatus(const rapidjson::Value* );
    void onCmdUnregisterClient(const rapidjson::Value* );
    void onCmdPlatformSelect(const rapidjson::Value* );

    //handlers for hcs::cmd
    void onCmdHostDisconnectPlatform(const rapidjson::Value* );
    void onCmdHostUnregister(const rapidjson::Value* );
    void onCmdHostDownloadFiles(const rapidjson::Value* );      //from UI
    void onCmdDynamicPlatformList(const rapidjson::Value* );
    void onCmdUpdateFirmware(const rapidjson::Value* );
    void onCmdDownloadControlView(const rapidjson::Value* );
    void onCmdGetLatestReleaseVersion(const rapidjson::Value* );

    void platformConnected(const int deviceId, const QString &classId);
    void platformDisconnected(const int deviceId);

    HCS_Client* getSenderClient() const { return current_client_; }     //TODO: only one client

    HCS_Client* getClientById(const QByteArray& client_id);

    bool parseConfig(const QString& config);

    BoardController boardsController_;
    ClientsController clients_;     //UI or other clients
    Database db_;
    LoggingAdapter dbLogAdapter_;
    LoggingAdapter clientsLogAdapter_;
    QNetworkAccessManager networkManager_;
    strata::DownloadManager downloadManager_;
    StorageManager storageManager_;
    FirmwareUpdateController updateController_;
    CoreUpdate coreUpdate_;

    HCS_Dispatcher dispatcher_;
    std::thread dispatcherThread_;

    typedef std::function<void(const rapidjson::Value* )> NotificationHandler;

    std::map<std::string, NotificationHandler> clientCmdHandler_;
    std::map<std::string, NotificationHandler> hostCmdHandler_;

    std::list<HCS_Client*> clientList_;
    HCS_Client* current_client_;

    rapidjson::Document config_;
};
