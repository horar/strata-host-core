
#include "WinEventBase.h"

#if defined(_WIN32)

namespace spyglass {

WinEventBase::WinEventBase(int type) : type_(type)
{
}

WinEventBase::~WinEventBase()
{
}

void WinEventBase::setCallback(std::function<void(WinEventBase*, int)> callback)
{
    callback_ = callback;
}

void WinEventBase::handle_event(int flags)
{
    if (callback_) {
        callback_(this, flags);
    }
}

} //namespace

#endif //defined(_WIN32)
