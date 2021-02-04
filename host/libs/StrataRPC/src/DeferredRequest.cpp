#include <StrataRPC/DeferredRequest.h>
#include <QDebug>
#include <QMetaMethod>
using namespace strata::strataRPC;

DeferredRequest::DeferredRequest(double id, QObject *parent) : QObject(parent), id_(id)
{
}

DeferredRequest::~DeferredRequest()
{
}

double DeferredRequest::getId() const
{
    return id_;
}

bool DeferredRequest::hasSuccessCallback()
{
    return isSignalConnected(QMetaMethod::fromSignal(&DeferredRequest::finishedSuccessfully));
}

bool DeferredRequest::hasErrorCallback()
{
    return isSignalConnected(QMetaMethod::fromSignal(&DeferredRequest::finishedWithError));
}

void DeferredRequest::callSuccessCallback(const Message &message)
{
    emit finishedSuccessfully(message);
}

void DeferredRequest::callErrorCallback(const Message &message)
{
    emit finishedWithError(message);
}