#pragma once

#include "templateLib.h"

#include <gtest/gtest.h>


class GtestTemplateTest : public testing::Test
{
public:
    // test helpers

protected:
    void SetUp() override;

    virtual void TearDown() override;
};
