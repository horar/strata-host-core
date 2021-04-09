#include "PlatformManagerTest.h"
#include <Mock/MockDevice.h>

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
    platformManager_ = std::make_shared<PlatformManagerDerivate>();
    connect(platformManager_.get(), &strata::PlatformManager::boardDisconnected, this,
            &PlatformManagerTest::onBoardDisconnected);
    platformManager_->init(true, false);
}

void PlatformManagerTest::cleanup()
{
    disconnect(platformManager_.get(), &strata::PlatformManager::boardDisconnected, this,
               &PlatformManagerTest::onBoardDisconnected);
}

void PlatformManagerTest::onBoardDisconnected(const QByteArray& deviceId)
{
    onBoardDisconnectedCalls_++;
    lastOnBoardDisconnectedDeviceId_ = deviceId;
}

std::shared_ptr<strata::device::MockDevice> PlatformManagerTest::addMockDevice(const QByteArray& deviceId,
                                                                                  const QString& deviceName)
{
    auto devicesCount = platformManager_->activeDeviceIds().count();
    QVERIFY_(platformManager_->addNewMockDevice(deviceId, deviceName));
    QVERIFY_(platformManager_->activeDeviceIds().contains(deviceId));
    QCOMPARE_(platformManager_->activeDeviceIds().count(), ++devicesCount);
    auto device = platformManager_->device(deviceId);
    auto mockDevice = std::dynamic_pointer_cast<strata::device::MockDevice>(platformManager_->device(deviceId));
    QVERIFY_(mockDevice.get() != nullptr);
    QVERIFY_(mockDevice->mockIsOpened());
    return mockDevice;
}

void PlatformManagerTest::removeMockDevice(const QByteArray& deviceId)
{
    auto devicesCount = platformManager_->activeDeviceIds().count();
    auto device = platformManager_->device(deviceId);
    auto mockDevice = std::dynamic_pointer_cast<strata::device::MockDevice>(platformManager_->device(deviceId));
    if (platformManager_->disconnectDevice(deviceId)) {
        QVERIFY_(platformManager_->removeMockDevice(deviceId));
        QVERIFY(mockDevice.get() != nullptr);
        QCOMPARE_(platformManager_->activeDeviceIds().count(), --devicesCount);
        QVERIFY(!mockDevice->mockIsOpened());
    } else {
        QVERIFY(device.get() == nullptr);
    }
}

void PlatformManagerTest::connectDisconnectTest()
{
    auto mockDevice = addMockDevice("mock1234", "Mock device");
    QVERIFY(mockDevice.get() != nullptr);
    QVERIFY(mockDevice->mockIsOpened());
    removeMockDevice("mock1234");
    QVERIFY(!mockDevice->mockIsOpened());
}

void PlatformManagerTest::connectMultipleTest()
{
    {
        auto mockDevice = addMockDevice("mock1", "Mock device 1");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice("mock2", "Mock device 2");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice("mock3", "Mock device 3");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice("mock4", "Mock device 4");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice("mock5", "Mock device 5");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    QCOMPARE(platformManager_->device("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(platformManager_->device("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(platformManager_->device("mock3")->deviceName(), "Mock device 3");
    QCOMPARE(platformManager_->device("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(platformManager_->device("mock5")->deviceName(), "Mock device 5");

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
        auto mockDevice = addMockDevice("mock1", "Mock device 1");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice("mock6", "Mock device 6");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    QCOMPARE(platformManager_->device("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(platformManager_->device("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(platformManager_->device("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(platformManager_->device("mock6")->deviceName(), "Mock device 6");
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
