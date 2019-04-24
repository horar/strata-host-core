#ifndef STRATA_EVENTS_MGR_WIN_COMM_FAKE_EVENT_H__
#define STRATA_EVENTS_MGR_WIN_COMM_FAKE_EVENT_H__

#if defined(_WIN32)

#include <functional>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include "EvEventBase.h"

namespace spyglass {

class WinCommFakeEvent : public EvEventBase
{
public:
    WinCommFakeEvent();
    virtual ~WinCommFakeEvent();

    /**
     * Creates fake event
     * @returns returns true when succeeded otherwise false
     */
    bool create();

    virtual ev_handle_t getWaitHandle();

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

#endif //STRATA_EVENTS_MGR_WIN_COMM_FAKE_EVENT_H__
