#pragma once

#include <QString>
#include <QJsonObject>

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
