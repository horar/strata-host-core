
#include "EvEvent.h"
#include "EvEventsMgr.h"

// libevent library
#include <event.h>
#include <event2/event.h>
#include <event2/thread.h>

#include <assert.h>


namespace spyglass {


void evEventsCallback(evutil_socket_t /*fd*/, short what, void *arg)
{
    assert(arg);
    spyglass::EvEvent *ev = static_cast<spyglass::EvEvent *>(arg);

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

EvEvent::EvEvent() : EvEvent(EvType::eEvTypeUnknown, (ev_handle_t) - 1, 0)
{
}

EvEvent::EvEvent(EvType type, ev_handle_t fileHandle, unsigned int timeInMs) :
        type_{type},
        fileHandle_{fileHandle},
        timeInMs_{timeInMs}
{
}

EvEvent::~EvEvent()
{
    if (event_ != nullptr) {
        deactivate();

        event_free(event_);
    }
}

void EvEvent::set(EvType type, ev_handle_t fileHandle, unsigned int timeInMs)
{
    if (event_ != nullptr) {
        return;
    }

    type_ = type;
    fileHandle_ = fileHandle;
    timeInMs_ = timeInMs;
}

void EvEvent::setCallback(std::function<void(EvEvent * , int)> callback)
{
    callback_ = callback;
}

bool EvEvent::activate(EvEventsMgr *mgr, int ev_flags)
{
    std::lock_guard <std::mutex> lock(lock_);
    if (event_ != nullptr) {
        deactivate();

        event_free(event_);
    }

    switch (type_) {
        case eEvTypeTimer: {
            event_ = event_new(mgr->base(), -1, EV_TIMEOUT | EV_PERSIST, evEventsCallback,
                               static_cast<void *>(this));

            timeval seconds = EvEvent::tvMsecs(timeInMs_);
            if (event_add(event_, &seconds) < 0) {
                return false;
            }
            active_ = true;
            break;
        }

        case eEvTypeHandle: {
            short flags = ((ev_flags & eEvStateRead) ? EV_READ : 0) | ((ev_flags & eEvStateWrite) ? EV_WRITE : 0);
            event_ = event_new(mgr->base(), fileHandle_, flags | EV_PERSIST, evEventsCallback,
                               static_cast<void *>(this));
            if (event_add(event_, nullptr) < 0) {
                return false;
            }
            active_ = true;
            break;
        }

        default:
            assert(false);
            return false;

    }

    return true;
}

void EvEvent::deactivate()
{
    if (event_ == nullptr || false == active_) {
        return;
    }

    event_del(event_);
    active_ = false;
}

bool EvEvent::isActive(int ev_flags) const
{
    short flags = ((ev_flags & eEvStateRead) ? EV_READ : 0) | ((ev_flags & eEvStateWrite) ? EV_WRITE : 0);
    return event_pending(event_, flags, nullptr) != 0;
}

void EvEvent::fire(int ev_flags)
{
    if (event_ == nullptr || false == active_) {
        return;
    }

    switch (type_) {
        case eEvTypeTimer:
            event_active(event_, EV_TIMEOUT, 0);
            break;
        case eEvTypeHandle: {
            short flags = ((ev_flags & eEvStateRead) ? EV_READ : 0) | ((ev_flags & eEvStateWrite) ? EV_WRITE : 0);
            event_active(event_, flags, 0);
        }
        default:
            assert(false);
            break;
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


} //end of namespace
