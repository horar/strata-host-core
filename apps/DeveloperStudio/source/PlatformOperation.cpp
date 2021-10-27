/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "PlatformOperation.h"

#include <QString>
#include <QJsonObject>

#include <StrataRPC/StrataClient.h>

#include "logging/LoggingQtCategories.h"

PlatformOperation::PlatformOperation(strata::strataRPC::StrataClient *strataClient, QObject *parent)
    : QObject(parent), strataClient_(strataClient)
{ }

PlatformOperation::~PlatformOperation()
{ }

bool PlatformOperation::platformStartApplication(QString deviceId)
{
    const QString command("platform_start_application");
    const QJsonObject payload {
        { "device_id", deviceId }
    };

    strata::strataRPC::DeferredRequest *deferredRequest = strataClient_->sendRequest(command, payload);

    if (deferredRequest == nullptr) {
        qCCritical(lcDevStudio).noquote().nospace() << "Failed to send '" << command << "' request, device ID: " << deviceId;
        return false;
    }

    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedSuccessfully, this, &PlatformOperation::replyHandler);
    connect(deferredRequest, &strata::strataRPC::DeferredRequest::finishedWithError, this, &PlatformOperation::replyHandler);

    return true;
}

void PlatformOperation::replyHandler(QJsonObject payload)
{
    const QString errorString = payload.value(QStringLiteral("error_string")).toString();
    if (errorString.isEmpty() == false) {
        qCWarning(lcDevStudio).noquote() << "Platform operation has failed:" << errorString;
    }
}
