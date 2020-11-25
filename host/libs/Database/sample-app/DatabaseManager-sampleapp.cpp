#include <thread>

#include "DatabaseManager.h"
#include "CouchbaseDocument.h"

#include <QDir>
#include <QDebug>
#include <QStandardPaths>

// Replicator URL endpoint
const QString replicator_url = "ws://localhost:4984/platform-list";
const QString replicator_username = "";
const QString replicator_password = "";

int main() {
    // Open database manager
    DatabaseManager databaseManager;

    // Open database
    // auto DB_all_channels = databaseManager.open("Sample_User");

    // Open database, provide QStringList of channels for connection
    QStringList channel_ls = {"channel_A", "channel_B"};
    auto DB_all_channels = databaseManager.open("Sample_User", channel_ls);

    // Object valid if database open successful
    if (DB_all_channels) {
        qDebug() << "Successfully opened database. Path: " << DB_all_channels->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return -1;
    }

    // Get database name
    qDebug() << "Database name: " << DB_all_channels->getDatabaseName();

    // Create document 1, write to all buckets
    CouchbaseDocument Doc1("My_Doc_All_Buckets");
    QString body_string = R"foo({"StrataTest": "Contents_1"})foo";

    if (Doc1.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    if (DB_all_channels->write(&Doc1)) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }

    // Create document 2, write to bucket 'channel_A' only
    CouchbaseDocument Doc2("My_Doc_Single_Bucket");
    body_string = R"foo({"StrataTest": "Contents_2"})foo";

    if (Doc2.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    if (DB_all_channels->write(&Doc2, "channel_A")) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }
/*
    // Create document 3, write to buckets 'channel_A', 'channel_B'
    CouchbaseDocument Doc3("My_Doc_Two_Buckets");
    body_string = R"foo({"StrataTest": "Contents_3"})foo";

    if (Doc3.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    // channel_ls = {"channel_A", "channel_B"};
    if (DB_all_channels->write(&Doc3, channel_ls)) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }
*/
    // Retrieve entire DB as a QJsonObject
    auto db_obj = DB_all_channels->getDatabaseAsJsonObj();
    qDebug() << "Entire DB as a Json Object:";
    foreach(const QString& key, db_obj.keys()) {
        QJsonValue value = db_obj.value(key);
        qDebug() << "Key =" << key << ", value =" << value;
    }

    // Start replicator
    if (DB_all_channels->startReplicator(replicator_url, replicator_username, replicator_password)) {
        qDebug() << "Replicator successfully started.";
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << replicator_url << "is valid.";
    }

    // Wait until replication is finished
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (DB_all_channels->getReplicatorStatus() != "Stopped" && DB_all_channels->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (DB_all_channels->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            DB_all_channels->stopReplicator();
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << replicator_url << "is valid.";
            break;
        }
    }

    return 0;
}
