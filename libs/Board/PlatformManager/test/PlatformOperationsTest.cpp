#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include <Operations/Identify.h>
#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>
#include <Mock/MockDevice.h>
#include <Mock/MockDeviceConstants.h>
#include "PlatformOperationsTest.h"

using strata::platform::operation::BasePlatformOperation;
using strata::platform::operation::StartBootloader;
using strata::device::MockCommand;
using strata::device::MockResponse;

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

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
    QVERIFY(!mockDevice_->mockIsOpened());
    QVERIFY(platform_->open());
}

void PlatformOperationsTest::cleanup()
{
    BasePlatformOperation *operation = platformOperation_.data();
    if (operation != nullptr) {
        disconnect(operation, &BasePlatformOperation::finished, this,
                   &PlatformOperationsTest::handleOperationFinished);
        platformOperation_.reset();
    }
    if (platform_.get() != nullptr) {
        platform_.reset();
    }
    if (mockDevice_.get() != nullptr) {
        mockDevice_.reset();
    }
}

void PlatformOperationsTest::handleOperationFinished(operation::Result result, int, QString)
{
    operationFinishedCount_++;
    if (result == operation::Result::Error) {
        operationErrorCount_++;
    }

    if (result == operation::Result::Timeout) {
        operationTimeoutCount_++;
    }
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

    parseResult = doc.Parse(msg.data());
    QVERIFY(!parseResult.IsError());
    QVERIFY(doc.IsObject());
    expectedDoc.Parse(expectedJson.data());
    if (doc != expectedDoc) {
        printJsonDoc(doc);
        printJsonDoc(expectedDoc);
    }
    QCOMPARE(doc, expectedDoc);
}

void PlatformOperationsTest::connectHandlers(BasePlatformOperation *operation) {
    connect(operation, &BasePlatformOperation::finished, this, &PlatformOperationsTest::handleOperationFinished);
}

void PlatformOperationsTest::identifyTest()
{
    rapidjson::Document expectedDoc;

    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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
    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

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
    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponse(MockResponse::no_JSON);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

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

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::get_firmware_info);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::request_platform_id);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(platform_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::start_application);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(!mockDevice_->mockIsBootloader());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->platformId().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QCOMPARE(operationTimeoutCount_,3);

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(platform_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::start_bootloader);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(mockDevice_->mockIsBootloader());
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
    QCOMPARE(operationTimeoutCount_,4);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 8);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request); //initial request
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request); //retry
    verifyMessage(recordedMessages[2], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[3], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[4], test_commands::start_application_request);
    verifyMessage(recordedMessages[5], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[6], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[7], test_commands::start_bootloader_request);
}

void PlatformOperationsTest::nackTest()
{
    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    mockDevice_->mockSetResponse(MockResponse::nack);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

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

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::get_firmware_info);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(platform_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::request_platform_id);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(platform_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::start_application);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(!mockDevice_->mockIsBootloader());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(platform_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(platform_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->platformId().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QCOMPARE(operationTimeoutCount_,3);

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(platform_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::start_bootloader);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(mockDevice_->mockIsBootloader());
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
    QCOMPARE(operationTimeoutCount_,4);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 8);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[2], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[3], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[4], test_commands::start_application_request);
    verifyMessage(recordedMessages[5], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[6], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[7], test_commands::start_bootloader_request);
}

void PlatformOperationsTest::switchToBootloaderAndBackTest()
{
    rapidjson::Document expectedDoc;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(platform_);
    platformOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(platform_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(!mockDevice_->mockIsBootloader());
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
    QCOMPARE(recordedMessages.size(), 8);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[2], test_commands::start_bootloader_request);
    verifyMessage(recordedMessages[3], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[4], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[5], test_commands::start_application_request);
    verifyMessage(recordedMessages[6], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[7], test_commands::request_platform_id_request);
}

void PlatformOperationsTest::cancelOperationTest()
{
    mockDevice_->mockSetAutoResponse(false);
    rapidjson::Document expectedDoc;

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(platform_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(mockDevice_->mockGetRecordedMessagesCount(), 1, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    platformOperation_->cancelOperation();

    QCOMPARE(platformOperation_->hasStarted(), true);
    QCOMPARE(platformOperation_->isSuccessfullyFinished(), false);
    QCOMPARE(platformOperation_->isFinished(), true);

    recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
}

void PlatformOperationsTest::identifyLegacyTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetLegacy(true);

    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(platform_, false), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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
