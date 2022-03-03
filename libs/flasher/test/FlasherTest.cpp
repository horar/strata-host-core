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

#include "FlasherTest.h"
#include <rapidjson/writer.h>
#include "FlasherTestConstants.h"
#include <FlasherConstants.h>
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

QTEST_MAIN(FlasherTest)

FlasherTest::FlasherTest() :
    platformOperations_(false, false),
    fakeFirmware_(QDir(QDir::tempPath()).filePath(QStringLiteral("fake_firmware"))),
    fakeBootloader_(QDir(QDir::tempPath()).filePath(QStringLiteral("fake_bootloader")))
{
}

void FlasherTest::initTestCase()
{
    createFiles();
}

void FlasherTest::cleanupTestCase()
{
    if (fakeFirmwareBackupName_.isEmpty() == false) {
        QFile::remove(fakeFirmwareBackupName_);
    }
}

void FlasherTest::init()
{
    flasherFinishedCount_ = 0;
    flasherOkCount_ = 0;
    flasherNoFirmwareCount_ = 0;
    flasherErrorCount_ = 0;
    flasherDisconnectedCount_ = 0;
    flasherTimeoutCount_ = 0;
    flasherCancelledCount_ = 0;

    mockDevice_ = std::make_shared<strata::device::MockDevice>("mock1234", "Mock device", true);
    platform_ = std::make_shared<strata::platform::Platform>(mockDevice_);
    mockDevice_->mockSetVersion(MockVersion::Version_2);
    QVERIFY(mockDevice_->mockGetVersion() == MockVersion::Version_2);
    expectedChunksCount_ = 0;
    QVERIFY(platform_->deviceConnected() == false);

    QSignalSpy platformOpened(platform_.get(), SIGNAL(opened()));
    platform_->open();
    QVERIFY((platformOpened.count() == 1) || (platformOpened.wait(250) == true));
    QVERIFY(platform_->deviceConnected());
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

void FlasherTest::handleFlasherFinished(strata::Flasher::Result result, QString)
{
    flasherFinishedCount_++;
    switch (result) {
    case strata::Flasher::Result::Ok: {
        flasherOkCount_++;
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

void FlasherTest::handleFlashingProgressForDisconnectDuringFlashOperation(int chunk, int total)
{
    if (chunk >= total/2) {
        mockDevice_->close(); //Disconnecting device
    }
}

void FlasherTest::handleFlashingProgressForCancelDuringFlashOperation(int chunk, int total)
{
    if (chunk >= total/2) {
        flasher_->cancel(); //Cancel flashing
    }
}

void FlasherTest::handleBackupProgressForDisconnectDuringBackupOperation(int chunk, int total)
{
    if (chunk >= total/2) {
        mockDevice_->close();
    }
}

void FlasherTest::handleBackupProgressForCancelDuringBackupOperation(int chunk, int total)
{
    if (chunk >= total/2) {
        flasher_->cancel();
    }
}

void FlasherTest::handleFlasherState(Flasher::State flasherState, bool done)
{
    if ((flasherState == Flasher::State::StartApplication) && (done == false)) {
        mockDevice_->mockSetResponseForCommand(MockResponse::Normal, MockCommand::Get_firmware_info);
        mockDevice_->mockSetResponseForCommand(MockResponse::Normal, MockCommand::Request_platform_id);
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

void FlasherTest::connectFlasherHandlers(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
}

void FlasherTest::connectFlasherForDisconnectDuringFlashOperation(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
    connect(flasher, &strata::Flasher::flashFirmwareProgress, this, &FlasherTest::handleFlashingProgressForDisconnectDuringFlashOperation);
    connect(flasher, &strata::Flasher::backupFirmwareProgress, this, &FlasherTest::handleBackupProgressForDisconnectDuringBackupOperation);
}

void FlasherTest::connectFlasherForCancelFlashOperation(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::finished, this, &FlasherTest::handleFlasherFinished);
    connect(flasher, &strata::Flasher::flashFirmwareProgress, this, &FlasherTest::handleFlashingProgressForCancelDuringFlashOperation);
    connect(flasher, &strata::Flasher::flashBootloaderProgress, this, &FlasherTest::handleFlashingProgressForCancelDuringFlashOperation);
    connect(flasher, &strata::Flasher::backupFirmwareProgress, this, &FlasherTest::handleBackupProgressForCancelDuringBackupOperation);
}

void FlasherTest::connectFlasherForSwitchingFromBootloader(strata::Flasher *flasher) const
{
    connect(flasher, &strata::Flasher::flasherState, this, &FlasherTest::handleFlasherState);
}

void FlasherTest::createFiles()
{
    if (fakeFirmware_.open() == false) {
        QFAIL("Cannot open fake firmware file");
    } else {
        QDataStream fakeFirmwareOut(&fakeFirmware_);
        fakeFirmwareOut << mockDevice_->generateMockFirmware();
        fakeFirmware_.close();
    }

    if (fakeBootloader_.open() == false) {
        QFAIL("Cannot open fake bootloader file");
    } else {
        QDataStream fakeBootloaderOut(&fakeBootloader_);
        fakeBootloaderOut << mockDevice_->generateMockFirmware(true);
        fakeBootloader_.close();
    }

    QTemporaryFile fakeFirmwareBackup(QDir(QDir::tempPath()).filePath(QStringLiteral("fake_firmware_backup")));
    if (fakeFirmwareBackup.open() == false) {
        QFAIL("Cannot open fake firmware for backup file");
    } else {
        fakeFirmwareBackupName_ = fakeFirmwareBackup.fileName();
        fakeFirmwareBackup.close();
    }
}

void FlasherTest::getExpectedValues(QString firmwarePath)
{
    QFile firmware(firmwarePath);

    if (firmware.open(QIODevice::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Algorithm::Md5);
        hash.addData(&firmware);

        expectedMd5_ = hash.result().toHex();

        expectedChunksCount_ = static_cast<int>((firmware.size() - 1 + strata::CHUNK_SIZE) / strata::CHUNK_SIZE); //Get expected chunks count

        firmware.seek(0);
        while (firmware.atEnd() == false) {
            int chunkSize = strata::CHUNK_SIZE;
            qint64 remainingFileSize = firmware.size() - firmware.pos();

            if (remainingFileSize <= strata::CHUNK_SIZE) {
                chunkSize = static_cast<int>(remainingFileSize);
            }
            QVector<quint8> chunk(chunkSize);
            qint64 bytesRead = firmware.read(reinterpret_cast<char*>(chunk.data()), chunkSize);

            expectedChunkSize_.append(bytesRead);

            size_t firmwareBase64Size = base64::encoded_size(static_cast<size_t>(bytesRead));
            QByteArray firmwareBase64;
            firmwareBase64.resize(static_cast<int>(firmwareBase64Size));
            base64::encode(firmwareBase64.data(), chunk.data(), static_cast<size_t>(bytesRead));

            expectedChunkCrc_.append((crc16::buypass(chunk.data(), static_cast<uint32_t>(bytesRead)))); //Get expected chunk crc

            if (firmwareBase64.isEmpty() == false) {
                expectedChunkData_.append(firmwareBase64);
            }
        }
    } else {
        QFAIL("Cannot open firmware.");
    }
}

void FlasherTest::clearExpectedValues()
{
    expectedMd5_.clear();
    expectedChunkSize_.clear();
    expectedChunkData_.clear();
    expectedChunkCrc_.clear();
}

void FlasherTest::flashFirmware(bool startInBootloader, Flasher::FinalAction finalAction)
{
    rapidjson::Document actualDoc;
    uint messageIndex(0);
    getExpectedValues(fakeFirmware_.fileName());

    if (startInBootloader) {
        mockDevice_->mockSetAsBootloader(true); // MockDevice starts in Bootloader mode
        QVERIFY(mockDevice_->mockIsBootloader());
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Get_firmware_info);
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Request_platform_id);
    }

    flasher_ = QSharedPointer<Flasher>(
                new Flasher(platform_, fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    connectFlasherForSwitchingFromBootloader(flasher_.data());

    flasher_->flashFirmware(finalAction);

    QTRY_COMPARE_WITH_TIMEOUT(flasherOkCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    bool startApplication = true;
    if (finalAction == Flasher::FinalAction::StayInBootloader
        || (startInBootloader && finalAction == Flasher::FinalAction::PreservePlatformState))
    {
        startApplication = false;
    }

    uint messageCount = 23;
    if (startInBootloader == false) {
        messageCount += 3;
    }
    if (startApplication) {
        messageCount += 3;
    }

    QCOMPARE(recordedMessages.size(), messageCount);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    if (startInBootloader == false) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_bootloader_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    }

    actualDoc.Parse(recordedMessages[messageIndex].data(), recordedMessages[messageIndex].size());
    ++messageIndex;
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(), "start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(), fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(), expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(), expectedMd5_);

    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_; chunkNumber++) {
        actualDoc.Parse(recordedMessages[messageIndex].data(), recordedMessages[messageIndex].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(), "flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
        QCOMPARE(actualChunk["size"].GetInt(), expectedChunkSize_[chunkNumber]);
        QCOMPARE(actualChunk["crc"].GetInt(), expectedChunkCrc_[chunkNumber]);
        QCOMPARE(actualChunk["data"].GetString(), expectedChunkData_[chunkNumber]);
        ++messageIndex;
    }

    if (startApplication) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_application_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex], test_commands::request_platform_id_request);
    }

    QCOMPARE(flasherFinishedCount_, 1);
}

void FlasherTest::flashBootloader(bool startInBootloader)
{
    rapidjson::Document actualDoc;
    uint messageIndex(0);
    getExpectedValues(fakeBootloader_.fileName());

    if (startInBootloader) {
        mockDevice_->mockSetAsBootloader(true); // MockDevice starts in Bootloader mode
        QVERIFY(mockDevice_->mockIsBootloader());
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Get_firmware_info);
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Request_platform_id);
    }

    flasher_ = QSharedPointer<Flasher>(
                new Flasher(platform_, fakeBootloader_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    connectFlasherForSwitchingFromBootloader(flasher_.data());

    flasher_->flashBootloader();

    QTRY_COMPARE_WITH_TIMEOUT(flasherOkCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    uint messageCount = 15;
    if (startInBootloader == false) {
        messageCount += 3;
    }

    QCOMPARE(recordedMessages.size(), messageCount);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    if (startInBootloader == false) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_bootloader_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    }

    actualDoc.Parse(recordedMessages[messageIndex].data(), recordedMessages[messageIndex].size());
    ++messageIndex;
    const rapidjson::Value& expectedPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(), "start_flash_bootloader");
    QCOMPARE(expectedPayload["size"].GetInt(), fakeBootloader_.size());
    QCOMPARE(expectedPayload["chunks"].GetInt(), expectedChunksCount_);
    QCOMPARE(expectedPayload["md5"].GetString(), expectedMd5_);

    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_; chunkNumber++) {
        actualDoc.Parse(recordedMessages[messageIndex].data(), recordedMessages[messageIndex].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(), "flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
        QCOMPARE(actualChunk["size"].GetInt(), expectedChunkSize_[chunkNumber]);
        QCOMPARE(actualChunk["crc"].GetInt(), expectedChunkCrc_[chunkNumber]);
        QCOMPARE(actualChunk["data"].GetString(), expectedChunkData_[chunkNumber]);
        ++messageIndex;
    }

    QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[messageIndex], test_commands::request_platform_id_request);

    QCOMPARE(flasherFinishedCount_, 1);
}

