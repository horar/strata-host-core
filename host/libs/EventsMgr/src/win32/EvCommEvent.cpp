
#if !defined(_WIN32)
#error "This file is only for Widnows"
#endif

#include "win32/EvCommEvent.h"

namespace spyglass {

    WinCommEvent::WinCommEvent() : EvEventBase(EvType::eEvTypeWinHandle),
        hComm_(NULL), flags_(0), state_(eNotInitialized),
        hReadWaitEvent_(NULL), dwEventMask_(0), hWriteEvent_(NULL)
    {
        wait_ = { 0 };
    }

    WinCommEvent::~WinCommEvent()
    {
        if (hWriteEvent_ != NULL) {
            ::CloseHandle(hWriteEvent_);
        }

        if (hReadWaitEvent_ != NULL) {
            ::CloseHandle(hReadWaitEvent_);
        }
    }

    bool WinCommEvent::create(HANDLE hComm)
    {
        hReadWaitEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
        if (hReadWaitEvent_ == NULL) {
            return false;
        }

        hWriteEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
        if (hWriteEvent_ == NULL) {
            return false;
        }

        hComm_ = hComm;
        state_ = eReady;
        return true;
    }

    preDispatchResult WinCommEvent::preDispatch()
    {
        resetCommMask();

        if (state_ == ePending) {
            return eIOPending;
        }

        dwEventMask_ = 0;
        memset(&wait_, 0, sizeof(wait_));
        wait_.hEvent = hReadWaitEvent_;

        if (!::WaitCommEvent(hComm_, &dwEventMask_, &wait_)) {
            if (GetLastError() != ERROR_IO_PENDING) {
                //hard error..
                return eError;
            }

            state_ = ePending;
            return eIOPending;
        }
        return eOK;
    }

    ev_handle_t WinCommEvent::getWaitHandle()
    {
        return reinterpret_cast<ev_handle_t>(hReadWaitEvent_);
    }

    bool WinCommEvent::isPending() const
    {
        return state_ == ePending;
    }

    void WinCommEvent::cancelWait()
    {
        if (state_ != ePending)
            return;

        ::CancelIoEx(hComm_, &wait_);
        ::ResetEvent(wait_.hEvent);
        state_ = eReady;
    }

    bool WinCommEvent::activate(int evFlags)
    {
        std::lock_guard <std::mutex> lock(eventLock_);

        DWORD dwComMask = (evFlags & EvEventBase::eEvStateRead) ? EV_RXCHAR : 0;
        if (!::SetCommMask(hComm_, dwComMask)) {
            //TODO: error handling
            return false;
        }
        if ((evFlags & EvEventBase::eEvStateWrite) != 0) {
            ::SetEvent(hWriteEvent_);
        }
        else {
            ::ResetEvent(hWriteEvent_);
        }

        flags_ = evFlags;
        return true;
    }

    void WinCommEvent::deactivate()
    {
        std::lock_guard <std::mutex> lock(eventLock_);

        ::SetCommMask(hComm_, 0);
        ::ResetEvent(hWriteEvent_);
        flags_ = 0;
    }

    int WinCommEvent::getActivationFlags()
    {
        std::lock_guard <std::mutex> lock(eventLock_);

        int flags = 0;
        flags |= (dwEventMask_ & EV_RXCHAR) ? EvEventBase::eEvStateRead : 0;
        flags |= (flags_ & EvEventBase::eEvStateWrite);
        return flags;
    }

    bool WinCommEvent::isActive(int ev_flags) const
    {
        return (flags_ & ev_flags) != 0;
    }

    ev_handle_t WinCommEvent::getWriteWaitHandle() const
    {
        return hWriteEvent_;
    }

    int WinCommEvent::resetCommMask()
    {
        DWORD dwComMask = (flags_ & EvEventBase::eEvStateRead) ? EV_RXCHAR : 0;
        return ::SetCommMask(hComm_, dwComMask);
    }

} //namespace spyglass


