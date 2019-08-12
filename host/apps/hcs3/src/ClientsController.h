
#ifndef HOST_HCS_CLIENTSCONTROLER_H__
#define HOST_HCS_CLIENTSCONTROLER_H__

#include <memory>
#include <EvEventsMgr.h>

#include <rapidjson/document.h>

class HCS_Dispatcher;
class Connector;
class LoggingAdapter;

class ClientsController final
{
public:
    ClientsController();
    ~ClientsController();

    /**
     * Setup logging adapter
     * @param adapter
     */
    void setLogAdapter(LoggingAdapter* adapter);

    /**
     * Initializes clients controller
     * @param dispatcher
     * @param config
     * @return returns true when succceeded otherwise false
     */
    bool initialize(HCS_Dispatcher* dispatcher, rapidjson::Value& config);

    /**
     * Sends message to client by given clientId
     * @param clientId
     * @param message
     * @return returns true when succceeded otherwise false
     */
    bool sendMessage(const std::string& clientId, const std::string& message);

private:
    void onDescriptorHandle(spyglass::EvEventBase*, int);

private:
    HCS_Dispatcher* dispatcher_{nullptr};
    LoggingAdapter* logAdapter_{nullptr};

    std::unique_ptr<Connector> client_connector_ ;  //router

    spyglass::EvEventsMgr events_manager_;
    spyglass::EvEvent client_event_;
};

#endif //HOST_HCS_CLIENTSCONTROLER_H__
