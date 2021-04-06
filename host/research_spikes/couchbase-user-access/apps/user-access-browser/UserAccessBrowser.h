#pragma once

#include "Database/DatabaseManager.h"
#include "Database/DatabaseAccess.h"

#include <QObject>
#include <QQmlApplicationEngine>

namespace strata::Database
{
class UserAccessBrowser: public QObject {
    Q_OBJECT

public:
    QQmlApplicationEngine* engine_;

    explicit UserAccessBrowser(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void login(const QString &loginUsername);

    Q_INVOKABLE void logout();

    Q_INVOKABLE void joinChannel(const QString &loginUsername, const QString &channel);

    Q_INVOKABLE void leaveChannel(const QString &loginUsername, const QString &channel);

    Q_INVOKABLE void clearUserDir(const QString &loginUsername);

    Q_INVOKABLE QStringList getAllDocumentIDs();

signals:
    void receivedDbContents(QStringList allChannelsGranted, QStringList allChannelsDenied, QStringList allDocumentIDs);

private:
    std::unique_ptr<DatabaseManager> databaseManager_ = nullptr;

    DatabaseAccess* DB_ = nullptr;

    QString loginUsername_ = "";

    QString dbDirName_ = "";

    QString endpointURL_ = "ws://localhost:4984/platform-list";

    void changeListener(const DatabaseAccess::ActivityLevel &status);
};

} // namespace strata::Database
