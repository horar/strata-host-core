#include <QDebug>

#include "TestHandlers.h"

void TestHandlers::handler_1(const Message &clientMessage)
{
    printClientMessage(clientMessage);
    for (size_t i = 0; i < 1000000000; i++) {
        // do work!
    }
    qDebug() << "handler_1";
}

void TestHandlers::handler_2(const Message &clientMessage)
{
    printClientMessage(clientMessage);
    qDebug() << "handler_2";
}

void TestHandlers::handler_3(const Message &clientMessage)
{
    printClientMessage(clientMessage);
    qDebug() << "handler_3";
}

void TestHandlers::handler_4(const Message &clientMessage)
{
    printClientMessage(clientMessage);
    qDebug() << "handler_4";
}

void TestHandlers::printClientMessage(const Message &cm)
{
    qDebug() << "client id: " << cm.clientID.toHex();
    qDebug() << "handler name: " << cm.handlerName;
    qDebug() << "message id: " << cm.messageID;
}
