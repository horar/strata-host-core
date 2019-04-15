#ifndef PLATFORM_MANAGER_WIN_COMM_EVENT_H__
#define PLATFORM_MANAGER_WIN_COMM_EVENT_H__

#if defined(_WIN32)

#include "WinEventBase.h"

namespace spyglass {

class WinCommEvent : public WinEventBase
{
public:
    WinCommEvent();
    virtual ~WinCommEvent();

    bool create(HANDLE hComm);

    void setCallback(std::function<void(WinEventBase*, int)> callback);

    virtual int getType() { return 1; }

    virtual ev2_handle_t getWaitHandle();
	virtual void handle_event(int flags);

	virtual bool activate(int evFlags);
	virtual void deactivate();

	bool isActive(int ev_flags) const;

protected:
	int preDispatch();

	int getEventStateFlags() const;
	bool isPending() const;

	void cancelWait();

private:
	int updateFlags();

private:
	HANDLE hComm_;

	int flags_;  //read / write

    enum state {
        eNotInitialized = 0,
        eReady = 1,
        ePending,
    };

    enum state state_;

    HANDLE hWaitEvent_;

	DWORD dwEventMask_;
	OVERLAPPED wait_;

    std::function<void(WinEventBase*, int)> callback_;

	friend class WinCommWaitManager;
};

}; //namespace


#endif //_WIN32

#endif //PLATFORM_MANAGER_WIN_COMM_EVENT_H__
