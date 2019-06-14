
#include "EvEventsMgr.h"
#include "EvEvent.h"

// libevent library
#include <event.h>
#include <event2/event.h>
#include <event2/thread.h>

#include <assert.h>
#include <iostream>


/////////////////////////////////////////////////////////////////////////////////

namespace spyglass
{

EvEventsMgr::EvEventsMgr() : event_base_(nullptr)
{
    static bool isInitialized = false;

    if (isInitialized == false) {

#if defined(_WIN32)
        int ret = evthread_use_windows_threads();
#else
        int ret = evthread_use_pthreads();
#endif
        if (ret < 0) {
            throw std::runtime_error("Initialization of libevent2 failed!");
        }

        isInitialized = true;
    }

    event_base_ = event_base_new();
    if (event_base_ == nullptr) {
        throw std::runtime_error("Initialization of libevent2 failed!");
    }
}

bool EvEventsMgr::registerEvent(EvEventBase* event)
{
    if (event->getType() != EvEventBase::EvType::eEvTypeHandle &&
        event->getType() != EvEventBase::EvType::eEvTypeTimer) {

        return false;
    }

    EvEvent* ev = static_cast<EvEvent*>(event);
    ev->setDispatcher(this);
    return true;
}

void EvEventsMgr::unregisterEvent(spyglass::EvEventBase *event)
{
    if (event->getType() != EvEventBase::EvType::eEvTypeHandle &&
        event->getType() != EvEventBase::EvType::eEvTypeTimer) {

        return;
    }

    EvEvent* ev = static_cast<EvEvent*>(event);
    ev->setDispatcher(nullptr);
}

EvEventsMgr::~EvEventsMgr()
{
    if (event_base_ != nullptr) {
        event_base_free(event_base_);
    }
}

void EvEventsMgr::dispatch(int flags)
{
    //Note: this are possible flags, not supported yet
    // EVLOOP_ONCE
    // EVLOOP_NONBLOCK
    // EVLOOP_NO_EXIT_ON_EMPTY

    assert(event_base_);
    event_base_loop(event_base_, flags);
}

bool EvEventsMgr::startInThread()
{
    eventsThread_ = std::thread(&EvEventsMgr::threadMain, this);
    return true;
}

void EvEventsMgr::stop()
{
    if (eventsThread_.get_id() == std::thread::id()) {
        return;
    }

    stopThread_ = true;

    event_base_loopexit(event_base_, nullptr);

    eventsThread_.join();
}

void EvEventsMgr::threadMain()
{
    //TODO: put this in log:  std::cout << "Start thread.." << std::endl;

    while(!stopThread_) {

        if (event_base_loop(event_base_, 0) < 0) {
            //TODO: show some error...
            break;
        }
    }

    //TODO: put this in log:  std::cout << "Stop thread." << std::endl;
}

//////////////////////////////////////////////////////////

bool EvEventsMgrInstance::wsa_init_done = false;

EvEventsMgrInstance::EvEventsMgrInstance()
{
#if defined(_WIN32)
    if (wsa_init_done == false)
    {
        WSADATA wsaData;
        if (WSAStartup( MAKEWORD(2,0), &wsaData ) != 0) {
            throw std::runtime_error("WSAStartup failed!");
        }

        wsa_init_done = true;
    }
#endif
}

EvEventsMgrInstance::~EvEventsMgrInstance()
{
#if defined(_WIN32)
    if (wsa_init_done) {
        WSACleanup();
    }
#endif
}


} //end of namespace
