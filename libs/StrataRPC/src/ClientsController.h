/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "Client.h"

#include <QList>
#include <QObject>

namespace strata::strataRPC
{
class ClientsController : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ClientsController);

public:
    /**
     * ClientController constructor
     */
    ClientsController(QObject *parent = nullptr) : QObject(parent)
    {
    }

    /**
     * ClientController destructor
     */
    ~ClientsController()
    {
    }

    /**
     * Returns connected Clients list. This is used to notify all connected clients.
     * @return QList of Client objects of all connected clients.
     */
    [[nodiscard]] QList<Client> getAllClients();

    /**
     * Checks if a client is connected base on client ID.
     * @param [in] clientId client if to search for.
     * @return True if the client id is registered, false otherwise.
     */
    bool isRegisteredClient(const QByteArray &clientId);

    /**
     * Register a client by adding it to connected clients list.
     * @param [in] client Client object containing the client id and API version.
     * @return True if the client was registered successfully, False if a client with the same
     * client id is already registered.
     */
    bool registerClient(const Client &client);

    /**
     * Unregister a client by removing it from connected clients list.
     * @param [in] clientId client id to unregister.
     * @return True if the client was found in the registered clients list and was removed
     * successfully. False otherwise.
     */
    bool unregisterClient(const QByteArray &clientId);

    /**
     * Returns client's API version.
     * @param [in] clientId client id to search for.
     * @return ApiVersion enum of the API version. This will return ApiVersion::none if the client
     * is not registered.
     */
    [[nodiscard]] ApiVersion getClientApiVersion(const QByteArray &clientId);

    /**
     * Returns the Client object based on the client id
     * @param [in] clientId client id to search for.
     * @return Client object. if the client is not registered it will return a client object with
     * empty client id.
     */
    [[nodiscard]] Client getClient(const QByteArray &clientId);

    /**
     * Updates client's API version
     * @param [in] clientId client id to update its API version
     * @param [in] newAPIVersion new API Version.
     * @return True if the client was found and its API Version got updated, False otherwise.
     */
    bool updateClientApiVersion(const QByteArray &clientId, const ApiVersion &newApiVersion);

private:
    QList<Client> clientsList_;
};

}  // namespace strata::strataRPC
