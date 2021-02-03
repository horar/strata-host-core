#include <StrataRPC/PendingRequest.h>
#include <QDebug>
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

void PendingRequest::callSuccessCallback(const Message &message)
{
    emit finishedSuccessfully(message);
}

void PendingRequest::callErrorCallback(const Message &message)
{
    emit finishedWithError(message);
}