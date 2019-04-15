
#include "WinCommWaitManager.h"
#include "WinEventBase.h"
#include "WinCommEvent.h"
#include "WinCommFakeEvent.h"
#include "WinTimerEvent.h"

#include <Windows.h>

#include <thread>

namespace spyglass
{

unsigned int g_waitTimeout = 500000;  //in ms

WinCommWaitManager::WinCommWaitManager() : hStopEvent_(NULL)
{
}

WinCommWaitManager::~WinCommWaitManager()
{
	if (hStopEvent_ != NULL) {
		::CloseHandle(hStopEvent_);
	}
}

bool WinCommWaitManager::registerEvent(WinEventBase* ev)
{
	ev2_handle_t handle = ev->getWaitHandle();
	if (handle == NULL) {
		return false;
	}

	eventMap_.insert({ handle, ev } );
	return true;
}

void WinCommWaitManager::unregisterEvent(WinEventBase* ev)
{
    for (auto item : eventMap_) {
        if (item.second == ev) {
            eventMap_.erase(item.first);
            return;
        }
    }
}

void WinCommWaitManager::startInThread()
{
	if (hStopEvent_ == NULL) {
		hStopEvent_ = ::CreateEvent(NULL, TRUE, FALSE, NULL);
		if (hStopEvent_ == 0) {
			return;
		}
	}

	eventsThread_ = std::thread(&WinCommWaitManager::threadMain, this);
}

void WinCommWaitManager::stop()
{
	if (eventsThread_.get_id() == std::thread::id()) {
		return;
	}

	stopThread_ = true;
	::SetEvent(hStopEvent_);

	eventsThread_.join();
}

int WinCommWaitManager::dispatch()
{
	int ret;
	DWORD dwCount = 0;
	HANDLE waitList[MAXIMUM_WAIT_OBJECTS];

    {
        std::lock_guard<std::mutex> lock(dispatchLock_);

	    for (auto item : eventMap_) {

            if (item.second->getType() == 1) {
                WinCommEvent* ev = static_cast<WinCommEvent*>(item.second);
                ret = ev->preDispatch();
    		    if (ret != 1)	//TODO: handle imedially dispatch..
    			    continue;
            }

		    waitList[dwCount] = item.first; dwCount++;
		    if (dwCount >= (MAXIMUM_WAIT_OBJECTS-1))
			    break;
	    }

    }

	if (dwCount == 0) {
		return 0;
	}

	waitList[dwCount] = hStopEvent_; dwCount++;

	DWORD dwRet = ::WaitForMultipleObjects(dwCount, waitList, FALSE, g_waitTimeout);
	if (dwRet == WAIT_FAILED) {
		return -1;
	}
	else if (dwRet == WAIT_TIMEOUT) {

		//Loop over all ev and cancel the Wait...

		for (const auto& item : eventMap_) {

			if (item.second->getType() == 1) {
				WinCommEvent* com = static_cast<WinCommEvent*>(item.second);
				com->cancelWait();
			}
		}

		return 0;
	}
	else if (dwRet >= WAIT_OBJECT_0 && dwRet < (WAIT_OBJECT_0 + dwCount)) {

		// check witch one is signaled..
		HANDLE hSignaled = waitList[(dwRet - WAIT_OBJECT_0)];
		if (hSignaled == hStopEvent_)
			return 0;

		auto findIt = eventMap_.find(hSignaled);
		if (findIt == eventMap_.end())
			return -1;

		int flags = 0;
		WinEventBase* ev = findIt->second;
		if (ev->getType() == 1) {
			WinCommEvent* com = static_cast<WinCommEvent*>(ev);
			flags = com->getEventStateFlags();
		}
        else if (ev->getType() == 3) {
            WinCommFakeEvent* com = static_cast<WinCommFakeEvent*>(ev);
            flags = com->getEventStateFlags();
        }

		ev->handle_event(flags);

		//reset wait event, and loop WaitFor... ??

		if (ev->getType() == 1) {
			WinCommEvent* com = static_cast<WinCommEvent*>(ev);
			com->cancelWait();
		}
		else if (ev->getType() == 2) {
			WinTimerEvent* timer = static_cast<WinTimerEvent*>(ev);
			timer->restartTimer();
		}

		return 1;
	}

	return -555;
}

void WinCommWaitManager::threadMain()
{
	//TODO: put this in log:  std::cout << "Start thread.." << std::endl;

	int ret;
	while (!stopThread_) {
		ret = dispatch();
	}

	//TODO: put this in log:  std::cout << "Stop thread." << std::endl;
}




} //namespace spyglass
