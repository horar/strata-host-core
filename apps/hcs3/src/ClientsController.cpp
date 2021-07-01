#include "ClientsController.h"

#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"

#include <Connector.h>
#include <rapidjson/document.h>

ClientsController::ClientsController()
{
}

ClientsController::~ClientsController()
{
    stop();
}

bool ClientsController::initialize(std::shared_ptr<HCS_Dispatcher> dispatcher, rapidjson::Value& config)
{
    using namespace strata::events_mgr;

    if (config.HasMember("subscriber_address") == false) {
        return false;
    }

    using Connector = strata::connector::Connector;
    client_connector_ = Connector::getConnector(Connector::CONNECTOR_TYPE::ROUTER);

    // opening the client socket to connect with UI
    if (client_connector_->open(config["subscriber_address"].GetString()) == false) {

        client_connector_.release();
        return false;
    }

    dispatcher_ = dispatcher;
    client_event_.create(EvEvent::EvType::eEvTypeHandle, reinterpret_cast<ev_handle_t>(client_connector_->getFileDescriptor()), 0);
    client_event_.setCallback(std::bind(&ClientsController::onDescriptorHandle, this, std::placeholders::_1, std::placeholders::_2));

    events_manager_.registerEvent(&client_event_);
    if (client_event_.activate(EvEvent::eEvStateRead) == false) {
        return false;
    }

    events_manager_.startInThread();
    return true;
}

bool ClientsController::sendMessage(const QByteArray& clientId, const QString& message)
{
    assert(clientId.isEmpty() == false);
    assert(message.isEmpty() == false);

    client_connector_->setDealerID(clientId.toStdString());
    auto status = client_connector_->send(message.toStdString());

    if (true == client_connector_->hasReadEvent()) {
        client_event_.fire(strata::events_mgr::EvEventBase::eEvStateRead);
    }

    return status;
}

void ClientsController::stop()
{
    if(events_manager_.isRunning()) {
        events_manager_.stop();
        qCInfo(logCategoryHcs) << "Clients controller stoped.";
    }
}

void ClientsController::onDescriptorHandle(strata::events_mgr::EvEventBase*, int)
{
    std::string read_message;
    DispatcherMessage msg;

    while (true == client_connector_->read(read_message)) {
        msg.from_client = QByteArray::fromStdString(client_connector_->getDealerID());
        msg.message = QByteArray::fromStdString(read_message);

        dispatcher_->addMessage(msg);
    }
}
