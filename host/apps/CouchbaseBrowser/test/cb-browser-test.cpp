#include <DatabaseImpl.h>
#include "ConfigManager.h"

#include <QDir>
#include <QObject>
#include <QStandardPaths>

#include <iostream>
#include <gtest/gtest.h>

class DatabaseImplTest : public ::testing::Test
{
public:
    DatabaseImplTest() {}

    bool isJsonMsgSuccess(const QString &msg)
    {
        QJsonObject obj = QJsonDocument::fromJson(msg.toUtf8()).object();
        return obj.value("status").toString() == "success";
    }

    const QString DB_folder_path = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);

    const QString DB_file_path = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation) + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest"
            + QDir::separator() + "db.sqlite3";

protected:
    void SetUp() override {}

    virtual void TearDown() override {}
};

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
    db->openDB(DB_folder_path);
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());
    EXPECT_FALSE(db->getListenStatus());
    db->closeDB();
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());
    EXPECT_FALSE(db->getListenStatus());
    db->closeDB();
    EXPECT_FALSE(db->isDBOpen());
    db->closeDB();

    delete db;
}

TEST_F(DatabaseImplTest, CREATE)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    QFileInfo fileinfo(DB_file_path);
    QDir dir(DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest");

    if(fileinfo.exists() || dir.exists()) {
        ASSERT_TRUE(dir.removeRecursively());
        qDebug() << "\n\nRemoved directory " << DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest" << "\n\n";
    }

    db->createNewDB(DB_folder_path, "DB_AutomatedTest");
    EXPECT_TRUE(db->getDBStatus());
    EXPECT_TRUE(db->isDBOpen());
    EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");

    db->closeDB();
    db->createNewDB(DB_folder_path, "DB_AutomatedTest");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    DatabaseImpl *db2 = new DatabaseImpl();
    EXPECT_EQ(db2->getDBName(), "");
    db2->createNewDB("", " ");
    EXPECT_FALSE(isJsonMsgSuccess(db2->getMessage()));
    db2->clearConfig();
    db2->closeDB();
    db2->createNewDB(QDir::separator(), "DB Name");
    EXPECT_FALSE(isJsonMsgSuccess(db2->getMessage()));

    delete db;
    delete db2;
}

TEST_F(DatabaseImplTest, CREATEDOC)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    QFileInfo fileinfo(DB_file_path);
    QDir dir(DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest");

    if(fileinfo.exists() || dir.exists()) {
        ASSERT_TRUE(dir.removeRecursively());
        qDebug() << "\n\nRemoved directory " << DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest" << "\n\n";
    }

    db->createNewDB(DB_folder_path, "DB_AutomatedTest");
    db->createNewDoc("","");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    db->createNewDoc("doc","");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    db->createNewDoc("doc", "NOT A JSON");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    EXPECT_EQ(db->getJsonDBContents(), "{}");

    db->createNewDoc("doc", "{\"key\":\"value\"}");
    EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");
    EXPECT_EQ(db->getJsonDBContents(), "{\"doc\":{\"key\":\"value\"}}");
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
}

TEST_F(DatabaseImplTest, EDITDOC)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    QFileInfo fileinfo(DB_file_path);
    QDir dir(DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest");

    if(fileinfo.exists() || dir.exists()) {
        ASSERT_TRUE(dir.removeRecursively());
        qDebug() << "\n\nDeleted local directory " << DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest" << "\n\n";
    }

    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->createNewDB(DB_folder_path, "DB_AutomatedTest");
    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");
    EXPECT_EQ(db->getJsonDBContents(), "{\"doc\":{\"name\":\"name1\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("doc", "", "{\"name\":\"name1\"}");
    EXPECT_EQ(db->getJsonDBContents(), "{\"doc\":{\"name\":\"name1\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("doc", "", "{\"name\":\"name2\"}");
    EXPECT_EQ(db->getJsonDBContents(), "{\"doc\":{\"name\":\"name2\"}}");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("", "newId", "body");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc(" ", "newId", "body");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->editDoc("doc", "", "");
    EXPECT_EQ(db->getJsonDBContents(), "{\"doc\":{\"name\":\"name2\"}}");

    db->editDoc("doc", "newDoc", "");
    EXPECT_EQ(db->getJsonDBContents(), "{\"newDoc\":{\"name\":\"name2\"}}");

    db->deleteDoc("doc");
    db->deleteDoc("newDoc");
    db->editDoc("doc", "doc2", "body");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    delete db;
}

TEST_F(DatabaseImplTest, DELETEDOC)
{
    DatabaseImpl *db = new DatabaseImpl(nullptr, false);

    QFileInfo fileinfo(DB_file_path);
    QDir dir(DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest");

    if(fileinfo.exists() || dir.exists()) {
        ASSERT_TRUE(dir.removeRecursively());
        qDebug() << "\n\nRemoved directory " << DB_folder_path + QDir::separator() + "db" + QDir::separator() + "DB_AutomatedTest" << "\n\n";
    }

    db->createNewDB(DB_folder_path, "DB_AutomatedTest");

    EXPECT_EQ(db->getJsonDBContents(), "{}");

    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->deleteDoc("doc");
    EXPECT_EQ(db->getJsonDBContents(), "{}");

    db->createNewDoc("doc", "{\"name\":\"name1\"}");
    db->editDoc("doc", "doc2", "");
    db->deleteDoc("doc");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    db->deleteDoc("doc2");
    EXPECT_TRUE(isJsonMsgSuccess(db->getMessage()));
    EXPECT_EQ(db->getJsonDBContents(), "{}");

    delete db;
}

int main(int argc, char** argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

