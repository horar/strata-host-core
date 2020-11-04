#pragma once
#include "../src/ClientMessage.h"

class TestHandlers {
public:
    TestHandlers() {}
    ~TestHandlers() {}
    void handler_1(const ClientMessage &clientMessage);
    void handler_2(const ClientMessage &clientMessage);
    void handler_3(const ClientMessage &clientMessage);
    void handler_4(const ClientMessage &clientMessage);

private:

    void printClientMessage(const ClientMessage &cm);
};
