/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "Request.h"

#include <QMap>
#include <QObject>
#include <QTimer>
#include <chrono>

namespace strata::strataRPC
{
class RequestsController : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(RequestsController);

public:
    /**
     * RequestController constructor
     */
    RequestsController(std::chrono::milliseconds check_timeout_interval,
                       std::chrono::milliseconds request_timeout);

    /**
     * RequestController destructor
     */
    ~RequestsController();

    /**
     * Adds a new request with callbacks to handle it's response.
     * @param [in] method request handler name.
     * @param [in] payload QJsonObject of the request payload.
     * @return std::pair of pointer to deferredRequest and QByteArray of json formatted
     * request.
     */
    [[nodiscard]] std::pair<DeferredRequest *, QByteArray> addNewRequest(
        const QString &method, const QJsonObject &payload);

    /**
     * Checks if there is a pending request with a specific id
     * @param [in] id pending request id.
     * @return True if there is a pending request with the same id.
     */
    bool isPendingRequest(const int &id);

    /**
     * Removes a pending id
     * @param [in] id pending request id.
     * @return True if the pending request was removed successfully, False if there is no pending
     * requests with the same id
     */
    bool removePendingRequest(const int &id);

    /**
     * Pops a pending request.
     * @param [in] id pending request id.
     * @return std::pair, boolean of request removal status and a copy of the request object. if the
     * request is not found in the list, the request object will be empty request with id 0.
     */
    [[nodiscard]] std::pair<bool, Request> popPendingRequest(const int &id);

    /**
     * return the handlerName of a pending request using it's id
     * @param [in] id pending request id.
     * @return QString of the handler name. This will return an empty string if there is no pending
     * request with the same id.
     */
    [[nodiscard]] QString getMethodName(const int &id);

signals:
    /**
     * Signal emitted when there are timed out requests.
     * @param [in] id of the timed out request.
     * @note connections to this signal must be Qt::ConnectionType::QueuedConnection, otherwise the
     * requests map will be modified during the search.
     */
    void requestTimedout(const int &id);

private:
    /**
     * Search for timed out requests in requests map.
     * @note requestTimedout() signal will be emitted when timed out request are found.
     */
    void findTimedoutRequests();

    QMap<int, Request> requests_;
    int currentRequestId_;

    QTimer findTimedoutRequestsTimer_;
    std::chrono::milliseconds request_timeout_;
};

}  // namespace strata::strataRPC
