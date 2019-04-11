
#include <EvEvent.h>	//for r/w flags

#include "WinTimerEvent.h"

namespace spyglass {

WinTimerEvent::WinTimerEvent() : WinEventBase(), hTimer_(NULL)
{
}

WinTimerEvent::~WinTimerEvent()
{
	if (hTimer_ != NULL) {
		::CloseHandle(hTimer_);
	}
}

bool WinTimerEvent::create()
{
	hTimer_ = ::CreateWaitableTimer(NULL, TRUE, NULL);
	return hTimer_ != NULL;
}

void WinTimerEvent::setCallback(std::function<void(EvEvent*, int)> callback)
{
	callback_ = callback;
}

bool WinTimerEvent::activate(int flags)
{
	LARGE_INTEGER time;
	time.QuadPart = -5000000LL;		//500ms

	BOOL ret = ::SetWaitableTimer(hTimer_, &time, 0, NULL, NULL, FALSE);
	if (!ret) {
		return false;
	}

	return true;
}

void WinTimerEvent::deactivate()
{
}

HANDLE WinTimerEvent::getWaitHandle()
{
	return hTimer_;
}

void WinTimerEvent::handle_event(int flags)
{
	if (callback_) {
		callback_(nullptr, flags);
	}
}


} //namespace