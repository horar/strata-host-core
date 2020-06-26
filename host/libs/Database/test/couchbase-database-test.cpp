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
    db->open();
    CouchbaseDocument *doc = new CouchbaseDocument("Test Doc 1");

    // Doc must have valid pointer
    EXPECT_NE(doc, nullptr);
    // Set empty body (fail case)
    QString body = "";
    EXPECT_FALSE(doc->setBody(body));
    // Set invalid json (fail case)
    body = "123";
    EXPECT_FALSE(doc->setBody(body));
    // Set invalid json (fail case)
    body = "Not a Json";
    EXPECT_FALSE(doc->setBody(body));
    // Set invalid json (fail case)
    body = R"foo({"name": "My Name", "age" : 50, "myobj")foo";
    EXPECT_FALSE(doc->setBody(body));
    // Set valid json
    body = R"foo({"name": "My Name", "age" : 50, "myobj" : { "myarray" : [1,2,3,4], "mykey" : "myvalue"}})foo";
    EXPECT_TRUE(doc->setBody(body));
    // Retrieve values (not saved)
    auto result_str = db->getDocumentAsStr("Test Doc 1");
    EXPECT_EQ(result_str, "");
    // Save Test Doc 1 to DB and retrieve values
    db->save(doc);
    result_str = db->getDocumentAsStr("Test Doc 1");
    EXPECT_NE(result_str, "");
    auto result_obj = db->getDocumentAsJsonObj("Test Doc 1");
    EXPECT_TRUE(result_obj.contains("name"));
    EXPECT_TRUE(result_obj.contains("age"));

    delete doc;
    delete db;
}

void CouchbaseDatabaseTest::SetUp() {
}

void CouchbaseDatabaseTest::TearDown() {
}
