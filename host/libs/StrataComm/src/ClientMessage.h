#pragma once

#include <QString>
#include <QJsonObject>
#include <functional>

namespace strata::strataComm {

// TODO: This can be used in both the server and client. find a good way to reuse this.
struct ClientMessage {
    enum MessageType {
        Notifiation,
        Command,
        none
    };

    enum ResponseType {
        Response,
        Notification,
        PlatformMessage,
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
