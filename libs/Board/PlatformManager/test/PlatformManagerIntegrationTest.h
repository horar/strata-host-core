#pragma once

#include <QObject>
#include "QtTest.h"

class PlatformManagerIntegrationTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformManagerIntegrationTest)

public:
    PlatformManagerIntegrationTest();

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void connectTest();
};
