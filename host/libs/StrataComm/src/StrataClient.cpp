#include "StrataClient.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

StrataClient::StrataClient(QString serverAddress, QObject *parent) : QObject(parent), dispatcher_(this), connector_(serverAddress)
{
}

StrataClient::~StrataClient()
{
}

bool StrataClient::connectServer()
{
    if (false == connector_.initilize()) {
        qCCritical(logCategoryStrataClient) << "Failed to connect to the server";
        return false;
    }

    connect(&connector_, &ClientConnector::newMessageRecived, this, &StrataClient::newServerMessage);
    connect(this, &StrataClient::dispatchHandler, &dispatcher_, &Dispatcher::dispatchHandler);

    // send register command to the server.
    // TODO: update this when implementing build request function
    connector_.sendMessage(R"({"jsonrpc": "2.0","method":"register_client","params": {"api_version": "1.0"},"id":1})");

    return true;
}

bool StrataClient::disconnectServer() 
{
    connector_.sendMessage(R"({"jsonrpc": "2.0","method":"unregister","params":{},"id":1})");
    disconnect(&connector_, &ClientConnector::newMessageRecived, this, &StrataClient::newServerMessage);
    // TODO: implement disconnect function in the connectors
}

void StrataClient::newServerMessage(const QByteArray &serverMessage)
{
    qCDebug(logCategoryStrataClient) << "New message from the server:" << serverMessage;
}

bool StrataClient::registerHandler(const QString &handlerName, StrataHandler handler)
{
    qCDebug(logCategoryStrataClient) << "Registering Handler:" << handlerName;
    if (false == dispatcher_.registerHandler(handlerName, handler)) {
        qCCritical(logCategoryStrataClient) << "Failed to register handler.";
        return false;
    }
    return true;
}

bool StrataClient::unregisterHandler(const QString &handlerName)
{
    qCDebug(logCategoryStrataClient) << "Unregistering handler:" << handlerName;
    if (false == dispatcher_.unregisterHandler(handlerName)) { // always return true.
        qCCritical(logCategoryStrataClient) << "Failed to unregister handler.";
        return false;
    }
    return true;
}
