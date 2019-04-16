
#include <EvEvent.h>	//for r/w flags

#include "WinCommEvent.h"

#if defined(_WIN32)

namespace spyglass {

    WinCommEvent::WinCommEvent() : WinEventBase(1), hComm_(NULL), flags_(0), state_(eNotInitialized), hWaitEvent_(NULL), dwEventMask_(0)
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
        hWaitEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
        if (hWaitEvent_ == NULL) {
            //TODO: error handling
            return false;
        }

        hComm_ = hComm;
        state_ = eReady;
        return true;
    }

    int WinCommEvent::preDispatch()
    {
        if (updateFlags() != 0) {
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

        int flags = getEvFlagsState();

        handle_event(flags);
        return 0;
    }

    ev2_handle_t WinCommEvent::getWaitHandle()
    {
        return reinterpret_cast<ev2_handle_t>(hWaitEvent_);
    }

    int WinCommEvent::getEvFlagsState() const
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

    bool WinCommEvent::activate(int evFlags)
    {
        flags_ = evFlags;
        return true;
    }

    void WinCommEvent::deactivate()
    {
        flags_ = 0;
    }

    bool WinCommEvent::isActive(int ev_flags) const
    {
        return (flags_ & ev_flags) != 0;
    }

    int WinCommEvent::updateFlags()
    {
        DWORD dwComMask = 0;
        dwComMask |= (flags_ & EvEvent::eEvStateRead) ? EV_RXCHAR : 0;
        //TODO: dwComMask |= (flags_ & EvEvent::eEvStateWrite) ? EV_TXEMPTY : 0;

        if (!::SetCommMask(hComm_, dwComMask)) {
            //TODO: error handling
            return -1;
        }

        return 0;
    }


} //namespace spyglass

#endif //defined(_WIN32)

