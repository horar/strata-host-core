/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataRPC/DeferredReply.h"

namespace strata::strataRPC
{

DeferredReply::DeferredReply(QObject *parent)
    : QObject(parent)
{
}

int DeferredReply::id() const
{
    return id_;
}

void DeferredReply::setId(int id)
{
    if (id_ == id) {
        return;
    }

    id_ = id;
}

QString DeferredReply::method() const
{
    return method_;
}

void DeferredReply::setMethod(const QString &method)
{
    method_ = method;
}

QJsonObject DeferredReply::params() const
{
    return params_;
}

void DeferredReply::setParams(const QJsonObject &params)
{
    params_ = params;
}

qint64 DeferredReply::timestamp() const
{
    return timestamp_;
}

void DeferredReply::setTimestamp(qint64 timestamp)
{
    timestamp_ = timestamp;
}

QDebug operator<<(QDebug debug, const DeferredReply &reply)
{
    return debug << &reply;
}

QDebug operator<<(QDebug debug, const DeferredReply *reply)
{
    debug.noquote() << reply->id() << reply->timestamp() << reply->method() << reply->params();
    return debug;
}

void DeferredReply::callSuccessCallback(const QJsonObject &result)
{
    emit finishedSuccessfully(result);
}

void DeferredReply::callErrorCallback(const QJsonObject &error)
{
    emit finishedWithError(error);
}

} // namespace strata::strataRPC
