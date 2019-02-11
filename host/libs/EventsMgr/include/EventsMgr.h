
#ifndef PROJECT_EVENTSMGR_H
#define PROJECT_EVENTSMGR_H

#include <functional>
#include <thread>

struct event_base;
struct event;
class EvEventsMgr;

//a copy from libevent2
#ifdef _WIN32
#define evutil_socket_t intptr_t
#else
#define evutil_socket_t int
#endif

//////////////////////////////////////////////////////////////////

class EvEvent
{
public:
    enum EventType {
        eEvTypeUnknown = 0,
        eEvTypeTimer,
        eEvTypeHandle,
        eEvTypeSignal       //Linux or Mac only
    };

    enum EventState {
        eEvStateRead  = 1,
        eEvStateWrite = 2,
        eEvStateTimeout = 4,
    };

    EvEvent();
    EvEvent(EventType type, int fileHandle, int timeInMs);
    ~EvEvent();

    /**
     * Sets the event type
     * @param type type of the event (Timer and Handle is now supported)
     * @param fileHandle filehandle or -1 for undefined
     * @param timeInMs timeout for event or 0 for undefined
     */
    void set(EventType type, int fileHandle, int timeInMs);

    /**
     * Sets callback function for this event
     * @param callback function to call
     */
    void setCallback(std::function<void(EvEvent*, int)> callback);

    /**
     * Activates the event in EvEventMgr
     * @param mgr event manager to attach
     * @param ev_flags flags see enum EventState
     * @return
     */
    bool activate(EvEventsMgr* mgr, int ev_flags = 0);

    /**
     * Deactivates event
     */
    void deactivate();

    /**
     * Fires the event
     * @param ev_flags flags see enum EventState
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
    EventType type_;
    int timeInMs_;
    int fileHandle_;
    bool active_ = false;

    std::function<void(EvEvent*, int)> callback_;

    struct event* event_;

    friend void evEventsCallback(evutil_socket_t fd, short what, void* arg);
};

//////////////////////////////////////////////////////////////////

class EvEventsMgr
{
public:
    EvEventsMgr();
    ~EvEventsMgr();

    EvEvent* CreateEventHandle(int fd);
    EvEvent* CreateEventTimer(int timeInMs);

    /**
     * starts dispatch loop with given flags
     * @param flags
     */
    void dispatch(int flags = 0);

    void startInThread();
    void stop();

    struct event_base* base() const { return event_base_; }

private:
    void threadMain();

private:
    std::thread eventsThread_;
    volatile sig_atomic_t stopThread_ = false;

private:
    struct event_base* event_base_;

};


#endif //PROJECT_EVENTSMGR_H
