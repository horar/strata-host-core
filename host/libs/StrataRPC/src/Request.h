#pragma once

#include <StrataRPC/Message.h>
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
    Request(QString method, QJsonObject payload, int messageId,
            StrataHandler errorCallback = nullptr, StrataHandler resultCallback = nullptr)
        : method_(method),
          payload_(payload),
          messageId_(messageId),
          errorCallback_(errorCallback),
          resultCallback_(resultCallback)
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
            {"jsonrpc", "2.0"}, {"method", method_}, {"params", payload_}, {"id", messageId_}};
        return QJsonDocument(jsonObject).toJson(QJsonDocument::JsonFormat::Compact);
    }

    QString method_;
    QJsonObject payload_;
    int messageId_;
    StrataHandler errorCallback_;
    StrataHandler resultCallback_;
};

}  // namespace strata::strataRPC
