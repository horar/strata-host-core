#include "CouchChat.h"
#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDebug>
#include <iostream>
#include <thread>

CouchChat::CouchChat(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;

    DatabaseManager databaseManager;

    std::string user_name, channel_name;
    std::cout << "\nWelcome to chat, enter your username: ";
    std::cin >> user_name;
    std::cout << "Enter desired chat room: ";
    std::cin >> channel_name;

    user_name_ = QString::fromStdString(user_name);
    channel_name_ = QString::fromStdString(channel_name);

    // Open database, provide desired username and chatroom
    DB_ = databaseManager.open(QString::fromStdString(channel_name), QString::fromStdString(user_name));

    // Object valid if database open successful
    if (DB_) {
        qDebug() << "Successfully opened database. Path: " << DB_->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return;
    }

    // Get database name and channel access name
    qDebug() << "Database name: " << DB_->getDatabaseName();
    qDebug() << "DB_ channel access: " << DB_->getChannelAccess();

    auto changeListener = [](cbl::Replicator, const CBLReplicatorStatus) {
        qDebug() << "CouchbaseDatabaseSampleApp changeListener -> replication status changed!";
    };

    auto documentListener = [this](cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
        qDebug() << "CouchbaseDatabaseSampleApp documentListener -> document status changed!";
        qDebug() << "---" << documents.size() << "docs" << (isPush ? "pushed:" : "pulled:");
        for (unsigned i = 0; i < documents.size(); ++i) {
            qDebug() << documents[i].ID;
            auto result_str = DB_->getDocumentAsStr(documents[i].ID);
            qDebug() << "Document '" << documents[i].ID << "' contents:" << result_str;
            emit receivedMessage(result_str);

            // qDebug() << "\n\nEMITTED MESSAGE TO UI:: " << result_str << "\n\n";
        }
    };

    // Start replicator
    if (DB_->startReplicator(replicator_url, replicator_username, replicator_password, "pushandpull", changeListener, documentListener, true)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << replicator_url << "is valid.";
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
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << replicator_url << "is valid.";
            break;
        }
    }
}

void CouchChat::sendMessage(QString message) {
    CouchbaseDocument Doc("CouchChat_Message");

    // Set document body with valid JSON
    QString body_string = "{\"msg\":\"" + message + "\"}";
    if (Doc.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    // Write document to database
    if (DB_->write(&Doc)) {
        qDebug() << "Successfully saved to database document with msg:" << message;
    } else {
        qDebug() << "Error saving database.";
        return;
    }
}
