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

void TestHandlers::handler_1(const RpcRequest &request)
{
    printClientMessage(request);
    for (size_t i = 0; i < 1000000000; i++) {
        // do work!
    }
}

void TestHandlers::handler_2(const RpcRequest &request)
{
    printClientMessage(request);
}

void TestHandlers::handler_3(const RpcRequest &request)
{
    printClientMessage(request);
}

void TestHandlers::handler_4(const RpcRequest &request)
{
    printClientMessage(request);
}

void TestHandlers::printClientMessage(const RpcRequest &request)
{
    qDebug().nospace().noquote() << "client id: 0x" << request.clientId().toHex();
    qDebug() << "method name:" << request.method();
    qDebug() << "message id:" << request.id();
}
