#include <chrono>
#include <thread>

#include "FlasherTest.h"
#include <rapidjson/writer.h>
#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>
#include <Operations/Identify.h>

#include "FlasherConstants.h"

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
    platform_ = std::make_shared<strata::platform::Platform>(device_);
    expectedChunksCount_ = 0;
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
        deviceOperation_.reset();
    }

    if (device_.get() != nullptr) {
        device_.reset();
    }

    clearExpectedValues();
}

void FlasherTest::clearExpectedValues()
{
    expectedMd5_.clear();
    expectedChunkSize_.clear();
    expectedChunkData_.clear();
    expectedChunkCrc_.clear();
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
        flasherCancelledCount_++;
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
            operation::StartBootloader* startBootloaderOperation = new operation::StartBootloader(platform_);
            deviceOperation_ = QSharedPointer<operation::StartBootloader>(
                        startBootloaderOperation, &QObject::deleteLater);
            startBootloaderOperation->setWaitTime(std::chrono::milliseconds(1)); //bypasses the 5-secs wait-time for bootloader to start
            startBootloaderOperation->run();

            QTRY_COMPARE_WITH_TIMEOUT(startBootloaderOperation->isSuccessfullyFinished(), true, 1000);
            QVERIFY(device_->mockIsBootloader());
        }
        break;
    }
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

void FlasherTest::handleFlashingProgressForDisconnectWhileFlashingTest(int chunk, int total)
{
    if (chunk >= total/2) {
        device_->close();
    }
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

void FlasherTest::connectFlasherForDisconnectWhileFlashingTest(strata::Flasher *flasher)
{
    connect(flasher, &strata::Flasher::flasherState, this, &FlasherTest::handleFlasherState);
    connect(flasher, &strata::Flasher::flashFirmwareProgress, this, &FlasherTest::handleFlashingProgressForDisconnectWhileFlashingTest);
}

void FlasherTest::getMd5(QFile firmware)
{
    if (firmware.open(QIODevice::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Algorithm::Md5);
        hash.addData(&firmware);
        expectedMd5_ = hash.result().toHex();
    }
}

void FlasherTest::getExpectedValues(QFile firmware)
{
    if (firmware.open(QIODevice::ReadOnly)) {
        if (firmware.size() > 0) {

            getMd5(firmware.fileName());

            expectedChunksCount_ = static_cast<int>((firmware.size() - 1 + strata::CHUNK_SIZE) / strata::CHUNK_SIZE);

            while (!firmware.atEnd()) {
                int chunkSize = strata::CHUNK_SIZE;
                qint64 remainingFileSize = firmware.size() - firmware.pos();

                if (remainingFileSize <= strata::CHUNK_SIZE) { //get size of the last chunk
                    chunkSize = static_cast<int>(remainingFileSize);
                }
                QVector<quint8> chunk(chunkSize);
                qint64 bytesRead = firmware.read(reinterpret_cast<char*>(chunk.data()), chunkSize);

                expectedChunkSize_.append(bytesRead);

                size_t firmwareBase64Size = base64::encoded_size(static_cast<size_t>(bytesRead));
                QByteArray firmwareBase64;
                firmwareBase64.resize(static_cast<int>(firmwareBase64Size));
                base64::encode(firmwareBase64.data(), chunk.data(), static_cast<size_t>(bytesRead));

                expectedChunkCrc_.append((crc16::buypass(chunk.data(), static_cast<uint32_t>(bytesRead))));


                if (!firmwareBase64.isNull() || !firmwareBase64.isEmpty()) {
                    expectedChunkData_.append(firmwareBase64);
                }
            }
        }
    }
}

void FlasherTest::flashFirmwareTest()
{
    rapidjson::Document actualDoc;
    QFile firmware("/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeFirmware.bin");
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
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
        actualDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size());
        const rapidjson::Value& actualPayload = actualDoc["payload"];
        QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
        QCOMPARE(actualPayload["size"].GetInt(),firmware.size());
        QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
        QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);
    }
    qDebug() << recordedMessages[7];
    {
        actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }
    qDebug() << recordedMessages[8];
    {
        actualDoc.Parse(recordedMessages[9].data(), recordedMessages[9].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),1);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[1]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[1]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[1]);
    }
    {
        actualDoc.Parse(recordedMessages[10].data(), recordedMessages[10].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),2);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[2]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[2]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[2]);
    }
    {
        actualDoc.Parse(recordedMessages[11].data(), recordedMessages[11].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),3);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[3]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[3]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[3]);
    }
    {
        actualDoc.Parse(recordedMessages[12].data(), recordedMessages[12].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),4);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[4]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[4]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[4]);
    }
    {
        actualDoc.Parse(recordedMessages[13].data(), recordedMessages[13].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),5);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[5]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[5]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[5]);
    }
    {
        actualDoc.Parse(recordedMessages[14].data(), recordedMessages[14].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),6);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[6]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[6]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[6]);
    }
    {
        actualDoc.Parse(recordedMessages[15].data(), recordedMessages[15].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),7);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[7]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[7]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[7]);
    }
    {
        actualDoc.Parse(recordedMessages[16].data(), recordedMessages[16].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),8);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[8]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[8]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[8]);
    }
    {
        actualDoc.Parse(recordedMessages[17].data(), recordedMessages[17].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),9);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[9]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[9]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[9]);
    }
    {
        actualDoc.Parse(recordedMessages[18].data(), recordedMessages[18].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),10);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[10]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[10]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[10]);
    }
    {
        actualDoc.Parse(recordedMessages[19].data(), recordedMessages[19].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),11);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[11]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[11]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[11]);
    }
    {
        actualDoc.Parse(recordedMessages[20].data(), recordedMessages[20].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),12);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[12]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[12]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[12]);
    }
    {
        actualDoc.Parse(recordedMessages[21].data(), recordedMessages[21].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),13);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[13]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[13]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[13]);
    }
    {
        actualDoc.Parse(recordedMessages[22].data(), recordedMessages[22].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),14);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[14]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[14]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[14]);
    }
    {
        actualDoc.Parse(recordedMessages[23].data(), recordedMessages[23].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),15);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[15]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[15]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[15]);
    }
    {
        actualDoc.Parse(recordedMessages[24].data(), recordedMessages[24].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),16);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[16]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[16]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[16]);
    }
    {
        actualDoc.Parse(recordedMessages[25].data(), recordedMessages[25].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),17);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[17]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[17]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[17]);
    }
    {
        actualDoc.Parse(recordedMessages[26].data(), recordedMessages[26].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),18);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[18]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[18]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[18]);
    }
    {
        actualDoc.Parse(recordedMessages[27].data(), recordedMessages[27].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),19);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[19]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[19]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[19]);
    }

    QCOMPARE(recordedMessages[28],test_commands::start_application_request); //start application after flashing
    QCOMPARE(recordedMessages[29],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[30],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),31);
}

