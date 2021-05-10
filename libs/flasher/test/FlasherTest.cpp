#include <chrono>
#include <thread>

#include "logging/LoggingQtCategories.h"
#include "FlasherTest.h"
#include <rapidjson/writer.h>
#include <Operations/StartBootloader.h>
#include <Operations/StartApplication.h>
#include "FlasherConstants.h"
#include "FlasherTestConstants.h"
#include <CodecBase64.h>
#include <Buypass.h>

using strata::Flasher;
using strata::platform::operation::PlatformOperations;
using strata::platform::operation::OperationSharedPtr;
using strata::platform::operation::BasePlatformOperation;
using strata::device::MockCommand;
using strata::device::MockResponse;
using strata::device::MockVersion;

namespace operation = strata::platform::operation;
namespace test_commands = strata::device::test_commands;
namespace flasher_test_constants = strata::FlasherTestConstants;

FlasherTest::FlasherTest() : platformOperations_(false, false)
{
}

void FlasherTest::initTestCase()
{
    createFiles();
}

void FlasherTest::cleanupTestCase()
{
    cleanFiles();
}

void FlasherTest::init()
{
    flasherFinishedCount_ = 0;
    flasherNoFirmwareCount_ = 0;
    flasherErrorCount_ = 0;
    flasherDisconnectedCount_ = 0;
    flasherTimeoutCount_ = 0;
    flasherCancelledCount_ = 0;

    mockDevice_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    platform_ = std::make_shared<strata::platform::Platform>(mockDevice_);
    expectedChunksCount_ = 0;
    QVERIFY(!mockDevice_->mockIsOpened());

    QSignalSpy platformOpened(platform_.get(), SIGNAL(opened(QByteArray)));
    platform_->open();
    QVERIFY((platformOpened.count() == 1) || (platformOpened.wait(250) == true));
    QVERIFY(mockDevice_->mockIsOpened());
}

