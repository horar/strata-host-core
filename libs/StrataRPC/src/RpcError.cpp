/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataRPC/RpcError.h"

namespace strata::strataRPC
{

RpcError::RpcError(ErrorCode code)
    : sharedDataPtr_(new RpcErrorData)
{
    setCode(code);
}

RpcError::RpcError(ErrorCode code, QString message)
    : sharedDataPtr_(new RpcErrorData)
{
    setCode(code);
    setMessage(message);
}

RpcError::RpcError(
        ErrorCode code,
        QString message,
        QJsonObject data)
    : sharedDataPtr_(new RpcErrorData)
{
    setCode(code);
    setMessage(message);
    setData(data);
}

RpcError::RpcError(const RpcError &other)
    : sharedDataPtr_(other.sharedDataPtr_)
{
}

RpcError::ErrorCode RpcError::code() const
{
    return sharedDataPtr_->code;
}

void RpcError::setCode(const ErrorCode &code)
{
    sharedDataPtr_->code = code;
}

QString RpcError::message() const
{
    if (sharedDataPtr_->message.isEmpty()) {
        return defaultMessage(sharedDataPtr_->code);
    }

    return sharedDataPtr_->message;
}

void RpcError::setMessage(const QString &message)
{
    sharedDataPtr_->message = message;
}

QJsonObject RpcError::data() const {
    return sharedDataPtr_->data;
}

void RpcError::setData(const QJsonObject &data) {
    sharedDataPtr_->data = data;
}

QString RpcError::defaultMessage(ErrorCode code)
{
    switch(code) {
    case NoError: return "";
    case ParseError: return "parse error";
    case InvalidRequestError: return "invalid request";
    case MethodNotFoundError: return "method not found";
    case InvalidParamsError: return "invalid parameter(s)";
    case InternalError: return "internal json-rpc error";
    case ClientRegistrationError: return "client registration error";
    case UnknownApiVersionError: return "unknown api version";
    case ClientAlreadyRegisteredError: return "client already registered";
    case ClientUnregistrationError: return "client unregistration error";
    case ProcedureExecutionError: return "procedure execution error";

    default:
        return "";
    }
}

QDebug operator<<(QDebug debug, const RpcError &error)
{
    debug.noquote().nospace()
            << error.code()
            << " "
            << error.message()
            << ", data: " << error.data();

    return debug;
}

RpcError::RpcErrorData::RpcErrorData()
    : code(RpcError::NoError)
{
}

RpcError::RpcErrorData::RpcErrorData(const RpcErrorData &other)
    : QSharedData(other),
      code(other.code),
      message(other.message),
      data(other.data)
{
}

RpcError::RpcErrorData::~RpcErrorData()
{
}

} //strata::strataRPC
