/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include <Operations/StartBootloader.h>
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceConstants.h>
#include "PlatformOperationsTest.h"

using strata::platform::operation::PlatformOperations;
using strata::platform::operation::OperationSharedPtr;
using strata::platform::operation::BasePlatformOperation;
using strata::platform::operation::StartBootloader;
using strata::device::MockCommand;
using strata::device::MockResponse;
using strata::device::MockVersion;

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

QTEST_MAIN(PlatformOperationsTest)

PlatformOperationsTest::PlatformOperationsTest() : platformOperations_(false, false) {

}

void PlatformOperationsTest::initTestCase()
{
}

void PlatformOperationsTest::cleanupTestCase()
{
}

void PlatformOperationsTest::init()
{
    operationErrorCount_ = 0;
    operationFinishedCount_ = 0;
    operationTimeoutCount_ = 0;
    mockDevice_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    platform_ = std::make_shared<strata::platform::Platform>(mockDevice_);
    mockDevice_->mockSetVersion(MockVersion::Version_1);
    QVERIFY(mockDevice_->mockGetVersion() == MockVersion::Version_1);
    QVERIFY(platform_->deviceConnected() == false);

    QSignalSpy platformOpened(platform_.get(), SIGNAL(opened()));
    platform_->open();
    QVERIFY((platformOpened.count() == 1) || (platformOpened.wait(250) == true));
    QVERIFY(platform_->deviceConnected());

    connect(&platformOperations_, &PlatformOperations::finished, this, &PlatformOperationsTest::handleOperationFinished);
}

void PlatformOperationsTest::cleanup()
{
    disconnect(&platformOperations_, nullptr, this, nullptr);
    platformOperations_.stopAllOperations();

    if (platform_.get() != nullptr) {
        platform_.reset();
    }
    if (mockDevice_.get() != nullptr) {
        mockDevice_.reset();
    }
}

void PlatformOperationsTest::handleOperationFinished(QByteArray, operation::Type, operation::Result result, int, QString)
{
    operationFinishedCount_++;
    if (result == operation::Result::Error) {
        operationErrorCount_++;
    }

    if (result == operation::Result::Timeout) {
        operationTimeoutCount_++;
    }
}

void PlatformOperationsTest::handleRetryGetFirmwareInfo()
{
    if (operationCommandsCount_ == 1) {
        mockDevice_->mockSetResponseForCommand(MockResponse::Normal, MockCommand::Get_firmware_info);
    }
    operationCommandsCount_++;
}

void PlatformOperationsTest::printJsonDoc(rapidjson::Document &doc)
{
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    qDebug("%s", buffer.GetString());
}

void PlatformOperationsTest::connectTest()
{
    mockDevice_->mockSetAutoResponse(false);
    QCOMPARE(mockDevice_->mockGetRecordedMessagesCount(), 0);
    QCOMPARE(operationErrorCount_, 0);
}

void PlatformOperationsTest::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
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

void PlatformOperationsTest::connectRetryGetFirmwareInfoHandler(BasePlatformOperation *operation)
{
    connect(operation, &BasePlatformOperation::sendCommand, this, &PlatformOperationsTest::handleRetryGetFirmwareInfo);
}

void PlatformOperationsTest::identifyTest()
{
    rapidjson::Document expectedDoc;

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(platform_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(platform_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(platform_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void PlatformOperationsTest::noResponseTest()
{
    mockDevice_->mockSetAutoResponse(false); //stopping auto-response

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    QCOMPARE(operationTimeoutCount_, 1); //check for retry; on Retrying command->onTimeout() is called
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request); //initial request
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request); //retry

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
}

void PlatformOperationsTest::notJSONTest()
{
    mockDevice_->mockSetResponseForCommand(MockResponse::No_JSON, MockCommand::Get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    QCOMPARE(operationTimeoutCount_,1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
}

void PlatformOperationsTest::JSONWithoutPayloadTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::No_payload, MockCommand::Get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    mockDevice_->mockSetResponseForCommand(MockResponse::Normal, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::No_payload, MockCommand::Request_platform_id);

    platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request); //initial request
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request); //retry
    verifyMessage(recordedMessages[2], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[3], test_commands::request_platform_id_request);
}

void PlatformOperationsTest::nackTest()
{
    mockDevice_->mockSetResponseForCommand(MockResponse::Nack, MockCommand::Get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
}

void PlatformOperationsTest::invalidValueTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Invalid, MockCommand::Get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    mockDevice_->mockSetResponseForCommand(MockResponse::Normal, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Invalid, MockCommand::Request_platform_id);

    platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_bootloader_invalid, MockCommand::Request_platform_id);

    platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,3);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 6);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[2], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[3], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[4], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[5], test_commands::request_platform_id_request);
}

void PlatformOperationsTest::bootloaderResponseTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_bootloader, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(mockDevice_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response_bootloader.data());
    QCOMPARE(platform_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(platform_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(platform_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);
}

void PlatformOperationsTest::cancelOperationTest()
{
    mockDevice_->mockSetAutoResponse(false);
    rapidjson::Document expectedDoc;

    OperationSharedPtr platformOperation = platformOperations_.StartBootloader(platform_);
    platformOperation->run();
    QTRY_COMPARE_WITH_TIMEOUT(mockDevice_->mockGetRecordedMessagesCount(), 1, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    platformOperation->cancelOperation();

    QCOMPARE(platformOperation->hasStarted(), true);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), false);
    QCOMPARE(platformOperation->isFinished(), true);

    recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
}

void PlatformOperationsTest::identifyLegacyTest()
{
    rapidjson::Document expectedDoc;

    // very old board without 'get_firmware_info' command support
    mockDevice_->mockSetResponseForCommand(MockResponse::Nack, MockCommand::Get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, false);
    platformOperation->run();
    QCOMPARE(platformOperation->deviceId(), "mock1234");

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(platform_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(platform_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(platform_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
}

void PlatformOperationsTest::retryGetFirmwareInfoTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::No_payload, MockCommand::Get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    connectRetryGetFirmwareInfoHandler(platformOperation.get());
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(platform_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(platform_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(platform_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 3);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[2], test_commands::request_platform_id_request);
}


// TODO tests for PlatformOperations:
// connect to device + init -> done
// command combos:
//   identify -> done
//   switchToBootloader -> done
//   startApplication -> done
//   flashFirmware -> done
//   backupFirmware
//   cancelOperation -> done
// device error handling -> done
// different command results (nextCommand)
// reset
// signals:
//   finished
//   error
// TODO test platform locking
// TODO test concurrent operations with more devices (can be the same thread, but overlapping
// operations)
// TODO modify response timer (in PlatformOperations) for tests -> done
