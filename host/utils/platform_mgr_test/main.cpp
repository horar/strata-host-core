//
// Created by Milan Franc on 2019-02-12.
//

#include <PlatformManager.h>
#include <PlatformConnection.h>
#include <SerialPort.h>

#include <string>
#include <vector>


int main(int argc, char* argv[])
{
    PlatformManager* mgr = new PlatformManager;


    mgr->Init();

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

    for(;;) {
        ev_mgr.dispatch();

        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }





    return 0;
}


