/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "ErrorTracker.h"

ErrorTracker::ErrorTracker(QObject *parent)
    : QObject(parent)
{
}

ErrorTracker::~ErrorTracker()
{
}

void ErrorTracker::reportError(strata::strataRPC::RpcErrorCode errorCode)
{
    if (errors_.contains(errorCode) == false) {
        errors_.insert(errorCode);
        emit errorsChanged();
    }
}

void ErrorTracker::removeError(strata::strataRPC::RpcErrorCode errorCode)
{
    if (errors_.remove(errorCode)) {
        emit errorsChanged();
    }
}

void ErrorTracker::removeErrors(const QList<strata::strataRPC::RpcErrorCode>& errorCodes)
{
    bool removed = false;

    for (const strata::strataRPC::RpcErrorCode errorCode : errorCodes) {
        if (errors_.remove(errorCode)) {
            removed = true;
        }
    }

    if (removed) {
        emit errorsChanged();
    }
}

QList<strata::strataRPC::RpcErrorCode> ErrorTracker::errors() const
{
    return errors_.toList();
}
