#pragma once

#include "SGUtilsCpp.h"

#include <gtest/gtest.h>
#include <QString>

class SGUtilsCppTest : public testing::Test
{
protected:
    void SetUp() override;

    virtual void TearDown() override;
    SGUtilsCpp utils;
    QString lorumIpsumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut "
                             "labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut "
                             "aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse "
                             "cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
                             "culpa qui officia deserunt mollit anim id est laborum.";
};
