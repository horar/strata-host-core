
#ifndef HOST_HOSTCONTROLLERSERVICE_H__
#define HOST_HOSTCONTROLLERSERVICE_H__

// rapid json library
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

#include <set>

#include <QObject>
#include "Dispatcher.h"
#include "ClientsController.h"
#include "Database.h"
#include "LoggingAdapter.h"
#include "BoardManagerWrapper.h"
#include <QJsonArray>


struct PlatformMessage;

class HCS_Client;
class StorageManager;

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
    void updatePlatformDocRequested(QString classId);

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
            int filesCompleted,
            int filesTotal);

    void sendPlatformDocumentsMessage(
            const QByteArray &clientId,
            const QJsonArray &documentList,
            const QString &error);

private:
    void handleMessage(const PlatformMessage& msg);

    void handleClientMsg(const PlatformMessage& msg);
    void handleCouchbaseMsg(const PlatformMessage& msg);
    void sendMessageToClients(const PlatformMessage& msg);
    bool disptachMessageToPlatforms(const std::string& dealer_id, const std::string& read_message);

    bool broadcastMessage(const std::string& message);

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

    void platformConnected(const QString &classId, const QString &platformId);
    void platformDisconnected(const PlatformMessage& item);

    HCS_Client* getSenderClient() const { return current_client_; }     //TODO: only one client

    HCS_Client* getClientById(const std::string& client_id);
    HCS_Client* findClientByPlatformId(const std::string& platformId);

    bool parseConfig(const QString& config);

    BoardManagerWrapper boards_;
    ClientsController clients_;     //UI or other clients
    Database db_;
    LoggingAdapter dbLogAdapter_;
    LoggingAdapter clientsLogAdapter_;

    StorageManager *storageManager_{nullptr};

    HCS_Dispatcher dispatcher_;
    std::thread dispatcherThread_;

    typedef std::function<void(const rapidjson::Value* )> NotificationHandler;

    std::map<std::string, NotificationHandler> clientCmdHandler_;
    std::map<std::string, NotificationHandler> hostCmdHandler_;

    std::list<HCS_Client*> clientList_;
    HCS_Client* current_client_;

    rapidjson::Document config_;
};

#endif //HOST_HOSTCONTROLLERSERVICE_H__
