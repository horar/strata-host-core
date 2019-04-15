#ifndef PLATFORM_MANAGER_WIN_COMM_FAKE_EVENT_H__
#define PLATFORM_MANAGER_WIN_COMM_FAKE_EVENT_H__

#if defined(_WIN32)

#include <functional>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include "WinEventBase.h"

namespace spyglass {

class WinCommFakeEvent : public WinEventBase
{
public:
    WinCommFakeEvent();
    virtual ~WinCommFakeEvent();

    bool create();

	virtual ev2_handle_t getWaitHandle();

    virtual bool activate(int evFlags);
    virtual void deactivate();

    int getEvFlagsState() const;

private:
	HANDLE hEvent_;
    int act_flags_;


    friend class WinCommWaitManager;
};

}; //namespace

#endif //_WIN32

#endif //PLATFORM_MANAGER_WIN_COMM_FAKE_EVENT_H__
