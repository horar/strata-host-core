//
// Created by Milan Franc on 2019-02-12.
//

#include <PlatformManager.h>
#include <PlatformConnection.h>
#include <serial_port.h>

#include <string>
#include <vector>
#include <iostream>

class MyHandler : public spyglass::PlatformConnHandler
{
public:
    virtual void onNewConnection(spyglass::PlatformConnection* connection)
    {
        connection->addMessage("{\"cmd\":\"request_platform_id\",\"payload\":{} }");

    }
    virtual void onCloseConnection(spyglass::PlatformConnection* connection)
    {

    }

    virtual void onNotifyReadConnection(spyglass::PlatformConnection* connection)
    {
        static int iCount = 0;
        std::string msg;
        while(connection->getMessage(msg)) {
            std::cout << "Msg:" << msg << std::endl;
            iCount++;
        }

        if (iCount == 2) {
            connection->addMessage("{\"cmd\":\"request_platform_id\",\"payload\":{} }");
            iCount = 0;
        }
    }
};

int main(int argc, char* argv[])
{
    spyglass::PlatformManager* mgr = new spyglass::PlatformManager;
    MyHandler handler;

    mgr->Init();
    mgr->setPlatformHandler(&handler);

    mgr->StartLoop();

    //make some loops and then exit..
    for(int i=0; i<100; i++) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    mgr->Stop();

    delete mgr;

    return 0;
}


