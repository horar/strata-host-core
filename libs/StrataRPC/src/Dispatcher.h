/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "logging/LoggingQtCategories.h"

#include <functional>

namespace strata::strataRPC
{
template <class HandlerArgument>
class Dispatcher
{
public:
    typedef std::function<void(const HandlerArgument &)> Handler;

    /**
     * Dispatcher constructor.
     */
    Dispatcher();

    /**
     * Dispatcher destructor.
     */
    ~Dispatcher();

    /**
     * Dispatch the handler in message.handlerName
     * @param handlerName The name of the registered handler.
     * @param argument The argument to pass to the handler.
     * @return True if the handler was found and got executed, False if the handler is not
     * registered.
     */
    bool dispatch(const QString &handlerName, const HandlerArgument &argument);

    /**
     * Register a new handler.
     * @param [in] handlerName the name of the handler.
     * @param [in] handler function pointer to function of type Handler.
     * @return True if the handler was registered successfully, False if the handler wad not
     * registered successfully or handler already registered.
     */
    bool registerHandler(const QString &handlerName, Handler handler);

    /**
     * Unregister a handler.
     * @param [in] handlerName the name of the handler.
     * @return returns True if the handler was found and remove successfully, False if the handler
     * was not registered.
     */
    bool unregisterHandler(const QString &handlerName);

private:
    std::map<QString, Handler> handlersList_;
};

template <class HandlerArgument>
Dispatcher<HandlerArgument>::Dispatcher()
{
}

template <class HandlerArgument>
Dispatcher<HandlerArgument>::~Dispatcher()
{
}

template <class HandlerArgument>
bool Dispatcher<HandlerArgument>::registerHandler(const QString &handlerName, Handler handler)
{
    qCDebug(lcStrataDispatcher) << "registering" << handlerName << "handler.";

    const auto [it, inserted] = handlersList_.insert(std::make_pair(handlerName, handler));
    if (false == inserted) {
        qCDebug(lcStrataDispatcher) << handlerName << "is already registered.";
    }

    return inserted;
}

template <class HandlerArgument>
bool Dispatcher<HandlerArgument>::unregisterHandler(const QString &handlerName)
{
    qCDebug(lcStrataDispatcher) << "unregistering " << handlerName << " handler.";

    size_t removedCount = handlersList_.erase(handlerName);
    if (removedCount == 0) {
        qCCritical(lcStrataDispatcher) << "Handler not found:" << handlerName;
    }

    return removedCount != 0;
}

template <class HandlerArgument>
bool Dispatcher<HandlerArgument>::dispatch(const QString &handlerName,
                                           const HandlerArgument &argument)
{
    // qCDebug(lcStrataDispatcher) << "Dispatching " << handlerName;

    auto it = handlersList_.find(handlerName);

    if (it == handlersList_.end()) {
        qCCritical(lcStrataDispatcher) << "Handler not found:" << handlerName;
        return false;
    }

    it->second(argument);

    return true;
}

}  // namespace strata::strataRPC
