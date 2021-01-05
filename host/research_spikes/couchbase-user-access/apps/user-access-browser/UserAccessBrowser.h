#pragma once

#include <QObject>
#include <QQmlApplicationEngine>

#include "DatabaseManager.h"

class UserAccessBrowser: public QObject {
    Q_OBJECT

public:
    QQmlApplicationEngine* engine_;

    explicit UserAccessBrowser(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void getUserAccessMap(const QString &endpointURL);

    Q_INVOKABLE void loginAndStartReplication(const QString &strataLoginUsername, const QStringList &strataChannelList, const QString &endpointURL);

    Q_INVOKABLE void logoutAndStopReplication();

    Q_INVOKABLE void joinChannel(const QString &strataLoginUsername, const QString &channel);

    Q_INVOKABLE void leaveChannel(const QString &strataLoginUsername, const QString &channel);

    Q_INVOKABLE void clearUserDir(const QString &strataLoginUsername);

    Q_INVOKABLE QStringList getAllDocumentIDs();

signals:
    void userAccessMapReceived(QJsonObject userAccessMap);

    void statusUpdated(int totalDocs);

private:
    std::unique_ptr<DatabaseManager> databaseManager_ = nullptr;

    DatabaseAccess* DB_ = nullptr;

    DatabaseAccess* userAccessDB_ = nullptr;

    QString strataLoginUsername_ = "";

    QString endpointURL_ = "";

    QString dbDirName_ = "";
};
