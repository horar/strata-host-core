#ifndef BOARDSCONTROLER_H
#define BOARDSCONTROLER_H

#include <QObject>
#include <QVariantMap>

#include <PlatformManager.h>

class PlatformBoard;

class BoardsController : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BoardsController)

    Q_PROPERTY(QStringList connectionIds READ connectionIds NOTIFY connectionIdsChanged)

public:
    BoardsController(QObject *parent = nullptr);
    virtual ~BoardsController();

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void sendCommand(QString connection_id, QString cmd);
    Q_INVOKABLE QVariantMap getConnectionInfo(const QString &connectionId);
    Q_INVOKABLE void reconnect(const QString &connectionId);
    Q_INVOKABLE bool disconnect(const QString &connectionId);

    QStringList connectionIds() const;
    spyglass::PlatformConnectionShPtr getConnection(const QString &connectionId);

    //callbacks from ConnectionHandler
    void newConnection(const QString &connectionId);
    void activeConnection(const QString &connectionId);
    void closeConnection(const QString &connectionId);
    void notifyMessageFromConnection(const QString &connectionId, const QString &message);

signals:
    void connectedBoard(QString connectionId);
    void disconnectedBoard(QString connectionId);
    void notifyBoardMessage(QString connectionId, QString message);
    void activeBoard(QString connectionId);
    void connectionIdsChanged();

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

    private:
        BoardsController *receiver_;

        std::mutex connectionsLock_;
        std::map<spyglass::PlatformConnection*, PlatformBoard*> connections_;
    };

private:
    spyglass::PlatformManager platform_mgr_;
    ConnectionHandler conn_handler_;
    QStringList connectionIds_;
};

#endif //BOARDSCONTROLER_H
