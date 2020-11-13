#include "UserAccessBrowser.h"
#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDebug>
#include <thread>

UserAccessBrowser::UserAccessBrowser(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
}

void UserAccessBrowser::loginAndStartReplication(const QString &strataLoginUsername, const QStringList &strataChannelList, const QString &endpointURL) {
    strataLoginUsername_ = strataLoginUsername;
    endpointURL_ = endpointURL;
    stopRequested_ = false;

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

    auto changeListener = [this](cbl::Replicator, const CBLReplicatorStatus) {
        if (!stopRequested_) {
            qDebug() << "CouchbaseDatabaseSampleApp changeListener -> replication status changed!";
            auto db_obj = DB_->getDatabaseAsJsonObj();
            emit statusUpdated(db_obj.size());
        }
    };

    auto documentListener = [](cbl::Replicator, bool, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>>) {
        qDebug() << "CouchbaseDatabaseSampleApp documentListener -> document status changed!";
    };

    // Start replicator
    if (DB_->startReplicator(endpointURL_, "", "", "pull", changeListener, documentListener, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL_ << "is valid.";
    }

    // Wait until replication is connected
    unsigned int retries = 0;
    while (DB_->getReplicatorStatus() != "Stopped" && DB_->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (DB_->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            DB_->stopReplicator();
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << endpointURL_ << "is valid.";
            break;
        }
    }
}

void UserAccessBrowser::logoutAndStopReplication() {
    stopRequested_ = true;
    strataLoginUsername_ = "";
    endpointURL_ = "";
    DB_->close();
}

QStringList UserAccessBrowser::getAllDocumentIDs() {
    return DB_->getDatabaseAsJsonObj().keys();
}
