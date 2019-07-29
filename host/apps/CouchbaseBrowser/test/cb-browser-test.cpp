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
    DatabaseImpl *db = new DatabaseImpl();
    EXPECT_NE(db, nullptr);
    EXPECT_FALSE(db->getDBStatus());
    EXPECT_FALSE(db->isDBOpen());
    delete db;

    for(int ctr = 0; ctr < 100; ++ctr)
    {
        DatabaseImpl *temp = new DatabaseImpl();
        EXPECT_NE(temp, nullptr);
        EXPECT_FALSE(temp->getDBStatus());
        EXPECT_FALSE(temp->isDBOpen());
        delete temp;
    }
}

TEST_F(DatabaseImplTest, OPEN)
{
    DatabaseImpl *db = new DatabaseImpl();

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
    DatabaseImpl *db = new DatabaseImpl();

    QFileInfo file(DB_file_path);

    if(file.exists()) {
        // Opening DB should succeed if file exists
        db->openDB(DB_file_path);
        EXPECT_TRUE(db->getDBStatus());
        EXPECT_TRUE(db->isDBOpen());
        EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");
    } else {
        // Creating new DB should succeed if file does not exist (create DB in desktop to test)
        db->createNewDB(DB_folder_path, "DB_AutomatedTest");
        EXPECT_TRUE(db->getDBStatus());
        EXPECT_TRUE(db->isDBOpen());
        EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");
    }

    db->closeDB();
    db->createNewDB(DB_folder_path, "DB_AutomatedTest");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));

    DatabaseImpl *db2 = new DatabaseImpl();
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
    DatabaseImpl *db = new DatabaseImpl();

    QFileInfo file(DB_file_path);

    if(file.exists()) {
        // Opening DB should succeed if file exists
        db->openDB(DB_file_path);
        EXPECT_TRUE(db->getDBStatus());
        EXPECT_TRUE(db->isDBOpen());
        EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");
    } else {
        // Creating new DB should succeed if file does not exist (create DB in desktop to test)
        db->createNewDB(DB_folder_path, "DB_AutomatedTest");
        EXPECT_TRUE(db->getDBStatus());
        EXPECT_TRUE(db->isDBOpen());
        EXPECT_EQ(db->getDBName(), "DB_AutomatedTest");
    }

    db->createNewDoc("","");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    db->createNewDoc("doc","");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    db->createNewDoc("doc", "NOT A JSON");
    EXPECT_FALSE(isJsonMsgSuccess(db->getMessage()));
    EXPECT_EQ(db->getJsonDBContents(), "{}");

    db->createNewDoc("doc", "\"key\":\"value\"");

    delete db;
}

int main(int argc, char** argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

