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

class RpcError {
public:
    enum ErrorCode {
        NoError = 0,

        /* JSON-RPC pre-defined error codes, from -32000 to -32768 */
        FailedToInitializeServer = -32000,
        FailedToRegisterHandler = -32001,
        FailedToUnregisterHandler = 32002,

        TransportError = -32300,
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
        };

    RpcError(ErrorCode code=ErrorCode::NoError);

    RpcError(ErrorCode code, QString message);

    RpcError(
            ErrorCode code,
            QString message,
            QJsonObject data);

    RpcError(const RpcError &other);

    ErrorCode code() const;
    void setCode(const ErrorCode &code);

    QString message() const;
    void setMessage(const QString &message);

    QJsonObject data() const;
    void setData(const QJsonObject &data);

    static QString defaultMessage(ErrorCode code);

    friend QDebug operator<<(QDebug debug, const RpcError &error);

private:

    class RpcErrorData: public QSharedData
    {
    public:
        RpcErrorData();
        RpcErrorData(const RpcErrorData &other);
        ~RpcErrorData();

        RpcError::ErrorCode code;
        QString message;
        QJsonObject data;
    };

    QSharedDataPointer<RpcErrorData> sharedDataPtr_;
};

} //strata::strataRPC
