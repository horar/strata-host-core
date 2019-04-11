
#include <EvEvent.h>	//for r/w flags

#include "WinCommEvent.h"

namespace spyglass {

	WinCommEvent::WinCommEvent() : WinEventBase(), hComm_(NULL), flags_(0), state_(eNotInitialized), hWaitEvent_(NULL), dwEventMask_(0)
	{
		wait_ = { 0 };
	}

	WinCommEvent::~WinCommEvent()
	{
		if (hWaitEvent_ != NULL) {
			::CloseHandle(hWaitEvent_);
		}
	}

	bool WinCommEvent::create(HANDLE hComm)
	{
		hComm_ = hComm;

		hWaitEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
		if (hWaitEvent_ == NULL) {
			//TODO: error handling
			return false;
		}

		state_ = eReady;
		flags_ |= EvEvent::eEvStateRead;
        return true;
	}

	void WinCommEvent::setCallback(std::function<void(EvEvent*, int)> callback)
	{
		callback_ = callback;
	}

	int WinCommEvent::preDispatch()
	{
		DWORD dwComMask = 0;
		dwComMask |= (flags_ & EvEvent::eEvStateRead) ? EV_RXCHAR : 0;
		dwComMask |= (flags_ & EvEvent::eEvStateWrite) ? EV_TXEMPTY : 0;

		if (!::SetCommMask(hComm_, dwComMask)) {
			//TODO: error handling
			return -1;
		}

		dwEventMask_ = 0;
		memset(&wait_, 0, sizeof(wait_));
		wait_.hEvent = hWaitEvent_;

		if (!::WaitCommEvent(hComm_, &dwEventMask_, &wait_)) {
			if (GetLastError() != ERROR_IO_PENDING) {
				//hard error..
				return -1;
			}

			state_ = ePending;
			return 1;	//IO_PENDING
		}

		int flags = getEventStateFlags();

		handle_event(flags);
		return 0;
	}

	HANDLE WinCommEvent::getWaitHandle()
	{
		return hWaitEvent_;
	}

	int WinCommEvent::getEventStateFlags() const
	{
		int flags = 0;
		flags |= (dwEventMask_ & EV_RXCHAR) ? EvEvent::eEvStateRead : 0;
		flags |= (dwEventMask_ & EV_TXEMPTY) ? EvEvent::eEvStateWrite : 0;
		return flags;
	}

	bool WinCommEvent::isPending() const
	{
		return state_ == ePending;
	}

	void WinCommEvent::cancelWait()
	{
		::CancelIoEx(hComm_, &wait_);
		::ResetEvent(wait_.hEvent);
		state_ = eReady;
	}

	void WinCommEvent::handle_event(int flags)
	{
		if (callback_) {
			callback_(nullptr, flags);
		}
	}

	bool WinCommEvent::activate(int evFlags)
	{
		return false;
	}

	void WinCommEvent::deactivate()
	{

	}

} //namespace spyglass
