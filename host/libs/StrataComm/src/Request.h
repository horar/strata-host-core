#pragma once

#include <QString>
#include <QJsonObject>
#include <QJsonDocument>

namespace strata::strataComm
{

struct Request
{
    QString method;
    QJsonObject payload;
    int messageId;

    QByteArray toJson() {
        QJsonObject jsonObject{{"jsonrpc", "2.0"}, {"method", method}, {"params", payload}, {"id", messageId}};
        return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
    }
};

} // namespace strata::strataComm
