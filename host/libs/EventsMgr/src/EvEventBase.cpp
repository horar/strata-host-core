
#include "EvEventBase.h"

#include <assert.h>

namespace spyglass {

EvEventBase::EvEventBase(EvType type) : type_(type)
{
}

EvEventBase::~EvEventBase()
{
}

void EvEventBase::setType(EvType type)
{
    assert(false);
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

