/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ClientsController.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

QList<Client> ClientsController::getAllClients()
{
    return clientsList_;
}

bool ClientsController::isRegisteredClient(const QByteArray &clientId)
{
    qCDebug(lcStrataClientsController).noquote().nospace()
        << "Searching for ClientID: 0x" << clientId.toHex();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(lcStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return false;
    }
    qCDebug(lcStrataClientsController).noquote().nospace()
        << "Client is registered. ClientID: 0x" << it->getClientID().toHex()
        << ", API Version: " << static_cast<int>(it->getApiVersion());
    return true;
}

bool ClientsController::registerClient(const Client &client)
{
    qCInfo(lcStrataClientsController).noquote().nospace()
        << "Registering ClientID: 0x" << client.getClientID().toHex()
        << ", API:" << static_cast<int>(client.getApiVersion());

    if (true == isRegisteredClient(client.getClientID())) {
        qCCritical(lcStrataClientsController).noquote().nospace()
            << "Client ID is already registered. ClientID: 0x" << client.getClientID().toHex();
        return false;
    }

    clientsList_.push_back(client);
    return true;
}

bool ClientsController::unregisterClient(const QByteArray &clientId)
{
    qCInfo(lcStrataClientsController).noquote().nospace()
        << "Unregistering client. ClientID: 0x" << clientId.toHex();

    auto it = std::find_if(clientsList_.begin(), clientsList_.end(),
                           [&clientId](const Client &currentClient) {
                               return currentClient.getClientID() == clientId;
                           });

    if (it == clientsList_.end()) {
        qCDebug(lcStrataClientsController).noquote().nospace()
            << "Client not found. ClientID: 0x" << clientId.toHex();
        return false;
    } else {
        qCInfo(lcStrataClientsController).noquote().nospace()
            << "Client unregistered. ClientID: 0x" << clientId.toHex();
        clientsList_.erase(it);
        return true;
    }
}

ApiVersion ClientsController::getClientApiVersion(const QByteArray &clientId)
{
    qCDebug(lcStrataClientsController).noquote().nospace()
        << "Searching for ClientID: 0x" << clientId.toHex();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(lcStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return ApiVersion::none;
    }
    qCDebug(lcStrataClientsController).noquote().nospace()
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
        qCDebug(lcStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return Client("", ApiVersion::v2);
    }
    return clientsList_[std::distance(clientsList_.begin(), it)];
}

bool ClientsController::updateClientApiVersion(const QByteArray &clientId,
                                               const ApiVersion &newApiVersion)
{
    qCDebug(lcStrataClientsController).noquote().nospace()
        << "Updating API Version. ClientID: 0x" << clientId.toHex();
    auto it = std::find_if(clientsList_.begin(), clientsList_.end(), [&clientId](Client &client) {
        return client.getClientID() == clientId;
    });
    if (it == clientsList_.end()) {
        qCDebug(lcStrataClientsController).noquote().nospace()
            << "Client is not registered. ClientID: 0x" << clientId.toHex();
        return false;
    }
    it->UpdateClientApiVersion(newApiVersion);
    return true;
}
