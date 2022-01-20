/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <StrataRPC/DeferredRequest.h>
#include <StrataRPC/Message.h>
#include <QDateTime>
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
     * @param [in] deferredRequest deferredRequest of the request.
     */
    Request(const QString &method, const QJsonObject &payload, const int &messageId,
            DeferredRequest *deferredRequest)
        : method_(method),
          payload_(payload),
          messageId_(messageId),
          deferredRequest_(deferredRequest),
          timestamp_(QDateTime::currentMSecsSinceEpoch())
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
    DeferredRequest *deferredRequest_;
    qint64 timestamp_;
};

}  // namespace strata::strataRPC
