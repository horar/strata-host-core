#include "BoardManagerTest.h"
#include "DeviceMock.h"

using strata::device::StringProperties;

void BoardManagerTest::initTestCase()
{
}

void BoardManagerTest::cleanupTestCase()
{
}

void BoardManagerTest::init()
{
    onBoardDisconnectedCalls_ = 0;
    lastOnBoardDisconnectedDeviceId_ = 0;
    boardManager_ = std::make_shared<BoardManagerDerivate>();
    connect(boardManager_.get(), &strata::BoardManager::boardDisconnected, this,
            &BoardManagerTest::onBoardDisconnected);
    boardManager_->init();
}

void BoardManagerTest::cleanup()
{
    disconnect(boardManager_.get(), &strata::BoardManager::boardDisconnected, this,
               &BoardManagerTest::onBoardDisconnected);
}

void BoardManagerTest::onBoardDisconnected(int deviceId)
{
    onBoardDisconnectedCalls_++;
    lastOnBoardDisconnectedDeviceId_ = deviceId;
}

std::shared_ptr<DeviceMock> BoardManagerTest::addMockDevice(const int deviceId,
                                                            const QString deviceName)
{
    auto devicesCount = boardManager_->readyDeviceIds().count();
    boardManager_->mockAddNewDevice(deviceId, deviceName);
    QVERIFY_(boardManager_->readyDeviceIds().contains(deviceId));
    QCOMPARE_(boardManager_->readyDeviceIds().count(), ++devicesCount);
    auto device = boardManager_->device(deviceId);
    auto mockDevice = std::dynamic_pointer_cast<DeviceMock>(boardManager_->device(deviceId));
    QVERIFY_(mockDevice.get() != nullptr);
    QVERIFY_(mockDevice->mockIsOpened());
    return mockDevice;
}

void BoardManagerTest::removeMockDevice(const int deviceId)
{
    auto devicesCount = boardManager_->readyDeviceIds().count();
    auto device = boardManager_->device(deviceId);
    auto mockDevice = std::dynamic_pointer_cast<DeviceMock>(boardManager_->device(deviceId));
    if (boardManager_->disconnect(deviceId)) {
        boardManager_->mockRemoveDevice(deviceId);
        QVERIFY(mockDevice.get() != nullptr);
        QCOMPARE_(boardManager_->readyDeviceIds().count(), --devicesCount);
        QVERIFY(!mockDevice->mockIsOpened());
    } else {
        QVERIFY(device.get() == nullptr);
    }
}

void BoardManagerTest::connectDisconnectTest()
{
    auto mockDevice = addMockDevice(1234, "Mock device");
    QVERIFY(mockDevice.get() != nullptr);
    QVERIFY(mockDevice->mockIsOpened());
    removeMockDevice(1234);
    QVERIFY(!mockDevice->mockIsOpened());
}

void BoardManagerTest::connectMultipleTest()
{
    {
        auto mockDevice = addMockDevice(1, "Mock device 1");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice(2, "Mock device 2");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice(3, "Mock device 3");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice(4, "Mock device 4");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice(5, "Mock device 5");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    QCOMPARE(boardManager_->device(1)->deviceName(), "Mock device 1");
    QCOMPARE(boardManager_->device(2)->deviceName(), "Mock device 2");
    QCOMPARE(boardManager_->device(3)->deviceName(), "Mock device 3");
    QCOMPARE(boardManager_->device(4)->deviceName(), "Mock device 4");
    QCOMPARE(boardManager_->device(5)->deviceName(), "Mock device 5");

    QCOMPARE(onBoardDisconnectedCalls_, 0);
    removeMockDevice(1);
    QCOMPARE(onBoardDisconnectedCalls_, 1);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, 1);
    removeMockDevice(3);
    QCOMPARE(onBoardDisconnectedCalls_, 2);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, 3);
    removeMockDevice(5);
    QCOMPARE(onBoardDisconnectedCalls_, 3);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, 5);
    removeMockDevice(5);  // try to remove the same again
    QCOMPARE(onBoardDisconnectedCalls_, 3);
    QCOMPARE(lastOnBoardDisconnectedDeviceId_, 5);
    {
        auto mockDevice = addMockDevice(1, "Mock device 1");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    {
        auto mockDevice = addMockDevice(6, "Mock device 6");
        QVERIFY(mockDevice.get() != nullptr);
        QVERIFY(mockDevice->mockIsOpened());
    }
    QCOMPARE(boardManager_->device(1)->deviceName(), "Mock device 1");
    QCOMPARE(boardManager_->device(2)->deviceName(), "Mock device 2");
    QCOMPARE(boardManager_->device(4)->deviceName(), "Mock device 4");
    QCOMPARE(boardManager_->device(6)->deviceName(), "Mock device 6");
}

// TODO tests for BoardManager signals:
void BoardManagerTest::boardConnectedSignalTest()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void BoardManagerTest::boardDisconnected()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void BoardManagerTest::boardReady()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void BoardManagerTest::boardError()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void BoardManagerTest::readyDeviceIdsChanged()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

// TODO tests for BoardManager slots:
void BoardManagerTest::handleOperationFinished()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void BoardManagerTest::handleOperationError()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}

void BoardManagerTest::handleDeviceError()
{
    QEXPECT_FAIL("", "TODO", Continue);
    QVERIFY(false);
}