void FlasherTest::cleanup()
{
    strata::Flasher *flasherOperation = flasher_.data();
    if (flasherOperation != nullptr) {
        disconnect(flasherOperation, &strata::Flasher::finished, this,
                   &FlasherTest::handleFlasherFinished);
        flasher_.reset();
    }

    disconnect(&platformOperations_, nullptr, this, nullptr);
    platformOperations_.stopAllOperations();

    if (platform_.get() != nullptr) {
        platform_.reset();
    }

    if (mockDevice_.get() != nullptr) {
        mockDevice_.reset();
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

void FlasherTest::handleFlasherFinished(strata::Flasher::Result result, QString)
{
    switch (result) {
    case strata::Flasher::Result::Ok: {
        flasherFinishedCount_++;
        break;
    }
    case strata::Flasher::Result::NoFirmware: {
        flasherNoFirmwareCount_++;
        break;
    }
    case strata::Flasher::Result::Error: {
        flasherErrorCount_++;
        break;
    }
    case strata::Flasher::Result::Timeout: {
        flasherTimeoutCount_++;
        break;
    }
    case strata::Flasher::Result::Disconnect: {
        flasherDisconnectedCount_++;
        break;
    }
    case strata::Flasher::Result::Cancelled: {
        flasherCancelledCount_++;
        break;
    }
    default:
        QFAIL("Recieved an unknown result after Flasher has finished flashing.");
        break;
    }
}

void FlasherTest::handleFlasherState(strata::Flasher::State state, bool done)
{
    switch (state) {
    case strata::Flasher::State::SwitchToBootloader: {
        if (done) {
            break;
        }
        OperationSharedPtr startBootloaderOperation = platformOperations_.StartBootloader(platform_);
        static_cast<operation::StartBootloader*>(startBootloaderOperation.get())->setWaitTime(std::chrono::milliseconds(1)); //Skipping wait-for-bootloader-to-start 5 sec timeout for Tests purporses
        startBootloaderOperation->run();
        QTRY_COMPARE_WITH_TIMEOUT(startBootloaderOperation->isSuccessfullyFinished(), true, flasher_test_constants::TEST_TIMEOUT);
        QVERIFY(mockDevice_->mockIsBootloader());
        break;
    }
    default:
        break;
    }
}

void FlasherTest::handleFlashingProgressForDisconnectWhileFlashing(int chunk, int total)
{
    if (chunk >= total/2) {
        mockDevice_->close(); //Disconnecting device
    }
}

void FlasherTest::handleFlashingProgressForCancelFlashOperation(int chunk, int total)
{
    if (chunk >= total/2) {
        flasher_->cancel(); //Cancel flashing
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

void FlasherTest::connectFlasherHandlers(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
    connect(flasher, &strata::Flasher::flasherState, this, &FlasherTest::handleFlasherState);
}

void FlasherTest::connectFlasherForDisconnectWhileFlashing(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
    connect(flasher, &strata::Flasher::flashFirmwareProgress, this, &FlasherTest::handleFlashingProgressForDisconnectWhileFlashing);
}

void FlasherTest::connectFlasherForCancelFirmwareOperation(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
    connect(flasher, &strata::Flasher::flasherState, this, &FlasherTest::handleFlasherState);
    connect(flasher, &strata::Flasher::flashFirmwareProgress, this, &FlasherTest::handleFlashingProgressForCancelFlashOperation);
    connect(flasher, &strata::Flasher::flashBootloaderProgress, this, &FlasherTest::handleFlashingProgressForCancelFlashOperation);
}

void FlasherTest::createFiles()
{
    fakeFirmware_ = new QFile(QDir(QDir::tempPath()).filePath("fakeFirmware.bin"));
    fakeBootloader_ = new QFile(QDir(QDir::tempPath()).filePath("fakeBootloader.bin"));
    fakeFirmwareBackup_ = new QFile(QDir(QDir::tempPath()).filePath("fakeFirmwareBackup.bin"));

    if (fakeFirmware_->open(QIODevice::ReadWrite) == false) {
        qCCritical(logCategoryFlasher()) << "Cannot open fake firmware file" << fakeFirmware_->fileName() << fakeFirmware_->errorString();
        delete fakeFirmware_;
    } else {
        QTextStream fakeFirmwareOut(fakeFirmware_);
        fakeFirmwareOut << flasher_test_constants::fakeFirmwareData;
        fakeFirmwareOut.flush();
    }

    if (fakeBootloader_->open(QIODevice::ReadWrite) == false) {
        qCCritical(logCategoryFlasher()) << "Cannot open fake bootloader file" << fakeBootloader_->fileName() << fakeBootloader_->errorString();
        delete fakeBootloader_;
    } else {
        QTextStream fakeBootloaderOut(fakeBootloader_);
        fakeBootloaderOut << flasher_test_constants::fakeBootloaderData;
        fakeBootloaderOut.flush();
    }

    if (fakeFirmwareBackup_->open(QIODevice::ReadWrite) == false) {
        qCCritical(logCategoryFlasher()) << "Cannot open fake firmware for backup file" << fakeFirmwareBackup_->fileName() << fakeFirmwareBackup_->errorString();
        delete fakeFirmwareBackup_;
    } else {
        QTextStream fakeFirmwareBackupOut(fakeFirmwareBackup_);
        fakeFirmwareBackupOut << flasher_test_constants::fakeFirmwareData;
        fakeFirmwareBackupOut.flush();
    }

    fakeFirmware_->close();
    fakeBootloader_->close();
    fakeFirmwareBackup_->close();
}

void FlasherTest::cleanFiles()
{
    fakeFirmware_->remove();
    fakeFirmware_->deleteLater();
    fakeBootloader_->remove();
    fakeBootloader_->deleteLater();
    fakeFirmwareBackup_->remove();
    fakeFirmwareBackup_->deleteLater();
}

void FlasherTest::getExpectedValues(QFile firmware)
{
    if (firmware.open(QIODevice::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Algorithm::Md5);
        hash.addData(&firmware);

        expectedMd5_ = hash.result().toHex(); //Get expected md5

        expectedChunksCount_ = static_cast<int>((firmware.size() - 1 + strata::CHUNK_SIZE) / strata::CHUNK_SIZE); //Get expected chunks count

        firmware.seek(0);
        while (!firmware.atEnd()) {
            int chunkSize = strata::CHUNK_SIZE;
            qint64 remainingFileSize = firmware.size() - firmware.pos();

            if (remainingFileSize <= strata::CHUNK_SIZE) { //Get size of the last chunk
                chunkSize = static_cast<int>(remainingFileSize);
            }
            QVector<quint8> chunk(chunkSize);
            qint64 bytesRead = firmware.read(reinterpret_cast<char*>(chunk.data()), chunkSize);

            expectedChunkSize_.append(bytesRead); //Get expected chunk size

            size_t firmwareBase64Size = base64::encoded_size(static_cast<size_t>(bytesRead));
            QByteArray firmwareBase64;
            firmwareBase64.resize(static_cast<int>(firmwareBase64Size));
            base64::encode(firmwareBase64.data(), chunk.data(), static_cast<size_t>(bytesRead));

            expectedChunkCrc_.append((crc16::buypass(chunk.data(), static_cast<uint32_t>(bytesRead)))); //Get expected chunk crc

            if (!firmwareBase64.isNull() || !firmwareBase64.isEmpty()) {
                expectedChunkData_.append(firmwareBase64); //Get expected chunk data
            }
        }
    }
}

void FlasherTest::flashFirmwareTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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

    int messageNumber = 8;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_; chunkNumber++) {
        {
            actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
            const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
            QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
            QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
            QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
            QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
            QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        }
        messageNumber++;
    }

    QCOMPARE(recordedMessages[28],test_commands::start_application_request); //Start application after flashing
    QCOMPARE(recordedMessages[29],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[30],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),31);
}

void FlasherTest::flashFirmwareWithoutStartApplicationTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashFirmware(false);

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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

    int messageNumber = 8;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_; chunkNumber++) {
        {
            actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
            const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
            QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
            QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
            QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
            QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
            QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        }
        messageNumber++;
    }

    QCOMPARE(recordedMessages[28],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[29],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),30); //Without start application
}

