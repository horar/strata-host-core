#ifndef COUCHCHAT_H
#define COUCHCHAT_H

#include <QObject>
#include <QQmlApplicationEngine>

#include "DatabaseManager.h"

class CouchChat: public QObject {
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString channel_name READ getChannel NOTIFY channelChanged)

public:
    explicit CouchChat(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE void loginAndStartReplication(const QString &user_name, const QString &channel_name, const QString &endpoint_url);
    Q_INVOKABLE void logoutAndStopReplication();

    QQmlApplicationEngine* engine_;

    QString getUsername() const { return user_name_; }
    QString getChannel() const { return channel_name_; }

signals:
    void receivedMessage(QString user, QString message);
    void usernameChanged();
    void channelChanged();

private:
    DatabaseAccess* DB_;

    // Current user info
    QString user_name_ = "";
    QString channel_name_ = "";

    // Replicator URL endpoint
    QString endpoint_url_ = "";
    const QString replicator_username_ = "";
    const QString replicator_password_ = "";

    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
};

#endif // COUCHCHAT_H
