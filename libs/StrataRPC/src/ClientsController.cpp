#include "ClientsController.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

QList<Client> ClientsController::getAllClients()
{
    return clientsList_;
}

bool ClientsController::isRegisteredClient(const QByteArray &clientId)
{
    qCDebug(logCategoryStrataClientsController) << "searching for clientId: " << clientId;
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController)
            << "Client is not registered. clientId: " << clientId;
        return false;
    }
    qCDebug(logCategoryStrataClientsController)
        << "Client is registered. clientId: " << it->getClientID()
        << " API Version: " << static_cast<int>(it->getApiVersion());
    return true;
}

bool ClientsController::registerClient(const Client &client)
{
    qCInfo(logCategoryStrataClientsController)
        << "Registering Client: " << client.getClientID()
        << "API:" << static_cast<int>(client.getApiVersion());

    if (true == isRegisteredClient(client.getClientID())) {
        qCCritical(logCategoryStrataClientsController)
            << "Client ID is already registered. ClientID: " << client.getClientID();
        return false;
    }

    clientsList_.push_back(client);
    return true;
}

bool ClientsController::unregisterClient(const QByteArray &clientId)
{
    qCInfo(logCategoryStrataClientsController) << "Unregistering client. clientId: " << clientId;

    auto it = std::find_if(clientsList_.begin(), clientsList_.end(),
                           [&clientId](const Client &currentClient) {
                               return currentClient.getClientID() == clientId;
                           });

    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "Client not found. Client ID: " << clientId;
        return false;
    } else {
        qCInfo(logCategoryStrataClientsController)
            << "Client unregistered. Client ID: " << clientId;
        clientsList_.erase(it);
        return true;
    }
}

ApiVersion ClientsController::getClientApiVersion(const QByteArray &clientId)
{
    qCDebug(logCategoryStrataClientsController) << "searching for clientId: " << clientId;
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController)
            << "Client is not registered. clientId: " << clientId;
        return ApiVersion::none;
    }
    qCDebug(logCategoryStrataClientsController)
        << "Client is registered. clientId: " << it->getClientID()
        << " API Version: " << static_cast<int>(it->getApiVersion());
    return it->getApiVersion();
}

Client ClientsController::getClient(const QByteArray &clientId)
{
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController)
            << "Client is not registered. clientId: " << clientId;
        return Client("", ApiVersion::v2);
    }
    return clientsList_[std::distance(clientsList_.begin(), it)];
}

bool ClientsController::updateClientApiVersion(const QByteArray &clientId,
                                               const ApiVersion &newApiVersion)
{
    qCDebug(logCategoryStrataClientsController) << "Updating API Version. client id:" << clientId;
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController)
            << "Client is not registered. clientId: " << clientId;
        return false;
    }
    it->UpdateClientApiVersion(newApiVersion);
    return true;
}
