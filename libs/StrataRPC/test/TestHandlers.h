/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "StrataRPC/RpcRequest.h"

using strata::strataRPC::RpcRequest;

class TestHandlers
{
public:


    TestHandlers()
    {
    }
    ~TestHandlers()
    {
    }
    void handler_1(const RpcRequest &request);
    void handler_2(const RpcRequest &request);
    void handler_3(const RpcRequest &request);
    void handler_4(const RpcRequest &request);

private:
    void printClientMessage(const RpcRequest &request);


};
