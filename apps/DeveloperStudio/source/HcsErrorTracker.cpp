/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "HcsErrorTracker.h"

#include <PlatformInterface/core/CoreInterface.h>
#include <StrataRPC/StrataClient.h>
#include <StrataRPC/RpcError.h>

#include "NotificationModel.h"

#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonArray>

HcsErrorTracker::HcsErrorTracker(
        strata::strataRPC::StrataClient *strataClient,
        CoreInterface *coreInterface,
        NotificationModel *notificationModel,
        QObject *parent)
    : QObject(parent),
      strataClient_(strataClient),
      coreInterface_(coreInterface),
      notificationModel_(notificationModel)
{
    connect(coreInterface_, &CoreInterface::hcsStatus, this, &HcsErrorTracker::handleHcsStatus);
}

HcsErrorTracker::~HcsErrorTracker()
{
}

bool HcsErrorTracker::checkHcsStatus() const
{
    strata::strataRPC::DeferredReply *reply = strataClient_->sendRequest("hcs_status", {});

    if (reply == nullptr) {
        qCCritical(lcDevStudio) << "Failed to send HCS status request";
        return false;
    }

    connect(reply, &strata::strataRPC::DeferredReply::finishedSuccessfully, this, &HcsErrorTracker::handleHcsStatus);
    connect(reply, &strata::strataRPC::DeferredReply::finishedWithError, this, &HcsErrorTracker::handleReplyError);

    return true;
}

void HcsErrorTracker::clearErrors()
{
    errorCodes_.clear();
}

void HcsErrorTracker::handleHcsStatus(QJsonObject payload)
{
    using strata::strataRPC::RpcErrorCode;

    QSet<RpcErrorCode> currentErrorCodes;

    const QJsonArray errorCodeList = payload["error_code_list"].toArray();
    for (const QJsonValue &errorCode : errorCodeList) {
        RpcErrorCode rpcErrorCode = static_cast<RpcErrorCode>(errorCode.toInt());
        if (rpcErrorCode != RpcErrorCode::NoError) {
            currentErrorCodes.insert(rpcErrorCode);
        }
    }

    QSet<RpcErrorCode> newErrorCodes = currentErrorCodes - errorCodes_;

    if (newErrorCodes.size() > 0) {
        for (const RpcErrorCode errorCode : newErrorCodes) {
            Notification::Request data;
            data.level = Notification::Warning;
            data.title = QStringLiteral("Host Controller Service issue found");
            data.description = strata::strataRPC::RpcError::defaultMessage(errorCode);
            if (data.description.size() > 0) {
                data.description[0] = data.description.at(0).toUpper();
            }
            data.removeAutomatically = false;

            qCWarning(lcDevStudio).nospace().noquote() << "HCS issue found: "
                << static_cast<int>(errorCode) << " - " << data.description;

            notificationModel_->create(data);
        }
    } else {
        qCInfo(lcDevStudio) << "HCS status: everything ok";
    }

    errorCodes_ = currentErrorCodes;
}

void HcsErrorTracker::handleReplyError(QJsonObject payload)
{
    qCWarning(lcDevStudio) << "Request for HCS status failed:" << payload["message"].toString();
}

