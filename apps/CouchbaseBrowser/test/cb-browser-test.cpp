/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "cb-browser-test.h"

#include "DatabaseImpl.h"
#include "ConfigManager.h"

#include <QDir>
#include <QObject>
#include <QCoreApplication>

#include <future>

#include <iostream>

using namespace fleece;
using namespace cbl;

// Need valid replicator info to run replication tests
#define Test_Replication false

TEST_F(DatabaseImplTest, CTOR)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    EXPECT_NE(db, nullptr);
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());

    delete db;
}

TEST_F(DatabaseImplTest, OPEN)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    // Should fail (empty file path)
    db->openDB("");
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());
    db->closeDB();
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());

    // Should fail (root dir)
    db->openDB("/");
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());

    // Should fail (not a DB file)
    db->openDB(DB_folder_path_);
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());
    EXPECT_FALSE(db->getListenStatus());
    db->closeDB();
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());
    EXPECT_FALSE(db->getListenStatus());
    db->closeDB();
    EXPECT_FALSE(db->isDBOpen());
}

TEST_F(DatabaseImplTest, CREATE)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    db->createNewDB("", "");
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());

    db->createNewDB(DB_folder_path_, " ");
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());

    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-1");
    EXPECT_TRUE(db->getDBStatus());
    EXPECT_TRUE(db->isDBOpen());
    EXPECT_EQ(db->getDBName(), "DB_AutomatedTest-1");
    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-1");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->closeDB();
    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-1");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    DatabaseImpl *db2 = new DatabaseImpl(nullptr, false);

    EXPECT_EQ(db2->getDBName(), "");
    db2->createNewDB(DB_folder_path_, "DB_AutomatedTest-1");
    EXPECT_FALSE(isJsonMsgSuccess(db2->getMessage()));
    db2->clearConfig();
    db2->closeDB();
    db2->createNewDB(QDir::separator(), "DB Name");
    EXPECT_FALSE(isJsonMsgSuccess(db2->getMessage()));

    db2->createNewDB(DB_folder_path_, "DB_AutomatedTest-2");

    delete db;
    delete db2;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-1.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
    dir.setPath(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-2.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}

TEST_F(DatabaseImplTest, CREATEDOC)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-3");
    db->createNewDoc("","");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    db->createNewDoc("doc","");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    db->createNewDoc("doc", "NOT A JSON");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{}");

    db->createNewDoc("doc", "{\"key\":\"value\"}");
    EXPECT_EQ(db->getDBName(), "DB_AutomatedTest-3");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{\"doc\":{\"key\":\"value\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->createNewDoc("doc", "{}");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->createNewDoc("doc", "");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->createNewDoc("doc2", "123");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->createNewDoc("doc2", "{\"array\":[\"a\",\"b\",\"c\"]}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    delete db;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-3.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}

TEST_F(DatabaseImplTest, EDITDOC)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-4");
    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    EXPECT_EQ(db->getDBName(), "DB_AutomatedTest-4");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{\"doc\":{\"name\":\"name1\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("doc", "", "{\"name\":\"name1\"}");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{\"doc\":{\"name\":\"name1\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("doc", "", "{\"name\":\"name2\"}");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{\"doc\":{\"name\":\"name2\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("", "newId", "body");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc(" ", "newId", "body");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("doc", "", "");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{\"doc\":{\"name\":\"name2\"}}");

    db->editDoc("doc", "newDoc", "");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{\"newDoc\":{\"name\":\"name2\"}}");

    db->deleteDoc("doc");
    db->deleteDoc("newDoc");
    db->editDoc("doc", "doc2", "body");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    delete db;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-4.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}

TEST_F(DatabaseImplTest, DELETEDOC)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-5");

    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{}");

    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->deleteDoc("doc");
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{}");

    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->editDoc("doc", "doc2", "");
    db->deleteDoc("doc");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->deleteDoc("doc2");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));
    EXPECT_EQ(db->getJsonDBContents().simplified().remove(' '), "{}");

    delete db;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-5.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}

