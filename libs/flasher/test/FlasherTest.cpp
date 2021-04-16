#include <chrono>
#include <thread>

#include "FlasherTest.h"
#include <rapidjson/writer.h>
#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>

#include <CodecBase64.h>
#include <Buypass.h>

//constexpr std::chrono::milliseconds RESPONSE_TIMEOUT_TESTS(100);

using strata::Flasher;
using strata::platform::operation::BasePlatformOperation;
using strata::device::MockCommand;
using strata::device::MockResponse;
using strata::device::MockVersion;

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;

void FlasherTest::initTestCase()
{
}

void FlasherTest::cleanupTestCase()
{
}

void FlasherTest::init()
{
    flasherFinishedCount_ = 0;
    flasherNoFirmwareCount_ = 0;
    flasherErrorCount_ = 0;
    flasherTimeoutCount_ = 0;
    device_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    //QVERIFY(device_->mockSetVersion(MockVersion::version2));
    QVERIFY(!device_->mockIsOpened());
    QVERIFY(device_->open());
}

void FlasherTest::cleanup()
{
    strata::Flasher *flasherOperation = flasher_.data();
    if (flasherOperation != nullptr) {
        disconnect(flasherOperation, &strata::Flasher::finished, this,
                   &FlasherTest::handleFlasherFinished);
        flasher_.reset();
    }

    BasePlatformOperation *deviceOperation = deviceOperation_.data();
    if (deviceOperation != nullptr) {
//        disconnect(deviceOperation, &strata::Flasher::finished, this,
//                   &FlasherTest::handleFlasherFinished);
        deviceOperation_.reset();
    }

    if (device_.get() != nullptr) {
        device_.reset();
    }
}

void FlasherTest::handleFlasherFinished(strata::Flasher::Result result, QString er)
{
    switch (result) {
    case strata::Flasher::Result::Ok: {
        qDebug() << er;
        flasherFinishedCount_++;
        break;
    }
    case strata::Flasher::Result::NoFirmware: {
        qWarning() << er;
        flasherNoFirmwareCount_++;
        break;
    }
    case strata::Flasher::Result::Error: {
        qCritical() << er;
        flasherErrorCount_++;
        break;
    }
    case strata::Flasher::Result::Timeout: {
        qWarning() << er;
        flasherTimeoutCount_++;
        break;
    }
    case strata::Flasher::Result::Cancelled: {
        qWarning() << er;
        break;
    }
    default:
        break;
    }
}

void FlasherTest::handleFlasherState(strata::Flasher::State state, bool done)
{
    qDebug() << "Handle flasher state: " << state << " is done: " << done;

    switch (state) {
    case strata::Flasher::State::SwitchToBootloader: {
        if (done) {
            break;
        }
        else {
            operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(device_);
            deviceOperation_ = QSharedPointer<operation::StartBootloader>(
                        startBootloaderOperation, &QObject::deleteLater);
            startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1)); //bypasses the 5-secs wait-time for bootloader to start
            startBootloaderOperation->run();

            QTRY_COMPARE_WITH_TIMEOUT(startBootloaderOperation->isSuccessfullyFinished(), true, 1000);
            QVERIFY(device_->mockIsBootloader());
        }
        break;
    }
//    case strata::Flasher::State::FlashBootloader: {

//        rapidjson::Document expectedDoc;
//        std::vector<QByteArray> request = device_->mockGetRecordedMessages();


//        qCritical() << request.size();
//        qWarning() << request;

//        //expectedDoc.Parse(request[7].data(), request[7].size());
////        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
////        QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_bootloader");
////        QCOMPARE(expectedChunk["number"].GetInt(),0);
////        QCOMPARE(expectedChunk["size"].GetInt(),256);
//        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));

////        chunkSize_ = expectedDoc["payload"]["size"].GetInt();
////        chunkAmount_ = expectedDoc["payload"]["chunks"].GetInt();
////        qDebug() << "There are" << chunkAmount_ << "chunks of size: " << chunkSize_ << "waiting to be flashed.";

//    }
    default:
        break;
    }
}

void FlasherTest::handleFlasherFirmwareProgress(int chunk, int total)
{
    qDebug() << "flashFW: " << chunk << " out of: " << total;
}

void FlasherTest::handleFlasherBootloaderProgress(int chunk, int total)
{
    qDebug() << "flashBootloader: " << chunk << " out of: " << total;
}

void FlasherTest::handleFlasherDevicePropertiesChanged()
{
    qCritical() << "properties changed!";

}

void FlasherTest::printJsonDoc(rapidjson::Document &doc)
{
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    qDebug("%s", buffer.GetString());
}

void FlasherTest::verifyMessage(const QByteArray &msg, const QByteArray &expectedJson)
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

