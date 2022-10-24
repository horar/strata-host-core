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
#include <QDebug>

namespace strata::strataRPC
{
Q_NAMESPACE

enum RpcErrorCode : int {
    NoError = 0,

    /* JSON-RPC pre-defined error codes, from -32000 to -32768 */
    ServerInitialializationError = -32000,
    HandlerRegistrationError = -32001,
    HandlerUnregistrationError = -32002,
    ConnectionError = -32003,
    DisconnectionError = -32004,

    TransportError = -32300,
    ReplyTimeoutError = -32301,
    SystemError = -32400,
    ApplicationError = -32500,
    InvalidRequestError = -32600,
    MethodNotFoundError = -32601,
    InvalidParamsError = -32602,
    InternalError = -32603,
    ParseError = -32700,

    /* Application specific errors, from 1 */
    ProcedureExecutionError = 1,
    ClientRegistrationError,
    UnknownApiVersionError,
    ClientAlreadyRegisteredError,
    ClientUnregistrationError,
    ClientNotRegistered,
    ReplicatorRunError,
    ReplicatorStopped,
    ReplicatorOffline,
    ReplicatorWebSocketFailed,
    ReplicatorWrongCredentials,
    ReplicatorNoSuchDb,
    FileServerNotAccessible,
    };
Q_ENUM_NS(RpcErrorCode)

class RpcError {
public:
    RpcError(RpcErrorCode code=RpcErrorCode::NoError);

    RpcError(RpcErrorCode code, QString message);

    RpcError(
            RpcErrorCode code,
            QString message,
            QJsonObject data);

    RpcError(const RpcError &other);

    RpcErrorCode code() const;
    void setCode(const RpcErrorCode &code);

    QString message() const;
    void setMessage(const QString &message);

    QJsonObject data() const;
    void setData(const QJsonObject &data);

    QJsonObject toJsonObject() const;

    static QString defaultMessage(RpcErrorCode code);

    friend QDebug operator<<(QDebug debug, const RpcError &error);

private:

    class RpcErrorData: public QSharedData
    {
    public:
        RpcErrorData();
        RpcErrorData(const RpcErrorData &other);
        ~RpcErrorData();

        RpcErrorCode code;
        QString message;
        QJsonObject data;
    };

    QSharedDataPointer<RpcErrorData> sharedDataPtr_;
};

} //strata::strataRPC
