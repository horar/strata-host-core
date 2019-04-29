#ifndef STRATA_EVENTS_MGR_WIN_COMM_WAIT_MANAGER_H__
#define STRATA_EVENTS_MGR_WIN_COMM_WAIT_MANAGER_H__

#if defined(_WIN32)

#include "EvEventBase.h"

#include <thread>
#include <atomic>
#include <mutex>
#include <list>
#include <utility>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

namespace spyglass
{

class WinCommWaitManager
{
public:
    WinCommWaitManager();
    ~WinCommWaitManager();

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

#endif //_WIN32

#endif //STRATA_EVENTS_MGR_WIN_COMM_WAIT_MANAGER_H__
