#pragma once

#include <QJsonObject>
#include <QString>
#include <functional>

namespace strata::strataComm
{
enum class MessageType { Notifiation, Command, None };

enum class ResponseType { Response, Notification, PlatformMessage, Error, None };

struct Message {
    QString handlerName;
    QJsonObject payload;
    double messageID;
    QByteArray clientID;
    MessageType messageType;
    ResponseType responseType;
};

typedef std::function<void(const Message &)> StrataHandler;

}  // namespace strata::strataComm
