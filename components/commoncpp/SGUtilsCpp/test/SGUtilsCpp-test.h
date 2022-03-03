/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
