
#ifndef HOST_HCS_CLIENTSCONTROLER_H__
#define HOST_HCS_CLIENTSCONTROLER_H__

#include <memory>
#include <EvEventsMgr.h>

#include <rapidjson/document.h>

class HCS_Dispatcher;
class Connector;

class ClientsController final
{
public:
    ClientsController();
    ~ClientsController();

    bool initialize(HCS_Dispatcher* dispatcher, rapidjson::Value& config);

    bool sendMessage(const std::string& clientId, const std::string& message);

private:
    void onDescriptorHandle(spyglass::EvEventBase*, int);

private:
    HCS_Dispatcher* dispatcher_;

    std::unique_ptr<Connector> client_connector_ ;  //router

    spyglass::EvEventsMgr events_manager_;
    spyglass::EvEvent client_event_;
};

#endif //HOST_HCS_CLIENTSCONTROLER_H__
