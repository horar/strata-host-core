#pragma once

#include <QObject>
#include <QThread>
#include <QMap>

#include "ClientMessage.h"

class Dispatcher : public QObject
{
    Q_OBJECT
public:
    Dispatcher(QObject *parent = nullptr);
    ~Dispatcher();
    bool start();
    bool stop();
    bool dispatch(const ClientMessage &clientMessage);
    bool registerHandler(const QString &handlerName, std::function<void(const ClientMessage &)> handler);
    bool unregisterHandler(const QString &handlerName);

public slots:
    void dispatchHandler(const ClientMessage &clientMessage);

private:
    bool isRegisteredHandler(const QString &handlerName);
//    QMap<QString, std::function<void(const ClientMessage &)>> handlersList_;
    std::map<QString, std::function<void(const ClientMessage &)>> handlersList_;
};
