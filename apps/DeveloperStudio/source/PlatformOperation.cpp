/*
 * Copyright (c) 2018-2022 onsemi.
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

    strata::strataRPC::DeferredReply *reply = strataClient_->sendRequest(command, payload);

    if (reply == nullptr) {
        qCCritical(lcDevStudio).noquote().nospace() << "Failed to send '" << command << "' request, device ID: " << deviceId;
        return false;
    }

    connect(reply, &strata::strataRPC::DeferredReply::finishedSuccessfully, this, &PlatformOperation::replyHandler);
    connect(reply, &strata::strataRPC::DeferredReply::finishedWithError, this, &PlatformOperation::errorHandler);

    return true;
}

void PlatformOperation::replyHandler(QJsonObject payload)
{
    Q_UNUSED(payload);
    qCDebug(lcDevStudio) << "Platform operation finished successfully";
}

void PlatformOperation::errorHandler(QJsonObject payload)
{
    qCWarning(lcDevStudio).noquote()
            << "Platform operation has failed."
            << payload.value("code").toInt()
            << payload.value("message").toString();
}
