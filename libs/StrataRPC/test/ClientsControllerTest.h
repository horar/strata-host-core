/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QSignalSpy>

#include "ClientsController.h"
#include "QtTest.h"

using strata::strataRPC::Client;
using strata::strataRPC::ClientsController;

class ClientsControllerTest : public QObject
{
    Q_OBJECT
public:
public slots:
    void notifyClientMock(const Client &client, const QString &handlerName,
                          const QJsonObject &payload);

private slots:
    void testIsRegisteredClient();
    void testRegisterClient();
    void testRegisterDublicateClient();
    void testUnregisterClient();
    void testGetApiVersion();
    void testGetClient();
    void testUpdateClientApiVersion();

private:
    ClientsController *clientsController_;
};