#include "Client.h"

using namespace strata::strataRPC;

Client::Client(QByteArray clientId, ApiVersion APIVersion)
    : clientId_(clientId), APIVersion_(APIVersion)
{
}

Client::~Client()
{
}

QByteArray Client::getClientID() const
{
    return clientId_;
}

ApiVersion Client::getApiVersion() const
{
    return APIVersion_;
}

void Client::UpdateClientApiVersion(const ApiVersion &newAPIVersion)
{
    APIVersion_ = newAPIVersion;
}
