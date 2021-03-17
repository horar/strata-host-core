#pragma once

#include <QObject>
#include <QQmlApplicationEngine>

#include "Database/DatabaseManager.h"

class CouchChat: public QObject {
    Q_OBJECT

    Q_PROPERTY(QString loginUsername READ getLoginUsername NOTIFY usernameChanged)

    Q_PROPERTY(QString channelName READ getChannel NOTIFY channelChanged)

public:
    QQmlApplicationEngine* engine_;

    explicit CouchChat(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);

    Q_INVOKABLE void login(const QString &strataLoginUsername, const QString &desiredChatroom);

    Q_INVOKABLE void logout();

    QString getLoginUsername() const;

    QString getChannel() const;

    Q_INVOKABLE QStringList getAllDocumentIDs();

    Q_INVOKABLE QStringList readChannelsAccessGrantedOfUser(const QString &loginUsername);

signals:
    void receivedDbContents(QStringList allChannelsGranted, QStringList allChannelsDenied, QStringList allDocumentIDs);

    void receivedMessage(QString user, QString message);

    void usernameChanged();

    void channelChanged();

private:
    std::unique_ptr<DatabaseManager> databaseManager_ = nullptr;

    DatabaseAccess* DB_ = nullptr;

    // Current user info
    QString loginUsername_ = "";

    QString channelName_ = "";

    // Replicator URL endpoint
    QString endpointURL_ = "ws://localhost:4984/chatroom-app";

    void documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents);
};