void FlasherTest::flashBootloaderTest()
{
    rapidjson::Document actualDoc;
    QFile bootloader(fakeBootloader_->fileName());
    getExpectedValues(bootloader.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,bootloader.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->flashBootloader();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT_BOOTLOADER);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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

    int messageNumber = 8;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_; chunkNumber++) {
        {
            actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
            const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
            QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
            QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
            QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
            QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
            QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        }
        messageNumber++;
    }

    QCOMPARE(recordedMessages[18],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[19],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),20);
}

void FlasherTest::backupFirmwareTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmwareBackup_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName(),expectedMd5_,"00000000-0000-4000-0000-000000000000"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->backupFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[6],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[7],test_commands::start_backup_firmware_request);

    {
    actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size()); //Backup firmware
    const rapidjson::Value& actualRequest = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"backup_firmware");
    QCOMPARE(actualRequest["status"].GetString(),"init");
    }

    qCritical() << recordedMessages[8];

    QCOMPARE(recordedMessages[9],test_commands::start_application_request);
    QCOMPARE(recordedMessages[10],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[11],test_commands::request_platform_id_request);
}

void FlasherTest::setFwClassIdTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName(),expectedMd5_,"00000000-0000-4000-0000-000000000000"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->setFwClassId();

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[6],test_commands::request_platform_id_request);

    {
    actualDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size()); //Set assisted platform id request
    const rapidjson::Value& actualRequest = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"set_assisted_platform_id");
    QCOMPARE(actualRequest["fw_class_id"].GetString(),"00000000-0000-4000-0000-000000000000");
    }

    QCOMPARE(recordedMessages[8],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[9],test_commands::start_application_request);
    QCOMPARE(recordedMessages[10],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[11],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),12);
}

