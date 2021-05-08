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

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

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
    QVERIFY(!mockDevice_->mockIsOpened());

    QSignalSpy platformOpened(platform_.get(), SIGNAL(opened(QByteArray)));
    platform_->open();
    QVERIFY((platformOpened.count() == 1) || (platformOpened.wait(250) == true));
    QVERIFY(mockDevice_->mockIsOpened());

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
        mockDevice_->mockSetResponseForCommand(MockResponse::normal, MockCommand::get_firmware_info);
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
    QVERIFY(!parseResult.IsError());
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
    mockDevice_->mockSetResponse(MockResponse::no_JSON);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::request_platform_id);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::start_application);

    platformOperation = platformOperations_.StartApplication(platform_);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::start_bootloader);

    platformOperation = platformOperations_.StartBootloader(platform_);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

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
    mockDevice_->mockSetResponse(MockResponse::nack);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::request_platform_id);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::start_application);

    platformOperation = platformOperations_.StartApplication(platform_);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::start_bootloader);

    platformOperation = platformOperations_.StartBootloader(platform_);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

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

    OperationSharedPtr platformOperation = platformOperations_.StartBootloader(platform_);
    static_cast<operation::StartBootloader*>(platformOperation.get())->setWaitTime(std::chrono::milliseconds(1));
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

    platformOperation = platformOperations_.StartApplication(platform_);
    platformOperation->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

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

    mockDevice_->mockSetLegacy(true);

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

    mockDevice_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::get_firmware_info);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    connectRetryGetFirmwareInfoHandler(platformOperation.get());
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

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
