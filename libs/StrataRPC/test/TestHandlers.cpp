/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QDebug>

#include "TestHandlers.h"

#ifdef false

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

#endif
