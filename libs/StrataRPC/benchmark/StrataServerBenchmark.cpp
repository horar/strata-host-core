#include "StrataServerBenchmark.h"

void StrataServerBenchmark::benchmarkLargeNumberOfHandlers()
{
    int totalNumberOfHandlers = 10000;
    StrataServer server(address_, false);
    server.initializeServer();

    for (int i = 0; i < totalNumberOfHandlers; i++) {
        server.registerHandler(QString::number(i),
                               [](const strata::strataRPC::Message &) { return; });
    }

    QBENCHMARK
    {
        server.newClientMessage("clientId",
                                R"({"jsonrpc": "2.0","method":"100000","params": {},"id":1})");
    }
}

void StrataServerBenchmark::benchmarkLargeNUmberOfClients()
{
    int totalNumberOfClients = 100;
    StrataServer server(address_, false);

    for (int i = 0; i < totalNumberOfClients; i++) {
        server.newClientMessage(QByteArray::number(i),
                                R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})");
    }

    QBENCHMARK
    {
        server.newClientMessage("99", R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})");
    }
}

void StrataServerBenchmark::benchmarkRegisteringClients()
{
    int clientsCounter = 0;
    StrataServer server(address_, false);

    QBENCHMARK
    {
        server.newClientMessage(QByteArray::number(clientsCounter),
                                R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})");
        clientsCounter++;
    }
}

void StrataServerBenchmark::benchmarkNotifyClientAPIv2()
{
    StrataServer server(address_, false);

    server.newClientMessage(
        "clientId",
        R"({"id":1,"jsonrpc":"2.0","method":"register_client","params":{"api_version":"2.0"}})");

    QBENCHMARK
    {
        server.notifyClient("clientId", "test_handler", QJsonObject(),
                            strata::strataRPC::ResponseType::Notification);
    }
}

void StrataServerBenchmark::benchmarkNotifyClientAPIv1()
{
    StrataServer server(address_, false);

    server.newClientMessage("clientId", R"({"cmd":"register_client", "payload":{}})");

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
        server.newClientMessage(QByteArray::number(i),
                                R"({"jsonrpc": "2.0","method":"100","params": {},"id":1})");
    }

    QBENCHMARK
    {
        server.notifyClient("999", "test_handler", QJsonObject(),
                            strata::strataRPC::ResponseType::Notification);
    }
}