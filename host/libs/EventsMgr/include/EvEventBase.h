#ifndef PLATFORM_MANAGER_WIN_EVENT_BASE_H__
#define PLATFORM_MANAGER_WIN_EVENT_BASE_H__

#include <functional>

namespace spyglass {

#ifdef _WIN32
    typedef void*  ev2_handle_t;
#else
    typedef int    ev2_handle_t;
#endif

class EvEventBase
{
public:
    enum class EvType {
        eEvTypeUnknown = 0,
        eEvTypeTimer,       //Linux,Mac
        eEvTypeHandle,      //Linux,Mac and Windows only sockets
        eEvTypeSignal,      //Linux or Mac only
        eEvTypeWinHandle,   //Windows only
        eEvTypeWinTimer,    //Windows only
        eEvTypeWinFakeHandle,
    };

    enum EvTypeFlags {   //flags for event type occured
        eEvStateRead  = 1,
        eEvStateWrite = 2,
        eEvStateTimeout = 4,
    };

public:
    EvEventBase(EvType type);
    virtual ~EvEventBase();

    EvType getType() const { return type_; }

    /**
     * Sets callback function for this event
     * @param callback function to call
     */
    void setCallback(std::function<void(EvEventBase*, int)> callback);

    virtual ev2_handle_t getWaitHandle() = 0;
    virtual void handle_event(int flags);

    virtual bool activate(int evFlags) = 0;
    virtual void deactivate() = 0;

protected:
    void setType(EvType type);

private:
    EvType type_;
    std::function<void(EvEventBase*, int)> callback_;
};

}; //namespace

#endif //PLATFORM_MANAGER_WIN_EVENT_BASE_H__
