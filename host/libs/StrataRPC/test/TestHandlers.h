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
