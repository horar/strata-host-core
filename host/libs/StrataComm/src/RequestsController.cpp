#include "RequestsController.h"
#include "logging/LoggingQtCategories.h"

using namespace strata::strataComm;

RequestsController::RequestsController()
{
    currentRequestId_ = 0;
}

RequestsController::~RequestsController()
{
}

void RequestsController::addNewRequest(const QString &method, const QJsonObject &payload)
{
    ++currentRequestId_;

    const auto it = requestsList_.find(currentRequestId_);
    if (it != requestsList_.end()) {
        qCCritical(logCategoryRequestsController) << "Dublicate request id.";
        return;
    }

    qCDebug(logCategoryRequestsController)
        << "Building request. id:" << currentRequestId_ << "method:" << method;

    const auto request =
        requestsList_.insert(currentRequestId_, Request(method, payload, currentRequestId_));

    emit sendRequest(request.value().toJson());
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
