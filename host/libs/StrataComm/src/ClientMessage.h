#pragma once

#include <QString>
#include <QJsonObject>
#include <functional>

namespace strata::strataComm {

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

struct Message {
    QString handlerName;
    QJsonObject payload;
    double messageID;
    MessageType messageType;
};

struct ClientMessage : public Message {
    QByteArray clientID;
};

struct ServerMessage : public Message {
    ResponseType responseType;
};

typedef std::function<void(const ClientMessage &)> StrataHandler;

} // namespace strata::strataComm 
