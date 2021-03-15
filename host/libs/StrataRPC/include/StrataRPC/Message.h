#pragma once

#include <QJsonObject>
#include <QString>

#include <functional>

namespace strata::strataRPC
{
enum class ResponseType { Response, Notification, PlatformMessage, Error };

struct Message {
    enum class MessageType { Notification, Command, Response, Error };

    QString handlerName;
    QJsonObject payload;
    int messageID;
    QByteArray clientID;
    MessageType messageType;
};

typedef std::function<void(const Message &)> StrataHandler;

}  // namespace strata::strataRPC