void FlasherTest::connectFlasherHandlers(strata::Flasher *flasher) {
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
    connect(flasher, &strata::Flasher::flasherState, this, &FlasherTest::handleFlasherState);
    connect(flasher, &strata::Flasher::flashFirmwareProgress, this, &FlasherTest::handleFlasherFirmwareProgress);
    connect(flasher, &strata::Flasher::flashBootloaderProgress, this, &FlasherTest::handleFlasherBootloaderProgress);
    connect(flasher, &strata::Flasher::devicePropertiesChanged, this, &FlasherTest::handleFlasherDevicePropertiesChanged);
}

void FlasherTest::flashFirmwareTest()
{
    rapidjson::Document expectedDoc;

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(device_,"/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeFirmware.bin"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[6],test_commands::request_platform_id_request);

    {
        expectedDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size());
        const rapidjson::Value& expectedPayload = expectedDoc["payload"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_firmware");
        QCOMPARE(expectedPayload["size"].GetInt(),5050);
        QCOMPARE(expectedPayload["chunks"].GetInt(),20);
        QCOMPARE(expectedPayload["md5"].GetString(),"7697fc6142b35547d70a7bd624d58c98");
    }
    qDebug() << recordedMessages[7];
    {
        expectedDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),0);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    qDebug() << recordedMessages[8];
    {
        expectedDoc.Parse(recordedMessages[9].data(), recordedMessages[9].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),1);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[10].data(), recordedMessages[10].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),2);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[11].data(), recordedMessages[11].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),3);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[12].data(), recordedMessages[12].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),4);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[13].data(), recordedMessages[13].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),5);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[14].data(), recordedMessages[14].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),6);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[15].data(), recordedMessages[15].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),7);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[16].data(), recordedMessages[16].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),8);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[17].data(), recordedMessages[17].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),9);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[18].data(), recordedMessages[18].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),10);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[19].data(), recordedMessages[19].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),11);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[20].data(), recordedMessages[20].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),12);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[21].data(), recordedMessages[21].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),13);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[22].data(), recordedMessages[22].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),14);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[23].data(), recordedMessages[23].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),15);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[24].data(), recordedMessages[24].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),16);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[25].data(), recordedMessages[25].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),17);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[26].data(), recordedMessages[26].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),18);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[27].data(), recordedMessages[27].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(expectedChunk["number"].GetInt(),19);
        QCOMPARE(expectedChunk["size"].GetInt(),186);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }

    QCOMPARE(recordedMessages[28],test_commands::start_application_request); //start application after flashing
    QCOMPARE(recordedMessages[29],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[30],test_commands::request_platform_id_request);
    qDebug() << recordedMessages[28];
    qDebug() << recordedMessages[29];
    qDebug() << recordedMessages[30];

    QCOMPARE(recordedMessages.size(),31);
}

void FlasherTest::flashBootloaderTest()
{
    rapidjson::Document expectedDoc;

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(device_,"/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeBootloader.bin"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashBootloader();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, 1500);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[6],test_commands::request_platform_id_request);

    {
        expectedDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size());
        const rapidjson::Value& expectedPayload = expectedDoc["payload"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"start_flash_bootloader");
        QCOMPARE(expectedPayload["size"].GetInt(),2559);
        QCOMPARE(expectedPayload["chunks"].GetInt(),10);
        QCOMPARE(expectedPayload["md5"].GetString(),"a76d6cc275356430c9323282139ea6d8");
    }
    qDebug() << recordedMessages[7];
    {
        expectedDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),0);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["crc"].GetInt(),crcForChunk());
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    qDebug() << recordedMessages[8];
    {
        expectedDoc.Parse(recordedMessages[9].data(), recordedMessages[9].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),1);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[10].data(), recordedMessages[10].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),2);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[11].data(), recordedMessages[11].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),3);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[12].data(), recordedMessages[12].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),4);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[13].data(), recordedMessages[13].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),5);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[14].data(), recordedMessages[14].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),6);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[15].data(), recordedMessages[15].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),7);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[16].data(), recordedMessages[16].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),8);
        QCOMPARE(expectedChunk["size"].GetInt(),256);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }
    {
        expectedDoc.Parse(recordedMessages[17].data(), recordedMessages[17].size());
        const rapidjson::Value& expectedChunk = expectedDoc["payload"]["chunk"];
        QCOMPARE(expectedDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(expectedChunk["number"].GetInt(),9);
        QCOMPARE(expectedChunk["size"].GetInt(),255);
        //QCOMPARE(expectedChunk["data"].GetString(),dataForChunkSize(256));
    }

    QCOMPARE(recordedMessages[18],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[19],test_commands::request_platform_id_request);
    qDebug() << recordedMessages[18];
    qDebug() << recordedMessages[19];

    QCOMPARE(recordedMessages.size(),20);
}

void FlasherTest::disconnectWhileFlashingTest()
{
    rapidjson::Document expectedDoc;

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(device_,"/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeFirmware.bin"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, 1000);
}
