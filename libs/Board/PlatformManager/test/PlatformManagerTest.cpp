#include "PlatformManagerTest.h"
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceScanner.h>

#include <QSignalSpy>

using strata::PlatformManager;
using strata::device::Device;
using strata::device::scanner::MockDeviceScanner;

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
    platformManager_->init(Device::Type::MockDevice);
    mockDeviceScanner_ = platformManager_->getScanner(Device::Type::MockDevice);
    QVERIFY_(mockDeviceScanner_.get() != nullptr);
}

void PlatformManagerTest::cleanup()
{
    platformManager_->deinit(Device::Type::MockDevice);

    disconnect(platformManager_.get(), &PlatformManager::platformRemoved, this,
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
    auto devicesCount = platformManager_->getDeviceIds().count();
    QSignalSpy platformAddedSignal(platformManager_.get(), SIGNAL(platformAdded(QByteArray)));
    QVERIFY_(static_cast<MockDeviceScanner*>(mockDeviceScanner_.get())->mockDeviceDetected(deviceId, deviceName, true));
    QVERIFY_((platformAddedSignal.count() == 1) || (platformAddedSignal.wait(250) == true));
    QVERIFY_(platformManager_->getDeviceIds().contains(deviceId));
    QCOMPARE_(platformManager_->getDeviceIds().count(), ++devicesCount);
    auto platform = platformManager_->getPlatform(deviceId);
    QVERIFY_(platform.get() != nullptr);
    auto device = platform->getDevice();
    QVERIFY_(device.get() != nullptr);
    auto mockDevice = std::dynamic_pointer_cast<strata::device::MockDevice>(device);
    QVERIFY_(mockDevice.get() != nullptr);
    QVERIFY_(mockDevice->mockIsOpened());
    return mockDevice;
}

void PlatformManagerTest::removeMockDevice(const QByteArray& deviceId)
{
    auto devicesCount = platformManager_->getDeviceIds().count();
    auto platform = platformManager_->getPlatform(deviceId);
    QSignalSpy platformAboutToCloseSignal(platformManager_.get(), SIGNAL(platformAboutToClose(QByteArray)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));
    if (platformManager_->disconnectPlatform(deviceId)) {
        QVERIFY((platformRemovedSignal.wait(250) == true) && (platformAboutToCloseSignal.count() == 1));
        QVERIFY(static_cast<MockDeviceScanner*>(mockDeviceScanner_.get())->mockDeviceLost(deviceId));
        QVERIFY(platform.get() != nullptr);
        auto mockDevice = std::dynamic_pointer_cast<strata::device::MockDevice>(platform->getDevice());
        QVERIFY(mockDevice.get() != nullptr);
        QCOMPARE(platformManager_->getDeviceIds().count(), --devicesCount);
        QVERIFY(!mockDevice->mockIsOpened());
    } else {
        QVERIFY(platform.get() == nullptr);
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
        auto mockDevice = addMockDevice("mock1", "Mock device 1");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice("mock6", "Mock device 6");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    QCOMPARE(platformManager_->getPlatform("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(platformManager_->getPlatform("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(platformManager_->getPlatform("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(platformManager_->getPlatform("mock6")->deviceName(), "Mock device 6");
}

void PlatformManagerTest::identifyNewPlatformTest()
{
    QSignalSpy platformRecognizedSignal(platformManager_.get(), SIGNAL(platformRecognized(QByteArray, bool)));

    const QByteArray deviceId("mock");
    addMockDevice(deviceId, "Mock device");

    QCOMPARE(platformRecognizedSignal.wait(250), true);
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
