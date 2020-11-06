#include "CouchChat.h"
#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDebug>
#include <iostream>
#include <thread>

CouchChat::CouchChat(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
}

void CouchChat::loginAndStartReplication(const QString &user_name, const QString &channel_name, const QString &endpoint_url) {
    user_name_ = user_name;
    channel_name_ = channel_name;
    endpoint_url_ = endpoint_url;
    usernameChanged();
    channelChanged();

    // Open database, provide desired username and chatroom
    DatabaseManager databaseManager;
    DB_ = databaseManager.open(channel_name, user_name);

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
            auto result_obj = DB_->getDocumentAsJsonObj(documents[i].ID);

            auto msg = result_obj.value("msg");
            auto msg_str = msg.toString();

            auto user = result_obj.value("user");
            auto user_str = user.toString();

            emit receivedMessage(user_str, msg_str);
        }
    };

    // Start replicator
    if (DB_->startReplicator(endpoint_url_, replicator_username_, replicator_password_, "pushandpull", changeListener, documentListener, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpoint_url_ << "is valid.";
    }

    // Wait until replication is connected
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (DB_->getReplicatorStatus() != "Stopped" && DB_->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (DB_->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            DB_->stopReplicator();
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << endpoint_url_ << "is valid.";
            break;
        }
    }
}

void CouchChat::sendMessage(const QString &message) {
    CouchbaseDocument Doc("CouchChat_Message");

    QString body_string("{\"msg\":\"" + message + "\","
        "\"user\":\"" + user_name_ + "\"}");

    if (Doc.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    if (DB_->write(&Doc)) {
        qDebug() << "Successfully saved to database document with msg:" << message;
    } else {
        qDebug() << "Error saving database.";
        return;
    }
}

void CouchChat::logoutAndStopReplication() {
    DB_->stopReplicator();
}
