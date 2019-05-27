//
// Created by Milan Franc on 2019-02-12.
//

#include <PlatformManager.h>
#include <PlatformConnection.h>
#include <serial_port.h>

#include <string>
#include <vector>
#include <iostream>

std::map<spyglass::PlatformConnection*, int> g_connectionMap;


class MyHandler : public spyglass::PlatformConnHandler
{
public:
    void onNewConnection(spyglass::PlatformConnectionShPtr connection) override
    {
        connection->addMessage("{\"cmd\":\"request_platform_id\",\"payload\":{} }");

    }
    void onCloseConnection(spyglass::PlatformConnectionShPtr /*connection*/) override
    {

    }

    void onNotifyReadConnection(spyglass::PlatformConnectionShPtr connection) override
    {
        int iCount = g_connectionMap[connection.get()];
        std::string msg;
        while(connection->getMessage(msg)) {
            std::cout << "Msg:" << msg << std::endl;
            iCount++;
        }

        if (iCount == 2) {
            connection->addMessage("{\"cmd\":\"request_platform_id\",\"payload\":{} }");
            iCount = 0;
        }

        g_connectionMap[connection.get()] = iCount;
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
    for(int i=0; i<20; i++) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    mgr->Stop();

    delete mgr;

    return 0;
}


