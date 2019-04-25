#ifndef STRATA_EVENTS_MGR_WIN_COMM_EVENT_H__
#define STRATA_EVENTS_MGR_WIN_COMM_EVENT_H__

#if defined(_WIN32)

#include "EvEventBase.h"

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

namespace spyglass {

class WinCommEvent : public EvEventBase
{
public:
    WinCommEvent();
    ~WinCommEvent();

    /**
     * creates an event for asynchronous notifications
     * @param hComm communication device handle to create wait event
     */
    bool create(HANDLE hComm);

    /**
     * returns handle to the wait event
     */
    ev_handle_t getWaitHandle() override;

    bool activate(int evFlags) override;
    void deactivate() override;

    int getActivationFlags() override;

    bool isActive(int ev_flags) const override;

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

#endif //STRATA_EVENTS_MGR_WIN_COMM_EVENT_H__
