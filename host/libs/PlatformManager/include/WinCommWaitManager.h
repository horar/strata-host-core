#ifndef WIN_COMM_WAIT_MANAGER_H__
#define WIN_COMM_WAIT_MANAGER_H__

#if defined(_WIN32)

#include <thread>
#include <atomic>
#include <map>

typedef void* HANDLE;

namespace spyglass
{

class WinEventBase;

class WinCommWaitManager
{
public:
	WinCommWaitManager();
	~WinCommWaitManager();

	void addEvent(WinEventBase* event);

	int dispatch();

	void startInThread();
	void stop();

private:
	void threadMain();

private:
	std::thread eventsThread_;
	std::atomic_bool stopThread_{ false };

	std::map<HANDLE, WinEventBase*> eventMap_;
	HANDLE hStopEvent_;
};

} //namespace

#endif //_WIN32

#endif //WIN_COMM_WAIT_MANAGER_H__
