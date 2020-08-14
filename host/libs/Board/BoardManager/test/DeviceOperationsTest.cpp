#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include "CommandResponseMock.h"
#include "Device/DeviceOperations.h"
#include "DeviceMock.h"
#include "DeviceOperationsDerivate.h"
#include "DeviceOperationsTest.h"

using strata::device::DeviceOperation;
using strata::device::DeviceOperations;
using strata::device::DeviceProperties;

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
    lastFinishedOperation_ = strata::device::DeviceOperation::None;
    device_ = std::make_shared<DeviceMock>(1234, "Mock device");
    bool openRes = device_->open();
    QVERIFY(openRes);
    deviceOperations_ = QSharedPointer<DeviceOperationsDerivate>(
        new DeviceOperationsDerivate(device_), &QObject::deleteLater);
    QCOMPARE(deviceOperations_->deviceId(), 1234);
    connect(deviceOperations_.get(), &DeviceOperations::finished, this,
            &DeviceOperationsTest::handleOperationFinished);
    connect(deviceOperations_.get(), &DeviceOperations::error, this,
            &DeviceOperationsTest::handleOperationError);
}

void DeviceOperationsTest::cleanup()
{
    disconnect(deviceOperations_.get(), &DeviceOperations::finished, this,
               &DeviceOperationsTest::handleOperationFinished);
    disconnect(deviceOperations_.get(), &DeviceOperations::error, this,
               &DeviceOperationsTest::handleOperationError);
    if (deviceOperations_.get() != nullptr) {
        deviceOperations_.reset();
    }
    if (device_.get() != nullptr) {
        device_.reset();
    }
}

void DeviceOperationsTest::handleOperationFinished(strata::device::DeviceOperation operation, int)
{
    lastFinishedOperation_ = operation;
    operationFinishedCount_++;
}

void DeviceOperationsTest::handleOperationError(QString)
{
    operationErrorCount_++;
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
    QCOMPARE(operationFinishedCount_, 0);
    QCOMPARE(lastFinishedOperation_, DeviceOperation::None);
    QCOMPARE(deviceOperations_->mockIsExecutingCommand(), false);
}

void DeviceOperationsTest::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    parseResult = doc.Parse(msg.toStdString().c_str());
    QVERIFY(!parseResult.IsError());
    QVERIFY(doc.IsObject());
    expectedDoc.Parse(expectedJson.toStdString().c_str());
    if (doc != expectedDoc) {
        printJsonDoc(doc);
        printJsonDoc(expectedDoc);
    }
    QCOMPARE(doc, expectedDoc);
}

void DeviceOperationsTest::identifyTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperations_->identify(false);
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperations_->mockGetOperation(), DeviceOperation::None, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);

    expectedDoc.Parse(test_commands::request_platform_id_response.toStdString().c_str());
    QCOMPARE(device_->property(DeviceProperties::verboseName),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->property(DeviceProperties::platformId),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->property(DeviceProperties::classId),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.toStdString().c_str());
    QCOMPARE(device_->property(DeviceProperties::bootloaderVer),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->property(DeviceProperties::applicationVer),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    // TODO tests for error situations
}

void DeviceOperationsTest::switchToBootloaderAndBackTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperations_->switchToBootloader();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperations_->mockGetOperation(), DeviceOperation::None, 6000);

    QVERIFY(device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response_bootloader.toStdString().c_str());
    QCOMPARE(device_->property(DeviceProperties::verboseName),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->property(DeviceProperties::platformId),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->property(DeviceProperties::classId),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.toStdString().c_str());
    QCOMPARE(device_->property(DeviceProperties::bootloaderVer),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->property(DeviceProperties::applicationVer),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    deviceOperations_->startApplication();
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperations_->mockGetOperation(), DeviceOperation::None, 1000);

    QVERIFY(!device_->mockIsBootloader());
    expectedDoc.Parse(test_commands::request_platform_id_response.toStdString().c_str());
    QCOMPARE(device_->property(DeviceProperties::verboseName),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->property(DeviceProperties::platformId),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->property(DeviceProperties::classId),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(test_commands::get_firmware_info_response.toStdString().c_str());
    QCOMPARE(device_->property(DeviceProperties::bootloaderVer),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->property(DeviceProperties::applicationVer),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 7);
    verifyMessage(recordedMessages[0], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[1], test_commands::update_firmware_request);
    verifyMessage(recordedMessages[2], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[3], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[4], test_commands::start_application_request);
    verifyMessage(recordedMessages[5], test_commands::request_platform_id_request);
    verifyMessage(recordedMessages[6], test_commands::get_firmware_info_request);
}

void DeviceOperationsTest::cancelOperationTest()
{
    device_->mockSetAutoResponse(false);
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;

    deviceOperations_->switchToBootloader();
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetMsgCount(), 1, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::request_platform_id_request);

    deviceOperations_->cancelOperation();

    QCOMPARE(deviceOperations_->mockGetOperation(), DeviceOperation::None);

    recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 1);
    verifyMessage(recordedMessages[0], test_commands::request_platform_id_request);
}

// TODO tests for DeviceOperations:
// connect to device + init -> done
// command combos:
//   identify
//   switchToBootloader
//   startApplication
//   flashFirmwareChunk
//   backupFirmwareChunk
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
