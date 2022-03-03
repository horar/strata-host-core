/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <thread>

#include "Database/DatabaseManager.h"
#include "Database/CouchbaseDocument.h"
#include "../src/CouchbaseDatabase.h"

#include <QDir>
#include <QDebug>
#include <QStandardPaths>

using namespace strata::Database;

// Replicator URL endpoint
const QString endpointURL = "ws://10.0.0.157:4984/platform-list";
const QString endpointUsername = "user_public";

int main() {
    // Open database manager
    auto changeListener = [](const DatabaseAccess::ActivityLevel) {
        qDebug() << "DatabaseManager-sampleapp changeListener -> replication status changed!";
    };

    auto databaseManager = std::make_unique<DatabaseManager>();
    if (databaseManager->init("", endpointURL, changeListener) == false) {
        qDebug() << "Error with initialization of database manager. Verify endpoint URL" << endpointURL << "is valid.";
        return -1;
    }

    // Wait until user_access_map replication is finished
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (databaseManager->getUserAccessReplicatorStatus() != "Stopped" && databaseManager->getUserAccessReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (databaseManager->getUserAccessReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << endpointURL << "is valid.";
            return -1;
        }
    }

    // Open database, provide QStringList of channels for connection
    QStringList channels = {"channel_public"};
    auto DB = databaseManager->login(endpointUsername, channels, changeListener);

    // Object valid if database open successful
    if (DB) {
        qDebug() << "Successfully opened database. Path: " << DB->getDatabasePath();
    } else {
        qDebug() << "Error: Failed to open database.";
        return -1;
    }

    // Print channels granted to user
    channels = databaseManager->readChannelsAccessGrantedOfUser(endpointUsername);
    qDebug() << "Channels:" << channels;

    // Get database name
    qDebug() << "Database name:" << DB->getDatabaseName();

    // Create document 1, write to all buckets
    CouchbaseDocument Doc1("My_Doc_All_Buckets");
    QString body_string = R"foo({"StrataTest": "Contents_1"})foo";

    if (Doc1.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    if (DB->write(&Doc1, "*")) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }

    // Create document 2, write to bucket 'channel_public' only
    CouchbaseDocument Doc2("My_Doc_Single_Bucket");
    body_string = R"foo({"StrataTest": "Contents_2"})foo";

    if (Doc2.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    if (DB->write(&Doc2, "channel_public")) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }

    // Create document 3, write to bucket 'channel_public'
    CouchbaseDocument Doc3("My_Doc_Two_Buckets");
    body_string = R"foo({"StrataTest": "Contents_3"})foo";

    if (Doc3.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
    }

    auto DB_2 = databaseManager->login(endpointUsername, "channel_public", changeListener);
    if (DB_2->write(&Doc3, "channel_public")) {
        qDebug() << "Successfully saved database.";
    } else {
        qDebug() << "Error saving database.";
        return -1;
    }

    // Retrieve entire DB as a QJsonObject
    auto db_obj = DB->getDatabaseAsJsonObj();
    qDebug() << "Entire DB as a Json Object:";
    foreach(const QString& key, db_obj.keys()) {
        QJsonValue value = db_obj.value(key);
        qDebug() << "Key =" << key << ", value =" << value;
    }

    // Retrieve entire DB as a QJsonObject
    db_obj = DB_2->getDatabaseAsJsonObj();
    qDebug() << "Entire DB as a Json Object:";
    foreach(const QString& key, db_obj.keys()) {
        QJsonValue value = db_obj.value(key);
        qDebug() << "Key =" << key << ", value =" << value;
    }

    return 0;
}
