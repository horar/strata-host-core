#include <chrono>
#include <thread>

#include <CommandValidator.h>
#include <rapidjson/writer.h>
#include "Device/DeviceOperations.h"
#include "DeviceMock.h"
#include "DeviceOperationsDerivate.h"
#include "DeviceOperationsTest.h"

using strata::device::DeviceOperation;
using strata::device::DeviceOperations;
using strata::device::DeviceProperties;

// TODO split off these string constants, put into separate file and use directly in MockDevice

const std::string get_firmware_info_ = R"({"cmd":"get_firmware_info"})";
const std::string get_firmware_info_ack_ =
R"({
    "ack":"get_firmware_info",
    "payload":{"return_value":true,"return_string":"command valid"}
})";
const std::string get_firmware_info_response_ =
R"({
    "notification": {
        "value":"get_firmware_info",
        "payload": {
            "bootloader": {
                "version":"1.1.1",
                "date":"20180401_123420"
            },
            "application": {
                "version":"1.1.2",
                "date":"20180401_131410"
            }
        }
    }
})";

const std::string request_platform_id_ =
R"({
    "cmd":"request_platform_id"
})";
const std::string request_platform_id_ack_ =
R"({
    "ack":"request_platform_id",
    "payload":{"return_value":true,"return_string":"command valid"}
})";
const std::string request_platform_id_response_ =
R"({
   "notification":{
      "value":"platform_id",
      "payload":{
         "name":"ON WaterHeater",
         "platform_id":"101",
         "class_id":"201",
         "count":1,
         "platform_id_version":"2.0"
      }
   }
})";

void DeviceOperationsTest::initTestCase()
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

void DeviceOperationsTest::cleanupTestCase()
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

void DeviceOperationsTest::init()
{
}

void DeviceOperationsTest::cleanup()
{
}

void DeviceOperationsTest::handleOperationFinished(strata::device::DeviceOperation operation, int)
{
    lastFinishedOperation_ = operation;
    operationFinishedCount_++;
}

void DeviceOperationsTest::handleOperationError(QString )
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
    QCOMPARE(device_->mockGetMsgCount(), 0);
    QCOMPARE(operationErrorCount_, 0);
    QCOMPARE(operationFinishedCount_, 0);
    QCOMPARE(lastFinishedOperation_, DeviceOperation::None);
    QCOMPARE(deviceOperations_->mockIsExecutingCommand(), false);
}

void DeviceOperationsTest::identifyTest()
{
    rapidjson::Document doc;
    rapidjson::Document expectedDoc;
    rapidjson::ParseResult parseResult;
    deviceOperations_->identify(false);

    // get_firmware_info and response
    QCOMPARE(deviceOperations_->mockGetOperation(), DeviceOperation::Identify);
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetMsgCount(), 1, 1000);
    parseResult = doc.Parse(device_->mockGetLastMsg().toStdString().c_str());
    QVERIFY(!parseResult.IsError());
    QVERIFY(doc.IsObject());
    expectedDoc.Parse(get_firmware_info_.c_str());
    QCOMPARE(doc, expectedDoc);
    device_->mockEmitMessage(get_firmware_info_ack_);
    device_->mockEmitMessage(get_firmware_info_response_);

    // request_platform_id and response
    QTRY_COMPARE_WITH_TIMEOUT(device_->mockGetMsgCount(), 2, 1000);
    QCOMPARE(deviceOperations_->mockGetOperation(), DeviceOperation::Identify);
    parseResult = doc.Parse(device_->mockGetLastMsg().toStdString().c_str());
    QVERIFY(!parseResult.IsError());
    QVERIFY(doc.IsObject());
    expectedDoc.Parse(request_platform_id_.c_str());
    QCOMPARE(doc, expectedDoc);
    device_->mockEmitMessage(request_platform_id_ack_);
    device_->mockEmitMessage(request_platform_id_response_);

    QTRY_COMPARE_WITH_TIMEOUT(deviceOperations_->mockGetOperation(), DeviceOperation::None, 1000);
    expectedDoc.Parse(request_platform_id_response_.c_str());
    QCOMPARE(device_->property(DeviceProperties::verboseName),
             expectedDoc["notification"]["payload"]["name"].GetString());
    QCOMPARE(device_->property(DeviceProperties::platformId),
             expectedDoc["notification"]["payload"]["platform_id"].GetString());
    QCOMPARE(device_->property(DeviceProperties::classId),
             expectedDoc["notification"]["payload"]["class_id"].GetString());
    expectedDoc.Parse(get_firmware_info_response_.c_str());
    QCOMPARE(device_->property(DeviceProperties::bootloaderVer),
             expectedDoc["notification"]["payload"]["bootloader"]["version"].GetString());
    QCOMPARE(device_->property(DeviceProperties::applicationVer),
             expectedDoc["notification"]["payload"]["application"]["version"].GetString());

    // TODO tests for error situations
}

// TODO tests for DeviceOperations:
// connect to device + init -> done
// command combos:
//   identify
//   switchToBootloader
//   flashFirmwareChunk
//   backupFirmwareChunk
//   startApplication
//   refreshPlatformId
//   cancelOperation
// device error handling
// different command results (nextCommand)
// reset
// signals:
//   finished
//   error

// TODO modify response timer (in DeviceOperations) for tests
