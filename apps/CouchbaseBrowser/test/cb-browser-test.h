/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
