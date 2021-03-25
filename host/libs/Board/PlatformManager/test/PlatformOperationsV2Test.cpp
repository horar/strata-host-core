#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include <Operations/Identify.h>
#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>
#include "PlatformOperationsV2Test.h"

using strata::platform::operation::BasePlatformOperation;
using strata::device::MockCommand;
using strata::device::MockResponse;
using strata::device::MockVersion;

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;

constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

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
    device_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    QVERIFY(device_->mockSetVersion(MockVersion::version2));
    QVERIFY(!device_->mockIsOpened());
    QVERIFY(device_->open());
}

void PlatformOperationsV2Test::cleanup()
{
    BasePlatformOperation *operation = platformOperation_.data();
    if (operation != nullptr) {
        disconnect(operation, &BasePlatformOperation::finished, this,
                   &PlatformOperationsV2Test::handleOperationFinished);
        platformOperation_.reset();
    }
    if (device_.get() != nullptr) {
        device_.reset();
    }
}

void PlatformOperationsV2Test::handleOperationFinished(operation::Result result, int, QString)
{
    operationFinishedCount_++;
    if (result == operation::Result::Error) {
        operationErrorCount_++;
    }

    if (result == operation::Result::Timeout) {
        operationTimeoutCount_++;
    }
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

void PlatformOperationsV2Test::connectHandlers(BasePlatformOperation *operation) {
    connect(operation, &BasePlatformOperation::finished, this, &PlatformOperationsV2Test::handleOperationFinished);
}

void PlatformOperationsV2Test::identifyEmbeddedApplicationTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    platformOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::embedded_app);

    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::identifyEmbeddedBootloaderTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    platformOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::embedded_btloader);

    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::identifyAssistedApplicationTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    platformOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_app);

    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::identifyAssistedBootloaderTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    platformOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_btloader);

    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::identifyAssistedNoBoardTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::Identify* identifyOperation = new operation::Identify(device_,true);
    platformOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_no_board);

    platformOperation_->run();
    QCOMPARE(platformOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::switchToBootloaderAndBackEmbeddedTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
    platformOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));

    device_->mockSetResponse(MockResponse::embedded_app);

    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::embedded_app);

    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::switchToBootloaderAndBackAssistedTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
    platformOperation_ = QSharedPointer<operation::StartBootloader>(
            startBootloaderOperation, &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1));

    device_->mockSetResponse(MockResponse::assisted_app);

    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

    platformOperation_ = QSharedPointer<operation::StartApplication>(
        new operation::StartApplication(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isSuccessfullyFinished(), true, 1000);

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

void PlatformOperationsV2Test::cancelOperationEmbeddedTest()
{
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::embedded_btloader);

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

void PlatformOperationsV2Test::cancelOperationAssistedTest()
{
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    platformOperation_ = QSharedPointer<operation::StartBootloader>(
        new operation::StartBootloader(device_), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_btloader);

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

void PlatformOperationsV2Test::noResponseEmbeddedTest()
{
    device_->mockSetAutoResponse(false);
    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponse(MockResponse::embedded_app);

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

void PlatformOperationsV2Test::noResponseAssistedTest()
{
    device_->mockSetAutoResponse(false);
    platformOperation_ = QSharedPointer<operation::Identify>(
        new operation::Identify(device_, true), &QObject::deleteLater);
    connectHandlers(platformOperation_.data());
    platformOperation_->setResponseTimeout(RESPONSE_TIMEOUT_TESTS);

    device_->mockSetResponse(MockResponse::assisted_app);

    platformOperation_->run();
    QTRY_COMPARE_WITH_TIMEOUT(platformOperation_->isFinished(), true, 1000);

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

void PlatformOperationsV2Test::invalidValueV2Test()
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
}
