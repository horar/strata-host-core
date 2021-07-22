#include <StrataRPC/DeferredRequest.h>

using namespace strata::strataRPC;

DeferredRequest::DeferredRequest(const int &id, QObject *parent) : QObject(parent), id_(id), timer_(this)
{
    timer_.setSingleShot(true);
    connect(&timer_, &QTimer::timeout, this, &DeferredRequest::requestTimeoutHandler);
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

void DeferredRequest::startTimer()
{
    timer_.start(REQUEST_TIMEOUT);
}

void DeferredRequest::stopTimer()
{
    timer_.stop();
}

void DeferredRequest::requestTimeoutHandler()
{
    emit requestTimedout(id_);
}
