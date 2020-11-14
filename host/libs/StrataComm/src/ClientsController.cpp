#include "ClientsController.h"

using namespace strata::strataComm;

void ClientsController::notifyAllClients(const QJsonObject &payload) {
    qCInfo(logCategoryStrataClientsController) << "Notifying all clients.";
    qCInfo(logCategoryStrataClientsController) << "Payload: " << payload;
    for( const auto &client : clientsList_) {
        qCInfo(logCategoryStrataClientsController) << "Notifying Client ID: " << client.getClientID();
        emit notifyClientSignal(client, payload);
    }
}

bool ClientsController::isRegisteredClient(const QByteArray &clientID) {
    qCInfo(logCategoryStrataClientsController) << "searching for clientID: " << clientID;
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (Client &client) {
        return client.getClientID() == clientID;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "Client is not registered. clientID: " << clientID;
        return false;
    }
    qCDebug(logCategoryStrataClientsController) << "Client is registered. clientID: " << it->getClientID() << " API Version: " << static_cast<int>(it->getApiVersion());
    return true;
}

bool ClientsController::registerClient(const Client &client) {
    qCInfo(logCategoryStrataClientsController) << "Registering Client: " << client.getClientID() << " " << static_cast<int>(client.getApiVersion());

    // find a better way.. maybe use different DS that vector or qlist? 
    if (true == isRegisteredClient(client.getClientID())) {
        qCCritical(logCategoryStrataClientsController) << "Client ID is already registered. ClientID: " << client.getClientID();
        return false;
    }

    clientsList_.push_back(client);
    return true;
}

bool ClientsController::unregisterClient(const QByteArray &clientID) {
    qCInfo(logCategoryStrataClientsController) << "Unregistering client. clientID: " << clientID;

    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (const Client &currentClient) {
        return currentClient.getClientID() == clientID;
    });

    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "Client not found. Client ID: " << clientID;
        return false;
    } else {
        qCDebug(logCategoryStrataClientsController) << "Client unregistered. Client ID: " << clientID;
        clientsList_.erase(it);
        return true;
    }
}

ApiVersion ClientsController::getClientApiVersion(const QByteArray &clientID) {
    qCInfo(logCategoryStrataClientsController) << "searching for clientID: " << clientID;
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (Client &client) {
        return client.getClientID() == clientID;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "Client is not registered. clientID: " << clientID;
        return ApiVersion::none;
    }
    qCDebug(logCategoryStrataClientsController) << "Client is registered. clientID: " << it->getClientID() << " API Version: " << static_cast<int>(it->getApiVersion());
    return it->getApiVersion();
}

Client ClientsController::getClient(const QByteArray &clientID) {
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (Client &client) {
        return client.getClientID() == clientID;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "Client is not registered. clientID: " << clientID;
        return Client("", ApiVersion::v2);
    }
    return clientsList_[std::distance(clientsList_.begin(), it)];
}
