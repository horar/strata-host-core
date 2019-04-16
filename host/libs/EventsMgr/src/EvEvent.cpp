
#include "EvEventBase.h"
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
    spyglass::EvEventBase *ev = static_cast<spyglass::EvEventBase *>(arg);

    int flags = 0;
    if (what & EV_READ)
        flags |= spyglass::EvEventBase::eEvStateRead;
    if (what & EV_WRITE)
        flags |= spyglass::EvEventBase::eEvStateWrite;
    if (what & EV_TIMEOUT)
        flags |= spyglass::EvEventBase::eEvStateTimeout;

    ev->handle_event(flags);
}

/////////////////////////////////////////////////////////////////////////////////

EvEvent::EvEvent() : EvEvent(EvType::eEvTypeUnknown, (ev_handle_t) - 1, 0)
{
}

EvEvent::EvEvent(EvType type, ev_handle_t fileHandle, unsigned int timeInMs) : EvEventBase(type),
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

    EvEventBase::setType(type);
    fileHandle_ = fileHandle;
    timeInMs_ = timeInMs;
}

void EvEvent::setDispatcher(EvEventsMgr* mgr)
{
    mgr_ = mgr;
}

bool EvEvent::activate(int ev_flags)  //EvEventsMgr *mgr,
{
    if (mgr_ == nullptr) {
        return false;
    }

    std::lock_guard <std::mutex> lock(lock_);
    if (event_ != nullptr) {
        deactivate();

        event_free(event_);
    }

    switch (EvEventBase::getType()) {
        case EvType::eEvTypeTimer: {
            event_ = event_new(mgr_->base(), -1, EV_TIMEOUT | EV_PERSIST, evEventsCallback,
                               static_cast<void *>(this));

            timeval seconds = EvEvent::tvMsecs(timeInMs_);
            if (event_add(event_, &seconds) < 0) {
                return false;
            }
            active_ = true;
            break;
        }

        case EvType::eEvTypeHandle: {
            short flags = ((ev_flags & EvEventBase::eEvStateRead) ? EV_READ : 0) | ((ev_flags & EvEventBase::eEvStateWrite) ? EV_WRITE : 0);
            event_ = event_new(mgr_->base(), fileHandle_, flags | EV_PERSIST, evEventsCallback,
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
    short flags = ((ev_flags & EvEventBase::eEvStateRead) ? EV_READ : 0) | ((ev_flags & EvEventBase::eEvStateWrite) ? EV_WRITE : 0);
    return event_pending(event_, flags, nullptr) != 0;
}

void EvEvent::fire(int ev_flags)
{
    if (event_ == nullptr || false == active_) {
        return;
    }

    switch (EvEventBase::getType()) {
        case EvType::eEvTypeTimer:
            event_active(event_, EV_TIMEOUT, 0);
            break;

        case EvType::eEvTypeHandle: {
            short flags = ((ev_flags & EvEventBase::eEvStateRead) ? EV_READ : 0) | ((ev_flags & EvEventBase::eEvStateWrite) ? EV_WRITE : 0);
            event_active(event_, flags, 0);
            break;
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


} //end of namespace
