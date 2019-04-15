#ifndef PLATFORM_MANAGER_WIN_EVENT_BASE_H__
#define PLATFORM_MANAGER_WIN_EVENT_BASE_H__

namespace spyglass {

#ifdef _WIN32
	typedef void*  ev2_handle_t;
#else
	typedef int    ev2_handle_t;
#endif

class WinEventBase
{
public:
	WinEventBase();
    virtual ~WinEventBase();

    void setCallback(std::function<void(WinEventBase*, int)> callback);


    virtual int getType() = 0;

    virtual ev2_handle_t getWaitHandle() = 0;
    virtual void handle_event(int flags);

    virtual bool activate(int evFlags) = 0;
    virtual void deactivate() = 0;

protected:


private:
    std::function<void(WinEventBase*, int)> callback_;
};

}; //namespace

#endif //PLATFORM_MANAGER_WIN_EVENT_BASE_H__
