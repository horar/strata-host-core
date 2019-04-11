#ifndef PLATFORM_MANAGER_WIN_EVENT_BASE_H__
#define PLATFORM_MANAGER_WIN_EVENT_BASE_H__

#if defined(_WIN32)

#include <functional>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

namespace spyglass {

class WinEventBase
{
public:
	WinEventBase() = default;
    virtual ~WinEventBase() = default;

    virtual int getType() = 0;

    virtual HANDLE getWaitHandle() = 0;
    virtual void handle_event(int flags) = 0;

    virtual bool activate(int evFlags) = 0;
    virtual void deactivate() = 0;
};

}; //namespace

#endif //_WIN32

#endif //PLATFORM_MANAGER_WIN_EVENT_BASE_H__
