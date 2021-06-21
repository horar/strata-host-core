#include <chrono>
#include <Operations/Identify.h>
#include "PlatformErrorsTest.h"
#include <rapidjson/writer.h>

using strata::device::Device;
using strata::device::MockDevice;
using strata::platform::operation::OperationSharedPtr;
using strata::platform::operation::Identify;

namespace test_commands = strata::device::test_commands;

PlatformErrorsTest::PlatformErrorsTest() : platformOperations_(false, false) {
    qRegisterMetaType<strata::device::Device::ErrorCode>("device::Device::ErrorCode");
}

void PlatformErrorsTest::initTestCase()
{
}

void PlatformErrorsTest::cleanupTestCase()
{
}

void PlatformErrorsTest::init()
{
    platformManager_ = std::make_shared<strata::PlatformManager>(true, false, false);
    platformManager_->init(Device::Type::MockDevice);

    auto deviceScanner = platformManager_->getScanner(Device::Type::MockDevice);
    QVERIFY(deviceScanner.get() != nullptr);

    mockDeviceScanner_ = std::dynamic_pointer_cast<strata::device::scanner::MockDeviceScanner>(deviceScanner);
    QVERIFY(mockDeviceScanner_.get() != nullptr);
}

void PlatformErrorsTest::cleanup()
{
    platformOperations_.stopAllOperations();

    if (platform_.get() != nullptr) {
        platform_.reset();
    }
    if (mockDevice_.get() != nullptr) {
        mockDevice_.reset();
    }

    platformManager_->deinit(Device::Type::MockDevice);
}

void PlatformErrorsTest::addMockDevice()
{
    devicesCount_ = platformManager_->getDeviceIds().count();

    QSignalSpy platformAddedSignal(platformManager_.get(), SIGNAL(platformAdded(QByteArray)));
    QVERIFY(mockDeviceScanner_->mockDeviceDetected(deviceId_, "Mock device", true));
    QVERIFY((platformAddedSignal.count() == 1) || (platformAddedSignal.wait(100) == true));

    QVERIFY(platformManager_->getDeviceIds().contains(deviceId_));
    QCOMPARE(platformManager_->getDeviceIds().count(), ++devicesCount_);

    platform_ = platformManager_->getPlatform(deviceId_);
    QVERIFY(platform_.get() != nullptr);
    auto device = platform_->getDevice();
    QVERIFY(device.get() != nullptr);
    mockDevice_ = std::dynamic_pointer_cast<strata::device::MockDevice>(device);
    QVERIFY(mockDevice_.get() != nullptr);
    QVERIFY(platform_->deviceConnected());
}

void PlatformErrorsTest::removeMockDevice(bool alreadyDisconnected)
{
    QSignalSpy platformTerminatedSignal(platform_.get(), SIGNAL(terminated()));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    QVERIFY(mockDeviceScanner_->mockDeviceLost(deviceId_));

    if (alreadyDisconnected) {
        QVERIFY((platformRemovedSignal.count() == 0) && (platformRemovedSignal.wait(100) == false));
    } else {
        QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(100) == true));
    }

    QVERIFY(platformManager_->getDeviceIds().contains(deviceId_) == false);
    QCOMPARE(platformManager_->getDeviceIds().count(), --devicesCount_);

    QVERIFY((platformTerminatedSignal.count() == 1) || (platformTerminatedSignal.wait(100) == true));
}

void PlatformErrorsTest::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    parseResult = doc.Parse(msg.data(), msg.size());
    QVERIFY(parseResult.IsError() == false);
    QVERIFY(doc.IsObject());
    expectedDoc.Parse(expectedJson.data(), expectedJson.size());
    if (doc != expectedDoc) {
        printJsonDoc(doc);
        printJsonDoc(expectedDoc);
    }
    QCOMPARE(doc, expectedDoc);
}

void PlatformErrorsTest::printJsonDoc(rapidjson::Document &doc)
{
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    qDebug("%s", buffer.GetString());
}

void PlatformErrorsTest::deviceLostWithDisconnectTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));

    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));
    mockDevice_->mockEmitError(Device::ErrorCode::DeviceDisconnected, "Device Disconnected");
    QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(100) == true));

    removeMockDevice(true);

    QVERIFY(platformErrorSignal.count() == 1);
    QList<QVariant> arguments = platformErrorSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::UserType);
    QVERIFY(arguments.at(1).type() == QVariant::String);
    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceDisconnected);
}

