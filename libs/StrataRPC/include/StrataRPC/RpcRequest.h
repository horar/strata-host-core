/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QSharedData>
#include <QString>
#include <QJsonObject>
#include <QJsonValue>
#include <QDebug>

namespace strata::strataRPC
{

class RpcRequest
{
public:
    RpcRequest();
    RpcRequest(const RpcRequest &other);
    ~RpcRequest();

    QByteArray clientId() const;
    void setClientId(const QByteArray clientId);

    QJsonValue id() const;
    void setId(const QJsonValue id);

    QString method() const;
    void setMethod(const QString method);

    QJsonObject params() const;
    void setParams(const QJsonObject params);

    friend QDebug operator<<(QDebug debug, const RpcRequest &request);

private:
    class RpcRequestData: public QSharedData
    {
    public:
        RpcRequestData();
        RpcRequestData(const RpcRequestData &other);

        QByteArray clientId;
        QJsonValue id;
        QString method;
        QJsonObject params;
    };

    QSharedDataPointer<RpcRequestData> sharedDataPtr_;
};

} //strata::strataRPC
