/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <chrono>
#include <Operations/Identify.h>
#include "PlatformErrorsTest.h"
#include <rapidjson/writer.h>

using strata::device::Device;
using strata::device::MockDevice;
using strata::platform::operation::OperationSharedPtr;
using strata::platform::operation::Identify;
using strata::device::MockVersion;

namespace test_commands = strata::device::test_commands;

QTEST_MAIN(PlatformErrorsTest)

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
    platformManager_->addScanner(Device::Type::MockDevice);

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

    platformManager_->removeScanner(Device::Type::MockDevice);
}

void PlatformErrorsTest::addMockDevice()
{
    devicesCount_ = platformManager_->getDeviceIds().count();

    QSignalSpy platformAddedSignal(platformManager_.get(), SIGNAL(platformAdded(QByteArray)));
    QVERIFY(mockDeviceScanner_->mockDeviceDetected(deviceId_, "Mock device", true).isEmpty());
    QVERIFY((platformAddedSignal.count() == 1) || (platformAddedSignal.wait(100) == true));

    QVERIFY(platformManager_->getDeviceIds().contains(deviceId_));
    QCOMPARE(platformManager_->getDeviceIds().count(), ++devicesCount_);

    platform_ = platformManager_->getPlatform(deviceId_);
    QVERIFY(platform_.get() != nullptr);
    auto device = mockDeviceScanner_->getMockDevice(platform_->deviceId());
    QVERIFY(device.get() != nullptr);
    mockDevice_ = std::dynamic_pointer_cast<strata::device::MockDevice>(device);
    QVERIFY(mockDevice_.get() != nullptr);
    QVERIFY(platform_->deviceConnected());
    mockDevice_->mockSetVersion(MockVersion::Version_1);
    QVERIFY(mockDevice_->mockGetVersion() == MockVersion::Version_1);
}

void PlatformErrorsTest::removeMockDevice(bool alreadyDisconnected)
{
    QSignalSpy platformTerminatedSignal(platform_.get(), SIGNAL(terminated()));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    QVERIFY(mockDeviceScanner_->disconnectDevice(deviceId_).isEmpty());

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
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);

    mockDevice_->mockEmitError(Device::ErrorCode::DeviceError, "Device Error");

    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(100) == true));

    QList<QVariant> arguments = platformErrorSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::UserType);
    QVERIFY(arguments.at(1).type() == QVariant::String);
    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceError);

    QVERIFY((platformRemovedSignal.count() == 1) || (platformRemovedSignal.wait(100) == true));

    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), deviceId_);
    QCOMPARE(platformOperation->hasStarted(), false);
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), false);
}

void PlatformErrorsTest::errorDuringOperationTest()
{
    addMockDevice();
    if (QTest::currentTestFailed() == true) {
        return;
    }

    mockDevice_->mockSetWriteErrorOnNthMessage(2);

    QSignalSpy platformSentSignal(platform_.get(), SIGNAL(messageSent(QByteArray, unsigned, QString)));

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), deviceId_);
    QCOMPARE(platformOperation->hasStarted(), true);
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), false);

    // write error is set on 2nd message, exactly 2 messageSent signals are expected
    QCOMPARE(platformSentSignal.count(), 2);
    QList<QVariant> arguments = platformSentSignal.takeLast();
    QVERIFY(arguments.at(2).type() == QVariant::String);
    QVERIFY(qvariant_cast<QString>(arguments.at(2)).isEmpty() == false);
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
    QSignalSpy platformClosedSignal(platformManager_.get(), SIGNAL(platformClosed(QByteArray)));

    mockDevice_->mockSetOpenEnabled(false);

    platformManager_->disconnectPlatform(deviceId_, std::chrono::milliseconds(10));

    QVERIFY((platformErrorSignal.count() == 1) || (platformErrorSignal.wait(250) == true));
    QVERIFY((platformClosedSignal.count() == 1) || (platformClosedSignal.wait(250) == true));

    QList<QVariant> arguments = platformErrorSignal.takeFirst();
    QVERIFY(arguments.at(0).type() == QVariant::UserType);
    QVERIFY(arguments.at(1).type() == QVariant::String);
    QCOMPARE(qvariant_cast<Device::ErrorCode>(arguments.at(0)), Device::ErrorCode::DeviceFailedToOpenGoingToRetry);

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
    QSignalSpy platformSentSignal(platform_.get(), SIGNAL(messageSent(QByteArray, unsigned, QString)));
    QSignalSpy platformRemovedSignal(platformManager_.get(), SIGNAL(platformRemoved(QByteArray)));

    std::unique_ptr<Identify> identifyOperation1 = std::make_unique<Identify>(platform_, true, 1, std::chrono::milliseconds(100));
    std::unique_ptr<Identify> identifyOperation2 = std::make_unique<Identify>(platform_, true);

    identifyOperation1->run();
    identifyOperation2->run();

    unsigned msgNumber = platform_->sendMessage("{}");
    bool signalReceived = false;

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

    QVERIFY(platformSentSignal.count() > 0);
    while (platformSentSignal.size() > 0) {
        QList<QVariant> arguments = platformSentSignal.takeFirst();
        QVERIFY(arguments.at(1).type() == QVariant::UInt);
        if (qvariant_cast<unsigned>(arguments.at(1)) == msgNumber) {
            signalReceived = true;
            QVERIFY(arguments.at(0).type() == QVariant::ByteArray);
            QVERIFY(qvariant_cast<QString>(arguments.at(0)) == "{}\n");
            QVERIFY(arguments.at(2).type() == QVariant::String);
            QVERIFY(qvariant_cast<QString>(arguments.at(2)).isEmpty() == false);
            break;
        }
    }
    QCOMPARE(signalReceived, true);

    // Second operation didn't succeed because device was locked by first operation
    // and messages from second operation could not be sent.
    // Failure to send messages should not cause a device error.
    QVERIFY((platformErrorSignal.count() == 0) && (platformErrorSignal.wait(250) == false));

    // unsuccessful operation should not terminate the device
    QVERIFY((platformRemovedSignal.count() == 0) && (platformRemovedSignal.wait(250) == false));
}
