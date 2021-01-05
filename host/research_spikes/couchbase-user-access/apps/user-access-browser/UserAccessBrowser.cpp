#include "UserAccessBrowser.h"
#include "DatabaseManager.h"
#include "DatabaseAccess.h"
#include "CouchbaseDocument.h"

#include <QDebug>

UserAccessBrowser::UserAccessBrowser(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
    databaseManager_ = std::make_unique<DatabaseManager>();
}

void UserAccessBrowser::getUserAccessMap(const QString &endpointURL) {
    userAccessDB_ = databaseManager_->open("user_access_map", "user_access_map");

    // Object valid if database open successful
    if (userAccessDB_) {
        qDebug() << "Successfully opened database. Path: " << userAccessDB_->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open user_access_map.";
        return;
    }

    auto changeListener = [this](cbl::Replicator, const CBLReplicatorStatus status) {
        qDebug() << "CouchbaseDatabase UserAccessBrowser changeListener -> replication status changed!";
        if (status.activity == kCBLReplicatorIdle) {
            auto db_obj = userAccessDB_->getDatabaseAsJsonObj();
            emit userAccessMapReceived(db_obj);
        }
    };

    // Start replicator (push and pull for user access map)
    if (userAccessDB_->startReplicator(endpointURL, "", "", "pushandpull", changeListener, nullptr, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL << "is valid.";
    }
}

void UserAccessBrowser::loginAndStartReplication(const QString &strataLoginUsername, const QStringList &strataChannelList, const QString &endpointURL) {
    DB_ = databaseManager_->open(strataLoginUsername, strataChannelList);

    // Object valid if database open successful
    if (DB_) {
        qDebug() << "Successfully opened database. Path: " << DB_->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return;
    }

    strataLoginUsername_ = strataLoginUsername;
    endpointURL_ = endpointURL;
    dbDirName_ = databaseManager_->getDbDirName();

    auto changeListener = [this](cbl::Replicator, const CBLReplicatorStatus status) {
        qDebug() << "CouchbaseDatabase UserAccessBrowser changeListener -> replication status changed!";
        if (status.activity == kCBLReplicatorIdle) {
            auto db_obj = DB_->getDatabaseAsJsonObj();
            emit statusUpdated(db_obj.size());
        }
    };

    // Start replicator (pull only for user DBs)
    if (DB_->startReplicator(endpointURL_, "", "", "pull", changeListener, nullptr, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL_ << "is valid.";
    }
}

void UserAccessBrowser::joinChannel(const QString &strataLoginUsername, const QString &channel) {
    userAccessDB_->joinChannel(strataLoginUsername, channel);
}

void UserAccessBrowser::leaveChannel(const QString &strataLoginUsername, const QString &channel) {
    userAccessDB_->leaveChannel(strataLoginUsername, channel);
}

void UserAccessBrowser::logoutAndStopReplication() {
    strataLoginUsername_ = "";
    endpointURL_ = "";
    DB_->close();
}

void UserAccessBrowser::clearUserDir(const QString &strataLoginUsername) {
    DatabaseManager tempMgr;
    DB_->clearUserDir(strataLoginUsername, tempMgr.getDbDirName());
}

QStringList UserAccessBrowser::getAllDocumentIDs() {
    return DB_->getDatabaseAsJsonObj().keys();
}
