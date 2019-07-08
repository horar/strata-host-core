
#include "Dispatcher.h"

const unsigned int g_waitForMessageTime = 500;  //in ms


HCS_Dispatcher::HCS_Dispatcher()
{

}

HCS_Dispatcher::~HCS_Dispatcher()
{

}

void HCS_Dispatcher::setMsgHandler(std::function<void(const PlatformMessage& )> callback)
{
    callback_ = callback;
}

// void registerHandler();
// void unregisterHandler();

void HCS_Dispatcher::addMessage(const PlatformMessage& msg)
{
    {
        std::lock_guard<std::mutex> lock(event_list_mutex_);
        events_list_.push_back(msg);
    }

    event_list_cv_.notify_all();
}

void HCS_Dispatcher::dispatch()
{
    int ret;
    PlatformMessage msg;

    while(stop_ == false) {

        ret = waitForMessage(msg, g_waitForMessageTime);
        if (ret < 0) {
            break;
        }
        else if (ret > 0) {

            if (callback_) {
                callback_(msg);
            }
        }
    }
}

void HCS_Dispatcher::stop()
{
    stop_ = true;
    event_list_cv_.notify_all();
}

int HCS_Dispatcher::waitForMessage(PlatformMessage& msg, unsigned int timeout)
{
    std::unique_lock<std::mutex> lock(event_list_mutex_);
    if (events_list_.empty()) {
        if (event_list_cv_.wait_for(lock, std::chrono::milliseconds(timeout)) ==
            std::cv_status::timeout) {
            return 0;
        }

        if (events_list_.empty()) {
            return 0;
        }
    }

    assert(!events_list_.empty());
    msg = events_list_.front();
    events_list_.pop_front();
    return 1;
}
