#pragma once

#include <QString>

#include <gtest/gtest.h>

class DatabaseImplTest : public ::testing::Test
{
public:
    DatabaseImplTest();

    bool isJsonMsgSuccess(const QString &msg);

    QString DB_folder_path_;

    // Info for replication tests:
    const QString url_ = "ws://localhost:4984/db";
    const QString username_ = "";
    const QString password_ = "";

protected:
    void SetUp() override;

    virtual void TearDown() override;
};
