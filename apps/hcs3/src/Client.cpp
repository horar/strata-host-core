#include "Client.h"

Client::Client(const QByteArray& client_id) : client_id_(client_id)
{
}

Client::~Client()
{
}

QByteArray Client::getClientId() const
{
    return client_id_;
}
