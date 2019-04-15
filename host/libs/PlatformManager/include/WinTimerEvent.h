#ifndef PLATFORM_MANAGER_WIN_TIMER_EVENT_H__
#define PLATFORM_MANAGER_WIN_TIMER_EVENT_H__

#if defined(_WIN32)

#include <functional>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include "WinEventBase.h"

namespace spyglass {

class WinTimerEvent : public WinEventBase
{
public:
    WinTimerEvent();
    virtual ~WinTimerEvent();

    bool create();
	void setCallback(std::function<void(WinEventBase*, int)> callback);

	void resetTimer();

    virtual int getType() { return 0; }

	virtual ev2_handle_t getWaitHandle();
    virtual void handle_event(int flags);

    virtual bool activate(int evFlags);
    virtual void deactivate();

private:
	HANDLE hTimer_;
	std::function<void(WinEventBase*, int)> callback_;

    friend class WinCommWaitManager;
};

}; //namespace

#endif //_WIN32

#endif //PLATFORM_MANAGER_WIN_TIMER_EVENT_H__
