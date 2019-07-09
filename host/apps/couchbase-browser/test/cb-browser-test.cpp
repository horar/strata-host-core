#include <databaseinterface.h>

#include <QObject>
#include <iostream>
#include <gtest/gtest.h>

class DatabaseInterfaceTest : public ::testing::Test
{
public:
    DatabaseInterfaceTest() {}

protected:
    void SetUp() override {}

    virtual void TearDown() override {}

    DatabaseInterface *db = new DatabaseInterface(1);
};

TEST_F(DatabaseInterfaceTest, DBstatus)
{
    EXPECT_FALSE(db->getDBstatus());
}

TEST_F(DatabaseInterfaceTest, CTOR)
{
    DatabaseInterface *db2 = new DatabaseInterface(5);

    EXPECT_NE(db2, nullptr);

    DatabaseInterface *db3 = new DatabaseInterface(5.5);

    EXPECT_NE(db3, nullptr);
}

int main(int argc, char** argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

