#include "RequestsController.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataRPC;

RequestsController::RequestsController()
{
    currentRequestId_ = 0;
}

RequestsController::~RequestsController()
{
}

std::pair<int, QByteArray> RequestsController::addNewRequest(const QString &method,
                                                             const QJsonObject &payload,
                                                             StrataHandler errorCallback,
                                                             StrataHandler resultCallback)
{
    ++currentRequestId_;

    const auto it = requestsList_.find(currentRequestId_);
    if (it != requestsList_.end()) {
        qCCritical(logCategoryRequestsController) << "Duplicate request id.";
        return {0, ""};
    }

    qCDebug(logCategoryRequestsController)
        << "Building request. id:" << currentRequestId_ << "method:" << method;

    const auto request = requestsList_.insert(
        currentRequestId_, Request(method, payload, currentRequestId_, 
                                   std::make_shared<PendingRequest>(currentRequestId_),
                                   errorCallback, resultCallback));

    return {currentRequestId_, request.value().toJson()};
}

bool RequestsController::isPendingRequest(int id)
{
    return requestsList_.contains(id);
}

bool RequestsController::removePendingRequest(int id)
{
    qCDebug(logCategoryRequestsController) << "Removing pending request id:" << id;
    auto it = requestsList_.find(id);
    if (it == requestsList_.end()) {
        qCDebug(logCategoryRequestsController) << "Request id not found.";
        return false;
    }
    return requestsList_.remove(id) > 0;
}

std::pair<bool, Request> RequestsController::popPendingRequest(int id)
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

QString RequestsController::getMethodName(int id)
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
