#include "Client.h"
#include <QDebug>

using namespace strata::strataRPC;

Client::Client(QObject *parent) : QObject(parent), strataClient_(new StrataClient(address_))
{
}

Client::~Client()
{
}

bool Client::init() 
{
    qDebug() << "init client";
    strataClient_->connectServer();
    return true;
}

void Client::start() 
{
    qDebug() << "start client";
}
