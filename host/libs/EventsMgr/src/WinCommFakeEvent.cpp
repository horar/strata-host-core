
#include "WinCommFakeEvent.h"

WinCommFakeEvent::WinCommFakeEvent()
{

}

WinCommFakeEvent::~WinCommFakeEvent()
{

}

bool WinCommFakeEvent::create()
{
    hEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
    if(hEvent_ == NULL)
        return false;

    return true;
}

void WinCommFakeEvent::setCallback(std::function<void(WinEventBase*, int)> callback)
{

}

int WinCommFakeEvent::getType() { return 2; }

ev2_handle_t WinCommFakeEvent::getWaitHandle()
{

}

void WinCommFakeEvent::handle_event(int flags)
{

}

bool WinCommFakeEvent::activate(int evFlags)
{

}

void WinCommFakeEvent::deactivate()
{

}
