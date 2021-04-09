#pragma once

#include <QString>

#include <gtest/gtest.h>

class CouchbaseDatabaseTest : public ::testing::Test
{
public:
    CouchbaseDatabaseTest();

protected:
    void SetUp() override;

    virtual void TearDown() override;
};
