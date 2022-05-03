/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QString>
#include <QJsonObject>
#include <QDebug>

namespace strata::strataRPC
{

class DeferredReply : public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(DeferredReply);

public:
    DeferredReply(QObject *parent);

    int id() const;
    void setId(int id);

    QString method() const;
    void setMethod(const QString &method);

    QJsonObject params() const;
    void setParams(const QJsonObject &params);

    qint64 timestamp() const;
    void setTimestamp(qint64 timestamp);

    friend QDebug operator<<(QDebug debug, const DeferredReply &reply);
    friend QDebug operator<<(QDebug debug, const DeferredReply *reply);

signals:
    /**
     * Signal Emitted when the server replies with a successful message.
     * @param [in] result QJsonObject of the payload.
     */
    void finishedSuccessfully(QJsonObject result);

    /**
     * Signal Emitted when the server resplies with a error message.
     * @param [in] error QJsonObject of the payload.
     */
    void finishedWithError(QJsonObject error);

private:
    friend class StrataClient;

    /**
     * Emits finishedSuccessfully signal.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void callSuccessCallback(const QJsonObject &result);

    /**
     * Emits finishedWithError signal.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void callErrorCallback(const QJsonObject &error);

    int id_;
    QString method_;
    QJsonObject params_;
    qint64 timestamp_;
};

} //strata::strataRPC
