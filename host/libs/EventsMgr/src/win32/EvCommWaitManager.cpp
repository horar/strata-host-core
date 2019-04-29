
#if !defined(_WIN32)
#error "This file is only for Widnows"
#endif

#include "win32/EvCommWaitManager.h"
#include "EvEventBase.h"
#include "win32/EvCommEvent.h"
#include "win32/EvTimerEvent.h"

#include <Windows.h>

#include <thread>
#include <assert.h>
#include <algorithm>

namespace spyglass
{

unsigned int g_waitTimeout = 5000;  //in ms
unsigned int g_maxEventMapSize = MAXIMUM_WAIT_OBJECTS-1;

WinCommWaitManager::WinCommWaitManager() : hWakeupEvent_(NULL)
{
}

WinCommWaitManager::~WinCommWaitManager()
{
    if (hWakeupEvent_ != NULL) {
        ::CloseHandle(hWakeupEvent_);
    }
}

bool WinCommWaitManager::registerEvent(EvEventBase* ev)
{
    if (eventList_.size() >= g_maxEventMapSize) {
        return false;
    }

    ev_handle_t handle = ev->getWaitHandle();
    if (handle == NULL) {
        return false;
    }

    {
        std::lock_guard<std::mutex> lock(dispatchLock_);
        eventList_.push_back(std::make_pair(handle, ev));
    }

    if (ev->getType() == EvEventBase::EvType::eEvTypeWinHandle) {
        WinCommEvent* com = static_cast<WinCommEvent*>(ev);
        ev_handle_t handle_write = com->getWriteWaitHandle();
        if (handle_write == NULL) {
            return false;
        }

        {
            std::lock_guard<std::mutex> lock(dispatchLock_);
            eventList_.push_back(std::make_pair(handle_write, ev));
        }
    }

    if (hWakeupEvent_ != NULL) {
        ::SetEvent(hWakeupEvent_);
    }

    return true;
}

void WinCommWaitManager::unregisterEvent(EvEventBase* ev)
{
    {
        std::lock_guard<std::mutex> lock(dispatchLock_);
        for (auto it = eventList_.begin(); it != eventList_.end(); ) {
            if (it->second == ev) {
                it = eventList_.erase(it);
            }
            else {
                ++it;
            }
        }
    }

    if (hWakeupEvent_ != NULL) {
        ::SetEvent(hWakeupEvent_);
    }
}

bool WinCommWaitManager::startInThread()
{
    if (hWakeupEvent_ == NULL) {
        hWakeupEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
        if (hWakeupEvent_ == NULL) {
            return false;
        }
    }

    eventsThread_ = std::thread(&WinCommWaitManager::threadMain, this);
    return true;
}

void WinCommWaitManager::stop()
{
    if (eventsThread_.get_id() == std::thread::id() || hWakeupEvent_ == NULL) {
        return;
    }

    stopThread_ = true;
    ::SetEvent(hWakeupEvent_);

    eventsThread_.join();
}

int WinCommWaitManager::dispatch()
{
    int ret;
    DWORD dwCount = 0;
    HANDLE waitList[MAXIMUM_WAIT_OBJECTS];
    int processed_events = 0;

    {
        std::lock_guard<std::mutex> lock(dispatchLock_);

        for (auto item : eventList_) {

            if (item.second->getType() == EvEventBase::EvType::eEvTypeWinHandle) {
                WinCommEvent* ev = static_cast<WinCommEvent*>(item.second);
                if (ev->getWaitHandle() == item.first) {
                    WinCommEvent::preDispatchResult res = ev->preDispatch();
                    if (res == WinCommEvent::eOK) {
                        //handle imedially dispatch..
                        int flags = ev->getActivationFlags();
                        if (flags != 0) {
                            ev->handle_event(flags);
                            processed_events++;
                        }
                    }
                    else if (res != WinCommEvent::eIOPending) {
                        //TODO: log errors..
                        continue;
                    }
                }
            }

            waitList[dwCount] = item.first;
            dwCount++;
            if (dwCount >= (MAXIMUM_WAIT_OBJECTS-1))
                break;
        }

    }

    assert(hWakeupEvent_);
    waitList[dwCount] = hWakeupEvent_;
    dwCount++;

    DWORD dwRet = ::WaitForMultipleObjects(dwCount, waitList, FALSE, g_waitTimeout);
    if (dwRet == WAIT_FAILED) {
        return -1;
    }
    else if (dwRet == WAIT_TIMEOUT) {

        //Loop over all ev and cancel the Wait...

        for (const auto& item : eventList_) {

            if (item.second->getType() == EvEventBase::EvType::eEvTypeWinHandle) {
                WinCommEvent* com = static_cast<WinCommEvent*>(item.second);
                com->cancelWait();
            }
        }

        return processed_events;
    }
    else if (dwRet >= WAIT_OBJECT_0 && dwRet < (WAIT_OBJECT_0 + dwCount)) {

        // check witch one is signaled..
        HANDLE hSignaled = waitList[(dwRet - WAIT_OBJECT_0)];
        if (hSignaled == hWakeupEvent_) {

            ::ResetEvent(hWakeupEvent_);
            return 0;
        }

        if ((ret = handleEvent(hSignaled)) < 0) {
            return ret;
        }

        processed_events++;
        return processed_events;
    }

    return -2;
}

int WinCommWaitManager::handleEvent(HANDLE hSignaled)
{
    EvEventBase* ev;
    std::list<event_pair>::iterator findIt;
    {
        std::lock_guard<std::mutex> lock(dispatchLock_);
        findIt = std::find_if(eventList_.begin(), eventList_.end(), [=](event_pair const& item) {
            return item.first == hSignaled;
        });
        if (findIt == eventList_.end()) {
            assert(false);     //Something really wrong!
            return -1;
        }

        ev = findIt->second;
    }

    int flags = 0;
    if (ev->getType() == EvEventBase::EvType::eEvTypeWinHandle) {
        WinCommEvent* com = static_cast<WinCommEvent*>(ev);
        flags = com->getActivationFlags();
    }

    ev->handle_event(flags);

    //reset wait event, and loop WaitFor... ??

    if (ev->getType() == EvEventBase::EvType::eEvTypeWinHandle) {
        WinCommEvent* com = static_cast<WinCommEvent*>(ev);
        com->cancelWait();
    }
    else if (ev->getType() == EvEventBase::EvType::eEvTypeWinTimer) {
        WinTimerEvent* timer = static_cast<WinTimerEvent*>(ev);
        timer->restartTimer();
    }

    if (eventList_.size() > 1) {

        //NOTE: move signalled event to back of the event list
        //      to avoid signalling one and the same event
        std::lock_guard<std::mutex> lock(dispatchLock_);
        event_pair temp = *findIt;

        eventList_.erase(findIt);
        eventList_.push_back(temp);
    }

    return 0;
}

void WinCommWaitManager::threadMain()
{
    //TODO: put this in log:  std::cout << "Start thread.." << std::endl;

    int ret;
    while (!stopThread_) {
        ret = dispatch();
        if (ret < 0)
            break;

    }

    //TODO: put this in log:  std::cout << "Stop thread." << std::endl;
}


} //namespace spyglass
