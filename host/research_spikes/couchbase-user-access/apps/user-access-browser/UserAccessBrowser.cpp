#include "UserAccessBrowser.h"
#include "../src/CouchbaseDatabase.h"

#include <QDebug>

using namespace strata::Database;

UserAccessBrowser::UserAccessBrowser(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
    auto changeListenerCallback = std::bind(&UserAccessBrowser::changeListener, this, std::placeholders::_1);

    databaseManager_ = std::make_unique<DatabaseManager>();
    if (databaseManager_->init("", endpointURL_, changeListenerCallback) == false) {
        qDebug() << "Error with initialization of database manager. Verify endpoint URL" << endpointURL_ << "is valid.";
    }
}

void UserAccessBrowser::login(const QString &loginUsername) {
    auto changeListenerCallback = std::bind(&UserAccessBrowser::changeListener, this, std::placeholders::_1);
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

void UserAccessBrowser::changeListener(const DatabaseAccess::ActivityLevel &status) {
    if (databaseManager_ && status == DatabaseAccess::ActivityLevel::ReplicatorIdle) {
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
