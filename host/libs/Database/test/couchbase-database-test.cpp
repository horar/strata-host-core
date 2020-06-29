#include "couchbase-database-test.h"

#include "Database.h"

#include <QDir>
#include <QObject>
#include <QCoreApplication>

#include <iostream>

CouchbaseDatabaseTest::CouchbaseDatabaseTest()
{
}

TEST_F(CouchbaseDatabaseTest, OPEN_DB) {
    Database *db = new Database("Test Database 1");

    // DB must have valid pointer
    EXPECT_NE(db, nullptr);
    // Open DB
    EXPECT_TRUE(db->open());
    // Check DB name
    EXPECT_EQ(db->getDatabaseName(), "Test Database 1");
    // Get documents of empty DB
    EXPECT_TRUE(db->getAllDocumentKeys().isEmpty());

    delete db;
}

TEST_F(CouchbaseDatabaseTest, DOCS) {
    Database *db = new Database("Test Database 2");
    EXPECT_TRUE(db->open());
    CouchbaseDocument *doc_1 = new CouchbaseDocument("Test Doc 1");
    CouchbaseDocument *doc_2 = new CouchbaseDocument("Test Doc 2");

    // Doc 1
    // Doc must have valid pointer
    EXPECT_NE(doc_1, nullptr);
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
    // Retrieve values (not saved)
    auto result_str = db->getDocumentAsStr("Test Doc 1");
    EXPECT_EQ(result_str, "");
    // Save Test Doc 1 to DB and retrieve values
    EXPECT_TRUE(db->save(doc_1));
    result_str = db->getDocumentAsStr("Test Doc 1");
    EXPECT_NE(result_str, "");
    // Get document as a json object and test for keys
    auto result_obj = db->getDocumentAsJsonObj("Test Doc 1");
    EXPECT_TRUE(result_obj.contains("name"));
    EXPECT_TRUE(result_obj.contains("age"));
    EXPECT_EQ(result_obj.value("age"), 1);

    // Doc 2
    // Set valid json
    body = R"foo({"name": "My Name", "age" : 1})foo";
    EXPECT_TRUE(doc_2->setBody(body));
    // Get value of key "age"
    result_obj = db->getDocumentAsJsonObj("Test Doc 2");
    EXPECT_EQ(result_obj.count(), 0);
    // Edit document key "age" value to 30
    (*doc_2)["age"] = 30;
    EXPECT_TRUE(db->save(doc_2));
    // Get value of key "age"
    result_obj = db->getDocumentAsJsonObj("Test Doc 2");
    EXPECT_EQ(result_obj.value("age"), 30);

    // Retrieve all document keys
    QStringList keys = db->getAllDocumentKeys();
    EXPECT_EQ(keys.size(), 2);
    EXPECT_TRUE(keys.contains("Test Doc 1"));
    EXPECT_TRUE(keys.contains("Test Doc 2"));

    // Delete Doc 1, check only Doc 2 exists
    db->deleteDoc("Test Doc 1");
    keys = db->getAllDocumentKeys();
    EXPECT_FALSE(keys.contains("Test Doc 1"));
    EXPECT_TRUE(keys.contains("Test Doc 2"));
    EXPECT_EQ(keys.size(), 1);

    // Delete Doc 2, check DB is empty
    db->deleteDoc("Test Doc 2");
    keys = db->getAllDocumentKeys();
    EXPECT_FALSE(keys.contains("Test Doc 1"));
    EXPECT_FALSE(keys.contains("Test Doc 2"));
    EXPECT_EQ(keys.size(), 0);

    delete doc_1;
    delete doc_2;
    delete db;
}

void CouchbaseDatabaseTest::SetUp() {
}

void CouchbaseDatabaseTest::TearDown() {
}
