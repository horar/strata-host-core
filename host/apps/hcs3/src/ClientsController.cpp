
#include "ClientsController.h"
#include <Connector.h>
#include <rapidjson/document.h>
#include "Dispatcher.h"

ClientsController::ClientsController() : dispatcher_(nullptr)
{

}

ClientsController::~ClientsController()
{

}

bool ClientsController::initialize(HCS_Dispatcher* dispatcher, rapidjson::Value& config)
{
    if (config.HasMember("subscriber_address") == false) {
        return false;
    }

    client_connector_.reset(ConnectorFactory::getConnector(ConnectorFactory::CONNECTOR_TYPE::ROUTER));

    // opening the client socket to connect with UI
    if (client_connector_->open(config["subscriber_address"].GetString()) == false) {

        client_connector_.release();
        return false;
    }

    dispatcher_ = dispatcher;
    client_event_.create(spyglass::EvEvent::EvType::eEvTypeHandle, reinterpret_cast<spyglass::ev_handle_t>(client_connector_->getFileDescriptor()), 0);
    client_event_.setCallback(std::bind(&ClientsController::onDescriptorHandle, this, std::placeholders::_1, std::placeholders::_2));

    events_manager_.registerEvent(&client_event_);
    if (client_event_.activate(spyglass::EvEvent::eEvStateRead) == false) {
        return false;
    }

    events_manager_.startInThread();
    return true;
}

bool ClientsController::sendMessage(const std::string& clientId, const std::string& message)
{
    assert(clientId.empty() == false);
    assert(message.empty() == false);

    client_connector_->setDealerID(clientId);
    return client_connector_->send(message);
}

void ClientsController::onDescriptorHandle(spyglass::EvEventBase*, int)
{
    std::string read_message;
    PlatformMessage msg;

    for(;;) {
        if (client_connector_->read(read_message) == false) {
            break;
        }

        msg.msg_type = PlatformMessage::eMsgClientMessage;
        msg.from_client = client_connector_->getDealerID();
        msg.message = read_message;
        msg.msg_document = nullptr;

        dispatcher_->addMessage(msg);
    }
}
