#include "UserAccessBrowser.h"
#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDebug>
#include <thread>

UserAccessBrowser::UserAccessBrowser(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
}

void UserAccessBrowser::loginAndStartReplication(const QString &strataLoginUsername, const QString &endpointURL) {
    strataLoginUsername_ = strataLoginUsername;
    endpointURL_ = endpointURL;

    // Open database, provide desired username and chatroom
    DatabaseManager databaseManager;
    DB_ = databaseManager.open(strataLoginUsername);

    // Object valid if database open successful
    if (DB_) {
        qDebug() << "Successfully opened database. Path: " << DB_->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return;
    }

    auto changeListener = [](cbl::Replicator, const CBLReplicatorStatus) {
        qDebug() << "CouchbaseDatabaseSampleApp changeListener -> replication status changed!";
    };

    auto documentListener = [this](cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
        qDebug() << "CouchbaseDatabaseSampleApp documentListener -> document status changed!";
        qDebug() << "---" << documents.size() << "docs" << (isPush ? "pushed:" : "pulled:");
        for (unsigned i = 0; i < documents.size(); ++i) {
            qDebug() << documents[i].ID;
            emit receivedMessage(documents[i].ID);
        }
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

// void UserAccessBrowser::sendMessage(const QString &message) {
//     CouchbaseDocument Doc("UserAccessBrowser_Message");

//     QString body_string("{\"msg\":\"" + message + "\","
//         "\"user\":\"" + user_name_ + "\"}");

//     if (Doc.setBody(body_string)) {
//         qDebug() << "Successfully set document contents.";
//     } else {
//         qDebug() << "Failed to set document contents, body must be in JSON format.";
//     }

//     if (DB_->write(&Doc)) {
//         qDebug() << "Successfully saved to database document with msg:" << message;
//     } else {
//         qDebug() << "Error saving database.";
//         return;
//     }
// }

void UserAccessBrowser::logoutAndStopReplication() {
    DB_->stopReplicator();
    DB_->close();
    strataLoginUsername_ = "";
    endpointURL_ = "";
}
