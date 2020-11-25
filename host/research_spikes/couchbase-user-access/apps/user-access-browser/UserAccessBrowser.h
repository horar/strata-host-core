#pragma once

#include <QObject>
#include <QQmlApplicationEngine>

#include "DatabaseManager.h"

class UserAccessBrowser: public QObject {
    Q_OBJECT

public:
    QQmlApplicationEngine* engine_;

    explicit UserAccessBrowser(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void loginAndStartReplication(const QString &strataLoginUsername, const QStringList &strataChannelList, const QString &endpointURL);

    Q_INVOKABLE void logoutAndStopReplication();

    Q_INVOKABLE QStringList getAllDocumentIDs();

signals:
    void statusUpdated(int total_docs);

private:
    DatabaseAccess* DB_;

    QString strataLoginUsername_ = "";

    QString endpointURL_ = "";
};
