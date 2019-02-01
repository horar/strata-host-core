
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

    void set(EventType type, int fileHandle, int timeInMs);

    void setCallback(std::function<void(EvEvent*, int)> callback);

    bool activate(EvEventsMgr* mgr, int ev_flags = 0);
    void deactivate();

    void fire();

    static struct timeval tvMsecs(int msecs);

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
