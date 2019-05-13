#ifndef SCI_BOARDCONTROLER_H
#define SCI_BOARDCONTROLER_H

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

    QStringList connectionIds() const;
    spyglass::PlatformConnection* getConnection(const QString &connectionId);

    //callbacks from ConnectionHandler
    void newConnection(spyglass::PlatformConnection *connection);
    void closeConnection(const QString &connectionId);
    void notifyMessageFromConnection(const QString &connectionId, const QString &message);

signals:
    void connectedBoard(QString connectionId);
    void disconnectedBoard(QString connectionId);
    void notifyBoardMessage(QString connectionId, QString message);
    void connectionIdsChanged();

private:
    class ConnectionHandler : public spyglass::PlatformConnHandler
    {
    public:
        ConnectionHandler();
        virtual ~ConnectionHandler();

        void setReceiver(BoardsController* receiver);

        virtual void onNewConnection(spyglass::PlatformConnection *connection);
        virtual void onCloseConnection(spyglass::PlatformConnection *connection);
        virtual void onNotifyReadConnection(spyglass::PlatformConnection *connection);

        PlatformBoard* getBoard(spyglass::PlatformConnection* connection);
        spyglass::PlatformConnection* getConnection(const std::string& conn_id);

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


#endif //SCI_BOARDCONTROLER_H
