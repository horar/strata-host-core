/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <thread>

#include "Database/DatabaseLib.h"
#include "Database/CouchbaseDocument.h"
#include "../src/CouchbaseDatabase.h"

#include <QDir>
#include <QDebug>
#include <QJsonValue>
#include <QJsonObject>
#include <QStandardPaths>

using namespace strata::Database;

#define DEBUG(...) printf("Database: "); printf(__VA_ARGS__); printf("\n");

// Replicator URL endpoint
const QString replicator_url = "ws://10.0.0.157:4984/strata-db";
const QString replicator_username = "";
const QString replicator_password = "";
const QStringList replicator_channels = {};

int main() {
    /********************************************
     * MAIN CRUD OPERATIONS *
     *******************************************/

    // Default DB location will be the current location
    DatabaseLib DB_1("Sample Database 1");

    // Open DB 1
    if (DB_1.open()) {
        qDebug() << "Database 1 will be stored in: " << DB_1.getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return -1;
    }

    // Get database name
    qDebug() << "Database name is: " << DB_1.getDatabaseName();

    // Create a document "Doc_1"
    CouchbaseDocument Doc_1("Doc_1");

    // Set document body (Fail case: must be in valid JSON format)
    QString body_string;
    body_string = "NOT A JSON!";
    if (!Doc_1.setBody(body_string)) {
        DEBUG("Failed to set document contents, body must be in JSON format.");
    } else {
        DEBUG("Successfully set document contents.");
    }

    // Set document body with valid JSON
    body_string = R"foo({"name": "My Name", "age" : 1, "myobj" : { "myarray" : [1,2,3,4], "mykey" : "myvalue"}})foo";
    if (!Doc_1.setBody(body_string)) {
        DEBUG("Failed to set document contents, body must be in JSON format.");
    } else {
        DEBUG("Successfully set document contents.");
    }

    // Save "Doc_1" to DB
    DB_1.save(&Doc_1);

    // Retrieve contents of "Doc_1" in JSON format (QString)
    QString result_str = DB_1.getDocumentAsStr("Doc_1");
    qDebug() << "Document contents: " << result_str;

    // Create a document "Doc_2" on DB 1
    CouchbaseDocument Doc_2("Doc_2");
    body_string = R"foo({"name": "My Other Name", "age" : 1})foo";
    if (!Doc_2.setBody(body_string)) {
        DEBUG("Failed to set document contents, body must be in JSON format.");
    } else {
        DEBUG("Successfully set document contents.");
    }

    // Modify key "age" with value 1 to 30 on "Doc_2"
    Doc_2["age"] = 30;

    // Save "Doc_2" to DB 1
    DB_1.save(&Doc_2);

    // Get all document keys in a QStringList
    auto document_keys = DB_1.getAllDocumentKeys();
    DEBUG("All document keys:");
    qDebug() << document_keys;

    // Retrieve contents of "Doc_1" in JSON format (QJsonObject)
    auto result_obj = DB_1.getDocumentAsJsonObj("Doc_1");
    DEBUG("Doc_1 as a Json Object:");
    foreach(const QString& key, result_obj.keys()) {
        QJsonValue value = result_obj.value(key);
        qDebug() << "Key =" << key << ", value =" << value;
    }

    // Retrieve entire DB as a QJsonObject
    auto db_obj = DB_1.getDatabaseAsJsonObj();
    DEBUG("Entire DB as a Json Object:");
    foreach(const QString& key, db_obj.keys()) {
        QJsonValue value = db_obj.value(key);
        qDebug() << "Key =" << key << ", value =" << value;
    }

    // Delete document "Doc_2"
    DB_1.deleteDoc("Doc_2");

    // Get all document keys in a QStringList
    document_keys = DB_1.getAllDocumentKeys();
    DEBUG("All document keys:");
    qDebug() << document_keys;

    /********************************************
     * REPLICATOR API *
     *******************************************/

    // DB location can be given as a QString argument
    QDir dir;
    const QString documentsPath = dir.absolutePath();

    DatabaseLib DB_2("Sample Database 2", documentsPath);

    // Open DB 2
    if (DB_2.open()) {
        qDebug() << "Database 2 will be stored in: " << DB_2.getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return -1;
    }

    // Start replicator on DB 2 with all default arguments
    if (DB_2.startBasicReplicator(replicator_url)) {
        DEBUG("Replicator successfully started.");
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << replicator_url << "is valid.";
    }

    // Wait until replication is finished
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));

    // Display all document keys
    document_keys = DB_2.getAllDocumentKeys();
    qDebug() << "\nAll document keys of DB 2 after replication: " << document_keys << "\n";

    DatabaseLib DB_3("Sample Database 3", documentsPath);

    // Open DB 3
    if (DB_3.open()) {
        qDebug() << "Database 3 will be stored in: " << DB_3.getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return -1;
    }

    // Start replicator on DB 3 with all non-default options
    auto changeListener = [](cbl::Replicator, const DatabaseAccess::ActivityLevel) {
        qDebug() << "CouchbaseDatabaseSampleApp changeListener -> replication status changed!\n";
    };

    auto documentListener = [](cbl::Replicator, bool, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>>) {
        qDebug() << "CouchbaseDatabaseSampleApp documentListener -> document status changed!\n";
    };

    if (DB_3.startBasicReplicator(replicator_url, replicator_username, replicator_password, replicator_channels, "pull", changeListener, documentListener)) {
        DEBUG("Replicator successfully started.");
    } else {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << replicator_url << "is valid.";
    }

    // Wait until replication is finished
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (DB_3.getReplicatorStatus() != "Stopped" && DB_3.getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (DB_3.getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            DB_3.stopReplicator();
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << replicator_url << "is valid.";
            break;
        }
    }

    // Display all document keys
    document_keys = DB_3.getAllDocumentKeys();
    qDebug() << "\nAll document keys of DB 3 after replication: " << document_keys << "(" << document_keys.size() << "documents in total).\n";

    DB_3.stopReplicator();
    return 0;
}
