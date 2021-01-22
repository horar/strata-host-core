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

    const auto [it, inserted] = handlersList_.insert(std::make_pair(handlerName, handler));
    if(false == inserted) {
        qCDebug(logCategoryStrataDispatcher()) << handlerName << " is already registered.";
    }

    return inserted;
}

bool Dispatcher::unregisterHandler(const QString &handlerName)
{
    qCDebug(logCategoryStrataDispatcher) << "unregistering " << handlerName << " handler.";

    size_t removedCount = handlersList_.erase(handlerName);
    if (removedCount == 0) {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found" << handlerName;
    }

    return removedCount != 0;
}

bool Dispatcher::dispatch(const Message &message)
{
    qCDebug(logCategoryStrataDispatcher) << "Dispatching " << message.handlerName;

    auto it = handlersList_.find(message.handlerName);

    if (it == handlersList_.end()) {
        qCCritical(logCategoryStrataDispatcher()) << "Handler not found " << message.handlerName;
        return false;
    }

    it->second(message);

    return true;
}

void Dispatcher::dispatchHandler(const Message &message)
{
    dispatch(message);
}

bool Dispatcher::isRegisteredHandler(const QString &handlerName)
{
    if (handlersList_.find(handlerName) == handlersList_.end()) {
        return false;
    }
    return true;
}
