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
    device_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    QVERIFY(!device_->mockIsOpened());
    QVERIFY(device_->open());
}

void PlatformOperationsTest::cleanup()
{
    BasePlatformOperation *operation = platformOperation_.data();
    if (operation != nullptr) {
        disconnect(operation, &BasePlatformOperation::finished, this,
                   &PlatformOperationsTest::handleOperationFinished);
        platformOperation_.reset();
    }
    if (device_.get() != nullptr) {
        device_.reset();
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
    device_->mockSetAutoResponse(false);
    QCOMPARE(device_->mockGetRecordedMessagesCount(), 0);
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
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void PlatformOperationsTest::noResponseTest()
{
    device_->mockSetAutoResponse(false); //stopping auto-response
    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    QCOMPARE(operationTimeoutCount_, 1); //check for retry; on Retrying command->onTimeout() is called
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request); //initial request
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request); //retry

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
}

void PlatformOperationsTest::notJSONTest()
{
    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponse(MockResponse::no_JSON);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    QCOMPARE(operationTimeoutCount_,1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
}

void PlatformOperationsTest::JSONWithoutPayloadTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::get_firmware_info);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::request_platform_id);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::start_application);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(!device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->platformId().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QCOMPARE(operationTimeoutCount_,3);

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::no_payload, MockCommand::start_bootloader);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,4);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
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
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    device_->mockSetResponse(MockResponse::nack);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
}

void PlatformOperationsTest::invalidValueTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::get_firmware_info);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    platformOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::request_platform_id);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::start_application);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(!device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->platformId().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QCOMPARE(operationTimeoutCount_,3);

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);
    device_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::start_bootloader);
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

    QVERIFY(device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,4);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
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
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
    platformOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response_bootloader.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(!device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
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
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetRecordedMessagesCount(), 1, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    platformOperation_->cancelOperation();

    QCOMPARE(platformOperation_->hasStarted(), true);
    QCOMPARE(platformOperation_->isSuccessfullyFinished(), false);
    QCOMPARE(platformOperation_->isFinished(), true);

    recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
}

void PlatformOperationsTest::identifyLegacyTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    device_->mockSetLegacy(true);

    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, false), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    expectedDoc.Parse(test_commands::request_platform_id_response.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
}


// TODO tests for PlatformOperations:
// connect to device + init -> done
// command combos:
//   identify -> done
//   switchToBootloader -> done
//   startApplication -> done
//   flashFirmware
//   backupFirmware
//   cancelOperation -> done
// device error handling -> done
// different command results (nextCommand)
// reset
// signals:
//   finished
//   error
// TODO test device locking
// TODO test concurrent operations with more devices (can be the same thread, but overlapping
// operations)
// TODO modify response timer (in PlatformOperations) for tests -> done