void FlasherTest::setFwClassId(bool startInBootloader, strata::Flasher::FinalAction finalAction)
{
    rapidjson::Document actualDoc;
    uint messageIndex(0);
    getExpectedValues(fakeFirmware_.fileName());

    if (startInBootloader) {
        mockDevice_->mockSetAsBootloader(true); // MockDevice starts in Bootloader mode
        QVERIFY(mockDevice_->mockIsBootloader());
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Get_firmware_info);
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Request_platform_id);
    }

    flasher_ = QSharedPointer<Flasher>(
                new Flasher(platform_, fakeFirmware_.fileName(), expectedMd5_, "00000000-0000-4000-0000-000000000000"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    connectFlasherForSwitchingFromBootloader(flasher_.data());

    flasher_->setFwClassId(finalAction);

    QTRY_COMPARE_WITH_TIMEOUT(flasherOkCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    bool startApplication = true;
    if (finalAction == Flasher::FinalAction::StayInBootloader
        || (startInBootloader && finalAction == Flasher::FinalAction::PreservePlatformState))
    {
        startApplication = false;
    }

    uint messageCount = 4;
    if (startInBootloader == false) {
        messageCount += 3;
    }
    if (startApplication) {
        messageCount += 3;
    }

    QCOMPARE(recordedMessages.size(), messageCount);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    if (startInBootloader == false) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_bootloader_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    }

    actualDoc.Parse(recordedMessages[messageIndex].data(), recordedMessages[messageIndex].size()); //Set assisted platform id request
    ++messageIndex;
    const rapidjson::Value& actualRequest = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(), "set_assisted_platform_id");
    QCOMPARE(actualRequest["fw_class_id"].GetString(), "00000000-0000-4000-0000-000000000000");

    QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    if (startApplication) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_application_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex], test_commands::request_platform_id_request);
    }

    QCOMPARE(flasherFinishedCount_, 1);
}