TEST_F(DatabaseImplTest, SAVEAS)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-6");
    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->saveAs(DB_folder_path_, "DB_AutomatedTest-7");

    delete db;

    DatabaseImpl *db2 = new DatabaseImpl(nullptr, false);
    EXPECT_NE(db2, nullptr);
    db2->openDB(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-7.cblite2" +  QDir::separator() + "db.sqlite3");

    ASSERT_TRUE(db2->isDBOpen());
    EXPECT_TRUE(isJsonMsgSuccess(db2->getMessage()));
    EXPECT_EQ(db2->getJsonDBContents().simplified().remove(' '), "{\"doc\":{\"name\":\"name1\"}}");

    delete db2;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-6.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
    dir.setPath(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-7.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}

#if Test_Replication
TEST_F(DatabaseImplTest, STARTLISTENING)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);
    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-8");

    EXPECT_TRUE(db->isDBOpen());

    std::future<bool> rep_starter = std::async(std::launch::async, [&db, this]() {return db->startListening(url_, username_, password_);});
    rep_starter.wait();
    std::this_thread::sleep_for(std::chrono::seconds(2));

    EXPECT_TRUE(db->isDBOpen());
    EXPECT_TRUE(db->getListenStatus());
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    // Compare replication results against results obtained directly from the CBLite API
    CBLDatabaseConfiguration db_config;
    db_config.flags = kCBLDatabase_Create;
    std::string db_path_str = DB_folder_path_.toStdString();
    db_config.directory = db_path_str.c_str();
    db_config.encryptionKey->algorithm = kCBLEncryptionNone;
    Database *db2 = new Database("DB_AutomatedTest-9", db_config);

    EXPECT_TRUE(db2->valid());

    ReplicatorConfiguration config(*db2);
    config.endpoint.setURL(url_.toStdString().c_str());

    if(!username_.isEmpty() && !password_.isEmpty()) {
        config.authenticator.setBasic(username_.toStdString().c_str(), password_.toStdString().c_str());
    }

    config.replicatorType = kCBLReplicatorTypePull;
    Replicator replicator(config);

    replicator.start();
    while(replicator.status().activity != kCBLReplicatorStopped) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    std::cout << "Finished with activity = " << replicator.status().activity <<
        ", error = (" << replicator.status().error.domain << "/" << replicator.status().error.code << ")\n";

     // Get all Document ID's in the current database
    Query query(*db2, kCBLN1QLLanguage, "SELECT _id");
    ResultSet results = query.execute();
    QJsonDocument document_json;
    QJsonObject total_json_obj;
    std::string total_json_str;

    for(ResultSetIterator it = results.begin(); it != results.end(); ++it) {
        Result r = *it;
        slice value_sl = r.valueAtIndex(0).asString();
        Document d = db2->getMutableDocument(std::string(value_sl));
        Dict read_dict = d.properties();
        document_json = QJsonDocument::fromJson(QByteArray::fromStdString(read_dict.toJSONString()));
        total_json_obj.insert(QString::fromStdString(std::string(value_sl)), document_json.object());
    }

    total_json_str = QJsonDocument(total_json_obj).toJson().toStdString();

    EXPECT_EQ(db->getJsonDBContents().toStdString(), total_json_str);

    delete db;
    delete db2;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-8.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
    dir.setPath(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-9.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}

TEST_F(DatabaseImplTest, PUSHANDPULL)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    db->createNewDB(DB_folder_path_, "DB_AutomatedTest-10");
    EXPECT_TRUE(db->isDBOpen());

    // Add a document to this DB
    QString test_doc_id = "GTest_Testing_Doc";
    QString test_doc_key = "contents";
    QString test_doc_val = "This is the GTest Testing doc.";
    QString test_doc_body = "{\"" + test_doc_key + "\":\"" + test_doc_val + "\"}";

    db->createNewDoc(test_doc_id, test_doc_body);

    // With the first DB, start a pushing replicator
    std::future<bool> rep_starter = std::async(std::launch::async, [&db, this]() {return db->startListening(url_, username_, password_, "push");});
    rep_starter.wait();
    std::this_thread::sleep_for(std::chrono::seconds(2));

    EXPECT_TRUE(db->isDBOpen());
    EXPECT_TRUE(db->getListenStatus());
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->closeDB();
    EXPECT_FALSE(db->isDBOpen());

    delete db;

    DatabaseImpl *db2 = new DatabaseImpl(nullptr, false);

    db2->createNewDB(DB_folder_path_, "DB_AutomatedTest-11");
    EXPECT_TRUE(db2->isDBOpen());

    // With the second DB, start a pulling replicator
    std::future<bool> rep_starter2 = std::async(std::launch::async, [&db2, this]() {return db2->startListening(url_, username_, password_);});
    rep_starter2.wait();
    std::this_thread::sleep_for(std::chrono::seconds(2));

    EXPECT_TRUE(db2->isDBOpen());
    EXPECT_TRUE(db2->getListenStatus());
    EXPECT_TRUE(isJsonMsgSuccess(db2->getMessage()));

    // Get contents of DB in Json format
    QJsonObject obj = QJsonDocument::fromJson(db2->getJsonDBContents().toUtf8()).object();

    // Verify added document is in the second DB
    ASSERT_TRUE(obj.contains(test_doc_id));

    // Verify contents of document match
    QJsonObject obj2 = obj.value(test_doc_id).toObject();
    EXPECT_TRUE(obj.value(test_doc_id).toObject().contains(test_doc_key));
    EXPECT_EQ(obj2.value(test_doc_key).toString(), test_doc_val);

    delete db2;

    QDir dir(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-10.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
    dir.setPath(QDir::cleanPath(DB_folder_path_ + QDir::separator() + "DB_AutomatedTest-11.cblite2"));
    if(dir.exists()) {
        dir.removeRecursively();
    }
}
#endif // end if Test_Replication

DatabaseImplTest::DatabaseImplTest()
{
    QDir dir(QCoreApplication::applicationFilePath());
    dir.makeAbsolute();

    if(dir.isReadable()) {
        DB_folder_path_ = dir.path();
    }
}

bool DatabaseImplTest::isJsonMsgSuccess(const QString &msg)
{
    QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
    return obj.value("status").toString() == "success";
}

void DatabaseImplTest::SetUp() {}

void DatabaseImplTest::TearDown() {
    #if !Test_Replication
        std::cout << "\nWARNING:\nTest executed with replication/sync gateway testing disabled. \
        \nEnter valid replication information and enable replication testing if desired.\n\n";
    #endif
}
