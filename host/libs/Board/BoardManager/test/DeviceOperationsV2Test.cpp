#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include <Device/Operations/Identify.h>
#include <Device/Operations/StartBootloader.h>
#include <Device/Operations/StartApplication.h>
#include <Device/Operations/Flash.h>
#include "DeviceOperationsV2Test.h"

using strata::device::operation::BaseDeviceOperation;
using strata::device::mock::MockCommand;
using strata::device::mock::MockResponse;
using strata::device::mock::MockVersion;

namespace operation = strata::device::operation;
namespace test_commands = strata::device::mock::test_commands;

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

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
    device_ = std::make_shared<strata::device::mock::MockDevice>("mock1234", "Mock device", true);
    QVERIFY(device_->mockSetVersion(MockVersion::version2));
    QVERIFY(!device_->mockIsOpened());
    QVERIFY(device_->open());
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

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::embedded_app);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), "mock1234");
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

    QVERIFY(identifyOperation->boardMode() == operation::Identify::BoardMode::Application);

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

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::embedded_btloader);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), "mock1234");
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

    QVERIFY(identifyOperation->boardMode() == operation::Identify::BoardMode::Bootloader);

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

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_app);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), "mock1234");
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

    expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data());;

    QVERIFY(identifyOperation->boardMode() == operation::Identify::BoardMode::Application);

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

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_btloader);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), "mock1234");
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

    QVERIFY(identifyOperation->boardMode() == operation::Identify::BoardMode::Bootloader);

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

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_no_board);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), "mock1234");
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

    QVERIFY(identifyOperation->boardMode() == operation::Identify::BoardMode::Application);

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

    device_->mockSetResponse(MockResponse::embedded_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

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

    device_->mockSetResponse(MockResponse::embedded_app);

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

    device_->mockSetResponse(MockResponse::assisted_app);

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

    device_->mockSetResponse(MockResponse::embedded_btloader);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetRecordedMessagesCount(), 1, 1000);

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

    device_->mockSetResponse(MockResponse::assisted_btloader);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetRecordedMessagesCount(), 1, 1000);

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
    deviceOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponse(MockResponse::embedded_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

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
    deviceOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponse(MockResponse::assisted_app);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

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
    deviceOperation_ = QSharedPointer<operation::Identify>(
                new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponseForCommand(MockResponse::invalid, MockCommand::get_firmware_info);

    deviceOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());
    QCOMPARE(operationTimeoutCount_,1);
}

void DeviceOperationsV2Test::flashFirmwareTest()
{
    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,256,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    deviceOperation_->run();

    flashFirmwareOperation->flashChunk(QVector<quint8>(),0);
    flashFirmwareOperation->flashChunk(QVector<quint8>(),1);
    flashFirmwareOperation->flashChunk(QVector<quint8>(),2);

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);
    verifyMessage(recordedMessages[0], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[1], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[2], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[3], device_->mockGetDynamicRequest()[0]);
}

void DeviceOperationsV2Test::flashBootloaderTest()
{
    operation::Flash* flashBootloaderOperation = new operation::Flash(device_,256,4,"207fb5670e66e7d6ecd89b5f195c0b71",false);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    deviceOperation_->run();

    flashBootloaderOperation->flashChunk(QVector<quint8>(),0);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),1);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),2);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),3);

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(), 5);
    verifyMessage(recordedMessages[0], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[1], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[2], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[3], device_->mockGetDynamicRequest()[0]);
    verifyMessage(recordedMessages[4], device_->mockGetDynamicRequest()[0]);
}

void DeviceOperationsV2Test::flashResendChunkTest()
{
    operation::Flash* flashBootloaderOperation = new operation::Flash(device_,256,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::flash_resend_chunk);

    deviceOperation_->run();

    flashBootloaderOperation->flashChunk(QVector<quint8>(),0);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),1);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),2);

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);
}

void DeviceOperationsV2Test::flashMemoryErrorTest()
{
    operation::Flash* flashBootloaderOperation = new operation::Flash(device_,256,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::flash_memory_error);

    deviceOperation_->run();

    flashBootloaderOperation->flashChunk(QVector<quint8>(),0);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),1);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),2);;

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);
}

void DeviceOperationsV2Test::flashInvalidCmdSequenceTest()
{
    operation::Flash* flashBootloaderOperation = new operation::Flash(device_,256,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::flash_invalid_cmd_sequence);

    deviceOperation_->run();

    flashBootloaderOperation->flashChunk(QVector<quint8>(),0);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),1);
    flashBootloaderOperation->flashChunk(QVector<quint8>(),2);

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);
}

void DeviceOperationsV2Test::flashInvalidValueTest()
{
    operation::Flash* flashBootloaderOperation = new operation::Flash(device_,256,1,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashBootloaderOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponse(MockResponse::flash_invalid_value);

    deviceOperation_->run();

    flashBootloaderOperation->flashChunk(QVector<quint8>(),0);

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->platformId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_,1);
}

void DeviceOperationsV2Test::cancelFlashOperationTest()
{
    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,256,2,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    deviceOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectHandlers(deviceOperation_.data());
    deviceOperation_->run();

    flashFirmwareOperation->flashChunk(QVector<quint8>(),0);

    deviceOperation_->cancelOperation();

    flashFirmwareOperation->flashChunk(QVector<quint8>(),1);

    QCOMPARE(deviceOperation_->hasStarted(), true);
    QCOMPARE(deviceOperation_->isSuccessfullyFinished(), false);
    QCOMPARE(deviceOperation_->isFinished(), true);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 2);
    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 0);
}
