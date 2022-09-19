/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "StrataRPC/RpcError.h"
#include <QJsonDocument>

namespace strata::strataRPC
{

RpcError::RpcError(RpcErrorCode code)
    : sharedDataPtr_(new RpcErrorData)
{
    setCode(code);
}

RpcError::RpcError(RpcErrorCode code, QString message)
    : sharedDataPtr_(new RpcErrorData)
{
    setCode(code);
    setMessage(message);
}

RpcError::RpcError(
        RpcErrorCode code,
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

RpcErrorCode RpcError::code() const
{
    return sharedDataPtr_->code;
}

void RpcError::setCode(const RpcErrorCode &code)
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

QJsonObject RpcError::toJsonObject() const
{
    QJsonObject errorObject;
    errorObject.insert("code", code());
    errorObject.insert("message", message());

    if (data().isEmpty() == false) {
        errorObject.insert("data", data());
    }

    return errorObject;
}

QString RpcError::defaultMessage(RpcErrorCode code)
{
    switch(code) {
    case NoError: return "";
    case ServerInitialializationError: return "server initialization error";
    case HandlerRegistrationError: return "handler registration error";
    case HandlerUnregistrationError: return "handler unregistration error";
    case ConnectionError: return "connection error";
    case DisconnectionError: return "disconnection error";
    case TransportError: return "transport error";
    case ReplyTimeoutError: return "reply timeout error";
    case SystemError: return "system error";
    case ApplicationError: return "appliacation error";
    case InvalidRequestError: return "invalid request";
    case MethodNotFoundError: return "method not found";
    case InvalidParamsError: return "invalid parameter(s)";
    case InternalError: return "internal json-rpc error";
    case ParseError: return "parse error";
    case ProcedureExecutionError: return "procedure execution error";
    case ClientRegistrationError: return "client registration error";
    case UnknownApiVersionError: return "unknown api version";
    case ClientAlreadyRegisteredError: return "client already registered";
    case ClientUnregistrationError: return "client unregistration error";
    case ClientNotRegistered: return "client not registered error";
    default:
        return "error message for this error not available";
    }
}

QDebug operator<<(QDebug debug, const RpcError &error)
{
    debug.noquote().nospace()
            << error.code()
            << ' '
            << error.message()
            << ", data: '"
            << QJsonDocument(error.data()).toJson(QJsonDocument::Compact)
            << '\'';

    return debug;
}

RpcError::RpcErrorData::RpcErrorData()
    : code(RpcErrorCode::NoError)
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
