#pragma once

#include <QObject>

#include "Message.h"

namespace strata::strataComm
{
class Dispatcher : public QObject
{
    Q_OBJECT
public:
    /**
     * Dispatcher constructor.
     */
    Dispatcher(QObject *parent = nullptr);

    /**
     * Dispatcher destructor.
     */
    ~Dispatcher();

    /**
     * Dispatch the handler in message.handlerName
     * @param [in] message Message object that contains meta data about the which handler to execute
     * and it's arguments.
     * @return True if the handler was found and got executed, False if the handler is not
     * registered.
     */
    bool dispatch(const Message &message);

    /**
     * Register a new handler.
     * @param [in] handlerName the name of the handler.
     * @param [in] handler function pointer to function of type StrataHandler.
     * @return True if the handler was registered successfully, False if the handler wad not
     * registered successfully or handler already registered.
     */
    bool registerHandler(const QString &handlerName, StrataHandler handler);

    /**
     * Unregister a handler.
     * @param [in] handlerName the name of the handler.
     * @return returns True if the handler was found and remove successfully, False if the handler was not registered.
     */
    bool unregisterHandler(const QString &handlerName);

public slots:

    /**
     * Slot to dispatch a handler.
     * @param [in] message Message object that contains meta data about the which handler to execute
     * and it's arguments.
     */
    void dispatchHandler(const Message &message);

private:
    /**
     * Checks if a handler is registered or not.
     * @param [in] handlerName The name of the handler to search for.
     * @return True if the handler is registered, False otherwise.
     */
    bool isRegisteredHandler(const QString &handlerName);

    std::map<QString, StrataHandler> handlersList_;
};

}  // namespace strata::strataComm