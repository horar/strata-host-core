#ifndef USERACCESSBROWSER_H
#define USERACCESSBROWSER_H

#include <QObject>
#include <QQmlApplicationEngine>

#include "DatabaseManager.h"

class UserAccessBrowser: public QObject {
    Q_OBJECT

public:
    explicit UserAccessBrowser(QQmlApplicationEngine *engine = nullptr, QObject *parent = nullptr);

    Q_INVOKABLE void loginAndStartReplication(const QString &strataLoginUsername, const QStringList &strataChannelList, const QString &endpointURL);
    Q_INVOKABLE void logoutAndStopReplication();
    Q_INVOKABLE QStringList getAllDocumentIDs();

    QQmlApplicationEngine* engine_;

signals:
    void statusUpdated(int total_docs);

private:
    DatabaseAccess* DB_;

    // Current user info
    QString strataLoginUsername_ = "";
    // QString channel_name_ = "";

    // Replicator URL endpoint
    QString endpointURL_ = "";
    // const QString replicator_username_ = "";
    // const QString replicator_password_ = "";

    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);

    bool stopRequested_ = false;
};

#endif // USERACCESSBROWSER_H
