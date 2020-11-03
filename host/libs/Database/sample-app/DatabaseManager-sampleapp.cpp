#include <thread>

#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDir>
#include <QDebug>
#include <QStandardPaths>

// Replicator URL endpoint
const QString replicator_url = "ws://localhost:4984/user-access-test";
const QString replicator_username = "";
const QString replicator_password = "";

int main() {
    // Open database manager
    DatabaseManager databaseManager;

    // Open database, provide channel for connection (external channel ID)
    auto DB_NDA = databaseManager.open("external_channel_1");

    // Object valid if database open successful
    if (DB_NDA) {
        qDebug() << "Successfully opened database. Path: " << DB_NDA->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return -1;
    }

    // Get database name and channel access name
    qDebug() << "Database name: " << DB_NDA->getDatabaseName();
    qDebug() << "DB_NDA channel access: " << DB_NDA->getChannelAccess();

    // Create a document
    CouchbaseDocument Doc("My_Doc");

    // Set document body with valid JSON
    QString body_string = R"foo({"name": "My Name", "age" : 1, "myobj" : { "myarray" : [1,2,3,4], "mykey" : "myvalue"}})foo";
    if (Doc.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    // Write document to database
    if (DB_NDA->write(&Doc)) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }

    // Retrieve entire DB as a QJsonObject
    auto db_obj = DB_NDA->getDatabaseAsJsonObj();
    qDebug() << "Entire DB as a Json Object:";
    foreach(const QString& key, db_obj.keys()) {
        QJsonValue value = db_obj.value(key);
        qDebug() << "Key =" << key << ", value =" << value;
    }

    // Start replicator
    if (DB_NDA->startReplicator(replicator_url, replicator_username, replicator_password, "pushandpull")) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << replicator_url << "is valid.";
    }

    // Wait until replication is finished
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (DB_NDA->getReplicatorStatus() != "Stopped" && DB_NDA->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (DB_NDA->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            DB_NDA->stopReplicator();
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << replicator_url << "is valid.";
            break;
        }
    }

    return 0;
}