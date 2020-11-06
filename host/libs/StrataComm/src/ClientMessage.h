#pragma once

#include <QString>
#include <QJsonObject>

namespace strata::strataComm {

struct ClientMessage {
    enum MessageType {
        Notifiation,
        Command,
        none
    };

    QString handlerName;
    QJsonObject payload;
    size_t messageID;
    QByteArray clientID;
    MessageType messageType;
};

typedef std::function<void(const ClientMessage &)> StrataHandler;

} // namespace strata::strataComm 
