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
#include <QJsonObject>
#include <QSet>

namespace strata::strataRPC {
    class StrataClient;
    enum RpcErrorCode : int;
}

class CoreInterface;
class NotificationModel;

class HcsErrorTracker: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(HcsErrorTracker)

public:
    HcsErrorTracker(strata::strataRPC::StrataClient *strataClient,
                    CoreInterface *coreInterface,
                    NotificationModel *notificationModel,
                    QObject *parent = nullptr);
    ~HcsErrorTracker();

    Q_INVOKABLE bool checkHcsStatus() const;

private slots:
    void handleHcsStatus(QJsonObject payload);
    void handleReplyError(QJsonObject payload);

private:
    strata::strataRPC::StrataClient *strataClient_;
    CoreInterface *coreInterface_;
    NotificationModel *notificationModel_;

    QSet<strata::strataRPC::RpcErrorCode> errorCodes_;
};
