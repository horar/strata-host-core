#include <StrataRPC/PendingRequest.h>
#include <QDebug>
#include <QMetaMethod>
using namespace strata::strataRPC;

PendingRequest::PendingRequest(double id, QObject *parent) : QObject(parent), id_(id)
{
}

PendingRequest::~PendingRequest()
{
}

double PendingRequest::getId() const
{
    return id_;
}

bool PendingRequest::hasSuccessCallback()
{
    return isSignalConnected(QMetaMethod::fromSignal(&PendingRequest::finishedSuccessfully));
}

bool PendingRequest::hasErrorCallback()
{
    return isSignalConnected(QMetaMethod::fromSignal(&PendingRequest::finishedWithError));
}

void PendingRequest::callSuccessCallback(const Message &message)
{
    emit finishedSuccessfully(message);
}

void PendingRequest::callErrorCallback(const Message &message)
{
    emit finishedWithError(message);
}