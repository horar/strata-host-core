#pragma once
#include "Message.h"

using strata::strataComm::Message;

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
