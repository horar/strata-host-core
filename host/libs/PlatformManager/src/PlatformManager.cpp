
#include "PlatformManager.h"
#include "PlatformConnection.h"
#include <serial_port.h>

#include <string>
#include <algorithm>
#include <functional>
#include <iostream>
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
    ports_update_.reset( eventsMgr_.CreateEventTimer(g_portsRefreshTime) );
    ports_update_->setCallback(std::bind(&PlatformManager::onUpdatePortList, this, std::placeholders::_1, std::placeholders::_2) );

    if (!ports_update_->activate(&eventsMgr_)) {
        ports_update_.release();
        return false;
    }

    return true;
}

void PlatformManager::StartLoop()
{
    eventsMgr_.startInThread();
}

void PlatformManager::Stop()
{
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

void PlatformManager::onUpdatePortList(EvEvent*, int)
{
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


}

EvEventsMgr* PlatformManager::getEvEventsMgr()
{
    return &eventsMgr_;
}

void PlatformManager::onAddedPort(serialPortHash hash)
{
    std::string portName  = hashToPortName(hash);
//TODO: add this to logging     std::cout << "New ser.port:" << portName << std::endl;

    PlatformConnection* conn = new PlatformConnection(this);
    if (conn->open(portName) == false) {
        delete conn;
        return;
    }

    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        openedPorts_.insert({hash, conn});
    }

    conn->attachEventMgr(&eventsMgr_);

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
