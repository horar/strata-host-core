#pragma once

#include "EventsMgr/EvEventBase.h"

#include <thread>
#include <atomic>
#include <mutex>
#include <list>
#include <utility>

#include <windows.h>

namespace strata::events_mgr {

class EvCommWaitManager
{
public:
    EvCommWaitManager();
    ~EvCommWaitManager();

    /**
     * Registers an event in this class
     * @param event event to register
     * @return returns true when succeeded, otherwise false
     */
    bool registerEvent(EvEventBase* event);

    /**
     * Unregister event from dispatcher
     * @param event event to unregister
     */
    void unregisterEvent(EvEventBase* event);

    /**
     * Starts dispatcher in second thread
     * @return returns true when succeded
     */
    bool startInThread();

    /**
     * Stops dispatcher thread
     */
    void stop();

private:
    void threadMain();

    /**
     * Dispatch function
     * @return negativ number is error, zero or one is
     */
    int dispatch();

    int handleEvent(HANDLE hEvent);

private:
    std::thread eventsThread_;
    std::atomic_bool stopThread_{ false };

    typedef std::pair<ev_handle_t, EvEventBase*> event_pair;

    std::list<event_pair> eventList_;
    std::mutex dispatchLock_;

    HANDLE hWakeupEvent_;
};

} //namespace
