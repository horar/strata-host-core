#pragma once
#include "../src/Message.h"

using strata::strataComm::Message;

class TestHandlers {
public:
    TestHandlers() {}
    ~TestHandlers() {}
    void handler_1(const Message &clientMessage);
    void handler_2(const Message &clientMessage);
    void handler_3(const Message &clientMessage);
    void handler_4(const Message &clientMessage);

private:

    void printClientMessage(const Message &cm);
};
