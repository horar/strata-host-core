#pragma once

#include <QObject>
#include <QCoreApplication>
#include <QEventLoop>

#include "QtTest.h"
#include "../src/ServerConnector.h"

class ServerConnectorTest : public QObject {
    Q_OBJECT

private slots:
    void testConnector();
    void testOpenConnectorFaild();
};