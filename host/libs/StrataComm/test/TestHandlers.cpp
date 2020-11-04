#include "TestHandlers.h"
#include <iostream>

void TestHandlers::handler_1(const ClientMessage &clientMessage) {
    printClientMessage(clientMessage);
    for(size_t i = 0; i < 1000000000; i++) {
        // do work!
    }
    std::cout << "handler_1" << std::endl;
}

void TestHandlers::handler_2(const ClientMessage &clientMessage) {
    printClientMessage(clientMessage);
    std::cout << "handler_2" << std::endl;
}

void TestHandlers::handler_3(const ClientMessage &clientMessage) {
    printClientMessage(clientMessage);
    std::cout << "handler_3" << std::endl;
}

void TestHandlers::handler_4(const ClientMessage &clientMessage) {
    printClientMessage(clientMessage);
    std::cout << "handler_4" << std::endl;
}

void TestHandlers::printClientMessage(const ClientMessage &cm) {
    std::cout << "client id: " << cm.clientID.toHex().toStdString() << std::endl;
    std::cout << "handler name: " << cm.handlerName.toStdString() << std::endl;
    std::cout << "message id: " << cm.messageID << std::endl;
}
