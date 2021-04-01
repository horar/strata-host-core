#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include <Device/Operations/Identify.h>
#include <Device/Operations/StartBootloader.h>
#include <Device/Operations/StartApplication.h>
#include <Device/Operations/Flash.h>
#include "DeviceOperationsV2Test.h"
#include "DeviceOperationsStatus.h"

#include "CodecBase64.h"

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
    flashPartialStatusCount_ = 0;
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

    BaseDeviceOperation *flashOperation = flashOperation_.data();
    if (flashOperation != nullptr) {
        disconnect(flashOperation, &BaseDeviceOperation::finished, this,
                   &DeviceOperationsV2Test::handleOperationFinished);
        disconnect(flashOperation, &BaseDeviceOperation::partialStatus, this,
                   &DeviceOperationsV2Test::handleFlashPartialStatus);
        flashOperation_.reset();
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

    if (result == operation::Result::Failure) {
        operationFailureCount_++;
    }

    if (result == operation::Result::Timeout) {
        operationTimeoutCount_++;
    }
}

void DeviceOperationsV2Test::handleFlashPartialStatus(int status)
{
    flashPartialStatusTest(device_->mockGetResponse(),status); //test if flashing has started
    flashOperation_->flashChunk(QVector<quint8>(256),flashPartialStatusCount_);
    flashPartialStatusCount_++;
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

void DeviceOperationsV2Test::connectHandlers(BaseDeviceOperation *operation)
{
    connect(operation, &BaseDeviceOperation::finished, this, &DeviceOperationsV2Test::handleOperationFinished);
}

void DeviceOperationsV2Test::connectFlashHandlers(operation::BaseDeviceOperation *operation)
{
    connect(operation, &BaseDeviceOperation::partialStatus, this, &DeviceOperationsV2Test::handleFlashPartialStatus);
    connect(operation, &BaseDeviceOperation::finished, this, &DeviceOperationsV2Test::handleOperationFinished);
}

QByteArray DeviceOperationsV2Test::dataForChunkSize(int chunkSize) //get actual data for chunkSize
{
    size_t chunkBase64Size = base64::encoded_size(static_cast<size_t>(chunkSize));
    QByteArray chunkBase64;
    chunkBase64.resize(static_cast<int>(chunkBase64Size));
    base64::encode(chunkBase64.data(), QVector<quint8>(chunkSize).data(), static_cast<size_t>(chunkSize));
    return chunkBase64.data();
}

void DeviceOperationsV2Test::flashPartialStatusTest(strata::device::mock::MockResponse response, int status)
{
    switch(response) {
    case MockResponse::normal: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::device::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1); //flashPartialStatusCount-1 because start_flash_firmware is sent first
            break;
        }
        break;
    }
    case MockResponse::flash_resend_chunk: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status, strata::device::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    case MockResponse::flash_memory_error: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::device::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    case MockResponse::flash_invalid_cmd_sequence: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::device::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    case MockResponse::flash_invalid_value: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::device::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    default:
        break;
    }
}

void DeviceOperationsV2Test::identifyEmbeddedApplicationTest()
{
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    rapidjson::Document expectedDoc;

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
    deviceOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);

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
    deviceOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);

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
    deviceOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);

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
    rapidjson::Document expectedDoc;

    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
                flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);

    flashFirmwareOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashFirmwareOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 0);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1); //finished flashing
    QCOMPARE(flashPartialStatusCount_, 3); //three chunks flashed

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);

    expectedDoc.Parse(recordedMessages[0]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedDoc["payload"]["size"].GetInt(),768);
    QCOMPARE(expectedDoc["payload"]["chunks"].GetInt(),3);
    QCOMPARE(expectedDoc["payload"]["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));

    expectedDoc.Parse(recordedMessages[2]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),1);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));

    expectedDoc.Parse(recordedMessages[3]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),2);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));
}

void DeviceOperationsV2Test::flashBootloaderTest()
{
    rapidjson::Document expectedDoc;

    operation::Flash* flashBootloaderOperation = new operation::Flash(device_,1024,4,"207fb5670e66e7d6ecd89b5f195c0b71",false);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashBootloaderOperation, &QObject::deleteLater);
    connectFlashHandlers(flashBootloaderOperation);

    flashBootloaderOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashBootloaderOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 0);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 4); //four chunks flashed

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 5);

    expectedDoc.Parse(recordedMessages[0]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_bootloader");
    QCOMPARE(expectedDoc["payload"]["size"].GetInt(),1024);
    QCOMPARE(expectedDoc["payload"]["chunks"].GetInt(),4);
    QCOMPARE(expectedDoc["payload"]["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));

    expectedDoc.Parse(recordedMessages[2]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),1);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));

    expectedDoc.Parse(recordedMessages[3]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),2);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));

    expectedDoc.Parse(recordedMessages[4]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),3);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));
}

