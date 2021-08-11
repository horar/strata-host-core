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
#include "PlatformController.h"
#include "FirmwareUpdateController.h"
#include "StorageManager.h"

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

    void parseMessageFromClient(const QByteArray &message, const QByteArray &clientId);

private:
    void handleMessage(const DispatcherMessage& msg);

    void sendMessageToClients(const QString &platformId, const QString& message);

    bool broadcastMessage(const QString& message);

    void handleUpdateProgress(const QByteArray& deviceId, const QByteArray& clientId, FirmwareUpdateController::UpdateProgress progress);

    void processCmdRequestHcsStatus(const strata::strataRPC::Message &message);
    void processCmdLoadDocuments(const strata::strataRPC::Message &message);
    void processCmdDownloadFiles(const strata::strataRPC::Message &message);
    void processCmdDynamicPlatformList(const strata::strataRPC::Message &message);
    void processCmdUpdateFirmware(const strata::strataRPC::Message &message);
    void processCmdDownlodView(const strata::strataRPC::Message &message);

    void processCmdRequestHcsStatus(const QByteArray &clientId);
    void processCmdClientUnregister(const QByteArray &clientId); // this is built in command
    void processCmdLoadDocuments(const QJsonObject &payload, const QByteArray &clientId);
    void processCmdHostUnregister(const QByteArray &clientId); // this is built in command
    void processCmdDownloadFiles(const QJsonObject &payload, const QByteArray &clientId);
    void processCmdDynamicPlatformList(const QByteArray &clientId);
    void processCmdUpdateFirmware(const QJsonObject &payload, const QByteArray &clientId);
    void processCmdDownlodView(const QJsonObject &payload, const QByteArray &clientId);

    void platformConnected(const QByteArray& deviceId);
    void platformDisconnected(const QByteArray& deviceId);

    Client* getSenderClient() const { return current_client_; }     //TODO: only one client

    Client* getClientById(const QByteArray& client_id);

    bool parseConfig(const QString& config);

    void callHandlerForTypeCmd(
            const QString &cmdName,
            const QJsonObject &payload,
            const QByteArray &clientId);

    void callHandlerForTypeHcsCmd(
            const QString &cmdName,
            const QJsonObject &payload,
            const QByteArray &clientId);

    PlatformController platformController_;
    ClientsController clients_;     //UI or other clients
    Database db_;
    QNetworkAccessManager networkManager_;
    strata::DownloadManager downloadManager_;
    StorageManager storageManager_;
    FirmwareUpdateController updateController_;

    std::shared_ptr<HCS_Dispatcher> dispatcher_;
    std::thread dispatcherThread_;

    std::list<Client*> clientList_;
    Client* current_client_;

    rapidjson::Document config_;
    std::shared_ptr<strata::strataRPC::StrataServer> strataServer_;
};
