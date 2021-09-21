/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include "QtTest.h"

class PlatformMessageTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformMessageTest)

public:
    PlatformMessageTest();

private slots:
    // test init/teardown
    /*!
     * \brief Run before test suite.
     */
    void initTestCase();
    /*!
     * \brief Run after test suite.
     */
    void cleanupTestCase();
    /*!
     * \brief Run before each test.
     */
    void init();
    /*!
     * \brief Run after each test.
     */
    void cleanup();

    // tests
    void validJsonTest();
    void invalidJsonTest();
    void copyMessageTest();
    void messageContentTest();

};