void DeviceOperationsV2Test::flashResendChunkTest()
{
    rapidjson::Document expectedDoc;

    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,512,2,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);

    device_->mockSetResponse(MockResponse::flash_resend_chunk);

    flashFirmwareOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashFirmwareOperation->isFinished(), true, 1100);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 0);
    QCOMPARE(operationTimeoutCount_, 1);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 3);

    expectedDoc.Parse(recordedMessages[0]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedDoc["payload"]["size"].GetInt(),512);
    QCOMPARE(expectedDoc["payload"]["chunks"].GetInt(),2);
    QCOMPARE(expectedDoc["payload"]["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0); //initial chunk - recieved status:resend_chunk
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));

    expectedDoc.Parse(recordedMessages[2]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0); //re-sent chunk after recieving resend_chunk
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));
}

void DeviceOperationsV2Test::flashMemoryErrorTest()
{
    rapidjson::Document expectedDoc;

    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);

    device_->mockSetResponse(MockResponse::flash_memory_error);

    flashFirmwareOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashFirmwareOperation->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 1);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);

    expectedDoc.Parse(recordedMessages[0]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedDoc["payload"]["size"].GetInt(),768);
    QCOMPARE(expectedDoc["payload"]["chunks"].GetInt(),3);
    QCOMPARE(expectedDoc["payload"]["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));
}

void DeviceOperationsV2Test::flashInvalidCmdSequenceTest()
{
    rapidjson::Document expectedDoc;

    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);

    device_->mockSetResponse(MockResponse::flash_invalid_cmd_sequence);

    flashFirmwareOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashFirmwareOperation->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 2);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);

    expectedDoc.Parse(recordedMessages[0]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedDoc["payload"]["size"].GetInt(),768);
    QCOMPARE(expectedDoc["payload"]["chunks"].GetInt(),3);
    QCOMPARE(expectedDoc["payload"]["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));
}

void DeviceOperationsV2Test::flashInvalidValueTest()
{
    rapidjson::Document expectedDoc;

    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);
    flashOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponse(MockResponse::flash_invalid_value);

    flashFirmwareOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashFirmwareOperation->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->platformId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 2);
    QCOMPARE(operationTimeoutCount_, 1);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);;

    expectedDoc.Parse(recordedMessages[0]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedDoc["payload"]["size"].GetInt(),768);
    QCOMPARE(expectedDoc["payload"]["chunks"].GetInt(),3);
    QCOMPARE(expectedDoc["payload"]["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1]);
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedDoc["payload"]["chunk"]["number"].GetInt(),0);
    QCOMPARE(expectedDoc["payload"]["chunk"]["size"].GetInt(),256);
    QCOMPARE(expectedDoc["payload"]["chunk"]["data"].GetString(),dataForChunkSize(256));
}

void DeviceOperationsV2Test::cancelFlashOperationTest()
{
    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,512,2,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);
    flashFirmwareOperation->run();

    flashFirmwareOperation->cancelOperation();

    flashFirmwareOperation->flashChunk(QVector<quint8>(256),0); //to verify cancel operation

    QCOMPARE(flashFirmwareOperation->hasStarted(), true);
    QCOMPARE(flashFirmwareOperation->isSuccessfullyFinished(), false);
    QCOMPARE(flashFirmwareOperation->isFinished(), true);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 2); //2 chunks + one fail flash
    QCOMPARE(operationErrorCount_, 1); //flash w/o flash operation
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 2); //run & cancel operations
    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 0);
}

void DeviceOperationsV2Test::startFlashInvalidTest()
{
    rapidjson::Document expectedDoc;

    operation::Flash* flashFirmwareOperation = new operation::Flash(device_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    flashOperation_ = QSharedPointer<operation::Flash>(
            flashFirmwareOperation, &QObject::deleteLater);
    connectFlashHandlers(flashFirmwareOperation);
    flashOperation_->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponseForCommand(MockResponse::start_flash_firmware_invalid,MockCommand::start_flash_firmware);

    flashFirmwareOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(flashFirmwareOperation->isFinished(), true, 1000);

    QVERIFY(device_->name().isEmpty());
    QVERIFY(device_->classId().isEmpty());
    QVERIFY(device_->platformId().isEmpty());
    QVERIFY(device_->bootloaderVer().isEmpty());
    QVERIFY(device_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 2);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(operationTimeoutCount_,1);
    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
}
