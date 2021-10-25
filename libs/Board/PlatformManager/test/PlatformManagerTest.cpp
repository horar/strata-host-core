/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "PlatformManagerTest.h"
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceScanner.h>

#include <QSignalSpy>

using strata::PlatformManager;
using strata::device::Device;
using strata::device::scanner::MockDeviceScanner;

QTEST_MAIN(PlatformManagerTest)

PlatformManagerTest::PlatformManagerTest()
{
}

void PlatformManagerTest::initTestCase()
{
}

void PlatformManagerTest::cleanupTestCase()
{
}

void PlatformManagerTest::init()
{
    onBoardDisconnectedCalls_ = 0;
    lastOnBoardDisconnectedDeviceId_.clear();
    bool handleIdentify = false;
    if (qstrcmp(QTest::currentTestFunction(), "identifyNewPlatformTest") == 0) {
        handleIdentify = true;
    }
    platformManager_ = std::make_shared<PlatformManager>(true, false, handleIdentify);
    connect(platformManager_.get(), &PlatformManager::platformRemoved, this,
            &PlatformManagerTest::onBoardDisconnected);
    platformManager_->addScanner(Device::Type::MockDevice);
    mockDeviceScanner_ = platformManager_->getScanner(Device::Type::MockDevice);
    QVERIFY(mockDeviceScanner_.get() != nullptr);
}

void PlatformManagerTest::cleanup()
{
    platformManager_->removeScanner(Device::Type::MockDevice);

    disconnect(platformManager_.get(), &PlatformManager::platformRemoved, this,
               &PlatformManagerTest::onBoardDisconnected);
}

void PlatformManagerTest::onBoardDisconnected(const QByteArray& deviceId, const QString& errorString)
{
    Q_UNUSED(errorString)

    onBoardDisconnectedCalls_++;
    lastOnBoardDisconnectedDeviceId_ = deviceId;
}

strata::platform::PlatformPtr PlatformManagerTest::addMockDevice(const QByteArray& deviceId,
                                                                 const QString& deviceName)
{
    auto devicesCount = platformManager_->getDeviceIds().count();
    QSignalSpy platformAddedSignal(platformManager_.get(), SIGNAL(platformOpened(QByteArray)));
    QVERIFY_(static_cast<MockDeviceScanner*>(mockDeviceScanner_.get())->mockDeviceDetected(deviceId, deviceName, true).isEmpty());
    QVERIFY_((platformAddedSignal.count() == 1) || (platformAddedSignal.wait(250) == true));
    QVERIFY_(platformManager_->getDeviceIds().contains(deviceId));
    QCOMPARE_(platformManager_->getDeviceIds().count(), ++devicesCount);
    auto platform = platformManager_->getPlatform(deviceId);
    if (platform.get() != nullptr) {
        QVERIFY_(platform->deviceType() == Device::Type::MockDevice);
        QVERIFY_(platform->deviceConnected());
    } else {
        QFAIL_("failed to create platform");
    }
    return platform;
}

void PlatformManagerTest::removeMockDevice(const QByteArray& deviceId)
{
    auto devicesCount = platformManager_->getDeviceIds().count();
    auto platform = platformManager_->getPlatform(deviceId);
    QSignalSpy platformAboutToCloseSignal(platformManager_.get(), SIGNAL(platformAboutToClose(QByteArray)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray, QString)));
    if (platformManager_->disconnectPlatform(deviceId)) {
        QVERIFY((platformAboutToCloseSignal.count() == 1) || (platformAboutToCloseSignal.wait(250) == true));
        QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(250) == true));
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceType() == Device::Type::MockDevice);
        QCOMPARE(platformManager_->getDeviceIds().count(), --devicesCount);
        QVERIFY(platform->deviceConnected() == false);
    } else {
        QVERIFY(platform.get() == nullptr);
    }
}

void PlatformManagerTest::connectDisconnectTest()
{
    auto platform = addMockDevice("mock1234", "Mock device");
    QVERIFY(platform.get() != nullptr);
    QVERIFY(platform->deviceConnected());
    removeMockDevice("mock1234");
    QVERIFY(platform->deviceConnected() == false);
}

void PlatformManagerTest::connectMultipleTest()
{
    {
        auto platform = addMockDevice("mock1", "Mock device 1");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    {
        auto platform = addMockDevice("mock2", "Mock device 2");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    {
        auto platform = addMockDevice("mock3", "Mock device 3");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    {
        auto platform = addMockDevice("mock4", "Mock device 4");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    {
        auto platform = addMockDevice("mock5", "Mock device 5");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    QCOMPARE(platformManager_->getPlatform("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(platformManager_->getPlatform("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(platformManager_->getPlatform("mock3")->deviceName(), "Mock device 3");
    QCOMPARE(platformManager_->getPlatform("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(platformManager_->getPlatform("mock5")->deviceName(), "Mock device 5");

    QCOMPARE(onBoardDisconnectedCalls_, 0);
    removeMockDevice("mock1");
    QCOMPARE(onBoardDisconnectedCalls_, 1);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, "mock1");
    removeMockDevice("mock3");
    QCOMPARE(onBoardDisconnectedCalls_, 2);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, "mock3");
    removeMockDevice("mock5");
    QCOMPARE(onBoardDisconnectedCalls_, 3);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, "mock5");
    removeMockDevice("mock5");  // try to remove the same again
    QCOMPARE(onBoardDisconnectedCalls_, 3);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, "mock5");
    {
        auto platform = addMockDevice("mock1", "Mock device 1");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    {
        auto platform = addMockDevice("mock6", "Mock device 6");
        QVERIFY(platform.get() != nullptr);
        QVERIFY(platform->deviceConnected());
    }
    QCOMPARE(platformManager_->getPlatform("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(platformManager_->getPlatform("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(platformManager_->getPlatform("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(platformManager_->getPlatform("mock6")->deviceName(), "Mock device 6");
}

void PlatformManagerTest::identifyNewPlatformTest()
{
    QSignalSpy platformRecognizedSignal(platformManager_.get(), SIGNAL(platformRecognized(QByteArray, bool, bool)));

    const QByteArray deviceId("mock");
    addMockDevice(deviceId, "Mock device");

    QVERIFY((platformRecognizedSignal.count() == 1) || (platformRecognizedSignal.wait(250) == true));
    QList<QVariant> arguments = platformRecognizedSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::ByteArray);
    QVERIFY(arguments.at(1).type() == QVariant::Bool);
    QCOMPARE(qvariant_cast<bool>(arguments.at(1)), true);

    removeMockDevice(deviceId);
}

// TODO tests for PlatformManager signals:
void PlatformManagerTest::boardConnectedSignalTest()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void PlatformManagerTest::boardDisconnected()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void PlatformManagerTest::boardReady()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void PlatformManagerTest::boardError()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void PlatformManagerTest::readyDeviceIdsChanged()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

// TODO tests for PlatformManager slots:
void PlatformManagerTest::handleOperationFinished()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void PlatformManagerTest::handleOperationError()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void PlatformManagerTest::handleDeviceError()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}
