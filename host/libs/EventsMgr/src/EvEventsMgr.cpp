
#include "EvEventsMgr.h"

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

EvEventsMgr::~EvEventsMgr()
{
    if (event_base_ != nullptr) {
        event_base_free(event_base_);
    }
}

EvEvent* EvEventsMgr::CreateEventHandle(ev_handle_t fd)
{
    return new EvEvent(EvEvent::EvType::eEvTypeHandle, fd, 0);
}

EvEvent* EvEventsMgr::CreateEventTimer(unsigned int timeInMs)
{
    return new EvEvent(EvEvent::EvType::eEvTypeTimer, -1, timeInMs);
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

void EvEventsMgr::startInThread()
{
    eventsThread_ = std::thread(&EvEventsMgr::threadMain, this);
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

} //end of namespace
