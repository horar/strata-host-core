/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QTimer>

namespace strata::strataRPC
{
class DeferredRequest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DeferredRequest);

public:
    /**
     * DeferredRequest constructor
     * @param [in] id request ID
     */
    DeferredRequest(const int &id, QObject *parent = nullptr);

    /**
     * DeferredRequest Destructor
     */
    ~DeferredRequest();

    /**
     * Accessor to the request ID
     * @return request ID
     */
    int getId() const;

signals:
    /**
     * Signal Emitted when the server respond with a successful message.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void finishedSuccessfully(const QJsonObject &jsonPayload);

    /**
     * Signal Emitted when the server respond with a Error message.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void finishedWithError(const QJsonObject &jsonPayload);

private:
    friend class StrataClient;

    /**
     * Emits finishedSuccessfully signal.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void callSuccessCallback(const QJsonObject &jsonPayload);

    /**
     * Emits finishedWithError signal.
     * @param [in] jsonPayload QJsonObject of the payload.
     */
    void callErrorCallback(const QJsonObject &jsonPayload);

    int id_;
};
}  // namespace strata::strataRPC
