#pragma once

#include <QObject>
#include "QtTest.h"
#include <PlatformManager.h>
#include <Operations/PlatformOperations.h>
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceScanner.h>
#include <Platform.h>

class PlatformErrorsTest : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(PlatformErrorsTest)

public:
    PlatformErrorsTest();

private slots:
    // test init/teardown
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // tests
    void deviceLostWithDisconnectTest();
    void deviceLostWithoutDisconnectTest();
    void singleErrorTest();
    void errorBeforeOperationTest();
    void errorDuringOperationTest();
    void errorAfterOperationTest();
    void unableToOpenTest();
    void unableToCloseTest();

private:
    void addMockDevice();
    void removeMockDevice(bool alreadyDisconnected);

    const QByteArray deviceId_ = "mock1234";
    strata::platform::PlatformPtr platform_;
    strata::device::MockDevicePtr mockDevice_;

    strata::platform::operation::PlatformOperations platformOperations_;

    std::shared_ptr<strata::PlatformManager> platformManager_;
    std::shared_ptr<strata::device::scanner::MockDeviceScanner> mockDeviceScanner_;

    int devicesCount_ = 0;
};

