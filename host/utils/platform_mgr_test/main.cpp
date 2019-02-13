//
// Created by Milan Franc on 2019-02-12.
//

#include <PlatformManager.h>
#include <PlatformConnection.h>
#include <serial_port.h>

#include <string>
#include <vector>
#include <iostream>

class MyHandler : public PlatformConnHandler
{
public:
    virtual void onNewConnection(PlatformConnection* connection)
    {
        connection->addMessage("{\"cmd\":\"request_platform_id\",\"payload\":{} }");

    }
    virtual void onCloseConnection(PlatformConnection* connection)
    {

    }

    virtual void onNotifyReadConnection(PlatformConnection* connection)
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
    PlatformManager* mgr = new PlatformManager;
    MyHandler handler;

    mgr->Init();
    mgr->setPlatformHandler(&handler);

    mgr->StartLoop();

    bool loop = true;
    while(loop) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    mgr->Stop();



#if 0
    std::vector<std::string> listOfPorts;
    getListOfSerialPorts(listOfPorts);

    if (listOfPorts.empty())
        return 1;

    EvEventsMgr ev_mgr;

    PlatformConnection* conn = new PlatformConnection(mgr);
    bool ret = conn->open(listOfPorts.front());
    if (ret) {
        conn->attachEventMgr(&ev_mgr);

    }


    conn->addMessage("{\"cmd\":\"request_platform_id\",\"payload\":{} }");


#endif



    return 0;
}


