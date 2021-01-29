#pragma once

#include <QObject>
#include <QQmlApplicationEngine>

#include "DatabaseManager.h"

class UserAccessBrowser: public QObject {
    Q_OBJECT

public:
    QQmlApplicationEngine* engine_;

    explicit UserAccessBrowser(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void login(const QString &strataLoginUsername);

    Q_INVOKABLE void logout();

    Q_INVOKABLE void joinChannel(const QString &strataLoginUsername, const QString &channel);

    Q_INVOKABLE void leaveChannel(const QString &strataLoginUsername, const QString &channel);

    Q_INVOKABLE void clearUserDir(const QString &strataLoginUsername);

    Q_INVOKABLE QStringList getAllDocumentIDs();

signals:
    void receivedDbContents(QStringList allChannelsGranted, QStringList allChannelsDenied, QStringList allDocumentIDs);

private:
    std::unique_ptr<DatabaseManager> databaseManager_ = nullptr;

    DatabaseAccess* DB_ = nullptr;

    QString loginUsername_ = "";

    QString dbDirName_ = "";

    QString endpointURL_ = "ws://localhost:4984/platform-list";

    void changeListener(cbl::Replicator, const CBLReplicatorStatus &status);
};