void FlasherTest::backupFirmware(bool startInBootloader, strata::Flasher::FinalAction finalAction)
{
    uint messageIndex(0);
    getExpectedValues(fakeFirmware_.fileName());

    if (startInBootloader) {
        mockDevice_->mockSetFirmwareEnabled(true);
        mockDevice_->mockSetAsBootloader(true); // MockDevice starts in Bootloader mode
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Get_firmware_info);
        mockDevice_->mockSetResponseForCommand(MockResponse::Platform_config_embedded_bootloader, MockCommand::Request_platform_id);
    }

    flasher_ = QSharedPointer<Flasher>(
                new Flasher(platform_, fakeFirmwareBackupName_, expectedMd5_, "00000000-0000-4000-0000-000000000000"), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    connectFlasherForSwitchingFromBootloader(flasher_.data());

    flasher_->backupFirmware(finalAction);

    QTRY_COMPARE_WITH_TIMEOUT(flasherFinishedCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    bool startApplication = true;
    if (finalAction == Flasher::FinalAction::StayInBootloader
        || (startInBootloader && finalAction == Flasher::FinalAction::PreservePlatformState))
    {
        startApplication = false;
    }

    uint messageCount = 23;
    if (startInBootloader == false) {
        messageCount += 3;
    }
    if (startApplication) {
        messageCount += 3;
    }

    QCOMPARE(recordedMessages.size(), messageCount);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    if (startInBootloader == false) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_bootloader_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::request_platform_id_request);
    }

    QCOMPARE(recordedMessages[messageIndex++], test_commands::start_backup_firmware_request);
    QCOMPARE(recordedMessages[messageIndex++], test_commands::backup_firmware_request_init);

    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_ - 1; chunkNumber++) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::backup_firmware_request);
    }

    if (startApplication) {
        QCOMPARE(recordedMessages[messageIndex++], test_commands::start_application_request);
        QCOMPARE(recordedMessages[messageIndex++], test_commands::get_firmware_info_request);
        QCOMPARE(recordedMessages[messageIndex], test_commands::request_platform_id_request);
    }

    QCOMPARE(flasherFinishedCount_, 1);

    QFile backedUpFirmware(fakeFirmwareBackupName_);

    if (fakeFirmware_.open()) {
        if (backedUpFirmware.open(QIODevice::ReadOnly)) {
            QCOMPARE(backedUpFirmware.readAll(), fakeFirmware_.readAll()); //Compare backed up data with the actual source
            backedUpFirmware.close();
        } else {
            QFAIL("Failed to open backed up firmware file.");
        }
        fakeFirmware_.close();
    } else {
        QFAIL("Failed to open fake firmware source file.");
    }
}

