
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

void WinTimerEvent::setCallback(std::function<void(WinEventBase*, int)> callback)
{
	callback_ = callback;
}

bool WinTimerEvent::activate(int flags)
{
	LARGE_INTEGER time;
	time.QuadPart = -150000000LL;		//500ms

	BOOL ret = ::SetWaitableTimer(hTimer_, &time, 0, NULL, NULL, FALSE);
	if (!ret) {
		return false;
	}

	return true;
}

void WinTimerEvent::deactivate()
{
	::CancelWaitableTimer(hTimer_);
}

ev2_handle_t WinTimerEvent::getWaitHandle()
{
	return reinterpret_cast<ev2_handle_t>(hTimer_);
}

void WinTimerEvent::handle_event(int flags)
{
	if (callback_) {
		callback_(nullptr, flags);
	}
}

void WinTimerEvent::resetTimer()
{
	activate(0);

}


} //namespace