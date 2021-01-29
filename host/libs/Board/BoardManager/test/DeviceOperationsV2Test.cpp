#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include "CommandResponseMock.h"
#include <Device/Operations/Identify.h>
#include <Device/Operations/StartBootloader.h>
#include <Device/Operations/StartApplication.h>
#include "DeviceMock.h"
#include "DeviceOperationsV2Test.h"

using strata::device::operation::BaseDeviceOperation;

namespace operation = strata::device::operation;

void DeviceOperationsV2Test::initTestCase()
{
}

void DeviceOperationsV2Test::cleanupTestCase()
{
}

void DeviceOperationsV2Test::init()
{
    operationErrorCount_ = 0;
    operationFinishedCount_ = 0;
    operationTimeoutCount_ = 0;
    device_ = std::make_shared<DeviceMock>(1234, "Mock device");
    bool openRes = device_->open();
    QVERIFY(openRes);
}

void DeviceOperationsV2Test::cleanup()
{
    BaseDeviceOperation *operation = deviceOperation_.data();
    if (operation != nullptr) {
        disconnect(operation, &BaseDeviceOperation::finished, this,
                   &DeviceOperationsV2Test::handleOperationFinished);
        deviceOperation_.reset();
    }
    if (device_.get() != nullptr) {
        device_.reset();
    }
}

void DeviceOperationsV2Test::handleOperationFinished(operation::Result result, int, QString)
{
    operationFinishedCount_++;
    if (result == operation::Result::Error) {
        operationErrorCount_++;
    }

    if (result == operation::Result::Timeout) {
        operationTimeoutCount_++;
    }
}

void DeviceOperationsV2Test::printJsonDoc(rapidjson::Document &doc)
{
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    qDebug("%s", buffer.GetString());
}

void DeviceOperationsV2Test::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
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

void DeviceOperationsV2Test::connectHandlers(BaseDeviceOperation *operation) {
    connect(operation, &BaseDeviceOperation::finished, this, &DeviceOperationsV2Test::handleOperationFinished);
}

void DeviceOperationsV2Test::identifyEmbeddedApplicationTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::embedded_app);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Embedded);
    QVERIFY(device_->controllerPlatformId().isEmpty());
    QVERIFY(device_->controllerClassId().isEmpty());
    QVERIFY(!device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());

    QVERIFY(!device_->bootloaderMode());
    QCOMPARE("application",
             expectedDoc["notification"]["payload"]["active"]);
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void DeviceOperationsV2Test::identifyEmbeddedBootloaderTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::embedded_btloader);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded_bootloader.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Embedded);
    QVERIFY(device_->controllerPlatformId().isEmpty());
    QVERIFY(device_->controllerClassId().isEmpty());
    QVERIFY(!device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_bootloader.data());

    QVERIFY(device_->bootloaderMode());
    QCOMPARE("bootloader",
             expectedDoc["notification"]["payload"]["active"]);
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void DeviceOperationsV2Test::identifyAssistedApplicationTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::assisted_app);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Assisted);
    QCOMPARE(device_->controllerPlatformId(),
             expectedDoc["notification"]["payload"]["controller_platform_id"].GetString());
    QCOMPARE(device_->controllerClassId(),
             expectedDoc["notification"]["payload"]["controller_class_id"].GetString());
    QVERIFY(device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());

    QVERIFY(!device_->bootloaderMode());
    QCOMPARE("application",
             expectedDoc["notification"]["payload"]["active"]);
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void DeviceOperationsV2Test::identifyAssistedBootloaderTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::assisted_btloader);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted_bootloader.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Assisted);
    QCOMPARE(device_->controllerPlatformId(),
             expectedDoc["notification"]["payload"]["controller_platform_id"].GetString());
    QCOMPARE(device_->controllerClassId(),
             expectedDoc["notification"]["payload"]["controller_class_id"].GetString());
    QVERIFY(device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_bootloader.data());

    QVERIFY(device_->bootloaderMode());
    QCOMPARE("bootloader",
             expectedDoc["notification"]["payload"]["active"].GetString());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void DeviceOperationsV2Test::identifyAssistedNoBoardTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::assisted_no_board);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), 1234);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted_without_board.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QVERIFY(device_->platformId().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Assisted);
    QCOMPARE(device_->controllerPlatformId(),
             expectedDoc["notification"]["payload"]["controller_platform_id"].GetString());
    QCOMPARE(device_->controllerClassId(),
             expectedDoc["notification"]["payload"]["controller_class_id"].GetString());
    QVERIFY(!device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());
    QVERIFY(!device_->bootloaderMode());
    QCOMPARE("application",
             expectedDoc["notification"]["payload"]["active"]);
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
}

void DeviceOperationsV2Test::switchToBootloaderAndBackEmbeddedTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));

    device_->mockSetResponse(CommandResponseMock::MockResponse::embedded_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 6000);

    QVERIFY(device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Embedded);
    QVERIFY(device_->controllerPlatformId().isEmpty());
    QVERIFY(device_->controllerClassId().isEmpty());
    QVERIFY(!device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());

    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    deviceOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::embedded_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(!device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded.data());
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

void DeviceOperationsV2Test::switchToBootloaderAndBackAssistedTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));

    device_->mockSetResponse(CommandResponseMock::MockResponse::assisted_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted.data());
    QCOMPARE(device_->name(),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->platformId(),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->classId(),
             expectedDoc["notification"]["payload"]["class_id"].GetString());

    QVERIFY(device_->controllerType() == strata::device::Device::ControllerType::Assisted);
    QCOMPARE(device_->controllerPlatformId(),
             expectedDoc["notification"]["payload"]["controller_platform_id"].GetString());
    QCOMPARE(device_->controllerClassId(),
             expectedDoc["notification"]["payload"]["controller_class_id"].GetString());
    QVERIFY(device_->isControllerConnectedToPlatform());

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_bootloader.data());
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
    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());
    QCOMPARE(device_->bootloaderVer(),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->applicationVer(),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());
    expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted.data());
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

void DeviceOperationsV2Test::cancelOperationEmbeddedTest()
{
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::embedded_btloader);

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

void DeviceOperationsV2Test::cancelOperationAssistedTest()
{
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::assisted_btloader);

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

void DeviceOperationsV2Test::noResponseEmbeddedTest()
{
    device_->mockSetAutoResponse(false);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::embedded_app);

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

void DeviceOperationsV2Test::noResponseAssistedTest()
{
    device_->mockSetAutoResponse(false);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(CommandResponseMock::MockResponse::assisted_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2200);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    QCOMPARE(operationTimeoutCount_, 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
}

void DeviceOperationsV2Test::invalidValueV2Test()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponseForCommand(CommandResponseMock::MockResponse::v2invalid, CommandResponseMock::Command::get_firmware_info);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 2000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);
}