void FlasherTest::flashFirmwareApplicationToApplicationTest()
{
    flashFirmware(false, Flasher::FinalAction::StartApplication);
}

void FlasherTest::flashFirmwareApplicationToBootloaderTest()
{
    flashFirmware(false, Flasher::FinalAction::StayInBootloader);
}

void FlasherTest::flashFirmwareApplicationToPreserveStateTest()
{
    flashFirmware(false, Flasher::FinalAction::PreservePlatformState);
}

void FlasherTest::flashFirmwareBootloaderToApplicationTest()
{
    flashFirmware(true, Flasher::FinalAction::StartApplication);
}

void FlasherTest::flashFirmwareBootloaderToBootloaderTest()
{
    flashFirmware(true, Flasher::FinalAction::StayInBootloader);
}

void FlasherTest::flashFirmwareBootloaderToPreserveStateTest()
{
    flashFirmware(true, Flasher::FinalAction::PreservePlatformState);
}

void FlasherTest::flashBootloaderFromApplicationTest()
{
    flashBootloader(false);
}

void FlasherTest::flashBootloaderFromBootloaderTest()
{
    flashBootloader(true);
}

void FlasherTest::setFwClassIdApplicationToApplicationTest()
{
    setFwClassId(false, Flasher::FinalAction::StartApplication);
}