void PlatformErrorsTest::deviceLostWithoutDisconnectTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));

    removeMockDevice(false);

    QVERIFY(platformErrorSignal.count() == 0);
}

void PlatformErrorsTest::singleErrorTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    mockDevice_->mockEmitError(Device::ErrorCode::DeviceError, "Device Error");

    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(100) == true));
    QList<QVariant> arguments = platformErrorSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::UserType);
    QVERIFY(arguments.at(1).type() == QVariant::String);
    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceError);

    QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(100) == true));
}

void PlatformErrorsTest::errorBeforeOperationTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));
    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);

    mockDevice_->mockEmitError(Device::ErrorCode::DeviceError, "Device Error");

    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), deviceId_);
    QCOMPARE(platformOperation->hasStarted(), true);
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), false);

    QVERIFY(platformErrorSignal.count() == 1);
    QList<QVariant> arguments = platformErrorSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::UserType);
    QVERIFY(arguments.at(1).type() == QVariant::String);
    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceError);
}

void PlatformErrorsTest::errorDuringOperationTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    mockDevice_->mockSetErrorOnNthMessage(2);

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));
    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), deviceId_);
    QCOMPARE(platformOperation->hasStarted(), true);
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), false);

    QVERIFY(platformErrorSignal.count() == 1);
}

void PlatformErrorsTest::errorAfterOperationTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), deviceId_);
    QCOMPARE(platformOperation->hasStarted(), true);
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), true);

    mockDevice_->mockEmitError(Device::ErrorCode::DeviceError, "Device Error");

    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(250) == true));
    QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(250) == true));

    QCOMPARE(platformOperation->isFinished(), true);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), true);
}

void PlatformErrorsTest::unableToOpenTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    mockDevice_->mockSetOpenEnabled(false);

    platformManager_->disconnectPlatform(deviceId_, std::chrono::milliseconds(10));

    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(250) == true));
    QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(250) == true));

    QList<QVariant> arguments = platformErrorSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::UserType);
    QVERIFY(arguments.at(1).type() == QVariant::String);
    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceFailedToOpen);

    QVERIFY(platform_->deviceConnected() == false);
}

void PlatformErrorsTest::unableToCloseTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));

    mockDevice_->mockSetErrorOnClose(true);

    removeMockDevice(false);

    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(250) == true));

    QVERIFY(platform_->deviceConnected() == false);
}

void PlatformErrorsTest::multipleOperationsTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    QSignalSpy platformErrorSignal(platform_.get(), SIGNAL(deviceError(device::Device::ErrorCode, QString)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    std::unique_ptr<Identify> identifyOperation1 = std::make_unique<Identify>(platform_, true, 1, std::chrono::milliseconds(100));
    std::unique_ptr<Identify> identifyOperation2 = std::make_unique<Identify>(platform_, true);

    identifyOperation1->run();
    identifyOperation2->run();

    QVERIFY(platform_->sendMessage("{}") == false);

    QCOMPARE(identifyOperation1->deviceId(), deviceId_);
    QCOMPARE(identifyOperation2->deviceId(), deviceId_);

    QCOMPARE(identifyOperation1->hasStarted(), true);
    QTRY_COMPARE_WITH_TIMEOUT(identifyOperation1->isFinished(), true, 1000);
    QCOMPARE(identifyOperation1->isSuccessfullyFinished(), true);

    QCOMPARE(identifyOperation2->hasStarted(), false);
    QTRY_COMPARE_WITH_TIMEOUT(identifyOperation2->isFinished(), true, 1000);
    QCOMPARE(identifyOperation2->isSuccessfullyFinished(), false);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    // TODO: Rewrite
//    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(250) == true));
//    QList<QVariant> arguments = platformErrorSignal.takeFirst();
//    QVERIFY(arguments.at(0).type() == QVariant::UserType);
//    QVERIFY(arguments.at(1).type() == QVariant::String);
//    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceBusy);

    // DeviceBusy should not terminate the device
    QVERIFY((platformRemovedSignal.count() == 0) && (platformRemovedSignal.wait(250) == false));
}
