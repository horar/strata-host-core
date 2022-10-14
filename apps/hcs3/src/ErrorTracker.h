/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <StrataRPC/RpcError.h>


class ErrorTracker: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ErrorTracker)

public:
    ErrorTracker(QObject* parent = nullptr);
    ~ErrorTracker();

    void reportError(strata::strataRPC::RpcErrorCode errorCode);

    void removeError(strata::strataRPC::RpcErrorCode errorCode);

    QList<strata::strataRPC::RpcErrorCode> errors() const;

signals:
    void errorsChanged();

private:
    QSet<strata::strataRPC::RpcErrorCode> errors_;
};
