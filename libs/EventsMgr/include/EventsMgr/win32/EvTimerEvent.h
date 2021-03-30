#pragma once

#include <functional>
#include <windows.h>
#include <mutex>

#include "EventsMgr/EvEventBase.h"


namespace strata::events_mgr {

class EvTimerEvent : public EvEventBase
{
public:
    EvTimerEvent();
    ~EvTimerEvent();

    /**
     * Creates timer event with specified time
     * @param timeInMs specified time to signal
     * @return returns true when succeeded, otherwise false
     */
    bool create(unsigned int timeInMs);

    /**
     * Restarts the timer
     */
    void restartTimer();

    /**
     * returns handle to the wait event
     */
    ev_handle_t getWaitHandle() override;

    bool activate(int evFlags) override;
    void deactivate() override;

    int getActivationFlags() override;

    bool isActive(int ev_flags) const override;

private:
    bool setTimer();

private:
    HANDLE hTimer_;
    unsigned int timeInMs_;
    bool active_;

    std::mutex lock_;
};

}; //namespace