void FlasherTest::setFwClassIdApplicationToBootloaderTest()
{
    setFwClassId(false, Flasher::FinalAction::StayInBootloader);
}

void FlasherTest::setFwClassIdApplicationToPreserveStateTest()
{
    setFwClassId(false, Flasher::FinalAction::PreservePlatformState);
}

void FlasherTest::setFwClassIdBootloaderToApplicationTest()
{
    setFwClassId(true, Flasher::FinalAction::StartApplication);
}

void FlasherTest::setFwClassIdBootloaderToBootloaderTest()
{
    setFwClassId(true, Flasher::FinalAction::StayInBootloader);
}

void FlasherTest::setFwClassIdBootloaderToPreserveStateTest()
{
    setFwClassId(true, Flasher::FinalAction::PreservePlatformState);
}

void FlasherTest::startFlashFirmwareInvalidCommandTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Start_flash_firmware_invalid_command,MockCommand::Start_flash_firmware);

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),6);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(),fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::startFlashFirmwareFirmwareTooLargeTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Start_flash_firmware_too_large,MockCommand::Start_flash_firmware);

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),6);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(),fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::flashFirmwareResendChunkTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_resend_chunk,MockCommand::Flash_firmware);

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),8);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(),fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);
    {
        actualDoc.Parse(recordedMessages[6].data(), recordedMessages[6].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }
    {
        actualDoc.Parse(recordedMessages[7].data(), recordedMessages[7].size()); //Re-sent chunk
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(),0);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);
    }

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::flashFirmwareMemoryErrorTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_memory_error,MockCommand::Flash_firmware);

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),7);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(),fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);

    actualDoc.Parse(recordedMessages[6].data(), recordedMessages[6].size());
    const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
    QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(actualChunk["number"].GetInt(),0);
    QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
    QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
    QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::flashFirmwareInvalidCmdSequenceTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());
    mockDevice_->mockSetResponseForCommand(MockResponse::Flash_firmware_invalid_cmd_sequence,MockCommand::Flash_firmware);

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),7);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(),fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);

    actualDoc.Parse(recordedMessages[6].data(), recordedMessages[6].size());
    const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
    QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
    QCOMPARE(actualChunk["number"].GetInt(),0);
    QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[0]);
    QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[0]);
    QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[0]);

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::disconnectDuringFlashTest()
{
    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherForDisconnectDuringFlashOperation(flasher_.data());

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherDisconnectedCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Device disconnected during firmware operation.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(),0);
    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::setNoFwClassIdTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->setFwClassId(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherErrorCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Cannot set firmware class ID, no fwClassId was provided.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(),0);
    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::flashFirmwareCancelTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeFirmware_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherForCancelFlashOperation(flasher_.data());

    flasher_->flashFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherCancelledCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Firmware operation was cancelled.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),16);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_firmware");
    QCOMPARE(actualPayload["size"].GetInt(),fakeFirmware_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);

    int messageNumber = 6;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_/2; chunkNumber++) {
        actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_firmware");
        QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        messageNumber++;
    }

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::flashBootloaderCancelTest()
{
    rapidjson::Document actualDoc;
    getExpectedValues(fakeBootloader_.fileName());

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeBootloader_.fileName()), &QObject::deleteLater);
    connectFlasherForCancelFlashOperation(flasher_.data());

    flasher_->flashBootloader();

    QTRY_COMPARE_WITH_TIMEOUT(flasherCancelledCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Flash bootlaoder operation was cancelled.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),11);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    actualDoc.Parse(recordedMessages[5].data(), recordedMessages[5].size());
    const rapidjson::Value& actualPayload = actualDoc["payload"];
    QCOMPARE(actualDoc["cmd"].GetString(),"start_flash_bootloader");
    QCOMPARE(actualPayload["size"].GetInt(),fakeBootloader_.size());
    QCOMPARE(actualPayload["chunks"].GetInt(),expectedChunksCount_);
    QCOMPARE(actualPayload["md5"].GetString(),expectedMd5_);

    int messageNumber = 6;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_/2; chunkNumber++) {
        actualDoc.Parse(recordedMessages[messageNumber].data(), recordedMessages[messageNumber].size());
        const rapidjson::Value& actualChunk = actualDoc["payload"]["chunk"];
        QCOMPARE(actualDoc["cmd"].GetString(),"flash_bootloader");
        QCOMPARE(actualChunk["number"].GetInt(), chunkNumber);
        QCOMPARE(actualChunk["size"].GetInt(),expectedChunkSize_[chunkNumber]);
        QCOMPARE(actualChunk["crc"].GetInt(),expectedChunkCrc_[chunkNumber]);
        QCOMPARE(actualChunk["data"].GetString(),expectedChunkData_[chunkNumber]);
        messageNumber++;
    }

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::backupFirmwareApplicationToApplicationTest()
{
    backupFirmware(false, Flasher::FinalAction::StartApplication);
}

