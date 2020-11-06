#pragma once

#include <QObject>
#include <QThread>
#include <QMap>

#include "ClientMessage.h"

namespace strata::strataComm {

class Dispatcher : public QObject
{
    Q_OBJECT
public:
    Dispatcher(QObject *parent = nullptr);
    ~Dispatcher();
    bool start();
    bool stop();
    bool dispatch(const ClientMessage &clientMessage);
    bool registerHandler(const QString &handlerName, StrataHandler handler);
    bool unregisterHandler(const QString &handlerName);

public slots:
    void dispatchHandler(const ClientMessage &clientMessage);

private:
    bool isRegisteredHandler(const QString &handlerName);
//    QMap<QString, StrataHandler> handlersList_;
    std::map<QString, StrataHandler> handlersList_;
};

}   // namespace strata::strataComm