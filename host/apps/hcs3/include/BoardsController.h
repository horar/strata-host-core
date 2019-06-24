#ifndef HCS_BOARDCONTROLER_H__
#define HCS_BOARDCONTROLER_H__

#include <PlatformManager.h>
#include <set>

#include "LoggingAdapter.h"

class PlatformBoard;
class HCS_Dispatcher;


class BoardsController final
{
public:
    BoardsController();
    ~BoardsController();

    bool initialize(HCS_Dispatcher* dispatcher);
    void setLogAdapter(LoggingAdapter* adapter);

    void sendMessage(const std::string& connectionId, const std::string& message);

    PlatformBoard* getPlatformBoard(const std::string& connectionId);
    PlatformBoard* findByPlatformId(const std::string& platformId);

    PlatformBoard* getBoardByClientId(const std::string& clientId);
    PlatformBoard* getFirstBoardByClassId(const std::string& classId);

    bool createPlatformsList(std::string& result);

    //callbacks from ConnectionHandler
    void newConnection(spyglass::PlatformConnectionShPtr connection);
    void closeConnection(const std::string& connectionId);
    void notifyMessageFromConnection(const std::string& connectionId, const std::string& message);

    void logging(LoggingAdapter::LogLevel level, const std::string& log_text);

private:
    class ConnectionHandler : public spyglass::PlatformConnHandler
    {
    public:
        ConnectionHandler();
        virtual ~ConnectionHandler();

        void setReceiver(BoardsController* receiver);

        void onNewConnection(spyglass::PlatformConnectionShPtr connection) override;
        void onCloseConnection(spyglass::PlatformConnectionShPtr connection) override;
        void onNotifyReadConnection(spyglass::PlatformConnectionShPtr connection) override;

        PlatformBoard* getBoard(spyglass::PlatformConnectionShPtr connection);
        PlatformBoard* findByPlatformId(const std::string& platformId);
        std::vector<PlatformBoard*> getConnectedList();

    private:
        BoardsController* receiver_;

        std::mutex connectionsLock_;
        std::map<spyglass::PlatformConnection*, PlatformBoard*> connections_;
    };

private:
    spyglass::PlatformManager platform_mgr_;
    ConnectionHandler conn_handler_;

    HCS_Dispatcher* dispatcher_{nullptr};
    LoggingAdapter* logAdapter_{nullptr};
};


#endif //HCS_BOARDCONTROLER_H__
