#include "UserAccessBrowser.h"
#include "DatabaseManager.h"
#include "DatabaseAccess.h"
#include "CouchbaseDocument.h"

#include <QDebug>

UserAccessBrowser::UserAccessBrowser(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
    auto changeListenerCallback = std::bind(&UserAccessBrowser::changeListener, this, std::placeholders::_1, std::placeholders::_2);
    databaseManager_ = std::make_unique<DatabaseManager>("", endpointURL_, changeListenerCallback);
}

void UserAccessBrowser::login(const QString &loginUsername) {
    auto changeListenerCallback = std::bind(&UserAccessBrowser::changeListener, this, std::placeholders::_1, std::placeholders::_2);
    DB_ = databaseManager_->login(loginUsername, "all", changeListenerCallback);

    loginUsername_ = loginUsername;
}

void UserAccessBrowser::joinChannel(const QString &loginUsername, const QString &channel) {
    databaseManager_->joinChannel(loginUsername, channel);
}

void UserAccessBrowser::leaveChannel(const QString &loginUsername, const QString &channel) {
    databaseManager_->leaveChannel(loginUsername, channel);
}

void UserAccessBrowser::logout() {
    loginUsername_ = "";
    endpointURL_ = "";
    DB_->close();
    delete DB_;
}

void UserAccessBrowser::clearUserDir(const QString &loginUsername) {
    DB_->clearUserDir(loginUsername, databaseManager_->getDbDirName());
}

void UserAccessBrowser::changeListener(cbl::Replicator, const CBLReplicatorStatus &status) {
    if (databaseManager_ && status.activity == kCBLReplicatorIdle) {
        auto allChannelsGranted = databaseManager_->readChannelsAccessGrantedOfUser(loginUsername_);
        auto allChannelsDenied = databaseManager_->readChannelsAccessDeniedOfUser(loginUsername_);
        auto allDocumentIDs = getAllDocumentIDs();
        emit receivedDbContents(allChannelsGranted, allChannelsDenied, allDocumentIDs);
    }
}

QStringList UserAccessBrowser::getAllDocumentIDs() {
    if (DB_) {
        return DB_->getDatabaseAsJsonObj().keys();
    } else {
        return QStringList();
    }
}