void FlasherTest::backupFirmwareApplicationToBootloaderTest()
{
    backupFirmware(false, Flasher::FinalAction::StayInBootloader);
}

void FlasherTest::backupFirmwareApplicationToPreserveStateTest()
{
    backupFirmware(false, Flasher::FinalAction::PreservePlatformState);
}

void FlasherTest::backupFirmwareBootloaderToApplicationTest()
{
    backupFirmware(true, Flasher::FinalAction::StartApplication);
}

void FlasherTest::backupFirmwareBootloaderToBootloaderTest()
{
    backupFirmware(true, Flasher::FinalAction::StayInBootloader);
}

void FlasherTest::backupFirmwareBootloaderToPreserveStateTest()
{
    backupFirmware(true, Flasher::FinalAction::PreservePlatformState);
}

void FlasherTest::disconnectDuringBackupTest()
{
    getExpectedValues(fakeFirmware_.fileName());
    mockDevice_->mockSetFirmwareEnabled(true);

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmware_.fileName()), &QObject::deleteLater);
    connectFlasherForDisconnectDuringFlashOperation(flasher_.data());

    flasher_->backupFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherDisconnectedCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Device disconnected during firmware operation.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();
    QCOMPARE(recordedMessages.size(),0);
    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::backupFirmwareCancelTest()
{
    getExpectedValues(fakeBootloader_.fileName());
    mockDevice_->mockSetFirmwareEnabled(true);

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeBootloader_.fileName()), &QObject::deleteLater);
    connectFlasherForCancelFlashOperation(flasher_.data());

    flasher_->backupFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherCancelledCount_, 1, flasher_test_constants::TEST_TIMEOUT); //Flash bootlaoder operation was cancelled.

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),16);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);

    QCOMPARE(recordedMessages[5],test_commands::start_backup_firmware_request);
    QCOMPARE(recordedMessages[6],test_commands::backup_firmware_request_init);

    int messageNumber = 7;
    for (int chunkNumber = 0; chunkNumber < expectedChunksCount_/2; chunkNumber++) {
    QCOMPARE(recordedMessages[messageNumber],test_commands::backup_firmware_request);
        messageNumber++;
    }

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::startBackupNoFirmwareTest()
{
    mockDevice_->mockSetFirmwareEnabled(false);

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmwareBackupName_), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->backupFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherNoFirmwareCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(), 6);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::start_backup_firmware_request);

    QCOMPARE(flasherFinishedCount_,1);
}

void FlasherTest::backupNoFirmwareTest()
{
    mockDevice_->mockSetFirmwareEnabled(false);

    flasher_ = QSharedPointer<strata::Flasher>(
                new strata::Flasher(platform_,fakeFirmwareBackupName_), &QObject::deleteLater);
    connectFlasherHandlers(flasher_.data());

    flasher_->backupFirmware(Flasher::FinalAction::StartApplication);

    QTRY_COMPARE_WITH_TIMEOUT(flasherNoFirmwareCount_, 1, flasher_test_constants::TEST_TIMEOUT);

    std::vector<QByteArray> recordedMessages = mockDevice_->mockGetRecordedMessages();

    QCOMPARE(recordedMessages.size(),6);
    QCOMPARE(recordedMessages[0],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[1],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[2],test_commands::start_bootloader_request);
    QCOMPARE(recordedMessages[3],test_commands::get_firmware_info_request);
    QCOMPARE(recordedMessages[4],test_commands::request_platform_id_request);
    QCOMPARE(recordedMessages[5],test_commands::start_backup_firmware_request);

    QCOMPARE(flasherFinishedCount_,1);
}
