#include "UserAccessBrowser.h"
#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDebug>

UserAccessBrowser::UserAccessBrowser(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
}

void UserAccessBrowser::getUserAccessMap(const QString &endpointURL) {
    DatabaseManager databaseManager;
    auto userAccessDB = databaseManager.open("user_access_map", "user_access_map");

    // Object valid if database open successful
    if (userAccessDB) {
        qDebug() << "Successfully opened database. Path: " << userAccessDB->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return;
    }

    auto changeListener = [this, userAccessDB](cbl::Replicator, const CBLReplicatorStatus status) {
        qDebug() << "CouchbaseDatabaseSampleApp changeListener -> replication status changed!";
        if (status.activity == kCBLReplicatorIdle) {
            auto db_obj = userAccessDB->getDatabaseAsJsonObj();
            emit userAccessMapReceived(db_obj);
        }
    };

    // Start replicator
    if (userAccessDB->startReplicator(endpointURL, "", "", "pull", changeListener, nullptr, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL << "is valid.";
    }
}

void UserAccessBrowser::loginAndStartReplication(const QString &strataLoginUsername, const QStringList &strataChannelList, const QString &endpointURL) {
    // Open database, provide desired username and chatroom
    DatabaseManager databaseManager;
    DB_ = databaseManager.open(strataLoginUsername, strataChannelList);

    // Object valid if database open successful
    if (DB_) {
        qDebug() << "Successfully opened database. Path: " << DB_->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return;
    }

    strataLoginUsername_ = strataLoginUsername;
    endpointURL_ = endpointURL;
    dbDirName_ = databaseManager.getDbDirName();

    auto changeListener = [this](cbl::Replicator, const CBLReplicatorStatus status) {
        qDebug() << "Couchbase UserAccessBrowser changeListener -> replication status changed!";
        if (status.activity == kCBLReplicatorIdle) {
            auto db_obj = DB_->getDatabaseAsJsonObj();
            emit statusUpdated(db_obj.size());
        }
    };

    // Start replicator
    if (DB_->startReplicator(endpointURL_, "", "", "pull", changeListener, nullptr, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL_ << "is valid.";
    }
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
