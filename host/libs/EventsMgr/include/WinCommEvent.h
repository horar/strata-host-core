#ifndef PLATFORM_MANAGER_WIN_COMM_EVENT_H__
#define PLATFORM_MANAGER_WIN_COMM_EVENT_H__

#if defined(_WIN32)

#include "EvEventBase.h"

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

namespace spyglass {

class WinCommEvent : public EvEventBase
{
public:
    WinCommEvent();
    virtual ~WinCommEvent();

    bool create(HANDLE hComm);

    virtual ev2_handle_t getWaitHandle();

    virtual bool activate(int evFlags);
    virtual void deactivate();

    bool isActive(int ev_flags) const;

    ev2_handle_t getWriteHandle();

    int getEvFlagsState() const;

protected:
    int preDispatch();

    bool isPending() const;

    void cancelWait();

private:
    int updateFlags();

private:
    HANDLE hComm_;
    int flags_;  //read

    enum state {
        eNotInitialized = 0,
        eReady = 1,
        ePending,
    };

    enum state state_;

    HANDLE hWaitEvent_;

    DWORD dwEventMask_;
    OVERLAPPED wait_;

    friend class WinCommWaitManager;
};

}; //namespace


#endif //_WIN32

#endif //PLATFORM_MANAGER_WIN_COMM_EVENT_H__
