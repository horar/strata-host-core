#pragma once

#include <QObject>
#include "QtTest.h"

class BoardManagerIntegrationTest : public QObject
{
    Q_OBJECT

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void connectTest();
};
