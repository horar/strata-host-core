#pragma once

#include "EventsMgr/EvEventBase.h"

#include <Windows.h>
#include <mutex>

namespace strata::events_mgr {

class EvCommEvent : public EvEventBase
{
public:
    EvCommEvent();
    ~EvCommEvent();

    /**
     * creates an event for asynchronous notifications
     * @param hComm communication device handle to create wait event
     */
    bool create(HANDLE hComm);

    /**
     * returns handle to the wait event
     */
    ev_handle_t getWaitHandle() override;

    bool activate(int evFlags) override;
    void deactivate() override;

    int getActivationFlags() override;

    bool isActive(int ev_flags) const override;

    ev_handle_t getWriteWaitHandle() const;

protected:

    enum preDispatchResult {
        eError = -1,
        eOK = 0,
        eIOPending,
    };

    preDispatchResult preDispatch();

    int resetCommMask();

    bool isPending() const;

    void cancelWait();

private:
    int updateFlags();

private:
    HANDLE hComm_;
    int flags_;  //read

    enum state {
        eNotInitialized = 0,
        eReady = 1,
        ePending,
    };

    enum state state_;

    std::mutex eventLock_;

    HANDLE hReadWaitEvent_;

    DWORD dwEventMask_;
    OVERLAPPED wait_;

    HANDLE hWriteEvent_;

    friend class EvCommWaitManager;
};

}; //namespace
