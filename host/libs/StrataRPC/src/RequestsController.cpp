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
                                                             const QJsonObject &payload)
{
    ++currentRequestId_;

    const auto it = requestsList_.find(currentRequestId_);
    if (it != requestsList_.end()) {
        qCCritical(logCategoryRequestsController) << "Duplicate request id.";
        return {0, ""};
    }

    qCDebug(logCategoryRequestsController)
        << "Building request. id:" << currentRequestId_ << "method:" << method;

    const auto request =
        requestsList_.insert(currentRequestId_, Request(method, payload, currentRequestId_));

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

QString RequestsController::getMethodName(int id)
{
    auto it = requestsList_.find(id);
    if (it == requestsList_.end()) {
        qCDebug(logCategoryRequestsController) << "Request id not found.";
        return "";
    }
    qCDebug(logCategoryRequestsController)
        << "request id" << it->messageId << "method" << it->method;
    return it->method;
}
