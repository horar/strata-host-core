#pragma once

#include <QString>
#include <QJsonObject>
#include <functional>

namespace strata::strataComm {

struct ClientMessage {
    enum MessageType {
        Notifiation,
        Command,
        none
    };

    enum ResponseType {
        Response,
        Notification,
        Error
    };

    QString handlerName;
    QJsonObject payload;
    double messageID;
    QByteArray clientID;
    MessageType messageType;
};

typedef std::function<void(const ClientMessage &)> StrataHandler;

} // namespace strata::strataComm 