void FlasherTest::setFwClassIdWithoutStartApplicationTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName(),expectedMd5_,"00000000-0000-4000-0000-000000000000"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->setFwClassId(false);

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);

    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[6],test_commands::request_platform_id_request);

    {
    actualDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size()); //Set assisted platform id request
    const rapidjson::Value& actualRequest = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"set_assisted_platform_id");
    QCOMPARE(actualRequest["fw_class_id"].GetString(),"00000000-0000-4000-0000-000000000000");
    }

    QCOMPARE(recordedMessages[8],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages.size(),9);
}

void FlasherTest::startFlashFirmwareInvalidCommandTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Start_flash_firmware_invalid,MockCommand::Start_flash_firmware);

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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

    QCOMPARE(recordedMessages.size(),8);
}

void FlasherTest::startFlashFirmwareFirmwareTooLargeTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Start_flash_firmware_invalid,MockCommand::Start_flash_firmware);

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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

    QCOMPARE(recordedMessages.size(),8);
}

void FlasherTest::flashFirmwareResendChunkTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_resend_chunk,MockCommand::Flash_firmware);

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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
    {
        actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }
    {
        actualDoc.Parse(recordedMessages[9].data(), recordedMessages[9].size()); //Re-sent chunk
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }

    QCOMPARE(recordedMessages.size(),10);
}

void FlasherTest::flashFirmwareMemoryErrorTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_memory_error,MockCommand::Flash_firmware);

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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
    {
        actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }

    QCOMPARE(recordedMessages.size(),9);
}

void FlasherTest::flashFirmwareInvalidCmdSequenceTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_invalid_cmd_sequence,MockCommand::Flash_firmware);

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

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
    {
        actualDoc.Parse(recordedMessages[8].data(), recordedMessages[8].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }

    QCOMPARE(recordedMessages.size(),9);
}

void FlasherTest::disconnectWhileFlashingTest()
{
    QFile firmware(fakeFirmware_->fileName());
    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherForDisconnectWhileFlashing(flasher_.data());

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherDisconnectedCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Device disconnected during firmware operation.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(),0);
}

void FlasherTest::setNoFwClassIdTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->setFwClassId();

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Cannot set firmware class ID, no fwClassId was provided.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(),0);
}

void FlasherTest::flashFirmwareCancelTest()
{
    rapidjson::Document actualDoc;
    QFile firmware(fakeFirmware_->fileName());
    getExpectedValues(firmware.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,firmware.fileName()), &QObject::deleteLater);
    connectFlasherForCancelFirmwareOperation(flasher_.data());

    flasher_->flashFirmware();

    QTRY_COMPARE_WITH_TIMEOUT(flasherCancelledCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Firmware operation was cancelled.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
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

    int messageNumber = 8;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_/2; chunkNumber++) {
        {
            actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
            const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
            QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
            QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
            QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
            QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
            QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        }
        messageNumber++;
    }

    QCOMPARE(recordedMessages.size(),18);
}

void FlasherTest::flashBootloaderCancelTest()
{
    rapidjson::Document actualDoc;
    QFile bootloader(fakeBootloader_->fileName());
    getExpectedValues(bootloader.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,bootloader.fileName()), &QObject::deleteLater);
    connectFlasherForCancelFirmwareOperation(flasher_.data());

    flasher_->flashBootloader();

    QTRY_COMPARE_WITH_TIMEOUT(flasherCancelledCount_, 1, flasher_test_constants::TEST_TIMEOUT_BOOTLOADER); //Flash bootlaoder operation was cancelled.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
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
        QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_bootloader");
        QCOMPARE(actualPayload["size"].GetInt(),bootloader.size());
        QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
        QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);
    }

    int messageNumber = 8;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_/2; chunkNumber++) {
        {
            actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
            const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
            QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
            QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
            QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
            QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
            QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        }
        messageNumber++;
    }

    QCOMPARE(recordedMessages.size(),13);
}
