#pragma once

#include <QJsonDocument>
#include <QJsonObject>
#include <QString>

namespace strata::strataComm
{
struct Request {
    Request(QString method, QJsonObject payload, int messageId)
        : method(method), payload(payload), messageId(messageId)
    {
    }

    QByteArray toJson()
    {
        QJsonObject jsonObject{
            {"jsonrpc", "2.0"}, {"method", method}, {"params", payload}, {"id", messageId}};
        return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
    }

    QString method;
    QJsonObject payload;
    int messageId;
};

}  // namespace strata::strataComm