void FlasherTest::flashBootloaderTest()
{
    rapidjson::Document actualDoc;
    QFile bootloader("/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeBootloader.bin");
    getExpectedValues(bootloader.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,bootloader.fileName()), &QObject::deleteLater);
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
        actualDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size());
        const rapidjson::Value& expectedPayload = actualDoc["payload"];
        QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_bootloader");
        QCOMPARE(expectedPayload["size"].GetInt(),bootloader.size());
        QCOMPARE(expectedPayload["chunks"].GetInt(),expectedChunksCount_);
        QCOMPARE(expectedPayload["md5"].GetString(),expectedMd5_);
    }
    qDebug() << recordedMessages[7];
    {
        actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }
    qDebug() << recordedMessages[8];
    {
        actualDoc.Parse(recordedMessages[9].data(), recordedMessages[9].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),1);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[1]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[1]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[1]);
    }
    {
        actualDoc.Parse(recordedMessages[10].data(), recordedMessages[10].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),2);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[2]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[2]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[2]);
    }
    {
        actualDoc.Parse(recordedMessages[11].data(), recordedMessages[11].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),3);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[3]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[3]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[3]);
    }
    {
        actualDoc.Parse(recordedMessages[12].data(), recordedMessages[12].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),4);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[4]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[4]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[4]);
    }
    {
        actualDoc.Parse(recordedMessages[13].data(), recordedMessages[13].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),5);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[5]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[5]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[5]);
    }
    {
        actualDoc.Parse(recordedMessages[14].data(), recordedMessages[14].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),6);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[6]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[6]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[6]);
    }
    {
        actualDoc.Parse(recordedMessages[15].data(), recordedMessages[15].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),7);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[7]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[7]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[7]);
    }
    {
        actualDoc.Parse(recordedMessages[16].data(), recordedMessages[16].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),8);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[8]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[8]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[8]);
    }
    {
        actualDoc.Parse(recordedMessages[17].data(), recordedMessages[17].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(),9);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[9]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[9]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[9]);
    }

    QCOMPARE(recordedMessages[18],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[19],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),20);
}


