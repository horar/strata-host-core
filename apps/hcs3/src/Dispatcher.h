
#ifndef HOST_HCS_DISPATCHER_H__
#define HOST_HCS_DISPATCHER_H__

#include <string>
#include <mutex>
#include <deque>
#include <atomic>
#include <functional>

#include <QByteArray>

#include <rapidjson/document.h>

struct DispatcherMessage
{
    QByteArray from_client;
    QByteArray message;
    rapidjson::Document* msg_document;

    // constructor
    DispatcherMessage();
};


class HCS_Dispatcher final
{
public:
    HCS_Dispatcher();
    ~HCS_Dispatcher();

    /**
     * sets message handler callback
     * @param callback
     */
    void setMsgHandler(std::function<void(const DispatcherMessage& )> callback);

//    void registerHandler();
//    void unregisterHandler();

    /**
     * adds a message to the message queue
     * @param msg message to add
     */
    void addMessage(const DispatcherMessage& msg);

    /**
     * Dispatch messages (loop)
     */
    void dispatch();

    /**
     * Stops the dispatch message loop. This should be called from other thread
     */
    void stop();

private:
    int waitForMessage(DispatcherMessage& msg, unsigned int timeout);

private:

    //message queue
    std::mutex event_list_mutex_;
    std::deque<DispatcherMessage> events_list_;
    std::condition_variable event_list_cv_;
    std::atomic_bool stop_{false};

    std::function<void(const DispatcherMessage& )> callback_;
};

#endif //HOST_HCS_DISPATCHER_H__
