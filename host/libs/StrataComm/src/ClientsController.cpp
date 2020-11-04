#include "ClientsController.h"

ClientsController::ClientsController(QObject *parent) : QObject(parent) {
}

ClientsController::~ClientsController() {
}

// Client *ClientsController::getClient(QByteArray clientID) {
//     qCInfo(logCategoryStrataClientsController) << "searching for clientID: " << clientID;
//     auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (Client &client) {
//         return client.getClientID() == clientID;
//     });
//     if (it == clientsList_.end()) {
//         return nullptr;
//     }
//     return it;
// }

// Client &ClientsController::getClient(QByteArray clientID) const {
//     qCInfo(logCategoryStrataClientsController) << "searching for clientID: " << clientID;
//     auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (Client &client) {
//         return client.getClientID() == clientID;
//     });
//     if (it == clientsList_.end()) {
//         return nullptr;
//     }
//     return it;
// }

void ClientsController::notifyAllClients(/* Add a payload */) {
    
}

bool ClientsController::isRegisteredClient(QByteArray clientID) {
    qCInfo(logCategoryStrataClientsController) << "searching for clientID: " << clientID;
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientID] (Client &client) {
        return client.getClientID() == clientID;
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "Client not found. clientID: " << clientID;
        return false;
    }
    qCDebug(logCategoryStrataClientsController) << "Client found. clientID: " << clientID;
    return true;
}

bool ClientsController::registerClient(Client client) {
    qCInfo(logCategoryStrataClientsController) << "Registering Client: " << client.getClientID() << " " << client.getApiVersion();
    clientsList_.push_back(client);
    return true;
}

bool ClientsController::unregisterClient(Client client) {
    qCInfo(logCategoryStrataClientsController) << "Unregistering Client: " << client.getClientID() << " " << client.getApiVersion();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&client] (Client &currentClient) {
        return currentClient.getClientID() == client.getClientID();
    });
    if (it == clientsList_.end()) {
        qCDebug(logCategoryStrataClientsController) << "client not found. Client ID: " << client.getClientID();
        return false;
    } else {
        qCDebug(logCategoryStrataClientsController) << "client unregistered. Client ID: " << client.getClientID();
        clientsList_.erase(it);
        return true;
    }
}
