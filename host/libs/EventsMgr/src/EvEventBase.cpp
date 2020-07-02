
#include "EventsMgr/EvEventBase.h"

#include <assert.h>

namespace strata::events_mgr {

EvEventBase::EvEventBase(EvType type) : type_(type)
{
}

EvEventBase::~EvEventBase()
{
}

void EvEventBase::setType(EvType type)
{
    type_ = type;
}

void EvEventBase::setCallback(std::function<void(EvEventBase*, int)> callback)
{
    callback_ = callback;
}

void EvEventBase::handle_event(int flags)
{
    if (callback_) {
        callback_(this, flags);
    }
}

} //namespace

