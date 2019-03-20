#ifndef STRATA_EVENTS_MGR_EVENT_H
#define STRATA_EVENTS_MGR_EVENT_H

#include <mutex>
#include <functional>

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

class EvEvent
{
public:
    enum class EvType {
        eEvTypeUnknown = 0,
        eEvTypeTimer,
        eEvTypeHandle,
        eEvTypeSignal       //Linux or Mac only
    };

    enum EvTypeFlags {   //flags for event type occured
        eEvStateRead  = 1,
        eEvStateWrite = 2,
        eEvStateTimeout = 4,
    };

    EvEvent();

    /**
     * Constructor
     * @param type type of event
     * @param fileHandle file handle or -1 for undefined
     * @param timeInMs timeout or 0 for undefined
     */
    EvEvent(EvType type, ev_handle_t fileHandle, unsigned int timeInMs);
    ~EvEvent();

    /**
     * Sets the event type
     * @param type type of the event (Timer and Handle is now supported)
     * @param fileHandle filehandle or -1 for undefined
     * @param timeInMs timeout for event or 0 for undefined
     */
    void set(EvType type, ev_handle_t fileHandle, unsigned int timeInMs);

    /**
     * Sets callback function for this event
     * @param callback function to call
     */
    void setCallback(std::function<void(EvEvent*, int)> callback);

    /**
     * Activates the event in EvEventMgr
     * @param mgr event manager to attach
     * @param ev_flags flags see enum EvTypeFlags
     * @return
     */
    bool activate(EvEventsMgr* mgr, int ev_flags = 0);

    /**
     * Deactivates event, removes from event_loop
     */
    void deactivate();

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

    void event_notification(int flags);

private:
    EvType type_;
    unsigned int timeInMs_;
    ev_handle_t fileHandle_;

    struct event* event_ = nullptr;

    std::function<void(EvEvent*, int)> callback_;
    bool active_ = false;       //status if event is in some event_base queue
    std::mutex lock_;

    friend void evEventsCallback(evutil_socket_t fd, short what, void* arg);
};


} //end of namespace

#endif //STRATA_EVENTS_MGR_EVENT_H
