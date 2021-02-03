#include <StrataRPC/PendingRequest.h>
#include <QDebug>
#include <QMetaMethod>
using namespace strata::strataRPC;

PendingRequest::PendingRequest(double id, QObject *parent) : id_(id), QObject(parent)
{
}

PendingRequest::~PendingRequest()
{
    qDebug() << "deleted!";
}

double PendingRequest::getId() const
{
    return id_;
}

bool PendingRequest::callSuccessCallback(const Message &message)
{
    if (isSignalConnected(QMetaMethod::fromSignal(&PendingRequest::finishedSuccessfully))) {
        emit finishedSuccessfully(message);
        return true;
    }
    return false;
}

bool PendingRequest::callErrorCallback(const Message &message)
{
    if (isSignalConnected(QMetaMethod::fromSignal(&PendingRequest::finishedWithError))) {
        emit finishedWithError(message);
        return true;
    }
    return false;
}