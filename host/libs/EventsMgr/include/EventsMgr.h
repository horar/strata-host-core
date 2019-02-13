
#ifndef PROJECT_EVENTSMGR_H
#define PROJECT_EVENTSMGR_H

#include <functional>
#include <thread>
#include <mutex>

struct event_base;
struct event;
class EvEventsMgr;

//a copy from libevent2
#if defined(_WIN32)
#define evutil_socket_t intptr_t
#else
#define evutil_socket_t int
#endif

#ifdef _WIN32
typedef intptr_t ev_handle_t;
#else
typedef int      ev_handle_t;
#endif

//////////////////////////////////////////////////////////////////

class EvEvent
{
public:
    enum EvType {
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
    EvEvent(EvType type, ev_handle_t fileHandle, int timeInMs);
    ~EvEvent();

    /**
     * Sets the event type
     * @param type type of the event (Timer and Handle is now supported)
     * @param fileHandle filehandle or -1 for undefined
     * @param timeInMs timeout for event or 0 for undefined
     */
    void set(EvType type, ev_handle_t fileHandle, int timeInMs);

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


    bool isActive(int ev_flags);

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
    EvType type_ = eEvTypeUnknown;
    int timeInMs_ = 0;
    ev_handle_t fileHandle_ = (ev_handle_t)-1;

    struct event* event_ = nullptr;

    std::function<void(EvEvent*, int)> callback_;
    bool active_ = false;       //status if event is in some event_base queue
    std::mutex lock_;

    friend void evEventsCallback(evutil_socket_t fd, short what, void* arg);
};

//////////////////////////////////////////////////////////////////

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
    EvEvent* CreateEventTimer(int timeInMs);

    /**
     * Starts dispatch loop with given flags
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
