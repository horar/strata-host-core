#include <QDebug>

#include "TestHandlers.h"

void TestHandlers::handler_1(const Message &message)
{
    printClientMessage(message);
    for (size_t i = 0; i < 1000000000; i++) {
        // do work!
    }
    qDebug() << "handler_1";
}

void TestHandlers::handler_2(const Message &message)
{
    printClientMessage(message);
    qDebug() << "handler_2";
}

void TestHandlers::handler_3(const Message &message)
{
    printClientMessage(message);
    qDebug() << "handler_3";
}

void TestHandlers::handler_4(const Message &message)
{
    printClientMessage(message);
    qDebug() << "handler_4";
}

void TestHandlers::printClientMessage(const Message &message)
{
    qDebug() << "client id: " << message.clientID.toHex();
    qDebug() << "handler name: " << message.handlerName;
    qDebug() << "message id: " << message.messageID;
}
