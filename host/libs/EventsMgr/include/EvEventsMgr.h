
#ifndef STRATA_EVENTS_MGR_H__
#define STRATA_EVENTS_MGR_H__

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
     * Register event to event dispatcher
     * @param event event to register
     * @return returns
     */
    bool registerEvent(EvEventBase* event);

    /**
     * Unregisters event from event dispatcher
     * @param event
     */
    void unregisterEvent(EvEventBase* event);

    /**
     * Starts dispatch loop with given flags
     * @param flags - not used at the moment
     */
    void dispatch(int flags = 0);

    /**
     * Starts dispatch loop in second thread and returns
     */
    bool startInThread();

    /**
     * Stops thread with dispatch loop
     */
    void stop();

    /**
     * returns event base for EvEventsMgr
     */
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

#endif //STRATA_EVENTS_MGR_H__
