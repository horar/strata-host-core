#ifndef COUCHCHAT_H
#define COUCHCHAT_H

#include <QObject>
#include <QQmlApplicationEngine>

#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

class CouchChat: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString channel_name READ getChannel NOTIFY channelChanged)

public:
    explicit CouchChat(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(QString message);

    QQmlApplicationEngine* engine_;
    QQmlComponent* component_;

    QString getUsername() const { return user_name_; }
    QString getChannel() const { return channel_name_; }

signals:
    void receivedMessage(QString message);
    void usernameChanged();
    void channelChanged();

private:
    DatabaseAccess* DB_;

    // Replicator URL endpoint
    const QString replicator_url = "ws://localhost:4984/user-access-test";
    const QString replicator_username = "";
    const QString replicator_password = "";

    QString user_name_, channel_name_;

    // std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener,
    // std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener,
};

#endif // COUCHCHAT_H
