#include "ClientsController.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

QList<Client> ClientsController::getAllClients()
{
    return clientsList_;
}

bool ClientsController::isRegisteredClient(const QByteArray &clientId)
{
    qCDebug(logCategoryStrataClientsController).noquote().nospace()
        << "Searching for ClientID: 0x" << clientId.toHex();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return false;
    }
    qCDebug(logCategoryStrataClientsController).noquote().nospace()
        << "Client is registered. ClientID: 0x" << it->getClientID().toHex()
        << ", API Version: " << static_cast<int>(it->getApiVersion());
    return true;
}

bool ClientsController::registerClient(const Client &client)
{
    qCInfo(logCategoryStrataClientsController).noquote().nospace()
        << "Registering ClientID: 0x" << client.getClientID().toHex()
        << ", API:" << static_cast<int>(client.getApiVersion());

    if (true == isRegisteredClient(client.getClientID())) {
        qCCritical(logCategoryStrataClientsController).noquote().nospace()
            << "Client ID is already registered. ClientID: 0x" << client.getClientID().toHex();
        return false;
    }

    clientsList_.push_back(client);
    return true;
}

bool ClientsController::unregisterClient(const QByteArray &clientId)
{
    qCInfo(logCategoryStrataClientsController).noquote().nospace()
        << "Unregistering client. ClientID: 0x" << clientId.toHex();

    auto it = std::find_if(clientsList_.begin(), clientsList_.end(),
                           [&clientId](const Client &currentClient) {
                               return currentClient.getClientID() == clientId;
                           });

    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController).noquote().nospace()
            << "Client not found. ClientID: 0x" << clientId.toHex();
        return false;
    } else {
        qCInfo(logCategoryStrataClientsController).noquote().nospace()
            << "Client unregistered. ClientID: 0x" << clientId.toHex();
        clientsList_.erase(it);
        return true;
    }
}

ApiVersion ClientsController::getClientApiVersion(const QByteArray &clientId)
{
    qCDebug(logCategoryStrataClientsController).noquote().nospace()
        << "Searching for ClientID: 0x" << clientId.toHex();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return ApiVersion::none;
    }
    qCDebug(logCategoryStrataClientsController).noquote().nospace()
        << "Client is registered. ClientID: 0x" << it->getClientID().toHex()
        << ", API Version: " << static_cast<int>(it->getApiVersion());
    return it->getApiVersion();
}

Client ClientsController::getClient(const QByteArray &clientId)
{
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return Client("", ApiVersion::v2);
    }
    return clientsList_[std::distance(clientsList_.begin(), it)];
}

bool ClientsController::updateClientApiVersion(const QByteArray &clientId,
                                               const ApiVersion &newApiVersion)
{
    qCDebug(logCategoryStrataClientsController).noquote().nospace()
        << "Updating API Version. ClientID: 0x" << clientId.toHex();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return false;
    }
    it->UpdateClientApiVersion(newApiVersion);
    return true;
}
