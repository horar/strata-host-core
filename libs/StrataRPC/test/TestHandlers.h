/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once
#include <StrataRPC/Message.h>

using strata::strataRPC::Message;

class TestHandlers
{
public:
    TestHandlers()
    {
    }
    ~TestHandlers()
    {
    }
    void handler_1(const Message &message);
    void handler_2(const Message &message);
    void handler_3(const Message &message);
    void handler_4(const Message &message);

private:
    void printClientMessage(const Message &message);
};
