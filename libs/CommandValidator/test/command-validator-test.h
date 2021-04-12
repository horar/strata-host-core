#pragma once

#include <gtest/gtest.h>
#include <rapidjson/document.h>

class CommandValidatorTest : public testing::Test
{
public:
    void printJsonDoc(rapidjson::Document &doc);

protected:
    void SetUp() override;

    virtual void TearDown() override;
};
