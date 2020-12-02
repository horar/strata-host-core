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

    Q_INVOKABLE void clearUserDir(const QString &strataLoginUsername);

    Q_INVOKABLE QStringList getAllDocumentIDs();

signals:
    void userAccessMapReceived(QJsonObject user_access_map);

    void statusUpdated(int total_docs);

private:
    DatabaseAccess* DB_ = nullptr;

    QString strataLoginUsername_ = "";

    QString endpointURL_ = "";

    QString dbDirName_ = "";
};
