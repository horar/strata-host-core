#pragma once

#include <QJsonObject>
#include <QString>
#include <functional>

namespace strata::strataComm
{
enum MessageType { Notifiation, Command, none };

enum ResponseType { Response, Notification, PlatformMessage, Error };

struct Message {
    QString handlerName;
    QJsonObject payload;
    double messageID;
};

struct ClientMessage : public Message {
    MessageType messageType;
    QByteArray clientID;
};

struct ServerMessage : public Message {
    ResponseType responseType;
};

typedef std::function<void(const ClientMessage &)> StrataHandler;
typedef std::function<void(const ClientMessage &)> ServerHandler;
typedef std::function<void(const ServerMessage &)> ClientHandler;

}  // namespace strata::strataComm
