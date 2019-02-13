
#include "EventsMgr.h"

// libevent library
#include <event.h>
#include <event2/event.h>
#include <event2/thread.h>

#include <assert.h>
#include <iostream>

namespace spyglass
{

void evEventsCallback(evutil_socket_t /*fd*/, short what, void* arg)
{
    assert(arg);
    spyglass::EvEvent* ev = static_cast<spyglass::EvEvent*>(arg);

    int flags = 0;
    if (what & EV_READ)
        flags |= spyglass::EvEvent::eEvStateRead;
    if (what & EV_WRITE)
        flags |= spyglass::EvEvent::eEvStateWrite;
    if (what & EV_TIMEOUT)
        flags |= spyglass::EvEvent::eEvStateTimeout;

    ev->event_notification(flags);
}

/////////////////////////////////////////////////////////////////////////////////

EvEvent::EvEvent()
{
}

EvEvent::EvEvent(EvType type, ev_handle_t fileHandle, int timeInMs) : EvEvent()
{
    set(type, fileHandle, timeInMs);
}

EvEvent::~EvEvent()
{
    if (event_) {
        deactivate();

        event_free(event_);
    }
}

void EvEvent::set(EvType type, ev_handle_t fileHandle, int timeInMs)
{
    type_ = type;
    fileHandle_ = fileHandle;
    timeInMs_ = timeInMs;
}

void EvEvent::setCallback(std::function<void(EvEvent*, int)> callback)
{
    callback_ = callback;
}

bool EvEvent::activate(EvEventsMgr* mgr, int ev_flags)
{
    std::lock_guard<std::mutex> lock(lock_);
    if (event_ != nullptr) {
        deactivate();

        event_free(event_);
    }

    if (type_ == eEvTypeTimer) {
        event_ = event_new(mgr->base(), -1, EV_TIMEOUT | EV_PERSIST, evEventsCallback, static_cast<void*>(this) );

        timeval seconds = EvEvent::tvMsecs(timeInMs_);
        if (event_add(event_, &seconds) < 0) {
            return false;
        }
        active_ = true;
    }
    else if (type_ == eEvTypeHandle) {

        short flags = ((ev_flags & eEvStateRead) ? EV_READ : 0) | ((ev_flags & eEvStateWrite) ? EV_WRITE : 0);
        event_ = event_new(mgr->base(), fileHandle_, flags | EV_PERSIST, evEventsCallback, static_cast<void*>(this) );
        if (event_add(event_, nullptr) < 0) {
            return false;
        }
        active_ = true;
    }

    return true;
}

void EvEvent::deactivate()
{
    if (!event_ || !active_)
        return;

    event_del(event_);
    active_ = false;
}

bool EvEvent::isActive(int ev_flags)
{
    short flags = ((ev_flags & eEvStateRead) ? EV_READ : 0) | ((ev_flags & eEvStateWrite) ? EV_WRITE : 0);
    return event_pending(event_, flags, nullptr) != 0;
}

void EvEvent::fire(int ev_flags)
{
    if (!event_ || !active_)
        return;

    if (type_ == eEvTypeTimer) {
        event_active(event_, EV_TIMEOUT, 0);
    }
    else if (type_ == eEvTypeHandle) {

        short flags = ((ev_flags & eEvStateRead) ? EV_READ : 0) | ((ev_flags & eEvStateWrite) ? EV_WRITE : 0);
        event_active(event_, flags, 0);
    }
}

struct timeval EvEvent::tvMsecs(unsigned int msecs)
{
    timeval t;
    t.tv_sec = msecs / 1000;
    t.tv_usec = (msecs % 1000) * 1000;
    return t;
}

void EvEvent::event_notification(int flags)
{
    if (callback_) {
        callback_(this, flags);
    }
}

/////////////////////////////////////////////////////////////////////////////////

EvEventsMgr::EvEventsMgr() : event_base_(nullptr)
{
    static bool isInitialized = false;

    if (!isInitialized) {

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
    if (!event_base_) {
        throw std::runtime_error("Initialization of libevent2 failed!");
    }
}

EvEventsMgr::~EvEventsMgr()
{
    if (event_base_) {
        event_base_free(event_base_);
    }
}

EvEvent* EvEventsMgr::CreateEventHandle(ev_handle_t fd)
{
    return new EvEvent(EvEvent::eEvTypeHandle, fd, 0);
}

EvEvent* EvEventsMgr::CreateEventTimer(int timeInMs)
{
    return new EvEvent(EvEvent::eEvTypeTimer, -1, timeInMs);
}

void EvEventsMgr::dispatch(int flags)
{
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
    stopThread_ = true;
    eventsThread_.join();
}

void EvEventsMgr::threadMain()
{
    int ret;

    std::cout << "Start thread.." << std::endl;

    while(!stopThread_) {

        ret = event_base_loop(event_base_, 0);  //flags
        if (ret < 0)
            break;

    }

    std::cout << "Stop thread." << std::endl;
}

} //end of namespace
