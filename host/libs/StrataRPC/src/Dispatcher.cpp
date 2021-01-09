#include "Dispatcher.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

Dispatcher::Dispatcher(QObject *parent) : QObject(parent)
{
}

Dispatcher::~Dispatcher()
{
}

bool Dispatcher::registerHandler(const QString &handlerName, StrataHandler handler)
{
    qCDebug(logCategoryStrataDispatcher) << "registering " << handlerName << " handler.";

    if (true == isRegisteredHandler(handlerName)) {
        qCDebug(logCategoryStrataDispatcher()) << handlerName << " is already registered.";
        return false;
    }

    handlersList_.insert(std::make_pair(handlerName, handler));
    return true;
}

bool Dispatcher::unregisterHandler(const QString &handlerName)
{
    qCDebug(logCategoryStrataDispatcher) << "unregistering " << handlerName << " handler.";

    if (true == isRegisteredHandler(handlerName)) {
        handlersList_.erase(handlerName);
        return true;
    } else {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found" << handlerName;
        return false;
    }
}

bool Dispatcher::dispatch(const Message &message)
{
    qCDebug(logCategoryStrataDispatcher) << "Dispatching " << message.handlerName;

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
    qCDebug(logCategoryStrataDispatcher) << "Dispatching " << message.handlerName;

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
