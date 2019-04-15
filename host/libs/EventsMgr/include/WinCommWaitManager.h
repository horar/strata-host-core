#ifndef WIN_COMM_WAIT_MANAGER_H__
#define WIN_COMM_WAIT_MANAGER_H__

#if defined(_WIN32)

#include "WinEventBase.h"

#include <thread>
#include <atomic>
#include <map>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

namespace spyglass
{

class WinCommWaitManager
{
public:
	WinCommWaitManager();
	~WinCommWaitManager();

	bool registerEvent(WinEventBase* event);
	void unregisterEvent(WinEventBase* event);

	int dispatch();

	void startInThread();
	void stop();

private:
	void threadMain();

private:
	std::thread eventsThread_;
	std::atomic_bool stopThread_{ false };

	std::map<ev2_handle_t, WinEventBase*> eventMap_;
	HANDLE hStopEvent_;
};

} //namespace

#endif //_WIN32

#endif //WIN_COMM_WAIT_MANAGER_H__
