#include "PlatformManagerTest.h"
#include <Mock/MockDevice.h>

void BoardManagerTest::initTestCase()
{
}

void BoardManagerTest::cleanupTestCase()
{
}

void BoardManagerTest::init()
{
    onBoardDisconnectedCalls_ = 0;
    lastOnBoardDisconnectedDeviceId_.clear();
    boardManager_ = std::make_shared<BoardManagerDerivate>();
    connect(boardManager_.get(), &strata::BoardManager::boardDisconnected, this,
            &BoardManagerTest::onBoardDisconnected);
    boardManager_->init(true, false);
}

void BoardManagerTest::cleanup()
{
    disconnect(boardManager_.get(), &strata::BoardManager::boardDisconnected, this,
               &BoardManagerTest::onBoardDisconnected);
}

void BoardManagerTest::onBoardDisconnected(const QByteArray& deviceId)
{
    onBoardDisconnectedCalls_++;
    lastOnBoardDisconnectedDeviceId_ = deviceId;
}

std::shared_ptr<strata::device::mock::MockDevice> BoardManagerTest::addMockDevice(const QByteArray& deviceId,
                                                                                  const QString& deviceName)
{
    auto devicesCount = boardManager_->activeDeviceIds().count();
    QVERIFY_(boardManager_->addNewMockDevice(deviceId, deviceName));
    QVERIFY_(boardManager_->activeDeviceIds().contains(deviceId));
    QCOMPARE_(boardManager_->activeDeviceIds().count(), ++devicesCount);
    auto device = boardManager_->device(deviceId);
    auto mockDevice = std::dynamic_pointer_cast<strata::device::mock::MockDevice>(boardManager_->device(deviceId));
    QVERIFY_(mockDevice.get() != nullptr);
    QVERIFY_(mockDevice->mockIsOpened());
    return mockDevice;
}

void BoardManagerTest::removeMockDevice(const QByteArray& deviceId)
{
    auto devicesCount = boardManager_->activeDeviceIds().count();
    auto device = boardManager_->device(deviceId);
    auto mockDevice = std::dynamic_pointer_cast<strata::device::mock::MockDevice>(boardManager_->device(deviceId));
    if (boardManager_->disconnectDevice(deviceId)) {
        QVERIFY_(boardManager_->removeMockDevice(deviceId));
        QVERIFY(mockDevice.get() != nullptr);
        QCOMPARE_(boardManager_->activeDeviceIds().count(), --devicesCount);
        QVERIFY(!mockDevice->mockIsOpened());
    } else {
        QVERIFY(device.get() == nullptr);
    }
}

void BoardManagerTest::connectDisconnectTest()
{
    auto mockDevice = addMockDevice("mock1234", "Mock device");
    QVERIFY(mockDevice.get() != nullptr);
    QVERIFY(mockDevice->mockIsOpened());
    removeMockDevice("mock1234");
    QVERIFY(!mockDevice->mockIsOpened());
}

void BoardManagerTest::connectMultipleTest()
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
    QCOMPARE(boardManager_->device("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(boardManager_->device("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(boardManager_->device("mock3")->deviceName(), "Mock device 3");
    QCOMPARE(boardManager_->device("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(boardManager_->device("mock5")->deviceName(), "Mock device 5");

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
    QCOMPARE(boardManager_->device("mock1")->deviceName(), "Mock device 1");
    QCOMPARE(boardManager_->device("mock2")->deviceName(), "Mock device 2");
    QCOMPARE(boardManager_->device("mock4")->deviceName(), "Mock device 4");
    QCOMPARE(boardManager_->device("mock6")->deviceName(), "Mock device 6");
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
