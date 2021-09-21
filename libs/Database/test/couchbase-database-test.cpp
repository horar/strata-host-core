/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "couchbase-database-test.h"

#include "Database/DatabaseLib.h"
#include "Database/CouchbaseDocument.h"
#include "../src/CouchbaseDatabase.h"

#include <QDir>
#include <QObject>
#include <QJsonObject>
#include <QCoreApplication>

#include <thread>
#include <iostream>

using namespace strata::Database;

// Need valid replicator info to run replication tests
#define Test_Replication false

// Replicator URL endpoint, username, password, and channels to replicate
#if Test_Replication
    const QString replicator_url = "ws://localhost:4984/strata-db";
    const QString replicator_username = "";
    const QString replicator_password = "";
    const QStringList replicator_channels = {};
#endif

TEST_F(CouchbaseDatabaseTest, OPEN_DB) {
    DatabaseLib *db_1 = new DatabaseLib("Test Database 1");
    DatabaseLib *db_2 = new DatabaseLib("Test Database 2", "Invalid path");
    DatabaseLib *db_3 = new DatabaseLib("Test Database 3", QDir::currentPath());
    DatabaseLib *db_4 = new DatabaseLib("");

    // DB must have valid pointer
    EXPECT_NE(db_1, nullptr);
    // Open DB
    EXPECT_TRUE(db_1->open());
    // Check DB name
    EXPECT_EQ(db_1->getDatabaseName(), "Test Database 1");
    // Get documents of empty DB
    EXPECT_TRUE(db_1->getAllDocumentKeys().isEmpty());

    // DB must have valid pointer
    EXPECT_NE(db_2, nullptr);
    // Open DB, expect false since path is invalid
    EXPECT_FALSE(db_2->open());

    // DB must have valid pointer
    EXPECT_NE(db_3, nullptr);
    // Open DB
    EXPECT_TRUE(db_3->open());
    // Check DB name
    EXPECT_EQ(db_3->getDatabaseName(), "Test Database 3");
    // Check DB path
    EXPECT_EQ(db_3->getDatabasePath(), QDir::currentPath());
    // Get documents of empty DB
    EXPECT_TRUE(db_3->getAllDocumentKeys().isEmpty());

    // DB must have valid pointer
    EXPECT_NE(db_4, nullptr);
    // Open DB, expect false since name is empty
    EXPECT_FALSE(db_4->open());

    delete db_1;
    delete db_2;
    delete db_3;
    delete db_4;
}

TEST_F(CouchbaseDatabaseTest, DOCS) {
    DatabaseLib *db = new DatabaseLib("Test Database 4");
    EXPECT_TRUE(db->open());
    CouchbaseDocument *doc_1 = new CouchbaseDocument("Test Doc 1");
    CouchbaseDocument *doc_2 = new CouchbaseDocument("Test Doc 2");

    // Docs must have valid pointer
    EXPECT_NE(doc_1, nullptr);
    EXPECT_NE(doc_2, nullptr);
    // Set empty body (fail case)
    QString body = "";
    EXPECT_FALSE(doc_1->setBody(body));
    // Set invalid json (fail case)
    body = "123";
    EXPECT_FALSE(doc_1->setBody(body));
    // Set invalid json (fail case)
    body = "Not a Json";
    EXPECT_FALSE(doc_1->setBody(body));
    // Set invalid json (fail case)
    body = R"foo({"name": "My Name", "age" : 1, "myobj")foo";
    EXPECT_FALSE(doc_1->setBody(body));
    // Set valid json
    body = R"foo({"name": "My Name", "age" : 1, "myobj" : { "myarray" : [1,2,3,4], "mykey" : "myvalue"}})foo";
    EXPECT_TRUE(doc_1->setBody(body));
    // Retrieve values (not saved, so expect empty response)
    auto result_str = db->getDocumentAsStr("Test Doc 1");
    EXPECT_EQ(result_str, "");
    // Save Test Doc 1 to DB and retrieve values
    EXPECT_TRUE(db->save(doc_1));
    auto doc_keys = db->getAllDocumentKeys();
    EXPECT_GE(doc_keys.size(), 1);
    auto doc1_key = doc_keys[0];

    result_str = db->getDocumentAsStr(doc1_key);
    EXPECT_NE(result_str, "");
    // Get document as a json object and test for keys
    auto result_obj = db->getDocumentAsJsonObj(doc1_key);

    EXPECT_TRUE(result_obj.contains("name"));
    EXPECT_TRUE(result_obj.contains("age"));
    EXPECT_EQ(result_obj.value("age"), 1);

    // Delete doc_1 from DB
    EXPECT_TRUE(db->deleteDoc(doc1_key));
    // DB is now empty
    EXPECT_EQ(db->getAllDocumentKeys().size(), 0);

    // Doc 2
    // Set valid json
    body = R"foo({"name": "My Name", "age" : 1})foo";
    EXPECT_TRUE(doc_2->setBody(body));
    result_obj = db->getDocumentAsJsonObj("Test Doc 2");
    EXPECT_EQ(result_obj.count(), 0);
    // Edit document key "age" value to 30
    (*doc_2)["age"] = 30;
    EXPECT_TRUE(db->save(doc_2));
    doc_keys = db->getAllDocumentKeys();
    EXPECT_GE(doc_keys.size(), 1);
    auto doc2_key = doc_keys[0];

    // Get value of key "age"
    result_obj = db->getDocumentAsJsonObj(doc2_key);
    EXPECT_EQ(result_obj.value("age"), 30);

    // Delete doc_2 from DB
    EXPECT_TRUE(db->deleteDoc(doc2_key));
    // DB is now empty
    EXPECT_EQ(db->getAllDocumentKeys().size(), 0);

    delete doc_1;
    delete doc_2;
    delete db;
}

