/*
 * Copyright (c) 2018-2022 onsemi.
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
#include <Operations/Identify.h>
#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>
#include <Operations/Flash.h>
#include "PlatformOperationsV2Test.h"
#include "PlatformOperationsStatus.h"
#include <CodecBase64.h>

using strata::platform::operation::PlatformOperations;
using strata::platform::operation::OperationSharedPtr;
using strata::platform::operation::BasePlatformOperation;
using strata::device::MockCommand;
using strata::device::MockResponse;
using strata::device::MockVersion;

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

QTEST_MAIN(PlatformOperationsV2Test)

PlatformOperationsV2Test::PlatformOperationsV2Test() : platformOperations_(false, false) {

}

void PlatformOperationsV2Test::initTestCase()
{
}

void PlatformOperationsV2Test::cleanupTestCase()
{
}

void PlatformOperationsV2Test::init()
{
    operationErrorCount_ = 0;
    operationFinishedCount_ = 0;
    operationTimeoutCount_ = 0;
    flashPartialStatusCount_ = 0;
    mockDevice_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    platform_ = std::make_shared<strata::platform::Platform>(mockDevice_);
    mockDevice_->mockSetVersion(MockVersion::Version_2);
    QVERIFY(mockDevice_->mockGetVersion() == MockVersion::Version_2);
    QVERIFY(platform_->deviceConnected() == false);

    QSignalSpy platformOpened(platform_.get(), SIGNAL(opened()));
    platform_->open();
    QVERIFY((platformOpened.count() == 1) || (platformOpened.wait(250) == true));
    QVERIFY(platform_->deviceConnected());

    connect(&platformOperations_, &PlatformOperations::finished, this, &PlatformOperationsV2Test::handleOperationFinished);
}

void PlatformOperationsV2Test::cleanup()
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

void PlatformOperationsV2Test::handleOperationFinished(QByteArray, operation::Type, operation::Result result, int, QString)
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

void PlatformOperationsV2Test::handleFlashPartialStatus(int status)
{
    operation::BasePlatformOperation *baseOp = qobject_cast<operation::BasePlatformOperation*>(QObject::sender());
    QVERIFY(baseOp != nullptr);

    flashPartialStatusTest(mockDevice_->mockGetResponseForCommand(MockCommand::Flash_firmware), status); // test if flashing has started

    operation::Flash *flashOp = dynamic_cast<operation::Flash*>(baseOp);
    QVERIFY(flashOp != nullptr);    // captures invalid operations

    flashOp->flashChunk(QVector<quint8>(256),flashPartialStatusCount_);
    flashPartialStatusCount_++;
}

void PlatformOperationsV2Test::printJsonDoc(rapidjson::Document &doc)
{
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    qDebug("%s", buffer.GetString());
}

void PlatformOperationsV2Test::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
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

void PlatformOperationsV2Test::connectFlashHandlers(BasePlatformOperation *operation)
{
    connect(operation, &BasePlatformOperation::partialStatus, this, &PlatformOperationsV2Test::handleFlashPartialStatus);
}

QByteArray PlatformOperationsV2Test::dataForChunkSize(int chunkSize) //get actual data for chunkSize
{
    size_t chunkBase64Size = base64::encoded_size(static_cast<size_t>(chunkSize));
    QByteArray chunkBase64;
    chunkBase64.resize(static_cast<int>(chunkBase64Size));
    base64::encode(chunkBase64.data(), QVector<quint8>(chunkSize).data(), static_cast<size_t>(chunkSize));
    return chunkBase64.data();
}

void PlatformOperationsV2Test::flashPartialStatusTest(strata::device::MockResponse response, int status)
{
    switch(response) {
    case MockResponse::Normal: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::platform::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1); //flashPartialStatusCount-1 because start_flash_firmware is sent first
            break;
        }
        break;
    }
    case MockResponse::Flash_firmware_resend_chunk: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status, strata::platform::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    case MockResponse::Flash_firmware_memory_error: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::platform::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    case MockResponse::Flash_firmware_invalid_cmd_sequence: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::platform::operation::FLASH_STARTED);
            break;
        default: QCOMPARE(status, flashPartialStatusCount_-1);
            break;
        }
        break;
    }
    case MockResponse::Flash_firmware_invalid_value: {
        switch(flashPartialStatusCount_) {
        case 0: QCOMPARE(status,strata::platform::operation::FLASH_STARTED);
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

void PlatformOperationsV2Test::identifyEmbeddedApplicationTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_app, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_app, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded.data(),
                          test_commands::request_platform_id_response_ver2_embedded.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());

        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Embedded);
        QVERIFY(platform_->controllerPlatformId().isEmpty());
        QVERIFY(platform_->controllerClassId().isEmpty());
        QVERIFY(platform_->isControllerConnectedToPlatform() == false);
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data(),
                          test_commands::get_firmware_info_response_ver2_application.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QVERIFY(static_cast<operation::Identify*>(platformOperation.get())->boardMode() == operation::Identify::BoardMode::Application);

        QCOMPARE("application", expectedPayload["active"]);
        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
}

void PlatformOperationsV2Test::identifyEmbeddedBootloaderTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded_bootloader.data(),
                          test_commands::request_platform_id_response_ver2_embedded_bootloader.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());

        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Embedded);
        QVERIFY(platform_->controllerPlatformId().isEmpty());
        QVERIFY(platform_->controllerClassId().isEmpty());
        QVERIFY(platform_->isControllerConnectedToPlatform() == false);
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_bootloader.data(),
                          test_commands::get_firmware_info_response_ver2_bootloader.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QVERIFY(static_cast<operation::Identify*>(platformOperation.get())->boardMode() == operation::Identify::BoardMode::Bootloader);

        QCOMPARE("bootloader", expectedPayload["active"]);
        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
}

void PlatformOperationsV2Test::identifyAssistedApplicationTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_app, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_app, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted.data(),
                          test_commands::request_platform_id_response_ver2_assisted.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());

        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Assisted);
        QCOMPARE(platform_->controllerPlatformId(), expectedPayload["controller_platform_id"].GetString());
        QCOMPARE(platform_->controllerClassId(), expectedPayload["controller_class_id"].GetString());
        QVERIFY(platform_->isControllerConnectedToPlatform());
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data(),
                          test_commands::get_firmware_info_response_ver2_application.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QVERIFY(static_cast<operation::Identify*>(platformOperation.get())->boardMode() == operation::Identify::BoardMode::Application);

        QCOMPARE("application", expectedPayload["active"]);
        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
}

void PlatformOperationsV2Test::identifyAssistedBootloaderTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_bootloader, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_bootloader, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);
    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted_bootloader.data(),
                          test_commands::request_platform_id_response_ver2_assisted_bootloader.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());

        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Assisted);

        QCOMPARE(platform_->controllerPlatformId(), expectedPayload["controller_platform_id"].GetString());
        QCOMPARE(platform_->controllerClassId(), expectedPayload["controller_class_id"].GetString());

        QVERIFY(platform_->isControllerConnectedToPlatform());
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_bootloader.data(),
                          test_commands::get_firmware_info_response_ver2_bootloader.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QVERIFY(static_cast<operation::Identify*>(platformOperation.get())->boardMode() == operation::Identify::BoardMode::Bootloader);

        QCOMPARE("bootloader", expectedPayload["active"].GetString());
        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
}

void PlatformOperationsV2Test::identifyAssistedNoBoardTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_no_board, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_no_board, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->run();

    QCOMPARE(platformOperation->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted_without_board.data(),
                          test_commands::request_platform_id_response_ver2_assisted_without_board.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QVERIFY(platform_->platformId().isEmpty());
        QVERIFY(platform_->classId().isEmpty());
        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Assisted);
        QCOMPARE(platform_->controllerPlatformId(), expectedPayload["controller_platform_id"].GetString());
        QCOMPARE(platform_->controllerClassId(), expectedPayload["controller_class_id"].GetString());
        QVERIFY(platform_->isControllerConnectedToPlatform() == false);
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data(),
                          test_commands::get_firmware_info_response_ver2_application.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QVERIFY(static_cast<operation::Identify*>(platformOperation.get())->boardMode() == operation::Identify::BoardMode::Application);

        QCOMPARE("application", expectedPayload["active"]);
        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
}

void PlatformOperationsV2Test::switchToBootloaderAndBackEmbeddedTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_app, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_app, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.StartBootloader(platform_);
    static_cast<operation::StartBootloader*>(platformOperation.get())->setWaitTime(std::chrono::milliseconds(1));
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(mockDevice_->mockIsBootloader());
    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded.data(),
                          test_commands::request_platform_id_response_ver2_embedded.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(),       expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(),    expectedPayload["class_id"].GetString());

        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Embedded);
        QVERIFY(platform_->controllerPlatformId().isEmpty());
        QVERIFY(platform_->controllerClassId().isEmpty());
        QVERIFY(platform_->isControllerConnectedToPlatform() == false);
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data(),
                          test_commands::get_firmware_info_response_ver2_application.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());

        platformOperation = platformOperations_.StartApplication(platform_);
        platformOperation->run();

        QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

        QVERIFY(mockDevice_->mockIsBootloader() == false);
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data(),
                          test_commands::get_firmware_info_response_ver2_application.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_embedded.data(),
                          test_commands::request_platform_id_response_ver2_embedded.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());
    }

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

void PlatformOperationsV2Test::switchToBootloaderAndBackAssistedTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_app, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_app, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.StartBootloader(platform_);
    static_cast<operation::StartBootloader*>(platformOperation.get())->setWaitTime(std::chrono::milliseconds(1));
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(mockDevice_->mockIsBootloader());

    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted.data(),
                          test_commands::request_platform_id_response_ver2_assisted.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());

        QVERIFY(platform_->controllerType() == strata::platform::Platform::ControllerType::Assisted);

        QCOMPARE(platform_->controllerPlatformId(), expectedPayload["controller_platform_id"].GetString());
        QCOMPARE(platform_->controllerClassId(), expectedPayload["controller_class_id"].GetString());

        QVERIFY(platform_->isControllerConnectedToPlatform());
    }
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_bootloader.data(),
                          test_commands::get_firmware_info_response_ver2_bootloader.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }

    platformOperation = platformOperations_.StartApplication(platform_);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(mockDevice_->mockIsBootloader() == false);
    {
        expectedDoc.Parse(test_commands::get_firmware_info_response_ver2_application.data(),
                          test_commands::get_firmware_info_response_ver2_application.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->bootloaderVer(), expectedPayload["bootloader"]["version"].GetString());
        QCOMPARE(platform_->applicationVer(), expectedPayload["application"]["version"].GetString());
    }
    {
        expectedDoc.Parse(test_commands::request_platform_id_response_ver2_assisted.data(),
                          test_commands::request_platform_id_response_ver2_assisted.size());
        const rapidjson::Value& expectedPayload = expectedDoc["notification"]["payload"];

        QCOMPARE(platform_->name(), expectedPayload["name"].GetString());
        QCOMPARE(platform_->platformId(), expectedPayload["platform_id"].GetString());
        QCOMPARE(platform_->classId(), expectedPayload["class_id"].GetString());
    }

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

void PlatformOperationsV2Test::cancelOperationEmbeddedTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetAutoResponse(false);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Request_platform_id);

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

void PlatformOperationsV2Test::cancelOperationAssistedTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetAutoResponse(false);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_bootloader, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_bootloader, MockCommand::Request_platform_id);

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

void PlatformOperationsV2Test::noResponseEmbeddedTest()
{
    mockDevice_->mockSetAutoResponse(false);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_app, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_app, MockCommand::Request_platform_id);

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

void PlatformOperationsV2Test::noResponseAssistedTest()
{
    mockDevice_->mockSetAutoResponse(false);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_app, MockCommand::Get_firmware_info);
    mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_assisted_app, MockCommand::Request_platform_id);

    OperationSharedPtr platformOperation = platformOperations_.Identify(platform_, true);
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    QCOMPARE(operationTimeoutCount_, 1);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::get_firmware_info_request);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());
}

void PlatformOperationsV2Test::invalidValueV2Test()
{
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
}

void PlatformOperationsV2Test::flashFirmwareTest()
{
    rapidjson::Document expectedDoc;

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 0);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1); //finished flashing
    QCOMPARE(flashPartialStatusCount_, 3); //three chunks flashed

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 4);

    {
        expectedDoc.Parse(recordedMessages[0].data(), recordedMessages[0].size());
        const rapidjson::Value& expectedPayload = expectedDoc["payload"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
        QCOMPARE(expectedPayload["size"].GetInt(),768);
        QCOMPARE(expectedPayload["chunks"].GetInt(),3);
        QCOMPARE(expectedPayload["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");
    }
    {
        expectedDoc.Parse(recordedMessages[1].data(), recordedMessages[1].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),0);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[2].data(), recordedMessages[2].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),1);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[3].data(), recordedMessages[3].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),2);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
}

void PlatformOperationsV2Test::flashBootloaderTest()
{
    rapidjson::Document expectedDoc;

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,1024,4,"207fb5670e66e7d6ecd89b5f195c0b71",false);
    connectFlashHandlers(platformOperation.get());
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isSuccessfullyFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 0);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 4); //four chunks flashed

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 5);

    {
        expectedDoc.Parse(recordedMessages[0].data(), recordedMessages[0].size());
        const rapidjson::Value& expectedPayload = expectedDoc["payload"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_bootloader");
        QCOMPARE(expectedPayload["size"].GetInt(),1024);
        QCOMPARE(expectedPayload["chunks"].GetInt(),4);
        QCOMPARE(expectedPayload["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");
    }
    {
        expectedDoc.Parse(recordedMessages[1].data(), recordedMessages[1].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),0);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[2].data(), recordedMessages[2].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),1);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[3].data(), recordedMessages[3].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),2);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[4].data(), recordedMessages[4].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),3);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
}

void PlatformOperationsV2Test::flashResendChunkTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_resend_chunk, MockCommand::Flash_firmware);

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,512,2,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1100);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 1);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 3);

    {
        expectedDoc.Parse(recordedMessages[0].data(), recordedMessages[0].size());
        const rapidjson::Value& expectedPayload = expectedDoc["payload"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
        QCOMPARE(expectedPayload["size"].GetInt(),512);
        QCOMPARE(expectedPayload["chunks"].GetInt(),2);
        QCOMPARE(expectedPayload["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");
    }
    {
        expectedDoc.Parse(recordedMessages[1].data(), recordedMessages[1].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),0); //initial chunk - recieved status:resend_chunk
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[2].data(), recordedMessages[2].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),0); //re-sent chunk after recieving resend_chunk
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
}

void PlatformOperationsV2Test::flashMemoryErrorTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_memory_error, MockCommand::Flash_firmware);

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 2);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);

    expectedDoc.Parse(recordedMessages[0].data(), recordedMessages[0].size());
    const rapidjson::Value& expectedPayload = expectedDoc["payload"];
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedPayload["size"].GetInt(),768);
    QCOMPARE(expectedPayload["chunks"].GetInt(),3);
    QCOMPARE(expectedPayload["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1].data(), recordedMessages[1].size());
    const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedChunk["number"].GetInt(),0);
    QCOMPARE(expectedChunk["size"].GetInt(),256);
    QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
}

void PlatformOperationsV2Test::flashInvalidCmdSequenceTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_invalid_cmd_sequence, MockCommand::Flash_firmware);

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 3);
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);

    expectedDoc.Parse(recordedMessages[0].data(), recordedMessages[0].size());
    const rapidjson::Value& expectedPayload = expectedDoc["payload"];
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedPayload["size"].GetInt(),768);
    QCOMPARE(expectedPayload["chunks"].GetInt(),3);
    QCOMPARE(expectedPayload["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1].data(), recordedMessages[1].size());
    const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedChunk["number"].GetInt(),0);
    QCOMPARE(expectedChunk["size"].GetInt(),256);
    QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
}

void PlatformOperationsV2Test::flashInvalidValueTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_invalid_value, MockCommand::Flash_firmware);

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->platformId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 3);
    QCOMPARE(operationTimeoutCount_, 1);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(flashPartialStatusCount_, 1);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);

    expectedDoc.Parse(recordedMessages[0].data(), recordedMessages[0].size());
    const rapidjson::Value& expectedPayload = expectedDoc["payload"];
    QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(expectedPayload["size"].GetInt(),768);
    QCOMPARE(expectedPayload["chunks"].GetInt(),3);
    QCOMPARE(expectedPayload["md5"].GetString(),"207fb5670e66e7d6ecd89b5f195c0b71");

    expectedDoc.Parse(recordedMessages[1].data(), recordedMessages[1].size());
    const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
    QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(expectedChunk["number"].GetInt(),0);
    QCOMPARE(expectedChunk["size"].GetInt(),256);
    QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
}

void PlatformOperationsV2Test::cancelFlashOperationTest()
{
    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,512,2,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->run();

    platformOperation->cancelOperation();

    static_cast<operation::Flash*>(platformOperation.get())->flashChunk(QVector<quint8>(256),0); //to verify cancel operation

    QCOMPARE(platformOperation->hasStarted(), true);
    QCOMPARE(platformOperation->isSuccessfullyFinished(), false);
    QCOMPARE(platformOperation->isFinished(), true);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 3); //2 chunks + one fail flash
    QCOMPARE(operationErrorCount_, 0); //flash w/o flash operation (no additional error after cancel)
    QCOMPARE(operationTimeoutCount_, 0);
    QCOMPARE(operationFinishedCount_, 1); //run & cancel operation
    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 0);
}

void PlatformOperationsV2Test::startFlashInvalidTest()
{
    rapidjson::Document expectedDoc;

    mockDevice_->mockSetResponseForCommand(MockResponse::Start_flash_firmware_invalid, MockCommand::Start_flash_firmware);

    OperationSharedPtr platformOperation = platformOperations_.Flash(platform_,768,3,"207fb5670e66e7d6ecd89b5f195c0b71",true);
    connectFlashHandlers(platformOperation.get());
    platformOperation->setResponseTimeouts(RESPONSE_TIMEOUT_TESTS);
    platformOperation->run();

    QTRY_COMPARE_WITH_TIMEOUT(platformOperation->isFinished(), true, 1000);

    QVERIFY(platform_->name().isEmpty());
    QVERIFY(platform_->classId().isEmpty());
    QVERIFY(platform_->platformId().isEmpty());
    QVERIFY(platform_->bootloaderVer().isEmpty());
    QVERIFY(platform_->applicationVer().isEmpty());

    QCOMPARE(operationFailureCount_, 3);
    QCOMPARE(operationFinishedCount_, 1);
    QCOMPARE(operationTimeoutCount_,1);
    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
}
