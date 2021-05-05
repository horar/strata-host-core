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

};
