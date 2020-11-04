#include "Client.h"

Client::Client(QByteArray clientId, QString APIVersion) : clientId_(clientId), APIVersion_(APIVersion) {
}

Client::~Client() {
}

QByteArray Client::getClientID() const {
    return clientId_;
}

QString Client::getApiVersion() const{
    return APIVersion_;
}
