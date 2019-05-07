
#include "PlatformManager.h"
#include "PlatformConnection.h"

#if defined(_WIN32)
#include <win32/EvCommEvent.h>
#endif

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

    ports_update_.reset(new EvTimerEvent());
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

PlatformConnectionShPtr PlatformManager::getConnection(const std::string& connection_id)
{
    serialPortHash hash = std::hash<std::string>{}(connection_id);
    PlatformConnectionShPtr conn;
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
    //TODO: add to log.. std::cout << "onUpdatePortList:" << std::endl;

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
            onRemoveClosedPort(hash);

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
//TODO: add this to logging    std::string portName  = hashToPortName(hash);
//TODO: add this to logging    std::cout << "Removed ser.port:" << portName << std::endl;

    PlatformConnectionShPtr conn;
    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        auto find = openedPorts_.find(hash);
        if (find == openedPorts_.end()) {
            return;
        }

        conn = find->second;
    }

//TODO: add to log.. std::cout << "Disconnect" << std::endl;

    EvEventBase* ev = conn->getEvent();
    if (ev) {
        eventsMgr_.unregisterEvent(ev);
        conn->releaseEvent();
    }

    if (plat_handler_) {
        plat_handler_->onCloseConnection(conn);
    }

    conn->close();
    conn.reset();

    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        openedPorts_.erase(hash);
    }
}

void PlatformManager::onRemoveClosedPort(serialPortHash hash)
{
    std::lock_guard<std::mutex> lock(closedPorts_mutex_);

    auto findIt = closedPorts_.find(hash);
    if (findIt != closedPorts_.end()) {
        closedPorts_.erase(findIt);
    }
}

bool PlatformManager::removeConnection(const std::string& connection_id)
{
    PlatformConnectionShPtr conn = getConnection(connection_id);
    if (!conn) {
        return false;
    }

    conn->close();

    unregisterConnection(conn->getName());

//TODO: add to log..  std::cout << "Disconnect" << std::endl;
    return true;
}

void PlatformManager::onAddedPort(serialPortHash hash)
{
//TODO: add to log.. std::cout << "onAddedPort()" << std::endl;

    std::string portName  = hashToPortName(hash);
//TODO: add this to logging     std::cout << "New ser.port:" << portName << std::endl;

    PlatformConnectionShPtr conn = std::make_shared<PlatformConnection>(this);
    if (conn->open(portName) == false) {
        return;
    }

    spyglass::EvEventBase* ev = conn->createEvent();
    eventsMgr_.registerEvent(ev);

    //activate event in dispatcher (for read)
    if (ev->activate(spyglass::EvEvent::eEvStateRead) == false) {
        //TODO: error logging...
        eventsMgr_.unregisterEvent(ev);

        return;
    }

//TODO: add to log.. std::cout << "New connection" << std::endl;

    {
        std::lock_guard<std::mutex> lock(connectionMap_mutex_);
        openedPorts_.insert({hash, conn});
    }

    if (plat_handler_) {
        plat_handler_->onNewConnection(conn);  //TODO:
    }
}

void PlatformManager::notifyConnectionReadable(const std::string& connection_id)
{
    if (plat_handler_ == nullptr) {
        //TODO: add some logging...
        return;
    }

    PlatformConnectionShPtr conn = getConnection(connection_id);
    if (conn) {
        plat_handler_->onNotifyReadConnection(conn);
    }
}

void PlatformManager::unregisterConnection(const std::string& connection_id)
{
    PlatformConnectionShPtr conn = getConnection(connection_id);
    if (!conn) {
        return;
    }

    serialPortHash hash = std::hash<std::string>{}(connection_id);

    EvEventBase* ev = conn->getEvent();
    if (ev != nullptr) {
        eventsMgr_.unregisterEvent(ev);
        conn->releaseEvent();
    }

    {
        std::lock_guard<std::mutex> lock1(closedPorts_mutex_);
        std::lock_guard<std::mutex> lock2(connectionMap_mutex_);

        closedPorts_.insert( { hash, conn } );
        openedPorts_.erase(hash);
    }
}


} //end of namespace
