#include "RequestsController.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

RequestsController::RequestsController() : requestsTimer_(this)
{
    currentRequestId_ = 0;
    requestsTimer_.setInterval(CHECK_REQUESTS_INTERVAL);
    connect(&requestsTimer_, &QTimer::timeout, this, &RequestsController::findTimedoutRequests);

    requestsTimer_.start();  // It might be more beneficial to add a init function instead of
                             // polling all the time!
}

RequestsController::~RequestsController()
{
}

std::pair<DeferredRequest *, QByteArray> RequestsController::addNewRequest(
    const QString &method, const QJsonObject &payload)
{
    ++currentRequestId_;

    const auto it = requestsList_.find(currentRequestId_);
    if (it != requestsList_.end()) {
        qCCritical(logCategoryRequestsController) << "Duplicate request id.";
        return {0, ""};
    }

    qCDebug(logCategoryRequestsController)
        << "Building request. id:" << currentRequestId_ << "method:" << method;

    DeferredRequest *deferredRequest = new DeferredRequest(currentRequestId_, this);
    const auto request = requestsList_.insert(
        currentRequestId_, Request(method, payload, currentRequestId_, deferredRequest));

    return {deferredRequest, request.value().toJson()};
}

bool RequestsController::isPendingRequest(const int &id)
{
    return requestsList_.contains(id);
}

bool RequestsController::removePendingRequest(const int &id)
{
    qCDebug(logCategoryRequestsController) << "Removing pending request id:" << id;
    auto it = requestsList_.find(id);
    if (it == requestsList_.end()) {
        qCDebug(logCategoryRequestsController) << "Request id not found.";
        return false;
    }
    return requestsList_.remove(id) > 0;
}

std::pair<bool, Request> RequestsController::popPendingRequest(const int &id)
{
    qCDebug(logCategoryRequestsController) << "Popping pending request id:" << id;
    auto it = requestsList_.find(id);
    if (it == requestsList_.end()) {
        qDebug(logCategoryRequestsController) << "Request id not found.";
        return {false, Request("", QJsonObject({{}}), 0, nullptr)};
    }
    Request request(it.value());
    return {requestsList_.remove(id) > 0, request};
}

QString RequestsController::getMethodName(const int &id)
{
    auto it = requestsList_.find(id);
    if (it == requestsList_.end()) {
        qCDebug(logCategoryRequestsController) << "Request id not found.";
        return "";
    }
    qCDebug(logCategoryRequestsController)
        << "request id" << it->messageId_ << "method" << it->method_;
    return it->method_;
}

void RequestsController::findTimedoutRequests()
{
    qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
    for (const auto &request : requestsList_) {
        if ((currentTime - request.timestamp_) < REQUEST_TIMOUT) {
            return;
        }
        emit requestTimedout(request.messageId_);
    }
}
