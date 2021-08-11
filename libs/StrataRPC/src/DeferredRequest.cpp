#include <StrataRPC/DeferredRequest.h>

using namespace strata::strataRPC;

DeferredRequest::DeferredRequest(const int &id, QObject *parent) : QObject(parent), id_(id)
{
}

DeferredRequest::~DeferredRequest()
{
}

int DeferredRequest::getId() const
{
    return id_;
}

void DeferredRequest::callSuccessCallback(const QJsonObject &jsonPayload)
{
    emit finishedSuccessfully(jsonPayload);
}

void DeferredRequest::callErrorCallback(const QJsonObject &jsonPayload)
{
    emit finishedWithError(jsonPayload);
}
