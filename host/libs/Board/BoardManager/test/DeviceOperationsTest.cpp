#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include "CommandResponseMock.h"
#include <Device/Operations/Identify.h>
#include <Device/Operations/StartBootloader.h>
#include <Device/Operations/StartApplication.h>
#include "DeviceMock.h"
#include "DeviceOperationsTest.h"

using strata::device::operation::BaseDeviceOperation;
using strata::device::operation::StartBootloader;

namespace operation = strata::device::operation;

void DeviceOperationsTest::initTestCase()
{
}

void DeviceOperationsTest::cleanupTestCase()
{
}

void DeviceOperationsTest::init()
{
    operationErrorCount_ = 0;
    operationFinishedCount_ = 0;
    operationTimeoutCount_ = 0;
    device_ = std::make_shared<DeviceMock>(1234, "Mock device");
    bool openRes = device_->open();
    QVERIFY(openRes);
}

void DeviceOperationsTest::cleanup()
{
    BaseDeviceOperation *operation = deviceOperation_.data();
    if (operation != nullptr) {
        disconnect(operation, &BaseDeviceOperation::finished, this,
                   &DeviceOperationsTest::handleOperationFinished);
        deviceOperation_.reset();
    }
    if (device_.get() != nullptr) {
        device_.reset();
    }
}

void DeviceOperationsTest::handleOperationFinished(operation::Result result, int, QString)
{
    operationFinishedCount_++;
    if (result == operation::Result::Error) {
        operationErrorCount_++;
    }

    if (result == operation::Result::Timeout) {
        operationTimeoutCount_++;
    }
}

void DeviceOperationsTest::printJsonDoc(rapidjson::Document &doc)
{
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    qDebug("%s", buffer.GetString());
}

void DeviceOperationsTest::connectTest()
{
    device_->mockSetAutoResponse(false);
    QCOMPARE(device_->mockGetMsgCount(), 0);
    QCOMPARE(operationErrorCount_, 0);
}

void DeviceOperationsTest::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
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

void DeviceOperationsTest::connectHandlers(BaseDeviceOperation *operation) {
    connect(operation, &BaseDeviceOperation::finished, this, &DeviceOperationsTest::handleOperationFinished);
}

void DeviceOperationsTest::identifyTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

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

void DeviceOperationsTest::noResponseTest()
{
    device_->mockSetAutoResponse(false); //stopping auto-response
    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2200);

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

void DeviceOperationsTest::notJSONTest()
{
    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponse(CommandResponseMock::MockResponse::no_JSON);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2200);

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

void DeviceOperationsTest::JSONWithoutPayloadTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::no_payload, CommandResponseMock::Command::get_firmware_info);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::no_payload, CommandResponseMock::Command::request_platform_id);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    deviceOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::no_payload, CommandResponseMock::Command::start_application);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

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

    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::no_payload, CommandResponseMock::Command::start_bootloader);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

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

void DeviceOperationsTest::nackTest()
{
    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponse(CommandResponseMock::MockResponse::nack);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
}

void DeviceOperationsTest::invalidValueTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::invalid, CommandResponseMock::Command::get_firmware_info);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);

    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::invalid, CommandResponseMock::Command::request_platform_id);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    expectedDoc.Parse(test_commands::get_firmware_info_response.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    QCOMPARE(operationTimeoutCount_,2);

    deviceOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::invalid, CommandResponseMock::Command::start_application);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

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

    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::invalid, CommandResponseMock::Command::start_bootloader);
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

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

void DeviceOperationsTest::switchToBootloaderAndBackTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

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

    deviceOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

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

void DeviceOperationsTest::cancelOperationTest()
{
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetMsgCount(), 1, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);

    deviceOperation_->cancelOperation();

    QCOMPARE(deviceOperation_->hasStarted(), true);
    QCOMPARE(deviceOperation_->isSuccessfullyFinished(), false);
    QCOMPARE(deviceOperation_->isFinished(), true);

    recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
}

void DeviceOperationsTest::identifyLegacyTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    device_->mockSetLegacy(true);

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, false), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

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


// TODO tests for DeviceOperations:
// connect to device + init -> done
// command combos:
//   identify
//   switchToBootloader
//   startApplication
//   flashFirmware
//   backupFirmware
//   cancelOperation
// device error handling
// different command results (nextCommand)
// reset
// signals:
//   finished
//   error
// TODO test device locking
// TODO test concurrent operations with more devices (can be the same thread, but overlapping
// operations)
// TODO modify response timer (in DeviceOperations) for tests
