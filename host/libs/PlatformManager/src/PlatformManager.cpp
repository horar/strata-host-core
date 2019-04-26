
#include "PlatformManager.h"
#include "PlatformConnection.h"
#include "WinCommEvent.h"

#include <EvEvent.h>

#include <serial_port.h>

#include <string>
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <assert.h>

namespace spyglass {

static const int g_portsRefreshTime = 500;  //in ms

////////////////////////////////////////////////////////////////////////////////////////////

PlatformManager::PlatformManager()
{
}

PlatformManager::~PlatformManager()
{
}

bool PlatformManager::Init()
{
#if defined(__linux__) || defined(__APPLE__)

    ports_update_.reset( new EvEvent());
    ports_update_->create(EvEvent::EvType::eEvTypeTimer, -1, g_portsRefreshTime);
    ports_update_->setCallback(std::bind(&PlatformManager::onUpdatePortList, this, std::placeholders::_1, std::placeholders::_2) );
    eventsMgr_.registerEvent(ports_update_.get());

    if (!ports_update_->activate(0)) {
        ports_update_.release();
        return false;
    }
#elif defined(_WIN32)

    ports_update_.reset(new WinTimerEvent());
    ports_update_->create(g_portsRefreshTime);
    ports_update_->setCallback(std::bind(&PlatformManager::onUpdatePortList, this, std::placeholders::_1, std::placeholders::_2));

    portsUpdateThread_.registerEvent(ports_update_.get());
    ports_update_->activate(0);
#endif

    return true;
}

bool PlatformManager::StartLoop()
{
    if (eventsMgr_.startInThread() == false) {
        return false;
    }

#if defined(_WIN32)
    if (portsUpdateThread_.startInThread() == false) {
        eventsMgr_.stop();
        return false;
    }
#endif

    return true;
}

void PlatformManager::Stop()
{
#if defined(_WIN32)
    portsUpdateThread_.stop();
#endif

    eventsMgr_.stop();
}

void PlatformManager::setPlatformHandler(PlatformConnHandler* handler)
{
    plat_handler_ = handler;
}

PlatformConnection* PlatformManager::getConnection(const std::string& connection_id)
{
    serialPortHash hash = std::hash<std::string>{}(connection_id);
    PlatformConnection* conn;
    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        auto find = openedPorts_.find(hash);
        if (find == openedPorts_.end()) {
            return nullptr;
        }
        conn = find->second;
    }

    return conn;
}

void PlatformManager::onUpdatePortList(EvEventBase*, int)
{
    static int idx = 0;

    std::cout << "onUpdatePortList:" << idx << std::endl;  idx++;

    std::vector<std::string> listOfSerialPorts;
    if (getListOfSerialPorts(listOfSerialPorts)) {

        std::vector<serialPortHash> myList;
        myList.reserve( listOfSerialPorts.size() );
        serialPortHash hash;
        for(const std::string& portName : listOfSerialPorts) {
            hash = std::hash<std::string>{}(portName);

            hashToName_.insert( { hash, portName } );
            myList.push_back(hash);
        }

        std::vector<serialPortHash> added, removed;
        added.reserve( listOfSerialPorts.size() );
        removed.reserve( listOfSerialPorts.size() );
        computeListDiff(myList, added, removed);

        //removed ports
        for(auto hash : removed) {
            onRemovedPort(hash);
        }

        //new ports added...
        for(auto hash : added) {
            onAddedPort(hash);
        }

        portsList_ = myList;
    }
}

void PlatformManager::computeListDiff(const std::vector<serialPortHash>& list,
                                      std::vector<serialPortHash>& added_ports,
                                      std::vector<serialPortHash>& removed_ports)
{
    std::vector<serialPortHash> curr(list);
    std::vector<serialPortHash> last(portsList_);

    std::sort(curr.begin(), curr.end());
    std::sort(last.begin(), last.end());

    //create differences of the lists.. what is added / removed
    std::set_difference(curr.begin(), curr.end(),
                        last.begin(), last.end(),
                        std::inserter(added_ports, added_ports.begin()));

    std::set_difference(last.begin(), last.end(),
                        curr.begin(), curr.end(),
                        std::inserter(removed_ports, removed_ports.begin()));
}

std::string PlatformManager::hashToPortName(serialPortHash hash)
{
    std::lock_guard<std::mutex> lock(connectionMap_mutex_);
    auto it = hashToName_.find(hash);
    if (it != hashToName_.end()) {
        return it->second;
    }

    return std::string();
}

void PlatformManager::onRemovedPort(serialPortHash hash)
{
    std::string portName  = hashToPortName(hash);
//TODO: add this to logging    std::cout << "Removed ser.port:" << portName << std::endl;

    PlatformConnection* conn;
    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        auto find = openedPorts_.find(hash);
        if (find == openedPorts_.end()) {
            return;
        }
        conn = find->second;
    }

    std::cout << "Disconnect" << std::endl;

    EvEventBase* ev = conn->getEvent();
    ev->deactivate();
    eventsMgr_.unregisterEvent(ev);

    if (plat_handler_) {
        plat_handler_->onCloseConnection(conn);
    }

    conn->close();

    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        openedPorts_.erase(hash);
    }

    delete conn;
}

void PlatformManager::removeConnection(PlatformConnection* /*conn*/)
{
    //TODO: remove connection

    std::cout << "Disconnect" << std::endl;


}

void PlatformManager::onAddedPort(serialPortHash hash)
{
    std::cout << "onAddedPort()" << std::endl;

    std::string portName  = hashToPortName(hash);
//TODO: add this to logging     std::cout << "New ser.port:" << portName << std::endl;

    PlatformConnection* conn = new PlatformConnection(this);
    if (conn->open(portName) == false) {
        delete conn;
        return;
    }

    spyglass::EvEventBase* ev = conn->getEvent();
    eventsMgr_.registerEvent(ev);

    //activate event in dispatcher (for read)
    if (ev->activate(spyglass::EvEvent::eEvStateRead) == false) {
        //TODO: error logging...
        eventsMgr_.unregisterEvent(ev);

        delete conn;
        return;
    }

    std::cout << "New connection" << std::endl;

    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        openedPorts_.insert({hash, conn});
    }

    if (plat_handler_) {
        plat_handler_->onNewConnection(conn);
    }
}

void PlatformManager::notifyConnectionReadable(PlatformConnection* conn)
{
#if !defined(NDEBUG)      //Debuging stuff
    bool found = false;
    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        for(auto it = openedPorts_.begin(); it != openedPorts_.end(); ++it) {
            if (it->second == conn) {
                found = true;
                break;
            }
        }
    }
    assert(found);
#endif

    if (plat_handler_) {
        plat_handler_->onNotifyReadConnection(conn);
    }
}

} //end of namespace
