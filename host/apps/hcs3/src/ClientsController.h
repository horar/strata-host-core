#ifndef HOST_HCS_CLIENTSCONTROLER_H__
#define HOST_HCS_CLIENTSCONTROLER_H__

#include <memory>

#include <EventsMgr/EvEventsMgr.h>

#include <QString>
#include <QByteArray>

#include <rapidjson/document.h>

class HCS_Dispatcher;
namespace strata::connector
{
class Connector;
}

class ClientsController final
{
public:
    ClientsController();
    ~ClientsController();

    /**
     * Initializes clients controller
     * @param dispatcher
     * @param config
     * @return returns true when succceeded otherwise false
     */
    bool initialize(std::shared_ptr<HCS_Dispatcher> dispatcher, rapidjson::Value& config);

    /**
     * Sends message to client by given clientId
     * @param clientId
     * @param message
     * @return returns true when succceeded otherwise false
     */
    bool sendMessage(const QByteArray& clientId, const QString& message);

    /**
     * Stops the clients controller
     */
    void stop();

private:
    void onDescriptorHandle(strata::events_mgr::EvEventBase*, int);

private:
    std::shared_ptr<HCS_Dispatcher> dispatcher_;

    std::unique_ptr<strata::connector::Connector> client_connector_ ;  //router

    strata::events_mgr::EvEventsMgr events_manager_;
    strata::events_mgr::EvEvent client_event_;
};

#endif //HOST_HCS_CLIENTSCONTROLER_H__
