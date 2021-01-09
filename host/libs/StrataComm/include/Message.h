#pragma once

#include <QJsonObject>
#include <QString>

#include <functional>

namespace strata::strataComm
{
enum class ResponseType { Response, Notification, PlatformMessage, Error };

struct Message {
    enum class MessageType { Notification, Command, Response, Error };

    QString handlerName;
    QJsonObject payload;
    double messageID;
    QByteArray clientID;
    MessageType messageType;
};

typedef std::function<void(const Message &)> StrataHandler;

}  // namespace strata::strataComm
