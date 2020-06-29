#pragma once

#include <functional>

namespace strata::events_mgr {

#ifdef _WIN32
    typedef void*  ev_handle_t;
#else
    typedef int    ev_handle_t;
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
    };

    enum EvTypeFlags {   //flags for event type occured
        eEvStateRead  = 1,
        eEvStateWrite = 2,
        eEvStateTimeout = 4,
    };

public:
    EvEventBase(EvType type);
    virtual ~EvEventBase();

    /**
     * returns type of the object
     */
    EvType getType() const { return type_; }

    /**
     * Sets callback function for this event
     * @param callback function to call
     */
    void setCallback(std::function<void(EvEventBase*, int)> callback);

    /**
     * returns handle for wait dispatcher
     */
    virtual ev_handle_t getWaitHandle() = 0;

    /**
     * Method that calls the callback.
     * @param flags bit flags of enum EvTypeFlags
     */
    virtual void handle_event(int flags);

    /**
     * Activates event in EventMgr (or WinCommWaitManager)
     * @param evFlags bit flags of enum EvTypeFlags
     * @return returns true when succeeded, otherwise false
     */
    virtual bool activate(int evFlags) = 0;

    /**
     * decativates event in EventMgr
     */
    virtual void deactivate() = 0;

    /**
     * returns activation flags
     * @return returns activation flags given on activate()
     */
    virtual int getActivationFlags() = 0;

    /**
     * Checks event activation flags
     * @param ev_flags flags to check
     * @return returns true when flags are set otherwise false
     */
    virtual bool isActive(int ev_flags) const = 0;    //TODO: probably better name...

protected:
    void setType(EvType type);

private:
    EvType type_;
    std::function<void(EvEventBase*, int)> callback_;
};

}; //namespace
