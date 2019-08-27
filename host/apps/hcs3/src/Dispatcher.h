
#ifndef HOST_HCS_DISPATCHER_H__
#define HOST_HCS_DISPATCHER_H__

#include <string>
#include <mutex>
#include <deque>
#include <atomic>
#include <functional>

#include <rapidjson/document.h>

struct PlatformMessage
{
    enum MessageType {
        eMsgUnknown = 0,
        eMsgPlatformConnected,
        eMsgPlatformDisconnected,
        eMsgPlatformMessage,
        eMsgClientMessage,
        eMsgCouchbaseMessage,

        eMsgStorageRequest,     //from StorageManager / Downloader
        eMsgStorageResponse,
    };

    MessageType msg_type;
    std::string from_client;
    std::string message;
    rapidjson::Document* msg_document;
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
    void setMsgHandler(std::function<void(const PlatformMessage& )> callback);

//    void registerHandler();
//    void unregisterHandler();

    /**
     * adds a message to the message queue
     * @param msg message to add
     */
    void addMessage(const PlatformMessage& msg);

    /**
     * Dispatch messages (loop)
     */
    void dispatch();

    /**
     * Stops the dispatch message loop. This should be called from other thread
     */
    void stop();

private:
    int waitForMessage(PlatformMessage& msg, unsigned int timeout);

private:

    //message queue
    std::mutex event_list_mutex_;
    std::deque<PlatformMessage> events_list_;
    std::condition_variable event_list_cv_;
    std::atomic_bool stop_{false};

    std::function<void(const PlatformMessage& )> callback_;
};

#endif //HOST_HCS_DISPATCHER_H__
