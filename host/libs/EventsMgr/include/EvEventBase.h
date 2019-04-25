#ifndef STRATA_EV_EVENT_BASE_H__
#define STRATA_EV_EVENT_BASE_H__

#include <functional>

namespace spyglass {

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

protected:
    void setType(EvType type);

private:
    EvType type_;
    std::function<void(EvEventBase*, int)> callback_;
};

}; //namespace

#endif //STRATA_EV_EVENT_BASE_H__
