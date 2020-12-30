#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

Dispatcher::Dispatcher(QObject *parent) : QObject(parent)
{
    qCInfo(logCategoryStrataDispatcher) << "dispatcher created.";
}

Dispatcher::~Dispatcher() {
    qCInfo(logCategoryStrataDispatcher) << "dispatcher destroyed.";
}

bool Dispatcher::start() {
    qCInfo(logCategoryStrataDispatcher) << "dispatcher started.";
    return true;
}

bool Dispatcher::stop() {
    qCInfo(logCategoryStrataDispatcher) << "dispatcher stopped.";
    return true;
}

bool Dispatcher::registerHandler(const QString &handlerName, StrataHandler handler) {
    qCInfo(logCategoryStrataDispatcher) << "registering " << handlerName << " handler.";

    if(true == isRegisteredHandler(handlerName)) {
        qCDebug(logCategoryStrataDispatcher()) << handlerName << " is already registered.";
        return false;
    }

//    handlersList_.insert(handlerName, handler);   // QMap
    handlersList_.insert(std::make_pair(handlerName, handler));
    return true;
}

bool Dispatcher::unregisterHandler(const QString &handlerName) {
    qCInfo(logCategoryStrataDispatcher) << "unregistering " << handlerName << " handler.";

    if ( true == isRegisteredHandler(handlerName)) {
//        handlersList_.remove(handlerName);    // QMap
        handlersList_.erase(handlerName);
        return true;
    }
    else {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found" << handlerName;
        return true;
    }
}

bool Dispatcher::dispatch(const Message &clientMessage) {
    qCInfo(logCategoryStrataDispatcher) << "Dispatching " << clientMessage.handlerName;

    if(auto it = handlersList_.find(clientMessage.handlerName); it == handlersList_.end()) {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found " << clientMessage.handlerName;
        return false;
    } else {
//        it.value()(clientMessage);    // QMap
        it->second(clientMessage);
    }
    return true;
}

void Dispatcher::dispatchHandler(const Message &clientMessage) {
    qCInfo(logCategoryStrataDispatcher) << "Dispatching " << clientMessage.handlerName;

    if(auto it = handlersList_.find(clientMessage.handlerName); it == handlersList_.end()) {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found " << clientMessage.handlerName;
        return;
    } else {
//        it.value()(clientMessage);    // QMap
        it->second(clientMessage);
    }
}

bool Dispatcher::isRegisteredHandler(const QString &handlerName) {
    if(handlersList_.find(handlerName) == handlersList_.end()) {
        return false;
    }
    return true;
}
