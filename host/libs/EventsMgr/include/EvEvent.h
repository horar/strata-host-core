#ifndef STRATA_EVENTS_MGR_EVENT_H
#define STRATA_EVENTS_MGR_EVENT_H

#include <mutex>
#include <functional>
#include <cstdio>

#include "EvEventBase.h"

#if defined(_WIN32)
#include <WinSock2.h>
#endif

//a copy from libevent2
#if defined(_WIN32)
#define evutil_socket_t intptr_t
#else
#define evutil_socket_t int
#endif

struct event;

namespace spyglass
{

#ifdef _WIN32
typedef intptr_t ev_handle_t;
#else
typedef int      ev_handle_t;
#endif

class EvEventsMgr;

//////////////////////////////////////////////////////////////////

class EvEvent : public EvEventBase
{
public:
    EvEvent();

    /**
     * Constructor
     * @param type type of event
     * @param fileHandle file handle or -1 for undefined
     * @param timeInMs timeout or 0 for undefined
     */
    EvEvent(EvType type, ev_handle_t fileHandle, unsigned int timeInMs);
    virtual ~EvEvent();

    /**
     * Sets the event type
     * @param type type of the event (Timer and Handle is now supported)
     * @param fileHandle filehandle or -1 for undefined
     * @param timeInMs timeout for event or 0 for undefined
     */
    void set(EvType type, ev_handle_t fileHandle, unsigned int timeInMs);

    /**
     * Sets the dispatcher for event
     * @param mgr
     */
    void setDispatcher(EvEventsMgr* mgr);

    /**
     * Activates the event in EvEventMgr
     * @param ev_flags flags see enum EvTypeFlags
     * @return
     */
    virtual bool activate(int ev_flags = 0);

    /**
     * Deactivates event, removes from event_loop
     */
    virtual void deactivate();


    virtual ev2_handle_t getWaitHandle() { return 0; }

    /**
     * Checks event activation flags
     * @param ev_flags flags to check
     * @return returns true when flags are set otherwise false
     */
    bool isActive(int ev_flags) const;    //TODO: probably better name...

    /**
     * Fires the event
     * @param ev_flags flags see enum EvTypeFlags
     */
    void fire(int ev_flags = 0);

    /**
     * Static method to convert time in miliseconds into 'struct timeval'
     * @param msecs time in miliseconds
     * @return converted time
     */
    static struct timeval tvMsecs(unsigned int msecs);

protected:


private:
    unsigned int timeInMs_;
    ev_handle_t fileHandle_;

    struct event* event_ = nullptr;
    EvEventsMgr* mgr_ = nullptr;

    bool active_ = false;       //status if event is in some event_base queue
    std::mutex lock_;

    friend void evEventsCallback(evutil_socket_t fd, short what, void* arg);
};


} //end of namespace

#endif //STRATA_EVENTS_MGR_EVENT_H
