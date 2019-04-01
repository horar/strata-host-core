
#ifndef STRATA_EVENTS_MGR_H
#define STRATA_EVENTS_MGR_H

#include <thread>
#include <mutex>
#include <atomic>

#include "EvEvent.h"

struct event_base;

namespace spyglass
{

/**
 * NOTE: This class is working on Mac,Linux with file descriptors (handles). But on Windows it works only with WinSock handles.
 */
class EvEventsMgr
{
public:
    EvEventsMgr();
    ~EvEventsMgr();

    /**
     * Creates event for a filehandle
     * @param fd file handle
     * @return returns new event
     */
    EvEvent* CreateEventHandle(ev_handle_t fd);

    /**
     * Creates event for a timeout
     * @param timeInMs timeour in miliseconds
     * @return returns new event
     */
    EvEvent* CreateEventTimer(unsigned int timeInMs);

    /**
     * Starts dispatch loop with given flags
     * @param flags - not used at the moment
     */
    void dispatch(int flags = 0);

    /**
     * Starts dispatch loop in second thread and returns
     */
    void startInThread();

    /**
     * Stops thread with dispatch loop
     */
    void stop();

    struct event_base* base() const { return event_base_; }

private:
    void threadMain();

private:
    std::thread eventsThread_;
    std::atomic_bool stopThread_{false};

private:
    struct event_base* event_base_;

};

} //end of namespace

#endif //STRATA_EVENTS_MGR_H
