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

} // namespace strata::strataComm 
