#include <databaseImpl.h>

#include <QObject>
#include <iostream>
#include <gtest/gtest.h>

class DatabaseImplTest : public ::testing::Test
{
public:
    DatabaseImplTest() {}

protected:
    void SetUp() override {}

    virtual void TearDown() override {}

    DatabaseImpl *db = new DatabaseImpl(1);
};

TEST_F(DatabaseImplTest, DBstatus)
{
    EXPECT_FALSE(db->getDBstatus());
}

TEST_F(DatabaseImplTest, CTOR)
{
    DatabaseImpl *db2 = new DatabaseImpl(5);

    EXPECT_NE(db2, nullptr);

    DatabaseImpl *db3 = new DatabaseImpl(5.5);

    EXPECT_NE(db3, nullptr);
}

int main(int argc, char** argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

