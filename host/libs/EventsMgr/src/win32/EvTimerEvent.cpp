
#if !defined(_WIN32)
#error "This file is only for Widnows"
#endif

#include "win32/EvTimerEvent.h"

namespace spyglass {

EvTimerEvent::EvTimerEvent() : EvEventBase(EvType::eEvTypeWinTimer), hTimer_(NULL), timeInMs_(0), active_(false)
{
}

EvTimerEvent::~EvTimerEvent()
{
    if (hTimer_ != NULL) {
        ::CloseHandle(hTimer_);
    }
}

bool EvTimerEvent::create(unsigned int timeInMs)
{
    if (hTimer_ != NULL) {
        return false;
    }

    hTimer_ = ::CreateWaitableTimer(NULL, TRUE, NULL);
    if (hTimer_ != NULL) {
        timeInMs_ = timeInMs;
    }

    return hTimer_ != NULL;
}

bool EvTimerEvent::activate(int flags)
{
    if (hTimer_ == NULL)
        return false;

    std::lock_guard <std::mutex> lock(lock_);
    if (active_) {
        return true;
    }

    bool ret;
    if ((ret = setTimer()) == true) {
        active_ = true;
    }
    return ret;
}

void EvTimerEvent::deactivate()
{
    std::lock_guard <std::mutex> lock(lock_);
    if (active_ == false) {
        return;
    }

    ::CancelWaitableTimer(hTimer_);
    active_ = false;
}

int EvTimerEvent::getActivationFlags()
{
    return (active_) ? EvEventBase::eEvStateTimeout : 0;
}

bool EvTimerEvent::isActive(int ev_flags) const
{
    return (ev_flags & EvEventBase::eEvStateTimeout) ? active_ : false;
}

bool EvTimerEvent::setTimer()
{
    LARGE_INTEGER time;
    time.QuadPart = (static_cast<int64_t>(timeInMs_ * 10000)) * -1;

    return ::SetWaitableTimer(hTimer_, &time, 0, NULL, NULL, FALSE) == TRUE;
}

ev_handle_t EvTimerEvent::getWaitHandle()
{
    return reinterpret_cast<ev_handle_t>(hTimer_);
}

void EvTimerEvent::restartTimer()
{
    setTimer();
}

} //namespace
