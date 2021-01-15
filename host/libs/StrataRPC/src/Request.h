#pragma once

#include <QJsonDocument>
#include <QJsonObject>
#include <QString>

namespace strata::strataRPC
{
struct Request {
    /**
     * Request constructor.
     * @param [in] method name of the handler.
     * @param [in] payload QJsonObject of the request payload.
     * @param [in] messageId request id.
     */
    Request(QString method, QJsonObject payload, int messageId)
        : method(method), payload(payload), messageId(messageId)
    {
    }

    /**
     * convert the request to QByteArray Json to be sent to the server.
     * @return QByteArray of formatted json to be sent to the server. This will create API v2 style
     * message.
     */
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

}  // namespace strata::strataRPC