#if Test_Replication
// This test is disabled by default, requires valid replicator information
TEST_F(CouchbaseDatabaseTest, REPLICATOR) {
    DatabaseLib *db_1 = new DatabaseLib("Test Database 5");
    DatabaseLib *db_2 = new DatabaseLib("Test Database 6");

    // Attempt to start replication (DB not open)
    EXPECT_FALSE(db_1->startBasicReplicator(replicator_url));
    // Open DB
    EXPECT_TRUE(db_1->open());
    // Attempt to start replication (empty endpoint)
    EXPECT_FALSE(db_1->startBasicReplicator(""));
    // Attempt to start replication (invalid endpoint)
    EXPECT_FALSE(db_1->startBasicReplicator("Invalid endpoint"));
    // Attempt to start replication (valid endpoint)
    EXPECT_TRUE(db_1->startBasicReplicator(replicator_url));
    // Wait until replication is finished
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (db_1->getReplicatorStatus() != "Stopped" && db_1->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (db_1->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            db_1->stopReplicator();
            FAIL();
            break;
        }
    }
    // Retrieve all document keys, expect at least one document replicated
    QStringList keys = db_1->getAllDocumentKeys();
    EXPECT_TRUE(keys.size() > 0);

    // Define custom listeners
    auto changeListener = [](cbl::Replicator, const DatabaseAccess::ActivityLevel) {
        std::cout << "CouchbaseDatabase TEST changeListener -> replication status changed!" << std::endl;
    };

    auto documentListener = [](cbl::Replicator, bool, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>>) {
        std::cout << "CouchbaseDatabase TEST documentListener -> document status changed!" << std::endl;
    };

    // Open DB
    EXPECT_TRUE(db_2->open());
    // Attempt to start replication using all possible inputs
    EXPECT_TRUE(db_2->startBasicReplicator(replicator_url, replicator_username, replicator_password, replicator_channels, "pull", changeListener, documentListener));
    // Wait until replication is finished
    retries = 0;
    while (db_2->getReplicatorStatus() != "Stopped" && db_2->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (db_2->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            db_2->stopReplicator();
            FAIL();
            break;
        }
    }
    // Retrieve all document keys, expect at least one document replicated
    keys = db_2->getAllDocumentKeys();
    EXPECT_TRUE(keys.size() > 0);

    delete db_1;
    delete db_2;
}
#endif // end if Test_Replication

CouchbaseDatabaseTest::CouchbaseDatabaseTest()
{
}

void CouchbaseDatabaseTest::SetUp() {
}

void CouchbaseDatabaseTest::TearDown() {
    #if !Test_Replication
        std::cout << "\nWARNING:\nTest executed with replication/sync gateway testing disabled. \
        \nEnter valid replication information and enable replication testing if desired.\n\n";
    #endif
}