void FlasherTest::flashFirmwareWithoutStartApplicationTest()
{
    rapidjson::Document actualDoc;
    QFile firmware("/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeFirmware.bin");
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashFirmware(false);

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
        actualDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size());
        const rapidjson::Value& actualPayload = actualDoc["payload"];
        QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
        QCOMPARE(actualPayload["size"].GetInt(),firmware.size());
        QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
        QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);
    }
    qDebug() << recordedMessages[7];
    {
        actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }
    qDebug() << recordedMessages[8];
    {
        actualDoc.Parse(recordedMessages[9].data(), recordedMessages[9].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),1);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[1]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[1]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[1]);
    }
    {
        actualDoc.Parse(recordedMessages[10].data(), recordedMessages[10].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),2);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[2]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[2]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[2]);
    }
    {
        actualDoc.Parse(recordedMessages[11].data(), recordedMessages[11].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),3);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[3]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[3]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[3]);
    }
    {
        actualDoc.Parse(recordedMessages[12].data(), recordedMessages[12].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),4);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[4]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[4]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[4]);
    }
    {
        actualDoc.Parse(recordedMessages[13].data(), recordedMessages[13].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),5);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[5]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[5]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[5]);
    }
    {
        actualDoc.Parse(recordedMessages[14].data(), recordedMessages[14].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),6);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[6]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[6]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[6]);
    }
    {
        actualDoc.Parse(recordedMessages[15].data(), recordedMessages[15].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),7);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[7]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[7]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[7]);
    }
    {
        actualDoc.Parse(recordedMessages[16].data(), recordedMessages[16].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),8);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[8]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[8]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[8]);
    }
    {
        actualDoc.Parse(recordedMessages[17].data(), recordedMessages[17].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),9);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[9]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[9]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[9]);
    }
    {
        actualDoc.Parse(recordedMessages[18].data(), recordedMessages[18].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),10);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[10]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[10]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[10]);
    }
    {
        actualDoc.Parse(recordedMessages[19].data(), recordedMessages[19].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),11);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[11]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[11]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[11]);
    }
    {
        actualDoc.Parse(recordedMessages[20].data(), recordedMessages[20].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),12);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[12]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[12]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[12]);
    }
    {
        actualDoc.Parse(recordedMessages[21].data(), recordedMessages[21].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),13);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[13]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[13]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[13]);
    }
    {
        actualDoc.Parse(recordedMessages[22].data(), recordedMessages[22].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),14);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[14]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[14]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[14]);
    }
    {
        actualDoc.Parse(recordedMessages[23].data(), recordedMessages[23].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),15);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[15]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[15]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[15]);
    }
    {
        actualDoc.Parse(recordedMessages[24].data(), recordedMessages[24].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),16);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[16]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[16]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[16]);
    }
    {
        actualDoc.Parse(recordedMessages[25].data(), recordedMessages[25].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),17);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[17]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[17]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[17]);
    }
    {
        actualDoc.Parse(recordedMessages[26].data(), recordedMessages[26].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),18);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[18]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[18]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[18]);
    }
    {
        actualDoc.Parse(recordedMessages[27].data(), recordedMessages[27].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),19);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[19]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[19]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[19]);
    }

    QCOMPARE(recordedMessages[28],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[29],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),30); //without start application
}

void FlasherTest::setFwClassIdTest()
{
    rapidjson::Document actualDoc;
    QFile firmware("/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeFirmware.bin");
    getExpectedValues(firmware.fileName());

    rapidjson::Document expectedDoc;

    operation::Identify* identifyOperation = new operation::Identify(platform_,true);
    deviceOperation_ = QSharedPointer<operation::Identify>(
        identifyOperation, &QObject::deleteLater);
    //connectHandlers(deviceOperation_.data());

    device_->mockSetResponse(MockResponse::assisted_app);

    deviceOperation_->run();
    QCOMPARE(deviceOperation_->deviceId(), "mock1234");
    QTRY_COMPARE_WITH_TIMEOUT(deviceOperation_->isSuccessfullyFinished(), true, 1000);

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(), 2);
    verifyMessage(recordedMessages[0], test_commands::get_firmware_info_request);
    verifyMessage(recordedMessages[1], test_commands::request_platform_id_request);


    qDebug() << platform_->firmwareClassId();

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->setFwClassId();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, 1000);

    qWarning() << flasherErrorCount_ << flasherNoFirmwareCount_ << flasherTimeoutCount_;

    //std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    qDebug() << recordedMessages;
}

void FlasherTest::disconnectWhileFlashingTest()
{
    rapidjson::Document actualDoc;
    QFile firmware("/Users/zbjmjt/work/new/spyglass/libs/flasher/test/fakeFirmware.bin");
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherForDisconnectWhileFlashingTest(flasher_.data());

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherCancelledCount_, 1, 1000);

    qWarning() << flasherErrorCount_ << flasherNoFirmwareCount_ << flasherTimeoutCount_;

    std::vector<QByteArray> recordedMessages = device_->mockGetRecordedMessages();
    qDebug() << recordedMessages;
}
