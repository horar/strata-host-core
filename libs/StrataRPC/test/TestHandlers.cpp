#include <QDebug>

#include "TestHandlers.h"

void TestHandlers::handler_1(const Message &message)
{
    printClientMessage(message);
    for (size_t i = 0; i < 1000000000; i++) {
        // do work!
    }
}

void TestHandlers::handler_2(const Message &message)
{
    printClientMessage(message);
}

void TestHandlers::handler_3(const Message &message)
{
    printClientMessage(message);
}

void TestHandlers::handler_4(const Message &message)
{
    printClientMessage(message);
}

void TestHandlers::printClientMessage(const Message &message)
{
    qDebug().nospace().noquote() << "client id: 0x" << message.clientID.toHex();
    qDebug() << "handler name:" << message.handlerName;
    qDebug() << "message id:" << message.messageID;
}
