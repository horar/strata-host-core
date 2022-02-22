/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataRPC/RpcRequest.h"

namespace strata::strataRPC
{

RpcRequest::RpcRequest()
    : sharedDataPtr_(new RpcRequestData)
{
}

RpcRequest::RpcRequest(const RpcRequest &other)
    : sharedDataPtr_(other.sharedDataPtr_)
{
}

RpcRequest::~RpcRequest()
{
}

QByteArray RpcRequest::clientId() const
{
    return sharedDataPtr_->clientId;
}

void RpcRequest::setClientId(const QByteArray clientId)
{
    sharedDataPtr_->clientId = clientId;
}

QJsonValue RpcRequest::id() const
{
    return sharedDataPtr_->id;
}

void RpcRequest::setId(const QJsonValue id)
{
    sharedDataPtr_->id = id;
}

QString RpcRequest::method() const
{
    return sharedDataPtr_->method;
}

void RpcRequest::setMethod(const QString method)
{
    sharedDataPtr_->method = method;
}

QJsonObject RpcRequest::params() const
{
    return sharedDataPtr_->params;
}

void RpcRequest::setParams(const QJsonObject params)
{
    sharedDataPtr_->params = params;
}

QDebug operator<<(QDebug debug, const RpcRequest &request)
{
    debug.noquote() << request.clientId().toHex() << request.id() << request.method() << request.params();
    return debug;
}

RpcRequest::RpcRequestData::RpcRequestData()
    : id(QJsonValue::Null)
{
}

RpcRequest::RpcRequestData::RpcRequestData(const RpcRequestData &other)
    : QSharedData(other),
      clientId(other.clientId),
      id(other.id),
      method(other.method),
      params(other.params)
{
}

} //strata::strataRPC
