#ifndef SCI_BOARDCONTROLER_H
#define SCI_BOARDCONTROLER_H

#include <QObject>

#include <PlatformManager.h>

class PlatformBoard;

class BoardsController : public QObject
{
    Q_OBJECT

public:
    BoardsController(QObject *parent = nullptr);
    virtual ~BoardsController();

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void sendCommand(QString connection_id, QString cmd);

    //callbacks from ConnectionHandler
    void newConnection(const std::string& connection_id, const std::string& verbose_name);
    void removeConnection(const std::string& connection_id);
    void notifyMessageFromConnection(const std::string& connection_id, const std::string& message);

signals:
    void connectedBoard(QString connectionId, QString verboseName);
    void disconnectedBoard(QString connectionId);
    void notifyBoardMessage(QString connectionId, QString message);

private:
    class ConnectionHandler : public spyglass::PlatformConnHandler
    {
    public:
        ConnectionHandler();
        virtual ~ConnectionHandler();

        void setParent(BoardsController* parent);

        void onNewConnection(spyglass::PlatformConnectionShPtr connection) override;
        void onCloseConnection(spyglass::PlatformConnectionShPtr connection) override;
        void onNotifyReadConnection(spyglass::PlatformConnectionShPtr connection) override;

        PlatformBoard* getBoard(spyglass::PlatformConnection* connection);

    private:
        BoardsController* parent_;

        std::mutex connectionsLock_;
        std::map<spyglass::PlatformConnection*, PlatformBoard*> connections_;
    };

private:
    spyglass::PlatformManager platform_mgr_;
    ConnectionHandler conn_handler_;

};


#endif //SCI_BOARDCONTROLER_H
