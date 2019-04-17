#ifndef WIN_COMM_WAIT_MANAGER_H__
#define WIN_COMM_WAIT_MANAGER_H__

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

    bool registerEvent(EvEventBase* event);
    void unregisterEvent(EvEventBase* event);

    int dispatch();

    void startInThread();
    void stop();

private:
    void threadMain();

private:
    std::thread eventsThread_;
    std::atomic_bool stopThread_{ false };

    typedef std::pair<ev2_handle_t, EvEventBase*> event_pair;

    std::list<event_pair> eventList_;
    std::mutex dispatchLock_;

    HANDLE hStopEvent_;
};

} //namespace

#endif //_WIN32

#endif //WIN_COMM_WAIT_MANAGER_H__
