
#ifndef HOST_HOSTCONTROLLERSERVICE_H__
#define HOST_HOSTCONTROLLERSERVICE_H__

// rapid json library
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <rapidjson/stringbuffer.h>

#include <set>

#include <QObject>
#include "BoardsController.h"
#include "Dispatcher.h"
#include "ClientsController.h"
#include "Database.h"


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

public slots:

private:
    void handleMesages(const PlatformMessage& msg);

    void handleClientMsg(const PlatformMessage& msg);
    void handleCouchbaseMsg(const PlatformMessage& msg);
    void handleStorageRequest(const PlatformMessage& msg);
    void handleStorageResponse(const PlatformMessage& msg);

    void sendMessageToClients(const PlatformMessage& msg);
    bool disptachMessageToPlatforms(const std::string& dealer_id, const std::string& read_message);

    bool broadcastMessage(const std::string& message);

    ///////
    //handlers for client (UI)
    void onCmdHCSStatus(const rapidjson::Value* );
    void onCmdRegisterClient(const rapidjson::Value* );
    void onCmdUnregisterClient(const rapidjson::Value* );
    void onCmdPlatformSelect(const rapidjson::Value* );
    void onCmdRequestAvaibilePlatforms(const rapidjson::Value* );

    //handlers for hcs::cmd
    void onCmdHostJwtToken(const rapidjson::Value* );
    void onCmdHostAdvertisePlatforms(const rapidjson::Value* );
    void onCmdHostGetPlatforms(const rapidjson::Value* );
    void onCmdHostRemoteDisconnect(const rapidjson::Value* );
    void onCmdHostDisconnectRemoteUser(const rapidjson::Value* );
    void onCmdHostDisconnectPlatform(const rapidjson::Value* );
    void onCmdHostUnregister(const rapidjson::Value* );
    void onCmdHostDownloadFiles(const rapidjson::Value* );      //from UI

    //called from Platform manager to handle platforms connect/disconnect
    void platformConnected(const PlatformMessage& item);
    void platformDisconnected(const PlatformMessage& item);

private:
    HCS_Client* getSenderClient() const { return current_client_; }     //TODO: only one client

    HCS_Client* getClientById(const std::string& client_id);
    HCS_Client* findClientByPlatformId(const std::string& platformId);

    bool parseConfig(const QString& config);

private:
    BoardsController boards_;
    ClientsController clients_;     //UI or other clients
    Database db_;

    StorageManager* storage_{nullptr};

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
