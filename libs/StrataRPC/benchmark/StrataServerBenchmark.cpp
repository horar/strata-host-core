/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataServerBenchmark.h"

#include <QMetaObject>

QTEST_MAIN(StrataServerBenchmark)

void StrataServerBenchmark::benchmarkLargeNumberOfHandlers()
{
    int totalNumberOfHandlers = 10000;
    StrataServer server(address_, false);
    server.initialize();

    for (int i = 0; i < totalNumberOfHandlers; i++) {
        server.registerHandler(QString::number(i),
                               [](const strata::strataRPC::Message &) { return; });
    }

    QBENCHMARK
    {
        QMetaObject::invokeMethod(
            &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "clientId"),
            Q_ARG(QByteArray, R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})"));
    }
}

void StrataServerBenchmark::benchmarkLargeNUmberOfClients()
{
    int totalNumberOfClients = 100;
    StrataServer server(address_, false);

    for (int i = 0; i < totalNumberOfClients; i++) {
        QMetaObject::invokeMethod(
            &server, "messageReceived", Qt::DirectConnection,
            Q_ARG(QByteArray, QByteArray::number(i)),
            Q_ARG(QByteArray, R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})"));
    }

    QBENCHMARK
    {
        QMetaObject::invokeMethod(
            &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "99"),
            Q_ARG(QByteArray, R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})"));
    }
}

void StrataServerBenchmark::benchmarkRegisteringClients()
{
    int clientsCounter = 0;
    StrataServer server(address_, false);

    QBENCHMARK
    {
        QMetaObject::invokeMethod(
            &server, "messageReceived", Qt::DirectConnection,
            Q_ARG(QByteArray, QByteArray::number(clientsCounter)),
            Q_ARG(QByteArray, R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})"));
        clientsCounter++;
    }
}

void StrataServerBenchmark::benchmarkNotifyClientAPIv2()
{
    StrataServer server(address_, false);

    QMetaObject::invokeMethod(
        &server, "messageReceived", Qt::DirectConnection, Q_ARG(QByteArray, "clientId"),
        Q_ARG(
            QByteArray,
            R"({"id":1,"jsonrpc":"2.0","method":"register_client","params":{"api_version":"2.0"}})"));

    QBENCHMARK
    {
        server.notifyClient("clientId", "test_handler", QJsonObject(),
                            strata::strataRPC::ResponseType::Notification);
    }
}

void StrataServerBenchmark::benchmarkNotifyClientAPIv1()
{
    StrataServer server(address_, false);

    QMetaObject::invokeMethod(&server, "messageReceived", Qt::DirectConnection,
                              Q_ARG(QByteArray, "clientId"),
                              Q_ARG(QByteArray, R"({"cmd":"register_client", "payload":{}})"));

    QBENCHMARK
    {
        server.notifyClient("clientId", "test_handler", QJsonObject(),
                            strata::strataRPC::ResponseType::Notification);
    }
}

void StrataServerBenchmark::benchmarkNotifyClientWithLargeNumberOfClients()
{
    int totalNumberOfClients = 1000;
    StrataServer server(address_, false);

    for (int i = 0; i < totalNumberOfClients; i++) {
        QMetaObject::invokeMethod(
            &server, "messageReceived", Qt::DirectConnection,
            Q_ARG(QByteArray, QByteArray::number(i)),
            Q_ARG(QByteArray, R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})"));
    }

    QBENCHMARK
    {
        server.notifyClient("999", "test_handler", QJsonObject(),
                            strata::strataRPC::ResponseType::Notification);
    }
}
