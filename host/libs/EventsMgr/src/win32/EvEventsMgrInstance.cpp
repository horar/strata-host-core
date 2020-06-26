#include "EventsMgr/win32/EvEventsMgrInstance.h"

#include <stdexcept>
#include <WinSock2.h>


namespace strata::events_mgr {

bool EvEventsMgrInstance::wsa_init_done = false;

EvEventsMgrInstance::EvEventsMgrInstance()
{
    if (wsa_init_done == false)
    {
        WSADATA wsaData;
        if (WSAStartup( MAKEWORD(2,0), &wsaData ) != 0) {
            throw std::runtime_error("WSAStartup failed!");
        }

        wsa_init_done = true;
    }
}

EvEventsMgrInstance::~EvEventsMgrInstance()
{
    if (wsa_init_done) {
        WSACleanup();
    }
}

} // namespace
