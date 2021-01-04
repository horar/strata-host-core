#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

Dispatcher::Dispatcher(QObject *parent) : QObject(parent)
{
    qCInfo(logCategoryStrataDispatcher) << "dispatcher created.";
}

Dispatcher::~Dispatcher()
{
    qCInfo(logCategoryStrataDispatcher) << "dispatcher destroyed.";
}

bool Dispatcher::start()
{
    qCInfo(logCategoryStrataDispatcher) << "dispatcher started.";
    return true;
}

bool Dispatcher::stop()
{
    qCInfo(logCategoryStrataDispatcher) << "dispatcher stopped.";
    return true;
}

bool Dispatcher::registerHandler(const QString &handlerName, StrataHandler handler)
{
    qCInfo(logCategoryStrataDispatcher) << "registering " << handlerName << " handler.";

    if (true == isRegisteredHandler(handlerName)) {
        qCDebug(logCategoryStrataDispatcher()) << handlerName << " is already registered.";
        return false;
    }

    handlersList_.insert(std::make_pair(handlerName, handler));
    return true;
}

bool Dispatcher::unregisterHandler(const QString &handlerName)
{
    qCInfo(logCategoryStrataDispatcher) << "unregistering " << handlerName << " handler.";

    if (true == isRegisteredHandler(handlerName)) {
        handlersList_.erase(handlerName);
        return true;
    } else {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found" << handlerName;
        return true;
    }
}

bool Dispatcher::dispatch(const Message &message)
{
    qCInfo(logCategoryStrataDispatcher) << "Dispatching " << message.handlerName;

    if (auto it = handlersList_.find(message.handlerName); it == handlersList_.end()) {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found " << message.handlerName;
        return false;
    } else {
        it->second(message);
    }
    return true;
}

void Dispatcher::dispatchHandler(const Message &message)
{
    qCInfo(logCategoryStrataDispatcher) << "Dispatching " << message.handlerName;

    if (auto it = handlersList_.find(message.handlerName); it == handlersList_.end()) {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found " << message.handlerName;
        return;
    } else {
        it->second(message);
    }
}

bool Dispatcher::isRegisteredHandler(const QString &handlerName)
{
    if (handlersList_.find(handlerName) == handlersList_.end()) {
        return false;
    }
    return true;
}
